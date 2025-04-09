/*  */
-- SELECT T1."GroupNum", T1."PymntGroup" FROM "SBO_FIGURETTI_PRO"."OCTG"  T1

/* lista de clientes solo que que tiene condicion de pago 'CONTADO' */
SELECT 
    T0."CardCode" AS "Código del Cliente",
    T0."CardName" AS "Nombre del Cliente",
    T1."GroupNum" AS "Número de Grupo",
    T1."PymntGroup" AS "Condicion de Pago"
FROM 
    OCRD T0
INNER JOIN 
    OCTG T1 ON T0."GroupNum" = T1."GroupNum"
WHERE 
   T1."GroupNum" = -1 --'Contado';



/* Orden de venta - Cliente Contado */
SELECT
    --T0."CardCode", 
    T1."CardCode" AS "Código del Cliente",
    T1."CardName" AS "Nombre del Cliente",
    T1."GroupCode",
    T1."Balance"
    --T2."GroupNum" AS "Número de Grupo",
    --T2."PymntGroup" AS "Condición de Pago"
FROM 
    ORDR T0
INNER JOIN 
    OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN 
    OCTG T2 ON T1."GroupNum" = T2."GroupNum"
WHERE
    T0."DocStatus" = 'O'
    AND T0."DocDueDate" < CURRENT_DATE 
    AND T1."Balance" > 0    --Saldo vencido mayor a cero
    AND T2."GroupNum" = -1  --Contado
GROUP BY 
    --T0."CardCode",
    T1."CardCode",
    T1."CardName",
    T1."GroupCode",
    T1."Balance"
HAVING 
    (
      MAX(T1."U_SYP_TCONTRIB") = 99 AND 
      DAYS_BETWEEN( MAX(T0."DocDueDate"), CURRENT_DATE) > 90 --si existe al menos un registro  99 = "Exterior" y si tiene más de 90 días vencidos
     ) 
    OR MAX(T1."U_SYP_TCONTRIB") <> 99


/* 

/*SELECT
    --T0."CardCode", 
    T1."CardCode" AS "Código del Cliente",
    T1."CardName" AS "Nombre del Cliente",
    T1."GroupCode",
    T1."Balance"
    --T2."GroupNum" AS "Número de Grupo",
    --T2."PymntGroup" AS "Condición de Pago"
FROM 
    ORDR T0
INNER JOIN 
    OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN 
    OCTG T2 ON T1."GroupNum" = T2."GroupNum"
WHERE
    T0."DocStatus" = 'O'
    AND T0."DocDueDate" < CURRENT_DATE 
    AND T1."Balance" > 0    --Saldo vencido mayor a cero
    AND T2."GroupNum" = -1  --Contado
GROUP BY 
    --T0."CardCode",
    T1."CardCode",
    T1."CardName",
    T1."GroupCode",
    T1."Balance"
HAVING 
    (
      MAX(T1."U_SYP_TCONTRIB") = 99 AND 
      DAYS_BETWEEN( MAX(T0."DocDueDate"), CURRENT_DATE) > 90 --si existe al menos un registro  99 = "Exterior" y si tiene más de 90 días vencidos
     ) 
    OR MAX(T1."U_SYP_TCONTRIB") <> 99*/
 */


    /* diagrama de flujo */
SELECT
    T1."CardCode" AS "Código del Cliente",
    T1."CardName" AS "Nombre del Cliente",
    T1."GroupCode",
    T1."Balance",
    CASE 
        WHEN T2."GroupNum" = -1 THEN 'C de Contado'
        WHEN T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90 THEN 'C exterior con Saldo mayor 90 días'
        WHEN T1."Balance" > T1."CreditLine" THEN 'Excede LC'
        WHEN T1."Balance" > 0 AND T0."DocDueDate" < CURRENT_DATE THEN 'C local con Saldo Vencido'
        ELSE 'Entrega Directa'
    END AS "Condición",
    CASE 
        WHEN T2."GroupNum" = -1 OR 
             (T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90) OR 
             (T1."Balance" > T1."CreditLine") OR 
             (T1."Balance" > 0 AND T0."DocDueDate" < CURRENT_DATE) THEN 'Proceso de Aprobación'
        ELSE 'Aprobado Directamente'
    END AS "Estado de Aprobación"
FROM 
    ORDR T0
INNER JOIN 
    OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN 
    OCTG T2 ON T1."GroupNum" = T2."GroupNum"
