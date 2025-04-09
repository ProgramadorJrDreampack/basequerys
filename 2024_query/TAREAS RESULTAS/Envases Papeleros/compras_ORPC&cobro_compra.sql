/* Info Compras */

SELECT
    'COMPRA' AS "Tipo",
    --T2."Series",
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
--INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'

UNION ALL

SELECT
    'NC COMPRA' AS "Tipo",
    --T2."Series",
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
--INNER JOIN OPCH T2 ON T0."DocEntry" = T2."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."CANCELED" = 'N'


/* Info Pagos Compra */

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



/* Info Ventas */

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



SELECT 
    'PAGO' AS "Tipo",  
    T0."DocEntry",
    T0."DocNum",
    T0."DocDate",
    T1."CardCode",
    T1."CardName",
    T1."DocCur",
    T1."DocTotal",
    T1."VatSum"  AS "IVA MXN",
    (T1."DocTotal" + T1."VatSum") AS "Total MXN",
    T1."TotalSumSy" AS "Subtotal USD",
    T1."VatSumSy"  AS "IVA USD",
    (T1."DocTotalSy" + T1."VatSumSy") AS "Total USD"
FROM 
    OVPM T0
INNER JOIN OPCH T1 ON T0."CardCode" = T1."CardCode" 
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
LIMIT 10


/* ULTIMO CAMBIO DE PAGOS */
SELECT 
    'PAGO' AS "Tipo",  
    T0."DocEntry",
    T0."DocNum",
    T0."DocDate",
    T1."CardCode",
    T1."CardName",
    T1."DocCur",
    T1."DocTotal",
    T1."VatSum"  AS "IVA MXN",
    (T1."DocTotal" + T1."VatSum") AS "Total MXN",
    T1."DocTotalSy",
    T1."VatSumFC",
    (T1."DocTotalSy" + T1."VatSumFC") AS "Total USD",
    T2.*
FROM 
    OVPM T0
INNER JOIN OPCH T1 ON T0."DocNum" = T1."DocNum"
INNER JOIN OCRD T2 ON T1."CardCode" = T2."CardCode" 
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
LIMIT 10


/* CAMBIOS POR VERIFICAR */





SELECT 
  T0.*
FROM OPCH T0 
WHERE T0."DocNum" = [%0]
 LIMIT 10


 SELECT 
    'PAGO' AS "Tipo",  
    T0."DocEntry",
    T0."DocNum",
    T1.*  
FROM 
    OVPM T0
INNER JOIN OPCH T1 ON T0."DocNum" = T1."DocNum"
INNER JOIN OCRD T2 ON T1."CardCode" = T2."CardCode" 
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
LIMIT 10

SELECT 
    T0."DocNum",
    T0."DocDate",
    T0."DocTotal",
    T2."DocNum",
    T2."DocDate" AS "Fecha de Factura",
    T2."DocTotal" AS "Total Factura",
    T1.*
FROM 
    OVPM T0 -- Encabezado de Pagos Efectuados
    INNER JOIN VPM2 T1 ON T0."DocEntry" = T1."DocNum" -- Relación entre pagos y facturas
    INNER JOIN OPCH T2 ON T1."DocEntry" = T2."DocEntry" -- Factura de Compra relacionada
    INNER JOIN OCRD T3 ON T2."CardCode" = T3."CardCode" -- Información del proveedor
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
ORDER BY 
    T0."DocNum";

****

SELECT 
  T0."DocNum",
  T0."CardName",
  T1."CardCode"
FROM OVPM T0 
INNER JOIN OPCH T1 ON T0."DocNum" = T1."DocNum"
WHERE T1."DocNum" = [%0]
LIMIT 10


24001036


SELECT 
  T0."DocNum",
  T0."CardName",
  T1."CardCode",
  T2.*
FROM OVPM T0 
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN OPCH T2 ON T0."DocNum" = T2."CardCode"
WHERE T0."DocNum" = [%0]
LIMIT 10



