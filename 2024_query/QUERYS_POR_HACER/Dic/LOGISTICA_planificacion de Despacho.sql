-- Subconsulta para obtener los códigos de cliente con días de vencimiento negativos
WITH ClientesConDiasVencimientoNegativo AS (
    SELECT DISTINCT 
        T0."CardCode"
    FROM OINV T0
    INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
    INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
    INNER JOIN OSLP T1 ON T3."SlpCode" = T1."SlpCode"
    WHERE 
        T0."DocStatus" = 'O' 
        AND T3."CardType" = 'C'
        AND T3."GroupCode" <> 120
        AND T0."DocDueDate" < CURRENT_DATE
        AND (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0
)

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
    T1."Price" / T1."NumPerMsr" AS "Precio Unitario", 
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
    T0."CardCode" = 'C1791411099001' AND
    T1."LineStatus" = 'O' 
    AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
    AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758')
    AND T0."CardCode" IN (SELECT "CardCode" FROM ClientesConDiasVencimientoNegativo) -- Filtrar los clientes con días de vencimiento negativos
    AND (T1."ShipDate" BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7)) -- Filtrar por fecha de entrega en los próximos 7 días


/* QUERY ORIGINAL  
    Ordenes de venta abiertas articulos dreampack
*/
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

/* 
Estado de cuenta clientes vencidos - con ejecutivos
*/

SELECT     
    --T0."DocEntry",    
    T1."SlpName" AS "Ejecutivo Asignado",    
    T0."CardCode" AS "Codigo Cliente",    
    T0."CardName" AS "Nombre Cliente",    
    CASE 
        WHEN T0."DocType" = 'I' THEN 'Fact. de Artículo'         
        WHEN T0."DocType" = 'S' THEN 'Fact de Servicio'         
        ELSE ' '     
    END AS "Tipo de Documento",    
    T0."DocNum" AS "# Documento",    
    T0."DocDate" AS "Fecha de Emisión de Documento",      
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Vencimiento",     
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",    
    T0."DocCur",    
    SUM(CASE WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE THEN T0."DocTotal" - T0."PaidToDate"        ELSE 0     END) AS "Saldo Vencido"
FROM OINV T0
INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"  -- Información del socio de negocio
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"  -- Condiciones de pago - definiciones
INNER JOIN OSLP T1 ON T3."SlpCode" = T1."SlpCode"  -- Información del ejecutivo asignado
WHERE     
    T0."DocStatus" = 'O'    AND T3."CardType" = 'C'  -- Solo clientes    
    AND T3."GroupCode" <> 120  -- Excluir los relacionados   
    AND T0."DocDueDate" < CURRENT_DATE  
GROUP BY     
--T0."DocEntry",    
T1."SlpName", T0."CardCode", T0."CardName", T0."DocType", T0."DocNum", T0."DocDate", T2."TolDays", T0."DocCur", T0."DocDueDate";



/* union de dos querys */
/* QUERY UNIDA: Ordenes de venta abiertas articulos dreampack con información de facturas */

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
    
    -- Información de la tabla OINV
    COALESCE(T6."SlpName", 'No Asignado') AS "Ejecutivo Asignado",
    COALESCE(T6."Codigo Cliente", 'No Disponible') AS "Codigo Cliente",
    COALESCE(T6."Nombre Cliente", 'No Disponible') AS "Nombre Cliente",
    COALESCE(T6."Tipo de Documento", 'No Disponible') AS "Tipo de Documento",
    COALESCE(T6."# Documento", 'No Disponible') AS "# Documento",
    COALESCE(T6."Fecha de Emisión de Documento", CURRENT_DATE) AS "Fecha de Emisión de Documento",
    COALESCE(T6."Días de Vencimiento", 0) AS "Días de Vencimiento",
    COALESCE(T6."Dias de Vencimiento (inc. Dias Tolerancia)", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",
    COALESCE(T6."DocCur", 'No Disponible') AS "DocCur",
    COALESCE(T6."Saldo Vencido", 0) AS "Saldo Vencido"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"

LEFT JOIN (
    SELECT     
        --T0."DocEntry",    
        T1."SlpName",    
        T0."CardCode",    
        T0."CardName",    
        CASE 
            WHEN T0."DocType" = 'I' THEN 'Fact. de Artículo'         
            WHEN T0."DocType" = 'S' THEN 'Fact. de Servicio'         
            ELSE ' '     
        END AS "Tipo de Documento",    
        T0."DocNum",    
        T0."DocDate",      
        DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Vencimiento",     
        DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",    
        T0."DocCur",    
        SUM(CASE WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE THEN (T0."DocTotal" - T0."PaidToDate") ELSE 0 END) AS "Saldo Vencido"
    FROM OINV T0
    INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
    INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
    INNER JOIN OSLP T1 ON T3."SlpCode" = T1."SlpCode"
    WHERE     
        T0."DocStatus" = 'O' AND 
        T3."CardType" = 'C' AND  
        T3."GroupCode" <> 120 AND  
        T0."DocDueDate" < CURRENT_DATE  
    GROUP BY     
        --T0."DocEntry",    
        T1."SlpName", 
        T0."CardCode", 
        T0."CardName", 
        T0."DocType",
        T0."DocNum", 
        T0."DocDate", 
        T2."TolDays", 
        T0."DocCur";  
) AS T6 ON (T0."CardCode" = COALESCE(T6."CardCode", '') 
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0) < 0
    )

