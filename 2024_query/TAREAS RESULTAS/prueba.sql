WITH CTE AS (
    SELECT 
        T0."DocEntry",
        T0."WTSum",
        T0."DocDate",
        T2."WTCode",
        T2."Rate",
        T2."TaxbleAmnt",
        T2."TxblAmntSC",
        T2."WTAmnt",
        ROW_NUMBER() OVER (PARTITION BY T0."DocEntry" ORDER BY T2."WTCode") AS RowNum
    FROM 
        OPCH T0
    INNER JOIN 
        PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
    LEFT JOIN 
        PCH5 T2 ON T0."DocEntry" = T2."AbsEntry"
    WHERE 
        T0."DocDate" BETWEEN [%0] AND [%1]
        AND T0."CANCELED" = 'N'
)
SELECT 
    'COMPRA' AS "Tipo",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    SUM(T1."LineTotal") AS "Subtotal MXN Total",
    SUM(T1."VatSum") AS "IVA MXN Total",
    SUM(T1."LineTotal" + T1."VatSum") AS "Total MXN Total",
    SUM(T1."TotalSumSy") AS "Subtotal USD Total",
    SUM(T1."VatSumSy") AS "IVA USD Total",
    SUM(T1."TotalSumSy" + T1."VatSumSy") AS "Total USD Total",
    T1."AcctCode" AS "Cuenta Mayor",
    T0."WTSum",
    MAX(CASE WHEN CTE.RowNum = 1 THEN CTE."WTCode" END) AS "WTCode1",
    MAX(CASE WHEN CTE.RowNum = 1 THEN CTE."Rate" END) AS "Rate1",
    MAX(CASE WHEN CTE.RowNum = 1 THEN CTE."TaxbleAmnt" END) AS "TaxbleAmnt1",
    MAX(CASE WHEN CTE.RowNum = 1 THEN CTE."TxblAmntSC" END) AS "TxblAmntSC1",
    MAX(CASE WHEN CTE.RowNum = 1 THEN CTE."WTAmnt" END) AS "WTAmnt1",
    MAX(CASE WHEN CTE.RowNum = 2 THEN CTE."WTCode" END) AS "WTCode2",
    MAX(CASE WHEN CTE.RowNum = 2 THEN CTE."Rate" END) AS "Rate2",
    MAX(CASE WHEN CTE.RowNum = 2 THEN CTE."TaxbleAmnt" END) AS "TaxbleAmnt2",
    MAX(CASE WHEN CTE.RowNum = 2 THEN CTE."TxblAmntSC" END) AS "TxblAmntSC2",
    MAX(CASE WHEN CTE.RowNum = 2 THEN CTE."WTAmnt" END) AS "WTAmnt2"
FROM 
    OPCH T0  
INNER JOIN 
    PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN 
    CTE ON T0."DocEntry" = CTE."DocEntry"
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
    AND T0."CANCELED" = 'N'
GROUP BY 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."CardCode", 
    T0."CardName", 
    T1."Currency", 
    T1."AcctCode", 
    T0."WTSum"
ORDER BY 
    T0."DocEntry", 
    T0."WTSum", 
    T0."DocDate"


/*  */

