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

    -- Retenciones de ISR
    T2."WTCode" AS "Código Retención ISR",
    T2."WTName" AS "Nombre Retención ISR",
    T2."Rate" AS "Tasa Retención ISR",
    T2."TaxbleAmnt" AS "Impuesto sujeto a retención ISR",
    T2."WTAmnt" AS "Importe Retención ISR",

    -- Retenciones de IVA
    T3."WTCode" AS "Código Retención IVA",
    T3."WTName" AS "Nombre Retención IVA",
    T3."Rate" AS "Tasa Retención IVA",
    T3."TaxbleAmnt" AS "Impuesto sujeto a retención IVA",
    T3."WTAmnt" AS "Importe Retención IVA"

FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 

-- Subconsulta para retenciones de ISR
LEFT JOIN (
    SELECT 
        A0."AbsEntry",
        A0."WTCode",
        A0."Rate",
        A0."TaxbleAmnt",
        A0."WTAmnt",
        A1."WTName"
    FROM PCH5 A0
    INNER JOIN OWHT A1 ON A0."WTCode" = A1."WTCode"
    WHERE A0."Type" = 'I'  -- Solo retenciones de Impuesto sobre la Renta
) T2 ON T0."DocEntry" = T2."AbsEntry"

-- Subconsulta para retenciones de IVA
LEFT JOIN (
    SELECT 
        A0."AbsEntry",
        A0."WTCode",
        A0."Rate",
        A0."TaxbleAmnt",
        A0."WTAmnt",
        A1."WTName"
    FROM PCH5 A0
    INNER JOIN OWHT A1 ON A0."WTCode" = A1."WTCode"
    WHERE A0."Type" = 'V'  -- Solo retenciones de IVA
) T3 ON T0."DocEntry" = T3."AbsEntry"

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
    T2."WTName", 
    T2."Rate", 
    T2."TaxbleAmnt", 
    T2."WTAmnt",  
    T3."WTCode", 
    T3."WTName",  
    T3."Rate", 
    T3."TaxbleAmnt", 
    T3."WTAmnt"

UNION ALL

SELECT 
    'NC COMPRA' AS "Tipo",
    T0."DocEntry",
    T0."DocNum" AS "Num Factura",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."Currency",
    
   -- Notas de crédito (valores negativos)
   SUM((T1."LineTotal" * -1)) As "Subtotal MXN Total",
   SUM((T1."VatSum" * -1))  AS "IVA MXN Total",
   SUM(((T1."LineTotal" + T1."VatSum") * -1)) AS "Total MXN Total",
   SUM((T1."TotalSumSy" * -1)) AS "Subtotal USD Total",
   SUM((T1."VatSumSy" * -1)) AS "IVA USD Total",
   SUM(((T1."TotalSumSy" + T1."VatSumSy") * -1)) AS "Total USD Total",

   -- Para las notas de crédito, no hay retenciones, así que usamos NULL
   NULL AS "Código Retención ISR", 
   NULL AS "Nombre Retención ISR", 
   NULL AS "Tasa Retención ISR", 
   NULL AS "Impuesto sujeto a retención ISR", 
   NULL AS "Importe Retención ISR",

   NULL AS "Código Retención IVA", 
   NULL AS "Nombre Retención IVA",  
   NULL AS "Tasa Retención IVA",  
   NULL AS "Impuesto sujeto a retención IVA",  
   NULL AS "Importe Retención IVA"

FROM ORPC T0
INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"
WHERE 
     T0."DocDate" BETWEEN [%0] AND [%1]
     AND  T0."CANCELED" = 'N'

GROUP BY 
     T0."DocEntry", 
     T0."DocNum", 
     T0."DocDate", 
     T0."CardCode", 
     T0."CardName", 
     T1."Currency";