WHERE
    T0."DocStatus" = 'O'          -- Solo órdenes abiertas
    AND T1."Balance" > 0           -- Saldo pendiente
GROUP BY 
    T1."CardCode",
    T1."CardName",
    T1."GroupCode",
    T1."Balance",
    T2."GroupNum",
    T1."U_SYP_TCONTRIB",
    T1."CreditLine"
HAVING 
    (T2."GroupNum" = -1)                          -- Pago al contado
    OR (T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90)  -- Cliente exterior con saldo vencido > 90 días
    OR (T1."Balance" > T1."CreditLine")           -- Excede límite de crédito
    OR (T1."Balance" > 0 AND T0."DocDueDate" < CURRENT_DATE)  -- Cliente local con saldo vencido



    /* asi tengo Pruebas Dreampack*/

SELECT
    T0."CardCode",
    T1."CardCode" AS "Código del Cliente",
    T1."CardName" AS "Nombre del Cliente",
    --T1."GroupCode",
    T1."Balance",
    CASE 
        WHEN T2."GroupNum" = -1 THEN 'C de Contado'
        WHEN T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90 THEN 'C exterior con Saldo mayor 90 días'
        WHEN T1."Balance" > T1."CreditLine" THEN 'Excede LC'
        WHEN T1."Balance" > 0 AND T0."DocDueDate" < CURRENT_DATE THEN 'C local con Saldo Vencido'
        ELSE 'Entrega Directa'
    END AS "Condición",
    CASE 
        WHEN T2."GroupNum" = -1 OR 
             (T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90) OR 
             (T1."Balance" > T1."CreditLine") OR 
             (T1."Balance" > 0 AND T0."DocDueDate" < CURRENT_DATE) THEN 'Proceso de Aprobación'
        ELSE 'Aprobado Directamente'
    END AS "Estado de Aprobación"
FROM 
    ORDR T0
INNER JOIN 
    OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN 
    OCTG T2 ON T1."GroupNum" = T2."GroupNum"
WHERE
    T0."DocStatus" = 'O'         
    AND T1."Balance" > 0   
GROUP BY 
     T0."CardCode",
    T0."DocDueDate",
    T1."CardCode",
    T1."CardName",
    T1."GroupCode",
    T1."Balance",
    T2."GroupNum",
    T1."U_SYP_TCONTRIB",
    T1."CreditLine"
   
HAVING 
    (T2."GroupNum" = -1)                          -- Pago al contado
    OR (T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90)  -- Cliente exterior con saldo vencido > 90 días
    OR (T1."Balance" > T1."CreditLine")           -- Excede límite de crédito
    --OR (T1."Balance" > 0 AND T0."DocDueDate" < CURRENT_DATE)  -- Cliente local con saldo vencido



/* HACIENDO PRUEBAS */

/* anterior */
SELECT
    T0."CardCode",
    T1."CardCode" AS "Código del Cliente",
    T1."CardName" AS "Nombre del Cliente",
    --T1."GroupCode",
    T1."Balance",
    CASE 
        WHEN T2."GroupNum" = -1 THEN 'C de Contado'
        WHEN T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90 THEN 'C exterior con Saldo mayor 90 días'
        WHEN T1."Balance" > T1."CreditLine" THEN 'Excede LC'
        WHEN T1."Balance" > 0 AND T0."DocDueDate" < CURRENT_DATE THEN 'C local con Saldo Vencido'
        ELSE 'Entrega Directa'
    END AS "Condición",
    CASE 
        WHEN T2."GroupNum" = -1 OR 
             (T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90) OR 
             (T1."Balance" > T1."CreditLine") OR 
             (T1."Balance" > 0 AND T0."DocDueDate" < CURRENT_DATE) THEN 'Proceso de Aprobación'
        ELSE 'Aprobado Directamente'
    END AS "Estado de Aprobación"
FROM 
    ORDR T0
INNER JOIN 
    OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN 
    OCTG T2 ON T1."GroupNum" = T2."GroupNum"
WHERE
    T0."DocStatus" = 'O'         
    AND T1."Balance" > 0
GROUP BY 
     T0."CardCode",
    T0."DocDueDate",
    T1."CardCode",
    T1."CardName",
    T1."GroupCode",
    T1."Balance",
    T2."GroupNum",
    T1."U_SYP_TCONTRIB",
    T1."CreditLine"
   