WITH CTE AS (
    SELECT 
        T0."DocEntry",
        T0."WTSum",
        T0."DocDate",
        T2."WTCode",
        T2."Rate",
        T2."TaxbleAmnt",
        T2."TxblAmntSC",
        T2."WTAmnt",
        ROW_NUMBER() OVER (PARTITION BY T0."DocEntry" ORDER BY T2."WTCode") AS RowNum
    FROM 
        ORPC T0
    INNER JOIN 
        RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
    LEFT JOIN 
        RPC5 T2 ON T0."DocEntry" = T2."AbsEntry"
    WHERE 
        T0."DocDate" BETWEEN [%0] AND [%1]
        AND T0."CANCELED" = 'N'
)
SELECT 
    'NC COMPRA' AS "Tipo",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    SUM((T1."LineTotal" * -1)) AS "Subtotal MXN Total",
    SUM((T1."VatSum" * -1)) AS "IVA MXN Total",
    SUM(((T1."LineTotal" + T1."VatSum") * -1)) AS "Total MXN Total",
    SUM((T1."TotalSumSy" * -1)) AS "Subtotal USD Total",
    SUM((T1."VatSumSy" * -1)) AS "IVA USD Total",
    SUM(((T1."TotalSumSy" + T1."VatSumSy") * -1)) AS "Total USD Total",
    T1."AcctCode" AS "Cuenta Mayor",
    T0."WTSum",
    MAX(CASE WHEN CTE.RowNum = 1 THEN CTE."WTCode" END) AS "WTCode1",
    MAX(CASE WHEN CTE.RowNum = 1 THEN CTE."Rate" END) AS "Rate1",
    MAX(CASE WHEN CTE.RowNum = 1 THEN CTE."TaxbleAmnt" END) AS "TaxbleAmnt1",
    MAX(CASE WHEN CTE.RowNum = 1 THEN CTE."TxblAmntSC" END) AS "TxblAmntSC1",
    MAX(CASE WHEN CTE.RowNum = 1 THEN CTE."WTAmnt" END) AS "WTAmnt1",
    MAX(CASE WHEN CTE.RowNum = 2 THEN CTE."WTCode" END) AS "WTCode2",
    MAX(CASE WHEN CTE.RowNum = 2 THEN CTE."Rate" END) AS "Rate2",
    MAX(CASE WHEN CTE.RowNum = 2 THEN CTE."TaxbleAmnt" END) AS "TaxbleAmnt2",
    MAX(CASE WHEN CTE.RowNum = 2 THEN CTE."TxblAmntSC" END) AS "TxblAmntSC2",
    MAX(CASE WHEN CTE.RowNum = 2 THEN CTE."WTAmnt" END) AS "WTAmnt2"
FROM 
    ORPC T0  
INNER JOIN 
    RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN 
    CTE ON T0."DocEntry" = CTE."DocEntry"
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
    AND T0."CANCELED" = 'N'
GROUP BY 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."CardCode", 
    T0."CardName", 
    T1."Currency", 
    T1."AcctCode", 
    T0."WTSum"


/* EJEMPLO */

SELECT
  T0."DocEntry",
  T0."WTSum",
  T0."DocDate",
  T2."WTCode",
  T2."Rate",
  T2."TaxbleAmnt",
  T2."TxblAmntSC",
  T2."WTAmnt",
  T2."WTAmntSC",
  T2."Category"
  --T2.*
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PCH5 T2 ON T0."DocEntry" = T2."AbsEntry"
WHERE 
  T0."DocDate" BETWEEN [%0] AND [%1]
  AND T0."CANCELED" = 'N';


