

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
ORDER BY 
    T0."CardName", 
    T0."DocDueDate";


    -- ***************************

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
ORDER BY 
    T0."CardName", 
    T0."DocDueDate";


    -- ********************

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
    AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90  -- Solo incluir documentos con más de 90 días de atraso
    AND T2."U_SYP_TCONTRIB" = '99'  -- Filtrar por tipo de contribuyente
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
ORDER BY 
    T0."CardName", 
    T0."DocDueDate";



    /* anteriores  */



    /* 
    

    /*
SELECT     
   T0."CardCode" AS "Código Cliente",    
   T0."CardName" AS "Nombre Cliente",    
   T1."SlpName" AS "Ejecutivo",    
   T2."CreditLine" AS "Límite de Crédito",    
    SUM(CASE         WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE         THEN T0."DocTotal" - T0."PaidToDate"        ELSE 0     END) AS "Saldo Vencido",    
    T0."DocEntry" AS "Número Documento",    
    T0."DocNum" AS "Número Factura",    
    T0."DocDate" AS "Fecha Contabilización",    
    T0."DocDueDate" AS "Fecha Vencimiento",    
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Atraso",    
    CASE WHEN T0."DocStatus" = 'O' THEN 'Abierto' ELSE ' ' END AS "Estado"
FROM     OINV T0   
 INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  -- Información del socio de negocio    
INNER JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"    -- Información del ejecutivo    
INNER JOIN (        
  SELECT "CardCode", MIN("DocDueDate") AS "MinDueDate", "CardName"        
  FROM OINV       
  WHERE "DocStatus" = 'O' AND "DocDueDate" < CURRENT_DATE        
   GROUP BY "CardCode",  "CardName"   
 ) AS SubQuery ON T0."CardCode" = SubQuery."CardCode" AND T0."DocDueDate" = SubQuery."MinDueDate" AND T0."CardName" = SubQuery."CardName"
WHERE     
  T0."DocStatus" = 'O'    AND 
  T0."DocDueDate" < CURRENT_DATE
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
ORDER BY     
  T0."CardName",     
  T0."DocDueDate";

 */

SELECT     
  T0."CardCode" AS "Código Cliente",    
  T0."CardName" AS "Nombre Cliente",    
  T1."SlpName" AS "Ejecutivo",    
  T2."CreditLine" AS "Límite de Crédito",    
  SUM(CASE  WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE  THEN T0."DocTotal" - T0."PaidToDate"  ELSE 0  END) AS "Saldo Vencido",    
  T0."DocEntry" AS "Número Documento",    
  T0."DocNum" AS "Número Factura",    
  T0."DocDate" AS "Fecha Contabilización",    
  T0."DocDueDate" AS "Fecha Vencimiento",    
  DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Atraso",    
  CASE WHEN T0."DocStatus" = 'O' THEN 'Abierto' ELSE ' ' END AS "Estado"
FROM     OINV T0    
INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  -- Información del socio de negocio    
INNER JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"    -- Información del ejecutivo
WHERE     
  T0."DocStatus" = 'O'   AND 
  T0."DocDueDate" < CURRENT_DATE    
   AND (        
      ( T2."U_SYP_TCONTRIB" = '99' AND 
        DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90
       ) -- Clientes del exterior con más de 90 días        
       --OR         --(T2."GroupCode" <> 'RELACIONADOS') -- Excluir clientes en el grupo RELACIONADOS    
   )
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
ORDER BY     
  T0."CardName",     
  T0."DocDueDate";
    
    
    
     */



     /* Por el momento auth saldo vencidod que no incluya los relacionados del grupo */

SELECT
    --T2."GroupCode", 
    T2."U_SYP_TCONTRIB",
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
    --T2."GroupCode",
    T2."U_SYP_TCONTRIB",
    T0."CardCode", 
    T0."CardName", 
    T1."SlpName", 
    T2."CreditLine", 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."DocDueDate", 
    T0."DocStatus"
ORDER BY 
    T0."CardName", 
    T0."DocDueDate";



    /* ya esta verificar  */
SELECT
    --T2."GroupCode", 
    T2."U_SYP_TCONTRIB",
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
    --T2."GroupCode",
    T2."U_SYP_TCONTRIB",
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


/* APROBADO - listo saldo vencidos ultima modificacion esperando que se apruebe en produccion */
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

    -- *******************APROBADO Aut saldo vencido Productivo******************************

DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO_VENCIDO INT;
BEGIN
   
     SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Verificar cuántas facturas están abiertas y vencidas
    SELECT COUNT(*) INTO SALDO_VENCIDO 
    FROM OINV T0 
    WHERE T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
    AND T0."CardCode" = :CLIENTE;

   IF (:SALDO_VENCIDO > 0) THEN
       SELECT 'TRUE'  FROM DUMMY;
    ELSE
        SELECT 'FALSE' FROM DUMMY;  
    END IF;
END;

