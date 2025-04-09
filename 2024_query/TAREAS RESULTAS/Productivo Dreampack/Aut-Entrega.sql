/* AUT - ENTREGA */

/* ORIGINAL */


/* AUT EXCEDE LIMITE CREDITO */
DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
BEGIN
    SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;
    --SELECT 'C0102876901001' INTO CLIENTE FROM DUMMY;

    SELECT 
        T0."Balance", T0."CreditLine" 
        INTO SALDO, LIMITE_CREDITO 
    FROM OCRD T0 
    WHERE 
        T0."CardType"  = 'C' 
        AND T0."CardCode" = :CLIENTE;
    --SELECT 500, 501 INTO SALDO,LIMITE_CREDITO FROM DUMMY;

    IF((:LIMITE_CREDITO=0 AND SALDO=0) OR :SALDO + :TOTAL_OV<:LIMITE_CREDITO) THEN
    SELECT 'FALSE' FROM DUMMY;
    ELSE
        SELECT 'TRUE' FROM DUMMY;
    END IF;

END;
/* PRUEBAS */



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
    WHERE
        "CardType" = 'C' 
        AND "CardCode" = :CLIENTE;

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



/* prueba 2 */
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

    -- Calcular el saldo vencido del cliente desde OINV
    SELECT SUM("DocTotal" - "PaidToDate") INTO SALDO_VENCIDO
    FROM OINV 
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
            -- Si no tiene saldo vencido, verificar si es un cliente exterior con saldo mayor a 90 días en OINV
            SELECT COUNT(*) INTO CLIENTE_EXTERIOR
            FROM OINV T0
            INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
            WHERE T1."CardCode" = :CLIENTE 
                AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior
                AND (T0."DocTotal" - T0."PaidToDate") > 0  -- Debe tener saldo pendiente
                AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90;  -- Saldo mayor a 90 días

            IF (:CLIENTE_EXTERIOR > 0) THEN
                -- Si es un cliente exterior con saldo mayor a 90 días, retorna TRUE
                SELECT 'TRUE' FROM DUMMY;
            ELSE
                SELECT 'FALSE' FROM DUMMY;
            END IF;
        END IF;
    END IF;

END;



/* PRUEBA  3*/

DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);

DECLARE SALDO_VENCIDO INT;

DECLARE CLIENTE_EXTERIOR INT;

BEGIN
    /*Excede Limite de Credito  */
    SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;

    SELECT T0."Balance", T0."CreditLine" 
    INTO SALDO, LIMITE_CREDITO 
    FROM OCRD T0 
    WHERE T0."CardType"  = 'C' AND T0."CardCode" = :CLIENTE;
    
    IF((:LIMITE_CREDITO = 0 AND SALDO = 0) OR :SALDO + :TOTAL_OV<:LIMITE_CREDITO) THEN
        SELECT 'FALSE' FROM DUMMY;
    ELSE
        SELECT 'TRUE' FROM DUMMY;
    END IF;

    -- RELACIONADO PARA ENTREGA PASAN DIRECTO OCRD T1."GroupCode" = 120 pasan en false

    /* verifica el cliente local tiene saldo vencido */
    SELECT COUNT(*) INTO SALDO_VENCIDO
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."CardType" = 'C'  --Solo clientes 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo vencido mayor a cero 
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0 -- Saldo vencido
        AND T0."CardCode" = :CLIENTE;

    IF (:SALDO_VENCIDO > 0) THEN
        SELECT 'TRUE' FROM DUMMY;  -- El cliente local tiene saldo vencido
    ELSE
        SELECT 'FALSE' FROM DUMMY;
    END IF;


    /* verificar si es un cliente exterior con saldo mayor a 90 días */
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

    IF (:CLIENTE_EXTERIOR > 0) THEN
        SELECT 'TRUE' FROM DUMMY;
    ELSE
        SELECT 'FALSE' FROM DUMMY;
    END IF;
END;


/* opcion 4 */  --ciente RESTAURANTS BAHAMAS LTD
DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
DECLARE SALDO_VENCIDO INT;
DECLARE CLIENTE_EXTERIOR INT;
DECLARE GROUP_CODE INT;