WHERE 
  (T1."LineStatus" = 'O') AND
  (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW')) AND
  (T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758'));


  /* ******** */
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
    T5."U_LAB_SIS_FABRIC" --,
    
   /* -- Información de la tabla OINV
    COALESCE(T6."SlpName", 'No Asignado') AS "Ejecutivo Asignado",
    COALESCE(T6."Codigo Cliente", 'No Disponible') AS "Codigo Cliente",
    COALESCE(T6."Nombre Cliente", 'No Disponible') AS "Nombre Cliente",
    COALESCE(T6."Tipo de Documento", 'No Disponible') AS "Tipo de Documento",
    COALESCE(T6."# Documento", 'No Disponible') AS "# Documento",
    COALESCE(T6."Fecha de Emisión de Documento", CURRENT_DATE) AS "Fecha de Emisión de Documento",
    COALESCE(T6."Días de Vencimiento", 0) AS "Días de Vencimiento",
    COALESCE(T6."Dias de Vencimiento (inc. Dias Tolerancia)", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",
    COALESCE(T6."DocCur", 'No Disponible') AS "DocCur",
    COALESCE(T6."Saldo Vencido", 0) AS "Saldo Vencido"*/

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"

LEFT JOIN (
    SELECT     
        --T0."DocEntry",    
        T1."SlpName",    
        T0."CardCode",    
        T0."CardName",    
        CASE 
            WHEN T0."DocType" = 'I' THEN 'Fact. de Artículo'         
            WHEN T0."DocType" = 'S' THEN 'Fact. de Servicio'         
            ELSE ' '     
        END AS "Tipo de Documento",    
        T0."DocNum",    
        T0."DocDate",      
        DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Vencimiento",     
        DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",    
        T0."DocCur",    
        SUM(CASE WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE THEN (T0."DocTotal" - T0."PaidToDate") ELSE 0 END) AS "Saldo Vencido"
    FROM OINV T0
    INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
    INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
    INNER JOIN OSLP T1 ON T3."SlpCode" = T1."SlpCode"
    WHERE     
        T0."DocStatus" = 'O' AND 
        T3."CardType" = 'C' AND  
        T3."GroupCode" <> 120 AND  
        T0."DocDueDate" < CURRENT_DATE  
    GROUP BY     
        --T0."DocEntry",    
        T1."SlpName", 
        T0."CardCode", 
        T0."CardName", 
        T0."DocType",
        T0."DocNum", 
        T0."DocDate", 
        T2."TolDays", 
        T0."DocCur",
        T0."DocDueDate" 
) AS T6 ON (
            T0."CardCode" = T6."CardCode" 
            AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T6."TolDays", 0) < 0
        )

WHERE 
  (T1."LineStatus" = 'O') AND
  (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW')) AND
  (T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758'));



/* prueba 1 */
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

INNER JOIN (
    SELECT     
        --T0."DocEntry",    
        T1."SlpName",    
        T0."CardCode",    
        T0."CardName",    
        CASE 
            WHEN T0."DocType" = 'I' THEN 'Fact. de Artículo'         
            WHEN T0."DocType" = 'S' THEN 'Fact. de Servicio'         
            ELSE ' '     
        END AS "Tipo de Documento",    
        T0."DocNum",    
        T0."DocDate", 
        T2."TolDays",     
        DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Vencimiento",     
        DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",    
        T0."DocCur",    
        SUM(CASE WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE THEN (T0."DocTotal" - T0."PaidToDate") ELSE 0 END) AS "Saldo Vencido"
    FROM OINV T0
    INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
    INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
    INNER JOIN OSLP T1 ON T3."SlpCode" = T1."SlpCode"
    WHERE     
        T0."DocStatus" = 'O' AND 
        T3."CardType" = 'C' AND  
        T3."GroupCode" <> 120 AND  
        T0."DocDueDate" < CURRENT_DATE  
    GROUP BY     
        --T0."DocEntry",    
        T1."SlpName", 
        T0."CardCode", 
        T0."CardName", 
        T0."DocType",
        T0."DocNum", 
        T0."DocDate", 
        T2."TolDays", 
        T0."DocCur",
        T0."DocDueDate" 
) AS T6 ON (
            T0."CardCode" = T6."CardCode" 
            AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T6."TolDays", 0) < 0
        )
WHERE 
  (T1."LineStatus" = 'O') AND
  (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW')) AND
  (T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758'))
   AND (T1."ShipDate" BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7)) -- Filtrar por fecha de entrega en los próximos 7 días;


/* opcion 2 */
/* QUERY UNIDA: Ordenes de venta abiertas con información de facturas */
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

    
    COALESCE(T6."Saldo Vencido", 0) AS "Saldo Vencido"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"


LEFT JOIN (
    SELECT     
        T0."CardCode",    
        SUM(CASE WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE THEN (T0."DocTotal" - T0."PaidToDate") ELSE 0 END) AS "Saldo Vencido"
        
    FROM OINV T0
    INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
    INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
    
    WHERE     
        -- Filtrar solo documentos abiertos y clientes válidos
        T0."DocStatus" = 'O' AND 
        T3."CardType" = 'C' AND  
        -- Solo incluir aquellos con días vencidos negativos
        (DAYS_BETWEEN(T0.DocDueDate, CURRENT_DATE) - COALESCE(T2.TolDays, 0)) < 0
        
    GROUP BY     
        -- Agrupar por el código del cliente
        T0.CardCode
) AS T6 ON (
            -- Condición para el LEFT JOIN
            (T3.CardCode = COALESCE(T6.CardCode, '') OR (T6.CardCode IS NULL))
)

WHERE 
  -- Condiciones originales
  (T1.LineStatus = 'O') AND
  (T1.WhsCode IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW')) AND
  (T0.DocNum NOT IN ('22001723', '22001745', '22001747', '22001758')) AND
  (T1.ShipDate BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7)); -- Filtrar por fecha de entrega en los próximos 7 días


  /* opcion 3 */
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

   
    COALESCE(T6."Saldo Vencido", 0) AS "Saldo Vencido"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"


LEFT JOIN (
    SELECT     
        T0."CardCode",    
        SUM(
           CASE 
               WHEN T0."DocStatus" = 'O' 
               AND T0."DocDueDate" < CURRENT_DATE THEN (T0."DocTotal" - T0."PaidToDate") 
               ELSE 0 
           END
         ) AS "Saldo Vencido"
        
    FROM OINV T0
    INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
    INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
    
    WHERE     
        T0."DocStatus" = 'O' AND 
        T3."CardType" = 'C' AND  
        -- Solo incluir aquellos con días vencidos negativos
        (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0
    GROUP BY     
        T0."CardCode"
) AS T6 ON (
            
            (T3."CardCode" = COALESCE(T6."CardCode", '') OR (T6."CardCode" IS NULL))
)

WHERE 
  (T1."LineStatus" = 'O') AND
  (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW')) AND
  (T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758')) AND
  (T1."ShipDate" BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7));

  /* ******IOpcion 4 */
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

   
    COALESCE(T6."Saldo Vencido", 0) AS "Saldo Vencido"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"


LEFT JOIN (
    SELECT     
        T0."CardCode",
          SUM(
             CASE 
                 WHEN (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0 
                 THEN (T0."DocTotal" - T0."PaidToDate") 
                 ELSE 0 
             END) 
          AS "Saldo Vencido"    
        
/*SUM(
           CASE 
               WHEN T0."DocStatus" = 'O' 
               AND T0."DocDueDate" < CURRENT_DATE THEN (T0."DocTotal" - T0."PaidToDate") 
               ELSE 0 
           END
         ) AS "Saldo Vencido"*/
        
    FROM OINV T0
    INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
    INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
    
    WHERE     
        T0."DocStatus" = 'O' AND 
        T3."CardType" = 'C' --AND  
        -- Solo incluir aquellos con días vencidos negativos
        --(DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0
    GROUP BY     
        T0."CardCode"
) AS T6 ON (
            
            (T3."CardCode" = COALESCE(T6."CardCode", '') OR (T6."CardCode" IS NULL))
)

WHERE 
  (T1."LineStatus" = 'O') AND
  (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW')) AND
  (T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758')) AND
  (T1."ShipDate" BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7));



/* solo motras los negativos */
SELECT     
    T0."CardCode",
    SUM(
        CASE 
            WHEN (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0 
            THEN (T0."DocTotal" - T0."PaidToDate") 
            ELSE 0 
        END) 
    AS "Saldo Vencido"
    
FROM OINV T0
INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"

WHERE     
    T0."DocStatus" = 'O' AND 
    T3."CardType" = 'C'
GROUP BY     
    T0."CardCode"

    /* ESTE SI TRA TODOS LOS NEGATIVOS */
SELECT     
    T0."CardCode",
    T0."CardName",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Vencimiento",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)", 
    SUM(
        CASE 
            WHEN (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0 
            THEN (T0."DocTotal" - T0."PaidToDate") 
            ELSE 0 
        END) 
    AS "Saldo Vencido"
    
FROM OINV T0
INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"

WHERE     
    T0."DocStatus" = 'O' AND 
    T3."CardType" = 'C' AND
    T3."GroupCode" <> 120  -- Excluir los relacionados
    AND T0."DocDueDate" < CURRENT_DATE
    AND (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0   
GROUP BY     
    T0."CardCode",
    T0."CardName",
    T0."DocDueDate",
    T2."TolDays"

/* todo hacer pruebas   */
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

   
    COALESCE(T6."Saldo Vencido", 0) AS "Saldo Vencido"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"


LEFT JOIN (
   SELECT     
    T0."CardCode",
    --T0."CardName",
    --DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Vencimiento",
    --DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)", 
    SUM(
        CASE 
            WHEN (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0 
            THEN (T0."DocTotal" - T0."PaidToDate") 
            ELSE 0 
        END) 
    AS "Saldo Vencido"
    FROM OINV T0
    INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
    INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"

    WHERE     
        T0."DocStatus" = 'O' AND 
        T3."CardType" = 'C' AND
        T3."GroupCode" <> 120  -- Excluir los relacionados
        AND T0."DocDueDate" < CURRENT_DATE
        AND (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0   
    GROUP BY     
        T0."CardCode",
        --T0."CardName",
        T0."DocDueDate",
        T2."TolDays"


) AS T6 ON (
            
            (T3."CardCode" = COALESCE(T6."CardCode", '') OR (T6."CardCode" IS NULL))
)

WHERE 
  (T1."LineStatus" = 'O') AND
  (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW')) AND
  (T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758')) AND
  (T1."ShipDate" BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7));



  /* POR EL MOMENTO QUEDO ASI */
SELECT 
    T0."DocNum",
    COALESCE(T0."NumAtCard"),
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

   COALESCE(T6."Dias de Vencimiento (inc. Dias Tolerancia)", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",
    COALESCE(T6."Saldo Vencido", 0) AS "Saldo Vencido"
    

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"


LEFT JOIN (
   SELECT     
    T0."CardCode",
    --T0."CardName",
    --DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Vencimiento",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)", 
    SUM(
        CASE 
            WHEN (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0 
            THEN (T0."DocTotal" - T0."PaidToDate") 
            ELSE 0 
        END) 
    AS "Saldo Vencido"
    FROM OINV T0
    INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
    INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"

    WHERE     
        T0."DocStatus" = 'O' AND 
        T3."CardType" = 'C' AND
        T3."GroupCode" <> 120  -- Excluir los relacionados
        AND T0."DocDueDate" < CURRENT_DATE
        AND (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0   
    GROUP BY     
        T0."CardCode",
        --T0."CardName",
        T0."DocDueDate",
        T2."TolDays"
) AS T6 ON T0."CardCode" = T6."CardCode"
--(T3."CardCode" = COALESCE(T6."CardCode", '') --OR (T6."CardCode" IS NULL) )

WHERE 
  T0."CardCode" = 'C0992106891001' AND
  (T1."LineStatus" = 'O') AND
  (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW')) AND
  (T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758')) AND
  (T1."ShipDate" BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7))
--GROUP BY 
  -- T0."DocNum"
 





/*SELECT     
    T0."CardCode",
    T0."CardName",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Vencimiento",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)", 
    SUM(
        CASE 
            WHEN (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0 
            THEN (T0."DocTotal" - T0."PaidToDate") 
            ELSE 0 
        END) 
    AS "Saldo Vencido"
    
FROM OINV T0
INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"

WHERE     
    T0."DocStatus" = 'O' AND 
    T3."CardType" = 'C' AND
    T3."GroupCode" <> 120  -- Excluir los relacionados
    AND T0."DocDueDate" < CURRENT_DATE
    AND (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0   
GROUP BY     
    T0."CardCode",
    T0."CardName",
    T0."DocDueDate",
    T2."TolDays"*/


/* POR EL MOMENTO */

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
    T5."U_LAB_SIS_FABRIC"
    

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"


LEFT JOIN (
   SELECT     
    T0."CardCode",
    --T0."CardName",
    --DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Vencimiento",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)", 
    SUM(
        CASE 
            WHEN (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0 
            THEN (T0."DocTotal" - T0."PaidToDate") 
            ELSE 0 
        END) 
    AS "Saldo Vencido"
    FROM OINV T0
    INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
    INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"

    WHERE     
        T0."DocStatus" = 'O' AND 
        T3."CardType" = 'C' AND
        T3."GroupCode" <> 120  -- Excluir los relacionados
        AND T0."DocDueDate" < CURRENT_DATE
        AND (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0   
    GROUP BY     
        T0."CardCode",
        --T0."CardName",
        T0."DocDueDate",
        T2."TolDays"
) AS T6 ON (T0."CardCode" = T6."CardCode") OR (T6."CardCode" IS NULL)
--(T3."CardCode" = COALESCE(T6."CardCode", '') --OR (T6."CardCode" IS NULL) )

WHERE 
  --T0."CardCode" = 'C0992106891001' AND
  (T1."LineStatus" = 'O') AND
  (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW')) AND
  (T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758')) --AND
  --(T1."ShipDate" BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7))
GROUP BY 
   T0."DocNum",
    T0."NumAtCard",
    T0."DocDate", 
    T0."DocDueDate", 
    T1."ShipDate", 
    T0."CardCode",
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription",
    T1."Quantity",
    T1."NumPerMsr",
    T1."OpenQty",
    T1."UomCode2",
    T1."Price",
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC"


/* *********** */
SELECT 
    T0."DocNum",
    COALESCE(T0."NumAtCard") AS "Número de Referencia",
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
    T1."Price" / T1."NumPerMsr" AS "Precio Unitario",
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",

   COALESCE(T6."Dias de Vencimiento (inc. Dias Tolerancia)", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",
   COALESCE(T6."Saldo Vencido", 0) AS "Saldo Vencido"

FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"

LEFT JOIN (
    SELECT     
        T0."CardCode",
        DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)", 
        SUM(
            CASE 
                WHEN (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0 
                THEN (T0."DocTotal" - T0."PaidToDate") 
                ELSE 0 
            END) AS "Saldo Vencido"
    FROM OINV T0
    INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
    INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
    WHERE     
        T0."DocStatus" = 'O' AND 
        T3."CardType" = 'C' AND
        T3."GroupCode" <> 120  
        AND (T0."DocDueDate" < CURRENT_DATE)
        AND (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) > 0   
    GROUP BY     
        T0."CardCode",
        COALESCE(T2."TolDays", 0),
        T0."DocDueDate"
) AS T6 ON T0."CardCode" = T6."CardCode"

WHERE 
  --T0."CardCode" = 'C0992106891001' AND
  (T1."LineStatus" = 'O') AND
  (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW')) AND
  (T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758')) AND
  (T1."ShipDate" BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7))


/*PERFECTO todo los clientes  con dias de vencimiento incluido los dias de tolerancia */
SELECT     
    T0."CardCode",
    T0."CardName",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)", 
    SUM(
        CASE 
            WHEN (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) > 0 
            THEN (T0."DocTotal" - T0."PaidToDate") 
            ELSE 0 
        END
    ) AS "Saldo Vencido"
    FROM OINV T0
    INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
    INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
    WHERE     
        T0."DocStatus" = 'O' AND 
        T3."CardType" = 'C' AND
        T3."GroupCode" <> 120  
        --AND (T0."DocDueDate" < CURRENT_DATE)
        AND (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) > 0   
    GROUP BY     
        T0."CardCode",
        T0."CardName",
        COALESCE(T2."TolDays", 0),
        T0."DocDueDate"


/* ***** */
SELECT 
    T0."DocNum",
    T0."NumAtCard" AS "Número de Referencia",
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
    T1."Price" / T1."NumPerMsr" AS "Precio Unitario",
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
    (T1."LineStatus" = 'O') AND
    (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW')) AND
    (T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758')) AND
    (T1."ShipDate" BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7)) AND
    (T0."CardCode" NOT IN (
        SELECT     
            DISTINCT T0."CardCode"
        FROM OINV T0
        INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
        INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
        WHERE     
            T0."DocStatus" = 'O' AND 
            T3."CardType" = 'C' AND
            T3."GroupCode" <> 120  
            --AND (T0."DocDueDate" < CURRENT_DATE)
            AND (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) > 0   
    ))


/*APROBADO  asi quedo el query -LOGISTICA - planificacion de Despacho */
SELECT 
    T0."DocNum",
    T0."NumAtCard" AS "Número de Referencia",
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
    T1."Price" / T1."NumPerMsr" AS "Precio Unitario",
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
    (T1."LineStatus" = 'O') AND
    (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW')) AND
    (T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758')) AND
    (T1."ShipDate" BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7)) AND
    (T0."CardCode" NOT IN (
        SELECT     
            DISTINCT T0."CardCode"
        FROM OINV T0
        INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
        INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
        WHERE     
            T0."DocStatus" = 'O' AND 
            T3."CardType" = 'C' AND
            T3."GroupCode" <> 120  
            --AND (T0."DocDueDate" < CURRENT_DATE)
            AND (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) > 0   
    ))

/* CONSULTA PARA SACAR TODO LOS CLIENTE CON DIAS DE VENCIMIENTO INCLUIDO LOS DIAS DE TOLERENCIA "NEGATIVO" */
SELECT DISTINCT 
    T0."CardCode", 
    T0."CardName",
    T0."DocDate" AS "Fecha de Emisión de Documento",      
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Vencimiento",     
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",  
    SUM(CASE 
            WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE THEN T0."DocTotal" - T0."PaidToDate"        
            ELSE 0     
        END
    ) AS "Saldo Vencido"
FROM OINV T0
INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
WHERE     
    T0."DocStatus" = 'O' AND 
    T3."CardType" = 'C' AND
    T3."GroupCode" <> 120  AND 
    (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) < 0
GROUP BY 
   T0."CardCode", 
    T0."CardName",
    T0."DocDate",
    T0."DocDueDate",
    T2."TolDays"

/* query de ventas -> Ordenes de Venta Abiertas Artículos Dreampack 
    * añadir saldo vencido con dias de gracias
 */

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
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
        ELSE ' ' 
   END AS "Condición",

   -- Saldo vencido
   CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE 'No' 
   END AS "Saldo Vencido",

   -- Saldo vencido más días de gracia
   CASE 
       WHEN COALESCE(A0."TotalVencido", 0) > 0 AND (DAYS_BETWEEN(CURRENT_DATE, A2."DueDate") <= COALESCE(T2."TolDays", 0)) THEN 'Sí'
       ELSE 'No'
   END AS "Saldo Vencido + Días de Gracia"

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
) AS A1 ON A1."CardCode" = T3."CardCode"

-- Subconsulta para obtener los días de gracia
LEFT JOIN (
    SELECT
        "GroupNum",
        MAX("TolDays") AS "TolDays"
    FROM OCTG
    GROUP BY "GroupNum"
) AS A2 ON A2.GroupNum = T3.GroupNum

WHERE 
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');


/* opcion 2 */

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
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
        ELSE ' ' 
   END AS "Condición",

   -- Saldo vencido
   CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE 'No' 
   END AS "Saldo Vencido",

   -- Saldo vencido más días de gracia
   /* CASE 
       WHEN COALESCE(A0."TotalVencido", 0) > 0 AND (DAYS_BETWEEN(CURRENT_DATE, T0."DocDueDate") <= COALESCE(T2.TolDays, 0)) THEN 'Sí'
       ELSE 'No'
   END AS "Saldo Vencido + Días de Gracia" */

    -- Saldo vencido más días de gracia
   /* CASE 
       WHEN COALESCE(A2."SaldoVencido", 0) > 0 AND (DAYS_BETWEEN(CURRENT_DATE, A2."DiasdeVencimiento") <= COALESCE(A2."TolDays", 0)) THEN 'Sí'
       WHEN COALESCE(A2."SaldoVencido", 0) = 0 AND (DAYS_BETWEEN(CURRENT_DATE, A2."DiasdeVencimiento") < 0) THEN 'Sí'
       ELSE 'No'
   END AS "Saldo Vencido + Días de Gracia" */

   /* 
     CASE 
       WHEN COALESCE(A2.SaldoVencido, 0) > 0 AND (DAYS_BETWEEN(CURRENT_DATE, A2.DiasDeVencimiento) <= COALESCE(A2.TolDays, 0)) THEN 'Tiene saldo vencido y está dentro del período de gracia'
       WHEN COALESCE(A2.SaldoVencido, 0) = 0 AND (DAYS_BETWEEN(CURRENT_DATE, A2.DiasDeVencimiento) < 0) THEN 'No tiene saldo vencido, pero tiene días de gracia'
       ELSE 'No tiene saldo vencido ni días de gracia aplicables'
   END AS "Saldo Vencido + Días de Gracia"   
    */

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
) AS A1 ON A1."CardCode" = T3."CardCode"

-- Subconsulta para obtener los días de gracia Y SI TIENE SALDO VENCIDO
LEFT JOIN (
    SELECT
        B0."CardCode",
        B2."TolDays",
        DAYS_BETWEEN(B0."DocDueDate", CURRENT_DATE) AS "DiasdeVencimiento",     
        --DAYS_BETWEEN(B0."DocDueDate", CURRENT_DATE) - COALESCE(B2."TolDays", 0) AS "DiasVencimientoDiasTolerancia",  
        SUM(CASE 
                WHEN B0."DocStatus" = 'O' AND B0."DocDueDate" < CURRENT_DATE THEN B0."DocTotal" - B0."PaidToDate"        
                ELSE 0     
            END
        ) AS "SaldoVencido"
    FROM OINV B0
    INNER JOIN OCRD B1 ON B0."CardCode" = B1."CardCode"
    INNER JOIN OCTG B2 ON B0."GroupNum" = B2."GroupNum"
    WHERE     
        B0."DocStatus" = 'O' AND 
        B1."CardType" = 'C' AND
        B1."GroupCode" <> 120  AND 
        (DAYS_BETWEEN(B0."DocDueDate", CURRENT_DATE) - COALESCE(B2."TolDays", 0)) < 0
    GROUP BY B0."CardCode", B2."TolDays", B0."DocDueDate"
) AS A2 ON A2."CardCode" = T3."CardCode"

WHERE 
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');



/* realizando el query mas dias de gracias 06-12-2024*/ 

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
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
        ELSE ' ' 
   END AS "Condición",

   -- Saldo vencido
   CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE 'No' 
   END AS "Saldo Vencido",
  
  --Dia de gracias
   CASE 
        WHEN  
           T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) > 0  
           AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) < 0
         THEN 'Tiene saldo vencido y está dentro del período de gracia'
        WHEN  
           T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
           AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) > 0
         THEN 'No Tiene saldo vencido y no está dentro del período de gracia'
        
        --WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        --WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        --WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE ' ' 
   END AS "Saldo vencido y dias de gracia"  

FROM ORDR T0 --pedido del cliente
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  --pedido de cliente fila 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" --Pedido de cliente - Ampliación de plazo de pago de impuesto
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"  --Socio de negocio
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  --Empleado del departamento de ventas
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

-- Subconsulta para obtener los días de gracia Y SI TIENE SALDO VENCIDO
LEFT JOIN (
  SELECT     
    T0."CardCode",
    T0."DocDueDate" AS "FechaVencimiento",
    SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencidoDG",
    SUM(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"
  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
  WHERE 
        T0."DocStatus" = 'O'
       AND (T0."DocDueDate" < CURRENT_DATE)
   GROUP BY T0."CardCode", T0."DocDueDate"      
) AS A2 ON A2."CardCode" = T3."CardCode"


WHERE 
  --T3."CardCode" = 'C0908915762001'  AND
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');






--------------------------------------------------

-- Día de gracia
CASE 
    WHEN T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) > 0 
         AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0)) < 0 
    THEN 'Tiene saldo vencido y está dentro del período de gracia'
    
    WHEN T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) = 0 
         AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0)) >= 0 
    THEN 'No Tiene saldo vencido y no está dentro del período de gracia'
    
    
    ELSE ' ' 
END AS "Saldo vencido y días de gracia"




/* **************************************** */
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

    T3."GroupNum",
    T3."U_SYP_TCONTRIB",

   -- Condición
   CASE 
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
        ELSE ' ' 
   END AS "Condición",

   -- Saldo vencido
   CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE 'No' 
   END AS "Saldo Vencido",
  
  --Dia de gracias
   CASE 
        --cliente contado
        WHEN  
           T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) > 0  
           AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'CC Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
           T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
           AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'CC No Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
           T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
           AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) >= 0
        THEN 'CC No Tiene saldo vencido y no está dentro del período de gracia'
        
        --cliente exterior
        WHEN  
            T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A2."TotalVencidoDG", 0) > 0  
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'CE Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
            T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'CE No Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
           T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
           AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) >= 0
        THEN 'CE No Tiene saldo vencido y no está dentro del período de gracia'
        
        --excede limite de credito y tiene saldo vencido
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A2."TotalVencidoDG", 0) > 0
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0 
        THEN 'EX LC Tiene saldo vencido y está dentro del período de gracia'

        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A2."TotalVencidoDG", 0) = 0
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0 
        THEN 'EX LC No Tiene saldo vencido y está dentro del período de gracia'

        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A2."TotalVencidoDG", 0) = 0
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) >= 0 
        THEN 'EX LC No Tiene saldo vencido y no está dentro del período de gracia'
        
        
        --WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE '' 
   END AS "Saldo vencido + dias de gracia"  

FROM ORDR T0 --pedido del cliente
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  --pedido de cliente fila 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" --Pedido de cliente - Ampliación de plazo de pago de impuesto
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"  --Socio de negocio
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  --Empleado del departamento de ventas
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

-- Subconsulta para obtener los días de gracia Y SI TIENE SALDO VENCIDO
LEFT JOIN (
  SELECT     
    T0."CardCode",
    T0."DocDueDate" AS "FechaVencimiento",
    SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencidoDG",
    SUM(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"
  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
  WHERE 
        T0."DocStatus" = 'O'
       AND (T0."DocDueDate" < CURRENT_DATE)
   GROUP BY T0."CardCode", T0."DocDueDate"      
) AS A2 ON A2."CardCode" = T3."CardCode"


WHERE 
  --T3."CardCode" = 'C0908915762001'  AND
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');



/* ********* MODIFICANDO */
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

    --T3."GroupNum",
    --T3."U_SYP_TCONTRIB",

   -- Condición
   CASE 
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
        ELSE ' ' 
   END AS "Condición",

   -- Saldo vencido
   CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE 'No' 
   END AS "Saldo Vencido",
  
  --Dia de gracias
   CASE 
        --cliente contado
        WHEN  
           T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) > 0  
           AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'CC Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
           T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
           AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'CC No Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
           T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
           AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) >= 0
        THEN 'CC No Tiene saldo vencido y no está dentro del período de gracia'
        
        --cliente exterior
        WHEN  
            T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A2."TotalVencidoDG", 0) > 0  
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'CE Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
            T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'CE No Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
           T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
           AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) >= 0
        THEN 'CE No Tiene saldo vencido y no está dentro del período de gracia'

        --excede limite de credito y tiene saldo vencido
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A2."TotalVencidoDG", 0) > 0
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0 
        THEN 'SI'--'EX LC Tiene saldo vencido y está dentro del período de gracia'

        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A2."TotalVencidoDG", 0) = 0
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0 
        THEN 'EX LC No Tiene saldo vencido y está dentro del período de gracia'

        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A2."TotalVencidoDG", 0) = 0
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) >= 0 
        THEN 'EX LC No Tiene saldo vencido y no está dentro del período de gracia'

        
        --WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        --WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        --WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE '' 
   END AS "Días de gracia"  

