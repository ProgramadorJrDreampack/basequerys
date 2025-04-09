--SELECT T0."DocNum", T0."ObjType", T0."CANCELED" FROM OPOR T0 LIMIT 5
SELECT 
    --T0."CANCELED",
    T0."DocStatus",
    T0."DocNum",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."ItemCode",
    T1."Dscription",
    T1."Quantity",
    T1."OpenCreQty"
FROM 
    OPOR T0 
INNER JOIN 
    POR1 T1 ON T0."DocEntry" = T1."DocEntry"
WHERE 
     T0."DocStatus" = 'O'
   --T1."OpenCreQty" > 0;

-- ***************************************************************************



SELECT 
T0."U_DPE_DOC_NUM",* 
FROM "@DPE_TIP_GASTO" T0 
INNER JOIN OPOR T1 ON T0."U_DPE_DOC_NUM" = T1."DocNum"
--WHERE T0."U_DPE_DOC_NUM"

















-- *********************************************************
   SELECT * FROM "@SYP_PROV"

--SELECT * FROM "@SYP_CANTON"

-- ***************************************************************
SELECT T0."Code", T0."Name" FROM "@SYP_PROV" T0

SELECT T0."U_SYP_PROV", T0."U_SYP_DESCCANTON" FROM "@SYP_CANTON" T0 WHERE T0."U_SYP_PROV" = '24'


-- *********************************************************************

-- ITEM Y VARIABLE
-- SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;

SELECT $[$38.11.0] INTO PROVINCIA FROM DUMMY;






-- ******************************************************************************

DECLARE CODEPROVINCIA VARCHAR(10);

BEGIN
    SELECT $[$38.11.0] INTO CODEPROVINCIA FROM DUMMY;

    IF (:CODEPROVINCIA) THEN
        SELECT T0."U_SYP_PROV", T0."U_SYP_DESCCANTON" FROM "@SYP_CANTON" T0 WHERE T0."U_SYP_PROV" = :CODEPROVINCIA 
    ELSE 
        SELECT T0."U_SYP_PROV", T0."U_SYP_DESCCANTON" FROM "@SYP_CANTON" T0 WHERE T0."U_SYP_PROV" = '24' 
    END IF;

END;


    SELECT T0."U_SYP_PROV", T0."U_SYP_DESCCANTON" FROM "@SYP_CANTON" T0 WHERE T0."U_SYP_PROV" = $[$38.11.0] 




-- OPRQ (solicitudes de pedido)
-- PRQ1 (linea de solicitud de pedido)
-- ODRF (borradores)
-- DRF1 (linea de borradores)



/* 
FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN OWDD A1 ON T0."DocEntry" = A1."DocEntry" AND A1."ObjType" = '22'
LEFT JOIN WDD1 A2 ON A1."WddCode" = A2."WddCode" AND A2."Status" = 'Y'
LEFT JOIN PRQ1 P1 ON T1."BaseEntry" = P1."DocEntry" AND T1."BaseLine" = P1."LineNum"
LEFT JOIN OPRQ P2 ON P1."DocEntry" = P2."DocEntry"
LEFT JOIN OUDP P3 ON P2."Department" = P3."Code"
--LEFT JOIN OSLP T2 ON T0."SlpCode" = T2."SlpCode"

LEFT JOIN PDN1 T3 ON T0."DocEntry" = T3."BaseEntry" AND T1."LineNum" = T3."BaseLine" ANd T3."BaseType" = '22'
LEFT JOIN OPDN T4 ON T3."DocEntry" = T4."DocEntry" 
LEFT JOIN OOCR T5 ON T1."OcrCode4" = T5."OcrCode"
LEFT JOIN OUSR T6 ON T0."UserSign" = "USERID"
LEFT JOIN OITM T7 ON T1."ItemCode" = T7."ItemCode"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO2" T8 ON T7."U_SYP_SUBGRUPO2" = T8."Code"

WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."U_SYP_TIPCOMPRA" = '01' AND T0."CANCELED" = 'N' --AND T0."DocNum" IN ('23001060')
--AND T4."CANCELED" = 'N'

 */

