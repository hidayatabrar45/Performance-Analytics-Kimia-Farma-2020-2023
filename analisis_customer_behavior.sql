-- ANALISIS CUSTOMER BEHAVIOR

-- Jumlah transaksi per customer
SELECT customer_name,
      SUM(CASE WHEN EXTRACT(YEAR FROM date) = 2020 THEN 1 ELSE 0 END) AS transaksi_2020,
      SUM(CASE WHEN EXTRACT(YEAR FROM date) = 2021 THEN 1 ELSE 0 END) AS transaksi_2021,
      SUM(CASE WHEN EXTRACT(YEAR FROM date) = 2022 THEN 1 ELSE 0 END) AS transaksi_2022,
      SUM(CASE WHEN EXTRACT(YEAR FROM date) = 2023 THEN 1 ELSE 0 END) AS transaksi_2023,
      COUNT(transaction_id) AS jumlah_transaksi
FROM `kimia_farma.kf_final_transaction`
GROUP BY customer_name
ORDER BY jumlah_transaksi DESC;

-- Jumlah transaksi per bulan dalam tahun
SELECT 
    EXTRACT(YEAR FROM date) AS tahun,
    EXTRACT(MONTH FROM date) AS bulan,
    COUNT(transaction_id) AS total_transaksi
FROM `kimia_farma.kf_final_transaction`
GROUP BY tahun, bulan
ORDER BY total_transaksi DESC;

--Jumlah transaksi pelanggan per tahun
--Dan kategori pelanggan 
--- Super Loyal: >50 transaksi per tahun, Loyal: 20-50 transaksi per tahun, Casual Buyer: 5-19 transaksi per tahun, One-time Buyer: ≤4 transaksi per tahun
SELECT 
    customer_name,
    EXTRACT(YEAR FROM date) AS tahun,
    COUNT(transaction_id) AS total_transaksi,
    CASE
        WHEN COUNT(transaction_id) >= 50 THEN 'Super Loyal'
        WHEN COUNT(transaction_id) BETWEEN 20 AND 49 THEN 'Loyal'
        WHEN COUNT(transaction_id) BETWEEN 10 AND 19 THEN 'Casual'
        ELSE 'One-time Buyer'
    END AS kategori_pelanggan
FROM `kimia_farma.kf_final_transaction`
GROUP BY customer_name, tahun
ORDER BY total_transaksi DESC;


-- Mencari total pelanggan berdasarkan kategori
SELECT 
    SUM(CASE WHEN kategori_pelanggan = 'Super Loyal' THEN 1 ELSE 0 END) AS super_loyal,
    SUM(CASE WHEN kategori_pelanggan = 'Loyal' THEN 1 ELSE 0 END) AS loyal,
    SUM(CASE WHEN kategori_pelanggan = 'Casual' THEN 1 ELSE 0 END) AS casual,
    SUM(CASE WHEN kategori_pelanggan = 'One-time Buyer' THEN 1 ELSE 0 END) AS one_time_buyer
FROM
(
  SELECT 
    customer_name,
    EXTRACT(YEAR FROM date) AS tahun,
    COUNT(transaction_id) AS total_transaksi,
    CASE
        WHEN COUNT(transaction_id) >= 50 THEN 'Super Loyal'
        WHEN COUNT(transaction_id) BETWEEN 20 AND 49 THEN 'Loyal'
        WHEN COUNT(transaction_id) BETWEEN 10 AND 19 THEN 'Casual'
        ELSE 'One-time Buyer'
    END AS kategori_pelanggan
FROM `kimia_farma.kf_final_transaction`
GROUP BY customer_name, tahun
)AS sub_query

-- total transaksi berdasarkan kategori
SELECT 
    kategori_pelanggan,
    SUM(total_transaksi) AS total_transaksi
