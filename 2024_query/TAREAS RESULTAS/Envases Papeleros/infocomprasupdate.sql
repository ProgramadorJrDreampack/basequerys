 /* 

 EPM Contabilidad - Info compra 
 tarea sumatoria total  
 
 */


 /* original */

 SELECT
    'COMPRA' AS "Tipo",
    T2."Series" AS "Serie",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."ItemCode",
    T1."Dscription",
    T1."Quantity" AS "CANTIDAD",
    T1."Currency",
    --T1."DiscPrcnt",
    T1."LineTotal" As "Subtotal MXN",
    T1."VatSum"  AS "IVA MXN",
    (T1."LineTotal" + T1."VatSum") AS "Total MXN",
    T1."TotalSumSy" AS "Subtotal USD",
    T1."VatSumSy" AS "IVA USD",
    (T1."TotalSumSy" + T1."VatSumSy") AS "Total USD",
    T1."AcctCode" AS "Cuenta Mayor"
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'

UNION ALL

SELECT
    'NC COMPRA' AS "Tipo",
     T2."Series" AS "Serie o Num Factura",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."ItemCode",
    T1."Dscription", 
    (T1."Quantity" * -1) AS "CANTIDAD",
    T1."Currency",
    --T1."DiscPrcnt",
    (T1."LineTotal" * -1) As "Subtotal MXN",
    (T1."VatSum" * -1)  AS "IVA MXN",
    ((T1."LineTotal" + T1."VatSum") * -1) AS "Total MXN",
    (T1."TotalSumSy" * -1) AS "Subtotal USD",
    (T1."VatSumSy" * -1) AS "IVA USD",
    ((T1."TotalSumSy" + T1."VatSumSy") * -1) AS "Total USD",
    T1."AcctCode" AS "Cuenta Mayor"
FROM ORPC T0
INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'

/* Fin Original */

/* actualizado */
INFO COMPRAS SUMATORIAS JULIO 
/*  POR CONFIRMAR LA ACTUALIZACION DE INFO COMPRAS  - EPM  */

SELECT 
    'COMPRA' AS "Tipo",
    T2."Series" AS "Serie",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."ItemCode",
    T1."Currency",
    SUM(T1."LineTotal") As "Subtotal MXN Total",
    SUM(T1."VatSum")  AS "IVA MXN Total",
    SUM(T1."LineTotal" + T1."VatSum") AS "Total MXN Total",
    SUM(T1."TotalSumSy") AS "Subtotal USD Total",
    SUM(T1."VatSumSy") AS "IVA USD Total",
    SUM(T1."TotalSumSy" + T1."VatSumSy") AS "Total USD Total"
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'
GROUP BY T0."DocEntry", T2."Series", T0."DocNum", T0."DocDate", T0."CardCode", T0."CardName", T1."Currency",  T1."ItemCode"

UNION ALL

SELECT
    'NC COMPRA' AS "Tipo",
     T2."Series" AS "Serie o Num Factura",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."ItemCode",
    T1."Currency",
    SUM((T1."LineTotal" * -1)) As "Subtotal MXN Total",
    SUM((T1."VatSum" * -1))  AS "IVA MXN Total",
    SUM(((T1."LineTotal" + T1."VatSum") * -1)) AS "Total MXN Total",
    SUM((T1."TotalSumSy" * -1)) AS "Subtotal USD Total",
    SUM((T1."VatSumSy" * -1)) AS "IVA USD Total",
    SUM(((T1."TotalSumSy" + T1."VatSumSy") * -1)) AS "Total USD Total"
FROM ORPC T0
INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'
GROUP BY T0."DocEntry", T2."Series", T0."DocNum", T0."DocDate", T0."CardCode", T0."CardName", T1."Currency",  T1."ItemCode"

/* Fin Actualizado */




/* quitar INFO COMPRAS*/

SELECT
    'COMPRA' AS "Tipo",
    T2."Series" AS "Serie",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."ItemCode",
    T1."Dscription",
    T1."Quantity" AS "CANTIDAD",
    T1."Currency",
    --T1."DiscPrcnt",
    T1."LineTotal" As "Subtotal MXN",
    T1."VatSum"  AS "IVA MXN",
    (T1."LineTotal" + T1."VatSum") AS "Total MXN",
    T1."TotalSumSy" AS "Subtotal USD",
    T1."VatSumSy" AS "IVA USD",
    (T1."TotalSumSy" + T1."VatSumSy") AS "Total USD",
    T1."AcctCode" AS "Cuenta Mayor"
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'

