-- ORIGINAL
-- es si tiene vinculado una orden de venta una oferta de venta, aparezca en una columna con el numero de asociacion
SELECT 
    T0."DocNum",T0."NumAtCard" ,T0."DocDate", T0."DocDueDate", T0."CardName", 
    T1."ItemCode", T1."Dscription",T1."Quantity"*T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty"*T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad", T1."Price"/T1."NumPerMsr", T1."TaxCode",
    T2."CityS",T2."StreetS",T0."Comments",T4."SlpName", T1."WhsCode" 
FROM ORDR
T0 INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode"=T4."SlpCode"  

WHERE T1."LineStatus" = 'O' AND T1."WhsCode" IN ('10PTE','10FPTE','10EPTE')


-- *********************************************************************

/* OPCION 1 */
SELECT 
    A0."DocNum" AS "Oferta Venta Asociada",
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate",
    T0."DocDueDate",
    T0."CardName",
    T1."ItemCode",
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad",
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr" AS "Precio Unitario",
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName",
    T1."WhsCode"
    
FROM ORDR T0
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry"
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"
LEFT JOIN OQUT A0 ON T1."BaseEntry" = A0."DocEntry" AND T1."BaseType" = 23
WHERE T1."LineStatus" = 'O'
AND T1."WhsCode" IN ('10PTE', '10FPTE', '10EPTE');


/* OPCION 2 */
SELECT 
    T0."DocNum", 
    T0."NumAtCard", 
    T0."DocDate", 
    T0."DocDueDate", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription", 
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante", 
    T1."UomCode2" AS "Unidad", 
    T1."Price" / T1."NumPerMsr" AS "Precio Unitario", 
    T1."TaxCode", 
    T2."CityS", 
    T2."StreetS", 
    T0."Comments", 
    T4."SlpName", 
    T1."WhsCode",
    -- Subconsulta para obtener el número de asociación con la oferta de venta
    (SELECT TOP 1 Q."DocNum" 
     FROM QUT1 Q 
     WHERE Q."BaseEntry" = T0."DocEntry" AND Q."BaseType" = 17) AS "NumeroOfertaAsociada"
FROM 
    ORDR T0 
    INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
    INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
    LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
    LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
WHERE 
    T1."LineStatus" = 'O' 
    AND T1."WhsCode" IN ('10PTE', '10FPTE', '10EPTE');



/* Añadir la oferta de venta asociada a la orden de venta */
SELECT 
     T5."DocNum" AS "SalesQuoteNum",
    T0."DocNum", T0."NumAtCard", T0."DocDate", T0."DocDueDate", T0."CardName", 
    T1."ItemCode", T1."Dscription", T1."Quantity"*T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty"*T1."NumPerMsr" AS "Cantidad Abierta Restante", 
    T1."UomCode2" AS "Unidad", T1."Price"/T1."NumPerMsr", T1."TaxCode", 
    T2."CityS", T2."StreetS", T0."Comments", T4."SlpName", T1."WhsCode"
FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode" 
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"
LEFT JOIN OQUT T5 ON T1."BaseEntry" = T5."DocEntry" AND T1."BaseType" = 23
WHERE T1."LineStatus" = 'O' AND T1."WhsCode" IN ('10PTE','10FPTE','10EPTE')


SELECT 
     --T5."DocNum" AS "SalesQuoteNum",
    T1."BaseEntry",

    T0."DocNum", T0."NumAtCard", T0."DocDate", T0."DocDueDate", T0."CardName", 
    T1."ItemCode", T1."Dscription", T1."Quantity"*T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty"*T1."NumPerMsr" AS "Cantidad Abierta Restante", 
    T1."UomCode2" AS "Unidad", T1."Price"/T1."NumPerMsr", T1."TaxCode", 
    T2."CityS", T2."StreetS", T0."Comments", T4."SlpName", T1."WhsCode"
FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode" 
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"
--LEFT JOIN OQUT T5 ON T1."DocEntry" = T5."DocEntry" AND T1."BaseType" = 23
WHERE T1."LineStatus" = 'O' AND T1."WhsCode" IN ('10PTE','10FPTE','10EPTE')



-- *******************************************************************************************


SELECT 
    T5.ItmsGrpNam, SUM(T1.Quantity) as 'kg Qty Sales Quotation' ,SUM(T2.Quantity) as 'kg Qty Sales Order'

FROM OQUT T0
INNER JOIN QUT1 T1 ON T1.DocEntry = T0.DocEntry
INNER JOIN RDR1 T2 ON T2.BaseEntry = T1.DocEntry AND T2.BaseLine = T1.LineNum
INNER JOIN ORDR T3 ON T3.DocEntry = T2.DocEntry


INNER JOIN OITM T4 ON T4.ItemCode = T1.ItemCode
INNER JOIN OITB T5 ON T5.ItmsGrpCod = T4.ItmsGrpCod
WHERE T0.CardCode  = 'C004885'      AND  T3.CardCode= 'C004885'

GROUP By T5.ItmsGrpNam

ORDER BY SUM(T1.Quantity) DESC



-- ORDR T0  
-- INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry", 
-- QUT1 T2 
-- INNER JOIN OQUT T3 ON T2."DocEntry" = T3."DocEntry"





/*Ordenes de Venta Abiertas Artículos EPM - OPCION 3 REVISAR CON MI JEFE */
SELECT
    'Orden de Venta' AS "Tipo de Documento",
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate",
    T0."DocDueDate",
    T0."CardName",
    T1."ItemCode",
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad",
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr",
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName",
    T1."WhsCode"
    
