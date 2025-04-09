/* Original */

SELECT 
    T0."DocEntry", 
    T0."DocNum", 
    T0."U_SYP_ORDEN_COMPRA",
    T0."DocDate", 
    T0."CardName", 
    T0."NumAtCard", 
    T1."ItemCode", 
    T1."Dscription" AS "Descripcion", 
    T2."U_LAB_SIS_FABRIC", 
    T1."AcctCode" AS "Cuenta Contable",
    CASE WHEN T0."NumAtCard" LIKE '04-001%' THEN ((CASE WHEN T1."NoInvtryMv" = 'N' THEN T1."Quantity" ELSE 0 END) * -1) ELSE T1."Quantity" END AS "CANTIDAD",
    T1."PriceBefDi"  As "Precio Unitario", 
    T1."StockPrice" AS "Costo", 
    T1."UomCode" AS "UoM",
    CASE WHEN T0."NumAtCard" LIKE '04-001%' THEN (T1."TotalSumSy" * -1) ELSE T1."TotalSumSy" END AS "Total Ingreso", (T1."Quantity" * T1."StockPrice") AS "Total Costo", 
    T1."TaxCode"  AS "IVA", 
    T1."GTotalSC" AS "Total Bruto", 
    T3."SlpName" AS "Vendedor",
    T2."U_SYP_PESOBRUTO" AS "PESO BRUTO", 
    T1."NoInvtryMv" As "No Mueve Inventario", 
    (T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1)) AS "Cant Conv", 
    ((T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1)) * (T2."U_SYP_PESOBRUTO" / COALESCE(A1."U_SYP_UPPL", 1))) AS "KG",
    (((T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1)) * (T2."U_SYP_PESOBRUTO" / COALESCE(A1."U_SYP_UPPL", 1))) / 1000) AS "Ton", 
    ((((T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1)) * (T2."U_SYP_PESOBRUTO" / COALESCE(A1."U_SYP_UPPL", 1))) / 1000) * T1."PriceBefDi") AS "D/T", 
    T4."Name" AS "SG1", 
    T5."Name" AS "SG2", 
    T6."Name" AS "SG3", 
    T7."Name" AS "SG4", 
    CASE WHEN T2."U_FIGU_SUBGRUPO5" = '0' THEN 'OPERATIVOS'
        WHEN T2."U_FIGU_SUBGRUPO5" = '1' THEN 'VASOS BF'
        WHEN T2."U_FIGU_SUBGRUPO5" = '2' THEN 'BUCKET'
        WHEN T2."U_FIGU_SUBGRUPO5" = '3' THEN 'TAPAS DE PAPEL'
        WHEN T2."U_FIGU_SUBGRUPO5" = '4' THEN 'EMPAQUES'
        WHEN T2."U_FIGU_SUBGRUPO5" = '5' THEN 'TAPAS PLASTICAS'
        WHEN T2."U_FIGU_SUBGRUPO5" = '6' THEN 'PLATOS'
        WHEN T2."U_FIGU_SUBGRUPO5" = '7' THEN 'VASOS BC'
        WHEN T2."U_FIGU_SUBGRUPO5" = '8' THEN 'HELADOS'
        WHEN T2."U_FIGU_SUBGRUPO5" = '9' THEN 'DESPERDICIOS'
        WHEN T2."U_FIGU_SUBGRUPO5" = '10' THEN 'BOLSA DE PAPEL'
        WHEN T2."U_FIGU_SUBGRUPO5" = '11' THEN 'STICKER'
        WHEN T2."U_FIGU_SUBGRUPO5" = '12' THEN 'CAMARON'
    ELSE T2."U_FIGU_SUBGRUPO5" END AS "SG5", 
    CASE WHEN T0."CANCELED" IN ('C', 'Y') THEN 'CANCELADO'
        WHEN T0."CANCELED" = 'N' THEN 'ACTIVO'
    ELSE T0."CANCELED" END AS "Cancelado", D1."CityS",
    T0."CardCode"

FROM OINV T0  
INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN INV12 D1 ON T0."DocEntry" = D1."DocEntry"
LEFT JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode" 
LEFT JOIN (
    SELECT *  FROM OITM A0 
    WHERE A0."ItemName" LIKE '%PACK%' ANd 
        A0."ItemCode" LIKE '07%' AND 
        A0."PriceUnit" = '16'
) A1 ON T2."ItemCode" = A1."ItemCode"
INNER JOIN OSLP T3 ON T0."SlpCode" = T3."SlpCode" 
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO1" T4 ON T2."U_SYP_SUBGRUPO1" = T4."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO2" T5 ON T2."U_SYP_SUBGRUPO2" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T2."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T2."U_SYP_SUBGRUPO4" = T7."Code"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]