FROM
(
  SELECT 
    customer_name,
    tahun,
    total_transaksi,
    CASE
        WHEN total_transaksi >= 50 THEN 'Super Loyal'
        WHEN total_transaksi BETWEEN 20 AND 49 THEN 'Loyal'
        WHEN total_transaksi BETWEEN 10 AND 19 THEN 'Casual'
        ELSE 'One-time Buyer'
    END AS kategori_pelanggan
  FROM (
      SELECT 
          customer_name,
          EXTRACT(YEAR FROM date) AS tahun,
          COUNT(transaction_id) AS total_transaksi
      FROM `kimia_farma.kf_final_transaction`
      GROUP BY customer_name, tahun
  ) AS transaksi_per_pelanggan
) AS pelanggan_kategori
GROUP BY kategori_pelanggan
ORDER BY total_transaksi DESC;



-- jumlah transaksi per bulan dari 2020-2023
SELECT 
    bulan,
    SUM(CASE WHEN tahun = 2020 THEN total_transaksi ELSE 0 END) AS tahun_2020,
    SUM(CASE WHEN tahun = 2021 THEN total_transaksi ELSE 0 END) AS tahun_2021,
    SUM(CASE WHEN tahun = 2022 THEN total_transaksi ELSE 0 END) AS tahun_2022,
    SUM(CASE WHEN tahun = 2023 THEN total_transaksi ELSE 0 END) AS tahun_2023
FROM
(
  SELECT 
    EXTRACT(MONTH FROM date) AS bulan,
    EXTRACT(YEAR FROM date) AS tahun,
    COUNT(transaction_id) AS total_transaksi
  FROM `kimia_farma.kf_final_transaction`
  GROUP BY bulan, tahun
) AS sub_query
GROUP BY bulan
ORDER BY bulan;
--- jumlah transaksi setiap bulan dalam tahun 2020-2023 tidak terlalu fluktuatif, ada direntang 12000 sampai 14000



-- Retensi rate pelanggan / Mengetahui customer yang bertahan
WITH pelanggan_per_tahun AS ( -- CTE tabel pelanggan per tahun
    SELECT 
        customer_name, 
        EXTRACT(YEAR FROM date) AS tahun
    FROM `kimia_farma.kf_final_transaction`
    GROUP BY customer_name, tahun
),

retensi AS ( -- CTE tabel retensi
    SELECT 
        p1.tahun AS tahun_sekarang,
        COUNT(DISTINCT p1.customer_name) AS total_customer,
        COUNT(DISTINCT p1.customer_name) - COUNT(DISTINCT p2.customer_name) AS lost_customer, -- pelanggan tahun sekarang - pelanggan tahun sebelumnya = pelanggan yang hilang
        COUNT(DISTINCT p2.customer_name) AS retained_customer -- retained customer adalah pelanggan yang bertahan
    FROM pelanggan_per_tahun AS p1
    LEFT JOIN pelanggan_per_tahun AS p2
    ON p1.customer_name = p2.customer_name AND p1.tahun = p2.tahun + 1 -- contoh = p1 2022, p2 2021. maka p1 = p2 + 1
    GROUP BY p1.tahun
)
SELECT *, 
    ROUND((retained_customer / total_customer) * 100, 2) AS retention_rate --persentase pelanggan yang kembali belanja
FROM retensi
ORDER BY tahun_sekarang;


-- Pelanggan yang hanya sekali belanja
WITH total_transaksi_per_pelanggan AS (
    SELECT 
        customer_name,
        COUNT(DISTINCT EXTRACT(YEAR FROM date)) AS jumlah_tahun_transaksi
    FROM `kimia_farma.kf_final_transaction`
    GROUP BY customer_name
)
SELECT 
    COUNT(customer_name) AS jumlah_pelanggan_once,
    COUNT(customer_name) / (SELECT COUNT(DISTINCT customer_name) FROM `kimia_farma.kf_final_transaction`) * 100 AS persen_once
FROM total_transaksi_per_pelanggan
WHERE jumlah_tahun_transaksi = 1;