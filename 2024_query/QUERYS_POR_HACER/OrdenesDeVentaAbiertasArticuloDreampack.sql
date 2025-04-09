-- original
SELECT 
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"

WHERE 
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');



-- pruebas
SELECT 
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",
    CASE 
        WHEN A0."TotalVencido" > 0 THEN 'Si'
        ELSE 'No'
    END AS "Saldo Vencido"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"
LEFT JOIN (
    /* Verifica si el cliente local tiene saldo vencido */
    SELECT 
        T0."CardCode",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencido"
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        -- AND DAYS_BETWEEN("DocDueDate", CURRENT_DATE) > 0  -- Solo facturas vencidas
        AND T1."GroupCode" <> 120 --Excluir los relacionados 
    GROUP BY T0."CardCode" 

) AS A0 ON A0."CardCode" = T0."CardCode"

WHERE 
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');



  
  /* prueba 2 */
  SELECT 
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",

    -- Límite de crédito
    COALESCE(T3."CreditLine", 0) AS "Límite de Crédito",

    -- Verificar si es cliente contado
    CASE 
        WHEN T3."GroupNum" = -1 THEN 'Sí'  -- -1 indica cliente contado
        ELSE 'No'
    END AS "Cliente Contado",

    -- Verificar saldo vencido para clientes locales
    CASE 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'
        ELSE 'No'
    END AS "Cliente Local con Saldo Vencido",

    -- Verificar saldo vencido para clientes exteriores a 90 días
    CASE 
        WHEN A1."TotalExteriorVencido" > 0 THEN 'Sí'
        ELSE 'No'
    END AS "Cliente Exterior con Saldo Vencido a 90 Días"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"

-- Subconsulta para saldo vencido de clientes locales
LEFT JOIN (
    SELECT 
        "CardCode",
        SUM("DocTotal" - "PaidToDate") AS "TotalVencido"
    FROM OINV
    WHERE 
        "DocStatus" = 'O'  -- Facturas abiertas
        AND DAYS_BETWEEN("DocDueDate", CURRENT_DATE) > 0  -- Solo facturas vencidas
    GROUP BY "CardCode"
) AS A0 ON A0."CardCode" = T0."CardCode"

-- Subconsulta para saldo vencido de clientes exteriores a 90 días
LEFT JOIN (
    SELECT 
        T0."CardCode",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalExteriorVencido"
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90  -- Solo facturas vencidas mayores a 90 días
        AND T1."U_SYP_TCONTRIB" = 99  -- Solo clientes exteriores
    GROUP BY T0."CardCode"
) AS A1 ON A1."CardCode" = T0."CardCode"

WHERE 
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');


/* Ordenes de venta abiertas articulos dreampack */
  /* PRUEBA 4 */
  SELECT 
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",

    COALESCE(A0."TotalVencido", 0)  AS "Saldo Vencido",
    COALESCE(T3."CreditLine", 0) AS "Límite de Crédito",

     CASE 
        WHEN (T3."GroupNum" = -1) THEN 'Sí'  -- Cliente contado
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  -- Cliente local con saldo vencido
        WHEN A1."TotalExteriorVencido" > 0 THEN 'Sí'  -- Cliente exterior con saldo vencido a más de 90 días
        WHEN (COALESCE(T3."CreditLine", 0) = 0 AND COALESCE(A0."TotalVencido", 0) = 0) THEN 'No' -- Límite y saldo en cero
        WHEN ((COALESCE(T3."CreditLine", 0) = 0 AND COALESCE(A0."TotalVencido", 0) > 0) OR (COALESCE(A0."TotalVencido", 0) > COALESCE(T3."CreditLine", 0))) THEN 'Sí' -- Excede límite de crédito
        ELSE 'No'
    END AS "Saldo Vencido",

    CASE 
        WHEN (T3."GroupNum" = -1) THEN 'Cliente Contado'  -- Cliente contado
        WHEN A0."TotalVencido" > 0 THEN 'Saldo Vencido'  -- Cliente local con saldo vencido
        WHEN A1."TotalExteriorVencido" > 0 THEN 'Saldo Vencido a más de 90 días - Cliente Exterior'  -- Cliente exterior con saldo vencido a más de 90 días
        WHEN COALESCE(T3."CreditLine", 0) < COALESCE(A0."TotalVencido", 0) THEN 'Excede Límite de Crédito' -- Excede límite de crédito
        ELSE ' ' 
   END AS "Estado del Cliente"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"

-- Subconsulta para saldo vencido de clientes locales
LEFT JOIN (
    SELECT 
        T0."CardCode",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencido"
    FROM OINV T0
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0  -- Solo facturas vencidas
    GROUP BY T0."CardCode"
) AS A0 ON A0."CardCode" = T0."CardCode"