UNION ALL

SELECT 
    T0."DocEntry", 
    T0."DocNum", 
    T0."U_LAB_ORDCOM", 
    T0."DocDate", 
    T0."CardName", 
    T0."NumAtCard", 
    T1."ItemCode", 
    T1."Dscription", 
    T3."U_LAB_SIS_FABRIC", 
    T1."AcctCode" AS "Cuenta Contable", 
    CASE WHEN T0."NumAtCard" LIKE '04-001%' THEN ((CASE WHEN T1."NoInvtryMv" = 'N' THEN T1."Quantity" ELSE 0 END) * -1) ELSE T1."Quantity" END AS "CANTIDAD", 
    T1."PriceBefDi" As "Precio Unitario", 
    T1."StockPrice", 
    T1."UomCode"  AS "UoM", 
    CASE WHEN T0."NumAtCard" LIKE '04-001%' THEN (T1."TotalSumSy" * -1) ELSE T1."TotalSumSy" END AS "Total Ingreso", (T1."Quantity" * T1."StockPrice") * -1 AS "Total Costo", 
    T1."TaxCode" AS "IVA", 
    (T1."GTotalSC" * -1) AS "Total Bruto", 
    T2."SlpName" AS "Vendedor", 
    T3."U_SYP_PESOBRUTO" AS "PESO BRUTO", 
    T1."NoInvtryMv" AS "No Mueve Inventario", 
    CASE WHEN T1."NoInvtryMv" = 'N' THEN (T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1) * -1)
        WHEN T1."NoInvtryMv" = 'Y' THEN '0' 
    END AS "Cant Conv", 
    CASE WHEN T1."NoInvtryMv" = 'N' THEN ((T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1)) * (T3."U_SYP_PESOBRUTO" / COALESCE(A1."U_SYP_UPPL", 1))) * -1 
        WHEN T1."NoInvtryMv" = 'Y' THEN '0' 
    END AS "KG", 
    CASE WHEN T1."NoInvtryMv" = 'N' THEN (((T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1)) * (T3."U_SYP_PESOBRUTO" / COALESCE(A1."U_SYP_UPPL", 1))) / 1000) * -1 
        WHEN T1."NoInvtryMv" = 'Y' THEN '0' 
    END AS "Ton", 
    ((((T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1)) * (T3."U_SYP_PESOBRUTO" / COALESCE(A1."U_SYP_UPPL", 1))) / 1000) * T1."PriceBefDi") AS "D/T", 
    T4."Name" AS "SG1", 
    T5."Name" AS "SG2", T6."Name" AS "SG3", T7."Name" AS "SG4", 
    CASE WHEN T3."U_FIGU_SUBGRUPO5" = '0' THEN 'OPERATIVOS'
        WHEN T3."U_FIGU_SUBGRUPO5" = '1' THEN 'VASOS BF'
        WHEN T3."U_FIGU_SUBGRUPO5" = '2' THEN 'BUCKET'
        WHEN T3."U_FIGU_SUBGRUPO5" = '3' THEN 'TAPAS DE PAPEL'
        WHEN T3."U_FIGU_SUBGRUPO5" = '4' THEN 'EMPAQUES'
        WHEN T3."U_FIGU_SUBGRUPO5" = '5' THEN 'TAPAS PLASTICAS'
        WHEN T3."U_FIGU_SUBGRUPO5" = '6' THEN 'PLATOS'
        WHEN T3."U_FIGU_SUBGRUPO5" = '7' THEN 'VASOS BC'
        WHEN T3."U_FIGU_SUBGRUPO5" = '8' THEN 'HELADOS'
        WHEN T3."U_FIGU_SUBGRUPO5" = '9' THEN 'DESPERDICIOS'
        WHEN T3."U_FIGU_SUBGRUPO5" = '10' THEN 'BOLSA DE PAPEL'
        WHEN T3."U_FIGU_SUBGRUPO5" = '11' THEN 'STICKER'
        WHEN T3."U_FIGU_SUBGRUPO5" = '12' THEN 'CAMARON'
    ELSE T3."U_FIGU_SUBGRUPO5" END AS "SG5", 
    CASE WHEN T0."CANCELED" IN ('C', 'Y') THEN 'CANCELADO'
        WHEN T0."CANCELED" = 'N' THEN 'ACTIVO'
    ELSE T0."CANCELED" END AS "Cancelado", 
    D1."CityS",
    T0."CardCode"

