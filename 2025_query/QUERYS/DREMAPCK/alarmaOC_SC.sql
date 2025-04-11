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


-- ++++++++++++++++++++++++++++++++++++++++++++++++

SELECT
    --T0."DocEntry",
    T0."DocNum" AS "NumDocPedido",
    T0."DocDate" AS "FechaDocPedido",
    CASE 
        WHEN T0."DocType" = 'I' THEN 'Articulo'
        WHEN T0."DocType" = 'S' THEN 'Servicio'
    END AS "Tipo",
    --T0."DocStatus", 
    T1."ItemCode",
    COALESCE(T2."ItemName", T1."Dscription"),
    --P2."DocEntry",
    P2."DocNum" AS "NumDocSC",
    T0."DocDate" AS "FechaDocSC"
FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PRQ1 P1 ON T1."BaseEntry" = P1."DocEntry" AND T1."BaseLine" = P1."LineNum"
LEFT JOIN OPRQ P2 ON P1."DocEntry" = P2."DocEntry"
LEFT JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
WHERE T0."DocStatus" = 'O' 
--AND T0."DocDate" >= ADD_DAYS(CURRENT_DATE, -1)  -- desde ayer
--T0."DocNum" = '25000701';





*******************alarma oc avierta con sc**************+
SELECT
    --T0."DocEntry",
    T0."DocNum" AS "NumDocPedido",
    T0."DocDate" AS "FechaDocPedido",
    T0."DocTime" AS "HoraDocPedido",
    CASE 
        WHEN T0."DocType" = 'I' THEN 'Articulo'
        WHEN T0."DocType" = 'S' THEN 'Servicio'
    END AS "Tipo",
    --T0."DocStatus", 
    T1."ItemCode",
    COALESCE(T2."ItemName", T1."Dscription"),
    --P2."DocEntry",
    P2."DocNum" AS "NumDocSC",
    P2."DocDate" AS "FechaDocSC",
    P2."DocTime" AS "HoraDocSC"
FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PRQ1 P1 ON T1."BaseEntry" = P1."DocEntry" AND T1."BaseLine" = P1."LineNum"
LEFT JOIN OPRQ P2 ON P1."DocEntry" = P2."DocEntry"
LEFT JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
WHERE T0."DocStatus" = 'O' AND T0."DocDate" >= ADD_DAYS(CURRENT_DATE, -7)  -- desde ayer
AND P2."Requester" = 'MAN01'
ORDER BY T0."DocDate" 
--T0."DocNum" = '25000701';