-- Subconsulta para saldo vencido de clientes exteriores a 90 días
LEFT JOIN (
    SELECT 
        T0."CardCode",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalExteriorVencido"
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90  -- Solo facturas vencidas mayores a 90 días
        AND T1."U_SYP_TCONTRIB" = 99  -- Solo clientes exteriores
    GROUP BY T0."CardCode"
) AS A1 ON A1."CardCode" = T0."CardCode"

WHERE 
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');


  /* prueba 5 NO*/

SELECT 
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr" AS "Precio Unitario", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",

    COALESCE(A0."TotalVencido", 0) AS "Saldo Vencido",
    COALESCE(T3."CreditLine", 0) AS "Límite de Crédito",

   CASE 
        WHEN (T3."GroupNum" = -1) THEN 'Cliente Contado'  -- Cliente contado
        WHEN A0."TotalVencido" > 0 THEN 'Cliente Local con Saldo Vencido'  -- Cliente local con saldo vencido
        WHEN A1."TotalExteriorVencido" > 0 THEN 'Cliente Exterior con Saldo Vencido a más de 90 días'  -- Cliente exterior con saldo vencido a más de 90 días
        WHEN COALESCE(T3."CreditLine", 0) = 0 AND COALESCE(A0."TotalVencido", 0) = 0 THEN 'Sin Problemas' -- Límite y saldo en cero
        WHEN COALESCE(A0."TotalVencido", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede Límite de Crédito' -- Excede límite de crédito
        ELSE 'Sin Problemas'
   END AS "Estado del Cliente"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"

-- Subconsulta para saldo vencido de clientes locales
LEFT JOIN (
    SELECT 
        T0."CardCode",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencido"
    FROM OINV T0
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0  -- Solo facturas vencidas
    GROUP BY T0."CardCode"
) AS A0 ON A0."CardCode" = T0."CardCode"

-- Subconsulta para saldo vencido de clientes exteriores a 90 días
LEFT JOIN (
    SELECT 
        T0."CardCode",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalExteriorVencido"
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90  -- Solo facturas vencidas mayores a 90 días
        AND T1."U_SYP_TCONTRIB" = 99  -- Solo clientes exteriores
    GROUP BY T0."CardCode"
) AS A1 ON A1."CardCode" = T0."CardCode"

WHERE 
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758')

GROUP BY 
     T0."DocNum",
     T0."NumAtCard",
     T0."DocDate",
     T0."DocDueDate",
     T1."ShipDate",
     T0."CardName",
     T1."ItemCode",
     T1."Dscription",
     COALESCE(A0."TotalVencido", 0),
     COALESCE(T3."CreditLine", 0),
     A1."TotalExteriorVencido",
     (T3."GroupNum")
HAVING 
     (T3."GroupNum" = -1)                          -- Pago al contado
     OR (A1."TotalExteriorVencido" > 0)            -- Cliente exterior con saldo vencido > 90 días
     OR (COALESCE(A0."TotalVencido", 0) > COALESCE(T3."CreditLine", 0))           -- Excede límite de crédito
     OR (COALESCE(A0."TotalVencido", 0) > 0 AND DAYS_BETWEEN(MAX(T2."DocDueDate"), CURRENT_DATE) > 90); -- Factura abierta y vencida mayor a 90 días


     /* asi quedo por el momento solo falta que aprueben */
     SELECT 
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",

    COALESCE(A0."TotalVencido", 0)  AS "Saldo Vencido",
    COALESCE(T3."CreditLine", 0) AS "Límite de Crédito",

     CASE
        WHEN (T3."GroupCode" = 120) THEN ' '  -- Cliente Relacionado 
        WHEN (T3."GroupNum" = -1) THEN ' '  -- Cliente contado
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  -- Cliente local con saldo vencido
        WHEN A1."TotalExteriorVencido" > 0 THEN 'Sí'  -- Cliente exterior con saldo vencido a más de 90 días
        --WHEN (COALESCE(T3."CreditLine", 0) = 0 AND COALESCE(A0."TotalVencido", 0) = 0) THEN 'No' -- Límite y saldo en cero
        --WHEN ((COALESCE(T3."CreditLine", 0) = 0 AND COALESCE(A0."TotalVencido", 0) > 0) OR (COALESCE(A0."TotalVencido", 0) > COALESCE(T3."CreditLine", 0))) THEN 'Sí' -- Excede límite de crédito
        WHEN COALESCE(T3."CreditLine", 0) < COALESCE(A0."TotalVencido", 0) THEN 'Sí'  -- Excede límite de crédito
        ELSE 'No'
    END AS "Saldo Vencido",

    CASE
        WHEN (T3."GroupCode" = 120) THEN 'Cliente Relacionado '  -- Cliente Relacionado 
        WHEN (T3."GroupNum" = -1) THEN 'Cliente Contado'  -- Cliente contado
        WHEN A0."TotalVencido" > 0 THEN 'Saldo Vencido'  -- Cliente local con saldo vencido
        WHEN A1."TotalExteriorVencido" > 0 THEN 'Saldo Vencido a más de 90 días - Cliente Exterior'  -- Cliente exterior con saldo vencido a más de 90 días
        WHEN COALESCE(T3."CreditLine", 0) < COALESCE(A0."TotalVencido", 0) THEN 'Excede Límite de Crédito' -- Excede límite de crédito
        ELSE ' ' 
   END AS "Estado del Cliente"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"

-- Subconsulta para saldo vencido de clientes locales
LEFT JOIN (
    SELECT 
        T0."CardCode",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencido"
    FROM OINV T0
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0  -- Solo facturas vencidas
    GROUP BY T0."CardCode"
) AS A0 ON A0."CardCode" = T0."CardCode"

-- Subconsulta para saldo vencido de clientes exteriores a 90 días
LEFT JOIN (
    SELECT 
        T0."CardCode",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalExteriorVencido"
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90  -- Solo facturas vencidas mayores a 90 días
        AND T1."U_SYP_TCONTRIB" = 99  -- Solo clientes exteriores
    GROUP BY T0."CardCode"
) AS A1 ON A1."CardCode" = T0."CardCode"

WHERE 
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758'); 




  /* otro ejemplo para que aprueben */
  SELECT 
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    MAX(T1."Quantity" * T1."NumPerMsr") AS "Cantidad", 
    MAX(T1."OpenQty" * T1."NumPerMsr") AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    MAX(T1."Price" / T1."NumPerMsr") AS "Precio / NumPerMsr ", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",

    T3."Balance",
    A0."TotalVencido" AS "Saldo Vencido",
    T3."CreditLine",

   CASE 
        WHEN T6."GroupNum" = -1 THEN 'C de Contado'
        WHEN T3."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90 THEN 'C exterior con Saldo mayor 90 días'
        WHEN T3."Balance" > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'
        WHEN T3."Balance" > 0 AND DAYS_BETWEEN(MAX(A0."DocDueDate"), CURRENT_DATE) > 90 THEN 'C local con Saldo Vencido'
        ELSE 'Entrega Directa'
    END AS "Condición",
   
   CASE 
        WHEN (T6."GroupNum" = -1) THEN 'No'  -- Cliente contado no tiene saldo vencido
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(A0."DocDueDate"), CURRENT_DATE) > 90) THEN 'Sí'  -- Cliente exterior con saldo vencido
        WHEN (T3."Balance"  > T3."CreditLine") THEN 'Sí'  -- Excede límite de crédito
        --WHEN COALESCE(T3."CreditLine", 0) < COALESCE(A0."TotalVencido", 0) THEN 'Excede Límite de Crédito'
        WHEN (T3."Balance" > 0 AND DAYS_BETWEEN(MAX(A0."DocDueDate"), CURRENT_DATE) > 90) THEN 'Sí'  -- Cliente local con saldo vencido
        ELSE 'No'  -- No hay saldo vencido
   END AS "Estado de Saldo Vencido"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"