FROM ORIN T0
INNER JOIN RIN1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN RIN12 D1 ON T0."DocEntry" = D1."DocEntry"
INNER JOIN OSLP T2 ON T0."SlpCode" = T2."SlpCode"
LEFT JOIN OITM T3 ON T1."ItemCode" = T3."ItemCode"
LEFT JOIN (
    SELECT *  FROM OITM A0 
    WHERE A0."ItemName" LIKE '%PACK%' ANd 
    A0."ItemCode" LIKE '07%' AND 
    A0."PriceUnit" = '16'
) A1 ON T3."ItemCode" = A1."ItemCode"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO1" T4 ON T3."U_SYP_SUBGRUPO1" = T4."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO2" T5 ON T3."U_SYP_SUBGRUPO2" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T3."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T3."U_SYP_SUBGRUPO4" = T7."Code"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]


/* ADD EL RUC DEL CLIENTE */
SELECT 
    T0."DocEntry", 
    T0."DocNum", 
    T0."U_SYP_ORDEN_COMPRA",
    T0."DocDate", 
    T0."CardName", 
    T0."NumAtCard", 
    T1."ItemCode", 
    T1."Dscription" AS "Descripcion", 
    T2."U_LAB_SIS_FABRIC", 
    T1."AcctCode" AS "Cuenta Contable",
    CASE WHEN T0."NumAtCard" LIKE '04-001%' THEN ((CASE WHEN T1."NoInvtryMv" = 'N' THEN T1."Quantity" ELSE 0 END) * -1) ELSE T1."Quantity" END AS "CANTIDAD",
    T1."PriceBefDi"  As "Precio Unitario", 
    T1."StockPrice" AS "Costo", 
    T1."UomCode" AS "UoM",
    CASE WHEN T0."NumAtCard" LIKE '04-001%' THEN (T1."TotalSumSy" * -1) ELSE T1."TotalSumSy" END AS "Total Ingreso", (T1."Quantity" * T1."StockPrice") AS "Total Costo", 
    T1."TaxCode"  AS "IVA", 
    T1."GTotalSC" AS "Total Bruto", 
    T3."SlpName" AS "Vendedor",
    T2."U_SYP_PESOBRUTO" AS "PESO BRUTO", 
    T1."NoInvtryMv" As "No Mueve Inventario", 
    (T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1)) AS "Cant Conv", 
    ((T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1)) * (T2."U_SYP_PESOBRUTO" / COALESCE(A1."U_SYP_UPPL", 1))) AS "KG",
    (((T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1)) * (T2."U_SYP_PESOBRUTO" / COALESCE(A1."U_SYP_UPPL", 1))) / 1000) AS "Ton", 
    ((((T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1)) * (T2."U_SYP_PESOBRUTO" / COALESCE(A1."U_SYP_UPPL", 1))) / 1000) * T1."PriceBefDi") AS "D/T", 
    T4."Name" AS "SG1", 
    T5."Name" AS "SG2", 
    T6."Name" AS "SG3", 
    T7."Name" AS "SG4", 
    CASE WHEN T2."U_FIGU_SUBGRUPO5" = '0' THEN 'OPERATIVOS'
        WHEN T2."U_FIGU_SUBGRUPO5" = '1' THEN 'VASOS BF'
        WHEN T2."U_FIGU_SUBGRUPO5" = '2' THEN 'BUCKET'
        WHEN T2."U_FIGU_SUBGRUPO5" = '3' THEN 'TAPAS DE PAPEL'
        WHEN T2."U_FIGU_SUBGRUPO5" = '4' THEN 'EMPAQUES'
        WHEN T2."U_FIGU_SUBGRUPO5" = '5' THEN 'TAPAS PLASTICAS'
        WHEN T2."U_FIGU_SUBGRUPO5" = '6' THEN 'PLATOS'
        WHEN T2."U_FIGU_SUBGRUPO5" = '7' THEN 'VASOS BC'
        WHEN T2."U_FIGU_SUBGRUPO5" = '8' THEN 'HELADOS'
        WHEN T2."U_FIGU_SUBGRUPO5" = '9' THEN 'DESPERDICIOS'
        WHEN T2."U_FIGU_SUBGRUPO5" = '10' THEN 'BOLSA DE PAPEL'
        WHEN T2."U_FIGU_SUBGRUPO5" = '11' THEN 'STICKER'
        WHEN T2."U_FIGU_SUBGRUPO5" = '12' THEN 'CAMARON'
    ELSE T2."U_FIGU_SUBGRUPO5" END AS "SG5", 
    CASE WHEN T0."CANCELED" IN ('C', 'Y') THEN 'CANCELADO'
        WHEN T0."CANCELED" = 'N' THEN 'ACTIVO'
    ELSE T0."CANCELED" END AS "Cancelado", D1."CityS",
    T0."CardCode",
    T8."LicTradNum" AS "RUC Cliente"

