/* ORDEN VENTA  */
/* ORIGINAL */

DECLARE CLIENTE VARCHAR(20);
DECLARE CLIENTE_CONTADO INT;
DECLARE CLIENTE_EXTERIOR INT;

BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Verificar si el cliente es contado
    SELECT COUNT(*) INTO CLIENTE_CONTADO
    FROM OCRD 
    WHERE
        "CardType"  = 'C' 
        AND "CardCode" = :CLIENTE 
        AND "GroupNum" = -1;  -- -1 indica cliente contado

    -- Si no es contado, verificar si es un cliente exterior con saldo mayor a 90 días en Factura
     SELECT COUNT(*) INTO CLIENTE_EXTERIOR
     FROM OINV T0
     INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
     WHERE 
            T0."DocStatus" = 'O'  -- Facturas abiertas
            AND T1."CardType" = 'C'  --Solo clientes
            AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
            AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo vencido mayor a cero 
            AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90 -- Saldo mayor a 90 días
            AND T0."CardCode" = :CLIENTE; 

    IF ( :CLIENTE_CONTADO > 0 OR :CLIENTE_EXTERIOR > 0) THEN
        SELECT 'TRUE' FROM DUMMY;
    ELSE
        SELECT 'FALSE' FROM DUMMY;
    END IF;

END;


/* PRUEBAS */

DECLARE CLIENTE VARCHAR(20);
DECLARE CLIENTE_CONTADO INT;
DECLARE CLIENTE_EXTERIOR INT;
DECLARE SALDO_VENCIDO DECIMAL(19,2);

BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Obtener el saldo vencido
    --SELECT $[$33.88.0] INTO SALDO_VENCIDO FROM DUMMY;

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
            T0."DocStatus" = 'O'  -- Facturas abiertas
            AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
            AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo vencido mayor a cero 
            AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90;  -- Saldo mayor a 90 días
            --AND (SALDO_VENCIDO > 0 AND (T0."DocTotal" - T0."PaidToDate") > 0)  -- Saldo vencido y facturas con saldo pendiente
            --AND (:SALDO_VENCIDO > 0 )  -- Saldo vencido
            AND T0."CardCode" = :CLIENTE; 

        IF (:CLIENTE_EXTERIOR > 0) THEN
            SELECT 'TRUE' FROM DUMMY; 
        ELSE
            SELECT 'FALSE' FROM DUMMY;
        END IF;

    END IF;

END;



/* ------- */
DECLARE
    CLIENTE VARCHAR(20);
    CLIENTE_CONTADO INT;
    CLIENTE_EXTERIOR INT;

BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Verificar si el cliente es contado
    SELECT COUNT(*) INTO CLIENTE_CONTADO
    FROM OCRD 
    WHERE "CardCode" = :CLIENTE AND "GroupNum" = -1;  -- -1 indica cliente contado

    IF (CLIENTE_CONTADO > 0) THEN
        -- Si existe un cliente contado, lanzar TRUE
        SELECT 'TRUE' FROM DUMMY;
    ELSE
        -- Si no es contado, verificar si es un cliente exterior con saldo mayor a 90 días en Factura
        SELECT COUNT(*) INTO CLIENTE_EXTERIOR
        FROM OINV T0
        INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
        WHERE 
            T0."DocStatus" = 'O'  -- Facturas abiertas
            AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
            AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo vencido mayor a cero 
            AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90  -- Saldo mayor a 90 días
            AND T0."CardCode" = :CLIENTE; 

        IF (CLIENTE_EXTERIOR > 0) THEN
            SELECT 'TRUE' FROM DUMMY; 
        ELSE
            SELECT 'FALSE' FROM DUMMY;
        END IF;

    END IF;

END;


/* MODIFICANDO */
DECLARE CLIENTE VARCHAR(20);
DECLARE CLIENTE_CONTADO INT;
DECLARE CLIENTE_EXTERIOR INT;

BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Verificar si el cliente es contado
    /*SELECT COUNT(*) INTO CLIENTE_CONTADO
    FROM OCRD 
    WHERE "CardCode" = :CLIENTE AND "GroupNum" = -1;  -- -1 indica cliente contado*/

   SELECT COUNT(*) INTO CLIENTE_CONTADO
   FROM ORDR T0
   INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
   WHERE T0."CardCode" = :CLIENTE AND T1."GroupNum" = -1;  

    IF (:CLIENTE_CONTADO > 0) THEN
        -- Si existe un cliente contado, lanzar TRUE
        SELECT 'TRUE' FROM DUMMY;
    ELSE
         SELECT 'FALSE' FROM DUMMY;
    END IF;

     /*
        -- Si no es contado, verificar si es un cliente exterior con saldo mayor a 90 días en Factura
        SELECT COUNT(*) INTO CLIENTE_EXTERIOR
        FROM OINV T0
        INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
        WHERE 
            T0."DocStatus" = 'O'  -- Facturas abiertas
            AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
            AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo vencido mayor a cero 
            AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90;  -- Saldo mayor a 90 días
            --AND (SALDO_VENCIDO > 0 AND (T0."DocTotal" - T0."PaidToDate") > 0)  -- Saldo vencido y facturas con saldo pendiente
            --AND (:SALDO_VENCIDO > 0 )  -- Saldo vencido
            AND T0."CardCode" = :CLIENTE; 

        IF (:CLIENTE_EXTERIOR > 0) THEN
            SELECT 'TRUE' FROM DUMMY; 
        ELSE
            SELECT 'FALSE' FROM DUMMY;
        END IF;  */