/*POR REVISAR INFO BASE COMPRA MAS RETENCIONES */
WITH CTE_COMPRA AS (
    SELECT 
        T0."DocEntry",
        T0."WTSum",
        T0."DocDate",
        T2."WTCode",
        T2."Rate",
        T2."TaxbleAmnt",
        T2."TxblAmntSC",
        T2."WTAmnt",
        ROW_NUMBER() OVER (PARTITION BY T0."DocEntry" ORDER BY T2."WTCode") AS RowNum
    FROM 
        OPCH T0
    INNER JOIN 
        PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
    LEFT JOIN 
        PCH5 T2 ON T0."DocEntry" = T2."AbsEntry"
    WHERE 
        T0."DocDate" BETWEEN [%0] AND [%1]
        AND T0."CANCELED" = 'N'
),
CTE_NC_COMPRA AS (
    SELECT 
        T0."DocEntry",
        T0."WTSum",
        T0."DocDate",
        T2."WTCode",
        T2."Rate",
        T2."TaxbleAmnt",
        T2."TxblAmntSC",
        T2."WTAmnt",
        ROW_NUMBER() OVER (PARTITION BY T0."DocEntry" ORDER BY T2."WTCode") AS RowNum
    FROM 
        ORPC T0
    INNER JOIN 
        RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
    LEFT JOIN 
        RPC5 T2 ON T0."DocEntry" = T2."AbsEntry"
    WHERE 
        T0."DocDate" BETWEEN [%0] AND [%1]
        AND T0."CANCELED" = 'N'
)
SELECT 
    'COMPRA' AS "Tipo",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    T1."LineTotal" AS "Subtotal MXN Total",
    T1."VatSum" AS "IVA MXN Total",
    T1."LineTotal" + T1."VatSum" AS "Total MXN Total",
    T1."TotalSumSy" AS "Subtotal USD Total",
    T1."VatSumSy" AS "IVA USD Total",
    T1."TotalSumSy" + T1."VatSumSy" AS "Total USD Total",
    -- SUM(T1."LineTotal") AS "Subtotal MXN Total",
    -- SUM(T1."VatSum") AS "IVA MXN Total",
    -- SUM(T1."LineTotal" + T1."VatSum") AS "Total MXN Total",
    -- SUM(T1."TotalSumSy") AS "Subtotal USD Total",
    -- SUM(T1."VatSumSy") AS "IVA USD Total",
    -- SUM(T1."TotalSumSy" + T1."VatSumSy") AS "Total USD Total",
    T1."AcctCode" AS "Cuenta Mayor",
    T0."WTSum",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 1 THEN CTE_COMPRA."WTCode" END) AS "Código de retención 1",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 1 THEN CTE_COMPRA."Rate" END) AS "Tasa 1",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 1 THEN CTE_COMPRA."TaxbleAmnt" END) AS "Importe sujeto a impuestos 1",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 1 THEN CTE_COMPRA."TxblAmntSC" END) AS "Importe sujeto a impuestos en MS 1",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 1 THEN CTE_COMPRA."WTAmnt" END) AS "Importe de retención de impuestos 1",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 2 THEN CTE_COMPRA."WTCode" END) AS "Código de retención 2",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 2 THEN CTE_COMPRA."Rate" END) AS "Tasa 2",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 2 THEN CTE_COMPRA."TaxbleAmnt" END) AS "Importe sujeto a impuestos 2",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 2 THEN CTE_COMPRA."TxblAmntSC" END) AS "Importe sujeto a impuestos en MS 2",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 2 THEN CTE_COMPRA."WTAmnt" END) AS "Importe de retención de impuestos 2"
FROM 
    OPCH T0  
INNER JOIN 
    PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN 
    CTE_COMPRA ON T0."DocEntry" = CTE_COMPRA."DocEntry"
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
    AND T0."CANCELED" = 'N'
GROUP BY 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."CardCode", 
    T0."CardName", 
    T1."Currency", 
    T1."AcctCode", 
    T0."WTSum"

UNION ALL

SELECT 
    'NC COMPRA' AS "Tipo",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    (T1."LineTotal" * -1) AS "Subtotal MXN Total",
    (T1."VatSum" * -1) AS "IVA MXN Total",
    ((T1."LineTotal" + T1."VatSum") * -1) AS "Total MXN Total",
    (T1."TotalSumSy" * -1) AS "Subtotal USD Total",
    (T1."VatSumSy" * -1) AS "IVA USD Total",
    ((T1."TotalSumSy" + T1."VatSumSy") * -1) AS "Total USD Total",
    -- SUM((T1."LineTotal" * -1)) AS "Subtotal MXN Total",
    -- SUM((T1."VatSum" * -1)) AS "IVA MXN Total",
    -- SUM(((T1."LineTotal" + T1."VatSum") * -1)) AS "Total MXN Total",
    -- SUM((T1."TotalSumSy" * -1)) AS "Subtotal USD Total",
    -- SUM((T1."VatSumSy" * -1)) AS "IVA USD Total",
    -- SUM(((T1."TotalSumSy" + T1."VatSumSy") * -1)) AS "Total USD Total",
    T1."AcctCode" AS "Cuenta Mayor",
    T0."WTSum",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 1 THEN CTE_NC_COMPRA."WTCode" END) AS "Código de retención 1",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 1 THEN CTE_NC_COMPRA."Rate" END) AS "Tasa 1",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 1 THEN CTE_NC_COMPRA."TaxbleAmnt" END) AS "Importe sujeto a impuestos 1",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 1 THEN CTE_NC_COMPRA."TxblAmntSC" END) AS "Importe sujeto a impuestos en MS 1",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 1 THEN CTE_NC_COMPRA."WTAmnt" END) AS "Importe de retención de impuestos 1",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 2 THEN CTE_NC_COMPRA."WTCode" END) AS "Código de retención 2",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 2 THEN CTE_NC_COMPRA."Rate" END) AS "Tasa 2",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 2 THEN CTE_NC_COMPRA."TaxbleAmnt" END) AS "Importe sujeto a impuestos 2",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 2 THEN CTE_NC_COMPRA."TxblAmntSC" END) AS "Importe sujeto a impuestos en MS 2",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 2 THEN CTE_NC_COMPRA."WTAmnt" END) AS "Importe de retención de impuestos 2"
