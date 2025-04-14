SELECT
    T0."DocNum" AS "Número de Solicitud",
    T0."DocDate" AS "Fecha de Solicitud",
    CASE 
        WHEN T0."DocStatus" = 'O' THEN 'Abierto'
        WHEN T0."DocStatus" = 'C' THEN 'Cerrado'
        ELSE T0."DocStatus"
    END AS "Estado",
    CASE 
        WHEN T0."DocType" = 'I' THEN 'Articulo'
        WHEN T0."DocType" = 'S' THEN 'Servicio'
    END AS "Tipo",
    T1."ItemCode" AS "Código de Artículo",
    T1."Dscription" AS "Descripción del Artículo",
    T1."Quantity" AS "Cantidad Solicitada",
    T2."U_NAME" AS "Nombre del Usuario que Creó la Solicitud"
FROM 
    OPRQ T0
INNER JOIN 
    PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN 
    OUSR T2 ON T0."UserSign" = T2."USERID"
WHERE 
    T0."DocDate" >= ADD_DAYS(CURRENT_DATE, -7)
ORDER BY 
    T0."DocDate" DESC;


    -- **************************************************
-- LISTA DE LOS ULTIMOS 7 DIAS DE SC
-- Nombre consulta : Lista de SC de los ultimos 7 días
SELECT
    T0."DocNum" AS "Número de Solicitud",
    T0."DocDate" AS "Fecha de Solicitud",
    T0."CreateDate" AS "Fecha de Creación",
    CASE 
        WHEN T0."DocStatus" = 'O' THEN 'Abierto'
        WHEN T0."DocStatus" = 'C' THEN 'Cerrado'
        ELSE T0."DocStatus"
    END AS "Estado",
    CASE 
        WHEN T0."DocType" = 'I' THEN 'Artículo'
        WHEN T0."DocType" = 'S' THEN 'Servicio'
    END AS "Tipo",
    T1."ItemCode" AS "Código de Artículo",
    T1."Dscription" AS "Descripción del Artículo",
    T1."Quantity" AS "Cantidad Solicitada",
    T2."U_NAME" AS "Nombre del Usuario que Creó la Solicitud"
FROM 
    OPRQ T0
INNER JOIN 
    PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN 
    OUSR T2 ON T0."UserSign" = T2."USERID"
WHERE 
    T0."CreateDate" >= ADD_DAYS(CURRENT_DATE, -7)
ORDER BY 
    T0."CreateDate" DESC;

TODOS los del dia de hoy de creacion

-- - LISTA DE LAS SC CREADAS HOY
-- Nombre de la consulta : Alarma SC las del día de hoy
SELECT
    T0."DocNum" AS "Número de Solicitud",
    T0."DocDate" AS "Fecha de Solicitud",
    T0."CreateDate" AS "Fecha de Creación",
    CASE 
        WHEN T0."DocStatus" = 'O' THEN 'Abierto'
        WHEN T0."DocStatus" = 'C' THEN 'Cerrado'
        ELSE T0."DocStatus"
    END AS "Estado",
    CASE 
        WHEN T0."DocType" = 'I' THEN 'Artículo'
        WHEN T0."DocType" = 'S' THEN 'Servicio'
    END AS "Tipo",
    T1."ItemCode" AS "Código de Artículo",
    T1."Dscription" AS "Descripción del Artículo",
    T1."Quantity" AS "Cantidad Solicitada",
    T2."U_NAME" AS "Nombre del Usuario que Creó la Solicitud"
FROM 
    OPRQ T0
INNER JOIN 
    PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN 
    OUSR T2 ON T0."UserSign" = T2."USERID"
WHERE 
    T0."CreateDate" >= CURRENT_DATE AND T0."CreateDate" < ADD_DAYS(CURRENT_DATE, 1)
ORDER BY 
    T0."CreateDate" DESC;



-- **************************************************
-- OPCION 1
SELECT
    T0."DocNum" AS "Número de Solicitud",
    T0."DocDate" AS "Fecha de Solicitud",
    T0."CreateDate" AS "Fecha de Creación",
    T0."DocTime" AS "Hora de Creación",
    CASE 
        WHEN T0."DocStatus" = 'O' THEN 'Abierto'
        WHEN T0."DocStatus" = 'C' THEN 'Cerrado'
        ELSE T0."DocStatus"
    END AS "Estado",
    CASE 
        WHEN T0."DocType" = 'I' THEN 'Artículo'
        WHEN T0."DocType" = 'S' THEN 'Servicio'
    END AS "Tipo",
    T1."ItemCode" AS "Código de Artículo",
    T1."Dscription" AS "Descripción del Artículo",
    T1."Quantity" AS "Cantidad Solicitada",
    T2."U_NAME" AS "Nombre del Usuario que Creó la Solicitud"
FROM 
    OPRQ T0
INNER JOIN 
    PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN 
    OUSR T2 ON T0."UserSign" = T2."USERID"
WHERE 
    T0."CreateDate" = CURRENT_DATE AND 
    T0."DocTime" = EXTRACT(HOUR FROM CURRENT_TIMESTAMP) * 60 + EXTRACT(MINUTE FROM CURRENT_TIMESTAMP)
   
ORDER BY 
    T0."CreateDate" DESC, 
    T0."DocTime" DESC;


-- **************************************************************
-- OPCION 2
SELECT
    T0."DocNum" AS "Número de Solicitud",
    T0."DocDate" AS "Fecha de Solicitud",
    T0."CreateDate" AS "Fecha de Creación",
    T0."DocTime" AS "Hora de Creación",
    CASE 
        WHEN T0."DocStatus" = 'O' THEN 'Abierto'
        WHEN T0."DocStatus" = 'C' THEN 'Cerrado'
        ELSE T0."DocStatus"
    END AS "Estado",
    CASE 
        WHEN T0."DocType" = 'I' THEN 'Artículo'
        WHEN T0."DocType" = 'S' THEN 'Servicio'
    END AS "Tipo",
    T1."ItemCode" AS "Código de Artículo",
    T1."Dscription" AS "Descripción del Artículo",
    T1."Quantity" AS "Cantidad Solicitada",
    T2."U_NAME" AS "Nombre del Usuario que Creó la Solicitud"
FROM 
    OPRQ T0
INNER JOIN 
    PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN 
    OUSR T2 ON T0."UserSign" = T2."USERID"
WHERE 
    T0."CreateDate" = CURRENT_DATE AND 
    T0."DocTime" BETWEEN 
        (EXTRACT(HOUR FROM CURRENT_TIMESTAMP) * 60 + EXTRACT(MINUTE FROM CURRENT_TIMESTAMP) - 10)
        AND
        (EXTRACT(HOUR FROM CURRENT_TIMESTAMP) * 60 + EXTRACT(MINUTE FROM CURRENT_TIMESTAMP))
ORDER BY 
    T0."CreateDate" DESC, 
    T0."DocTime" DESC;