FROM OINV T0  
INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN INV12 D1 ON T0."DocEntry" = D1."DocEntry"
LEFT JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode" 
LEFT JOIN (
    SELECT *  FROM OITM A0 
    WHERE A0."ItemName" LIKE '%PACK%' ANd 
        A0."ItemCode" LIKE '07%' AND 
        A0."PriceUnit" = '16'
) A1 ON T2."ItemCode" = A1."ItemCode"
INNER JOIN OSLP T3 ON T0."SlpCode" = T3."SlpCode" 
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO1" T4 ON T2."U_SYP_SUBGRUPO1" = T4."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO2" T5 ON T2."U_SYP_SUBGRUPO2" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T2."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T2."U_SYP_SUBGRUPO4" = T7."Code"
LEFT JOIN OCRD T8 ON T8."CardCode" = T0."CardCode" 
WHERE T0."DocDate" BETWEEN [%0] AND [%1] /*AND
    T0."CardName" LIKE '%CLAUDIA LIZETH BASTIDAS VILLARREAL%' OR
    T0."CardName" LIKE '%MARIA JOSE SALGADO%' OR
    T0."CardName" LIKE '%MARTÍNEZ CARMEN%' OR
    T0."CardName" LIKE '%JARAMILLO SANTIAGO%' OR
    T0."CardName" LIKE '%FULVIO FERNANDO ROMERO ROMERO%' OR
    T0."CardName" LIKE '%EDGAR ABEIGA%' OR
    T0."CardName" LIKE '%PESÁNTEZ CARRIÓN PATRICIO JOSUÉ%' OR
    T0."CardName" LIKE '%CECILIA BURBANO SERRANO%' OR
    T0."CardName" LIKE '%ALBERTO GREGORIO MURILLO BAJAÑA%' OR
    T0."CardName" LIKE '%JULIO ALBERTO DELGADO AYORA%' OR
    T0."CardName" LIKE '%The Myers Group Of Companies%' OR
    T0."CardName" LIKE '%GUIDO ANDRÉS CARRASCO SARMIENTO%'*/
    
  
UNION ALL