LEFT JOIN OCTG T6 ON T3."GroupNum" = T6."GroupNum"

-- Subconsulta para saldo vencido de clientes locales
LEFT JOIN (
    SELECT 
        T0."CardCode",
        MAX(T0."DocDueDate") AS "DocDueDate",
        T0."DocStatus",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencido"
    FROM OINV T0
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T0."DocDueDate" < CURRENT_DATE
    GROUP BY T0."CardCode", T0."DocStatus"
) AS A0 ON A0."CardCode" = T3."CardCode"

WHERE 
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758')
GROUP BY 
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."UomCode2",
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",
    T6."GroupNum",
    T3."U_SYP_TCONTRIB",
    T3."CreditLine",
    T3."Balance",
    A0."TotalVencido";



    /* pruebas modificada */
SELECT 
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",

    T3."Balance",
    COALESCE(A0."TotalVencido", 0) AS "Saldo Vencido",
    COALESCE(T3."CreditLine", 0) AS "Límite de Crédito",
    

   -- Condición
   CASE 
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  -- Cliente contado
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  -- Excede límite de crédito
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  -- Cliente local con saldo vencido
        ELSE ' ' 
   END AS "Condición",

   -- Saldo vencido
   CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  -- Cliente contado tiene saldo vencido
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  -- Cliente exterior con saldo vencido
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Sí'  -- Excede límite de crédito
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  -- Cliente local con saldo vencido
        
        ELSE 'No' 
   END AS "Saldo Vencido"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"

-- Subconsulta para saldo vencido de clientes locales
LEFT JOIN (
    SELECT 
        "CardCode",
        SUM("DocTotal" - "PaidToDate") AS "TotalVencido"
    FROM OINV
    WHERE 
        "DocStatus" = 'O'  -- Facturas abiertas
        AND "DocDueDate" < CURRENT_DATE  -- Solo documentos vencidos
    GROUP BY "CardCode"
) AS A0 ON A0."CardCode" = T3."CardCode"