/* codigo por verificar  al sr mauricio APROBADO*/
DE QUE BANCO AH HECHO EL PAGO - SUBTOTAL MEXICO
SELECT
    T0."DocNum",
    T0."DocDate",
    T0."DocTotal",
    T1."DocEntry",
    T2."DocNum",
    T2."DocDate",
    T2."CardCode",
    T2."CardName",
    T2."DiscSum" AS "Subtotal MX",
    T2."VatSum" AS "IVA MXN",
    T2."DocTotal" AS "Total MXN",
    T2."DiscSumFC" AS "Subtotal USD",
    T2."VatSumFC" AS "IVA USD",
    T2."DocTotalFC" AS "Total USD",
    T3."CardCode",
    T3."CardName"
FROM 
    OVPM T0
    INNER JOIN VPM2 T1 ON T0."DocEntry" = T1."DocNum"
    INNER JOIN OPCH T2 ON T1."DocEntry" = T2."DocEntry"
    INNER JOIN OCRD T3 ON T2."CardCode" = T3."CardCode"
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
ORDER BY 
    T0."DocDate";

    /* 30-092024 */

    /* Probando */
SELECT 
  T0."DocNum",
  T0."DocDate",
  T1."DocEntry",
  T2."DocNum",
  T2."DocDate",
  T2."CardCode"
FROM OVPM T0
INNER JOIN VPM2 T1 ON T0."DocEntry" = T1."DocNum" 
INNER JOIN OPCH T2 ON T0."DocNum" = T2."CardCode"
WHERE T0."DocNum" = [%0]
LIMIT 10


    24001126
    COMPRAS DEL AÑO 

    24000869

    EPM - Bancos - pagos efectuados -- revisar esa parte en la consulta



    /* AQUI YA ESTA CON EL NOMBRE DEL BANCO */  

   SELECT 
    T0."DocNum",
    T0."DocDate",
    T0."DocTotal",
    T1."DocEntry",
    T2."DocNum",
    T2."DocDate",
    T2."CardCode",
    T2."CardName",
    T2."DiscSum" AS "Subtotal MX",
    T2."VatSum" AS "IVA MXN",
    T2."DocTotal" AS "Total MXN",
    T2."DiscSumFC" AS "Subtotal USD",
    T2."VatSumFC" AS "IVA USD",
    T2."DocTotalFC" AS "Total USD",
    T3."CardCode",
    T3."CardName",
    T4."BankName"
FROM 
    OVPM T0
    INNER JOIN VPM2 T1 ON T0."DocEntry" = T1."DocNum"
    INNER JOIN OPCH T2 ON T1."DocEntry" = T2."DocEntry"
    INNER JOIN OCRD T3 ON T2."CardCode" = T3."CardCode"
    LEFT JOIN ODSC T4 ON T3."BankCode" = T4."BankCode"
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
ORDER BY 
    T0."DocDate";


    -- OJO
SELECT 
    T0."DocNum",
    T0."DocDate",
    T0."DocTotal",
    T1."DocEntry",
    T2."DocNum",
    T2."DocDate",
    T2."CardCode",
    T2."CardName",
    SUM(T2."LineTotal" - (T2."LineTotal" * T2."VatPrcnt" / 100)) AS "Subtotal MX",
    SUM(T2."VatSum") AS "IVA MXN",
    T2."DocTotal" AS "Total MXN",
    T2."DiscSumFC" AS "Subtotal USD",
    T2."VatSumFC" AS "IVA USD",
    T2."DocTotalFC" AS "Total USD",
    T3."CardCode",
    T3."CardName",
    T4."BankName"
FROM 
    OVPM T0
    INNER JOIN VPM2 T1 ON T0."DocEntry" = T1."DocNum"
    INNER JOIN OPCH T2 ON T1."DocEntry" = T2."DocEntry"
    INNER JOIN OCRD T3 ON T2."CardCode" = T3."CardCode"
    LEFT JOIN ODSC T4 ON T3."BankCode" = T4."BankCode"
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
GROUP BY 
    T0."DocNum",
    T0."DocDate",
    T0."DocTotal",
    T1."DocEntry",
    T2."DocNum",
    T2."DocDate",
    T2."CardCode",
    T2."CardName",
    T3."CardCode",
    T3."CardName",
    T4."BankName"
