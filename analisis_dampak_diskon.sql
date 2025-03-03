-- Analisis Dampak Diskon
-- Apakah dengan bertambah diskon, bertambah juga jumlah transaksi, nett_sales, dan nett_profit?

SELECT 
        CASE
          WHEN discount_percentage * 100 = 0 THEN 'Tidak Discount'
          WHEN discount_percentage * 100 > 0 AND discount_percentage * 100 <= 5 THEN '0 - 5%'
          WHEN discount_percentage * 100 > 5 AND discount_percentage * 100 <= 10 THEN '6 - 10%'
          WHEN discount_percentage * 100 > 10 AND discount_percentage * 100 <= 20 THEN '11 - 20%'
          ELSE '20 ke atas'
        END AS kategori_diskon,
        COUNT(transaction_id) AS jumlah_transaksi
FROM `kimia_farma.kf_final_transaction`
GROUP BY kategori_diskon
ORDER BY jumlah_transaksi DESC;
-- terlihat bahwa jumlah transaksi relatif tinggi di semua kategori diskon (0-5%, 6-10%, 11-20%), tetapi transaksi tanpa diskon jauh lebih sedikit.
-- Diskon kemungkinan besar berpengaruh terhadap peningkatan jumlah transaksi.

--  total nett_sales per kategori diskon
SELECT 
        CASE
          WHEN discount_percentage * 100 = 0 THEN 'Tidak Discount'
          WHEN discount_percentage * 100 > 0 AND discount_percentage * 100 <= 5 THEN '0 - 5%'
          WHEN discount_percentage * 100 > 5 AND discount_percentage * 100 <= 10 THEN '6 - 10%'
          WHEN discount_percentage * 100 > 10 AND discount_percentage * 100 <= 20 THEN '11 - 20%'
          ELSE '20 ke atas'
        END AS kategori_diskon,
        SUM(price * (1 - discount_percentage)) AS total_pendapatan,
        ROUND(AVG(price * (1 - discount_percentage)),3) AS rata_rata_pendapatan
FROM `kimia_farma.kf_final_transaction`
GROUP BY kategori_diskon
ORDER BY total_pendapatan DESC;
-- 1. Total Pendapatan Tertinggi ada di kategori diskon 0 - 5%, diikuti oleh 6 - 10% dan 11 - 20%.
--    Ini menunjukkan bahwa produk dengan diskon rendah masih mampu menghasilkan pendapatan besar.

-- 2. Rata-rata pendapatan per transaksi tertinggi ada di kategori Tanpa Diskon, disusul oleh 0 - 5%.
--    Menarik! Ini bisa berarti bahwa meskipun tanpa diskon, ada transaksi dengan nominal besar yang tetap terjadi.

-- Insight Potensial:

-- Diskon kecil (0 - 5%) cukup efektif untuk meningkatkan pendapatan tanpa mengurangi terlalu banyak margin keuntungan.
-- Diskon besar (11 - 20%) mulai mengalami penurunan pendapatan, mungkin karena strategi harga atau pelanggan lebih memilih produk dengan diskon kecil.
-- Tanpa diskon masih menghasilkan rata-rata pendapatan per transaksi yang tinggi → Mungkin produk-produk premium atau yang memiliki permintaan tinggi tetap dibeli tanpa perlu diskon besar.



-- --  total nett profit per kategori diskon
SELECT 
        CASE
          WHEN discount_percentage * 100 = 0 THEN 'Tidak Discount'
          WHEN discount_percentage * 100 > 0 AND discount_percentage * 100 <= 5 THEN '0 - 5%'
          WHEN discount_percentage * 100 > 5 AND discount_percentage * 100 <= 10 THEN '6 - 10%'
          WHEN discount_percentage * 100 > 10 AND discount_percentage * 100 <= 20 THEN '11 - 20%'
          ELSE '20 ke atas'
        END AS kategori_diskon,

        SUM(
            CASE
                WHEN price <= 50000 THEN (price * (1 - discount_percentage)) * 0.1
                WHEN price > 50000 AND price <= 100000 THEN (price * (1 - discount_percentage)) * 0.15
                WHEN price > 100000 AND price <= 300000 THEN (price * (1 - discount_percentage)) * 0.2
                WHEN price > 300000 AND price <= 500000 THEN (price * (1 - discount_percentage)) * 0.25
                ELSE (price * (1 - discount_percentage)) * 0.3
            END
            ) AS total_laba_bersih,

        ROUND(AVG(
            CASE
                WHEN price <= 50000 THEN (price * (1 - discount_percentage)) * 0.1
                WHEN price > 50000 AND price <= 100000 THEN (price * (1 - discount_percentage)) * 0.15
                WHEN price > 100000 AND price <= 300000 THEN (price * (1 - discount_percentage)) * 0.2
                WHEN price > 300000 AND price <= 500000 THEN (price * (1 - discount_percentage)) * 0.25
                ELSE (price * (1 - discount_percentage)) * 0.3
            END
            ),3) AS rata_rata_laba_bersih
FROM `kimia_farma.kf_final_transaction`
GROUP BY kategori_diskon
ORDER BY total_laba_bersih DESC;
