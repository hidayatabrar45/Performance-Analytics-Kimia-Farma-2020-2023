-- Analisis Inventory

-- Produk dengan stok tertinggi dan terendah
SELECT product_name, opname_stock
FROM `kimia_farma.kf_inventory`
ORDER BY opname_stock DESC;

SELECT product_name, opname_stock
FROM `kimia_farma.kf_inventory`
ORDER BY opname_stock ASC;


--Distribusi stok per cabang
SELECT 
    branch_id,
    SUM(opname_stock) AS total_stok
FROM `kimia_farma.kf_inventory`
GROUP BY branch_id
ORDER BY total_stok ASC;

--Distribusi stok per provinsi
SELECT 
    kc.provinsi,
    SUM(i.opname_stock) AS total_stok
FROM `kimia_farma.kf_inventory` AS i
LEFT JOIN `kimia_farma.kf_kantor_cabang` AS kc
ON i.branch_id = kc.branch_id
GROUP BY kc.provinsi
ORDER BY total_stok DESC;



