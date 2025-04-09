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



