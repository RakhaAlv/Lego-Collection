<?php
// REST API utama LEGO Collection: melayani data tema/set JSON serta gambar statis.

declare(strict_types=1);
$reqPath = rawurldecode((string) parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH));

if (preg_match('#/api/image\.php$#', $reqPath)) {
    require __DIR__ . '/api/image.php';
    exit;
}

// Layani file gambar lokal di /images dengan header CORS agar bisa dimuat di Flutter Web.
if (PHP_SAPI === 'cli-server') {
    $staticFile = realpath(__DIR__ . $reqPath);
    $imagesDir  = realpath(__DIR__ . '/images');
    if ($staticFile && $imagesDir && str_starts_with($staticFile, $imagesDir . DIRECTORY_SEPARATOR) && is_file($staticFile)) {
        $mime = [
            'png'  => 'image/png',
            'jpg'  => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'webp' => 'image/webp',
        ];
        $ext = strtolower(pathinfo($staticFile, PATHINFO_EXTENSION));
        header('Content-Type: ' . ($mime[$ext] ?? 'application/octet-stream'));
        header('Access-Control-Allow-Origin: *');
        header('Cache-Control: public, max-age=86400');
        header('Content-Length: ' . filesize($staticFile));
        readfile($staticFile);
        exit;
    }
    if ($reqPath !== '/' && is_file(__DIR__ . $reqPath)) {
        return false;
    }
}

// Set header JSON dan izinkan akses lintas domain (CORS) untuk Flutter client.
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
if ($method === 'OPTIONS') {
    http_response_code(200);
    exit;
}

function send_json(int $code, array $payload): void
{
    http_response_code($code);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
    exit;
}

// Deteksi Base URL server otomatis agar link gambar menyesuaikan host yang aktif.
function base_url(): string
{
    $https  = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
        || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https');
    $scheme = $https ? 'https' : 'http';
    $host   = $_SERVER['HTTP_HOST'] ?? 'localhost:8000';
    $script = str_replace('\\', '/', $_SERVER['SCRIPT_NAME'] ?? '/');
    $dir    = preg_match('#^(.*)/index\.php$#', $script, $m) ? $m[1] : '';
    return $scheme . '://' . $host . $dir;
}

// Ubah path gambar relatif (images/76269.png) menjadi URL absolut.
function with_image_url(array $item): array
{
    if (!preg_match('#^https?://#', $item['image_url'])) {
        $item['image_url'] = base_url() . '/' . ltrim($item['image_url'], '/');
    }
    return $item;
}

function find_by_id(array $items, string $id): ?array
{
    if (!ctype_digit($id)) {
        return null;
    }
    $targetId = (int) $id;
    foreach ($items as $item) {
        if ($item['id'] === $targetId) {
            return $item;
        }
    }
    return null;
}

$themes     = require __DIR__ . '/../data/themes.php';
$sets       = require __DIR__ . '/../data/sets.php';
$themeNames = array_column($themes, 'theme_name', 'id');

$sets = array_map(function (array $s) use ($themeNames): array {
    $s['theme'] = $themeNames[$s['theme_id']] ?? $s['theme'];
    return with_image_url($s);
}, $sets);
$themes = array_map('with_image_url', $themes);

if ($method !== 'GET') {
    send_json(405, ['status' => 'error', 'message' => 'Method not allowed. Please use GET.']);
}

// Routing endpoint API: /api/sets, /api/sets/{id}, /api/themes, /api/themes/{id}.
$path = rtrim(parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/', '/');

if (!preg_match('#/api/(sets|themes)(?:/([^/]+))?$#', $path, $m)) {
    if ($path === '' || $path === '/api' || preg_match('#/index\.php$#', $path)) {
        send_json(200, [
            'status'    => 'success',
            'message'   => 'LEGO COLLECTION API is running',
            'endpoints' => ['/api/sets', '/api/sets?theme_id={id}', '/api/sets/{id}', '/api/themes', '/api/themes/{id}'],
        ]);
    }
    send_json(404, ['status' => 'error', 'message' => 'Endpoint not found']);
}

$resource = $m[1];
$id       = $m[2] ?? null;

if ($resource === 'sets') {
    if ($id === null) {
        $themeId = $_GET['theme_id'] ?? null;
        if ($themeId !== null && $themeId !== '') {
            if (!ctype_digit((string) $themeId)) {
                send_json(400, ['status' => 'error', 'message' => 'Query parameter theme_id must be numeric']);
            }
            $sets = array_values(array_filter($sets, fn(array $s): bool => $s['theme_id'] === (int) $themeId));
        }
        send_json(200, ['status' => 'success', 'data' => $sets]);
    }

    $foundSet = find_by_id($sets, $id);
    if ($foundSet !== null) {
        send_json(200, ['status' => 'success', 'data' => $foundSet]);
    }
    send_json(404, ['status' => 'error', 'message' => 'LEGO set not found']);
}

if ($id === null) {
    send_json(200, ['status' => 'success', 'data' => $themes]);
}
$foundTheme = find_by_id($themes, $id);
if ($foundTheme !== null) {
    send_json(200, ['status' => 'success', 'data' => $foundTheme]);
}
send_json(404, ['status' => 'error', 'message' => 'LEGO theme not found']);