-- Subconsulta para saldo vencido de clientes exteriores a 90 días
LEFT JOIN (
    SELECT 
        T0."CardCode",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalExteriorVencido"
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90  -- Solo facturas vencidas mayores a 90 días
        AND T1."U_SYP_TCONTRIB" = 99  -- Solo clientes exteriores
    GROUP BY T0."CardCode"
) AS A1 ON A1."CardCode" = T0."CardCode"

WHERE 
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');



/* asi quedo esta es la final */
SELECT 
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",

    T3."Balance",
    COALESCE(A0."TotalVencido", 0) AS "Saldo Vencido",
    COALESCE(T3."CreditLine", 0) AS "Límite de Crédito",
    

   -- Condición
   CASE 
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  -- Cliente contado
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'  -- Excede límite de crédito y tiene saldo vencido
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  -- Excede límite de crédito
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  -- Cliente local con saldo vencido
        ELSE ' ' 
   END AS "Condición",

   -- Saldo vencido
   CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  -- Cliente contado tiene saldo vencido
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  -- Cliente exterior con saldo vencido
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' -- Excede límite de crédito y tiene saldo vencido
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  -- Cliente local con saldo vencido
        ELSE 'No' 
   END AS "Saldo Vencido"

   /*-- Condición
   CASE 
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  -- Cliente contado
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  -- Excede límite de crédito
        --WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'  -- Excede límite de crédito y tiene saldo vencido
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  -- Cliente local con saldo vencido
        ELSE ' ' 
   END AS "Condición",

   -- Saldo vencido
   CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Si'  -- Cliente contado tiene saldo vencido
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Si'  -- Cliente exterior con saldo vencido
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Si'  -- Excede límite de crédito
        --WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Si'  -- Excede límite de crédito y tiene saldo vencido
        WHEN A0."TotalVencido" > 0 THEN 'Si'  -- Cliente local con saldo vencido
        ELSE 'No' 
   END AS "Saldo Vencido"*/

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"

-- Subconsulta para saldo vencido de clientes locales
LEFT JOIN (
    SELECT 
        "CardCode",
        SUM("DocTotal" - "PaidToDate") AS "TotalVencido"
    FROM OINV
    WHERE 
        "DocStatus" = 'O'  -- Facturas abiertas
        AND "DocDueDate" < CURRENT_DATE  -- Solo documentos vencidos
    GROUP BY "CardCode"
) AS A0 ON A0."CardCode" = T3."CardCode"

-- Subconsulta para saldo vencido de clientes exteriores a 90 días
LEFT JOIN (
    SELECT 
        T0."CardCode",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalExteriorVencido"
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90  -- Solo facturas vencidas mayores a 90 días
        AND T1."U_SYP_TCONTRIB" = 99  -- Solo clientes exteriores
    GROUP BY T0."CardCode"
) AS A1 ON A1."CardCode" = T0."CardCode"

WHERE 
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');


  /* original 02-12-2024 */
  SELECT 
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",

    --T3."Balance",
    --COALESCE(A0."TotalVencido", 0) AS "Saldo Vencido",
    --COALESCE(T3."CreditLine", 0) AS "Límite de Crédito",
    

   -- Condición
   CASE 
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  -- Cliente contado
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'  -- Excede límite de crédito y tiene saldo vencido
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  -- Excede límite de crédito
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  -- Cliente local con saldo vencido
        ELSE ' ' 
   END AS "Condición",

   -- Saldo vencido
   CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  -- Cliente contado tiene saldo vencido
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  -- Cliente exterior con saldo vencido
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' -- Excede límite de crédito y tiene saldo vencido
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  -- Cliente local con saldo vencido
        ELSE 'No' 
   END AS "Saldo Vencido"


FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"

-- Subconsulta para saldo vencido de clientes locales
LEFT JOIN (
    SELECT 
        "CardCode",
        SUM("DocTotal" - "PaidToDate") AS "TotalVencido"
    FROM OINV
    WHERE 
        "DocStatus" = 'O'  -- Facturas abiertas
        AND "DocDueDate" < CURRENT_DATE  -- Solo documentos vencidos
    GROUP BY "CardCode"
) AS A0 ON A0."CardCode" = T3."CardCode"

-- Subconsulta para saldo vencido de clientes exteriores a 90 días
LEFT JOIN (
    SELECT 
        T0."CardCode",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalExteriorVencido"
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90  -- Solo facturas vencidas mayores a 90 días
        AND T1."U_SYP_TCONTRIB" = 99  -- Solo clientes exteriores
    GROUP BY T0."CardCode"
) AS A1 ON A1."CardCode" = T0."CardCode"

WHERE 
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');



