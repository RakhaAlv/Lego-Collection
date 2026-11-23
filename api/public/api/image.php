<?php
/**
 * Proxy & Cache Gambar Produk LEGO (`api/image.php?set=76269` atau `?theme=1`).
 *
 * Alur kerja:
 * 1. Kirim header CORS agar Flutter Web & Android bebas error 400/403.
 * 2. Cek cache lokal di `api/public/images/`.
 * 3. Jika belum ada di cache (untuk `?set=`), ambil halaman `lego.com/id-id/product/...`
 *    via cURL, ekstrak `<meta property="og:image" content="...">`, lalu simpan ke cache.
 * 4. Jika lego.com memblokir / timeout, buat gambar PNG fallback lokal lewat GD
 *    dan kirim dengan HTTP 200.
 */
declare(strict_types=1);

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$imagesDir = dirname(__DIR__) . '/images';
if (!is_dir($imagesDir)) {
    @mkdir($imagesDir, 0777, true);
}

function send_cached_file(string $path): void
{
    $ext = strtolower(pathinfo($path, PATHINFO_EXTENSION));
    $mime = [
        'png' => 'image/png',
        'jpg' => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'webp' => 'image/webp',
    ][$ext] ?? 'image/png';
    header('Content-Type: ' . $mime);
    header('Cache-Control: public, max-age=86400');
    header('Content-Length: ' . filesize($path));
    readfile($path);
    exit;
}

function find_cached_image(string $dir, string $prefix): ?string
{
    foreach (['jpg', 'jpeg', 'png', 'webp'] as $ext) {
        $candidate = $dir . '/' . $prefix . '.' . $ext;
        if (is_file($candidate) && filesize($candidate) > 0) {
            return $candidate;
        }
    }
    return null;
}

function curl_fetch(string $url): ?string
{
    if (!function_exists('curl_init')) {
        return null;
    }
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_FOLLOWLOCATION => true,
        CURLOPT_TIMEOUT => 5,
        CURLOPT_CONNECTTIMEOUT => 3,
        CURLOPT_USERAGENT => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36',
        CURLOPT_HTTPHEADER => ['Accept-Language: id-ID,id;q=0.9,en-US;q=0.8'],
    ]);
    $body = curl_exec($ch);
    $status = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    if ($body === false || $status < 200 || $status >= 400) {
        return null;
    }
    return (string) $body;
}

function try_fetch_lego_og_image(string $productUrl, string $dir, string $prefix): ?string
{
    $html = curl_fetch($productUrl);
    if ($html === null) {
        return null;
    }
    if (!preg_match('/<meta[^>]+property=["\']og:image["\'][^>]+content=["\']([^"\']+)["\']/i', $html, $m)
        && !preg_match('/<meta[^>]+content=["\']([^"\']+)["\'][^>]+property=["\']og:image["\']/i', $html, $m)) {
        return null;
    }
    $imgUrl = html_entity_decode($m[1], ENT_QUOTES | ENT_HTML5, 'UTF-8');
    $bytes = curl_fetch($imgUrl);
    if ($bytes === null || strlen($bytes) < 512) {
        return null;
    }
    $info = @getimagesizefromstring($bytes);
    if ($info === false || empty($info['mime'])) {
        return null;
    }
    $extMap = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
    $ext = $extMap[$info['mime']] ?? null;
    if ($ext === null) {
        return null;
    }
    $out = $dir . '/' . $prefix . '.' . $ext;
    file_put_contents($out, $bytes);
    return $out;
}

function generate_fallback_png(string $outPath, int $themeId, string $title, string $subtitle): void
{
    $palette = [
        1 => [[140, 18, 28],  [245, 195, 30]],
        2 => [[25, 75, 145],  [175, 215, 255]],
        3 => [[85, 20, 35],   [235, 185, 65]],
        4 => [[20, 95, 75],   [245, 200, 35]],
        5 => [[15, 105, 175], [250, 205, 30]],
        6 => [[24, 26, 32],   [230, 235, 240]],
    ];
    [$bg, $ac] = $palette[$themeId] ?? [[40, 40, 48], [246, 201, 14]];
    $w = 800;
    $h = 600;
    $img = imagecreatetruecolor($w, $h);
    imagefill($img, 0, 0, imagecolorallocate($img, ...$bg));
    $panel = imagecolorallocatealpha($img, 0, 0, 0, 65);
    imagefilledrectangle($img, 0, 400, $w, $h, $panel);

    $white = imagecolorallocate($img, 255, 255, 255);
    $accent = imagecolorallocate($img, ...$ac);
    $font = 'C:/Windows/Fonts/arialbd.ttf';
    if (is_file($font) && function_exists('imagettftext')) {
        imagettftext($img, 30, 0, 40, 470, $white, $font, $title);
        imagettftext($img, 22, 0, 40, 525, $accent, $font, $subtitle);
    } else {
        imagestring($img, 5, 40, 460, $title, $white);
        imagestring($img, 4, 40, 505, $subtitle, $accent);
    }
    imagepng($img, $outPath, 9);
    imagedestroy($img);
}

$setNum = $_GET['set'] ?? null;
$themeIdParam = $_GET['theme'] ?? null;

if ($setNum !== null && ctype_digit((string) $setNum)) {
    $prefix = 'set_' . $setNum;
    if ($cached = find_cached_image($imagesDir, $prefix)) {
        send_cached_file($cached);
    }
    $sets = require dirname(__DIR__, 2) . '/data/sets.php';
    foreach ($sets as $s) {
        if ($s['set_number'] === (string) $setNum) {
            if (!empty($s['product_url']) && ($fetched = try_fetch_lego_og_image($s['product_url'], $imagesDir, $prefix))) {
                send_cached_file($fetched);
            }
            $fallback = $imagesDir . '/' . $prefix . '.png';
            generate_fallback_png($fallback, (int) $s['theme_id'], $s['name'], '#' . $s['set_number'] . ' | ' . $s['pieces'] . ' pcs');
            send_cached_file($fallback);
        }
    }
}

if ($themeIdParam !== null && ctype_digit((string) $themeIdParam)) {
    $themeId = (int) $themeIdParam;
    $prefix = 'theme_' . $themeId;
    if ($cached = find_cached_image($imagesDir, $prefix)) {
        send_cached_file($cached);
    }
    $themes = require dirname(__DIR__, 2) . '/data/themes.php';
    foreach ($themes as $t) {
        if ((int) $t['id'] === $themeId) {
            $fallback = $imagesDir . '/' . $prefix . '.png';
            generate_fallback_png($fallback, $themeId, $t['theme_name'], 'Sejak ' . $t['established_year']);
            send_cached_file($fallback);
        }
    }
}

header('Content-Type: application/json; charset=utf-8');
http_response_code(404);
echo json_encode(['status' => 'error', 'message' => 'Gambar tidak ditemukan'], JSON_UNESCAPED_UNICODE);
