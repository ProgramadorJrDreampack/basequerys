SELECT 
  T1."U_NAME", 
CASE
     WHEN  T0."U_SYP_MTVCOMP" = 'MATE' THEN 'Compra Materia'
     WHEN  T0."U_SYP_MTVCOMP" = 'PDTR' THEN 'Producto Terminado'
     WHEN  T0."U_SYP_MTVCOMP" = 'SELB' THEN 'Semielaborado'
     ELSE '' 
END AS "Motivo de Compra"
  --T0."U_SYP_MTVCOMP"
 
FROM OPRQ T0  
INNER JOIN OUSR T1 ON T0."UserSign" = T1."USERID" 
WHERE 
  T1."USERID" IN (147,70) AND T0."U_SYP_MTVCOMP" IN ('MATE', 'PDTR', 'SELB')


SELECT T0."USERID", T0."USER_CODE", T0."U_NAME" FROM OUSR T0 WHERE T0."USERID" IN (147,70);


SELECT *  FROM OPRQ T0  INNER JOIN OUSR T1 ON T0."UserSign" = T1."USERID" LIMIT 10;


/* AUTORIZA SOLICITUD DE COMPRA  */
DECLARE MOTIVO_COMPRA VARCHAR(100);
DECLARE NOMBRE_USUARIO VARCHAR(100);
DECLARE USER_ID NUMERIC;
DECLARE USUARIO VARCHAR(20);

BEGIN
    
    SELECT $[$1470002177.1.0] INTO USUARIO FROM DUMMY;

    --SELECT 'manager' INTO USUARIO FROM DUMMY;
    
    SELECT 
        CASE
            WHEN T0."U_SYP_MTVCOMP" = 'ACFI' THEN 'Compra Activo Fijo'
            WHEN T0."U_SYP_MTVCOMP" = 'INSU' THEN 'Compra Insumos'
            WHEN T0."U_SYP_MTVCOMP" = 'MATE' THEN 'Compra Materia'
            WHEN T0."U_SYP_MTVCOMP" = 'PDTR' THEN 'Producto Terminado'
            WHEN T0."U_SYP_MTVCOMP" = 'REPU' THEN 'Compra Repuesto'
            WHEN T0."U_SYP_MTVCOMP" = 'SELB' THEN 'Semielaborado'
            WHEN T0."U_SYP_MTVCOMP" = 'SERV' THEN 'Compra de Servicios'
            WHEN T0."U_SYP_MTVCOMP" = 'VARI' THEN 'Compras Varias'
            ELSE '' 
        END AS "Motivo de Compra",
        T1."U_NAME" AS "Nombre del Usuario",
        T0."UserSign" AS "User ID"
    INTO MOTIVO_COMPRA, NOMBRE_USUARIO, USER_ID
    FROM OPRQ T0  
    INNER JOIN OUSR T1 ON T0."UserSign" = T1."USERID" 
    WHERE T0."Requester" = :USUARIO AND T1."USER_CODE" = :USUARIO
    --T0."UserSign" = :USUARIO

    -- Aprobación condicional
    IF (:USER_ID = 1 AND :USUARIO = 'manager') OR (:USER_ID = 147 AND :USUARIO = 'COM04') OR (:USER_ID = 70 AND :USUARIO = 'BOD04') THEN
        IF :MOTIVO_COMPRA = 'INSU' THEN
            SELECT 'TRUE' FROM DUMMY; -- Aprobado
        ELSE
            SELECT 'FALSE' FROM DUMMY; -- No aprobado
        END IF;
    ELSE
        SELECT 'FALSE' FROM DUMMY; -- No aprobado
    END IF;
END;

----$[$8.1] 
 --$[OPRQ.DocEntry]

/* AUTORIZA CREAR FACTURA */

DECLARE PRECIO_CMP DECIMAL(19,2);
DECLARE CANTIDAD NUMERIC;
DECLARE ARTICULO VARCHAR(100);
DECLARE DOCENTRY NUMERIC;
DECLARE PRECIO_ENTR DECIMAL(19,2);
DECLARE CONT NUMERIC;
BEGIN

SELECT $[$38.1.0], $[$38.11.NUMBER], $[$38.14.NUMBER], IFNULL($[$38.45.NUMBER],0) 
INTO ARTICULO, CANTIDAD,PRECIO_CMP, DOCENTRY   
FROM DUMMY;



