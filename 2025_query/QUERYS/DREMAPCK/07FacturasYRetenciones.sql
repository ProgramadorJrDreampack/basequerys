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



-- ***********************************************************************

SELECT
    T0."DocEntry",
    T0."DocNum",
    T0."NumAtCard",
    T0."CardCode",
    T0."CardName",
    T0."DocDate",
    SUM(T1."LineTotal") AS "Subtotal",
    SUM(T1."VatSum") AS "IVA",
    T1."AcctCode",
    T2."DocNum" AS "ReciboNum",
    T2."DocDate" AS "ReciboFecha",
    T2."Comments",
    T2."TrsfrSum",
    T3."U_SYP_REGIMEN_APP",
    T5."Code",
    T5."U_SYP_DESCR",
    T5."U_SYP_CUENTA"
   
FROM OINV T0
LEFT JOIN INV1 T1 ON T1."DocEntry" = T0."DocEntry"
LEFT JOIN RCT2 T4 ON T4."DocEntry" = T0."DocEntry"
LEFT JOIN ORCT T2 ON T2."DocEntry" = T4."DocNum"
INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
INNER JOIN "@SYP_TOPER" T5 ON T2."U_SYP_TIPOOPERACION" = T5."Code"
WHERE 
    T0."DocNum" = '25000977'
GROUP BY
    T0."DocEntry",
    T0."DocNum",
    T0."NumAtCard",
    T0."CardCode",
    T0."CardName",
    T0."DocDate",
    T2."DocNum",
    T2."DocDate",
    T2."Comments",
    T2."TrsfrSum",
    T3."U_SYP_REGIMEN_APP",
    T1."AcctCode",
    T5."Code",T5."U_SYP_DESCR",
    T5."U_SYP_CUENTA"


    -- ***************************************************************************
