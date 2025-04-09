SELECT 
  T0."DocEntry",
  --T0."DocStatus",
  T1."CardName",
  T2."PymntGroup",
  T1."CreditLine",
  T0."NumAtCard",
  T0."DocDueDate"
  --*
FROM OINV T0
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN OCTG T2 ON T1."GroupNum" = T2."GroupNum"
WHERE 
    T0."DocStatus" = 'O'
    AND T0."DocDueDate" < CURRENT_DATE
    AND T1."CardType" = 'C'
    AND T1."QryGroup19" = 'Y'
--LIMIT 10




-- ***************************************

SELECT 
    T0."CardCode" AS "Código del Cliente",
    T0."CardName" AS "Nombre del Cliente",
    --T0."QryGroup19" AS "Seguro de Crédito",
    --T0."GroupNum" AS "Condición de Pago",
    MAX(T2."PymntGroup") AS "Condición de Pago",
    T0."CreditLine" AS "Límite de Crédito",
    MAX(T1."NumAtCard") AS "Número de Referencia"--,
    /*DAYS_BETWEEN(T1."DocDueDate", CURRENT_DATE) AS "Días Pendientes",
    T1."DocDueDate" AS "Fecha de Vencimiento",
    SUM(T1."DocTotal") AS "Suma Importe Original",
    SUM(T1."DocTotal" - T1."PaidToDate") AS "Suma Total Cartera",
    SUM(CASE WHEN T1.""DocDueDate" > GETDATE() THEN T1."DocTotal" ELSE 0 END) AS "Suma por Vencer"*/
FROM 
    OCRD T0
INNER JOIN 
    OINV T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
WHERE 
   T1."DocStatus" = 'O'
    --AND T1."DocDueDate" < CURRENT_DATE
    AND T0."CardType" = 'C'
    AND T0."QryGroup19" = 'Y'
GROUP BY 
    T0."CardCode", 
    T0."CardName", 
    T0."QryGroup19",
    T0."CreditLine",
    T1."DocDueDate";


    -- *********************


-- Realizando el nuevo query  /* rivisando l srta xiomara macias */
SELECT 
    T0."CardCode" AS "Código del Cliente",
    T0."CardName" AS "Nombre del Cliente", 
    MAX(T2."PymntGroup") AS "Condición de Pago",
    T0."CreditLine" AS "Límite de Crédito",
    MAX(T1."NumAtCard") AS "Número de Referencia",
    DAYS_BETWEEN(T1."DocDueDate", CURRENT_DATE) AS "Días Pendientes",
    T1."DocDueDate" AS "Fecha de Vencimiento",
    SUM(T1."DocTotal") AS "Suma Importe Original",
    SUM(T1."DocTotal" - T1."PaidToDate") AS "Suma Total Cartera",
    SUM(
       CASE 
           WHEN T1."DocDueDate" > GETDATE() THEN T1."DocTotal" 
            ELSE 0 
       END
    ) AS "Suma por Vencer"
FROM 
    OCRD T0
INNER JOIN 
    OINV T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
WHERE 
   T1."DocStatus" = 'O'
    --AND T1."DocDueDate" < CURRENT_DATE
    AND T0."CardType" = 'C'
    AND T0."QryGroup19" = 'Y'
GROUP BY 
    T0."CardCode", 
    T0."CardName", 
    T0."QryGroup19",
    T0."CreditLine",
    T1."DocDueDate"
ORDER BY 
T0."CardName";

/* listo aprobado por xiomara */
/* Facturas Vencidas - Seguro Credito */

SELECT 
    T0."CardCode" AS "Código del Cliente",
    T0."CardName" AS "Nombre del Cliente", 
    T2."PymntGroup" AS "Condición de Pago",
    T0."CreditLine" AS "Límite de Crédito",
    T1."NumAtCard" AS "Número de Referencia",
    DAYS_BETWEEN(T1."DocDueDate", CURRENT_DATE) AS "Días Pendientes",
    T1."DocDueDate" AS "Fecha de Vencimiento",
    T1."DocTotal" AS "Suma Importe Original",
    T1."DocTotal" - T1."PaidToDate" AS "Suma Total Cartera",
    CASE 
        WHEN T1."DocDueDate" > GETDATE() THEN T1."DocTotal" 
        ELSE 0 
    END
    AS "Suma por Vencer"
FROM 
    OCRD T0
INNER JOIN 
    OINV T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
WHERE 
   T1."DocStatus" = 'O'
    --AND T1."DocDueDate" < CURRENT_DATE
    AND T0."CardType" = 'C'
    AND T0."QryGroup19" = 'Y'
ORDER BY 
T0."CardName";