--   ***************************************************
--ordenes de venta abierta, fecha de entrega del día actual más 7 días a futuro 
SELECT 
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",

   -- Condición
   CASE 
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  -- Cliente contado
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'  -- Excede límite de crédito y tiene saldo vencido
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  -- Excede límite de crédito
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  -- Cliente local con saldo vencido
        ELSE ' ' 
   END AS "Condición",

   -- Saldo vencido
   CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  -- Cliente contado tiene saldo vencido
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  -- Cliente exterior con saldo vencido
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' -- Excede límite de crédito y tiene saldo vencido
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  -- Cliente local con saldo vencido
        ELSE 'No' 
   END AS "Saldo Vencido"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"

-- Subconsulta para saldo vencido de clientes locales
LEFT JOIN (
    SELECT 
        "CardCode",
        SUM("DocTotal" - "PaidToDate") AS "TotalVencido"
    FROM OINV
    WHERE 
        "DocStatus" = 'O'  
        AND "DocDueDate" < CURRENT_DATE  
    GROUP BY "CardCode"
) AS A0 ON A0."CardCode" = T3."CardCode"

-- Subconsulta para saldo vencido de clientes exteriores a 90 días
LEFT JOIN (
    SELECT 
        T0."CardCode",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalExteriorVencido"
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90  
        AND T1."U_SYP_TCONTRIB" = 99  
    GROUP BY T0."CardCode"
) AS A1 ON A1."CardCode" = T0."CardCode"

WHERE 
    T1."LineStatus" = 'O' 
    AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
     AND (T1."ShipDate" BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7)) -- Filtra por fecha de entrega en los próximos 7 días
    --AND (T1."ShipDate" BETWEEN CURRENT_DATE AND DATEADD(DAY, 7, CURRENT_DATE)) -- Filtra por fecha de entrega en los próximos 7 días
    AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');



    /* una subconsulta de los saldos vencidos y solo añadir lo que no tiene saldo vencido  */

SELECT
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"

WHERE 
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758')
  AND (T1."ShipDate" BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7)) -- Filtra por fecha de entrega en los próximos 7 días
  AND (
    SELECT COALESCE(SUM(TI."DocTotal") - SUM(TI."PaidToDate"), 0)
    FROM OINV TI
    WHERE TI."CardCode" = T0."CardCode"
    AND TI."DocStatus" = 'O' -- Solo facturas abiertas
    AND TI."DocDueDate" < CURRENT_DATE
    ) = 0; -- Solo documentos vencidos
  
  
/* trabajando 11-12-2024 */
SELECT
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate",
    T0."CardCode", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",

    -- Condición
    CASE 
        WHEN T3."GroupCode" = '120' AND T3."GroupNum" = -1 THEN 'C Relacionado de contado' 
        WHEN T3."GroupNum" = -1 THEN 'C de contado' 
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
        ELSE ' ' 
    END AS "Condición",

    -- Saldo vencido
    CASE
        WHEN T3."GroupCode" = '120' AND T3."GroupNum" = -1  AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE 'No' 
    END AS "Saldo Vencido",

    -- Saldo Vencido + Días de Gracia
    CASE 
       WHEN T3."GroupCode" = '120' THEN 'No'  -- Si es un cliente relacionado, mostrar "No"
       WHEN COALESCE(A2."TotalVencidoDG", 0) > 0 
         AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) > 0 THEN 'Sí'
       WHEN COALESCE(A2."TotalVencidoDG", 0) > 0 THEN 'No'  -- Si hay saldo vencido pero no es relacionado
       ELSE 'No'
    END AS "Saldo Vencido + Días de Gracia",

    A2."FechaVencimiento",
    A2."DiaExtras",

    -- Cálculo de días vencidos más días de gracia
    DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) AS "FechaVencimiento + DiasExtras",

    A2."TotalVencidoDG"
  
FROM ORDR T0 --pedido del cliente
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" --pedido de cliente fila 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" --Pedido de cliente - Ampliación de plazo de pago de impuesto
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode" --Socio de negocio
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode" --Empleado del departamento de ventas
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode" --Item o Articulos

-- Subconsulta para saldo vencido de clientes locales
LEFT JOIN (
    SELECT 
        "CardCode",
        SUM("DocTotal" - "PaidToDate") AS "TotalVencido"
    FROM OINV
    WHERE 
        "DocStatus" = 'O'  
        AND "DocDueDate" < CURRENT_DATE  
    GROUP BY "CardCode"
) AS A0 ON A0."CardCode" = T3."CardCode"

-- Subconsulta para saldo vencido de clientes exteriores a 90 días
LEFT JOIN (
    SELECT 
        T0."CardCode",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalExteriorVencido"
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90  
        AND T1."U_SYP_TCONTRIB" = 99  
    GROUP BY T0."CardCode"
) AS A1 ON A1."CardCode" = T3."CardCode"