UNION ALL

SELECT
    'NC COMPRA' AS "Tipo",
     T2."Series" AS "Serie o Num Factura",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."ItemCode",
    T1."Dscription", 
    (T1."Quantity" * -1) AS "CANTIDAD",
    T1."Currency",
    --T1."DiscPrcnt",
    (T1."LineTotal" * -1) As "Subtotal MXN",
    (T1."VatSum" * -1)  AS "IVA MXN",
    ((T1."LineTotal" + T1."VatSum") * -1) AS "Total MXN",
    (T1."TotalSumSy" * -1) AS "Subtotal USD",
    (T1."VatSumSy" * -1) AS "IVA USD",
    ((T1."TotalSumSy" + T1."VatSumSy") * -1) AS "Total USD",
    T1."AcctCode" AS "Cuenta Mayor"
FROM ORPC T0
INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'

/* actualizar asi quedo Info Base Compra */  Cuenta del mayor add


SELECT 
    'COMPRA' AS "Tipo",
    T2."Series" AS "Serie",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    SUM(T1."LineTotal") As "Subtotal MXN Total",
    SUM(T1."VatSum")  AS "IVA MXN Total",
    SUM(T1."LineTotal" + T1."VatSum") AS "Total MXN Total",
    SUM(T1."TotalSumSy") AS "Subtotal USD Total",
    SUM(T1."VatSumSy") AS "IVA USD Total",
    SUM(T1."TotalSumSy" + T1."VatSumSy") AS "Total USD Total"
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'
GROUP BY  T0."DocNum", T2."Series", T0."DocEntry", T0."DocDate", T0."CardCode", T0."CardName", T1."Currency"

UNION ALL

SELECT
    'NC COMPRA' AS "Tipo",
     T2."Series" AS "Serie o Num Factura",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    SUM((T1."LineTotal" * -1)) As "Subtotal MXN Total",
    SUM((T1."VatSum" * -1))  AS "IVA MXN Total",
    SUM(((T1."LineTotal" + T1."VatSum") * -1)) AS "Total MXN Total",
    SUM((T1."TotalSumSy" * -1)) AS "Subtotal USD Total",
    SUM((T1."VatSumSy" * -1)) AS "IVA USD Total",
    SUM(((T1."TotalSumSy" + T1."VatSumSy") * -1)) AS "Total USD Total"
FROM ORPC T0
INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'
GROUP BY T0."DocNum", T2."Series", T0."DocEntry", T0."DocDate", T0."CardCode", T0."CardName", T1."Currency"




/* 
  EPM - CONTABILIDAD

  INFO COMPRAS - ELIMINAR


SELECT
    'COMPRA' AS "Tipo",
    T2."Series" AS "Serie",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."ItemCode",
    T1."Dscription",
    T1."Quantity" AS "CANTIDAD",
    T1."Currency",
    --T1."DiscPrcnt",
    T1."LineTotal" As "Subtotal MXN",
    T1."VatSum"  AS "IVA MXN",
    (T1."LineTotal" + T1."VatSum") AS "Total MXN",
    T1."TotalSumSy" AS "Subtotal USD",
    T1."VatSumSy" AS "IVA USD",
    (T1."TotalSumSy" + T1."VatSumSy") AS "Total USD",
    T1."AcctCode" AS "Cuenta Mayor"
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'

UNION ALL

SELECT
    'NC COMPRA' AS "Tipo",
     T2."Series" AS "Serie o Num Factura",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."ItemCode",
    T1."Dscription", 
    (T1."Quantity" * -1) AS "CANTIDAD",
    T1."Currency",
    --T1."DiscPrcnt",
    (T1."LineTotal" * -1) As "Subtotal MXN",
    (T1."VatSum" * -1)  AS "IVA MXN",
    ((T1."LineTotal" + T1."VatSum") * -1) AS "Total MXN",
    (T1."TotalSumSy" * -1) AS "Subtotal USD",
    (T1."VatSumSy" * -1) AS "IVA USD",
    ((T1."TotalSumSy" + T1."VatSumSy") * -1) AS "Total USD",
    T1."AcctCode" AS "Cuenta Mayor"
FROM ORPC T0
INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'

*/