FROM ORDR T0 --pedido del cliente
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  --pedido de cliente fila 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" --Pedido de cliente - Ampliación de plazo de pago de impuesto
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"  --Socio de negocio
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  --Empleado del departamento de ventas
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

-- Subconsulta para obtener los días de gracia Y SI TIENE SALDO VENCIDO
LEFT JOIN (
  SELECT DISTINCT    
    T0."CardCode",
    T0."DocDueDate" AS "FechaVencimiento",
    SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencidoDG",
    SUM(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"
  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
  WHERE 
        T0."DocStatus" = 'O'
       AND (T0."DocDueDate" < CURRENT_DATE)
   GROUP BY T0."CardCode", T0."DocDueDate"      
) AS A2 ON A2."CardCode" = T3."CardCode"


WHERE 
  T3."CardCode" = 'C0993374672001'  AND
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');




  /* *SALDO VENCIDO + dias de tolerenacia*/

  SELECT
    T0."DocNum",
    T0."CardCode",
    T0."CardName",
    T0."DocDueDate",
   
    COALESCE(T2."TolDays", 0) AS "Dias de tolerancia",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",
     SUM(T0."DocTotal" - T0."PaidToDate") AS "Saldo Vencido"
    /*SUM(
        CASE 
            WHEN (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) > 0 
            THEN (T0."DocTotal" - T0."PaidToDate") 
            ELSE 0 
        END
    ) AS "Saldo Vencido"*/
FROM OINV T0
INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
WHERE 
     --T0."CardCode" = 'C0702116666001' AND   
    T0."DocStatus" = 'O' AND 
    T3."CardType" = 'C' AND
    T3."GroupCode" <> 120  
    --AND (T0."DocDueDate" < CURRENT_DATE)
    --AND (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) > 0   
GROUP BY
    T0."DocNum",     
    T0."CardCode",
    T0."CardName",
    COALESCE(T2."TolDays", 0),
    T0."DocDueDate"
ORDER BY
    T0."CardCode",
    T0."CardName";



/* new query */
SELECT DISTINCT
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

    --T3."GroupNum",
    T3."U_SYP_TCONTRIB",

   -- Condición
   CASE 
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
        ELSE ' ' 
   END AS "Condición",

   -- Saldo vencido
   CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE 'No' 
   END AS "Saldo Vencido",
  
  --Dia de gracias
   CASE 
        --cliente contado
        WHEN  
           T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) > 0  
           AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'CC Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
           T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
           AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'CC No Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
           T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
           AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) >= 0
        THEN 'CC No Tiene saldo vencido y no está dentro del período de gracia'
        
        --cliente exterior
        WHEN  
            T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A2."TotalVencidoDG", 0) > 0  
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'Sí' --'CE Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
            T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'CE No Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
           T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
           AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) >= 0
        THEN 'CE No Tiene saldo vencido y no está dentro del período de gracia'

        --excede limite de credito y tiene saldo vencido
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A2."TotalVencidoDG", 0) > 0
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0 
        THEN 'Sí'--'EX LC Tiene saldo vencido y está dentro del período de gracia'

        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A2."TotalVencidoDG", 0) = 0
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0 
        THEN 'EX LC No Tiene saldo vencido y está dentro del período de gracia'

        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A2."TotalVencidoDG", 0) = 0
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) >= 0 
        THEN 'EX LC No Tiene saldo vencido y no está dentro del período de gracia'

        
        --WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        --WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        --WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE '' 
   END AS "Días de gracia"  