END;


/* ********************* */

DECLARE
    CLIENTE VARCHAR(20);
    CLIENTE_CONTADO INT;
    CLIENTE_EXTERIOR INT;

BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Verificar si el cliente es contado
    SELECT COUNT(*) INTO CLIENTE_CONTADO
    FROM OCRD 
    WHERE "CardCode" = :CLIENTE AND "GroupNum" = -1;  -- -1 indica cliente contado

    -- Verificar si es un cliente exterior con saldo mayor a 90 días en Factura
    SELECT COUNT(*) INTO CLIENTE_EXTERIOR
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo vencido mayor a cero 
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90  -- Saldo mayor a 90 días
        AND T0."CardCode" = :CLIENTE; 

    -- Evaluar si el cliente es contado o exterior con saldo vencido
    IF (CLIENTE_CONTADO > 0 OR CLIENTE_EXTERIOR > 0) THEN
        SELECT 'TRUE' FROM DUMMY;
    ELSE
        SELECT 'FALSE' FROM DUMMY;
    END IF;

END;



/* AUT - ORDEN DE VENTA - CLIENTE CONTADO - CLIENTE EXTERIOR */
DECLARE CLIENTE VARCHAR(20);
DECLARE CLIENTE_CONTADO INT;
DECLARE CLIENTE_EXTERIOR INT;

BEGIN
    -- Obtener el código del cliente desde el contexto de la alerta
    SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Verificar si el cliente es contado
    SELECT COUNT(*) INTO CLIENTE_CONTADO
    FROM OCRD 
    WHERE 
        "CardType" = 'C' AND 
        "CardCode" = :CLIENTE 
        AND "GroupNum" = -1;  -- -1 indica cliente contado

    -- Si no es contado, verificar si es un cliente exterior con saldo mayor a 90 días en Factura
     SELECT COUNT(*) INTO CLIENTE_EXTERIOR
     FROM OINV T0
     INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
     WHERE 
            T0."DocStatus" = 'O'  -- Facturas abiertas
            AND T1."CardType" = 'C'  --Solo clientes
            AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
            AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo vencido mayor a cero 
            AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90 -- Saldo mayor a 90 días
            AND T0."CardCode" = :CLIENTE; 

    IF ( :CLIENTE_CONTADO > 0 OR :CLIENTE_EXTERIOR > 0) THEN
        SELECT 'TRUE' FROM DUMMY;
    ELSE
        SELECT 'FALSE' FROM DUMMY;
    END IF;

END;


/* SUMAR DIAS DE TOLERANCIA EN EXTERIOR */
SELECT 
  T0."CardCode" AS "Codigo Cliente",
  T0."CardName" AS "Nombre Cliente",
  T2."TolDays"
FROM OINV T0
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum" 
WHERE 
    T0."DocStatus" = 'O'  -- Facturas abiertas
    AND T1."CardType" = 'C'  --Solo clientes
    AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
    AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo vencido mayor a cero 
    AND DAYS_BETWEEN(ADD_DAYS(T0."DocDueDate", COALESCE(T2."TolDays", 0)), CURRENT_DATE) > 90 -- Saldo mayor a 90 días considerando días de tolerancia
    --AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90 -- Saldo mayor a 90 días



/* MATERIAL DE APOYO */

/*ORDEN DE VENTA*/
 -- Verificar si el cliente es contado
--SELECT * FROM OCRD WHERE "CardType" = 'C' AND "GroupNum" = -1 LIMIT 10

-- Si no es contado, verificar si es un cliente exterior con saldo mayor a 90 días en Factura 
/*SELECT
  T0."CardCode", 
*
FROM OINV T0
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
WHERE 
   T0."DocStatus" = 'O'  -- Facturas abiertas
   AND T1."CardType" = 'C'  --Solo clientes
   AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
   AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo vencido mayor a cero 
   AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90 -- Saldo mayor a 90 días
LIMIT 10
--AND T0."CardCode" = :CLIENTE;*/

/* ENTREGA */ /* VERIFICAR */
/* Verificar si el cliente es relacionado */
SELECT 
T0."CardCode",
T0."GroupCode"
FROM OCRD T0
WHERE T0."CardType" = 'C' AND T0."GroupCode" = 120;

/* Verifica si el cliente local tiene saldo vencido */

/*SELECT 
T0."CardCode"
FROM OINV T0
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
WHERE 
    T0."DocStatus" = 'O'  -- Facturas abiertas
    AND T1."CardType" = 'C'  -- Solo clientes 
    AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo pendiente mayor a cero 
    AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0 -- Saldo vencido
    AND T1."GroupCode" <> 120;   --Excluir los relacionados*/