SELECT 
    T0."DocEntry", 
    T0."DocNum", 
    T0."U_LAB_ORDCOM", 
    T0."DocDate", 
    T0."CardName", 
    T0."NumAtCard", 
    T1."ItemCode", 
    T1."Dscription", 
    T3."U_LAB_SIS_FABRIC", 
    T1."AcctCode" AS "Cuenta Contable", 
    CASE WHEN T0."NumAtCard" LIKE '04-001%' THEN ((CASE WHEN T1."NoInvtryMv" = 'N' THEN T1."Quantity" ELSE 0 END) * -1) ELSE T1."Quantity" END AS "CANTIDAD", 
    T1."PriceBefDi" As "Precio Unitario", 
    T1."StockPrice", 
    T1."UomCode"  AS "UoM", 
    CASE WHEN T0."NumAtCard" LIKE '04-001%' THEN (T1."TotalSumSy" * -1) ELSE T1."TotalSumSy" END AS "Total Ingreso", (T1."Quantity" * T1."StockPrice") * -1 AS "Total Costo", 
    T1."TaxCode" AS "IVA", 
    (T1."GTotalSC" * -1) AS "Total Bruto", 
    T2."SlpName" AS "Vendedor", 
    T3."U_SYP_PESOBRUTO" AS "PESO BRUTO", 
    T1."NoInvtryMv" AS "No Mueve Inventario", 
    CASE WHEN T1."NoInvtryMv" = 'N' THEN (T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1) * -1)
        WHEN T1."NoInvtryMv" = 'Y' THEN '0' 
    END AS "Cant Conv", 
    CASE WHEN T1."NoInvtryMv" = 'N' THEN ((T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1)) * (T3."U_SYP_PESOBRUTO" / COALESCE(A1."U_SYP_UPPL", 1))) * -1 
        WHEN T1."NoInvtryMv" = 'Y' THEN '0' 
    END AS "KG", 
    CASE WHEN T1."NoInvtryMv" = 'N' THEN (((T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1)) * (T3."U_SYP_PESOBRUTO" / COALESCE(A1."U_SYP_UPPL", 1))) / 1000) * -1 
        WHEN T1."NoInvtryMv" = 'Y' THEN '0' 
    END AS "Ton", 
    ((((T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1)) * (T3."U_SYP_PESOBRUTO" / COALESCE(A1."U_SYP_UPPL", 1))) / 1000) * T1."PriceBefDi") AS "D/T", 
    T4."Name" AS "SG1", 
    T5."Name" AS "SG2", T6."Name" AS "SG3", T7."Name" AS "SG4", 
    CASE WHEN T3."U_FIGU_SUBGRUPO5" = '0' THEN 'OPERATIVOS'
        WHEN T3."U_FIGU_SUBGRUPO5" = '1' THEN 'VASOS BF'
        WHEN T3."U_FIGU_SUBGRUPO5" = '2' THEN 'BUCKET'
        WHEN T3."U_FIGU_SUBGRUPO5" = '3' THEN 'TAPAS DE PAPEL'
        WHEN T3."U_FIGU_SUBGRUPO5" = '4' THEN 'EMPAQUES'
        WHEN T3."U_FIGU_SUBGRUPO5" = '5' THEN 'TAPAS PLASTICAS'
        WHEN T3."U_FIGU_SUBGRUPO5" = '6' THEN 'PLATOS'
        WHEN T3."U_FIGU_SUBGRUPO5" = '7' THEN 'VASOS BC'
        WHEN T3."U_FIGU_SUBGRUPO5" = '8' THEN 'HELADOS'
        WHEN T3."U_FIGU_SUBGRUPO5" = '9' THEN 'DESPERDICIOS'
        WHEN T3."U_FIGU_SUBGRUPO5" = '10' THEN 'BOLSA DE PAPEL'
        WHEN T3."U_FIGU_SUBGRUPO5" = '11' THEN 'STICKER'
        WHEN T3."U_FIGU_SUBGRUPO5" = '12' THEN 'CAMARON'
    ELSE T3."U_FIGU_SUBGRUPO5" END AS "SG5", 
    CASE WHEN T0."CANCELED" IN ('C', 'Y') THEN 'CANCELADO'
        WHEN T0."CANCELED" = 'N' THEN 'ACTIVO'
    ELSE T0."CANCELED" END AS "Cancelado", 
    D1."CityS",
    T0."CardCode",
    T8."LicTradNum" AS "RUC Cliente"

FROM ORIN T0
INNER JOIN RIN1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN RIN12 D1 ON T0."DocEntry" = D1."DocEntry"
INNER JOIN OSLP T2 ON T0."SlpCode" = T2."SlpCode"
LEFT JOIN OITM T3 ON T1."ItemCode" = T3."ItemCode"
LEFT JOIN (
    SELECT *  FROM OITM A0 
    WHERE A0."ItemName" LIKE '%PACK%' ANd 
    A0."ItemCode" LIKE '07%' AND 
    A0."PriceUnit" = '16'
) A1 ON T3."ItemCode" = A1."ItemCode"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO1" T4 ON T3."U_SYP_SUBGRUPO1" = T4."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO2" T5 ON T3."U_SYP_SUBGRUPO2" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T3."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T3."U_SYP_SUBGRUPO4" = T7."Code"
LEFT JOIN OCRD T8 ON T8."CardCode" = T0."CardCode"
WHERE T0."DocDate" BETWEEN [%0] AND [%1] /*AND
    T0."CardName" LIKE '%CLAUDIA LIZETH BASTIDAS VILLARREAL%' OR
    T0."CardName" LIKE '%MARIA JOSE SALGADO%' OR
    T0."CardName" LIKE '%MARTÍNEZ CARMEN%' OR
    T0."CardName" LIKE '%JARAMILLO SANTIAGO%' OR
    T0."CardName" LIKE '%FULVIO FERNANDO ROMERO ROMERO%' OR
    T0."CardName" LIKE '%EDGAR ABEIGA%' OR
    T0."CardName" LIKE '%PESÁNTEZ CARRIÓN PATRICIO JOSUÉ%' OR
    T0."CardName" LIKE '%CECILIA BURBANO SERRANO%' OR
    T0."CardName" LIKE '%ALBERTO GREGORIO MURILLO BAJAÑA%' OR
    T0."CardName" LIKE '%JULIO ALBERTO DELGADO AYORA%' OR
    T0."CardName" LIKE '%The Myers Group Of Companies%' OR
    T0."CardName" LIKE '%GUIDO ANDRÉS CARRASCO SARMIENTO%'*/