<?php
/**
 * Generator gambar fallback lokal (PNG) di api/public/images/
 * untuk endpoint api/image.php?set=... dan api/image.php?theme=...
 * Jalankan: php api/tools/generate_images.php
 */
declare(strict_types=1);

$themes = require __DIR__ . '/../data/themes.php';
$sets   = require __DIR__ . '/../data/sets.php';
$outDir = __DIR__ . '/../public/images';
if (!is_dir($outDir)) {
    mkdir($outDir, 0777, true);
}

// Hapus PNG lama dari tema/set sebelumnya agar cache bersih (36 gambar).
foreach (glob($outDir . '/*.png') ?: [] as $old) {
    @unlink($old);
}

$palette = [
    1 => [[140, 18, 28],  [245, 195, 30]],  // 1. Marvel: merah gelap + emas
    2 => [[25, 75, 145],  [175, 215, 255]], // 2. Disney: biru dongker + biru muda
    3 => [[85, 20, 35],   [235, 185, 65]],  // 3. Harry Potter: burgundy + emas
    4 => [[20, 95, 75],   [245, 200, 35]],  // 4. NINJAGO: hijau giok + emas
    5 => [[15, 105, 175], [250, 205, 30]],  // 5. LEGO City: biru cerah + kuning
    6 => [[24, 26, 32],   [230, 235, 240]], // 6. Star Wars: hitam galaksi + perak
];

$font = null;
foreach (['C:/Windows/Fonts/arialbd.ttf', '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'] as $f) {
    if (is_file($f) && function_exists('imagettftext')) {
        $font = $f;
        break;
    }
}

function shade(array $c, float $k): array
{
    return array_map(fn($v) => (int) max(0, min(255, $v * $k)), $c);
}

function draw_text($img, string $text, int $size, int $y, $color, ?string $font, int $w): void
{
    if ($font) {
        do {
            $box = imagettfbbox($size, 0, $font, $text);
            $tw = $box[2] - $box[0];
            if ($tw <= $w - 60) {
                break;
            }
            $size -= 2;
        } while ($size > 10);
        imagettftext($img, $size, 0, (int) (($w - $tw) / 2), $y, $color, $font, $text);
    } else {
        $tw = imagefontwidth(5) * strlen($text);
        imagestring($img, 5, (int) (($w - $tw) / 2), $y - 15, $text, $color);
    }
}

function draw_brick($img, int $cx, int $cy, int $studsX, int $studsY, array $rgb): void
{
    $unit = 44;
    $bw = $studsX * $unit;
    $bh = 70;
    $depth = $studsY * 18;
    $x0 = $cx - (int) ($bw / 2);
    $y0 = $cy;
    $front = imagecolorallocate($img, ...$rgb);
    $top   = imagecolorallocate($img, ...shade($rgb, 1.15));
    $side  = imagecolorallocate($img, ...shade($rgb, 0.7));
    $edge  = imagecolorallocate($img, ...shade($rgb, 0.5));

    imagefilledpolygon($img, [$x0, $y0, $x0 + $depth, $y0 - $depth, $x0 + $bw + $depth, $y0 - $depth, $x0 + $bw, $y0], $top);
    imagefilledpolygon($img, [$x0 + $bw, $y0, $x0 + $bw + $depth, $y0 - $depth, $x0 + $bw + $depth, $y0 - $depth + $bh, $x0 + $bw, $y0 + $bh], $side);
    imagefilledrectangle($img, $x0, $y0, $x0 + $bw, $y0 + $bh, $front);
    imagerectangle($img, $x0, $y0, $x0 + $bw, $y0 + $bh, $edge);

    for ($j = $studsY - 1; $j >= 0; $j--) {
        for ($i = 0; $i < $studsX; $i++) {
            $sx = $x0 + (int) ($unit / 2) + $i * $unit + (int) (($j + 0.5) * $depth / $studsY);
            $sy = $y0 - (int) (($j + 0.5) * $depth / $studsY);
            imagefilledrectangle($img, $sx - 14, $sy - 12, $sx + 14, $sy, $side);
            imagefilledellipse($img, $sx, $sy, 28, 12, $side);
            imagefilledellipse($img, $sx, $sy - 12, 28, 12, $top);
            imageellipse($img, $sx, $sy - 12, 28, 12, $edge);
        }
    }
}

function render(string $file, array $bg, array $accent, string $title, string $subtitle, ?string $font, int $studsX): void
{
    $w = 800;
    $h = 600;
    $img = imagecreatetruecolor($w, $h);
    imageantialias($img, true);
    for ($y = 0; $y < $h; $y++) {
        $c = shade($bg, 1.25 - 0.55 * ($y / $h));
        imageline($img, 0, $y, $w, $y, imagecolorallocate($img, ...$c));
    }
    $dot = imagecolorallocatealpha($img, 255, 255, 255, 115);
    for ($y = 30; $y < $h; $y += 60) {
        for ($x = 30; $x < $w; $x += 60) {
            imagefilledellipse($img, $x, $y, 22, 22, $dot);
        }
    }

    draw_brick($img, (int) ($w / 2) - 20, 250, $studsX, 2, $accent);

    $white = imagecolorallocate($img, 255, 255, 255);
    $panel = imagecolorallocatealpha($img, 0, 0, 0, 70);
    imagefilledrectangle($img, 0, 400, $w, $h, $panel);
    draw_text($img, $title, 40, 470, $white, $font, $w);
    draw_text($img, $subtitle, 24, 530, imagecolorallocate($img, ...$accent), $font, $w);
    imagepng($img, $file, 9);
    imagedestroy($img);
}

foreach ($themes as $t) {
    [$bg, $ac] = $palette[$t['id']];
    $out = $outDir . '/theme_' . $t['id'] . '.png';
    render($out, $bg, $ac, $t['theme_name'], 'Sejak ' . $t['established_year'], $font, 4);
    echo "OK theme {$t['id']}\n";
}
foreach ($sets as $s) {
    [$bg, $ac] = $palette[$s['theme_id']];
    $out = $outDir . '/set_' . $s['set_number'] . '.png';
    render($out, $bg, $ac, $s['name'], '#' . $s['set_number'] . '  |  ' . $s['pieces'] . ' pcs', $font, 2 + ($s['id'] % 3));
    echo "OK set {$s['set_number']}\n";
}