/* AHI QUE RELAIZAR LAS PRUEBAS */
/* alert para Preubas Dreampack  */
/* Opcion 1 */
DECLARE 
    CLIENTE VARCHAR(20);
    SALDO_VENCIDO INT;
BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Verificar cuántas entregas están abiertas y vencidas
    SELECT COUNT(*) INTO SALDO_VENCIDO 
    FROM ODLN T0
    INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  -- Información del socio de negocio
    INNER JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"    -- Información del ejecutivo
    WHERE 
        T0."DocStatus" = 'O' 
        AND T0."DocDueDate" < CURRENT_DATE 
        AND T0."CardCode" = :CLIENTE
        AND T2."GroupCode" <> 120
    GROUP BY 
        T0."CardCode", 
        T0."CardName", 
        T1."SlpName", 
        T2."CreditLine"
    HAVING 
        (
            MAX(T2."U_SYP_TCONTRIB") = 99 AND 
            DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90 -- Si existe al menos un registro 99 = "Exterior" y si tiene más de 90 días vencidos
        ) 
        OR MAX(T2."U_SYP_TCONTRIB") <> 99;  -- Se incluyan los registros que no tienen el valor 99

   IF (:SALDO_VENCIDO > 0) THEN
       SELECT 'TRUE' FROM DUMMY;
   ELSE
       SELECT 'FALSE' FROM DUMMY;  
   END IF;
END;


/* Opcion 2 NO*/
/* DECLARE 
    CLIENTE VARCHAR(20);
    SALDO_VENCIDO INT;
    LIMITE_CREDITO INT;
BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Obtener el límite de crédito del cliente
    SELECT T2."CreditLine" INTO LIMITE_CREDITO 
    FROM OCRD T2 
    WHERE T2."CardCode" = :CLIENTE;

    -- Verificar cuántas entregas están abiertas y vencidas
    SELECT COUNT(*) INTO SALDO_VENCIDO 
    FROM ODLN T0
    INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  -- Información del socio de negocio
    INNER JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"    -- Información del ejecutivo
    WHERE 
        T0."DocStatus" = 'O' 
        AND T0."DocDueDate" < CURRENT_DATE 
        AND T0."CardCode" = :CLIENTE
        AND T2."GroupCode" <> 120
    GROUP BY 
        T0."CardCode", 
        T0."CardName", 
        T1."SlpName", 
        T2."CreditLine"
    HAVING 
        (
            SUM(CASE WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE THEN T0."DocTotal" - T0."PaidToDate" ELSE 0 END) > LIMITE_CREDITO
            AND MAX(T2."U_SYP_TCONTRIB") = 99 
            AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90 -- Si existe al menos un registro 99 = "Exterior" y si tiene más de 90 días vencidos
        ) 
        OR (MAX(T2."U_SYP_TCONTRIB") <> 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) < 90); -- Se incluyan los registros que no tienen el valor 99

   IF (SALDO_VENCIDO > 0) THEN
       SELECT 'TRUE' FROM DUMMY;
   ELSE
       SELECT 'FALSE' FROM DUMMY;  
   END IF;
END; */


/* Aut - Autoriza Pedido Limite Credito */
DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
BEGIN
SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;
--SELECT 'C0102876901001' INTO CLIENTE FROM DUMMY;

SELECT 
    T0."Balance", 
    T0."CreditLine" INTO SALDO, LIMITE_CREDITO FROM OCRD T0 WHERE T0."CardType"  = 'C' AND T0."CardCode" = :CLIENTE;
--SELECT 500, 501 INTO SALDO,LIMITE_CREDITO FROM DUMMY;

IF((:LIMITE_CREDITO=0 AND SALDO=0) OR :SALDO + :TOTAL_OV<:LIMITE_CREDITO) THEN
   SELECT 'FALSE' FROM DUMMY;
ELSE
     SELECT 'TRUE' FROM DUMMY;
END IF;

END;


-- ***************************************************************************

DECLARE 
    CLIENTE NVARCHAR(20);
    SALDO_VENCIDO INT;
BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Verificar cuántas entregas están abiertas y vencidas
    SELECT COUNT(*) INTO SALDO_VENCIDO 
    FROM (
        SELECT 
            T0."CardCode", 
            T0."CardName", 
            T1."SlpName", 
            T2."CreditLine",
            T2."U_SYP_TCONTRIB",
            T0."DocDueDate"
        FROM ODLN T0
        INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  -- Información del socio de negocio
        INNER JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"    -- Información del ejecutivo
        WHERE 
            T0."DocStatus" = 'O' 
            AND T0."DocDueDate" < CURRENT_DATE 
            AND T0."CardCode" = :CLIENTE
            AND T2."GroupCode" <> 120
        GROUP BY 
            T0."CardCode", 
            T0."CardName", 
            T1."SlpName", 
            T2."CreditLine",
            T2."U_SYP_TCONTRIB",
            T0."DocDueDate"
        HAVING 
            (
                MAX(T2."U_SYP_TCONTRIB") = 99 AND 
                DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90 -- Si existe al menos un registro 99 = "Exterior" y si tiene más de 90 días vencidos
            ) 
            OR MAX(T2."U_SYP_TCONTRIB") <> 99  -- Se incluyan los registros que no tienen el valor 99
    ) AS Subquery;

    IF (:SALDO_VENCIDO > 0) THEN
        SELECT 'TRUE' FROM DUMMY;
    ELSE
        SELECT 'FALSE' FROM DUMMY;  
    END IF;
