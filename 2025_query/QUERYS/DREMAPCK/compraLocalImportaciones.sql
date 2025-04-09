SELECT 
    YEAR(fecha_compra) AS año,
    SUM(total_compras) AS total_compras,
    SUM(CASE WHEN tipo_compra = 'local' THEN total_compras ELSE 0 END) AS compras_locales,
    SUM(CASE WHEN tipo_compra = 'importacion' THEN total_compras ELSE 0 END) AS compras_importaciones,
    (SUM(CASE WHEN tipo_compra = 'local' THEN total_compras ELSE 0 END) / SUM(total_compras)) * 100 AS porcentaje_local,
    (SUM(CASE WHEN tipo_compra = 'importacion' THEN total_compras ELSE 0 END) / SUM(total_compras)) * 100 AS porcentaje_importaciones
FROM 
    compras
WHERE 
    YEAR(fecha_compra) IN (2022, 2023, 2024)
GROUP BY 
    YEAR(fecha_compra)
ORDER BY 
    año;


--SELECT T0."U_SYP_TIPCOMPRA" FROM OPCH T0 LIMIT 10

SELECT 
    YEAR(T0.DocDate) AS año,
    SUM(T0.DocTotal) AS total_compras,
    SUM(CASE WHEN T1.LineTotal > 0 THEN T1.LineTotal ELSE 0 END) AS compras_locales,
    SUM(CASE WHEN T1.LineTotal < 0 THEN T1.LineTotal ELSE 0 END) AS compras_importaciones,
    (SUM(CASE WHEN T1.LineTotal > 0 THEN T1.LineTotal ELSE 0 END) / SUM(T0.DocTotal)) * 100 AS porcentaje_local,
    (SUM(CASE WHEN T1.LineTotal < 0 THEN T1.LineTotal ELSE 0 END) / SUM(T0.DocTotal)) * 100 AS porcentaje_importaciones
FROM 
    OPCH T0
INNER JOIN 
    PCH1 T1 ON T0.DocEntry = T1.DocEntry
WHERE 
    YEAR(T0.DocDate) IN (2022, 2023, 2024)
GROUP BY 
    YEAR(T0.DocDate)
ORDER BY 
    año;



SELECT 
    YEAR(T0."DocDate") AS "año",
    SUM(T0."DocTotal") AS "total_compras",
    SUM(CASE WHEN T0."U_SYP_TIPCOMPRA" = '01' THEN T0.DocTotal ELSE 0 END) AS "compras_locales",
    SUM(CASE WHEN T0."U_SYP_TIPCOMPRA" = '02' THEN T0.DocTotal ELSE 0 END) AS "compras_importaciones",
    --(SUM(CASE WHEN T0."U_SYP_TIPCOMPRA" = '01' THEN T0.DocTotal ELSE 0 END) / SUM(T0.DocTotal)) * 100 AS porcentaje_local,
    --(SUM(CASE WHEN T0.U_SYP_TIPCOMPRA = '02' THEN T0.DocTotal ELSE 0 END) / SUM(T0.DocTotal)) * 100 AS porcentaje_importaciones
FROM 
    OPCH T0
WHERE 
    YEAR(T0."DocDate") IN (2022, 2023, 2024)
GROUP BY 
    YEAR(T0."DocDate")
LIMIT 10;


/* **************Opcion 1**************** */

SELECT
    YEAR(T0."DocDate") AS "año",
    SUM(T0."DocTotal") AS "total_compras",
    (SELECT SUM(T1."DocTotal") FROM OPCH T1 WHERE YEAR(T1."DocDate") = YEAR(T0."DocDate") AND T1."U_SYP_TIPCOMPRA" = '01') AS "compras_locales",
    (SELECT SUM(T2."DocTotal") FROM OPCH T2 WHERE YEAR(T2."DocDate") = YEAR(T0."DocDate") AND T2."U_SYP_TIPCOMPRA" = '02') AS "compras_importaciones"
FROM
    OPCH T0
WHERE
    YEAR(T0."DocDate") IN (2022, 2023, 2024)
GROUP BY
    YEAR(T0."DocDate")
ORDER BY
    "año";


/* **************Opcion 2**************** */

SELECT 
    YEAR(T0."DocDate") AS "año",
    --SUM(T0."DocTotal") AS "total_compras",
    SUM(CASE WHEN T0."U_SYP_TIPCOMPRA" = '01' THEN T0."DocTotal" ELSE 0 END) AS "compras_locales",
    SUM(CASE WHEN T0."U_SYP_TIPCOMPRA" = '02' THEN T0."DocTotal" ELSE 0 END) AS "compras_importaciones"
   
FROM 
    OPCH T0
WHERE 
    YEAR(T0."DocDate") IN (2022, 2023, 2024)
GROUP BY 
    YEAR(T0."DocDate");

-- **************Opcion 3********************

SELECT
    YEAR(T0."DocDate") AS "año",
    SUM(T0."DocTotal") AS "total_compras",
    (SELECT SUM(T1."DocTotal") FROM OPCH T1 WHERE YEAR(T1."DocDate") = YEAR(T0."DocDate") AND T1."U_SYP_TIPCOMPRA" = '01') AS "compras_locales",
    (SELECT SUM(T2."DocTotal") FROM OPCH T2 WHERE YEAR(T2."DocDate") = YEAR(T0."DocDate") AND T2."U_SYP_TIPCOMPRA" = '02') AS "compras_importaciones",
    (SUM(CASE WHEN T0."U_SYP_TIPCOMPRA" = '01' THEN T0."DocTotal" ELSE 0 END) / SUM(T0."DocTotal")) * 100 AS "porcentaje_local",
    (SUM(CASE WHEN T0."U_SYP_TIPCOMPRA" = '02' THEN T0."DocTotal" ELSE 0 END) / SUM(T0."DocTotal")) * 100 AS "porcentaje_importaciones"
FROM
    OPCH T0
WHERE
    YEAR(T0."DocDate") IN (2022, 2023, 2024) AND (T0."U_SYP_TIPCOMPRA" IN ('01', '02'))
GROUP BY
    YEAR(T0."DocDate")
ORDER BY
    "año";