-- Subconsulta para obtener los días de gracia
LEFT JOIN (
  SELECT    
      T0."CardCode",
      MIN(T0."DocDueDate") AS "FechaVencimiento",
      SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencidoDG",
      MAX(T0."ExtraDays") as "DiaExtras"--,
      --MAX(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"
  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
  WHERE 
      T0."DocStatus" = 'O'
      AND T0."DocDueDate" < CURRENT_DATE
   GROUP BY T0."CardCode"
) AS A2 ON A2."CardCode" = T3."CardCode"

WHERE 
  --T3."CardCode" = 'C0992991178001' AND
  --T3."GroupCode" = '120' AND
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');



/* MODIFICANDO */

SELECT
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate",
    T0."CardCode", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",

    -- Condición
    CASE 
        WHEN T3."GroupCode" = '120' AND T3."GroupNum" = -1 THEN 'C Relacionado de contado' 
        WHEN T3."GroupNum" = -1 THEN 'C de contado' 
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
        ELSE ' ' 
    END AS "Condición",

    -- Saldo vencido
    CASE
        WHEN T3."GroupCode" = '120' AND T3."GroupNum" = -1  AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE 'No' 
    END AS "Saldo Vencido",

   /* -- Saldo Vencido + Días de Gracia
    CASE 
       WHEN T3."GroupCode" = '120' THEN 'No'  -- Si es un cliente relacionado, mostrar "No"
       WHEN COALESCE(A2."TotalVencidoDG", 0) > 0 
         AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) > 0 THEN 'Sí'
       --WHEN COALESCE(A2."TotalVencidoDG", 0) > 0 THEN 'No'  -- Si hay saldo vencido pero no es relacionado
       ELSE 'No'
    END AS "Saldo Vencido + Días de Gracia",

*/


/*-- Saldo Vencido + Días de Gracia
CASE 
    WHEN T3."GroupCode" = '120' THEN 
        -- Si es un cliente relacionado
        CASE 
            WHEN DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) > 0 THEN 'Sí'
            ELSE 'No'
        END
    WHEN COALESCE(A2."TotalVencidoDG", 0) > 0 THEN 
        -- Si es un cliente local con saldo vencido
        CASE 
            WHEN DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) > 0 THEN 'Sí'
            ELSE 'No'
        END
    ELSE 'No'
END AS "Saldo Vencido + Días de Gracia", */


/*-- Saldo Vencido + Días de Gracia
CASE 
    WHEN T3."GroupCode" = '120' THEN 'No'  -- Si es un cliente relacionado, mostrar "No"
    WHEN COALESCE(A2."TotalVencidoDG", 0) > 0 THEN 
        -- Si es un cliente local con saldo vencido
        CASE 
            WHEN DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) > 0 THEN 'Sí'
            ELSE 'No'
        END
    ELSE 'Noooo'
END AS "Saldo Vencido + Días de Gracia",*/

-- Saldo Vencido + Días de Gracia
CASE 
    WHEN T3."GroupCode" = '120' THEN 'No'  -- Si es un cliente relacionado, mostrar "No"

    WHEN T3."U_SYP_TCONTRIB" = 99 AND  THEN  -- Si es un cliente exterior
        CASE 
            WHEN T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0 
                AND (DAYS_BETWEEN(A1."FechaVencimientoExterior", CURRENT_DATE) + COALESCE(A1."DiaExtrasExterior", 0)) > 0 THEN 'Sí A 90 DIAS'
             
            ELSE 'No EXTE'
        END
    /*WHEN COALESCE(A2."TotalVencidoDG", 0) > 0 THEN 
        -- Si es un cliente local con saldo vencido
        CASE 
            WHEN DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) > 0 THEN 'Sí'
            ELSE 'No'
        END */
    ELSE 'No' 
END AS "Saldo Vencido + Días de Gracia",




    A2."FechaVencimiento",
    A2."DiaExtras",

    -- Cálculo de días vencidos más días de gracia
    DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) AS "FechaVencimiento + DiasExtras",

 DAYS_BETWEEN(A1."FechaVencimientoExterior", CURRENT_DATE) - COALESCE(A1."DiaExtrasExterior", 0) AS "FechaVencimiento + DiasExtras SOLO EXTERIOR",

    A2."TotalVencidoDG",
   A1."TotalExteriorVencido"
  
FROM ORDR T0 --pedido del cliente
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" --pedido de cliente fila 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" --Pedido de cliente - Ampliación de plazo de pago de impuesto
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode" --Socio de negocio
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode" --Empleado del departamento de ventas
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode" --Item o Articulos

-- Subconsulta para saldo vencido de clientes locales
LEFT JOIN (
    SELECT 
        "CardCode",
        SUM("DocTotal" - "PaidToDate") AS "TotalVencido"
    FROM OINV
    WHERE 
        "DocStatus" = 'O'  
        AND "DocDueDate" < CURRENT_DATE  
    GROUP BY "CardCode"
) AS A0 ON A0."CardCode" = T3."CardCode"

