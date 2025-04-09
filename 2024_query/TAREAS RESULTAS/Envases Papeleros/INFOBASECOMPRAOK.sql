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

UNION ALL

/* nota de credito compra  */

SELECT 
    'NC COMPRA' AS "Tipo",
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
    T4."WTCode", T4."Type", T4."Rate", T4."TaxbleAmnt", T4."TxblAmntSC", T4."WTAmnt", T4."WTAmntSC", T4."Category", T4."BaseType",  -- Primera retención
    T5."WTCode", T5."Type", T5."Rate", T5."TaxbleAmnt", T5."TxblAmntSC", T5."WTAmnt", T5."WTAmntSC", T5."Category", T5."BaseType"  -- Segunda retención



/* se va actualizar info base compra */
/* requerimiento del Econ. Mauricio añadir la nota de credito a lado de las compras */
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
    T2."WTName",
    CASE 
       WHEN T2."Type" = 'I' THEN 'Retención de Impuesto sobre la Renta'
       WHEN T2."Type" = 'V' THEN 'Retención de IVA'
       ELSE ' '
    END AS "Tipo Retención 1",
    T2."Rate" AS "Tasa Retención 1",
    T2."TaxbleAmnt" AS "Impuesto sujeto a impuesto Retención 1",
    T2."TxblAmntSC" AS "Impuesto sujeto a impuesto MS Retención 1",
    T2."WTAmnt" AS "Importe Retención 1",
    T2."WTAmntSC" AS "Importe de retenciones de impuesto MS Retención 1",
    CASE 
       WHEN T2."Category" = 'I' THEN 'Factura'
       WHEN T2."Category" = 'P' THEN 'Pago'
       ELSE ' '
    END AS "Categoria 1",
    CASE 
       WHEN T2."BaseType" = 'G' THEN 'Bruto'
       WHEN T2."BaseType" = 'N' THEN 'Neto'
       WHEN T2."BaseType" = 'V' THEN 'Iva'
       ELSE ' '
    END AS "Importe Base 1",
     
   
    -- Segunda retención
    T3."WTCode" AS "Código Retención 2",
    T3."WTName",
    CASE 
       WHEN T3."Type" = 'I' THEN 'Retención de Impuesto sobre la Renta'
       WHEN T3."Type" = 'V' THEN 'Retención de IVA'
       ELSE ' '
    END AS "Tipo Retención 2",
    --T3."Type" AS "Tipo Retención 2",
    T3."Rate" AS "Tasa Retención 2",
    T3."TaxbleAmnt" AS "Impuesto sujeto a impuesto Retención 2",
    T3."TxblAmntSC" AS "Impuesto sujeto a impuesto MS Retención 2",
    T3."WTAmnt" AS "Importe Retención 2",
    T3."WTAmntSC" AS "Importe de retenciones de impuesto MS Retención 2",
    CASE 
       WHEN T3."Category" = 'I' THEN 'Factura'
       WHEN T3."Category" = 'P' THEN 'Pago'
       ELSE ' '
    END AS "Categoria 2",
    CASE 
       WHEN T3."BaseType" = 'G' THEN 'Bruto'
       WHEN T3."BaseType" = 'N' THEN 'Neto'
       WHEN T3."BaseType" = 'V' THEN 'Iva'
       ELSE ' '
    END AS "Importe Base 2"
   
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 

-- Primera retención
LEFT JOIN (
    SELECT 
        A0."AbsEntry",
        A0."WTCode",
        A0."Type",
        A0."Rate",
        A0."TaxbleAmnt",
        A0."TxblAmntSC",
        A0."WTAmnt",
        A0."WTAmntSC",
        A0."Category",
        A0."BaseType",
        A1."WTName",
        ROW_NUMBER() OVER (PARTITION BY A0."AbsEntry" ORDER BY A0."WTCode") AS "Retencion_Num"
    FROM PCH5 A0
    INNER JOIN OWHT A1 ON A0."WTCode" = A1."WTCode"
) T2 ON T0."DocEntry" = T2."AbsEntry" AND T2."Retencion_Num" = 1  -- Primera retención

