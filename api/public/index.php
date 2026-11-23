<?php
/**
 * LETS - LEGO Catalog REST API (Tugas Akhir PPB 2026)
 * Pengembang : Rakha Aljiva Prabaswara (21120124140126) - Kelompok 9 / Shift 02
 *
 * Jalankan: php -S 0.0.0.0:8000 -t api/public
 *
 * Endpoint (GET):
 *   /api/sets            (opsional ?theme_id=)
 *   /api/sets/{id}
 *   /api/themes
 *   /api/themes/{id}
 *   /api/image.php?set={set_number} | ?theme={theme_id}
 */

declare(strict_types=1);

$reqPath = rawurldecode((string) parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH));

// Delegasikan /api/image.php langsung sebelum mengirim header JSON.
if (preg_match('#/api/image\.php$#', $reqPath)) {
    require __DIR__ . '/api/image.php';
    exit;
}

// Layani gambar statis (php -S) beserta header CORS agar juga dapat dimuat di Flutter Web.
if (PHP_SAPI === 'cli-server') {
    $staticFile = realpath(__DIR__ . $reqPath);
    $imagesDir = realpath(__DIR__ . '/images');
    if ($staticFile && $imagesDir && str_starts_with($staticFile, $imagesDir . DIRECTORY_SEPARATOR) && is_file($staticFile)) {
        $mime = ['png' => 'image/png', 'jpg' => 'image/jpeg', 'jpeg' => 'image/jpeg', 'webp' => 'image/webp'];
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

// ---------- Header & CORS ----------
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
if ($method === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// ---------- Helper ----------
function send_json(int $code, array $payload): void
{
    http_response_code($code);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
    exit;
}

function base_url(): string
{
    $https = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
        || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https');
    $scheme = $https ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? 'localhost:8000';
    // Mendukung deploy di sub-folder (mis. hosting Apache: /lego/api/public/index.php)
    // sekaligus aman di PHP built-in server saat SCRIPT_NAME berisi path route (/api/sets/1).
    $script = str_replace('\\', '/', $_SERVER['SCRIPT_NAME'] ?? '/');
    $dir = preg_match('#^(.*)/index\.php$#', $script, $m) ? $m[1] : '';
    return $scheme . '://' . $host . $dir;
}

function with_image_url(array $item): array
{
    if (!preg_match('#^https?://#', $item['image_url'])) {
        $item['image_url'] = base_url() . '/' . ltrim($item['image_url'], '/');
    }
    return $item;
}

// ---------- Data ----------
$themes = require __DIR__ . '/../data/themes.php';
$sets   = require __DIR__ . '/../data/sets.php';

$themeNames = array_column($themes, 'theme_name', 'id');
$sets = array_map(function (array $s) use ($themeNames) {
    $s['theme'] = $themeNames[$s['theme_id']] ?? $s['theme'];
    return with_image_url($s);
}, $sets);
$themes = array_map('with_image_url', $themes);

// ---------- Routing ----------
if ($method !== 'GET') {
    send_json(405, ['status' => 'error', 'message' => 'Method tidak diizinkan, gunakan GET']);
}

$path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
$path = rtrim($path, '/');

if (!preg_match('#/api/(sets|themes)(?:/([^/]+))?$#', $path, $m)) {
    if ($path === '' || $path === '/api' || preg_match('#/index\.php$#', $path)) {
        send_json(200, [
            'status' => 'success',
            'message' => 'LETS - LEGO Catalog API aktif',
            'endpoints' => [
                '/api/sets',
                '/api/sets?theme_id={id}',
                '/api/sets/{id}',
                '/api/themes',
                '/api/themes/{id}',
                '/api/image.php?set={set_number}',
                '/api/image.php?theme={theme_id}',
            ],
        ]);
    }
    send_json(404, ['status' => 'error', 'message' => 'Endpoint tidak ditemukan']);
}

$resource = $m[1];
$id = $m[2] ?? null;

if ($resource === 'sets') {
    if ($id === null) {
        $themeId = $_GET['theme_id'] ?? null;
        if ($themeId !== null && $themeId !== '') {
            if (!ctype_digit((string) $themeId)) {
                send_json(400, ['status' => 'error', 'message' => 'Parameter theme_id harus berupa angka']);
            }
            $sets = array_values(array_filter($sets, fn($s) => $s['theme_id'] === (int) $themeId));
        }
        send_json(200, ['status' => 'success', 'data' => $sets]);
    }
    foreach ($sets as $s) {
        if (ctype_digit($id) && $s['id'] === (int) $id) {
            send_json(200, ['status' => 'success', 'data' => $s]);
        }
    }
    send_json(404, ['status' => 'error', 'message' => 'Set LEGO tidak ditemukan']);
}

// themes
if ($id === null) {
    send_json(200, ['status' => 'success', 'data' => $themes]);
}
foreach ($themes as $t) {
    if (ctype_digit($id) && $t['id'] === (int) $id) {
        send_json(200, ['status' => 'success', 'data' => $t]);
    }
}
send_json(404, ['status' => 'error', 'message' => 'Tema LEGO tidak ditemukan']);