BEGIN  
--bahamas
   
    /* Obtener el código del cliente y el total OV */
    SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;

    /* Verificar si el cliente es relacionado */
    SELECT T0."GroupCode" INTO GROUP_CODE
    FROM OCRD T0
    WHERE T0."CardType" = 'C' AND T0."CardCode" = :CLIENTE;

    -- Si el GroupCode es 120 (Relacionado), retornar FALSE
    IF (:GROUP_CODE = 120) THEN
        SELECT 'FALSE' FROM DUMMY;
    END IF;


    /* Obtener saldo y límite de crédito */
    SELECT T0."Balance", T0."CreditLine" 
    INTO SALDO, LIMITE_CREDITO 
    FROM OCRD T0 
    WHERE 
        T0."CardType" = 'C' -- Solo clientes 
        AND T0."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE;

    /* Verificar si se excede el límite de crédito */
    IF ((:LIMITE_CREDITO = 0 AND :SALDO = 0) OR (:SALDO + :TOTAL_OV < :LIMITE_CREDITO) ) THEN
        SELECT 'FALSE' FROM DUMMY;
    ELSE
        SELECT 'TRUE' FROM DUMMY;
    END IF;

    /* Verifica si el cliente local tiene saldo vencido */
    SELECT COUNT(*) INTO SALDO_VENCIDO
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."CardType" = 'C'  -- Solo clientes 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo pendiente mayor a cero 
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0 -- Saldo vencido
        AND T1."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE;

    IF (:SALDO_VENCIDO > 0) THEN
        SELECT 'TRUE' FROM DUMMY;  -- El cliente local tiene saldo vencido
    ELSE
        SELECT 'FALSE' FROM DUMMY;  -- No tiene saldo vencido
    END IF;

    /* Verificar si es un cliente exterior con saldo mayor a 90 días */
    SELECT COUNT(*) INTO CLIENTE_EXTERIOR
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."CardType" = 'C'  -- Solo clientes
        AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo pendiente mayor a cero 
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90 -- Saldo mayor a 90 días
        AND T1."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE; 

    IF (:CLIENTE_EXTERIOR > 0) THEN
        SELECT 'TRUE' FROM DUMMY;  -- Cliente exterior con saldo mayor a 90 días
    ELSE
        SELECT 'FALSE' FROM DUMMY;  -- No cumple con la condición de cliente exterior
    END IF;

END;



/* AUT - ENTREGA - LIMITE DE CREDITO - SALDO VENCIDO - CLIENTE EXTERIOR */
DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
DECLARE SALDO_VENCIDO INT;
DECLARE CLIENTE_EXTERIOR INT;
DECLARE GROUP_CODE INT;

BEGIN  
   
    /* Obtener el código del cliente y el total OV */
    SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;

    /* Verificar si el cliente es relacionado */
    SELECT T0."GroupCode" INTO GROUP_CODE
    FROM OCRD T0
    WHERE T0."CardType" = 'C' AND T0."CardCode" = :CLIENTE;

    -- Si el GroupCode es 120 (Relacionado), retornar FALSE
    IF (:GROUP_CODE = 120) THEN
        SELECT 'FALSE' FROM DUMMY;
    END IF;


    /* Obtener saldo y límite de crédito */
    SELECT T0."Balance", T0."CreditLine" 
    INTO SALDO, LIMITE_CREDITO 
    FROM OCRD T0 
    WHERE 
        T0."CardType" = 'C' -- Solo clientes 
        AND T0."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE;

    /* Verificar si se excede el límite de crédito */
    IF ((:LIMITE_CREDITO = 0 AND :SALDO = 0) OR (:SALDO + :TOTAL_OV < :LIMITE_CREDITO) ) THEN
        SELECT 'FALSE' FROM DUMMY;
    ELSE
        SELECT 'TRUE' FROM DUMMY;
    END IF;

    /* Verifica si el cliente local tiene saldo vencido */
    SELECT COUNT(*) INTO SALDO_VENCIDO
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."CardType" = 'C'  -- Solo clientes 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo pendiente mayor a cero 
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0 -- Saldo vencido
        AND T1."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE;

    IF (:SALDO_VENCIDO > 0) THEN
        SELECT 'TRUE' FROM DUMMY;  -- El cliente local tiene saldo vencido
    ELSE
        SELECT 'FALSE' FROM DUMMY;  -- No tiene saldo vencido
    END IF;

    /* Verificar si es un cliente exterior con saldo mayor a 90 días */
    SELECT COUNT(*) INTO CLIENTE_EXTERIOR
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."CardType" = 'C'  -- Solo clientes
        AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo pendiente mayor a cero 
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90 -- Saldo mayor a 90 días
        AND T1."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE; 

    IF (:CLIENTE_EXTERIOR > 0) THEN
        SELECT 'TRUE' FROM DUMMY;  -- Cliente exterior con saldo mayor a 90 días
    ELSE
        SELECT 'FALSE' FROM DUMMY;  -- No cumple con la condición de cliente exterior
    END IF;