FROM 
    ORPC T0  
INNER JOIN 
    RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN 
    CTE_NC_COMPRA ON T0."DocEntry" = CTE_NC_COMPRA."DocEntry"
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
    AND T0."CANCELED" = 'N'
GROUP BY 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."CardCode", 
    T0."CardName", 
    T1."Currency", 
    T1."AcctCode", 
    T0."WTSum"

ORDER BY 
    "Tipo", 
    "DocEntry", 
    "DocDate"



/* revisando  */

SELECT 
    'COMPRA' AS "Tipo",
    T0."DocEntry", 
    T0."DocNum" AS "Num Factura", 
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    SUM(T1."LineTotal") AS "Subtotal MXN Total",
    SUM(T1."VatSum")  AS "IVA MXN Total",
    SUM(T1."LineTotal" + T1."VatSum") AS "Total MXN Total",
    SUM(T1."TotalSumSy") AS "Subtotal USD Total",
    SUM(T1."VatSumSy") AS "IVA USD Total",
    SUM(T1."TotalSumSy" + T1."VatSumSy") AS "Total USD Total"
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
    AND T0."CANCELED" = 'N'
GROUP BY 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."CardCode",
    T0."CardName", 
    T1."Currency"


/* ARREGLANDO  */

WITH CTE_COMPRA AS (
    SELECT 
        T0."DocEntry",
        T0."WTSum",
        T0."DocDate",
        T2."WTCode",
        T2."Rate",
        T2."TaxbleAmnt",
        T2."TxblAmntSC",
        T2."WTAmnt",
        ROW_NUMBER() OVER (PARTITION BY T0."DocEntry" ORDER BY T2."WTCode") AS RowNum
    FROM 
        OPCH T0
    INNER JOIN 
        PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
    LEFT JOIN 
        PCH5 T2 ON T0."DocEntry" = T2."AbsEntry"
    WHERE 
        T0."DocDate" BETWEEN [%0] AND [%1]
        AND T0."CANCELED" = 'N'
),
CTE_NC_COMPRA AS (
    SELECT 
        T0."DocEntry",
        T0."WTSum",
        T0."DocDate",
        T2."WTCode",
        T2."Rate",
        T2."TaxbleAmnt",
        T2."TxblAmntSC",
        T2."WTAmnt",
        ROW_NUMBER() OVER (PARTITION BY T0."DocEntry" ORDER BY T2."WTCode") AS RowNum
    FROM 
        ORPC T0
    INNER JOIN 
        RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
    LEFT JOIN 
        RPC5 T2 ON T0."DocEntry" = T2."AbsEntry"
    WHERE 
        T0."DocDate" BETWEEN [%0] AND [%1]
        AND T0."CANCELED" = 'N'
)
SELECT 
    'COMPRA' AS "Tipo",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    SUM(T1."LineTotal") AS "Subtotal MXN Total",
    SUM(T1."VatSum") AS "IVA MXN Total",
    SUM(T1."LineTotal" + T1."VatSum") AS "Total MXN Total",
    SUM(T1."TotalSumSy") AS "Subtotal USD Total",
    SUM(T1."VatSumSy") AS "IVA USD Total",
    SUM(T1."TotalSumSy" + T1."VatSumSy") AS "Total USD Total",
    --T1."AcctCode" AS "Cuenta Mayor",
    --T0."WTSum",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 1 THEN CTE_COMPRA."WTCode" END) AS "Código de retención 1",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 1 THEN CTE_COMPRA."Rate" END) AS "Tasa 1",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 1 THEN CTE_COMPRA."TaxbleAmnt" END) AS "Importe sujeto a impuestos 1",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 1 THEN CTE_COMPRA."TxblAmntSC" END) AS "Importe sujeto a impuestos en MS 1",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 1 THEN CTE_COMPRA."WTAmnt" END) AS "Importe de retención de impuestos 1",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 2 THEN CTE_COMPRA."WTCode" END) AS "Código de retención 2",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 2 THEN CTE_COMPRA."Rate" END) AS "Tasa 2",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 2 THEN CTE_COMPRA."TaxbleAmnt" END) AS "Importe sujeto a impuestos 2",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 2 THEN CTE_COMPRA."TxblAmntSC" END) AS "Importe sujeto a impuestos en MS 2",
    MAX(CASE WHEN CTE_COMPRA.RowNum = 2 THEN CTE_COMPRA."WTAmnt" END) AS "Importe de retención de impuestos 2"
