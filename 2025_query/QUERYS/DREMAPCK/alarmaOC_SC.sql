SELECT 
    T0."DocEntry",
    T0."DocNum",
    T1."DocEntry",
    T1."DocNum",
    T2."ItemCode",
    T2."Quantity",
    T2."Price"
FROM 
    OPRQ T0  -- Solicitud de Compra
INNER JOIN 
    OPOR T1 ON T0."DocEntry" = T1."BaseEntry"  -- Orden de Compra
INNER JOIN 
    POR1 T2 ON T1."DocEntry" = T2."DocEntry"  -- Líneas de Orden de Compra
WHERE 
    T0."DocNum" = '25000478' --$[OPRQ.DocNum]  -- Filtro por el número de solicitud de compra


    -- *****************************************


SELECT
    T0."DocEntry",
    T0."DocNum", 
    T1."ItemCode",
    P2."DocEntry",
    P2."DocNum"
FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PRQ1 P1 ON T1."BaseEntry" = P1."DocEntry" AND T1."BaseLine" = P1."LineNum"
LEFT JOIN OPRQ P2 ON P1."DocEntry" = P2."DocEntry"
WHERE T0."DocNum" = '25000701';