-- Subconsulta para saldo vencido de clientes exteriores a 90 días
LEFT JOIN (
    SELECT 
        T0."CardCode",
        MIN(T0."DocDueDate") AS "FechaVencimientoExterior",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalExteriorVencido",
        MAX(T0."ExtraDays") as "DiaExtrasExterior"
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90  
        AND T1."U_SYP_TCONTRIB" = 99  
    GROUP BY T0."CardCode"
) AS A1 ON A1."CardCode" = T3."CardCode"

-- Subconsulta para obtener los días de gracia
LEFT JOIN (
  SELECT    
      T0."CardCode",
      MIN(T0."DocDueDate") AS "FechaVencimiento",
      SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencidoDG",
      MAX(T0."ExtraDays") as "DiaExtras"--,
      --MAX(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"
  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
  WHERE 
      T0."DocStatus" = 'O'
      AND T0."DocDueDate" < CURRENT_DATE
   GROUP BY T0."CardCode"
) AS A2 ON A2."CardCode" = T3."CardCode"

WHERE 
  --T3."CardCode" = 'C0992991178001' AND
  --T3."GroupCode" = '120' AND
  T3."U_SYP_TCONTRIB" = 99 AND
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');



  /* ************ */

  /*WHEN T3."U_SYP_TCONTRIB" = 99 THEN  -- Si es un cliente exterior
        CASE 
            WHEN T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0 
                AND (DAYS_BETWEEN(A1."FechaVencimientoExterior", CURRENT_DATE) + COALESCE(A1."DiaExtrasExterior", 0)) > 0 THEN 'Sí'
        ELSE 'No cliente exterior'
     END

    WHEN COALESCE(A0."TotalVencido", 0) > 0 THEN -- Si es un cliente local
        -- Si es un cliente local con saldo vencido
        CASE 
            WHEN A0."TotalVencido" > 0 THEN 'Sí'
        ELSE 'No cliente local'
    END */


    /* MÑN HACER PRUEBAS  */

SELECT
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate",
    T0."CardCode", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",

    -- Condición
    CASE 
        WHEN T3."GroupCode" = '120' AND T3."GroupNum" = -1 THEN 'C Relacionado de contado' 
        WHEN T3."GroupNum" = -1 THEN 'C de contado' 
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
        ELSE ' ' 
    END AS "Condición",

    -- Saldo vencido
    CASE
        WHEN T3."GroupCode" = '120' AND T3."GroupNum" = -1  AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE 'No' 
    END AS "Saldo Vencido",

    -- Saldo Vencido + Días de Gracia
    CASE 
        WHEN T3."GroupCode" = '120' THEN 'No SOLO RELACIONADO'  -- Si es un cliente relacionado, mostrar "No"

    WHEN  COALESCE(A2."TotalVencidoDG", 0)  > 0 AND 
        DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) > 0 THEN 'Si'

    WHEN  COALESCE(A2."TotalVencidoDG", 0)  > 0 AND 
        DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) < 0 THEN 'No'

    WHEN  COALESCE(A2."TotalVencidoDG", 0)  = 0 AND 
        DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) = 0 THEN 'No'


        ELSE '*****'
    END AS "Saldo Vencido + Días de Gracia",

    A2."FechaVencimiento",
    A2."DiaExtras",

    -- Cálculo de días vencidos más días de gracia
    DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) AS "FechaVencimiento + DiasExtras",

    --DAYS_BETWEEN(A1."FechaVencimientoExterior", CURRENT_DATE) - COALESCE(A1."DiaExtrasExterior", 0) AS "FechaVencimiento + DiasExtras SOLO EXTERIOR",

    A2."TotalVencidoDG" --,
   --A1."TotalExteriorVencido"
  
FROM ORDR T0 --pedido del cliente
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" --pedido de cliente fila 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" --Pedido de cliente - Ampliación de plazo de pago de impuesto
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode" --Socio de negocio
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode" --Empleado del departamento de ventas
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode" --Item o Articulos

-- Subconsulta para saldo vencido de clientes locales
LEFT JOIN (
    SELECT 
        "CardCode",
        SUM("DocTotal" - "PaidToDate") AS "TotalVencido"
    FROM OINV
    WHERE 
        "DocStatus" = 'O'  
        AND "DocDueDate" < CURRENT_DATE  
    GROUP BY "CardCode"
) AS A0 ON A0."CardCode" = T3."CardCode"

-- Subconsulta para saldo vencido de clientes exteriores a 90 días
LEFT JOIN (
    SELECT 
        T0."CardCode",
        MIN(T0."DocDueDate") AS "FechaVencimientoExterior",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalExteriorVencido",
        MAX(T0."ExtraDays") as "DiaExtrasExterior"
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90  
        AND T1."U_SYP_TCONTRIB" = 99  
    GROUP BY T0."CardCode"
) AS A1 ON A1."CardCode" = T3."CardCode"