-- ASI QUEDO
SELECT
    T0."DocEntry",
    T0."DocNum",
    T0."NumAtCard",
    T0."CardCode",
    T0."CardName",
    T0."DocDate",
    SUM(T1."LineTotal") AS "Subtotal",
    SUM(T1."VatSum") AS "IVA",
    T1."AcctCode",
    T2."DocNum" AS "ReciboNum",
    T2."DocDate" AS "ReciboFecha",
    T2."Comments",
    T2."TrsfrSum",
    T3."U_SYP_REGIMEN_APP",
    T8."Code",
    T8."U_SYP_DESCR",
    T8."U_SYP_CUENTA",

    -- Retenciones por porcentaje (con subconsultas)
    (SELECT SUM(T1_sub."LineTotal" * 0.01) 
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-601') AS "Retencion_1%",

    (SELECT SUM(T1_sub."LineTotal" * 0.02)
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-602') AS "Retencion_2%",

    (SELECT SUM(T1_sub."LineTotal" * 0.0175)
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-616') AS "Retencion_1_75%",

    (SELECT SUM(T1_sub."LineTotal" * 0.0275)
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-617') AS "Retencion_2_75%",


     -- Retenciones de IVA (con subconsultas)
    (SELECT SUM(T1_sub."VatSum" * 0.10)
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-610') AS "Retencion_IVA_10%",

    (SELECT SUM(T1_sub."VatSum" * 0.20)
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-611') AS "Retencion_IVA_20%",

    (SELECT SUM(T1_sub."VatSum" * 0.30)
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-612') AS "Retencion_IVA_30%",

    (SELECT SUM(T1_sub."VatSum" * 0.70)
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-614') AS "Retencion_IVA_70%",

    (SELECT SUM(T1_sub."VatSum" * 1.00)
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-615') AS "Retencion_IVA_100%"

FROM OINV T0
LEFT JOIN INV1 T1 ON T1."DocEntry" = T0."DocEntry"
LEFT JOIN RCT2 T4 ON T4."DocEntry" = T0."DocEntry"
LEFT JOIN ORCT T2 ON T2."DocEntry" = T4."DocNum"
INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
INNER JOIN "@SYP_TOPER" T8 ON T2."U_SYP_TIPOOPERACION" = T8."Code"
WHERE
      T0."DocDate" BETWEEN [%0] AND [%1] 
    --T0."DocNum" = '25000977'
GROUP BY
    T0."DocEntry",
    T0."DocNum",
    T0."NumAtCard",
    T0."CardCode",
    T0."CardName",
    T0."DocDate",
    T1."AcctCode",
    T2."DocNum",
    T2."DocDate",
    T2."Comments",
    T2."TrsfrSum",
    T3."U_SYP_REGIMEN_APP",
    T8."Code",
    T8."U_SYP_DESCR",
    T8."U_SYP_CUENTA"

    -- *******************************************************************
    -- Otra forma
SELECT
    T0."DocEntry",
    T0."DocNum",
    T0."NumAtCard",
    T0."CardCode",
    T0."CardName",
    T0."DocDate",
    SUM(T1."LineTotal") AS "Subtotal",
    SUM(T1."VatSum") AS "IVA",
    T1."AcctCode",
    T2."DocNum" AS "ReciboNum",
    T2."DocDate" AS "ReciboFecha",
    T2."Comments",
    T2."TrsfrSum",
    T3."U_SYP_REGIMEN_APP",
    T8."Code",
    T8."U_SYP_DESCR",
    T8."U_SYP_CUENTA",

    -- Retenciones por porcentaje (con subconsultas)
    (SELECT SUM(T1_sub."LineTotal" * (T5_sub."U_SYP_PORCN_RET" / 100)) --0.01
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-601') AS "Retencion_1%",

    (SELECT SUM(T1_sub."LineTotal" * (T5_sub."U_SYP_PORCN_RET" / 100)) --0.02
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-602') AS "Retencion_2%",

    (SELECT SUM(T1_sub."LineTotal" * (T5_sub."U_SYP_PORCN_RET" / 100)) --0.0175
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-616') AS "Retencion_1_75%",

    (SELECT SUM(T1_sub."LineTotal" *  (T5_sub."U_SYP_PORCN_RET" / 100)) --0.0275
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-617') AS "Retencion_2_75%",


     -- Retenciones de IVA (con subconsultas)
    (SELECT SUM(T1_sub."VatSum" * (T5_sub."U_SYP_PORCN_RET" / 100)) --0.10
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-610') AS "Retencion_IVA_10%",

    (SELECT SUM(T1_sub."VatSum" * (T5_sub."U_SYP_PORCN_RET" / 100)) --0.20
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-611') AS "Retencion_IVA_20%",

    (SELECT SUM(T1_sub."VatSum" * (T5_sub."U_SYP_PORCN_RET" / 100)) --0.30
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-612') AS "Retencion_IVA_30%",

    (SELECT SUM(T1_sub."VatSum" * (T5_sub."U_SYP_PORCN_RET" / 100)) --0.70
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-614') AS "Retencion_IVA_70%",

    (SELECT SUM(T1_sub."VatSum" * (T5_sub."U_SYP_PORCN_RET" / 100)) --1.00
     FROM INV1 T1_sub
     INNER JOIN "@SYP_TOPER" T5_sub ON T2."U_SYP_TIPOOPERACION" = T5_sub."Code"
     WHERE T1_sub."DocEntry" = T0."DocEntry" AND T5_sub."Code" = 'C-615') AS "Retencion_IVA_100%"

FROM OINV T0
LEFT JOIN INV1 T1 ON T1."DocEntry" = T0."DocEntry"
LEFT JOIN RCT2 T4 ON T4."DocEntry" = T0."DocEntry"
LEFT JOIN ORCT T2 ON T2."DocEntry" = T4."DocNum"
INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
INNER JOIN "@SYP_TOPER" T8 ON T2."U_SYP_TIPOOPERACION" = T8."Code"
WHERE
    T0."DocDate" BETWEEN [%0] AND [%1]
    --T0."DocNum" = '25000977'
GROUP BY
    T0."DocEntry",
    T0."DocNum",
    T0."NumAtCard",
    T0."CardCode",
    T0."CardName",
    T0."DocDate",
    T1."AcctCode",
    T2."DocNum",
    T2."DocDate",
    T2."Comments",
    T2."TrsfrSum",
    T3."U_SYP_REGIMEN_APP",
    T8."Code",
    T8."U_SYP_DESCR",
    T8."U_SYP_CUENTA"