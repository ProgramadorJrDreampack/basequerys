
SELECT
    T0."ItemCode" AS "Número de Activo Fijo",
    T0."ItemName" AS "Nombre del Activo Fijo",
    CASE T0."AsstStatus"
           WHEN 'A' THEN 'Activo'
           WHEN 'I' THEN 'Inactivo'
           WHEN 'N' THEN 'Nuevo'
       END AS "Estado del Activo",
    T4."BuyTax" AS "Costo de Adquisición",
    T4."OtherTax" AS "Costo de Producción",
    T4."TotalTax" AS "Valor Contable Neto",
    T4."cstAllcAcc" AS "Amortización Normal",
    T4."cstExpAcc" AS "Valor de Recuperación",
    T2."UseLife",
    T0."ItmsGrpCod"
FROM OITM T0
INNER JOIN OACS T1 ON T0."AssetClass" = T1."Code" 
INNER JOIN ACS1 T2 ON T1."Code" = T2."Code"
INNER JOIN OITB T3 ON T0."ItmsGrpCod" = T3."ItmsGrpCod"
INNER JOIN OARG T4 ON T0."CstGrpCode" = T4."CstGrpCode"
WHERE T0."ItemType" = 'F'
LIMIT 10



/* ESTO REALICE DE BANCO DE PAGOS EFECTUADOS */
SELECT 
    'PAGO' AS "Tipo",
    T0."DocEntry",
    T0."DocNum" AS "Num Pago",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T0."BankCode" AS "Código Banco",
    T0."BankName" AS "Nombre Banco",
    T0."CashSum" AS "Monto Pago",
    T0."CashSumFC" AS "Monto Pago FC",
    T0."Currency" AS "Moneda",
    T0."AcctCode" AS "Cuenta Mayor"
FROM 
    OVPM T0  
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
AND 
    T0."Canceled" = 'N'