-- Segunda retención
LEFT JOIN (
    SELECT 
        A0."AbsEntry",
        A0."WTCode",
        A0."Type",
        A0."Rate",
        A0."TaxbleAmnt",
        A0."TxblAmntSC",
        A0."WTAmnt",
        A0."WTAmntSC",
        A0."Category",
        A0."BaseType",
         A1."WTName",
        ROW_NUMBER() OVER (PARTITION BY A0."AbsEntry" ORDER BY A0."WTCode") AS "Retencion_Num"
    FROM PCH5 A0
    INNER JOIN OWHT A1 ON A0."WTCode" = A1."WTCode"
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
    T2."WTCode", T2."Type", T2."Rate", T2."TaxbleAmnt", T2."TxblAmntSC", T2."WTAmnt", T2."WTAmntSC", T2."Category", T2."BaseType", T2."WTName",  -- Primera retención
    T3."WTCode", T3."Type", T3."Rate", T3."TaxbleAmnt", T3."TxblAmntSC", T3."WTAmnt", T3."WTAmntSC",  T3."Category", T3."BaseType", T3."WTName"  -- Segunda retención
/*UNION ALL*/

/* nota de credito compra  */

SELECT 
    'NC COMPRA' AS "Tipo",
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
    T4."WTName",
    CASE 
       WHEN T4."Type" = 'I' THEN 'Retención de Impuesto sobre la Renta'
       WHEN T4."Type" = 'V' THEN 'Retención de IVA'
       ELSE ' '
    END AS "Tipo Retención 1",
    T4."Rate" AS "Tasa Retención 1",
    T4."TaxbleAmnt" AS "Impuesto sujeto a impuesto Retención 1",
    T4."TxblAmntSC" AS "Impuesto sujeto a impuesto MS Retención 1",
    T4."WTAmnt" AS "Importe Retención 1",
    T4."WTAmntSC" AS "Importe de retenciones de impuesto MS Retención 1",
    CASE 
       WHEN T4."Category" = 'I' THEN 'Factura'
       WHEN T4."Category" = 'P' THEN 'Pago'
       ELSE ' '
    END AS "Categoria 1",
    CASE 
       WHEN T4."BaseType" = 'G' THEN 'Bruto'
       WHEN T4."BaseType" = 'N' THEN 'Neto'
       WHEN T4."BaseType" = 'V' THEN 'Iva'
       ELSE ' '
    END AS "Importe Base 1",
    
    -- Segunda retención
    T5."WTCode" AS "Código Retención 2",
    T5."WTName",
    CASE 
       WHEN T5."Type" = 'I' THEN 'Retención de Impuesto sobre la Renta'
       WHEN T5."Type" = 'V' THEN 'Retención de IVA'
       ELSE ' '
    END AS "Tipo Retención 2",
    T5."Rate" AS "Tasa Retención 2",
    T5."TaxbleAmnt" AS "Impuesto sujeto a impuesto Retención 2",
    T5."TxblAmntSC" AS "Impuesto sujeto a impuesto MS Retención 2",
    T5."WTAmnt" AS "Importe Retención 2",
    T5."WTAmntSC" AS "Importe de retenciones de impuesto MS Retención 2",
    CASE 
       WHEN T5."Category" = 'I' THEN 'Factura'
       WHEN T5."Category" = 'P' THEN 'Pago'
       ELSE ' '
    END AS "Categoria 2",
    CASE 
       WHEN T5."BaseType" = 'G' THEN 'Bruto'
       WHEN T5."BaseType" = 'N' THEN 'Neto'
       WHEN T5."BaseType" = 'V' THEN 'Iva'
       ELSE ' '
    END AS "Importe Base 2"

FROM ORPC T0
INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"

-- Primera retención
LEFT JOIN (
    SELECT 
        A0."AbsEntry",
        A0."WTCode",
        A0."Type",
        A0."Rate",
        A0."TaxbleAmnt",
        A0."TxblAmntSC",
        A0."WTAmnt",
        A0."WTAmntSC",
        A0."Category",
        A0."BaseType",
        A1."WTName",
        ROW_NUMBER() OVER (PARTITION BY A0."AbsEntry" ORDER BY A0."WTCode") AS "Retencion_Num"
    FROM PCH5 A0
    INNER JOIN OWHT A1 ON A0."WTCode" = A1."WTCode"
) T4 ON T0."DocEntry" = T4."AbsEntry" AND T4."Retencion_Num" = 1  -- Primera retención

-- Segunda retención
LEFT JOIN (
    SELECT 
        A0."AbsEntry",
        A0."WTCode",
        A0."Type",
        A0."Rate",
        A0."TaxbleAmnt",
        A0."TxblAmntSC",
        A0."WTAmnt",
        A0."WTAmntSC",
        A0."Category",
        A0."BaseType",
        A1."WTName",
        ROW_NUMBER() OVER (PARTITION BY A0."AbsEntry" ORDER BY A0."WTCode") AS "Retencion_Num"
    FROM PCH5 A0
    INNER JOIN OWHT A1 ON A0."WTCode" = A1."WTCode"
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
    T4."WTCode", T4."Type", T4."Rate", T4."TaxbleAmnt", T4."TxblAmntSC", T4."WTAmnt", T4."WTAmntSC", T4."Category", T4."BaseType", T4."WTName",  -- Primera retención
    T5."WTCode", T5."Type", T5."Rate", T5."TaxbleAmnt", T5."TxblAmntSC", T5."WTAmnt", T5."WTAmntSC", T5."Category", T5."BaseType", T5."WTName"  -- Segunda retención


----------------ASI VA A QUEDAR POR EL MOMENTO INFO BASE COMPRA----------------
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
    T2."WTName",
    CASE 
       WHEN T2."Type" = 'I' THEN 'Retención de Impuesto sobre la Renta'
       WHEN T2."Type" = 'V' THEN 'Retención de IVA'
       ELSE ' '
    END AS "Tipo Retención 1",
    T2."Rate" AS "Tasa Retención 1",
    T2."TaxbleAmnt" AS "Impuesto sujeto a impuesto Retención 1",
    T2."TxblAmntSC" AS "Impuesto sujeto a impuesto MS Retención 1",
    T2."WTAmnt" AS "Importe Retención 1",
    T2."WTAmntSC" AS "Importe de retenciones de impuesto MS Retención 1",
    CASE 
       WHEN T2."Category" = 'I' THEN 'Factura'
       WHEN T2."Category" = 'P' THEN 'Pago'
       ELSE ' '
    END AS "Categoria 1",
    CASE 
       WHEN T2."BaseType" = 'G' THEN 'Bruto'
       WHEN T2."BaseType" = 'N' THEN 'Neto'
       WHEN T2."BaseType" = 'V' THEN 'Iva'
       ELSE ' '
    END AS "Importe Base 1",
     
   
    -- Segunda retención
    T3."WTCode" AS "Código Retención 2",
    T3."WTName",
    CASE 
       WHEN T3."Type" = 'I' THEN 'Retención de Impuesto sobre la Renta'
       WHEN T3."Type" = 'V' THEN 'Retención de IVA'
       ELSE ' '
    END AS "Tipo Retención 2",
    T3."Rate" AS "Tasa Retención 2",
    T3."TaxbleAmnt" AS "Impuesto sujeto a impuesto Retención 2",
    T3."TxblAmntSC" AS "Impuesto sujeto a impuesto MS Retención 2",
    T3."WTAmnt" AS "Importe Retención 2",
    T3."WTAmntSC" AS "Importe de retenciones de impuesto MS Retención 2",
    CASE 
       WHEN T3."Category" = 'I' THEN 'Factura'
       WHEN T3."Category" = 'P' THEN 'Pago'
       ELSE ' '
    END AS "Categoria 2",
    CASE 
       WHEN T3."BaseType" = 'G' THEN 'Bruto'
       WHEN T3."BaseType" = 'N' THEN 'Neto'
       WHEN T3."BaseType" = 'V' THEN 'Iva'
       ELSE ' '
    END AS "Importe Base 2"
   
FROM OPCH T0  
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry" 

-- Primera retención
LEFT JOIN (
    SELECT 
        A0."AbsEntry",
        A0."WTCode",
        A0."Type",
        A0."Rate",
        A0."TaxbleAmnt",
        A0."TxblAmntSC",
        A0."WTAmnt",
        A0."WTAmntSC",
        A0."Category",
        A0."BaseType",
        A1."WTName",
        ROW_NUMBER() OVER (PARTITION BY A0."AbsEntry" ORDER BY A0."WTCode") AS "Retencion_Num"
    FROM PCH5 A0
    INNER JOIN OWHT A1 ON A0."WTCode" = A1."WTCode"
) T2 ON T0."DocEntry" = T2."AbsEntry" AND T2."Retencion_Num" = 1  -- Primera retención

-- Segunda retención
LEFT JOIN (
    SELECT 
        A0."AbsEntry",
        A0."WTCode",
        A0."Type",
        A0."Rate",
        A0."TaxbleAmnt",
        A0."TxblAmntSC",
        A0."WTAmnt",
        A0."WTAmntSC",
        A0."Category",
        A0."BaseType",
         A1."WTName",
        ROW_NUMBER() OVER (PARTITION BY A0."AbsEntry" ORDER BY A0."WTCode") AS "Retencion_Num"
    FROM PCH5 A0
    INNER JOIN OWHT A1 ON A0."WTCode" = A1."WTCode"
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
    T2."WTCode", T2."Type", T2."Rate", T2."TaxbleAmnt", T2."TxblAmntSC", T2."WTAmnt", T2."WTAmntSC", T2."Category", T2."BaseType", T2."WTName",  -- Primera retención
    T3."WTCode", T3."Type", T3."Rate", T3."TaxbleAmnt", T3."TxblAmntSC", T3."WTAmnt", T3."WTAmntSC",  T3."Category", T3."BaseType", T3."WTName"  -- Segunda retención
UNION ALL

/* nota de credito compra  */

SELECT 
    'NC COMPRA' AS "Tipo",
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
    T4."WTName",
    CASE 
       WHEN T4."Type" = 'I' THEN 'Retención de Impuesto sobre la Renta'
       WHEN T4."Type" = 'V' THEN 'Retención de IVA'
       ELSE ' '
    END AS "Tipo Retención 1",
    T4."Rate" AS "Tasa Retención 1",
    T4."TaxbleAmnt" AS "Impuesto sujeto a impuesto Retención 1",
    T4."TxblAmntSC" AS "Impuesto sujeto a impuesto MS Retención 1",
    T4."WTAmnt" AS "Importe Retención 1",
    T4."WTAmntSC" AS "Importe de retenciones de impuesto MS Retención 1",
    CASE 
       WHEN T4."Category" = 'I' THEN 'Factura'
       WHEN T4."Category" = 'P' THEN 'Pago'
       ELSE ' '
    END AS "Categoria 1",
    CASE 
       WHEN T4."BaseType" = 'G' THEN 'Bruto'
       WHEN T4."BaseType" = 'N' THEN 'Neto'
       WHEN T4."BaseType" = 'V' THEN 'Iva'
       ELSE ' '
    END AS "Importe Base 1",
    
    -- Segunda retención
    T5."WTCode" AS "Código Retención 2",
    T5."WTName",
    CASE 
       WHEN T5."Type" = 'I' THEN 'Retención de Impuesto sobre la Renta'
       WHEN T5."Type" = 'V' THEN 'Retención de IVA'
       ELSE ' '
    END AS "Tipo Retención 2",
    T5."Rate" AS "Tasa Retención 2",
    T5."TaxbleAmnt" AS "Impuesto sujeto a impuesto Retención 2",
    T5."TxblAmntSC" AS "Impuesto sujeto a impuesto MS Retención 2",
    T5."WTAmnt" AS "Importe Retención 2",
    T5."WTAmntSC" AS "Importe de retenciones de impuesto MS Retención 2",
    CASE 
       WHEN T5."Category" = 'I' THEN 'Factura'
       WHEN T5."Category" = 'P' THEN 'Pago'
       ELSE ' '
    END AS "Categoria 2",
    CASE 
       WHEN T5."BaseType" = 'G' THEN 'Bruto'
       WHEN T5."BaseType" = 'N' THEN 'Neto'
       WHEN T5."BaseType" = 'V' THEN 'Iva'
       ELSE ' '
    END AS "Importe Base 2"

FROM ORPC T0
INNER JOIN RPC1 T1 ON T0."DocEntry" = T1."DocEntry"

-- Primera retención
LEFT JOIN (
    SELECT 
        A0."AbsEntry",
        A0."WTCode",
        A0."Type",
        A0."Rate",
        A0."TaxbleAmnt",
        A0."TxblAmntSC",
        A0."WTAmnt",
        A0."WTAmntSC",
        A0."Category",
        A0."BaseType",
        A1."WTName",
        ROW_NUMBER() OVER (PARTITION BY A0."AbsEntry" ORDER BY A0."WTCode") AS "Retencion_Num"
    FROM PCH5 A0
    INNER JOIN OWHT A1 ON A0."WTCode" = A1."WTCode"
) T4 ON T0."DocEntry" = T4."AbsEntry" AND T4."Retencion_Num" = 1  -- Primera retención

-- Segunda retención
LEFT JOIN (
    SELECT 
        A0."AbsEntry",
        A0."WTCode",
        A0."Type",
        A0."Rate",
        A0."TaxbleAmnt",
        A0."TxblAmntSC",
        A0."WTAmnt",
        A0."WTAmntSC",
        A0."Category",
        A0."BaseType",
        A1."WTName",
        ROW_NUMBER() OVER (PARTITION BY A0."AbsEntry" ORDER BY A0."WTCode") AS "Retencion_Num"
    FROM PCH5 A0
    INNER JOIN OWHT A1 ON A0."WTCode" = A1."WTCode"
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
    T4."WTCode", T4."Type", T4."Rate", T4."TaxbleAmnt", T4."TxblAmntSC", T4."WTAmnt", T4."WTAmntSC", T4."Category", T4."BaseType", T4."WTName",  -- Primera retención
    T5."WTCode", T5."Type", T5."Rate", T5."TaxbleAmnt", T5."TxblAmntSC", T5."WTAmnt", T5."WTAmntSC", T5."Category", T5."BaseType", T5."WTName"  -- Segunda retención


/*
Aprobado Por El Economista Mauricio 13-11-2024 
 haciendo pruebas poner las retenciones ordenadas 
 con Compra y nota de credito */

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