HAVING 
    (T2."GroupNum" = -1)                          -- Pago al contado
    OR (T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90)  -- Cliente exterior con saldo vencido > 90 días
    OR (T1."Balance" > T1."CreditLine")           -- Excede límite de crédito

/* pruebas */
SELECT
    T0."CardCode",
    T1."CardCode" AS "Código del Cliente",
    T1."CardName" AS "Nombre del Cliente",
    T1."Balance",
    CASE 
        WHEN T2."GroupNum" = -1 THEN 'C de Contado'
        WHEN T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90 THEN 'C exterior con Saldo mayor 90 días'
        WHEN T1."Balance" > T1."CreditLine" THEN 'Excede LC'
        WHEN T1."Balance" > 0 AND MAX(T3."DocDueDate") < CURRENT_DATE THEN 'C local con Saldo Vencido'
        ELSE 'Entrega Directa'
    END AS "Condición",
    CASE 
        WHEN T2."GroupNum" = -1 OR 
             (T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90) OR 
             (T1."Balance" > T1."CreditLine") OR 
             (T1."Balance" > 0 AND MAX(T3."DocDueDate") < CURRENT_DATE) THEN 'Proceso de Aprobación'
        ELSE 'Aprobado Directamente'
    END AS "Estado de Aprobación"
FROM 
    ORDR T0
INNER JOIN 
    OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN 
    OCTG T2 ON T1."GroupNum" = T2."GroupNum"
LEFT JOIN (
    SELECT 
        "CardCode", 
        MAX("DocDueDate") AS "DocDueDate", 
        "DocStatus"
    FROM 
        OINV
    WHERE 
        "DocStatus" = 'O' AND "DocDueDate" < CURRENT_DATE
    GROUP BY 
        "CardCode", "DocStatus"
) T3 ON T0."CardCode" = T3."CardCode"
WHERE
    T0."DocStatus" = 'O'         
    AND T1."Balance" > 0
GROUP BY 
     T0."CardCode",
     T0."DocDueDate",
     T1."CardCode",
     T1."CardName",
     T1."GroupCode",
     T1."Balance",
     T2."GroupNum",
     T1."U_SYP_TCONTRIB",
     T1."CreditLine",
     T3."DocStatus",
      T3."DocDueDate"
HAVING 
    (T2."GroupNum" = -1)                          -- Pago al contado
    OR (T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90)  -- Cliente exterior con saldo vencido > 90 días
    OR (T1."Balance" > T1."CreditLine")           -- Excede límite de crédito
    OR (T3."DocStatus" = 'O' AND T3."DocDueDate" < CURRENT_DATE); -- Factura abierta y vencida




    /* asi quedo Perfecto */

    SELECT
    T0."CardCode",
    T1."CardCode" AS "Código del Cliente",
    T1."CardName" AS "Nombre del Cliente",
    T1."Balance",
    CASE 
        WHEN T2."GroupNum" = -1 THEN 'C de Contado'
        WHEN T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90 THEN 'C exterior con Saldo mayor 90 días'
        WHEN T1."Balance" > T1."CreditLine" THEN 'Excede LC'
        WHEN T1."Balance" > 0 AND DAYS_BETWEEN(MAX(T3."DocDueDate"), CURRENT_DATE) > 90 THEN 'C local con Saldo Vencido'
        ELSE 'Entrega Directa'
    END AS "Condición",
    CASE 
        WHEN T2."GroupNum" = -1 OR 
             (T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90) OR 
             (T1."Balance" > T1."CreditLine") OR 
             (T1."Balance" > 0 AND DAYS_BETWEEN(MAX(T3."DocDueDate"), CURRENT_DATE) > 90) THEN 'Proceso de Aprobación'
        ELSE 'Aprobado Directamente'
    END AS "Estado de Aprobación"
FROM 
    ORDR T0
INNER JOIN 
    OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN 
    OCTG T2 ON T1."GroupNum" = T2."GroupNum"
LEFT JOIN (
    SELECT 
        "CardCode", 
        MAX("DocDueDate") AS "DocDueDate", 
        "DocStatus"
    FROM 
        OINV
    WHERE 
        "DocStatus" = 'O' AND "DocDueDate" < CURRENT_DATE
    GROUP BY 
        "CardCode", "DocStatus"
) T3 ON T0."CardCode" = T3."CardCode"
WHERE
    T0."DocStatus" = 'O'         
    AND T1."Balance" > 0
