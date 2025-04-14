/* Original */
SELECT
T0."DocNum",
T0."NumAtCard",
T0."CardCode",
T0."CardName",
T0."DocDate",
T2."DocNum",
T2."DocDate",
T2."Comments",
T2."TrsfrSum"

FROM OINV T0
LEFT JOIN RCT2 T1 ON T1."DocEntry" = T0."DocEntry"
LEFT JOIN ORCT T2 ON T2."DocEntry" = T1."DocNum"

WHERE T0."DocDate" BETWEEN [%0] AND [%1]

/* Modificando */

SELECT
    T0."DocNum",
    T0."NumAtCard",
    T0."CardCode",
    T0."CardName",
    T0."DocDate",
    SUM(T1."LineTotal") AS "Subtotal",
    SUM(T1."VatSum") AS "IVA",
    T2."DocNum" AS "ReciboNum",
    T2."DocDate" AS "ReciboFecha",
    T2."Comments",
    T2."TrsfrSum",
    T3."U_SYP_REGIMEN_APP"
   
FROM OINV T0
LEFT JOIN INV1 T1 ON T1."DocEntry" = T0."DocEntry"
LEFT JOIN RCT2 T4 ON T4."DocEntry" = T0."DocEntry"
LEFT JOIN ORCT T2 ON T2."DocEntry" = T4."DocNum"
INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
WHERE 
    T0."DocNum" = '25000977'
GROUP BY
    T0."DocNum",
    T0."NumAtCard",
    T0."CardCode",
    T0."CardName",
    T0."DocDate",
    T2."DocNum",
    T2."DocDate",
    T2."Comments",
    T2."TrsfrSum",
    T3."U_SYP_REGIMEN_APP"



    -- *********************************** BAN-BF-ORCT Consulta de Tipos de Operacion*********************************************
SELECT T0."Code",T0."U_SYP_DESCR", T0."U_SYP_CUENTA" FROM "@SYP_TOPER"  T0  where T0."U_SYP_TIPO" NOT IN ('C')