Select  COUNT(*) INTO CONT 
  From "OPDN" OC, "PDN1" OD
 Where OC."DocEntry" = OD."DocEntry"
   And OC."DocEntry" = :DOCENTRY
   And OD."ItemCode" = :ARTICULO
   And OD."Quantity" = :CANTIDAD;
   
   
   IF :CONT>0 THEN 
			Select  OD."Price" INTO PRECIO_ENTR 
			From "OPDN" OC, "PDN1" OD
			Where OC."DocEntry" = OD."DocEntry"
			And OC."DocEntry" = :DOCENTRY
			And OD."ItemCode" = :ARTICULO
			And OD."Quantity" = :CANTIDAD;
           IF (:PRECIO_CMP  <> :PRECIO_ENTR AND :DOCENTRY<>0) THEN
            SELECT 'TRUE' FROM DUMMY;
           ELSE
            SELECT 'FALSE' FROM DUMMY;
           END IF;
	ELSE
		SELECT 'FALSE' FROM DUMMY;
	END IF;

END;


-- *********************************************
DECLARE MOTIVO_COMPRA VARCHAR(100);
DECLARE NOMBRE_USUARIO VARCHAR(100);
DECLARE USER_ID NUMERIC;

DECLARE DOCNUM VARCHAR(20);
BEGIN
    
   SELECT $[OPRQ.DocNum] INTO DOCNUM FROM DUMMY;  
   
   --SELECT COUNT(*)  INTO CONT FROM OPRQ T0 WHERE T0."DocNum" = :DOCNUM;

    SELECT 
       T0."U_SYP_MTVCOMP",
       T1."U_NAME",
       T0."UserSign"
    INTO MOTIVO_COMPRA, NOMBRE_USUARIO, USER_ID
    FROM OPRQ T0  
    INNER JOIN OUSR T1 ON T0."UserSign" = T1."USERID" 
    WHERE T0."DocNum" = :DOCNUM;

   
   IF (:USER_ID = 1 AND :NOMBRE_USUARIO  = 'manager') THEN
        IF (:MOTIVO_COMPRA = 'INSU') THEN
            SELECT 'TRUE' FROM DUMMY; -- Aprobado
        ELSE
            SELECT 'FALSE' FROM DUMMY; -- No aprobado
        END IF;
    ELSE
        SELECT 'FALSE' FROM DUMMY; -- No aprobado
    END IF;

   
END;


-- *************************************


SELECT 
       T0."U_SYP_MTVCOMP",
       T1."U_NAME",
       T0."UserSign"
    --INTO MOTIVO_COMPRA, NOMBRE_USUARIO, USER_ID
    FROM OPRQ T0  
    INNER JOIN OUSR T1 ON T0."UserSign" = T1."USERID" 
    WHERE T0."UserSign" = 1 AND  T1."U_NAME" = 'manager' AND T0."U_SYP_MTVCOMP" = 'INSU';




    -- *********************
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
BEGIN
SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;
--SELECT 'C0102876901001' INTO CLIENTE FROM DUMMY;

SELECT T0."Balance" , T0."CreditLine" INTO SALDO, LIMITE_CREDITO FROM OCRD T0 WHERE T0."CardType"  = 'C' AND T0."CardCode" = :CLIENTE;
--SELECT 500, 501 INTO SALDO,LIMITE_CREDITO FROM DUMMY;

IF((:LIMITE_CREDITO=0 AND SALDO=0) OR :SALDO + :TOTAL_OV<:LIMITE_CREDITO) THEN
   SELECT 'FALSE' FROM DUMMY;
ELSE
     SELECT 'TRUE' FROM DUMMY;
END IF;

END;




*****************************************************
SELECT 
  T1."USERID",
  T1."USER_CODE",
  --T1."U_NAME", 
 CASE
            WHEN T0."U_SYP_MTVCOMP" = 'ACFI' THEN 'Compra Activo Fijo'
            WHEN T0."U_SYP_MTVCOMP" = 'INSU' THEN 'Compra Insumos'
            WHEN T0."U_SYP_MTVCOMP" = 'MATE' THEN 'Compra Materia'
            WHEN T0."U_SYP_MTVCOMP" = 'PDTR' THEN 'Producto Terminado'
            WHEN T0."U_SYP_MTVCOMP" = 'REPU' THEN 'Compra Repuesto'
            WHEN T0."U_SYP_MTVCOMP" = 'SELB' THEN 'Semielaborado'
            WHEN T0."U_SYP_MTVCOMP" = 'SERV' THEN 'Compra de Servicios'
            WHEN T0."U_SYP_MTVCOMP" = 'VARI' THEN 'Compras Varias'
            ELSE '' 
 END AS "Motivo de Compra"
  --T0."U_SYP_MTVCOMP"
 