FROM
    ORDR T0
INNER JOIN
    RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN
    RDR12 T2 ON T0."DocEntry" = T2."DocEntry"
LEFT JOIN
    OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN
    OSLP T4 ON T3."SlpCode" = T4."SlpCode"
WHERE
    T1."LineStatus" = 'O' AND T1."WhsCode" IN ('10PTE', '10FPTE', '10EPTE')

UNION ALL

SELECT
    'Oferta de Venta' AS "Tipo de Documento",
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate",
    T0."DocDueDate",
    T0."CardName",
    T1."ItemCode",
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad",
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr",
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName",
    T1."WhsCode"
    
FROM
    OQUT T0
INNER JOIN
    QUT1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN
    QUT12 T2 ON T0."DocEntry" = T2."DocEntry"
LEFT JOIN
    OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN
    OSLP T4 ON T3."SlpCode" = T4."SlpCode"
WHERE
    T1."LineStatus" = 'O' --AND T1."WhsCode" IN ('10PTE', '10FPTE', '10EPTE');


/*opcion 4  */

SELECT
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate",
    T0."DocDueDate",
    T0."CardName",
    (SELECT
         CASE
             WHEN COUNT(L."BaseEntry") > 0 THEN MAX(L."BaseEntry")
             ELSE NULL
         END
     FROM
         RDR1 L
     WHERE
         L."TargetType" IN (17, 23) AND L."BaseEntry" = T0."DocEntry"
    ) AS "Número de Documento Vinculado",
    T1."ItemCode",
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad",
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr",
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName",
    T1."WhsCode"
FROM
    ORDR T0
INNER JOIN
    RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN
    RDR12 T2 ON T0."DocEntry" = T2."DocEntry"
LEFT JOIN
    OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN
    OSLP T4 ON T3."SlpCode" = T4."SlpCode"
WHERE
    T1."LineStatus" = 'O' AND T1."WhsCode" IN ('10PTE', '10FPTE', '10EPTE');


-- *********************************************************************************************

/* SELECT 
    T0."DocNum",  -- Número de Documento de la Orden
    T0."NumAtCard", -- Número de Referencia del Cliente
    T0."DocDate", -- Fecha de la Orden
    T0."DocDueDate", -- Fecha de Vencimiento
    T0."CardName", -- Nombre del Cliente
    T1."ItemCode", -- Código del Artículo
    T1."Dscription", -- Descripción del Artículo
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", -- Cantidad
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante", -- Cantidad Abierta Restante
    T1."UomCode2" AS "Unidad", -- Unidad de Medida
    T1."Price" / T1."NumPerMsr" AS "Precio", -- Precio
    T1."TaxCode", -- Código de Impuesto
    T2."CityS", -- Ciudad de Envío
    T2."StreetS", -- Calle de Envío
    T0."Comments", -- Comentarios
    T4."SlpName", -- Nombre del Empleado de Ventas
    T1."WhsCode",  -- Código de Almacén
    
    -- Aquí está la parte agregada para vincular y mostrar el Número de Cotización de Venta
    (SELECT DISTINCT T5."DocNum" 
     FROM QUOT1 T6 
     INNER JOIN OQUT T5 ON T6."DocEntry" = T5."DocEntry"
     WHERE T6."BaseType" = 17 AND T6."BaseEntry" = T0."DocEntry" AND T6."BaseLine" = T1."LineNum") AS "NumeroCotizacion"
    
FROM ORDR T0
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry"
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"
WHERE T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTE', '10FPTE', '10EPTE') */


--SELECT T0."ObjType", * FROM OQUT T0

--SELECT T0."DocNum", T0."NumAtCard", * FROM ORDR T0 WHERE T0."ObjType" = 23 LIMIT 200

SELECT 
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate",
    T0."DocDueDate",
    T0."CardName",
    T1."ItemCode",
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad",
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr" AS "Precio",
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName",
    T1."WhsCode",
    T5."DocNum" AS "NumeroCotizacion"

FROM ORDR T0
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry"
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"
LEFT JOIN QUOT1 T6 ON T1."DocEntry" = T6."BaseEntry" AND T1."LineNum" = T6."BaseLine" AND T6."BaseType" = 17
LEFT JOIN OQUT T5 ON T6."DocEntry" = T5."DocEntry"

WHERE T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTE', '10FPTE', '10EPTE')


--   *****************************************************************
/* 24-02-2025 */

/* Sse add la Oferta de venta vinculada con la orden de venta */
SELECT 
    T5."DocNum" AS "Numero Doc Oferta de Venta",
    --T0."U_beas_type",
    --T0."ObjType",
    --T0."DocEntry",
    --T1."DocEntry",

    --T1."BaseRef",
    --T1."BaseType",
    T0."DocNum", 
    T0."NumAtCard", 
    T0."DocDate", 
    T0."DocDueDate", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity"*T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty"*T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad", 
    T1."Price"/T1."NumPerMsr", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode" 

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"
LEFT JOIN OQUT T5 ON CAST(T1."BaseRef" AS VARCHAR) = CAST(T5."DocNum" AS VARCHAR) AND T1."BaseType" = '23'
WHERE T1."LineStatus" = 'O' AND T1."WhsCode" IN ('10PTE','10FPTE','10EPTE')





