/* original */

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


/* Modificando */

-- Retención = (IVA MXN Total / Subtotal MXN Total) * 100

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
  SUM(T1."TotalSumSy" + T1."VatSumSy") AS "Total USD Total",
  (SUM(T1."VatSum") / SUM(T1."LineTotal")) * 100 AS "Retención MXN",
  (SUM(T1."VatSumSy") / SUM(T1."TotalSumSy")) * 100 AS "Retención USD",
  T1."AcctCode" AS "Cuenta Mayor"
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'
GROUP BY 
 T2."Series", T0."DocEntry", T0."DocNum", T0."DocDate", T0."CardCode", T0."CardName", T1."Currency", T1."AcctCode"

UNION ALL

SELECT
  'NC COMPRA' AS "Tipo",
  T2."Series" AS "Serie",
  T0."DocEntry",
  T0."DocNum" AS "Num Factura",
  T0."DocDate",
  T0."CardCode",
  T0."CardName",
  T1."Currency",
  SUM((T1."LineTotal" * -1)) As "Subtotal MXN Total",
  SUM((T1."VatSum" * -1)) AS "IVA MXN Total",
  SUM(((T1."LineTotal" + T1."VatSum") * -1)) AS "Total MXN Total",
  SUM((T1."TotalSumSy" * -1)) AS "Subtotal USD Total",
  SUM((T1."VatSumSy" * -1)) AS "IVA USD Total",
  SUM(((T1."TotalSumSy" + T1."VatSumSy") * -1)) AS "Total USD Total",
  ((SUM((T1."VatSum" * -1)) / SUM((T1."LineTotal" * -1))) * 100 AS "Retención MXN",
  ((SUM((T1."VatSumSy" * -1)) / SUM((T1."TotalSumSy" * -1))) * 100 AS "Retención USD",
  T1."AcctCode" AS "Cuenta Mayor"
FROM ORPC T0
INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'
GROUP BY 
 T2."Series", T0."DocEntry", T0."DocNum", T0."DocDate", T0."CardCode", T0."CardName", T1."Currency", T1."AcctCode"

/* me falta los  iva , de retenciones  */
SELECT 
    'COMPRA' AS "Tipo",
    T0."Series" AS "Serie",
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
    SUM(T1."TotalSumSy" + T1."VatSumSy") AS "Total USD Total",
    SUM(T2."WTSum") AS "Retención Total",
    T1."AcctCode" AS "Cuenta Mayor"
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN INV5 T2 ON T0."DocEntry"  = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'
GROUP BY 
  T0."DocEntry", T0."DocNum", T0."DocDate", T0."CardCode", T0."CardName", T1."Currency", T1."AcctCode"

UNION ALL

SELECT
    'NC COMPRA' AS "Tipo",
    --T2."Series" AS "Serie",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    SUM((T1."LineTotal" * -1)) As "Subtotal MXN Total",
    SUM((T1."VatSum" * -1)) AS "IVA MXN Total",
    SUM(((T1."LineTotal" + T1."VatSum") * -1)) AS "Total MXN Total",
    
    SUM((T1."TotalSumSy" * -1)) AS "Subtotal USD Total",
    SUM((T1."VatSumSy" * -1)) AS "IVA USD Total",
    SUM(((T1."TotalSumSy" + T1."VatSumSy") * -1)) AS "Total USD Total",
    SUM(T2."WTSum" * -1) AS "Retención Total",
    T1."AcctCode" AS "Cuenta Mayor"
FROM ORPC T0
INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN INV5 T2 ON T0."DocEntry" = T2."DocEntry"
--INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'
GROUP BY 
 --T2."Series", 
T0."DocEntry", T0."DocNum", T0."DocDate", T0."CardCode", T0."CardName", T1."Currency", T1."AcctCode"


 /* ***TRABAJANDO INFO BASE COMPRA*** */

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
    T0."WTSum"
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
--LEFT JOIN INV5 T2 ON T1."AcctCode" = T2."Account"
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
    --T2."WTCode",
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
    SUM((T1."LineTotal" * -1)) AS "Subtotal MXN Total",
    SUM((T1."VatSum" * -1)) AS "IVA MXN Total",
    SUM(((T1."LineTotal" + T1."VatSum") * -1)) AS "Total MXN Total",
    SUM((T1."TotalSumSy" * -1)) AS "Subtotal USD Total",
    SUM((T1."VatSumSy" * -1)) AS "IVA USD Total",
    SUM(((T1."TotalSumSy" + T1."VatSumSy") * -1)) AS "Total USD Total",
    T1."AcctCode" AS "Cuenta Mayor",
    --T2."WTCode",
    T0."WTSum"
FROM ORPC T0
INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
--LEFT JOIN INV5 T2 ON T1."AcctCode" = T2."Account"
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



/* trabajando en info compra con subconsulta *********** */

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
    T0."WTSum"
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
    SUM((T1."LineTotal" * -1)) AS "Subtotal MXN Total",
    SUM((T1."VatSum" * -1)) AS "IVA MXN Total",
    SUM(((T1."LineTotal" + T1."VatSum") * -1)) AS "Total MXN Total",
    SUM((T1."TotalSumSy" * -1)) AS "Subtotal USD Total",
    SUM((T1."VatSumSy" * -1)) AS "IVA USD Total",
    SUM(((T1."TotalSumSy" + T1."VatSumSy") * -1)) AS "Total USD Total",
    T1."AcctCode" AS "Cuenta Mayor",
    T0."WTSum"
FROM ORPC T0
INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
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

  /* SELECT
  T0."DocEntry",
  T0."WTSum",
  (SELECT T2."BaseType" FROM INV5 T2 WHERE T2."Account" = T1."AcctCode") AS "BaseType",
  (SELECT T2."Category" FROM INV5 T2 WHERE T2."Account" = T1."AcctCode") AS "Category",
  (SELECT T2."Type" FROM INV5 T2 WHERE T2."Account" = T1."AcctCode") AS "Type",
  (SELECT T2."Rate" FROM INV5 T2 WHERE T2."Account" = T1."AcctCode") AS "Rate"
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
WHERE 
  T0."DocDate" BETWEEN [%0] AND [%1]
  AND T0."CANCELED" = 'N';

*/


/*  ESTE SI SALIO LA SUBCONSULTA 
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

 */


 /* SOCIO DE NEGOCIO
   SELECT T0."CardCode", T0."CardName", T1."SlpName" 
   FROM OCRD T0  
   INNER JOIN OSLP T1 ON T0."SlpCode" = T1."SlpCode" 
   WHERE T0."CardCode" LIKE 'C%'
 
  */

SELECT 
  T0."DocEntry",
  T0."WTSum",
  T2."BaseType",
  T2."Category",
  T2."Type",
  T2."Rate"
FROM 
  OPCH T0  
  INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
  INNER JOIN (
    SELECT "Account", "BaseType", "Category", "Type","Rate" FROM INV5
  ) T2 ON T1."AcctCode" = T2."Account"
WHERE 
  T0."DocDate" BETWEEN [%0] AND [%1]
  AND T0."CANCELED" = 'N';


/* ****************************************************** */

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
    (
     SELECT T2."Rate" FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry"
    ) AS "Rate"
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
    SUM((T1."LineTotal" * -1)) AS "Subtotal MXN Total",
    SUM((T1."VatSum" * -1)) AS "IVA MXN Total",
    SUM(((T1."LineTotal" + T1."VatSum") * -1)) AS "Total MXN Total",
    SUM((T1."TotalSumSy" * -1)) AS "Subtotal USD Total",
    SUM((T1."VatSumSy" * -1)) AS "IVA USD Total",
    SUM(((T1."TotalSumSy" + T1."VatSumSy") * -1)) AS "Total USD Total",
    T1."AcctCode" AS "Cuenta Mayor",
    T0."WTSum",
    (
        SELECT T2."Rate" 
        FROM RPC5 T2 
        WHERE T2."AbsEntry" = T0."DocEntry"
    ) AS "Rate"
FROM ORPC T0
INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
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

/* ********************TRABAJANDO 04/10/2024********************************** */

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
    T3."Rate",
    T3."Category",
    T3."TaxbleAmnt",
    T3."TxblAmntSC",
    T0."WTSum"
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PCH5 T3 ON T0."DocEntry" = T3."AbsEntry" 
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
    T0."WTSum", 
    T3."Rate",
    T3."Category",
    T3."TaxbleAmnt",
    T3."TxblAmntSC"
 
UNION ALL

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
    T3."Rate",
    T3."Category",
    T3."TaxbleAmnt",
    T3."TxblAmntSC",
    T0."WTSum"
FROM ORPC T0
INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN RPC5 T3 ON T0."DocEntry" = T3."AbsEntry"
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
    T0."WTSum", 
    T3."Rate",
    T3."Category",
    T3."TaxbleAmnt",
    T3."TxblAmntSC"



/* CON ESTO SALIO  */

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
    INNER JOIN 
        PCH5 T2 ON T0."DocEntry" = T2."AbsEntry"
    WHERE 
        T0."DocDate" BETWEEN [%0] AND [%1]
        AND T0."CANCELED" = 'N'
)
SELECT 
    "DocEntry",
    "WTSum",
    "DocDate",
    MAX(CASE WHEN RowNum = 1 THEN "WTCode" END) AS "WTCode1",
    MAX(CASE WHEN RowNum = 1 THEN "Rate" END) AS "Rate1",
    MAX(CASE WHEN RowNum = 1 THEN "TaxbleAmnt" END) AS "TaxbleAmnt1",
    MAX(CASE WHEN RowNum = 1 THEN "TxblAmntSC" END) AS "TxblAmntSC1",
    MAX(CASE WHEN RowNum = 1 THEN "WTAmnt" END) AS "WTAmnt1",
    MAX(CASE WHEN RowNum = 2 THEN "WTCode" END) AS "WTCode2",
    MAX(CASE WHEN RowNum = 2 THEN "Rate" END) AS "Rate2",
    MAX(CASE WHEN RowNum = 2 THEN "TaxbleAmnt" END) AS "TaxbleAmnt2",
    MAX(CASE WHEN RowNum = 2 THEN "TxblAmntSC" END) AS "TxblAmntSC2",
    MAX(CASE WHEN RowNum = 2 THEN "WTAmnt" END) AS "WTAmnt2"
FROM 
    CTE
GROUP BY 
    "DocEntry",
    "WTSum",
    "DocDate"
ORDER BY 
    "DocEntry",
    "WTSum",
    "DocDate"


/* 

SELECT 
    T0."DocEntry",
    T0."WTSum",
    T0."DocDate"
    /* (SELECT T2."WTCode" FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry") AS "WTCode",
    (SELECT T2."Rate" FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry") AS "Rate",
    (SELECT MIN(T2."TaxbleAmnt") FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry") AS "TaxbleAmnt",
    (SELECT MIN(T2."TxblAmntSC") FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry") AS "TxblAmntSC",
    (SELECT MIN(T2."WTAmnt") FROM PCH5 T2 WHERE T2."AbsEntry" = T0."DocEntry") AS "WTAmnt" */
FROM 
    OPCH T0
INNER JOIN 
    PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
    AND T0."CANCELED" = 'N'
ORDER BY 
    T0."DocEntry",
    T0."WTSum",
    T0."DocDate"



 */













    /* INFO VENTAS ORIGINAL */
SELECT
'FAC' AS "Tipo",
T0."DocEntry",
T0."DocNum",
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


FROM OINV T0  
INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry" 

WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'

UNION ALL

SELECT
'NC' AS "Tipo",
T0."DocEntry",
T0."DocNum",
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

FROM ORIN T0
INNER JOIN RIN1 T1 ON T0."DocEntry" = T1."DocEntry"

WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'
 


 /*
 VERIFICAR SI SE APRUEBA 
 INFO VENTAS Sumatorias y agrupados Modificando */
 SELECT
   'FAC' AS "Tipo",
    T0."DocEntry",
    T0."DocNum",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
   --T1."ItemCode",
   --T1."Dscription",
   --T1."Quantity" AS "CANTIDAD",
   T1."Currency",
   --T1."DiscPrcnt",
   SUM(T1."LineTotal") As "Subtotal MXN Total",
   SUM(T1."VatSum")  AS "IVA MXN Total",
   SUM(T1."LineTotal" + T1."VatSum") AS "Total MXN Total",
   SUM(T1."TotalSumSy") AS "Subtotal USD Total",
   SUM(T1."VatSumSy") AS "IVA USD Total",
   SUM(T1."TotalSumSy" + T1."VatSumSy") AS "Total USD Total",
   T1."AcctCode" AS "Cuenta Mayor"


FROM OINV T0  
INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry" 

WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'
GROUP BY
   T0."DocEntry",
    T0."DocNum",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    T1."AcctCode"
  
UNION ALL

SELECT
   'NC' AS "Tipo",
   T0."DocEntry",
   T0."DocNum",
   T0."DocDate",
   T0."CardCode",
   T0."CardName",
   --T1."ItemCode",
   --T1."Dscription", 
   --(T1."Quantity" * -1) AS "CANTIDAD",
   T1."Currency",
   --T1."DiscPrcnt",
   SUM((T1."LineTotal" * -1)) As "Subtotal MXN",
   SUM((T1."VatSum" * -1))  AS "IVA MXN",
   SUM(((T1."LineTotal" + T1."VatSum") * -1)) AS "Total MXN",
   SUM((T1."TotalSumSy" * -1)) AS "Subtotal USD",
   SUM((T1."VatSumSy" * -1)) AS "IVA USD",
   SUM(((T1."TotalSumSy" + T1."VatSumSy") * -1)) AS "Total USD",
   T1."AcctCode" AS "Cuenta Mayor"

FROM ORIN T0
INNER JOIN RIN1 T1 ON T0."DocEntry" = T1."DocEntry"

WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'
GROUP BY 
    T0."DocEntry",
    T0."DocNum",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
   T1."AcctCode"