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


04EDI07140018


Explicación de la condición:
T0."DocDate" < CURRENT_DATE:

Esta parte de la condición selecciona todos los documentos cuya fecha ("DocDate") es anterior al día actual (CURRENT_DATE). Esto significa que cualquier documento de ayer o de días anteriores se incluirá sin considerar la hora.

OR (T0."DocDate" = CURRENT_DATE AND T0."DocTime" < 160000):

Esta parte de la condición se aplica cuando el documento es del día actual (T0."DocDate" = CURRENT_DATE).

Dentro de esta condición, se verifica que la hora del documento (T0."DocTime") sea menor que 160000, que representa las 4:00 PM en formato numérico (HHMMSS).

Esto significa que si el documento es del día actual, solo se incluirá si fue creado antes de las 4:00 PM.


SELECT
    --T0."DocEntry",
    T0."DocNum" AS "NumDocPedido",
    T0."DocDate" AS "FechaDocPedido",
    T0."DocTime" AS "HoraDocPedido",
    --T0."CreateTS",
    --T0."CreateDate",
    --TO_NVARCHAR(TO_TIME(T0."CreateDate"), 'HH24:MI:SS') AS "HoraInicio",
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
    P2."DocTime" AS "HoraDocSC",
    P2."CreateTS"
FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PRQ1 P1 ON T1."BaseEntry" = P1."DocEntry" AND T1."BaseLine" = P1."LineNum"
LEFT JOIN OPRQ P2 ON P1."DocEntry" = P2."DocEntry"
LEFT JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
WHERE T0."DocStatus" = 'O' 
AND (
    T0."DocDate" < CURRENT_DATE -- cualquier documento de ayer o de días anteriores se incluirá sin considerar la hora.
     OR 
        (T0."DocDate" = CURRENT_DATE AND T0."DocTime" < 160000)  --si el documento es del día actual, solo se incluirá si fue creado antes de las 4:00 PM.
    ) 
AND T0."DocDate" >= ADD_DAYS(CURRENT_DATE, -7)
AND P2."Requester" = 'MAN01'
ORDER BY T0."DocDate";

-- *****************************************************************************************************************

SELECT

 P2."DocNum" AS "NumDocSC",
    P2."DocDate" AS "FechaDocSC",
    P2."DocTime" AS "HoraDocSC",
    P2."CreateTS",
    
    --T0."DocEntry",
    T0."DocNum" AS "NumDocPedido",
    T0."DocDate" AS "FechaDocPedido",
    T0."DocTime" AS "HoraDocPedido",
    T0."CreateTS",
    T0."CreateDate",
    --TO_NVARCHAR(TO_TIME(T0."CreateDate"), 'HH24:MI:SS') AS "HoraInicio",
    CASE 
        WHEN T0."DocType" = 'I' THEN 'Articulo'
        WHEN T0."DocType" = 'S' THEN 'Servicio'
    END AS "Tipo",
    --T0."DocStatus", 
    T1."ItemCode",
    COALESCE(T2."ItemName", T1."Dscription")
    --P2."DocEntry",
   
FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PRQ1 P1 ON T1."BaseEntry" = P1."DocEntry" AND T1."BaseLine" = P1."LineNum"
LEFT JOIN OPRQ P2 ON P1."DocEntry" = P2."DocEntry"
LEFT JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
WHERE T0."DocStatus" = 'O' 
AND (
    T0."CreateDate" < CURRENT_DATE -- cualquier documento de ayer
     OR 
        (T0."CreateDate" = CURRENT_DATE AND T0."DocTime" < 160000)  --si el documento es del día actual, solo se incluirá si fue creado antes de las 4:00 PM. FORMATO HMS
    ) 
AND T0."CreateDate" >= ADD_DAYS(CURRENT_DATE, -7)
/*AND (
    T0."DocDate" < CURRENT_DATE -- cualquier documento de ayer
     OR 
        (T0."DocDate" = CURRENT_DATE AND T0."DocTime" < 160000)  --si el documento es del día actual, solo se incluirá si fue creado antes de las 4:00 PM. FORMATO HMS
    ) 
AND T0."DocDate" >= ADD_DAYS(CURRENT_DATE, -7)*/
AND P2."Requester" = 'MAN01'
ORDER BY T0."DocDate";


-- *****************************************************************************************************************************

SELECT
    --P2."DocEntry",
    P2."DocNum" AS "NumDocSC",
    P2."DocDate" AS "FechaDocSC",
    P2."DocTime" AS "HoraDocSC",
    --P2."CreateTS",
    
    --T0."DocEntry",
    T0."DocNum" AS "NumDocPedido",
    T0."DocDate" AS "FechaDocPedido",
    T0."DocTime" AS "HoraDocPedido",
    --T0."CreateTS",
    T0."CreateDate",
    CASE 
        WHEN T0."DocType" = 'I' THEN 'Articulo'
        WHEN T0."DocType" = 'S' THEN 'Servicio'
    END AS "Tipo",
    T1."ItemCode",
    COALESCE(T2."ItemName", T1."Dscription")
    
   
FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PRQ1 P1 ON T1."BaseEntry" = P1."DocEntry" AND T1."BaseLine" = P1."LineNum"
LEFT JOIN OPRQ P2 ON P1."DocEntry" = P2."DocEntry"
LEFT JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
WHERE T0."DocStatus" = 'O' 
AND (
    T0."CreateDate" < CURRENT_DATE -- cualquier documento de ayer
     OR 
        (T0."CreateDate" = CURRENT_DATE AND T0."DocTime" < 160000)  --si el documento es del día actual, solo se incluirá si fue creado antes de las 4:00 PM. FORMATO HMS
    ) 
AND T0."CreateDate" >= ADD_DAYS(CURRENT_DATE, -7)
AND P2."Requester" = 'MAN01'