/* 
   INFO COBROS COMPRA - ELIMINAR

   SELECT
    CASE
        WHEN T1."InvType" IN ('18', '46') THEN 'Novedad'
        ELSE NULL
    END AS "Novedades",
    T0."DocNum" AS "# de documento de cobro",
    T0."DocDate" AS "Fecha cobro",
    CASE
        WHEN T1."InvType" = '13' THEN A1."DocNum"
        ELSE NULL
    END AS "# de Factura aplicada",
    CASE
        WHEN T0."TrsfrAcct" IS NOT NULL THEN B1."AcctName"
        ELSE B2."AcctName"
    END AS "Banco",
    CASE
        WHEN T1."DocNum" IS NULL AND T4."DocNum" IS NULL THEN T0."DocTotal"
        WHEN T0."DocType" = 'A' THEN T4."SumApplied"
        ELSE (
            CASE
                WHEN T1."InvType" = '18' THEN (-1 * T1."SumApplied")
                ELSE T1."SumApplied"
            END
        )
    END AS "Valor Cobrado MXN",
    CASE
        WHEN T1."DocNum" IS NULL AND T4."DocNum" IS NULL THEN T0."DocTotalSy"
        WHEN T0."DocType" = 'A' THEN T4."AppliedSys"
        ELSE (
            CASE
                WHEN T1."InvType" = '18' THEN (-1 * T1."AppliedSys")
                ELSE T1."AppliedSys"
            END
        )
    END AS "Valor Cobrado USD",
    CASE
        WHEN T0."TrsfrAcct" IS NOT NULL THEN 'Transferencia'
        WHEN T0."CashAcct" IS NOT NULL THEN 'Efectivo'
        WHEN T0."CheckAcct" IS NOT NULL THEN 'Cheque'
        ELSE 'Tarjeta de Credito'
    END AS "Metodo de pago"

FROM ORCT T0
LEFT JOIN RCT2 T1 ON T0."DocEntry" = T1."DocNum"
LEFT JOIN OINV A1 ON A1."DocEntry" = T1."baseAbs"
LEFT JOIN RCT4 T4 ON T0."DocEntry" = T4."DocNum" AND T0."DocType" = 'A' -- TIPO A
LEFT JOIN OACT B1 ON T0."TrsfrAcct" = B1."AcctCode"
LEFT JOIN OACT B2 ON T0."CashAcct" = B2."AcctCode"

WHERE T0."DocDate" BETWEEN [%0] AND [%1] --T0."DocNum" = '24005170'
AND T0."Canceled" = 'N'
ORDER BY T0."DocDate"

 */


 /* 
   INFO PAGOS - PREGUNTAR SI SE BORRA
   SELECT
T0."DocEntry",
T0."DocNum",
T0."DocDate",
T0."CardCode",
T0."CardName",
T1."ItemCode",
T1."Dscription",
T1."Quantity" AS "CANTIDAD",
T1."AcctCode",
T1."Currency",
/*T1."DiscPrcnt",
T1."LineTotal" As "Subtotal MXN",
T1."VatSum"  AS "IVA MXN",*/
(T1."LineTotal" + T1."VatSum") AS "Total MXN",
/*T1."TotalSumSy" AS "Subtotal USD",
T1."VatSumSy" AS "IVA USD",*/
(T1."TotalSumSy" + T1."VatSumSy") AS "Total USD"
,T1."LineTotal" AS "Total Linea MXN", 
--T1."OpenSum", 
T1."TotalSumSy" AS "Total Linea USD"

FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 

WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'

ORDER BY T0."DocDate"

  */



/* 
  EPM - CONTABILIDAD
INFO BASE COMPRAS - BIEN
INFO COBROS - BIEN
INFO COBROS COMPRA - ELIMINAR
INFO COMPRAS - ELIMINAR
INFO PAGOS -
INFO PAGOS COMPRA - BIEN
INFO VENTAS - BIEN

*/