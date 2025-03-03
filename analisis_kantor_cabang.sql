-- Analisis Kantor Cabang

-- Sebaran jumlah cabang
SELECT provinsi,
      COUNT(branch_id) AS jumlah_cabang
FROM `kimia_farma.kf_kantor_cabang`
GROUP BY provinsi
ORDER BY jumlah_cabang DESC;

-- Rata-rata rating cabang provinsi
SELECT provinsi,
      ROUND(AVG(rating),2) AS rating_rata_rata
FROM `kimia_farma.kf_kantor_cabang`
GROUP BY provinsi
ORDER BY rating_rata_rata DESC;

-- 5 Cabang terbaik dan terendah (rating)
-- Cabang Tertinggi
SELECT branch_name,
      kota,
      provinsi,
      rating
FROM `kimia_farma.kf_kantor_cabang`
ORDER BY rating DESC
LIMIT 5;

-- Cabang Terendah
SELECT branch_name,
      kota,
      provinsi,
      rating
FROM `kimia_farma.kf_kantor_cabang`
ORDER BY rating ASC
LIMIT 5;

--provinsi dengan pendapatan tertinggi
SELECT 
    kc.provinsi,
    SUM(ft.price * (1 - ft.discount_percentage)) AS total_pendapatan
FROM `kimia_farma.kf_kantor_cabang` AS kc
LEFT JOIN `kimia_farma.kf_final_transaction` AS ft 
ON kc.branch_id = ft.branch_id
GROUP BY kc.provinsi
ORDER BY total_pendapatan DESC;
-- output: 3 provinsi terbesar pendapatannya: Jawa Barat, Sumatera Utara, Jawa Tengah

-- branch kategori dengan pendapatan terbesar
SELECT 
    kc.branch_category,
    SUM(ft.price * (1 - ft.discount_percentage)) AS total_pendapatan
FROM `kimia_farma.kf_kantor_cabang` AS kc
LEFT JOIN `kimia_farma.kf_final_transaction` AS ft 
ON kc.branch_id = ft.branch_id
GROUP BY kc.provinsi, kc.branch_category
ORDER BY total_pendapatan DESC;
-- output: pendapatan paling banyak berasal dari Apotek


-- Hubungan antara rating cabang dan pendapatan
SELECT 
    kc.provinsi,
    ROUND(AVG(kc.rating),1) AS rata_rating_cabang,
    ROUND(AVG(ft.price * (1 - ft.discount_percentage)), 3) AS rata_rata_pendapatan
FROM `kimia_farma.kf_final_transaction` ft
JOIN `kimia_farma.kf_kantor_cabang` kc
ON ft.branch_id = kc.branch_id
GROUP BY kc.provinsi
ORDER BY rata_rata_pendapatan DESC;



WITH ranked_data AS (-- membuat ranking tabel
    SELECT 
        kc.provinsi,
        ROUND(AVG(kc.rating), 1) AS rata_rating_cabang, -- menghitung rata-rata rating cabang
        ROUND(AVG(ft.price * (1 - ft.discount_percentage)), 3) AS rata_rata_pendapatan, -- menghitung rata-rata pendapatan
        DENSE RANK() OVER (ORDER BY ROUND(AVG(kc.rating), 1) DESC) AS rank_rating, -- memberi ranking pada rating
        DENSE RANK() OVER (ORDER BY ROUND(AVG(ft.price * (1 - ft.discount_percentage)), 3) DESC) AS rank_pendapatan  -- memberi ranking pada pendapatan
    FROM `kimia_farma.kf_final_transaction` AS ft
    JOIN `kimia_farma.kf_kantor_cabang` AS kc
    ON ft.branch_id = kc.branch_id
    GROUP BY kc.provinsi
)
SELECT 
    provinsi,
    rata_rating_cabang,
    rata_rata_pendapatan,
    rank_rating,
    rank_pendapatan,
    (rank_rating - rank_pendapatan) AS selisih_ranking
FROM ranked_data
ORDER BY selisih_ranking DESC;
-- Menghitung selisih ranking:
-- Selisih positif → Rating tinggi tetapi pendapatannya lebih rendah.
-- Selisih negatif → Pendapatan tinggi tetapi ratingnya lebih rendah.
-- Selisih = 0 → Seimbang antara rating dan pendapatan.

-- Jika selisih > 0 → Provinsi ini memiliki rating tinggi, tapi pendapatan rendah (mungkin ada masalah pricing, daya beli, dll.).
-- Jika selisih < 0 → Provinsi ini pendapatannya tinggi, tapi ratingnya rendah (mungkin cabang di sana laris tapi layanan kurang memuaskan).
-- Jika selisih mendekati 0 → Provinsi memiliki keseimbangan antara rating dan pendapatan.