FROM ORDR T0 --pedido del cliente
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  --pedido de cliente fila 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" --Pedido de cliente - Ampliación de plazo de pago de impuesto
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"  --Socio de negocio
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  --Empleado del departamento de ventas
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

-- Subconsulta para obtener los días de gracia Y SI TIENE SALDO VENCIDO
LEFT JOIN (
  SELECT DISTINCT    
    T0."CardCode",
    T0."DocDueDate" AS "FechaVencimiento",
    SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencidoDG",
    SUM(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"
  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
  WHERE 
        T0."DocStatus" = 'O'
       AND (T0."DocDueDate" < CURRENT_DATE)
   GROUP BY T0."CardCode", T0."DocDueDate"      
) AS A2 ON A2."CardCode" = T3."CardCode"


WHERE 
  T3."CardCode" = 'C0908915762001'  AND
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');


  /* opcion 1.1 */
SELECT DISTINCT
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

    --T3."GroupNum",
    --T3."U_SYP_TCONTRIB",

-- Días de Vencimiento (incluyendo Días de Tolerancia)
   COALESCE(A2."DiasTolerancia", 0) AS "Dias de tolerancia",
   DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",

   -- Condición
   CASE 
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
        ELSE ' ' 
   END AS "Condición",

   -- Saldo vencido
   CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE 'No' 
   END AS "Saldo Vencido",

 -- Día de gracia
   CASE 
       WHEN DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) < 0 THEN 'Sí'
       ELSE 'No'
   END AS "Dia de Gracia"
  
  /*--Dia de gracias
   CASE 
        --cliente contado
        WHEN  
           T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) > 0  
           AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'CC Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
           T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
           AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'CC No Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
           T3."GroupNum" = -1 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
           AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) >= 0
        THEN 'CC No Tiene saldo vencido y no está dentro del período de gracia'
        
        --cliente exterior
        WHEN  
            T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A2."TotalVencidoDG", 0) > 0  
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'Sí' --'CE Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
            T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0
        THEN 'CE No Tiene saldo vencido y está dentro del período de gracia'

        WHEN  
           T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A2."TotalVencidoDG", 0) = 0  
           AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) >= 0
        THEN 'CE No Tiene saldo vencido y no está dentro del período de gracia'

        --excede limite de credito y tiene saldo vencido
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A2."TotalVencidoDG", 0) > 0
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0 
        THEN 'Sí'--'EX LC Tiene saldo vencido y está dentro del período de gracia'

        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A2."TotalVencidoDG", 0) = 0
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) < 0 
        THEN 'EX LC No Tiene saldo vencido y está dentro del período de gracia'

        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A2."TotalVencidoDG", 0) = 0
            AND (DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) ) >= 0 
        THEN 'EX LC No Tiene saldo vencido y no está dentro del período de gracia'

        
        --WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        --WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 

  
        ELSE '' 
   END AS "Días de gracia"  */

