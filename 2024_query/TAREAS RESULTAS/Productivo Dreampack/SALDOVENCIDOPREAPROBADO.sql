SELECT
    T0."CardCode" AS "Código Cliente",
    T0."CardName" AS "Nombre Cliente",
    T1."SlpName" AS "Ejecutivo",
    T2."CreditLine" AS "Límite de Crédito",
    SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) AS "Saldo Vencido",
    T0."DocEntry" AS "Número Documento",
    T0."DocNum" AS "Número Factura",
    T0."DocDate" AS "Fecha Contabilización",
    T0."DocDueDate" AS "Fecha Vencimiento",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Atraso",
    CASE WHEN T0."DocStatus" = 'O' THEN 'Abierto' ELSE ' ' END AS "Estado"
FROM 
    OINV T0
    INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  -- Información del socio de negocio
    INNER JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"    -- Información del ejecutivo
    INNER JOIN (
        SELECT "CardCode", MIN("DocDueDate") AS "MinDueDate", "CardName"
        FROM OINV
        WHERE "DocStatus" = 'O' AND "DocDueDate" < CURRENT_DATE
        GROUP BY "CardCode",  "CardName"
    ) AS SubQuery ON T0."CardCode" = SubQuery."CardCode" AND T0."DocDueDate" = SubQuery."MinDueDate" AND T0."CardName" = SubQuery."CardName"
WHERE 
    T0."DocStatus" = 'O'
    AND T0."DocDueDate" < CURRENT_DATE
    AND T2."GroupCode" <> 120
GROUP BY 
    T0."CardCode", 
    T0."CardName", 
    T1."SlpName", 
    T2."CreditLine", 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."DocDueDate", 
    T0."DocStatus"
HAVING 
    (
      MAX(T2."U_SYP_TCONTRIB") = 99 AND 
      DAYS_BETWEEN( MAX(T0."DocDueDate"), CURRENT_DATE) > 90 --si existe al menos un registro  99 = "Exterior" y si tiene más de 90 días vencidos
     ) 
    OR MAX(T2."U_SYP_TCONTRIB") <> 99  --se incluyan los registros que no tienen el valor 99
ORDER BY 
    T0."CardName", 
    T0."DocDueDate";


    /* SALDO VENCIDO APROBADO EN ALERTA */

DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO_VENCIDO INT;
BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Contar cuántos documentos están abiertos y vencidos para el cliente específico
    SELECT COUNT(*) INTO SALDO_VENCIDO
    FROM OINV T0
    INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"
    WHERE 
        T0."DocStatus" = 'O'
        AND T0."DocDueDate" < CURRENT_DATE
        AND T2."GroupCode" <> 120
        AND T2."Balance" > 0
        AND T0."CardCode" = :CLIENTE; 

    IF (:SALDO_VENCIDO > 0) THEN
        SELECT 'TRUE' FROM DUMMY; 
    ELSE
        SELECT 'FALSE' FROM DUMMY;
    END IF;
END;


/* pruebas 12-11-2024 */
SELECT
    --T2."GroupCode",
    --T2."GroupCode", 
    --T2."U_SYP_TCONTRIB",
    T0."CardCode" AS "Código Cliente",
    T0."CardName" AS "Nombre Cliente",
    T1."SlpName" AS "Ejecutivo",
    T2."CreditLine" AS "Límite de Crédito",
    SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) AS "Saldo Vencido",
    T0."DocEntry" AS "Número Documento",
    T0."DocNum" AS "Número Factura",
    T0."DocDate" AS "Fecha Contabilización",
    T0."DocDueDate" AS "Fecha Vencimiento",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Atraso",
    CASE WHEN T0."DocStatus" = 'O' THEN 'Abierto' ELSE ' ' END AS "Estado"
FROM 
    OINV T0
    INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  -- Información del socio de negocio
    INNER JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"    -- Información del ejecutivo
    INNER JOIN (
        SELECT "CardCode", MIN("DocDueDate") AS "MinDueDate", "CardName"
        FROM OINV
        WHERE "DocStatus" = 'O' AND "DocDueDate" < CURRENT_DATE
        GROUP BY "CardCode",  "CardName"
    ) AS SubQuery ON T0."CardCode" = SubQuery."CardCode" AND T0."DocDueDate" = SubQuery."MinDueDate" AND T0."CardName" = SubQuery."CardName"