FROM 
    OPCH T0  
INNER JOIN 
    PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN 
    CTE_COMPRA ON T0."DocEntry" = CTE_COMPRA."DocEntry"
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
    AND T0."CANCELED" = 'N'
GROUP BY 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."CardCode", 
    T0."CardName", 
    T1."Currency", 
    --T1."AcctCode", 
    --T0."WTSum"

UNION ALL

SELECT 
    'NC COMPRA' AS "Tipo",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    SUM(T1."LineTotal" * -1) AS "Subtotal MXN Total",
    SUM(T1."VatSum" * -1) AS "IVA MXN Total",
    SUM(((T1."LineTotal" + T1."VatSum") * -1)) AS "Total MXN Total",
    SUM((T1."TotalSumSy" * -1)) AS "Subtotal USD Total",
    SUM((T1."VatSumSy" * -1)) AS "IVA USD Total",
    SUM(((T1."TotalSumSy" + T1."VatSumSy") * -1)) AS "Total USD Total",
    --T1."AcctCode" AS "Cuenta Mayor",
    --T0."WTSum",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 1 THEN CTE_NC_COMPRA."WTCode" END) AS "Código de retención 1",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 1 THEN CTE_NC_COMPRA."Rate" END) AS "Tasa 1",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 1 THEN CTE_NC_COMPRA."TaxbleAmnt" END) AS "Importe sujeto a impuestos 1",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 1 THEN CTE_NC_COMPRA."TxblAmntSC" END) AS "Importe sujeto a impuestos en MS 1",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 1 THEN CTE_NC_COMPRA."WTAmnt" END) AS "Importe de retención de impuestos 1",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 2 THEN CTE_NC_COMPRA."WTCode" END) AS "Código de retención 2",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 2 THEN CTE_NC_COMPRA."Rate" END) AS "Tasa 2",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 2 THEN CTE_NC_COMPRA."TaxbleAmnt" END) AS "Importe sujeto a impuestos 2",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 2 THEN CTE_NC_COMPRA."TxblAmntSC" END) AS "Importe sujeto a impuestos en MS 2",
    MAX(CASE WHEN CTE_NC_COMPRA.RowNum = 2 THEN CTE_NC_COMPRA."WTAmnt" END) AS "Importe de retención de impuestos 2"
FROM 
    ORPC T0  
INNER JOIN 
    RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN 
    CTE_NC_COMPRA ON T0."DocEntry" = CTE_NC_COMPRA."DocEntry"
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
    AND T0."CANCELED" = 'N'
GROUP BY 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."CardCode", 
    T0."CardName", 
    T1."Currency", 
    --T1."AcctCode", 
    --T0."WTSum"

