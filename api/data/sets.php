<?php
/**
 * Seed data 30 Set LEGO (6 Tema x 5 Set).
 * Field image_url menunjuk ke file gambar asli lokal di api/public/images/,
 * lalu diubah menjadi URL absolut (/images/<file>) oleh index.php sesuai host aktif.
 */
return [
    // ---------- 1. LEGO Marvel ----------
    [
        'id' => 1, 'theme_id' => 1, 'set_number' => '76269',
        'name' => 'Avengers Tower', 'theme' => 'LEGO Marvel',
        'pieces' => 5201, 'age_rating' => '18+', 'release_year' => 2023,
        'dimensions' => '90 cm x 34 cm x 25 cm', 'price_idr' => 8499000,
        'product_url' => 'https://www.lego.com/id-id/product/avengers-tower-76269',
        'image_url' => 'images/76269.png',
        'description' => 'Menara Avengers setinggi 90 cm dengan akses interior tiap lantai, Quinjet, Leviathan, '
            . 'dan 31 figur karakter ikonik Marvel Cinematic Universe.',
    ],
    [
        'id' => 2, 'theme_id' => 1, 'set_number' => '76178',
        'name' => 'Daily Bugle', 'theme' => 'LEGO Marvel',
        'pieces' => 3772, 'age_rating' => '18+', 'release_year' => 2021,
        'dimensions' => '82 cm x 27 cm x 27 cm', 'price_idr' => 5999000,
        'product_url' => 'https://www.lego.com/id-id/product/daily-bugle-76178',
        'image_url' => 'images/76178.webp',
        'description' => 'Gedung kantor berita Daily Bugle empat lantai bertema Spider-Man lengkap dengan '
            . '25 minifigure termasuk Green Goblin, Doc Ock, dan Venom.',
    ],
    [
        'id' => 3, 'theme_id' => 1, 'set_number' => '76191',
        'name' => 'Infinity Gauntlet', 'theme' => 'LEGO Marvel',
        'pieces' => 590, 'age_rating' => '18+', 'release_year' => 2021,
        'dimensions' => '31 cm x 13 cm x 11 cm', 'price_idr' => 1399000,
        'product_url' => 'https://www.lego.com/id-id/product/infinity-gauntlet-76191',
        'image_url' => 'images/76191.webp',
        'description' => 'Model pajangan sarung tangan Thanos berwarna emas metalik dengan jari artikulasi '
            . 'dan keenam Infinity Stones yang berkilau.',
    ],
    [
        'id' => 4, 'theme_id' => 1, 'set_number' => '76313',
        'name' => 'MARVEL Logo & Minifigures', 'theme' => 'LEGO Marvel',
        'pieces' => 931, 'age_rating' => '12+', 'release_year' => 2025,
        'dimensions' => '13 cm x 28 cm x 7 cm', 'price_idr' => 1699000,
        'product_url' => 'https://www.lego.com/id-id/product/marvel-logo-minifigures-76313',
        'image_url' => 'images/76313.webp',
        'description' => 'Plakat logo merah-putih MARVEL yang dapat dipajang dengan mekanisme tombol '
            . 'untuk memunculkan lima minifigure Avengers termasuk Iron Man, Thor, dan Hulk.',
    ],
    [
        'id' => 5, 'theme_id' => 1, 'set_number' => '76321',
        'name' => 'Spider-Man vs. Doc Ock Subway Train Scene', 'theme' => 'LEGO Marvel',
        'pieces' => 393, 'age_rating' => '9+', 'release_year' => 2025,
        'dimensions' => '8 cm x 23 cm x 5 cm', 'price_idr' => 859000,
        'product_url' => 'https://www.lego.com/id-id/product/spider-man-vs-doc-ock-subway-train-scene-76321',
        'image_url' => 'images/76321.webp',
        'description' => 'Adegan aksi kereta bawah tanah klasik Spider-Man melawan Doc Ock dengan gerbong kereta '
            . 'berisi akses interior, elemen jaring laba-laba, dan 4 minifigure.',
    ],

    // ---------- 2. LEGO Disney ----------
    [
        'id' => 6, 'theme_id' => 2, 'set_number' => '43269',
        'name' => '101 Dalmatians Puppy', 'theme' => 'LEGO Disney',
        'pieces' => 1722, 'age_rating' => '18+', 'release_year' => 2025,
        'dimensions' => '22 cm x 19 cm x 14 cm', 'price_idr' => 3299000,
        'product_url' => 'https://www.lego.com/id-id/product/101-dalmatians-puppy-43269',
        'image_url' => 'images/43269.webp',
        'description' => 'Figur anak anjing Dalmatian yang menggemaskan dengan kepala, telinga, dan pose '
            . 'yang dapat dikustomisasi sebagai Patch, Penny, Rolly, atau karakter lainnya.',
    ],
    [
        'id' => 7, 'theme_id' => 2, 'set_number' => '43242',
        'name' => "Snow White and the Seven Dwarfs' Cottage", 'theme' => 'LEGO Disney',
        'pieces' => 2228, 'age_rating' => '18+', 'release_year' => 2024,
        'dimensions' => '20 cm x 35 cm x 20 cm', 'price_idr' => 3999000,
        'product_url' => 'https://www.lego.com/id-id/product/snow-white-and-the-seven-dwarfs-cottage-43242',
        'image_url' => 'images/43242.webp',
        'description' => 'Pondok hutan klasik Putri Salju dan Ketujuh Kurcaci lengkap dengan sumur harapan, '
            . 'atap dapat dibuka, perapian menyala, dan 10 minifigure.',
    ],
    [
        'id' => 8, 'theme_id' => 2, 'set_number' => '43247',
        'name' => 'Young Simba the Lion King', 'theme' => 'LEGO Disney',
        'pieces' => 1445, 'age_rating' => '18+', 'release_year' => 2024,
        'dimensions' => '29 cm x 22 cm x 24 cm', 'price_idr' => 2299000,
        'product_url' => 'https://www.lego.com/id-id/product/young-simba-the-lion-king-43247',
        'image_url' => 'images/43247.webp',
        'description' => 'Model pajangan anak singa Simba edisi perayaan ke-30 The Lion King dengan kepala '
            . 'artikulasi yang dapat diputar untuk berbagai pose ekspresif.',
    ],
    [
        'id' => 9, 'theme_id' => 2, 'set_number' => '43280',
        'name' => 'Beach Fun with Lilo & Stitch', 'theme' => 'LEGO Disney',
        'pieces' => 113, 'age_rating' => '4+', 'release_year' => 2026,
        'dimensions' => '11 cm x 16 cm x 9 cm', 'price_idr' => 459000,
        'product_url' => 'https://www.lego.com/id-id/product/beach-fun-with-lilo-stitch-43280',
        'image_url' => 'images/43280.webp',
        'description' => 'Set bermain pantai tropis Hawaii bersama Lilo dan Stitch lengkap dengan papan selancar, '
            . 'pondok pantai, dan Starter Brick yang ramah perakit pemula.',
    ],
    [
        'id' => 10, 'theme_id' => 2, 'set_number' => '43222',
        'name' => 'Disney Castle', 'theme' => 'LEGO Disney',
        'pieces' => 4837, 'age_rating' => '18+', 'release_year' => 2023,
        'dimensions' => '80 cm x 59 cm x 33 cm', 'price_idr' => 6799000,
        'product_url' => 'https://www.lego.com/id-id/product/disney-castle-43222',
        'image_url' => 'images/43222.webp',
        'description' => 'Kastil ikonik edisi ulang tahun ke-100 Disney lengkap dengan ruang dansa berputar, '
            . 'ruangan tematik film klasik, dan 8 minifigure.',
    ],

    // ---------- 3. LEGO Harry Potter ----------
    [
        'id' => 11, 'theme_id' => 3, 'set_number' => '76444',
        'name' => 'Diagon Alley Wizarding Shops', 'theme' => 'LEGO Harry Potter',
        'pieces' => 2750, 'age_rating' => '18+', 'release_year' => 2025,
        'dimensions' => '14 cm x 88 cm x 8 cm', 'price_idr' => 3499000,
        'product_url' => 'https://www.lego.com/id-id/product/diagon-alley-wizarding-shops-76444',
        'image_url' => 'images/76444.webp',
        'description' => 'Model arsitektur berskala mikro kawasan toko sihir Diagon Alley mencakup Bank Gringotts, '
            . 'toko tongkat Ollivanders, Weasleys Wizard Wheezes, dan 12 mikrofigur.',
    ],
    [
        'id' => 12, 'theme_id' => 3, 'set_number' => '76425',
        'name' => 'Hedwig at 4 Privet Drive', 'theme' => 'LEGO Harry Potter',
        'pieces' => 336, 'age_rating' => '7+', 'release_year' => 2024,
        'dimensions' => '10 cm x 11 cm x 9 cm', 'price_idr' => 349000,
        'product_url' => 'https://www.lego.com/id-id/product/hedwig-at-4-privet-drive-76425',
        'image_url' => 'images/76425.webp',
        'description' => 'Figur burung hantu salju Hedwig yang bertengger di papan jalan 4 Privet Drive lengkap '
            . 'dengan koper berisi foto orang tua Harry, buku ramuan, dan tongkat sihir.',
    ],
    [
        'id' => 13, 'theme_id' => 3, 'set_number' => '76443',
        'name' => "Hagrid & Harry's Motorcycle Ride", 'theme' => 'LEGO Harry Potter',
        'pieces' => 617, 'age_rating' => '9+', 'release_year' => 2025,
        'dimensions' => '16 cm x 16 cm x 12 cm', 'price_idr' => 859000,
        'product_url' => 'https://www.lego.com/id-id/product/hagrid-harrys-motorcycle-ride-76443',
        'image_url' => 'images/76443.webp',
        'description' => 'Model rakitan motor terbang ikonik Rubeus Hagrid bersama Harry Potter dan Hedwig di '
            . 'sespan dengan roda berputar serta kepala karakter artikulasi.',
    ],
    [
        'id' => 14, 'theme_id' => 3, 'set_number' => '76460',
        'name' => 'Hogwarts Castle: Sorting Hat Ceremony', 'theme' => 'LEGO Harry Potter',
        'pieces' => 124, 'age_rating' => '7+', 'release_year' => 2026,
        'dimensions' => '10 cm x 14 cm x 8 cm', 'price_idr' => 329000,
        'product_url' => 'https://www.lego.com/id-id/product/hogwarts-castle-sorting-hat-ceremony-76460',
        'image_url' => 'images/76460.webp',
        'description' => 'Set adegan upacara Topi Seleksi di Aula Besar Hogwarts dilengkapi roda putar asrama '
            . 'dan minifigure Harry Potter, Hermione Granger, serta Profesor McGonagall.',
    ],
    [
        'id' => 15, 'theme_id' => 3, 'set_number' => '76475',
        'name' => 'Forbidden Forest: Expecto Patronum', 'theme' => 'LEGO Harry Potter',
        'pieces' => 244, 'age_rating' => '7+', 'release_year' => 2026,
        'dimensions' => '14 cm x 17 cm x 10 cm', 'price_idr' => 659000,
        'product_url' => 'https://www.lego.com/id-id/product/forbidden-forest-expecto-patronum-76475',
        'image_url' => 'images/76475.webp',
        'description' => 'Petualangan di Hutan Terlarang dengan figur rusa Patronus biru transparan berkilau, '
            . 'pohon berkabut, dan minifigure menghadapi Dementor.',
    ],

    // ---------- 4. LEGO NINJAGO ----------
    [
        'id' => 16, 'theme_id' => 4, 'set_number' => '71837',
        'name' => 'NINJAGO City Workshops', 'theme' => 'LEGO NINJAGO',
        'pieces' => 3244, 'age_rating' => '14+', 'release_year' => 2025,
        'dimensions' => '41 cm x 25 cm x 25 cm', 'price_idr' => 4499000,
        'product_url' => 'https://www.lego.com/id-id/product/ninjago-city-workshops-71837',
        'image_url' => 'images/71837.webp',
        'description' => 'Bangunan modular kota empat lantai dengan bengkel mekanik, dua derek fungsional, '
            . 'model mech yang bisa dirakit-custom, dan 10 minifigure.',
    ],
    [
        'id' => 17, 'theme_id' => 4, 'set_number' => '71814',
        'name' => 'Tournament Temple City', 'theme' => 'LEGO NINJAGO',
        'pieces' => 3489, 'age_rating' => '14+', 'release_year' => 2024,
        'dimensions' => '48 cm x 63 cm x 32 cm', 'price_idr' => 4299000,
        'product_url' => 'https://www.lego.com/id-id/product/tournament-temple-city-71814',
        'image_url' => 'images/71814.webp',
        'description' => 'Kompleks kuil turnamen megah di tebing batu lengkap dengan arena bertarung bergerak, '
            . 'naga kecil, kincir air, dan 13 minifigure NINJAGO Dragons Rising.',
    ],
    [
        'id' => 18, 'theme_id' => 4, 'set_number' => '71866',
        'name' => 'Ninja Character Display 15th Anniversary', 'theme' => 'LEGO NINJAGO',
        'pieces' => 447, 'age_rating' => '14+', 'release_year' => 2026,
        'dimensions' => '19 cm x 25 cm x 14 cm', 'price_idr' => 859000,
        'product_url' => 'https://www.lego.com/id-id/product/ninja-character-display-15th-anniversary-71866',
        'image_url' => 'images/71866.webp',
        'description' => 'Panggung kuil pajangan edisi perayaan 15 tahun NINJAGO lengkap dengan gerbang torii, '
            . 'lentera, pohon sakura, dan jajaran lengkap minifigure para ninja klasik.',
    ],
    [
        'id' => 19, 'theme_id' => 4, 'set_number' => '71822',
        'name' => 'Source Dragon of Motion', 'theme' => 'LEGO NINJAGO',
        'pieces' => 1716, 'age_rating' => '12+', 'release_year' => 2024,
        'dimensions' => '39 cm x 63 cm x 74 cm', 'price_idr' => 2599000,
        'product_url' => 'https://www.lego.com/id-id/product/source-dragon-of-motion-71822',
        'image_url' => 'images/71822.webp',
        'description' => 'Naga terbesar dalam sejarah LEGO NINJAGO berwarna merah-emas dengan sayap raksasa '
            . 'artikulasi penuh, takhta pelana, dan 6 naga roh kecil.',
    ],
    [
        'id' => 20, 'theme_id' => 4, 'set_number' => '71838',
        'name' => "Kai's Motorcycle Speed Race", 'theme' => 'LEGO NINJAGO',
        'pieces' => 79, 'age_rating' => '6+', 'release_year' => 2025,
        'dimensions' => '4 cm x 9 cm x 3 cm', 'price_idr' => 199000,
        'product_url' => 'https://www.lego.com/id-id/product/kais-motorcycle-speed-race-71838',
        'image_url' => 'images/71838.webp',
        'description' => 'Set duel balap berkecepatan tinggi menampilkan dua motor ninja milik Kai dan Spectral '
            . 'Dragonian Scout dengan pedang kristal.',
    ],

    // ---------- 5. LEGO City ----------
    [
        'id' => 21, 'theme_id' => 5, 'set_number' => '60445',
        'name' => 'F1 Truck with RB20 & AMR24 F1 Cars', 'theme' => 'LEGO City',
        'pieces' => 1086, 'age_rating' => '8+', 'release_year' => 2025,
        'dimensions' => '9 cm x 44 cm x 7 cm', 'price_idr' => 1699000,
        'product_url' => 'https://www.lego.com/id-id/product/f1-truck-with-rb20-amr24-f1-cars-60445',
        'image_url' => 'images/60445.webp',
        'description' => 'Truk pengangkut tim Formula 1 yang dilengkapi ruang simulator balap, jalur muat '
            . 'otomatis, dua mobil balap F1 RB20 & AMR24, serta kru pit.',
    ],
    [
        'id' => 22, 'theme_id' => 5, 'set_number' => '60480',
        'name' => 'Yellow Backhoe Loader', 'theme' => 'LEGO City',
        'pieces' => 301, 'age_rating' => '7+', 'release_year' => 2026,
        'dimensions' => '10 cm x 24 cm x 8 cm', 'price_idr' => 659000,
        'product_url' => 'https://www.lego.com/id-id/product/yellow-backhoe-loader-60480',
        'image_url' => 'images/60480.webp',
        'description' => 'Alat berat ekskavator pemuat kuning dengan sekop depan yang bisa dimiringkan, '
            . 'lengan penggali belakang fungsional, ban besar, dan 2 minifigure pekerja.',
    ],
    [
        'id' => 23, 'theme_id' => 5, 'set_number' => '60491',
        'name' => 'Motorcycle Transporter', 'theme' => 'LEGO City',
        'pieces' => 88, 'age_rating' => '4+', 'release_year' => 2026,
        'dimensions' => '7 cm x 14 cm x 6 cm', 'price_idr' => 499000,
        'product_url' => 'https://www.lego.com/id-id/product/motorcycle-transporter-60491',
        'image_url' => 'images/60491.webp',
        'description' => 'Truk bak datar pengangkut dua sepeda motor sport beserta jalur landai dan aksesori '
            . 'bengkel untuk anak usia 4+ tahun.',
    ],
    [
        'id' => 24, 'theme_id' => 5, 'set_number' => '60430',
        'name' => 'Interstellar Spaceship', 'theme' => 'LEGO City',
        'pieces' => 240, 'age_rating' => '6+', 'release_year' => 2024,
        'dimensions' => '4 cm x 22 cm x 17 cm', 'price_idr' => 349000,
        'product_url' => 'https://www.lego.com/id-id/product/interstellar-spaceship-60430',
        'image_url' => 'images/60430.webp',
        'description' => 'Pesawat luar angkasa berkecepatan tinggi dengan pendorong lipat yang menyala saat '
            . 'baterai energi dimasukkan, dilengkapi drone jetpack astronot.',
    ],
    [
        'id' => 25, 'theme_id' => 5, 'set_number' => '60337',
        'name' => 'Express Passenger Train', 'theme' => 'LEGO City',
        'pieces' => 764, 'age_rating' => '7+', 'release_year' => 2022,
        'dimensions' => '10 cm x 86 cm x 5 cm', 'price_idr' => 2699000,
        'product_url' => 'https://www.lego.com/id-id/product/express-passenger-train-60337',
        'image_url' => 'images/60337.webp',
        'description' => 'Kereta ekspres bermotor dengan kontrol jarak jauh Powered Up, lampu depan menyala, '
            . 'gerbong makan, peron stasiun, dan jalur rel oval.',
    ],

    // ---------- 6. LEGO Star Wars ----------
    [
        'id' => 26, 'theme_id' => 6, 'set_number' => '75460',
        'name' => 'New Republic X-Wing Starfighter', 'theme' => 'LEGO Star Wars',
        'pieces' => 558, 'age_rating' => '9+', 'release_year' => 2026,
        'dimensions' => '8 cm x 31 cm x 28 cm', 'price_idr' => 1199000,
        'product_url' => 'https://www.lego.com/id-id/product/new-republic-x-wing-starfighter-75460',
        'image_url' => 'images/75460.webp',
        'description' => 'Pesawat tempur X-Wing armada New Republic berwarna biru-putih dengan sayap serang '
            . 'yang bisa dibuka, penembak pegas, dan ruang droid astromech.',
    ],
    [
        'id' => 27, 'theme_id' => 6, 'set_number' => '75421',
        'name' => "SMART Play: Darth Vader's TIE Fighter", 'theme' => 'LEGO Star Wars',
        'pieces' => 473, 'age_rating' => '8+', 'release_year' => 2026,
        'dimensions' => '10 cm x 14 cm x 15 cm', 'price_idr' => 1199000,
        'product_url' => 'https://www.lego.com/id-id/product/smart-play-darth-vaders-tie-fighter-75421',
        'image_url' => 'images/75421.webp',
        'description' => 'Pesawat TIE Advanced x1 ikonik milik Darth Vader dengan sayap bersudut khas, '
            . 'kokpit buka-tutup, fitur SMART Play, dan penembak laser ganda.',
    ],
    [
        'id' => 28, 'theme_id' => 6, 'set_number' => '75411',
        'name' => 'Darth Maul Mech', 'theme' => 'LEGO Star Wars',
        'pieces' => 143, 'age_rating' => '6+', 'release_year' => 2025,
        'dimensions' => '12 cm x 10 cm x 7 cm', 'price_idr' => 329000,
        'product_url' => 'https://www.lego.com/id-id/product/darth-maul-mech-75411',
        'image_url' => 'images/75411.webp',
        'description' => 'Robot mech tempur Darth Maul berwarna hitam-merah dengan kokpit terbuka, lengan-kaki '
            . 'artikulasi, serta pedang Lightsaber bermata ganda raksasa.',
    ],
    [
        'id' => 29, 'theme_id' => 6, 'set_number' => '75372',
        'name' => 'Clone Trooper & Battle Droid Battle Pack', 'theme' => 'LEGO Star Wars',
        'pieces' => 215, 'age_rating' => '7+', 'release_year' => 2024,
        'dimensions' => '6 cm x 10 cm x 5 cm', 'price_idr' => 499000,
        'product_url' => 'https://www.lego.com/id-id/product/clone-trooper-battle-droid-battle-pack-75372',
        'image_url' => 'images/75372.webp',
        'description' => 'Paket pasukan Clone Wars berisi 4 Clone Trooper dan 5 Battle Droid lengkap dengan '
            . 'motor speeder, STAP speeder, dan Octuptarra tri-droid.',
    ],
    [
        'id' => 30, 'theme_id' => 6, 'set_number' => '75375',
        'name' => 'Millennium Falcon', 'theme' => 'LEGO Star Wars',
        'pieces' => 921, 'age_rating' => '18+', 'release_year' => 2024,
        'dimensions' => '13 cm x 24 cm x 19 cm', 'price_idr' => 1499000,
        'product_url' => 'https://www.lego.com/id-id/product/millennium-falcon-75375',
        'image_url' => 'images/75375.webp',
        'description' => 'Model pajangan seri Starship Collection Millennium Falcon skala menengah edisi ke-25 '
            . 'LEGO Star Wars lengkap dengan dudukan miring dan pelat nama.',
    ],
];
