

/* Todos los documentos que esten vencidos. (sin incluir tolerancia) */

SELECT 
    T1."SlpName" AS "Ejecutivo Asignado",
    T0."CardCode" AS "Codigo Cliente",
    T0."CardName" AS "Nombre Cliente",
    T0."DocType" AS "Tipo de Documento",
    T0."DocNum" AS "# Documento",
    T0."DocDate" AS "Fecha de Emisión de Documento",
    T0."DocDueDate" AS "Fecha Vencimiento",
    ADD_DAYS(T0."DocDueDate", COALESCE(T2."TolDays", 0)) AS "Fecha Vencimiento + Días de Tolerancia",
    SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) AS "Saldo Vencido"
FROM 
    OINV T0
INNER JOIN 
    OCRD T3 ON T0."CardCode" = T3."CardCode"  -- Información del socio de negocio
INNER JOIN 
    OCTG T2 ON T0."GroupNum" = T2."GroupNum"  -- Condiciones de pago - definiciones
INNER JOIN 
    OSLP T1 ON T3."SlpCode" = T1."SlpCode"  -- Información del ejecutivo asignado
WHERE 
    T0."DocStatus" = 'O'
    AND T3."CardType" = 'C'  -- Solo clientes
    AND T3."GroupCode" <> 120  -- Excluir los relacionados
    AND ADD_DAYS(T0."DocDueDate", COALESCE(T2."TolDays", 0)) < CURRENT_DATE 
GROUP BY 
    T1."SlpName",
    T0."CardCode", 
    T0."CardName",
    T0."DocType",  
    T0."DocNum",  
    T0."DocDate",  
    T2."TolDays",  
    T0."DocDueDate";



    /* ********************* */

    SELECT 
    T0."DocEntry",
    T1."SlpName" AS "Ejecutivo Asignado",
    T0."CardCode" AS "Codigo Cliente",
    T0."CardName" AS "Nombre Cliente",
    CASE 
        WHEN T0."DocType" = 'I'   THEN 'Artículo' 
        WHEN T0."DocType" = 'S'   THEN 'Servicio' 
        ELSE ' ' 
    END AS "Tipo de Documento",
    T0."DocNum" AS "# Documento",
    T0."DocDate" AS "Fecha de Emisión de Documento",
    --T0."DocDueDate" AS "Fecha Vencimiento",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Vencimiento",
    COALESCE(T2."TolDays", 0) AS "Días de tolerancia",
    ADD_DAYS(T0."DocDueDate", COALESCE(T2."TolDays", 0)) AS "Fecha Vencimiento + Días de Tolerancia",
    --DAYS_BETWEEN (TO_DATE (T0."DocDueDate", 'YYYY-MM-DD')) "Fecha Vencimiento",
    --ADD_DAYS(T0."DocDueDate", COALESCE(T2."TolDays", 0)) AS "Fecha Vencimiento + Días de Tolerancia",
    SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) AS "Saldo Vencido"
FROM 
    OINV T0
INNER JOIN 
    OCRD T3 ON T0."CardCode" = T3."CardCode"  -- Información del socio de negocio
INNER JOIN 
    OCTG T2 ON T0."GroupNum" = T2."GroupNum"  -- Condiciones de pago - definiciones
INNER JOIN 
    OSLP T1 ON T3."SlpCode" = T1."SlpCode"  -- Información del ejecutivo asignado
WHERE 
    T0."DocStatus" = 'O'
    AND T3."CardType" = 'C'  -- Solo clientes
    AND T3."GroupCode" <> 120  -- Excluir los relacionados
   AND T0."DocDueDate" < CURRENT_DATE 
    --AND ADD_DAYS(T0."DocDueDate", COALESCE(T2."TolDays", 0)) < CURRENT_DATE 
GROUP BY 
    T0."DocEntry",
    T1."SlpName",
    T0."CardCode", 
    T0."CardName",
    T0."DocType",  
    T0."DocNum",  
    T0."DocDate",  
    T2."TolDays",  
    T0."DocDueDate";


    /* asi quedo revisar */
    SELECT 
    T0."DocEntry",
    T1."SlpName" AS "Ejecutivo Asignado",
    T0."CardCode" AS "Codigo Cliente",
    T0."CardName" AS "Nombre Cliente",
    CASE 
        WHEN T0."DocType" = 'I'   THEN 'Artículo' 
        WHEN T0."DocType" = 'S'   THEN 'Servicio' 
        ELSE ' ' 
    END AS "Tipo de Documento",
    T0."DocNum" AS "# Documento",
    T0."DocDate" AS "Fecha de Emisión de Documento",
  
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Vencimiento",
    COALESCE(T2."TolDays", 0) AS "Días de tolerancia",

    -- Sumar días de vencimiento y días de tolerancia
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) + COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",

    --ADD_DAYS(T0."DocDueDate", COALESCE(T2."TolDays", 0)) AS "Fecha Vencimiento + Días de Tolerancia",
    --DAYS_BETWEEN (TO_DATE (T0."DocDueDate", 'YYYY-MM-DD')) "Fecha Vencimiento",
    --ADD_DAYS(T0."DocDueDate", COALESCE(T2."TolDays", 0)) AS "Fecha Vencimiento + Días de Tolerancia",

    SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) AS "Saldo Vencido"