WHERE 
    T0."DocStatus" = 'O'
    AND T0."DocDueDate" < CURRENT_DATE
    AND T2."GroupCode" <> 120   --EXCLUIR LOS RELACIONADOS
GROUP BY 
    --T2."GroupCode", 
    --T2."GroupCode",
    --T2."U_SYP_TCONTRIB",
    T0."CardCode", 
    T0."CardName", 
    T1."SlpName", 
    T2."CreditLine", 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."DocDueDate", 
    T0."DocStatus"
HAVING 
    (
      MAX(T2."U_SYP_TCONTRIB") = 99 AND 
      DAYS_BETWEEN( MAX(T0."DocDueDate"), CURRENT_DATE) > 90 --si existe al menos un registro  99 = "Exterior" y si tiene más de 90 días vencidos
     ) 
    OR MAX(T2."U_SYP_TCONTRIB") <> 99  --se incluyan los registros que no tienen el valor 99
ORDER BY 
    T0."CardName", 
    T0."DocDueDate";


    ----------------------------
DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO_VENCIDO INT;
BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Contar cuántos documentos están abiertos y vencidos para el cliente específico
    SELECT COUNT(*) INTO SALDO_VENCIDO
    FROM OINV T0
    INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"
    WHERE 
        T0."DocStatus" = 'O'
        AND T0."DocDueDate" < CURRENT_DATE
        AND T2."GroupCode" <> 120
        AND T2."Balance" > 0
        AND T0."CardCode" = :CLIENTE; 

    IF (:SALDO_VENCIDO > 0) THEN
        SELECT 'TRUE' FROM DUMMY; 
    ELSE
        SELECT 'FALSE' FROM DUMMY;
    END IF;
END;




/* SALDO VENCIDO - add días de tolerancia en Condiciones de pago - definiciones */

SELECT 
  T0."CardCode" AS "Codigo Cliente",
  T0."CardName" AS "Nombre Cliente",
  SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) AS "Saldo Vencido",
  COALESCE(T2."TolDays", 0) AS "Dias de tolerancia"
FROM OINV T0
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"  -- Información del socio de negocio
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"  -- Condiciones de pago - definiciones
WHERE 
    T0."DocStatus" = 'O'
     AND T1."CardType" = 'C'  --Solo clientes
     --AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior
      --AND T1."GroupNum" = -1  --Solo cliente contado 
     --AND T0."DocDueDate" < CURRENT_DATE
    AND T1."GroupCode" <> 120 ----EXCLUIR LOS RELACIONADOS
    AND ADD_DAYS(T0."DocDueDate", COALESCE(T2."TolDays", 0)) < CURRENT_DATE 
GROUP BY 
    T0."CardCode", 
    T0."CardName",
    T2."TolDays";


    /* ************* */
SELECT 
  T0."CardCode" AS "Codigo Cliente",
  T0."CardName" AS "Nombre Cliente",
  T0."DocDueDate",
  COALESCE(T2."TolDays", 0) AS "Dias de tolerancia",
  ADD_DAYS(T0."DocDueDate", COALESCE(T2."TolDays", 0)) AS "Fecha Vencimiento + Días de Tolerancia",
  SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) AS "Saldo Vencido"
  
FROM OINV T0
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"  -- Información del socio de negocio
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"  -- Condiciones de pago - definiciones
WHERE 
    T0."DocStatus" = 'O'
     AND T1."CardType" = 'C'  --Solo clientes
     --AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior
      --AND T1."GroupNum" = -1  --Solo cliente contado 
     --AND T0."DocDueDate" < CURRENT_DATE
    AND T1."GroupCode" <> 120 ----EXCLUIR LOS RELACIONADOS
    AND ADD_DAYS(T0."DocDueDate", COALESCE(T2."TolDays", 0)) < CURRENT_DATE 
GROUP BY 
    T0."CardCode", 
    T0."CardName",
    T2."TolDays",
    T0."DocDueDate"