GROUP BY 
     T0."CardCode",
     T0."DocDueDate",
     T1."CardCode",
     T1."CardName",
     T1."GroupCode",
     T1."Balance",
     T2."GroupNum",
     T1."U_SYP_TCONTRIB",
     T1."CreditLine",
     T3."DocStatus",
     T3."DocDueDate"
HAVING 
    (T2."GroupNum" = -1)                          -- Pago al contado
    OR (T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90)  -- Cliente exterior con saldo vencido > 90 días
    OR (T1."Balance" > T1."CreditLine")           -- Excede límite de crédito
    OR (T3."DocStatus" = 'O' AND DAYS_BETWEEN(T3."DocDueDate", CURRENT_DATE) > 90); -- Factura abierta y vencida mayor a 90 días


/* contruccion del alerta */
/* ejemplo 1 */
--DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
--DECLARE TOTAL_OV DECIMAL(19,2);
DECLARE CONDICION VARCHAR(100);
DECLARE ESTADO_APROBACION VARCHAR(100);

BEGIN
    -- Obtener el cliente y el total de la orden
    --SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;
    -- SELECT 'C0102876901001' INTO CLIENTE FROM DUMMY;

    -- Obtener el saldo y límite de crédito del cliente
    SELECT T1."Balance", T1."CreditLine" INTO SALDO, LIMITE_CREDITO 
    FROM OCRD T1 
    WHERE T1."CardCode" = :CLIENTE;

    -- Evaluar condiciones según la lógica original
    SELECT 
        CASE 
            WHEN T2."GroupNum" = -1 THEN 'C de Contado'
            WHEN T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90 THEN 'C exterior con Saldo mayor 90 días'
            WHEN SALDO > LIMITE_CREDITO THEN 'Excede LC'
            WHEN SALDO > 0 AND DAYS_BETWEEN(MAX(T3."DocDueDate"), CURRENT_DATE) > 90 THEN 'C local con Saldo Vencido'
            ELSE 'Entrega Directa'
        END INTO CONDICION,
        CASE 
            WHEN T2."GroupNum" = -1 OR 
                 (T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90) OR 
                 (SALDO > LIMITE_CREDITO) OR 
                 (SALDO > 0 AND DAYS_BETWEEN(MAX(T3."DocDueDate"), CURRENT_DATE) > 90) THEN 'Proceso de Aprobación'
            ELSE 'Aprobado Directamente'
        END INTO ESTADO_APROBACION
    FROM 
        ORDR T0
    INNER JOIN 
        OCRD T1 ON T0."CardCode" = T1."CardCode"
    INNER JOIN 
        OCTG T2 ON T1."GroupNum" = T2."GroupNum"
    LEFT JOIN (
        SELECT 
            "CardCode", 
            MAX("DocDueDate") AS "DocDueDate", 
            "DocStatus"
        FROM 
            OINV
        WHERE 
            "DocStatus" = 'O' AND "DocDueDate" < CURRENT_DATE
        GROUP BY 
            "CardCode", "DocStatus"
    ) T3 ON T0."CardCode" = T3."CardCode"
    WHERE
        T0."DocStatus" = 'O'         
        AND SALDO > 0;

    -- Generar alerta o resultado basado en las condiciones evaluadas
    IF (LIMITE_CREDITO = 0 AND SALDO = 0) OR (SALDO + TOTAL_OV < LIMITE_CREDITO) THEN
        SELECT 'FALSE' FROM DUMMY;
    ELSE
        SELECT 'TRUE' FROM DUMMY;
    END IF;

END;


/* ejemplo 2 */
DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
DECLARE PROCESO_APROBACION INT;

BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Obtener el saldo y límite de crédito del cliente
    SELECT T1."Balance", T1."CreditLine" INTO SALDO, LIMITE_CREDITO 
    FROM OCRD T1 
    WHERE T1."CardCode" = :CLIENTE;

    -- Contar cuántos documentos cumplen con las condiciones
    SELECT COUNT(*) INTO PROCESO_APROBACION
    FROM ORDR T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    INNER JOIN OCTG T2 ON T1."GroupNum" = T2."GroupNum"
    LEFT JOIN (
        SELECT 
            "CardCode", 
            MAX("DocDueDate") AS "DocDueDate", 
            "DocStatus"
        FROM 
            OINV
        WHERE 
            "DocStatus" = 'O' AND "DocDueDate" < CURRENT_DATE
        GROUP BY 
            "CardCode", "DocStatus"
    ) T3 ON T0."CardCode" = T3."CardCode"
    WHERE
        T0."DocStatus" = 'O'         
        AND T1."Balance" > 0
    GROUP BY 
         T0."CardCode",
         T0."DocDueDate",
         T1."CardCode",
         T1."CardName",
         T1."GroupCode",
         T1."Balance",
         T2."GroupNum",
         T1."U_SYP_TCONTRIB",
         T1."CreditLine",
         T3."DocStatus",
         T3."DocDueDate"
    HAVING 
        (T2."GroupNum" = -1)                          -- Pago al contado
        OR (T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90)  -- Cliente exterior con saldo vencido > 90 días
        OR (T1."Balance" > LIMITE_CREDITO)           -- Excede límite de crédito
        OR (T3."DocStatus" = 'O' AND DAYS_BETWEEN(T3."DocDueDate", CURRENT_DATE) > 90); -- Factura abierta y vencida mayor a 90 días

    -- Evaluar si se debe lanzar el proceso de aprobación
    IF (PROCESO_APROBACION > 0) THEN
        SELECT 'TRUE' AS Alert FROM DUMMY;  -- Lanzar proceso de aprobación
    ELSE
        SELECT 'FALSE' AS Alert FROM DUMMY;  -- Entrega directa
    END IF;

END;



/* ejemplo 3 */

DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
DECLARE PROCESO_APROBACION INT;
DECLARE CONDICION VARCHAR(100);

BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Obtener el saldo y límite de crédito del cliente
    SELECT T1."Balance", T1."CreditLine" INTO SALDO, LIMITE_CREDITO 
    FROM OCRD T1 
    WHERE T1."CardCode" = :CLIENTE;

    -- Evaluar condiciones
    SELECT 
        CASE 
            WHEN T2."GroupNum" = -1 THEN 'C de Contado'  -- Cliente de contado
            WHEN T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90 THEN 'C exterior con Saldo mayor 90 dias'
            WHEN SALDO > LIMITE_CREDITO THEN 'Excede LC'
            WHEN SALDO > 0 AND DAYS_BETWEEN(MAX(T3."DocDueDate"), CURRENT_DATE) > 0 THEN 'C local con Saldo Vencido'
        ELSE 'Entrega Directa'
        END INTO CONDICION
    FROM 
        ORDR T0
    INNER JOIN 
        OCRD T1 ON T0."CardCode" = T1."CardCode"
    INNER JOIN 
        OCTG T2 ON T1."GroupNum" = T2."GroupNum"
    LEFT JOIN (
        SELECT 
            "CardCode", 
            MAX("DocDueDate") AS "DocDueDate", 
            "DocStatus"
        FROM 
            OINV
        WHERE 
            "DocStatus" = 'O' AND "DocDueDate" < CURRENT_DATE
        GROUP BY 
            "CardCode", "DocStatus"
    ) T3 ON T0."CardCode" = T3."CardCode"
    WHERE
        T0."DocStatus" = 'O'         
        AND SALDO > 0
        AND T1."CardCode" = :CLIENTE  -- Asegurarse de filtrar por el cliente específico
    GROUP BY 
         T2."GroupNum", T1."U_SYP_TCONTRIB", SALDO, LIMITE_CREDITO;

    -- Evaluar la condición y determinar el resultado final
    IF (CONDICION = 'C de Contado') THEN
        SELECT 'TRUE' FROM DUMMY;  -- Cliente de contado
    ELSEIF (CONDICION = 'C exterior con Saldo mayor 90 dias') THEN
        SELECT 'TRUE' FROM DUMMY;  -- Cliente exterior con saldo mayor a 90 días
    ELSEIF (CONDICION = 'Excede LC') THEN
        SELECT 'TRUE' FROM DUMMY;  -- Excede límite de crédito
    ELSEIF (CONDICION = 'C local con Saldo Vencido') THEN
        SELECT 'TRUE' FROM DUMMY;  -- Cliente local con saldo vencido
    ELSE
        -- Verificar facturas abiertas y vencidas mayores a 90 días
        SELECT COUNT(*) INTO PROCESO_APROBACION
        FROM OINV T4
        WHERE 
            T4."CardCode" = :CLIENTE AND 
            T4."DocStatus" = 'O' AND 
            DAYS_BETWEEN(T4."DocDueDate", CURRENT_DATE) > 90; 

        IF (PROCESO_APROBACION > 0) THEN
            SELECT 'TRUE' FROM DUMMY;  -- Facturas abiertas y mayores a 90 días son TRUE
        ELSE
            SELECT 'FALSE' FROM DUMMY;  -- Ninguna condición cumplida, retorna FALSE
        END IF;
    END IF;