FROM 
    OINV T0
INNER JOIN 
    OCRD T3 ON T0."CardCode" = T3."CardCode"  -- Información del socio de negocio
INNER JOIN 
    OCTG T2 ON T0."GroupNum" = T2."GroupNum"  -- Condiciones de pago - definiciones
INNER JOIN 
    OSLP T1 ON T3."SlpCode" = T1."SlpCode"  -- Información del ejecutivo asignado
WHERE 
    T0."DocStatus" = 'O'
    AND T3."CardType" = 'C'  -- Solo clientes
    AND T3."GroupCode" <> 120  -- Excluir los relacionados
   AND T0."DocDueDate" < CURRENT_DATE 
    --AND ADD_DAYS(T0."DocDueDate", COALESCE(T2."TolDays", 0)) < CURRENT_DATE 
GROUP BY 
    T0."DocEntry",
    T1."SlpName",
    T0."CardCode", 
    T0."CardName",
    T0."DocType",  
    T0."DocNum",  
    T0."DocDate",  
    T2."TolDays",  
    T0."DocDueDate";


    /* reporte de cartera vencida */

    SELECT 
    T0."DocEntry",
    T1."SlpName" AS "Ejecutivo Asignado",
    --T0."CardCode" AS "Codigo Cliente",
    T0."CardName" AS "Nombre Cliente",
    CASE 
        WHEN T0."DocType" = 'I'   THEN 'Artículo' 
        WHEN T0."DocType" = 'S'   THEN 'Servicio' 
        ELSE ' ' 
    END AS "Tipo de Documento",
    T0."DocNum" AS "# Documento",
    T0."DocDate" AS "Fecha de Emisión de Documento",
  
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Vencimiento",
    COALESCE(T2."TolDays", 0) AS "Días de tolerancia",

    -- Sumar días de vencimiento y días de tolerancia
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) + COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",

    SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) AS "Saldo Vencido"
FROM 
    OINV T0
INNER JOIN 
    OCRD T3 ON T0."CardCode" = T3."CardCode"  -- Información del socio de negocio
INNER JOIN 
    OCTG T2 ON T0."GroupNum" = T2."GroupNum"  -- Condiciones de pago - definiciones
INNER JOIN 
    OSLP T1 ON T3."SlpCode" = T1."SlpCode"  -- Información del ejecutivo asignado
WHERE 
    T0."DocStatus" = 'O'
    AND T3."CardType" = 'C'  -- Solo clientes
    AND T3."GroupCode" <> 120  -- Excluir los relacionados
    AND T0."DocDueDate" < CURRENT_DATE  
GROUP BY 
    T0."DocEntry",
    T1."SlpName",
    T0."CardCode", 
    T0."CardName",
    T0."DocType",  
    T0."DocNum",  
    T0."DocDate",  
    T2."TolDays",  
    T0."DocDueDate";


    /* aprobado */
SELECT 
    --T0."DocEntry",
    T1."SlpName" AS "Ejecutivo Asignado",
    --T0."CardCode" AS "Codigo Cliente",
    T0."CardName" AS "Nombre Cliente",
    CASE 
        WHEN T0."DocType" = 'I'   THEN 'Fact. de Artículo' 
        WHEN T0."DocType" = 'S'   THEN 'Fact de Servicio' 
        ELSE ' ' 
    END AS "Tipo de Documento",
    T0."DocNum" AS "# Documento",
    T0."DocDate" AS "Fecha de Emisión de Documento",
  
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Vencimiento",
    --COALESCE(T2."TolDays", 0) AS "Días de tolerancia",

    -- Sumar días de vencimiento y días de tolerancia
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) - COALESCE(T2."TolDays", 0) AS "Dias de Vencimiento (inc. Dias Tolerancia)",

    T0."DocCur",

    SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) AS "Saldo Vencido"
FROM 
    OINV T0
INNER JOIN 
    OCRD T3 ON T0."CardCode" = T3."CardCode"  -- Información del socio de negocio
INNER JOIN 
    OCTG T2 ON T0."GroupNum" = T2."GroupNum"  -- Condiciones de pago - definiciones
INNER JOIN 
    OSLP T1 ON T3."SlpCode" = T1."SlpCode"  -- Información del ejecutivo asignado
WHERE 
    T0."DocStatus" = 'O'
    AND T3."CardType" = 'C'  -- Solo clientes
    AND T3."GroupCode" <> 120  -- Excluir los relacionados
    AND T0."DocDueDate" < CURRENT_DATE  
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
    T0."DocDueDate";