/* *********************************Se esta trabajando 18-03-2025****************************************** */


SELECT 
    T0."DocStatus",
    T0."DocNum" AS "Número PO",
    T0."DocDate" AS "Fecha PO",
    T0."CardCode" AS "Código Proveedor",
    T0."CardName" AS "Nombre Proveedor",
    T2."DocNum" AS "Número Factura",
    T2."DocDate" AS "Fecha Factura",
    SUM(T3."Quantity" * T3."Price") AS "Total Antes de Descuento"
FROM 
    OPOR T0 

INNER JOIN OPDN T1 
    ON T0."DocEntry" = T1."BaseEntry" 
    AND T1."BaseType" = 22  -- 22 = Tipo base para Órdenes de Compra

INNER JOIN OPCH T2 
    ON T1."DocEntry" = T2."BaseEntry" 
    AND T2."BaseType" = 20  -- 20 = Tipo base para Entrada de Mercancía

INNER JOIN PCH1 T3 
    ON T2."DocEntry" = T3."DocEntry"
WHERE 
    T0."DocDate" >= '2024-01-01'
    AND T0."DocNum" = '24000136'
GROUP BY 
    T0."DocStatus",
    T0."DocNum",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T2."DocNum",
    T2."DocDate"
ORDER BY T0."DocDate";


/* asi esta quedando */
SELECT 
    --T0."DocStatus",
    T0."DocNum",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    

    /* T1."LineNum",
     T1."TrgetEntry",
     T1."BaseType",
     T1."BaseEntry",*/
     

    --T1."DocEntry", T2."BaseEntry"
    --T1.*

       --T1."DocEntry" , T2."BaseEntry"

      --T2.*
        --T2."BaseType",

       --T3.*
       T4.*
     


    --T2."DocNum" AS "Número Factura",
    --T2."DocDate" AS "Fecha Factura",
    --SUM(T3."Quantity" * T3."Price") AS "Total Antes de Descuento"
FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PDN1 T2 ON  T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'
LEFT JOIN OPDN T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN PCH1 T4 ON T3."DocEntry" = T4."BaseEntry" AND T1."LineNum" = T4."BaseLine" AND T4."BaseType" = '20'  -- 20 = Tipo base para Entrada de Mercancía 

    --AND T1."BaseType" = 22  -- 22 = Tipo base para Órdenes de Compra

/*INNER JOIN OPCH T2 ON T1."DocEntry" = T2."BaseEntry" 
    --AND T2."BaseType" = 20  -- 20 = Tipo base para Entrada de Mercancía

INNER JOIN PCH1 T3 ON T2."DocEntry" = T3."DocEntry"*/
WHERE 
    T0."DocDate" >= '2024-01-01'
    AND T0."DocNum" = '24000136'
/*GROUP BY 
    T0."DocStatus",
    T0."DocNum",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    --T2."DocNum",
    --T2."DocDate"*/
ORDER BY T0."DocDate";






-- BF - RECUPERA NOMBRE SN 
SELECT T0."CardName"  FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
WHERE T1."ItemCode" =  $[$38.1.0]  -- ITEM Y VARIABLE
--GROUP BY T0."DocDate", T0."DocNum"
Order BY T0."DocDate" Desc
Limit 1


-- ******************************************************************************
SELECT 
   
    
    SUM(T4."Quantity" * T4."Price") AS "Total Antes de Descuento"--,
    --T5."BaseAmnt"
   
FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PDN1 T2 ON  T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'  -- 22 = Tipo base para Órdenes de Compra
LEFT JOIN OPDN T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN PCH1 T4 ON T3."DocEntry" = T4."BaseEntry" AND T1."LineNum" = T4."BaseLine" AND T4."BaseType" = '20'  -- 20 = Tipo base para Entrada de Mercancía
LEFT JOIN OPCH T5 ON T4."DocEntry" = T5."DocEntry" 
WHERE 
    T0."DocDate" >= '2024-01-01'
    AND T0."DocNum" = '24000136';