FROM ORDR T0 --pedido del cliente
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  --pedido de cliente fila 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" --Pedido de cliente - Ampliación de plazo de pago de impuesto
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"  --Socio de negocio
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  --Empleado del departamento de ventas
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

-- Subconsulta para obtener los días de gracia Y SI TIENE SALDO VENCIDO
LEFT JOIN (
  SELECT DISTINCT    
    T0."CardCode",
    T0."DocDueDate" AS "FechaVencimiento",
    SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencidoDG",
    SUM(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"
  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
  WHERE 
        T0."DocStatus" = 'O'
       AND (T0."DocDueDate" < CURRENT_DATE)
   GROUP BY T0."CardCode", T0."DocDueDate"      
) AS A2 ON A2."CardCode" = T3."CardCode"


WHERE 
  T3."CardCode" = 'C0990004196001'  AND
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');


  /* opcion 2 verificar */
SELECT DISTINCT
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

    --T3."GroupNum",
    --T3."U_SYP_TCONTRIB",

   
   COALESCE(A2."DiasTolerancia", 0) AS "Dias de tolerancia",
   A2."FechaVencimiento",

   -- Días de Vencimiento (incluyendo Días de Tolerancia)
   DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",

   -- Condición
   CASE 
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
        ELSE ' ' 
   END AS "Condición",

   -- Saldo vencido
   CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE 'No' 
   END AS "Saldo Vencido",

 -- Día de gracia
   CASE 
       WHEN DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) < 0 THEN 'Sí'
       ELSE 'No'
   END AS "Día de Gracia"
  
