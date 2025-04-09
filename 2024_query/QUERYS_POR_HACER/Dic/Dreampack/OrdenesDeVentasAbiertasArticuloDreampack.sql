-- Original
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

    DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) AS "FechaVencimiento + DiasExtras"


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
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');