FROM OPRQ T0  
INNER JOIN OUSR T1 ON T0."UserSign" = T1."USERID" 
WHERE 
  T1."USERID" = 1 AND T1."USER_CODE" = 'manager' AND T0."U_SYP_MTVCOMP" IN ('INSU')



--   *******************************************************************
-- Nuevo porcesos de aprobacion para insumo 
    -- SELECT $[OPRQ."Requester".0], $[OPRQ."DocNum".0], $[OPRQ."U_SYP_MTVCOMP".0] 


DECLARE USER_CODE VARCHAR(20);
DECLARE MOTIVO_COMPRA VARCHAR(100);

BEGIN

    SELECT $[OPRQ."Requester".0], $[OPRQ."U_SYP_MTVCOMP".0] 
    INTO USER_CODE, MOTIVO_COMPRA 
    FROM DUMMY;

    IF (:USER_CODE = 'manager') THEN
        IF (:MOTIVO_COMPRA = 'INSU') THEN
            SELECT 'TRUE' FROM DUMMY;
        ELSE 
            SELECT 'FALSE' FROM DUMMY;
        END IF;
    ELSE
        SELECT 'FALSE' FROM DUMMY; 
    END IF;

END;


-- ******************
DECLARE USER_CODE VARCHAR(20);

BEGIN

SELECT $[OPRQ."Requester".0] INTO USER_CODE  FROM DUMMY;


    IF (:USER_CODE  = 'manager') THEN
        SELECT 'TRUE' FROM DUMMY; 
    ELSE
        SELECT 'FALSE' FROM DUMMY; 
    END IF;
    


END;



-- ****************************************************************************************************************************************

-- SC Dreampack (Jessica = 'COM04' / Josue = BOD04 / Omar Lopez = 'COM05')
-- Cuando el motivo de Compras es Insumos el proceso de aprobación llega a Santiago

-- se creo una etapa que es el encargado de autorizar el señor Santiago Jefe de Produccion
Aut SC INSUMO - Autorizacion Solicitud de compra con insumo

-- se creeo un modelo de autorizacion 
nombre : Aut SC Mot Com Insu
descripcion : Autorizacion SC Motivo de compra inusmo
Activo
Activo al actualizar
Autor:  son las persona que realizar el proceso
Documentos : Elige el modulo
Etapas : los que aprueban 
condiciones : realizar el query

NOMBRE DEL QUERY : AUTORIZACIONES = AUT SC MOT COMPRA INSUMO

DECLARE USER_CODE VARCHAR(20);
DECLARE MOTIVO_COMPRA VARCHAR(100);

BEGIN

    SELECT $[OPRQ."Requester".0], $[OPRQ."U_SYP_MTVCOMP".0] 
    INTO USER_CODE, MOTIVO_COMPRA 
    FROM DUMMY;

    -- IF (:USER_CODE = 'manager') OR (:USER_CODE = 'COM04') OR (:USER_CODE = 'BOD04') OR (:USER_CODE = 'COM05') THEN
    IF :USER_CODE IN ('COM04', 'BOD04', 'COM05') THEN
        IF (:MOTIVO_COMPRA = 'INSU') THEN
            SELECT 'TRUE' FROM DUMMY;
        ELSE 
            SELECT 'FALSE' FROM DUMMY;
        END IF;
    ELSE
        SELECT 'FALSE' FROM DUMMY; 
    END IF;

END;


-- ********************************************************
NOMBRE DEL QUERY : AUTORIZACIONES = AUT SC MOT COMPRA MENOS INSUMO

DECLARE USER_CODE VARCHAR(20);
DECLARE MOTIVO_COMPRA VARCHAR(100);

BEGIN

    SELECT $[OPRQ."Requester".0], $[OPRQ."U_SYP_MTVCOMP".0] 
    INTO USER_CODE, MOTIVO_COMPRA 
    FROM DUMMY;

    IF :USER_CODE IN ('COM04', 'BOD04', 'COM05') THEN
        IF (:MOTIVO_COMPRA != 'INSU') THEN
            SELECT 'TRUE' FROM DUMMY;
        ELSE 
            SELECT 'FALSE' FROM DUMMY;
        END IF;
    ELSE
        SELECT 'FALSE' FROM DUMMY; 
    END IF;

END;