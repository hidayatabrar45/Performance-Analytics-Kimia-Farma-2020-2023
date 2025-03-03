-- ANALISIS PRODUK

-- Produk terlaris
SELECT 
    ft.product_id, 
    p.product_name, 
    COUNT(ft.transaction_id) AS jumlah_transaksi
FROM `kimia_farma.kf_final_transaction` ft
LEFT JOIN `kimia_farma.kf_product` p 
ON ft.product_id = p.product_id
GROUP BY ft.product_id, p.product_name
ORDER BY jumlah_transaksi DESC;
-- output: 3produk terlaris: 
---        1. Other analgesics and antipyretics, Pyrazolones and Anilides
---        2. Psycholeptics drugs, Hypnotics and sedatives drugs
---        3. Anti-inflammatory and antirheumatic products, non-steroids, Acetic acid derivatives and related substances


-- Total pendapatan per produk
-- 1. join kf_product dengan kf_final_transaction
SELECT 
    ft.product_id,
    p.product_name,
    SUM(ft.price * (1 - ft.discount_percentage)) AS total_pendapatan
FROM `kimia_farma.kf_final_transaction` AS ft
LEFT JOIN `kimia_farma.kf_product` AS p 
ON ft.product_id = p.product_id
GROUP BY ft.product_id, p.product_name
ORDER BY total_pendapatan DESC;

-- Produk paling menguntungkan
SELECT p.product_id,
      p.product_name,
      p.product_category,
      CASE -- jika harga (kriteria) dari total_pendapatan(nett_sales)
          WHEN ft.price <= 50000 THEN (ft.price * (1 - discount_percentage)) * 0.1
          WHEN ft.price > 50000 AND ft.price <= 100000 THEN (ft.price * (1 - discount_percentage)) * 0.15
          WHEN ft.price > 100000 AND ft.price <= 300000 THEN (ft.price * (1 - discount_percentage)) * 0.2
          WHEN ft.price > 300000 AND ft.price <= 500000 THEN (ft.price * (1 - discount_percentage)) * 0.25
          ELSE (ft.price * (1 - discount_percentage)) * 0.3
      END AS nett_profit
FROM `kimia_farma.kf_product` AS p
LEFT JOIN `kimia_farma.kf_final_transaction` AS ft
ON p.product_id = ft.product_id
GROUP BY p.product_id, p.product_name, p.product_category, ft.price, ft.discount_percentage
ORDER BY nett_profit DESC;