END;



/* ORIGINAL */
DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
DECLARE SALDO_VENCIDO INT;
DECLARE CLIENTE_EXTERIOR INT;
DECLARE GROUP_CODE INT;

BEGIN  
   
    /* Obtener el código del cliente y el total OV */
    SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;

    /* Verificar si el cliente es relacionado */
    SELECT T0."GroupCode" INTO GROUP_CODE
    FROM OCRD T0
    WHERE T0."CardType" = 'C' AND T0."CardCode" = :CLIENTE;

    -- Si el GroupCode es 120 (Relacionado), retornar FALSE
    IF (:GROUP_CODE = 120) THEN
        SELECT 'FALSE' FROM DUMMY;
    END IF;


    /* Obtener saldo y límite de crédito */
    SELECT T0."Balance", T0."CreditLine" 
    INTO SALDO, LIMITE_CREDITO 
    FROM OCRD T0 
    WHERE 
        T0."CardType" = 'C' -- Solo clientes 
        AND T0."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE;

    /* Verificar si se excede el límite de crédito */
    IF ((:LIMITE_CREDITO = 0 AND :SALDO = 0) OR (:SALDO + :TOTAL_OV < :LIMITE_CREDITO) ) THEN
        SELECT 'FALSE' FROM DUMMY;
    ELSE
        SELECT 'TRUE' FROM DUMMY;
    END IF;

    /* Verifica si el cliente local tiene saldo vencido */
    SELECT COUNT(*) INTO SALDO_VENCIDO
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."CardType" = 'C'  -- Solo clientes 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo pendiente mayor a cero 
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0 -- Saldo vencido
        AND T1."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE;

    IF (:SALDO_VENCIDO > 0) THEN
        SELECT 'TRUE' FROM DUMMY;  -- El cliente local tiene saldo vencido
    ELSE
        SELECT 'FALSE' FROM DUMMY;  -- No tiene saldo vencido
    END IF;

    /* Verificar si es un cliente exterior con saldo mayor a 90 días */
    SELECT COUNT(*) INTO CLIENTE_EXTERIOR
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."CardType" = 'C'  -- Solo clientes
        AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo pendiente mayor a cero 
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90 -- Saldo mayor a 90 días
        AND T1."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE; 

    IF (:CLIENTE_EXTERIOR > 0) THEN
        SELECT 'TRUE' FROM DUMMY;  -- Cliente exterior con saldo mayor a 90 días
    ELSE
        SELECT 'FALSE' FROM DUMMY;  -- No cumple con la condición de cliente exterior
    END IF;

END;

/* MATERIAL DE APOLLO PARA LA ENTREGA */
--CLIENTE RELACIONADO
/*SELECT 
T0."CardCode",
T0."GroupCode"
FROM OCRD T0
WHERE T0."CardType" = 'C' AND T0."GroupCode" = 120
LIMIT 5*/

--SALDO Y LIMITE DE CREDITO
/*SELECT 
T0."CardCode",T0."Balance", T0."CreditLine" 
FROM OCRD T0 
WHERE 
        T0."CardType" = 'C' -- Solo clientes 
        AND T0."GroupCode" <> 120   --Excluir los relacionados 
LIMIT 5*/

--CLIENTE LOCAL TIENE SALDO VENCIDO
/*SELECT
T0."CardCode",
(T0."DocTotal" - T0."PaidToDate") AS "Saldo Vencido"
FROM OINV T0
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."CardType" = 'C'  -- Solo clientes 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo pendiente mayor a cero 
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0 -- Saldo vencido
        AND T1."GroupCode" <> 120;   --Excluir los relacionados*/

--CLIENTE EXTERIOR CON SALDO 90 DIAS
SELECT
    T0."CardCode", 
    (T0."DocTotal" - T0."PaidToDate") AS "Saldo vencido a 90 dias"
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."CardType" = 'C'  -- Solo clientes
        AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo pendiente mayor a cero 
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90 -- Saldo mayor a 90 días
        AND T1."GroupCode" <> 120;   --Excluir los relacionados

/* MODIFICANDO 19-11-2024 PASARON LAS 4 PRUEBAS 
   AUT - ENTREGA - LIMITE DE CREDITO - SALDO VENCIDO - CLIENTE EXTERIOR */

DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
DECLARE SALDO_VENCIDO INT;
DECLARE CLIENTE_EXTERIOR INT;
DECLARE GROUP_CODE INT;

BEGIN  
   
   /* Obtener el código del cliente y el total OV */
    SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;

    /* Verificar si el cliente es relacionado */
    SELECT T0."GroupCode" INTO GROUP_CODE
    FROM OCRD T0
    WHERE T0."CardType" = 'C' AND T0."CardCode" = :CLIENTE;

    -- Si el GroupCode es 120 (Relacionado), retornar FALSE
    IF (:GROUP_CODE = 120) THEN
        SELECT 'FALSE' FROM DUMMY;
        RETURN;
    ELSE
        SELECT 'TRUE' FROM DUMMY;
        RETURN;
    END IF;


    /* Obtener saldo y límite de crédito */
    SELECT T0."Balance", T0."CreditLine" 
    INTO SALDO, LIMITE_CREDITO 
    FROM OCRD T0 
    WHERE 
        T0."CardType" = 'C' -- Solo clientes 
        AND T0."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE;

    /* Verificar si se excede el límite de crédito */
    IF ((:LIMITE_CREDITO = 0 AND :SALDO = 0) OR (:SALDO + :TOTAL_OV < :LIMITE_CREDITO) ) THEN
        SELECT 'FALSE' FROM DUMMY;
    ELSE
        SELECT 'TRUE' FROM DUMMY;
    END IF;


    /* Verifica si el cliente local tiene saldo vencido */
    SELECT COUNT(*) INTO SALDO_VENCIDO
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."CardType" = 'C'  -- Solo clientes 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo pendiente mayor a cero 
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0 -- Saldo vencido
        AND T1."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE;

    IF (:SALDO_VENCIDO > 0) THEN
        SELECT 'TRUE' FROM DUMMY;  -- El cliente local tiene saldo vencido
    ELSE
        SELECT 'FALSE' FROM DUMMY;  -- No tiene saldo vencido
    END IF;

  /* Verificar si es un cliente exterior con saldo mayor a 90 días */
    SELECT COUNT(*) INTO CLIENTE_EXTERIOR
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."CardType" = 'C'  -- Solo clientes
        AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo pendiente mayor a cero 
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90 -- Saldo mayor a 90 días
        AND T1."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE; 

    IF (:CLIENTE_EXTERIOR > 0) THEN
        SELECT 'TRUE' FROM DUMMY;  -- Cliente exterior con saldo mayor a 90 días
    ELSE
        SELECT 'FALSE' FROM DUMMY;  -- No cumple con la condición de cliente exterior
    END IF;
   

END;



/* ORIGINAL 26-11-2024*/
DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
DECLARE SALDO_VENCIDO INT;
DECLARE CLIENTE_EXTERIOR INT;
DECLARE GROUP_CODE INT;

BEGIN  
   
   /* Obtener el código del cliente y el total OV */
    SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;

    /* Verificar si el cliente es relacionado */
    SELECT T0."GroupCode" INTO GROUP_CODE
    FROM OCRD T0
    WHERE T0."CardType" = 'C' AND T0."CardCode" = :CLIENTE;

    -- Si el GroupCode es 120 (Relacionado), retornar FALSE
    IF (:GROUP_CODE = 120) THEN
        SELECT 'FALSE' FROM DUMMY;
        RETURN;
    ELSE
        SELECT 'TRUE' FROM DUMMY;
        RETURN;
    END IF;


    /* Obtener saldo y límite de crédito */
    SELECT T0."Balance", T0."CreditLine" 
    INTO SALDO, LIMITE_CREDITO 
    FROM OCRD T0 
    WHERE 
        T0."CardType" = 'C' -- Solo clientes 
        AND T0."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE;

    /* Verificar si se excede el límite de crédito */
    IF ((:LIMITE_CREDITO = 0 AND :SALDO = 0) OR (:SALDO + :TOTAL_OV < :LIMITE_CREDITO) ) THEN
        SELECT 'FALSE' FROM DUMMY;
    ELSE
        SELECT 'TRUE' FROM DUMMY;
    END IF;


    /* Verifica si el cliente local tiene saldo vencido */
    SELECT COUNT(*) INTO SALDO_VENCIDO
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."CardType" = 'C'  -- Solo clientes 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo pendiente mayor a cero 
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0 -- Saldo vencido
        AND T1."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE;

    IF (:SALDO_VENCIDO > 0) THEN
        SELECT 'TRUE' FROM DUMMY;  -- El cliente local tiene saldo vencido
    ELSE
        SELECT 'FALSE' FROM DUMMY;  -- No tiene saldo vencido
    END IF;

  /* Verificar si es un cliente exterior con saldo mayor a 90 días */
    SELECT COUNT(*) INTO CLIENTE_EXTERIOR
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."CardType" = 'C'  -- Solo clientes
        AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo pendiente mayor a cero 
        AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90 -- Saldo mayor a 90 días
        AND T1."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE; 

    IF (:CLIENTE_EXTERIOR > 0) THEN
        SELECT 'TRUE' FROM DUMMY;  -- Cliente exterior con saldo mayor a 90 días
    ELSE
        SELECT 'FALSE' FROM DUMMY;  -- No cumple con la condición de cliente exterior
    END IF;
   

