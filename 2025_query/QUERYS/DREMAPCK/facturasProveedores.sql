SELECT
    T0."DocEntry",
    T0."DocNum",
    T0."DocDate",
    T0."CardName",
    T0."Comments",
    T0."DocDueDate",
    T0."U_SYP_SERIESUC",
    T0."U_SYP_MDSD",
    T0."U_SYP_MDCO",
    (T0."U_SYP_SERIESUC" || '-' || T0."U_SYP_MDSD" || '-' || T0."U_SYP_MDCO") AS "Serie Completa",
    T0."BaseAmnt" AS "SubTotal",
    T0."VatSum" AS "Iva",
    (T0."BaseAmnt" + T0."VatSum") AS "Total General",
    T0."DocTotal",
    T0."WTSum" AS "Retencion",
    T0."CtlAccount",
    T0."PaidSum" AS "Total Pagado",
    T0."U_SYP_NROAUTO",
    
    T0."U_SYP_DESDOC",

   T0."U_SYP_TPDOCCERT",
   T0."U_SYP_SUCCERT",
   T0."U_SYP_SERTRET",
   T0."U_SYP_CORCERT",
   T0."U_SYP_NROAUTOC",
   CASE  
      WHEN T0."U_SYP_ESTADO_FE" = 'A' THEN 'Autorizado'
      WHEN T0."U_SYP_ESTADO_FE" = 'D' THEN 'Documento Devuelto'
      WHEN T0."U_SYP_ESTADO_FE" = 'E' THEN 'Enviar'
      WHEN T0."U_SYP_ESTADO_FE" = 'P' THEN 'Por Enviar'
      ELSE ''
   END AS "Estado Fact. Elect"
    
FROM OPCH T0
WHERE
     T0."DocDate" BETWEEN [%0] AND [%1]
  --T0."DocNum" = '25000007'
ORDER BY
    T0."DocDate";