ORDER BY 
    "Tipo", 
    "DocEntry", 
    "DocDate"

ORDER BY 
    "Tipo" 
    --"DocEntry", 
    --"DocDate"


    /* casi */

    SELECT 
    'COMPRA' AS "Tipo",
    T0."DocEntry", 
    T0."DocNum" AS "Num Factura", 
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    SUM(T1."LineTotal") AS "Subtotal MXN Total",
    SUM(T1."VatSum") AS "IVA MXN Total",
    SUM(T1."LineTotal" + T1."VatSum") AS "Total MXN Total",
    SUM(T1."TotalSumSy") AS "Subtotal USD Total",
    SUM(T1."VatSumSy") AS "IVA USD Total",
    SUM(T1."TotalSumSy" + T1."VatSumSy") AS "Total USD Total",
    T2."WTCode",
    T2."Rate",
    SUM(T2."TaxbleAmnt") AS "TaxbleAmnt Total",
    SUM(T2."TxblAmntSC") AS "TxblAmntSC Total",
    SUM(T2."WTAmnt") AS "WTAmnt Total"
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 
LEFT JOIN PCH5 T2 ON T0."DocEntry" = T2."AbsEntry"
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
    AND T0."CANCELED" = 'N'
GROUP BY 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."CardCode",
    T0."CardName", 
    T1."Currency",
    T2."WTCode",
    T2."Rate"


    /* subconsulta */

    SELECT 
    'COMPRA' AS "Tipo",
    T0."DocEntry", 
    T0."DocNum" AS "Num Factura", 
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    SUM(T1."LineTotal") AS "Subtotal MXN Total",
    SUM(T1."VatSum") AS "IVA MXN Total",
    SUM(T1."LineTotal" + T1."VatSum") AS "Total MXN Total",
    SUM(T1."TotalSumSy") AS "Subtotal USD Total",
    SUM(T1."VatSumSy") AS "IVA USD Total",
    SUM(T1."TotalSumSy" + T1."VatSumSy") AS "Total USD Total",

    -- Subconsultas para obtener cada campo de retención
    (SELECT SUM(T2."TaxbleAmnt") 
     FROM PCH5 T2 
     WHERE T2."AbsEntry" = T0."DocEntry") AS "TaxbleAmnt Total",

    (SELECT SUM(T2."TxblAmntSC") 
     FROM PCH5 T2 
     WHERE T2."AbsEntry" = T0."DocEntry") AS "TxblAmntSC Total",

    (SELECT SUM(T2."WTAmnt") 
     FROM PCH5 T2 
     WHERE T2."AbsEntry" = T0."DocEntry") AS "WTAmnt Total",

    (SELECT STRING_AGG(T2."WTCode", ', ')
     FROM PCH5 T2 
     WHERE T2."AbsEntry" = T0."DocEntry") AS "WTCode",

    (SELECT STRING_AGG(T2."Rate", ', ')
     FROM PCH5 T2 
     WHERE T2."AbsEntry" = T0."DocEntry") AS "Rate"
     
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
    AND T0."CANCELED" = 'N'
GROUP BY 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."CardCode",
    T0."CardName", 
    T1."Currency"
**********************************