ORDER BY 
    T0."DocDate";

    

    -- INVENTARIO - ARTICULOS CREADOS 07 DIAN ANTERIOR - ANDREA STEFANIA ALFONZO
    /* 
    UNIDAD MEDIDA DE VENTA
    GRUPO DE UNIDAD DE MEDIDA - DEFINICION DE GRUPO --(datos de inventario)
    agrupacion - (100 de caja) */
SELECT
    T0."ItemCode",
    T0."ItemName",
    T0."UgpEntry",
    T0."PriceUnit",
    T0."CntUnitMsr",
    T0."NumInCnt",
    T1."Name" AS "Familia",
    T2."Name" As "SubFamilia"
FROM OITM T0
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
WHERE 
    T0."ItemType" = 'I'
AND 
T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -7) AND T0."ItemCode" LIKE '07%'



    07 Y 04 LA CONSULTA

    /* del 07 */

SELECT
    T0."ItemCode",
    T0."ItemName",
    T0."CntUnitMsr",
    T0."NumInCnt",
    T1."Name" AS "Familia",
    T2."Name" As "SubFamilia",
    T3."UgpName",
    T4."UomCode",
    T4."UomName"
FROM OITM T0
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
INNER JOIN OUGP T3 ON T0."UgpEntry" = T3."UgpEntry"
INNER JOIN OUOM T4 ON T0."PriceUnit" = T4."UomEntry"
WHERE 
    T0."ItemType" = 'I'
    AND T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -7) 
    AND T0."ItemCode" LIKE '07%' 



/* 
OR T0."ItemCode" LIKE '04%'
 */



 INFO PAGOS COMPRA

 SELECT
    T0."DocNum" AS "# de documento de pago",
    T0."DocDate" AS "Fecha de pago",
    CASE
        WHEN T0."TrsfrAcct" IS NOT NULL THEN B1."AcctName"
        ELSE B2."AcctName" 
    END AS "Banco",
    CASE
        WHEN T2."DocNum" IS NULL AND T4."DocNum" IS NULL THEN T0."DocTotal"
        WHEN T0."DocType" = 'A' THEN T4."SumApplied"
        ELSE (
            CASE
                WHEN T1."InvType" = '18' THEN (-1 * T1."SumApplied")
                ELSE T1."SumApplied" 
            END
        )
    END AS "Valor Pagado MXN",
    CASE
        WHEN T2."DocNum" IS NULL AND T4."DocNum" IS NULL THEN T0."DocTotalSy"
        WHEN T0."DocType" = 'A' THEN T4."AppliedSys"
        ELSE (
            CASE
                WHEN T1."InvType" = '18' THEN (-1 * T1."AppliedSys")
                ELSE T1."AppliedSys" 
            END
        )
    END AS "Valor Pagado USD",
    CASE
        WHEN T0."TrsfrAcct" IS NOT NULL THEN 'Transferencia'
        WHEN T0."CashAcct" IS NOT NULL THEN 'Efectivo'
        WHEN T0."CheckAcct" IS NOT NULL THEN 'Cheque'
        ELSE 'Tarjeta de Crédito' 
    END AS "Método de pago"
FROM OVPM T0 -- Usando OVPM para pagos efectuados
LEFT JOIN VPM1 T1 ON T0."DocEntry" = T1."DocNum" -- Uniendo la tabla de detalles de pagos
LEFT JOIN OPCH A1 ON A1."DocEntry" = T1."DocNum" -- Uniendo a facturas de compras
LEFT JOIN VPM2 T4 ON T0."DocEntry" = T4."DocNum" AND T0."DocType" = 'A' -- TIPO A
LEFT JOIN OACT B1 ON T0."TrsfrAcct" = B1."AcctCode"
LEFT JOIN OACT B2 ON T0."CashAcct" = B2."AcctCode"
WHERE T0."DocDate" BETWEEN [%0] AND [%1] -- Filtrando por fechas
AND T0."Canceled" = 'N' 
ORDER BY T0."DocDate"