END;


/* EJEMPLO 4 */
DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
DECLARE PROCESO_APROBACION INT;
DECLARE CONDICION VARCHAR(100);

BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Evaluar condiciones y obtener saldo y límite de crédito del cliente
    SELECT 
        T1."Balance", 
        T1."CreditLine",
        CASE 
            WHEN T2."GroupNum" = -1 THEN 'C de Contado'  -- Cliente de contado
            WHEN T1."U_SYP_TCONTRIB" = 99 AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90 THEN 'C exterior con Saldo mayor 90 dias'
            WHEN T1."Balance" > T1."CreditLine" THEN 'Excede LC'
            WHEN T1."Balance" > 0 AND DAYS_BETWEEN(MAX(T3."DocDueDate"), CURRENT_DATE) > 0 THEN 'C local con Saldo Vencido'
            ELSE 'Entrega Directa'
        END INTO SALDO, LIMITE_CREDITO, CONDICION
    FROM 
        ORDR T0
    INNER JOIN 
        OCRD T1 ON T0."CardCode" = T1."CardCode"
    INNER JOIN 
        OCTG T2 ON T1."GroupNum" = T2."GroupNum"
    LEFT JOIN (
        SELECT 
            "CardCode", 
            MAX("DocDueDate") AS "DocDueDate", 
            "DocStatus"
        FROM 
            OINV
        WHERE 
            "DocStatus" = 'O' AND "DocDueDate" < CURRENT_DATE
        GROUP BY 
            "CardCode", "DocStatus"
    ) T3 ON T0."CardCode" = T3."CardCode"
    WHERE
        T0."DocStatus" = 'O'         
        AND T1."Balance" > 0
        AND T1."CardCode" = :CLIENTE  -- Asegurarse de filtrar por el cliente específico
    GROUP BY 
         T1."Balance", 
         T1."CreditLine", 
         T2."GroupNum", 
         T1."U_SYP_TCONTRIB";

    -- Evaluar la condición y determinar el resultado final
    IF (:CONDICION = 'C de Contado') THEN
        SELECT 'TRUE' FROM DUMMY;  -- Cliente de contado
    ELSEIF (:CONDICION = 'C exterior con Saldo mayor 90 dias') THEN
        SELECT 'TRUE' FROM DUMMY;  -- Cliente exterior con saldo mayor a 90 días
    ELSEIF (:CONDICION = 'Excede LC') THEN
        SELECT 'TRUE' FROM DUMMY;  -- Excede límite de crédito
    ELSEIF (:CONDICION = 'C local con Saldo Vencido') THEN
        SELECT 'TRUE' FROM DUMMY;  -- Cliente local con saldo vencido
    ELSE
        -- Verificar facturas abiertas y vencidas mayores a 90 días
        SELECT COUNT(*) INTO PROCESO_APROBACION
        FROM OINV T4
        WHERE 
            T4."CardCode" = :CLIENTE AND 
            T4."DocStatus" = 'O' AND 
            DAYS_BETWEEN(T4."DocDueDate", CURRENT_DATE) > 90; 

        IF (:PROCESO_APROBACION > 0) THEN
            SELECT 'TRUE' FROM DUMMY;  -- Facturas abiertas y mayores a 90 días son TRUE
        ELSE
            SELECT 'FALSE' FROM DUMMY;  -- Ninguna condición cumplida, retorna FALSE
        END IF;
    END IF;

END;


/* refactorizando Orden De Venta */
SELECT
    T1."CardCode" AS "Código del Cliente",
    T1."CardName" AS "Nombre del Cliente",
    T1."GroupCode",
    T1."Balance",
    T2."GroupNum" AS "Número de Grupo",
    T2."PymntGroup" AS "Condición de Pago"
FROM 
    ORDR T0
INNER JOIN 
    OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN 
    OCTG T2 ON T1."GroupNum" = T2."GroupNum"
WHERE
    T0."DocStatus" = 'O'
    AND T0."DocDueDate" < CURRENT_DATE 
    AND T1."Balance" > 0    --Saldo vencido mayor a cero
    AND T2."GroupNum" = -1  --Contado
GROUP BY 
    T1."CardCode",
    T1."CardName",
    T1."GroupCode",
    T1."Balance",
    T2."GroupNum",
    T2."PymntGroup"
