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



/* ACTUALIZAR SUMATORIA Y AGRUPACION */

SELECT
'FAC' AS "Tipo",
T0."DocEntry",
T0."DocNum",
T0."DocDate",
T0."CardCode",
T0."CardName",
T1."Dscription",
--T1."Quantity" AS "CANTIDAD",
T1."Currency",
--T1."DiscPrcnt",
SUM(T1."LineTotal") As "Subtotal MXN",
SUM(T1."VatSum")  AS "IVA MXN",
SUM(T1."LineTotal" + T1."VatSum") AS "Total MXN",
SUM(T1."TotalSumSy") AS "Subtotal USD",
SUM(T1."VatSumSy") AS "IVA USD",
SUM(T1."TotalSumSy" + T1."VatSumSy") AS "Total USD",
T1."AcctCode" AS "Cuenta Mayor"
FROM OINV T0  
INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'
GROUP BY  T0."DocEntry", T0."DocNum", T0."DocDate", T0."CardCode", T0."CardName", T1."Dscription", T1."Currency", T1."AcctCode"

UNION ALL

SELECT
'NC' AS "Tipo",
T0."DocEntry",
T0."DocNum",
T0."DocDate",
T0."CardCode",
T0."CardName",
T1."Dscription", 
--(T1."Quantity" * -1) AS "CANTIDAD",
T1."Currency",
--T1."DiscPrcnt",
SUM(T1."LineTotal" * -1) As "Subtotal MXN",
SUM(T1."VatSum" * -1)  AS "IVA MXN",
SUM((T1."LineTotal" + T1."VatSum") * -1) AS "Total MXN",
SUM(T1."TotalSumSy" * -1) AS "Subtotal USD",
SUM(T1."VatSumSy" * -1) AS "IVA USD",
SUM((T1."TotalSumSy" + T1."VatSumSy") * -1) AS "Total USD",
T1."AcctCode" AS "Cuenta Mayor"

FROM ORIN T0
INNER JOIN RIN1 T1 ON T0."DocEntry" = T1."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'
GROUP BY T0."DocEntry", T0."DocNum", T0."DocDate", T0."CardCode", T0."CardName", T1."Dscription", T1."Currency", T1."AcctCode"



/* este es el query original que esta en INFO VENNTAS */
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