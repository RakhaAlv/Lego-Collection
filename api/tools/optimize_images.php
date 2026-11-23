<?php
/**
 * Skrip optimasi gambar di api/public/images/:
 * - Mengecilkan gambar berdimensi > 800px secara proporsional (maks 800px)
 * - Mengompres ulang WebP (kualitas 80) & PNG (level 8) dengan alpha terjaga
 * Jalankan: php api/tools/optimize_images.php
 */
declare(strict_types=1);

$dir = __DIR__ . '/../public/images';
$maxDim = 800;

$files = glob($dir . '/*.{webp,png,jpg,jpeg}', GLOB_BRACE) ?: [];
sort($files);

$totalBefore = 0;
$totalAfter = 0;

foreach ($files as $path) {
    $beforeBytes = filesize($path) ?: 0;
    $totalBefore += $beforeBytes;
    $info = @getimagesize($path);
    if ($info === false) {
        echo 'SKIP ' . basename($path) . " (bukan gambar valid)\n";
        $totalAfter += $beforeBytes;
        continue;
    }

    [$w, $h, $type] = $info;
    $src = match ($type) {
        IMAGETYPE_WEBP => @imagecreatefromwebp($path),
        IMAGETYPE_PNG  => @imagecreatefrompng($path),
        IMAGETYPE_JPEG => @imagecreatefromjpeg($path),
        default        => false,
    };

    if ($src === false) {
        echo 'SKIP ' . basename($path) . " (gagal decode)\n";
        $totalAfter += $beforeBytes;
        continue;
    }

    $scale = min(1.0, $maxDim / max($w, $h));
    $nw = max(1, (int) round($w * $scale));
    $nh = max(1, (int) round($h * $scale));

    $dst = imagecreatetruecolor($nw, $nh);
    imagealphablending($dst, false);
    imagesavealpha($dst, true);
    $transparent = imagecolorallocatealpha($dst, 0, 0, 0, 127);
    imagefilledrectangle($dst, 0, 0, $nw, $nh, $transparent);
    imagecopyresampled($dst, $src, 0, 0, 0, 0, $nw, $nh, $w, $h);

    $tmp = $path . '.tmp';
    $saved = match ($type) {
        IMAGETYPE_WEBP => imagewebp($dst, $tmp, 80),
        IMAGETYPE_PNG  => imagepng($dst, $tmp, 8),
        IMAGETYPE_JPEG => imagejpeg($dst, $tmp, 82),
        default        => false,
    };

    imagedestroy($src);
    imagedestroy($dst);

    if ($saved && is_file($tmp)) {
        $newBytes = filesize($tmp) ?: $beforeBytes;
        // Simpan hasil jika dimensi memang dikecilkan atau ukuran file berkurang.
        if ($nw < $w || $nh < $h || $newBytes < $beforeBytes) {
            rename($tmp, $path);
            $afterBytes = $newBytes;
        } else {
            @unlink($tmp);
            $afterBytes = $beforeBytes;
        }
    } else {
        @unlink($tmp);
        $afterBytes = $beforeBytes;
    }

    $totalAfter += $afterBytes;
    printf(
        "OK %-12s %4dx%-4d -> %4dx%-4d | %5.1f KB -> %5.1f KB\n",
        basename($path),
        $w,
        $h,
        $nw,
        $nh,
        $beforeBytes / 1024,
        $afterBytes / 1024
    );
}

printf(
    "TOTAL: %.1f KB -> %.1f KB (hemat %.1f%%)\n",
    $totalBefore / 1024,
    $totalAfter / 1024,
    $totalBefore > 0 ? (1 - $totalAfter / $totalBefore) * 100 : 0
);