END;


/* ASI QUEDO POR EL MOMENTO */
DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
DECLARE SALDO_VENCIDO INT;
DECLARE CLIENTE_EXTERIOR INT;
DECLARE GROUP_CODE INT;

BEGIN  
   
   /* Obtener el código del cliente y el total OV */
    SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;

    /* Verificar si el cliente es relacionado */
    SELECT T0."GroupCode" INTO GROUP_CODE
    FROM OCRD T0
    WHERE T0."CardType" = 'C' AND T0."CardCode" = :CLIENTE;

    -- Si el GroupCode es 120 (Relacionado), retornar FALSE
    IF (:GROUP_CODE = 120) THEN
        SELECT 'FALSE' FROM DUMMY;
        RETURN;
    ELSE
        SELECT 'TRUE' FROM DUMMY;
        RETURN;
    END IF;


    /* Obtener saldo y límite de crédito */
    SELECT T0."Balance", T0."CreditLine" 
    INTO SALDO, LIMITE_CREDITO 
    FROM OCRD T0 
    WHERE 
        T0."CardType" = 'C' -- Solo clientes 
        AND T0."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE;

    /* Verificar si se excede el límite de crédito */
    IF ((:LIMITE_CREDITO = 0 AND :SALDO = 0) OR (:SALDO + :TOTAL_OV < :LIMITE_CREDITO) ) THEN
        SELECT 'FALSE' FROM DUMMY;
    ELSE
        SELECT 'TRUE' FROM DUMMY;
    END IF;


    /* Verifica si el cliente local tiene saldo vencido */
    SELECT COUNT(*) INTO SALDO_VENCIDO
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."CardType" = 'C'  -- Solo clientes 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo pendiente mayor a cero 
        --AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 0 -- Saldo vencido
       AND DAYS_BETWEEN(ADD_DAYS(T0."DocDueDate", COALESCE(T2."TolDays", 0)), CURRENT_DATE) > 0 -- Saldo vencido considerando días de tolerancia
        AND T1."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE;

    IF (:SALDO_VENCIDO > 0) THEN
        SELECT 'TRUE' FROM DUMMY;  -- El cliente local tiene saldo vencido
    ELSE
        SELECT 'FALSE' FROM DUMMY;  -- No tiene saldo vencido
    END IF;

  /* Verificar si es un cliente exterior con saldo mayor a 90 días */
    SELECT COUNT(*) INTO CLIENTE_EXTERIOR
    FROM OINV T0
    INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
    INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum" 
    WHERE 
        T0."DocStatus" = 'O'  -- Facturas abiertas
        AND T1."CardType" = 'C'  -- Solo clientes
        AND T1."U_SYP_TCONTRIB" = 99  -- 99 indica cliente exterior 
        AND (T0."DocTotal" - T0."PaidToDate") > 0   -- Saldo pendiente mayor a cero
        AND DAYS_BETWEEN(ADD_DAYS(T0."DocDueDate", COALESCE(T2."TolDays", 0)), CURRENT_DATE) > 90 -- Saldo mayor a 90 días considerando días de tolerancia 
        --AND DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) > 90 -- Saldo mayor a 90 días
        AND T1."GroupCode" <> 120   --Excluir los relacionados 
        AND T0."CardCode" = :CLIENTE; 

    IF (:CLIENTE_EXTERIOR > 0) THEN
        SELECT 'TRUE' FROM DUMMY;  -- Cliente exterior con saldo mayor a 90 días
    ELSE
        SELECT 'FALSE' FROM DUMMY;  -- No cumple con la condición de cliente exterior
    END IF;
   

END;