SELECT 
    'COMPRA' AS "Tipo",
    T0."DocEntry", 
    T0."DocNum" AS "Num Factura", 
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    SUM(T1."LineTotal") AS "Subtotal MXN Total",
    SUM(T1."VatSum") AS "IVA MXN Total",
    SUM(T1."LineTotal" + T1."VatSum") AS "Total MXN Total",
    SUM(T1."TotalSumSy") AS "Subtotal USD Total",
    SUM(T1."VatSumSy") AS "IVA USD Total",
    SUM(T1."TotalSumSy" + T1."VatSumSy") AS "Total USD Total",

    -- Subconsultas para obtener cada campo de retención
    (SELECT T2."WTCode" FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry" LIMIT 1) AS "WTCode_1",
    (SELECT T2."Rate" FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry" LIMIT 1) AS "Rate_1",
    (SELECT T2."TaxbleAmnt" FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry" LIMIT 1) AS "TaxbleAmnt_1",
    (SELECT T2."TxblAmntSC" FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry" LIMIT 1) AS "TxblAmntSC_1",
    (SELECT T2."WTAmnt" FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry" LIMIT 1) AS "WTAmnt_1",

    (SELECT T2."WTCode" FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry" LIMIT 1 OFFSET 1) AS "WTCode_2",
    (SELECT T2."Rate" FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry" LIMIT 1 OFFSET 1) AS "Rate_2",
    (SELECT T2."TaxbleAmnt" FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry" LIMIT 1 OFFSET 1) AS "TaxbleAmnt_2",
    (SELECT T2."TxblAmntSC" FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry" LIMIT 1 OFFSET 1) AS "TxblAmntSC_2",
    (SELECT T2."WTAmnt" FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry" LIMIT 1 OFFSET 1) AS "WTAmnt_2"

    -- Puedes añadir más subconsultas con OFFSET para más retenciones si es necesario.
     
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
    AND T0."CANCELED" = 'N'
GROUP BY 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."CardCode",
    T0."CardName", 
    T1."Currency"


    *******************************









   


    /* solucion 2 PERFECTO */
  
SELECT 
    'COMPRA' AS "Tipo",
    T0."DocEntry", 
    T0."DocNum" AS "Num Factura", 
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    SUM(T1."LineTotal") AS "Subtotal MXN Total",
    SUM(T1."VatSum") AS "IVA MXN Total",
    SUM(T1."LineTotal" + T1."VatSum") AS "Total MXN Total",
    SUM(T1."TotalSumSy") AS "Subtotal USD Total",
    SUM(T1."VatSumSy") AS "IVA USD Total",
    SUM(T1."TotalSumSy" + T1."VatSumSy") AS "Total USD Total",
    
    -- Primera retención
    T2."WTCode" AS "Código Retención 1",
    T2."Type" AS "Tipo Retención 1",
    T2."Rate" AS "Tasa Retención 1",
    T2."TaxbleAmnt" AS "Impuesto sujeto a impuesto Retención 1",
    T2."TxblAmntSC" AS "Impuesto sujeto a impuesto MS Retención 1",
    T2."WTAmnt" AS "Importe Retención 1",
    T2."WTAmntSC" AS "Importe de retenciones de impuesto MS Retención 1",
    T2."Category" AS "Categoria 1",
    T2."BaseType" AS "Importe Base 1",
    
    -- Segunda retención
    T3."WTCode" AS "Código Retención 2",
    T3."Type" AS "Tipo Retención 2",
    T3."Rate" AS "Tasa Retención 2",
    T3."TaxbleAmnt" AS "Impuesto sujeto a impuesto Retención 2",
    T3."TxblAmntSC" AS "Impuesto sujeto a impuesto MS Retención 2",
    T3."WTAmnt" AS "Importe Retención 2",
    T3."WTAmntSC" AS "Importe de retenciones de impuesto MS Retención 2",
    T3."Category" AS "Categoria 1",
    T3."BaseType" AS "Importe Base 2"

FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 

-- Primera retención
LEFT JOIN (
    SELECT 
        "AbsEntry",
        "WTCode",
        "Type",
        "Rate",
        "TaxbleAmnt",
        "TxblAmntSC",
        "WTAmnt",
        "WTAmntSC",
        "Category",
        "BaseType",
        ROW_NUMBER() OVER (PARTITION BY "AbsEntry" ORDER BY "WTCode") AS "Retencion_Num"
    FROM PCH5
) T2 ON T0."DocEntry" = T2."AbsEntry" AND T2."Retencion_Num" = 1  -- Primera retención

-- Segunda retención
LEFT JOIN (
    SELECT 
        "AbsEntry",
        "WTCode",
        "Type",
        "Rate",
        "TaxbleAmnt",
        "TxblAmntSC",
        "WTAmnt",
        "WTAmntSC",
        "Category",
        "BaseType",
        ROW_NUMBER() OVER (PARTITION BY "AbsEntry" ORDER BY "WTCode") AS "Retencion_Num"
    FROM PCH5
) T3 ON T0."DocEntry" = T3."AbsEntry" AND T3."Retencion_Num" = 2  -- Segunda retención

WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
    AND T0."CANCELED" = 'N'

GROUP BY 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."CardCode",
    T0."CardName", 
    T1."Currency",
    T2."WTCode", T2."Type", T2."Rate", T2."TaxbleAmnt", T2."TxblAmntSC", T2."WTAmnt", T2."WTAmntSC", T2."Category", T2."BaseType",  -- Primera retención
    T3."WTCode", T3."Type", T3."Rate", T3."TaxbleAmnt", T3."TxblAmntSC", T3."WTAmnt", T3."WTAmntSC",  T3."Category", T3."BaseType"  -- Segunda retención



/* nota de credito compra  */

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
    SUM(((T1."TotalSumSy" + T1."VatSumSy") * -1)) AS "Total USD Total",
    
    -- Primera retención
    T4."WTCode" AS "Código Retención 1",
    T4."Type" AS "Tipo Retención 1",
    T4."Rate" AS "Tasa Retención 1",
    T4."TaxbleAmnt" AS "Impuesto sujeto a impuesto Retención 1",
    T4."TxblAmntSC" AS "Impuesto sujeto a impuesto MS Retención 1",
    T4."WTAmnt" AS "Importe Retención 1",
    T4."WTAmntSC" AS "Importe de retenciones de impuesto MS Retención 1",
    T4."Category" AS "Categoria 1",
    T4."BaseType" AS "Importe Base 1",
    
    -- Segunda retención
    T5."WTCode" AS "Código Retención 2",
    T5."Type" AS "Tipo Retención 2",
    T5."Rate" AS "Tasa Retención 2",
    T5."TaxbleAmnt" AS "Impuesto sujeto a impuesto Retención 2",
    T5."TxblAmntSC" AS "Impuesto sujeto a impuesto MS Retención 2",
    T5."WTAmnt" AS "Importe Retención 2",
    T5."WTAmntSC" AS "Importe de retenciones de impuesto MS Retención 2",
    T5."Category" AS "Categoria 2",
    T5."BaseType" AS "Importe Base 2"

FROM ORPC T0
INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"

-- Primera retención
LEFT JOIN (
    SELECT 
        "AbsEntry",
        "WTCode",
        "Type",
        "Rate",
        "TaxbleAmnt",
        "TxblAmntSC",
        "WTAmnt",
        "WTAmntSC",
        "Category",
        "BaseType",
        ROW_NUMBER() OVER (PARTITION BY "AbsEntry" ORDER BY "WTCode") AS "Retencion_Num"
    FROM PCH5
) T4 ON T0."DocEntry" = T4."AbsEntry" AND T4."Retencion_Num" = 1  -- Primera retención

-- Segunda retención
LEFT JOIN (
    SELECT 
        "AbsEntry",
        "WTCode",
        "Type",
        "Rate",
        "TaxbleAmnt",
        "TxblAmntSC",
        "WTAmnt",
        "WTAmntSC",
        "Category",
        "BaseType",
        ROW_NUMBER() OVER (PARTITION BY "AbsEntry" ORDER BY "WTCode") AS "Retencion_Num"
    FROM PCH5
) T5 ON T0."DocEntry" = T5."AbsEntry" AND T5."Retencion_Num" = 2  -- Segunda retención

WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'

GROUP BY 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."CardCode",
    T0."CardName", 
    T1."Currency",
    T2."Series",
    T4."WTCode", T4."Type", T4."Rate", T4."TaxbleAmnt", T4."TxblAmntSC", T4."WTAmnt", T4."WTAmntSC", T4."Category", T4."BaseType",  -- Primera retención
    T5."WTCode", T5."Type", T5."Rate", T5."TaxbleAmnt", T5."TxblAmntSC", T5."WTAmnt", T5."WTAmntSC", T5."Category", T5."BaseType"  -- Segunda retención
    