HAVING 
    (
      MAX(T1."U_SYP_TCONTRIB") = 99 AND 
      DAYS_BETWEEN( MAX(T0."DocDueDate"), CURRENT_DATE) > 90 --si existe al menos un registro  99 = "Exterior" y si tiene más de 90 días vencidos
     ) 
    OR MAX(T1."U_SYP_TCONTRIB") <> 99;

    /* opcion 1 */


DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE CLIENTE_CONTADO INT;
DECLARE CLIENTE_EXTERIOR INT;

BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Verificar si el cliente es contado
    SELECT COUNT(*) INTO CLIENTE_CONTADO
    FROM OCRD 
    WHERE "CardCode" = :CLIENTE AND "GroupNum" = -1;  -- -1 indica cliente contado

    IF CLIENTE_CONTADO > 0 THEN
        -- Si existe un cliente contado, lanzar TRUE
        SELECT TRUE AS Resultado;
    ELSE
        -- Si no es contado, verificar si es un cliente exterior con saldo mayor a 90 días
        SELECT COUNT(*) INTO CLIENTE_EXTERIOR
        FROM OCRD T1
        INNER JOIN ORDR T0 ON T0."CardCode" = T1."CardCode"
        WHERE T1."CardCode" = CLIENTE 
          AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior
          AND T1."Balance" > 0  
          AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90;  -- Saldo mayor a 90 días

        IF CLIENTE_EXTERIOR > 0 THEN
            -- Si es un cliente exterior con saldo mayor a 90 días, lanzar TRUE
            SELECT TRUE AS Resultado;
        ELSE
            -- Si no lanzar FALSE
            SELECT FALSE AS Resultado;
        END IF;
    END IF;
END;


/* ORDEN DE VENTA */
/* opcion 2 */

/* 
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
 */


/* ORDEN VENTA  */
/* - */
DECLARE CLIENTE VARCHAR(20);
DECLARE CLIENTE_CONTADO INT;
DECLARE CLIENTE_EXTERIOR_SALDO_VENCIDO INT;
DECLARE SALDO_VENCIDO DECIMAL(19,2);

BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Obtener el saldo vencido
    SELECT $[$33.88.0] INTO SALDO_VENCIDO FROM DUMMY;

    -- Verificar si el cliente es contado
    SELECT COUNT(*) INTO CLIENTE_CONTADO
    FROM OCRD 
    WHERE "CardCode" = :CLIENTE AND "GroupNum" = -1;  -- -1 indica cliente contado

    IF (:CLIENTE_CONTADO > 0) THEN
        -- Si existe un cliente contado, lanzar TRUE
        SELECT 'TRUE' FROM DUMMY;
    ELSE
        -- Si no es contado, verificar si es un cliente exterior con saldo mayor a 90 días en Factura
        SELECT COUNT(*) INTO CLIENTE_EXTERIOR_SALDO_VENCIDO
        FROM OINV T0
        INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
        WHERE 
            T0."DocStatus" = 'O'
            AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
            AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90;  -- Saldo mayor a 90 días
            --AND (SALDO_VENCIDO > 0 )  -- Saldo vencido
            AND T0."CardCode" = :CLIENTE; 

        IF (:CLIENTE_EXTERIOR_SALDO_VENCIDO > 0) THEN
            SELECT 'TRUE' FROM DUMMY; 
        ELSE
            SELECT 'FALSE' FROM DUMMY;
        END IF;

    END IF;

END;


/* --- */
DECLARE CLIENTE VARCHAR(20);
DECLARE CLIENTE_CONTADO INT;
DECLARE CLIENTE_EXTERIOR INT;
DECLARE SALDO_VENCIDO DECIMAL(19,2);

BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    --Obtener el saldo vencido 
    SELECT $[$33.88.0] INTO SALDO_VENCIDO FROM DUMMY;

    -- Verificar si el cliente es contado
    SELECT COUNT(*) INTO CLIENTE_CONTADO
    FROM OCRD 
    WHERE "CardCode" = :CLIENTE AND "GroupNum" = -1;  -- -1 indica cliente contado

    IF (:CLIENTE_CONTADO > 0) THEN
        -- Si existe un cliente contado, lanzar TRUE
        SELECT 'TRUE' FROM DUMMY;
    ELSE
        -- Si no es contado, verificar si es un cliente exterior con saldo mayor a 90 días en Factura
        SELECT COUNT(*) INTO CLIENTE_EXTERIOR
        FROM OINV T0
        INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
        WHERE 
            T0."DocStatus" = 'O'
            AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
            AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90
            AND T0."DocTotal" > T0."PaidToDate"    -- Facturas con saldo pendiente
            AND T0."CardCode" = :CLIENTE; 

        IF (:CLIENTE_EXTERIOR > 0) THEN
            SELECT 'TRUE' FROM DUMMY; 
        ELSE
            SELECT 'FALSE' FROM DUMMY;
        END IF;

    END IF;