FROM ORDR T0 --pedido del cliente
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  --pedido de cliente fila 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" --Pedido de cliente - Ampliación de plazo de pago de impuesto
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"  --Socio de negocio
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  --Empleado del departamento de ventas
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
  SELECT DISTINCT    
    T0."CardCode",
    --T0."DocDueDate" AS "FechaVencimiento",
     MAX(T0."DocDueDate") AS "FechaVencimiento",
    SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencidoDG",
    SUM(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"
  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
  WHERE 
        T0."DocStatus" = 'O'
       AND (T0."DocDueDate" < CURRENT_DATE)
   GROUP BY T0."CardCode"      
) AS A2 ON A2."CardCode" = T3."CardCode"


WHERE 
  --T3."CardCode" = 'C0990004196001'  AND
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');


  /* OPCION 3 VERIFICAR */
SELECT --DISTINCT
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

    --COALESCE(A2."DiasTolerancia", 0) AS "Dias de tolerancia",
    A2."FechaVencimiento",

    -- Días de Vencimiento (incluyendo Días de Tolerancia)
    DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",

    -- Condición
    CASE 
            WHEN T3."GroupNum" = -1 THEN 'C de contado'  
            WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
            WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
            WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
            WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
            ELSE ' ' 
    END AS "Condición",

    -- Saldo vencido
    CASE 
            WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
            WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
            WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
            WHEN A0."TotalVencido" > 0 THEN 'Sí'  
            ELSE 'No' 
    END AS "Saldo Vencido",

    -- Día de gracia
    CASE 
        WHEN DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) < 0 THEN 'Sí'
        ELSE 'No'
    END AS "Día de Gracia"
  