SELECT
    T0."DocNum" AS "# de documento de pago",
    T0."DocDate" AS "Fecha de pago",
    CASE
        WHEN T0."TrsfrAcct" IS NOT NULL THEN B1."AcctName"
        ELSE B2."AcctName" 
    END AS "Banco",
    CASE
        WHEN T0."TrsfrAcct" IS NOT NULL THEN 'Transferencia'
        WHEN T0."CashAcct" IS NOT NULL THEN 'Efectivo'
        WHEN T0."CheckAcct" IS NOT NULL THEN 'Cheque'
        ELSE 'Tarjeta de Crédito' 
    END AS "Método de pago"
FROM OVPM T0 -- Usando OVPM para pagos efectuados
LEFT JOIN VPM1 T1 ON T0."DocEntry" = T1."DocNum" -- Uniendo la tabla de detalles de pagos
LEFT JOIN OPCH A1 ON A1."DocEntry" = T1."DocNum" -- Uniendo a facturas de compras
LEFT JOIN VPM2 T4 ON T0."DocEntry" = T4."DocNum" AND T0."DocType" = 'A' -- TIPO A
LEFT JOIN OACT B1 ON T0."TrsfrAcct" = B1."AcctCode"
LEFT JOIN OACT B2 ON T0."CashAcct" = B2."AcctCode"
WHERE T0."DocDate" BETWEEN [%0] AND [%1] -- Filtrando por fechas
AND T0."Canceled" = 'N' 
ORDER BY T0."DocDate"


***
SELECT
    CASE
       WHEN T1."InvType" IN ('18', '46') THEN 'Novedad'
    ELSE NULL END AS "Novedades",
    T0."DocNum" AS "# de documento de pago",
    T0."DocDate" AS "Fecha de pago",
    A1."DocNum" AS  "# de Factura aplicada",
    CASE
       WHEN T0."TrsfrAcct" IS NOT NULL THEN B1."AcctName"
    ELSE B2."AcctName" END AS "Banco",
    CASE
       WHEN T1."DocNum" IS NULL AND T1."DocNum" IS NULL THEN T0."DocTotal"
       WHEN T0."DocType" = 'A' THEN T1."SumApplied"
    ELSE (	CASE
                  WHEN T1."InvType" = '18' THEN (-1 * T1."SumApplied")
                  ELSE T1."SumApplied" END
	 )
     END AS "Valor Pagado MXN",
     CASE
          WHEN T1."DocNum" IS NULL AND T1."DocNum" IS NULL THEN T0."DocTotalSy"
          WHEN T0."DocType" = 'A' THEN T1."AppliedSys"
     ELSE ( CASE
	   WHEN T1."InvType" = '18' THEN (-1 * T1."AppliedSys")
	   ELSE T1."AppliedSys" END
	 )
      END AS "Valor Pagado USD",
      CASE
          WHEN T0."TrsfrAcct" IS NOT NULL THEN 'Transferencia'
          WHEN T0."CashAcct" IS NOT NULL THEN 'Efectivo'
         WHEN T0."CheckAcct" IS NOT NULL THEN 'Cheque'
      ELSE 'Tarjeta de Credito' END AS "Metodo de pago"
FROM OVPM T0 -- Usando OVPM para pagos efectuados
LEFT JOIN VPM2 T1 ON T0."DocEntry" = T1."DocNum" -- Uniendo la tabla de detalles de pagos
LEFT JOIN OPCH A1 ON A1."DocEntry" = T1."DocEntry" -- Uniendo a facturas de compras 
LEFT JOIN OACT B1 ON T0."TrsfrAcct" = B1."AcctCode"
LEFT JOIN OACT B2 ON T0."CashAcct" = B2."AcctCode"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."Canceled" = 'N' 
ORDER BY T0."DocDate"