END;


/*DECLARE CLIENTE VARCHAR(20);
  DECLARE SALDO_VENCIDO INT;
BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Verificar cuántas entregas están abiertas y vencidas
    SELECT COUNT(*) INTO SALDO_VENCIDO 
    FROM ODLN T0
    INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  -- Información del socio de negocio
    INNER JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"    -- Información del ejecutivo
    WHERE 
        T0."DocStatus" = 'O' 
        AND T0."DocDueDate" < CURRENT_DATE 
        AND T0."CardCode" = :CLIENTE
        AND T2."GroupCode" <> 120;

    GROUP BY 
        T0."CardCode", 
        T0."CardName", 
        T1."SlpName", 
        T2."CreditLine"
    HAVING 
        (
            MAX(T2."U_SYP_TCONTRIB") = 99 AND 
            DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90 -- Si existe al menos un registro 99 = "Exterior" y si tiene más de 90 días vencidos
        ) 
        OR MAX(T2."U_SYP_TCONTRIB") <> 99; -- Se incluyan los registros que no tienen el valor 99

   IF (:SALDO_VENCIDO > 0) THEN
       SELECT 'TRUE' FROM DUMMY;
   ELSE
       SELECT 'FALSE' FROM DUMMY;  
   END IF;
END;*/


/* prueba */

DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO_VENCIDO INT;
BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Verificar el saldo vencido para el cliente específico
    SELECT SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) INTO SALDO_VENCIDO
    FROM OINV T0
    INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  -- Información del socio de negocio
    INNER JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"    -- Información del ejecutivo
    WHERE 
        T0."DocStatus" = 'O'
        AND T0."DocDueDate" < CURRENT_DATE
        AND T0."CardCode" = :CLIENTE  -- Filtrar por el cliente específico
        AND T2."GroupCode" <> 120;

    -- Comprobar si hay saldo vencido y devolver el resultado
    IF (:SALDO_VENCIDO > 0) THEN
        SELECT 'TRUE' FROM DUMMY;  -- Retornar TRUE si hay saldo vencido
    ELSE
        SELECT 'FALSE' FROM DUMMY;  -- Retornar FALSE si no hay saldo vencido
    END IF;
END;


/* este seria la prueba*/


DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO_VENCIDO DECIMAL(19, 4);  
BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Verificar el saldo vencido para el cliente específico en la tabla de entregas (ODLN)
    SELECT SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) INTO SALDO_VENCIDO
    FROM ODLN T0
    INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  
    INNER JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"
    WHERE 
        T0."DocStatus" = 'O'
        AND T0."DocDueDate" < CURRENT_DATE
        AND T0."CardCode" = :CLIENTE
        AND T2."GroupCode" <> 120;

    IF (:SALDO_VENCIDO > 0) THEN
        SELECT 'TRUE' FROM DUMMY; 
    ELSE
        SELECT 'FALSE' FROM DUMMY;
    END IF;
END;

/* ANTERIOR */
DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO_VENCIDO DECIMAL(19, 4);  
BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Verificar el saldo vencido para el cliente específico en la tabla de entregas (ODLN)
    SELECT SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) INTO SALDO_VENCIDO
    FROM ODLN T0
    INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  
    INNER JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"
    WHERE 
        T0."DocStatus" = 'O'
        AND T0."DocDueDate" < CURRENT_DATE
        AND T0."CardCode" = :CLIENTE
        AND T2."GroupCode" <> 120;

    IF (:SALDO_VENCIDO > 0) THEN
        SELECT 'TRUE' FROM DUMMY; 
    ELSE
        SELECT 'FALSE' FROM DUMMY;
    END IF;
END;

/* PRUEBA */

DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO_VENCIDO DECIMAL(19, 4);
BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Verificar el saldo vencido para el cliente específico en la tabla de entregas (ODLN)
    SELECT SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) INTO SALDO_VENCIDO
    FROM ODLN T0
    INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  
    INNER JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"    
    WHERE  
        T0."DocStatus" = 'O'
        AND T0."DocDueDate" < CURRENT_DATE
        AND T2."GroupCode" <> 120
        AND T0."CardCode" = :CLIENTE
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
            DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90
        ) 
        OR MAX(T2."U_SYP_TCONTRIB") <> 99;

    
    IF (:SALDO_VENCIDO > 0) THEN
        SELECT 'TRUE' FROM DUMMY;
    ELSE
        SELECT 'FALSE' FROM DUMMY;
    END IF;
END;

