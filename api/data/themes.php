<?php
/**
 * Seed data 6 Tema LEGO (Tugas Akhir PPB 2026).
 * Field image_url berisi path relatif ke file gambar asli di api/public/images/;
 * URL absolut dibangun oleh index.php berdasarkan host server PHP aktif.
 */
return [
    [
        'id' => 1,
        'theme_name' => 'LEGO Marvel',
        'established_year' => 2012,
        'target_audience' => 'Anak, Remaja & Dewasa (7+ hingga 18+)',
        'difficulty_level' => 'Menengah - Tinggi',
        'total_sets_released' => 250,
        'characteristic' => 'Markas ikonik, helm kolektor, dan minifigure superhero Marvel Cinematic Universe.',
        'image_url' => 'images/76269.png',
        'overview' => 'LEGO Marvel membawa kisah para superhero Avengers, Spider-Man, dan Guardians of the Galaxy '
            . 'ke dalam bentuk bangunan modular raksasa, mech, serta objek kolektor.',
    ],
    [
        'id' => 2,
        'theme_name' => 'LEGO Disney',
        'established_year' => 2016,
        'target_audience' => 'Semua Usia (4+ hingga 18+)',
        'difficulty_level' => 'Rendah - Tinggi',
        'total_sets_released' => 150,
        'characteristic' => 'Istana dongeng, pondok animasi klasik, dan karakter ikonik Disney & Pixar.',
        'image_url' => 'images/43222.webp',
        'overview' => 'LEGO Disney merayakan keajaiban film animasi Disney dan Pixar melalui replika kastil megah, '
            . 'adegan film favorit, serta karakter yang penuh detail nostalgia.',
    ],
    [
        'id' => 3,
        'theme_name' => 'LEGO Harry Potter',
        'established_year' => 2001,
        'target_audience' => 'Anak, Remaja & Dewasa (7+ hingga 18+)',
        'difficulty_level' => 'Menengah - Tinggi',
        'total_sets_released' => 170,
        'characteristic' => 'Kastil Hogwarts, Diagon Alley, makhluk ajaib, dan dunia sihir penuh ruang rahasia.',
        'image_url' => 'images/76444.webp',
        'overview' => 'LEGO Harry Potter menghadirkan kembali petualangan dunia sihir Wizarding World, '
            . 'mulai dari kawasan Diagon Alley berskala kolektor hingga adegan ikonik di Hogwarts.',
    ],
    [
        'id' => 4,
        'theme_name' => 'LEGO NINJAGO',
        'established_year' => 2011,
        'target_audience' => 'Anak & Remaja (6+ hingga 14+)',
        'difficulty_level' => 'Menengah',
        'total_sets_released' => 450,
        'characteristic' => 'Naga elemental, kuil turnamen, robot mech, motor ninja, dan kota bertingkat khas NINJAGO.',
        'image_url' => 'images/71837.webp',
        'overview' => 'LEGO NINJAGO adalah tema orisinal LEGO yang memadukan aksi seni bela diri, fantasi naga, '
            . 'dan arsitektur kota futuristik bersama tim ninja Lloyd, Kai, Jay, Cole, Zane, dan Nya.',
    ],
    [
        'id' => 5,
        'theme_name' => 'LEGO City',
        'established_year' => 2005,
        'target_audience' => 'Anak & Keluarga (4+ hingga 8+)',
        'difficulty_level' => 'Rendah - Menengah',
        'total_sets_released' => 700,
        'characteristic' => 'Kendaraan perkotaan realistis, truk balap F1, alat berat, kereta penumpang, dan eksplorasi antariksa.',
        'image_url' => 'images/60445.webp',
        'overview' => 'LEGO City menggambarkan aktivitas kota dan petualangan modern dengan kendaraan balap, '
            . 'alat konstruksi, transportasi kereta listrik, hingga pesawat ruang angkasa ramah anak.',
    ],
    [
        'id' => 6,
        'theme_name' => 'LEGO Star Wars',
        'established_year' => 1999,
        'target_audience' => 'Anak, Remaja & Dewasa (6+ hingga 18+)',
        'difficulty_level' => 'Menengah - Tinggi',
        'total_sets_released' => 900,
        'characteristic' => 'Pesawat luar angkasa ikonik, mech karakter, battle pack pasukan, dan seri kolektor.',
        'image_url' => 'images/75375.webp',
        'overview' => 'LEGO Star Wars adalah tema lisensi legendaris yang menghadirkan pesawat tempur seperti '
            . 'Millennium Falcon, X-Wing, dan TIE Fighter dari galaksi Star Wars.',
    ],
];