FROM ORDR T0 --pedido del cliente
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  --pedido de cliente fila 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" --Pedido de cliente - Ampliación de plazo de pago de impuesto
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"  --Socio de negocio
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  --Empleado del departamento de ventas
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
  SELECT --DISTINCT    
    T0."CardCode",
    MAX(T0."DocDueDate") AS "FechaVencimiento",
    SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencidoDG",
    MAX(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"
    --SUM(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"
  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
  WHERE 
        T0."DocStatus" = 'O'
       --AND (T0."DocDueDate" < CURRENT_DATE)
   GROUP BY T0."CardCode", T2."TolDays"     
) AS A2 ON A2."CardCode" = T3."CardCode"


WHERE 
  T3."CardCode" = 'C0992106891001'  AND
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');




  /* QUEDO EL QUERY ASI FUE REVISADO PERO AUN LE FALTA  */
  SELECT --DISTINCT
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

    /*T3."Balance",
    COALESCE(A0."TotalVencido", 0) AS "Saldo Vencido",
    COALESCE(T3."CreditLine", 0) AS "Límite de Crédito",

    A0."TotalVencido",
    A1."TotalExteriorVencido",
    A2."TotalVencidoDG", */


    --COALESCE(A2."DiasTolerancia", 0) AS "Dias de tolerancia",
    A2."FechaVencimiento",

    -- Días de Vencimiento (incluyendo Días de Tolerancia)
    DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",

    -- Condición
    CASE 
            WHEN T3."GroupNum" = -1 THEN 'C de contado'  
            WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
            WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
            WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
            WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
            ELSE ' ' 
    END AS "Condición",

    -- Saldo vencido
    CASE 
            WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
            WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
            WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
            WHEN A0."TotalVencido" > 0 THEN 'Sí'  
            ELSE 'No' 
    END AS "Saldo Vencido",

    -- Día de gracia
    CASE 
        WHEN DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) < 0 THEN 'Sí'
        ELSE 'No'
    END AS "Día de Gracia"
  
FROM ORDR T0 --pedido del cliente
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  --pedido de cliente fila 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" --Pedido de cliente - Ampliación de plazo de pago de impuesto
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"  --Socio de negocio
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  --Empleado del departamento de ventas
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
  SELECT --DISTINCT    
    T0."CardCode",
    MAX(T0."DocDueDate") AS "FechaVencimiento",
    SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencidoDG",
    MAX(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"
    --SUM(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"
  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
  WHERE 
        T0."DocStatus" = 'O'
        AND T0."DocDueDate" < CURRENT_DATE
   GROUP BY T0."CardCode", T2."TolDays"     
) AS A2 ON A2."CardCode" = T3."CardCode"


WHERE 
  --T3."CardCode" = 'C0916032386001' AND --'C0992106891001'  AND
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');


-- **************************************************************************************************************
SELECT
    T0."DocNum",    
    T0."CardCode",
    MIN(T0."DocDueDate") AS "FechaVencimiento",
    SUM(T0."DocTotal" - T0."PaidToDate") AS "TotalVencidoDG",
    MAX(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia",
    SUM(T0."ExtraDays") as "Dia extras"

  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
  WHERE 
        T0."DocStatus" = 'O'
        AND T0."DocDueDate" < CURRENT_DATE
   GROUP BY T0."DocNum",T0."CardCode", T2."TolDays"
-- *****************************************************************************************************************
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
            WHEN T3."GroupNum" = -1 THEN 'C de contado'  
            WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
            WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
            WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
            WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
            ELSE ' ' 
    END AS "Condición",

    -- Saldo vencido
    CASE 
            WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
            WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
            WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
            WHEN A0."TotalVencido" > 0 THEN 'Sí'  
            ELSE 'No' 
    END AS "Saldo Vencido",

    -- Día de gracia
    CASE 
        WHEN DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) > 0 THEN 'Sí'
        ELSE 'No'
    END AS "Día de Gracia",


    A2."DiaExtras",
    A2."FechaVencimiento",
    COALESCE(A2."DiasTolerancia", 0) AS "Dias de tolerancia",
    

    -- Días de Vencimiento (incluyendo Días de Tolerancia)
    DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",



    --A0."TotalVencido",
    A2."TotalVencidoDG"
    
  
FROM ORDR T0 --pedido del cliente
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  --pedido de cliente fila 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" --Pedido de cliente - Ampliación de plazo de pago de impuesto
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"  --Socio de negocio
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  --Empleado del departamento de ventas
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
    SUM(T0."ExtraDays") as "DiaExtras",
    MAX(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"

  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
  WHERE 
        T0."DocStatus" = 'O'
        AND T0."DocDueDate" < CURRENT_DATE
   GROUP BY T0."CardCode", T2."TolDays"     
) AS A2 ON A2."CardCode" = T3."CardCode"


WHERE 
  --T3."CardCode" = 'C0916032386001' AND --'C0992106891001'  AND
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');






-- *****************************************************************************************************************


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
            WHEN T3."GroupNum" = -1 THEN 'C de contado'  
            WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
            WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
            WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
            WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
            ELSE ' ' 
    END AS "Condición",

    -- Saldo vencido
    CASE 
            WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
            WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
            WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
            WHEN A0."TotalVencido" > 0 THEN 'Sí'  
            ELSE 'No' 
    END AS "Saldo Vencido",

    -- Día de gracia
    CASE 
        --WHEN DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) > 0
         WHEN DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) > 0  
THEN 'Sí'
        ELSE 'No'
    END AS "Día de Gracia",



    DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) AS "FechaVencimientoDiasExtras",

    A2."DiaExtras",
    A2."FechaVencimiento",
    --COALESCE(A2."DiasTolerancia", 0) AS "Dias de tolerancia",
    

    -- Días de Vencimiento (incluyendo Días de Tolerancia)
    --DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",



    --A0."TotalVencido",
    A2."TotalVencidoDG"
    
  
FROM ORDR T0 --pedido del cliente
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  --pedido de cliente fila 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" --Pedido de cliente - Ampliación de plazo de pago de impuesto
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"  --Socio de negocio
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  --Empleado del departamento de ventas
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
    MAX(T0."ExtraDays") as "DiaExtras",
    MAX(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"

  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
  WHERE 
        T0."DocStatus" = 'O'
        AND T0."DocDueDate" < CURRENT_DATE
   GROUP BY T0."CardCode", T2."TolDays"     
) AS A2 ON A2."CardCode" = T3."CardCode"