END;

/* orden de venta opcion 2 */
DECLARE CLIENTE VARCHAR(20);
DECLARE CLIENTE_CONTADO INT;
DECLARE CLIENTE_EXTERIOR_SALDO_VENCIDO INT;

BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    SELECT $[$33.88.0] INTO SALDO_VENCIDO FROM DUMMY;

    -- Verificar si el cliente es contado
    SELECT COUNT(*) INTO CLIENTE_CONTADO
    FROM OCRD 
    WHERE "CardCode" = :CLIENTE AND "GroupNum" = -1;  -- -1 indica cliente contado

    IF (:CLIENTE_CONTADO > 0) THEN
        -- Si existe un cliente contado, lanzar TRUE
        SELECT 'TRUE' FROM DUMMY;
    ELSE
        -- Si no es contado, verificar si es un cliente exterior con saldo mayor a 90 días en Factura
        SELECT COUNT(*) INTO CLIENTE_EXTERIOR_SALDO_VENCIDO
        FROM (
            SELECT T0."CardCode"
            FROM OINV T0
            INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
            WHERE 
                T0."DocStatus" = 'O'
                AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
                AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90
                AND T0."DocTotal" > T0."PaidToDate"    -- Facturas con saldo pendiente
                AND T0."CardCode" = :CLIENTE
            GROUP BY T0."CardCode"
        ) AS Subquery;

        IF (:CLIENTE_EXTERIOR_SALDO_VENCIDO > 0) THEN
            SELECT 'TRUE' FROM DUMMY; 
        ELSE
            SELECT 'FALSE' FROM DUMMY;
        END IF;

    END IF;

END;


-- ENTREGA
/* opcion 1 */
DECLARE CLIENTE VARCHAR(20);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE SALDO_VENCIDO DECIMAL(19,2);
DECLARE CLIENTE_EXTERIOR INT;

BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Obtener el límite de crédito del cliente
    SELECT "CreditLine" INTO LIMITE_CREDITO 
    FROM OCRD 
    WHERE "CardCode" = :CLIENTE;

    -- Calcular el saldo vencido del cliente
    SELECT SUM("Balance") INTO SALDO_VENCIDO
    FROM ORDR 
    WHERE "CardCode" = :CLIENTE 
      AND "DocDueDate" < CURRENT_DATE;  -- Solo documentos vencidos

    -- Verificar si el saldo vencido excede el límite de crédito
    IF (:SALDO_VENCIDO > :LIMITE_CREDITO) THEN
        -- Si excede el límite de crédito, retorna TRUE para proceso de aprobación
        SELECT 'TRUE' FROM DUMMY;
    ELSE
        -- Verificar si es un cliente local con saldo vencido
        IF (:SALDO_VENCIDO > 0) THEN
            -- Si tiene saldo vencido, retorna TRUE
            SELECT 'TRUE' FROM DUMMY;
        ELSE
            -- Si no tiene saldo vencido, verificar si es un cliente exterior con saldo mayor a 90 días
            SELECT COUNT(*) INTO CLIENTE_EXTERIOR
            FROM OCRD T1
            INNER JOIN ORDR T0 ON T0."CardCode" = T1."CardCode"
            WHERE T1."CardCode" = :CLIENTE 
              AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior
              AND T1."Balance" > 0  -- Debe tener saldo pendiente
              AND DAYS_BETWEEN(MAX(T0."DocDueDate"), CURRENT_DATE) > 90;  -- Saldo mayor a 90 días

            IF (:CLIENTE_EXTERIOR > 0) THEN
                -- Si es un cliente exterior con saldo mayor a 90 días, retorna TRUE
                SELECT 'TRUE' FROM DUMMY;
            ELSE
                -- Si no cumple ninguna condición, retorna FALSE
                SELECT 'FALSE' FROM DUMMY;
            END IF;
        END IF;
    END IF;
END;





/* 



 */