-- Subconsulta para obtener los días de gracia
LEFT JOIN (
  SELECT    
      T0."CardCode",
      MIN(T0."DocDueDate") AS "FechaVencimiento",
      SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencidoDG",
      MAX(T0."ExtraDays") as "DiaExtras"--,
      --MAX(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"
  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
  WHERE 
      T0."DocStatus" = 'O'
      AND T0."DocDueDate" < CURRENT_DATE
   GROUP BY T0."CardCode"
) AS A2 ON A2."CardCode" = T3."CardCode"

WHERE 
  --T3."CardCode" = 'C0992991178001' AND
  --T3."GroupCode" = '120' AND  --RELACIONADOS
  --T3."U_SYP_TCONTRIB" = 99 AND  --EXTERIOR
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');


/* PERFECTO APROBADO POR MI JEFE Y XIOMARA 12-12-2024 */
SELECT
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate",
    T0."CardCode", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    T1."UomCode2" AS "Unidad",
    T1."Price" / T1."NumPerMsr", 
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",

    -- Condición
    CASE 
        WHEN T3."GroupCode" = '120' AND T3."GroupNum" = -1 THEN 'C Relacionado de contado' 
        WHEN T3."GroupNum" = -1 THEN 'C de contado' 
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
        ELSE ' ' 
    END AS "Condición",

    -- Saldo vencido
    CASE
        WHEN T3."GroupCode" = '120' AND T3."GroupNum" = -1  AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE 'No' 
    END AS "Saldo Vencido",

    -- Saldo Vencido + Días de Gracia
    CASE 
        WHEN T3."GroupCode" = '120' THEN 'No'  -- Si es un cliente relacionado, mostrar "No"

        WHEN  COALESCE(A2."TotalVencidoDG", 0)  > 0 AND 
            DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) > 0 THEN 'Si'

        WHEN  COALESCE(A2."TotalVencidoDG", 0)  > 0 AND 
            DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) < 0 THEN 'No'

        WHEN  COALESCE(A2."TotalVencidoDG", 0)  = 0 AND 
            DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) = 0 THEN 'No'

        ELSE 'No'
    END AS "Saldo Vencido + Días de Gracia",

    --A2."FechaVencimiento",
    --A2."DiaExtras",
    --A2."DiasTolerancia",

    -- Cálculo de días vencidos más días de gracia
    --DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) AS "FechaVencimiento + DiasExtras",

    --DAYS_BETWEEN(A1."FechaVencimientoExterior", CURRENT_DATE) - COALESCE(A1."DiaExtrasExterior", 0) AS "FechaVencimiento + DiasExtras SOLO EXTERIOR",

    --A2."TotalVencidoDG" --,
   --A1."TotalExteriorVencido"
  
FROM ORDR T0 --pedido del cliente
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" --pedido de cliente fila 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" --Pedido de cliente - Ampliación de plazo de pago de impuesto
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode" --Socio de negocio
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode" --Empleado del departamento de ventas
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode" --Item o Articulos

-- Subconsulta para saldo vencido de clientes locales
LEFT JOIN (
    SELECT 
        "CardCode",
        SUM("DocTotal" - "PaidToDate") AS "TotalVencido"
    FROM OINV
    WHERE 
        "DocStatus" = 'O'  
        AND "DocDueDate" < CURRENT_DATE  
    GROUP BY "CardCode"
) AS A0 ON A0."CardCode" = T3."CardCode"

-- Subconsulta para saldo vencido de clientes exteriores a 90 días
LEFT JOIN (
    SELECT 
        T0."CardCode",
        MIN(T0."DocDueDate") AS "FechaVencimientoExterior",
        SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalExteriorVencido",
        MAX(T0."ExtraDays") as "DiaExtrasExterior"
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90  
        AND T1."U_SYP_TCONTRIB" = 99  
    GROUP BY T0."CardCode"
) AS A1 ON A1."CardCode" = T3."CardCode"

-- Subconsulta para obtener los días de gracia
LEFT JOIN (
  SELECT DISTINCT    
      T0."CardCode",
      MIN(T0."DocDueDate") AS "FechaVencimiento",
      SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencidoDG",
      --MAX(T0."ExtraDays") as "DiaExtras"--,
      COALESCE(T2."TolDays", 0) AS "DiasTolerancia"
  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T1."GroupNum" = T2."GroupNum"
  WHERE 
      T0."DocStatus" = 'O'
      AND T0."DocDueDate" < CURRENT_DATE
   GROUP BY T0."CardCode", T2."TolDays"
) AS A2 ON A2."CardCode" = T3."CardCode"

WHERE 
  --T3."CardCode" = 'C0992991178001' AND
  --T3."GroupCode" = '120' AND  --RELACIONADOS
  --T3."U_SYP_TCONTRIB" = 99 AND  --EXTERIOR
 -- (T1."ShipDate" BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7)) AND
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');