WHERE 
  --T3."CardCode" = 'C0916032386001' AND --'C0992106891001'  AND
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');


--   ************************************************************************************************

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
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
        ELSE ' ' 
    END AS "Condición",

    -- Saldo vencido
    CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE 'No' 
    END AS "Saldo Vencido",

    -- Día de gracia
    CASE 
        WHEN DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) > 0  
            THEN 'Sí'
        ELSE 'No'
    END AS "Día de Gracia",

    -- Cálculo de días vencidos más días de gracia
    DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) AS "FechaVencimientoDiasExtras",

    A2."DiaExtras",
    A2."FechaVencimiento",

    -- Total saldo vencido más días de gracia
    COALESCE(A0."TotalVencido", 0) + CASE 
        WHEN DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) > 0  
            THEN DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0)
            ELSE 0
        END AS "Saldo Vencido + Días de Gracia",

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
      MAX(T0."ExtraDays") as "DiaExtras",
      MAX(COALESCE(T2."TolDays", 0)) AS "DiasTolerancia"
  FROM OINV T0
  INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
  INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
  WHERE 
      T0."DocStatus" = 'O'
      AND T0."DocDueDate" < CURRENT_DATE
   GROUP BY T0."CardCode"
) AS A2 ON A2."CardCode" = T3."CardCode"

WHERE 
  --T3."CardCode" = 'C0916032386001' AND --'C0992106891001'  AND
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');




  /* REVISAR */
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
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
        ELSE ' ' 
    END AS "Condición",

    -- Saldo vencido
    CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE 'No' 
    END AS "Saldo Vencido",

    CASE 
        WHEN COALESCE(A0."TotalVencido", 0) > 0 AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) + COALESCE(A2."DiaExtras", 0) > 0  
            THEN 'Sí'
        ELSE 'No'
    END AS "Saldo Vencido + Días de Gracia",
   

    A2."FechaVencimiento",
    A2."DiaExtras",

    -- Cálculo de días vencidos más días de gracia
    DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) + COALESCE(A2."DiaExtras", 0) AS "FechaVencimiento + DiasExtras",

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
  --T3."CardCode" = 'C0916032386001' AND --'C0992106891001'  AND
  T1."LineStatus" = 'O' 
  AND T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW') 
  AND T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758');


/* revisar opcion 1  */
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
        WHEN T3."GroupNum" = -1 THEN 'C de contado'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'C exterior con Saldo mayor 90 días'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Excede LC y tiene saldo vencido'
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) THEN 'Excede LC'  
        WHEN A0."TotalVencido" > 0 THEN 'C local con Saldo Vencido'  
        ELSE ' ' 
    END AS "Condición",

    -- Saldo vencido
    CASE 
        WHEN  T3."GroupNum" = -1 AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí'  
        WHEN (T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0) THEN 'Sí'  
        WHEN COALESCE(T3."Balance", 0) > COALESCE(T3."CreditLine", 0) AND COALESCE(A0."TotalVencido", 0) > 0 THEN 'Sí' 
        WHEN A0."TotalVencido" > 0 THEN 'Sí'  
        ELSE 'No' 
    END AS "Saldo Vencido",

   /* CASE 
        WHEN COALESCE(A2."TotalVencidoDG", 0) > 0 AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) > 0  THEN 'Sí'
        
        ELSE 'No'
    END AS "Saldo Vencido + Días de Gracia",*/

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


/* revisar opcion 2 */
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



/* REVISAR ESTA PARTE DE SALDO VENCIDO + DIA DE GRACIA  */
  -- Saldo Vencido + Días de Gracia
    CASE 
       WHEN T3."GroupCode" = '120' THEN 'No'  -- Si es un cliente relacionado, mostrar "No"
       --WHEN T3."GroupCode" <> '120' THEN 'Sí----' 
       WHEN T3."GroupCode" <> '120' AND COALESCE(A2."TotalVencidoDG", 0) > 0 AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) > 0 THEN 'Sí joj'

       --WHEN T3."U_SYP_TCONTRIB" = 99 AND COALESCE(A1."TotalExteriorVencido", 0) > 0 
          --AND DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiaExtras", 0) > 0 THEN 'Sí exterior'
        --AND DAYS_BETWEEN(A1."FechaVencimientoCE", CURRENT_DATE) - COALESCE(A1."DiaExtrasCE", 0) > 0  THEN 'Sí'  
       

  
       ELSE ''
    END AS "Saldo Vencido + Días de Gracia",


/* 17-12-2024 */
/* planificacion de despacho se va add una columna "Bloqueado para entrega" */
/* Query Original */
SELECT 
    T0."DocNum",
    T0."NumAtCard" AS "Número de Referencia",
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
    T1."Price" / T1."NumPerMsr" AS "Precio Unitario",
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
    (T1."LineStatus" = 'O') AND
    (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW')) AND
    (T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758')) AND
    (T1."ShipDate" BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7)) AND
    (T0."CardCode" NOT IN (
        SELECT     
            DISTINCT T0."CardCode"
        FROM OINV T0
        INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
        INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
        WHERE     
            T0."DocStatus" = 'O' AND 
            T3."CardType" = 'C' AND
            T3."GroupCode" <> 120  
            --AND (T0."DocDueDate" < CURRENT_DATE)
            AND (DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0)) > 0   
    ))

/* ahi que validarlo  Opcion 1*/
SELECT 
    T0."DocNum",
    T0."NumAtCard" AS "Número de Referencia",
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
    T1."Price" / T1."NumPerMsr" AS "Precio Unitario",
    T1."TaxCode",
    T2."CityS",
    T2."StreetS",
    T0."Comments",
    T4."SlpName", 
    T1."WhsCode", 
    T5."U_LAB_SIS_FABRIC",
    
    --Bloqueado para entrega
    CASE 
        WHEN T3."GroupCode" = '120' THEN 'No'  -- Si es un cliente relacionado, mostrar "No"

    WHEN  COALESCE(A2."TotalVencidoDG", 0)  > 0 AND 
        DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) > 0 THEN 'Si'

    WHEN  COALESCE(A2."TotalVencidoDG", 0)  > 0 AND 
        DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) < 0 THEN 'No'

    WHEN  COALESCE(A2."TotalVencidoDG", 0)  = 0 AND 
        DAYS_BETWEEN(A2."FechaVencimiento", CURRENT_DATE) - COALESCE(A2."DiasTolerancia", 0) = 0 THEN 'No'


        ELSE 'No'
    END AS "BloqueadoParaEntrega"

    
FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN RDR12 T2 ON T0."DocEntry" = T2."DocEntry" 
LEFT JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
LEFT JOIN OSLP T4 ON T3."SlpCode" = T4."SlpCode"  
LEFT JOIN OITM T5 ON T1."ItemCode" = T5."ItemCode"

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
    (T1."LineStatus" = 'O') AND
    (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA', '10PTW')) AND
    (T0."DocNum" NOT IN ('22001723', '22001745', '22001747', '22001758')) AND
    (T1."ShipDate" BETWEEN CURRENT_DATE AND ADD_DAYS(CURRENT_DATE, 7));