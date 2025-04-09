
/* ORIGINAL PRUEBAS EPM MEXICO */

CREATE PROCEDURE SBO_SP_TransactionNotification_CLIENT
(
	in object_type nvarchar(30), 				-- SBO Object Type
	in transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	in num_of_cols_in_key int,
	in list_of_key_cols_tab_del nvarchar(255),
	in list_of_cols_val_tab_del nvarchar(255), 
	-- Return values
	out error int, -- Result (0 for no error)
	out error_message nvarchar (200) -- Error string to be displayed
	
)
LANGUAGE SQLSCRIPT
AS
---- Custom Variables
DOCNUM NVARCHAR(10);
DOCENTRY nvarchar(10);
DECLA NVARCHAR(10);
ITEM NVARCHAR(13);
ABSENTRY NVARCHAR(10);
POS NVARCHAR(2);
ALMACEN NVARCHAR(7);
OT NVARCHAR(10);
CODCLAS NVARCHAR(15);
UNMED NVARCHAR(15);
TYPE_ITEM NVARCHAR(2);

CODMP NVARCHAR(15);
DESCMP NVARCHAR(50);
CODSKU NVARCHAR(15);
DESCSKU NVARCHAR(50);
PLMER INT;
PLTOT INT;
PLNEC INT; 
FECHEN DATE;
DESDE NVARCHAR(6);
HASTA NVARCHAR(6);
USRM INT;
USR INT;
BODEGA100 NVARCHAR(5);

BEGIN
--=======================================================================================
-- STORE PROCEDURE PARA QUE EL AREA DE TI DE LA EMPRESA AGREGUE SUS PROPIAS VALIDACIONES
--=======================================================================================

--ENTRADA DE MERCANCIAS PARA PROCESO FSC
/*IF :object_type = '59' AND ( :transaction_type = 'A' OR :transaction_type = 'U') THEN
		--DOCUMENTO ACTUAL
		SELECT T0."DocNum",T0."DocEntry",T1."ItemCode",t1."U_beas_belposid",t1."U_beas_belnrid", T1."WhsCode",T4."AbsEntry"
		INTO DOCNUM,DOCENTRY,ITEM,POS,OT,ALMACEN,ABSENTRY
		FROM "OIGN" T0 INNER JOIN "IGN1" T1 ON T1."DocEntry" = T0."DocEntry"  
		INNER JOIN "OITL" T2 ON T0."DocEntry" = T2."DocEntry" AND T2."DocNum" = T0."DocNum"
		INNER JOIN "ITL1" T3 ON T3."LogEntry" = T2."LogEntry"
		INNER JOIN "OBTN" T4 ON T4."ItemCode" = T3."ItemCode" and T3."MdAbsEntry" = T4."AbsEntry"
		WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
		 
		 --IF :ALMACEN = '04FPDP' THEN
		--CONSULTA HACIA SALIDA DE MERCANCIA		 
			 SELECT TOP 1 T4."U_LAB_FSC_DECLA" INTO DECLA
				FROM "OIGE" T0 
				INNER JOIN "IGE1" T1 ON T1."DocEntry" = T0."DocEntry"
				INNER JOIN "OITL" T2 ON T0."DocEntry" = T2."DocEntry" AND T2."DocNum" = T0."DocNum"
				INNER JOIN "ITL1" T3 ON T3."LogEntry" = T2."LogEntry"
				INNER JOIN "OBTN" T4 ON T4."ItemCode" = T3."ItemCode" and T3."MdAbsEntry" = T4."AbsEntry"
				WHERE T1."U_beas_belnrid" = :OT AND T1."U_beas_belposid" = :POS 
				ORDER BY T0."DocNum" DESC;
			 
			 
			 UPDATE "OBTN" SET "U_LAB_FSC_DECLA"= :DECLA WHERE "ItemCode" = :ITEM AND "AbsEntry"= :ABSENTRY;
		 --END IF;
	

END IF;*/

IF :object_type = '4' AND ( :transaction_type = 'A' OR :transaction_type = 'U') THEN
	SELECT T0."NCMCode", T0."SalUnitMsr", T0."ItemType"
	INTO CODCLAS, UNMED, TYPE_ITEM
	FROM "OITM" T0 WHERE T0."ItemCode" = :list_of_cols_val_tab_del;
	IF TYPE_ITEM = 'I' THEN
		IF (:CODCLAS IS NULL OR :CODCLAS = '-1') THEN
			error := 1;
			error_message := N'DPE: Debe Ingresar el campo Código de Clasificación';
		END IF;
		IF (:UNMED IS NULL) THEN
			error := 2;
			error_message := N'DPE: Debe Ingresar el campo Unidad de Medida de Ventas';
		END IF;
	END IF;
END IF;
/*
IF :object_type = '22' AND ( :transaction_type = 'A' OR :transaction_type = 'U') THEN
	SELECT T1."ItemCode", T0."U_codigoMP", T0."U_descMP", T0."U_codigoSKU", T0."U_descSKU", T0."U_planasMerma"
	, T0."U_planasTot", T0."U_planasNec", T0."U_FechaEntrega"
	INTO ITEM, CODMP, DESCMP, CODSKU, DESCSKU, PLMER, PLTOT, PLNEC, FECHEN
	FROM "OPOR" T0 INNER JOIN "POR1" T1 ON T0."DocEntry" = T1."DocEntry"
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	IF :ITEM = '00F05010006' THEN
		IF (:CODMP IS NULL OR :CODMP = '') THEN
			error := 1;
			error_message := N'DPE: Debe Ingresar el campo Código de Materia Prima';
		END IF;
		IF (:DESCMP IS NULL OR :DESCMP = '') THEN
			error := 1;
			error_message := N'DPE: Debe Ingresar el campo Descripcion de Materia Prima';
		END IF;
		IF (:CODSKU IS NULL OR :CODSKU = '') THEN
			error := 1;
			error_message := N'DPE: Debe Ingresar el campo Código SKU';
		END IF;
		IF (:DESCSKU IS NULL OR :DESCSKU = '') THEN
			error := 1;
			error_message := N'DPE: Debe Ingresar el campo Descripcion SKU';
		END IF;
		IF (:PLMER IS NULL) THEN
			error := 1;
			error_message := N'DPE: Debe Ingresar el campo Planas Merma';
		END IF;
		IF (:PLTOT IS NULL) THEN
			error := 1;
			error_message := N'DPE: Debe Ingresar el campo Planas Totales';
		END IF;
		IF (:PLNEC IS NULL) THEN
			error := 1;
			error_message := N'DPE: Debe Ingresar el campo Planas Necesarias';
		END IF;
		IF (:FECHEN IS NULL) THEN
			error := 1;
			error_message := N'DPE: Debe Ingresar el campo Fecha de Entrega';
		END IF;
	END IF;
END IF;
*/

--ENTRADA DE MERCANCIA
IF :object_type = '59' AND ( :transaction_type IN ('A', 'U')) THEN
	SELECT COALESCE(COUNT(*), 0)
	INTO BODEGA100
	FROM IGN1 T0
	WHERE T0."WhsCode" = 'A100' AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT T0."UserSign2"
	INTO USR
	FROM OIGN T0
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	
	IF (BODEGA100 > 0) THEN
		IF (:USR NOT IN (10, 50)) THEN --NO ES USUARIO DE COSTOS
				error := 1001;
				error_message := N'EPM: Solo usuarios de costos permitidos para Bodega A100';
		END IF;
	END IF;
ENd IF;

--SALIDA DE MERCANCIA
IF :object_type = '60' AND ( :transaction_type IN ('A', 'U')) THEN
	SELECT COALESCE(COUNT(*), 0)
	INTO BODEGA100
	FROM IGE1 T0
	WHERE T0."WhsCode" = 'A100' AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT T0."UserSign2"
	INTO USR
	FROM OIGE T0
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	
	IF (BODEGA100 > 0) THEN
		IF (:USR NOT IN (10, 50)) THEN --NO ES USUARIO DE COSTOS
				error := 1001;
				error_message := N'EPM: Solo usuarios de costos permitidos para Bodega A100';
		END IF;
	END IF;
ENd IF;

--Transferencia de STOCK limitar a producción a solo las bodegas autorizadas
IF :object_type = '67' AND ( :transaction_type = 'A' OR :transaction_type = 'U') THEN
	SELECT T0."UserSign"
	INTO USRM
	FROM OWTR T0	
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO DESDE
	FROM WTR1 T0
	WHERE (T0."FromWhsCod" LIKE '11%' OR T0."FromWhsCod" LIKE '12%' OR T0."FromWhsCod" LIKE '14%') AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO HASTA
	FROM WTR1 T0
	WHERE (T0."WhsCode" LIKE '11%' OR T0."WhsCode" LIKE '12%' OR T0."WhsCode" LIKE '14%') AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO BODEGA100
	FROM WTR1 T0
	WHERE (T0."WhsCode" = 'A100' OR T0."FromWhsCod" = 'A100') AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT T0."UserSign2"
	INTO USR
	FROM OWTR T0
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	
	IF (BODEGA100 > 0) THEN
		IF (:USR NOT IN (10, 50)) THEN --NO ES USUARIO DE COSTOS
				error := 1001;
				error_message := N'EPM: Solo usuarios de costos permitidos para Bodega A100';
		END IF;
	END IF;
	
	IF (:USRM NOT IN ('1', '10', '45')) THEN
		IF (:DESDE > 0) THEN
			error := 1;
			error_message := N'EPM: No tienes permisos para transferir desde bodegas no autorizadas';
		END IF;
		IF (:HASTA > 0) THEN
			error := 2;
			error_message := N'EPM: No tienes permisos para transferir a bodegas no autorizadas';
		END IF;
	END IF;
END IF;

END;





/* FIN ORIGINAL */


/* PRUEBAS 1 */
-- Validación para Cliente y Proveedor en la tabla OCRD
IF :object_type IN ('2', '4') AND ( :transaction_type = 'A' OR :transaction_type = 'U') THEN
    DECLARE @clientCount INT;
    DECLARE @supplierCount INT;
    DECLARE @email NVARCHAR(100);
    DECLARE @phone NVARCHAR(20);
    
    -- Obtener el correo y teléfono del cliente/proveedor
    SELECT 
        T0."Email", 
        T0."Phone1"
    INTO 
        @email, 
        @phone
    FROM OCRD T0
    WHERE T0."CardCode" = :list_of_key_cols_tab_del;

    -- Contar clientes y proveedores
    SELECT 
        COUNT(*) INTO @clientCount 
    FROM OCRD 
    WHERE "CardType" = 'C' AND "CardCode" = :list_of_key_cols_tab_del;

    SELECT 
        COUNT(*) INTO @supplierCount 
    FROM OCRD 
    WHERE "CardType" = 'S' AND "CardCode" = :list_of_key_cols_tab_del;

    -- Validar que al menos un cliente o proveedor esté presente
    IF (@clientCount = 0 AND @supplierCount = 0) THEN
        error := 1;
        error_message := N'DPE: Debe existir al menos un Cliente o Proveedor asociado.';
    END IF;

    -- Validar formato de correo electrónico
    IF (@email IS NOT NULL AND NOT @email LIKE '%@%._%') THEN
        error := 2;
        error_message := N'DPE: El formato del correo electrónico es inválido.';
    END IF;

    -- Validar número de teléfono (debe tener al menos 7 dígitos)
    IF (@phone IS NOT NULL AND LEN(REPLACE(@phone, '-', '')) < 7) THEN
        error := 3;
        error_message := N'DPE: El número de teléfono debe tener al menos 7 dígitos.';
    END IF;
END IF;


/* PRUEBA 2 */

CREATE PROCEDURE SBO_SP_TransactionNotification_CLIENT
(
    in object_type nvarchar(30),                -- SBO Object Type
    in transaction_type nchar(1),               -- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
    in num_of_cols_in_key int,
    in list_of_key_cols_tab_del nvarchar(255),
    in list_of_cols_val_tab_del nvarchar(255), 
    -- Return values
    out error int,                               -- Result (0 for no error)
    out error_message nvarchar (200)            -- Error string to be displayed
)
LANGUAGE SQLSCRIPT
AS
BEGIN
    -- Validación para agregar o actualizar un cliente o proveedor en OCRD
    IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
        DECLARE customerExists INT;
        DECLARE email NVARCHAR(100);
        DECLARE phone NVARCHAR(50);
        
        -- Verificar si el cliente o proveedor ya existe en OCRD
        SELECT COUNT(*)
        INTO customerExists
        FROM OCRD
        WHERE "CardCode" = :list_of_key_cols_tab_del;  -- Suponiendo que el código del cliente/proveedor se pasa aquí
        
        IF customerExists = 0 THEN
            error := 1;
            error_message := N'DPE: Debe agregar al menos un cliente o proveedor.';
            RETURN;
        END IF;

        -- Validar campos de correo y teléfono
        SELECT T0."Email", T0."Phone1"
        INTO email, phone
        FROM OCRD T0 
        WHERE T0."CardCode" = :list_of_key_cols_tab_del;

        IF email IS NULL OR email = '' THEN
            error := 2;
            error_message := N'DPE: Debe ingresar un correo electrónico válido.';
            RETURN;
        END IF;

        IF phone IS NULL OR phone = '' THEN
            error := 3;
            error_message := N'DPE: Debe ingresar un número de teléfono válido.';
            RETURN;
        END IF;
    END IF;

    -- ... (resto de su procedimiento existente)

END;


/* prueba 3 */

-- Validate Business Partner (OCRD)
IF :object_type = '2' AND ( :transaction_type = 'A' OR :transaction_type = 'U') THEN
    DECLARE BP_EXISTS INT;
    SELECT COUNT(*) INTO BP_EXISTS
    FROM OCRD T0
    WHERE T0."CardCode" IN (SELECT "CardCode" FROM OCRD WHERE "CardType" IN ('C', 'S', 'L'));
    
    IF BP_EXISTS = 0 THEN
        error := 3;
        error_message := N'No existe al menos un cliente, proveedor o lead';
    END IF;
    
    -- Validate email and phone number
    DECLARE EMAIL_VALID INT;
    DECLARE PHONE_VALID INT;
    SELECT COUNT(*) INTO EMAIL_VALID
    FROM OCRD T0
    WHERE T0."E_Mail" IS NOT NULL AND T0."E_Mail" <> '';
    
    SELECT COUNT(*) INTO PHONE_VALID
    FROM OCRD T0
    WHERE T0."Phone1" IS NOT NULL AND T0."Phone1" <> '';
    
    IF EMAIL_VALID = 0 THEN
        error := 4;
        error_message := N'No existe un correo electrónico válido';
    END IF;
    
    IF PHONE_VALID = 0 THEN
        error := 5;
        error_message := N'No existe un número de teléfono válido';
    END IF;
END IF;




-- T0."E_Mail" LIKE '%^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$%'
/* ASI ESTA QUEDANDO POR EL MOMENTO */

BP_EXISTS INT;
CARD_NAME_VALID NVARCHAR(100);
EMAIL_VALID NVARCHAR(100);
PHONE_VALID NVARCHAR(20);
MAIN_USAGE NVARCHAR(10);
ADDRESS_VALID NVARCHAR(150);
STREET_VALID NVARCHAR(100);
COLONIA_VALID NVARCHAR(100);
CITY_VALID NVARCHAR(100);
ZIP_CODE_VALID NVARCHAR(50);
COUNTRY_VALID NVARCHAR(50);

-- Validación para agregar o actualizar en OCRD DATOS MAESTRO SOCIO NEGOCIO
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
	
	-- Limitar que al menos exista un CardType donde C = 'Cliente' , S = 'Proveedor' y L = 'Lead'  
    SELECT COUNT(*) INTO BP_EXISTS
    FROM OCRD T0
    WHERE T0."CardCode" IN (SELECT "CardCode" FROM OCRD WHERE "CardType" IN ('C', 'S', 'L'));
    
    --validar nombre y que no acepte caracteres especiales
    SELECT T0."CardName" INTO CARD_NAME_VALID
    FROM OCRD T0
    WHERE T0."CardName" IS NOT NULL AND T0."CardName" <> '' 
    AND T0."CardName" LIKE '%[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]%';
    
    -- validar que no este vacio y sea correo electronico válido
    SELECT T0."E_Mail" INTO EMAIL_VALID
    FROM OCRD T0
    WHERE T0."E_Mail" IS NOT NULL AND T0."E_Mail" <> ''
    AND T0."E_Mail" LIKE '%^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$%' 
    --AND T0."E_Mail" LIKE '%_@__%.__%';
    
    -- validar telefono que no este vacio y que tenga maximo 10 
    SELECT T0."Phone1" INTO PHONE_VALID
    FROM OCRD T0
    WHERE T0."Phone1" IS NOT NULL AND T0."Phone1" <> '' 
    AND LENGTH(T0."Phone1") >= 10;
    
    -- validar el uso principal que sea requerido y no este vacio
    SELECT T0."U_B1SYS_MainUsage" INTO MAIN_USAGE
    FROM OCRD T0
    WHERE T0."U_B1SYS_MainUsage" IS NOT NULL AND T0."U_B1SYS_MainUsage" <> '';
    
    -- Validar en Direcion en CRD1
    SELECT T1."Address" INTO ADDRESS_VALID
    FROM CRD1 T1
    WHERE T1."Address" IS NOT NULL AND T1."Address" <> '';
    
    SELECT T1."Street" INTO STREET_VALID
    FROM CRD1 T1
    WHERE T1."Street" IS NOT NULL AND T1."Street" <> '';
    
    SELECT T1."Colonia" INTO COLONIA_VALID
    FROM CRD1 T1
    WHERE T1."Colonia" IS NOT NULL AND T1."Colonia" <> '';
    
    SELECT T1."City" INTO CITY_VALID
    FROM CRD1 T1
    WHERE T1."City" IS NOT NULL AND T1."City" <> '';
    
    SELECT T1."ZipCode" INTO ZIP_CODE_VALID
    FROM CRD1 T1
    WHERE T1."ZipCode" IS NOT NULL AND T1."ZipCode" <> '';
    
    SELECT T1."Country" INTO COUNTRY_VALID
    FROM CRD1 T1
    WHERE T1."Country" IS NOT NULL AND T1."Country" <> '';
    
    IF BP_EXISTS = 0 THEN
        error := 1;
        error_message := N'Debe seleccionar al menos un cliente, proveedor o lead';
    END IF;
    
    IF CARD_NAME_VALID IS NULL THEN
        error := 2;
        error_message := N'El nombre del cliente o proveedor debe contener solo letras, acentos y espacios. No se permiten caracteres especiales.';
    END IF;
    
    IF EMAIL_VALID IS NULL THEN
        error := 3;
        error_message := N'No existe un correo electrónico válido';
    END IF;
    
    IF PHONE_VALID IS NULL THEN
        error := 4;
        error_message := N'No existe un número de teléfono válido';
    END IF;
    
    IF MAIN_USAGE IS NULL THEN
        error := 5;
        error_message := N'El uso principal es requerido';
    END IF;
    
    IF ADDRESS_VALID IS NULL THEN
        error := 6;
        error_message := N'La dirección es requerida';
    END IF;
    
    IF STREET_VALID IS NULL THEN
        error := 7;
        error_message := N'La calle/número es requerida';
    END IF;
    
    IF COLONIA_VALID IS NULL THEN
        error := 8;
        error_message := N'La colonia es requerida';
    END IF;
    
    IF CITY_VALID IS NULL THEN
        error := 9;
        error_message := N'La ciudad es requerida';
    END IF;
    
    IF ZIP_CODE_VALID IS NULL THEN
        error := 10;
        error_message := N'El código postal es requerido';
    END IF;
    
    IF COUNTRY_VALID IS NULL THEN
        error := 10;
        error_message := N'El país/región es requerido';
    END IF;
 

END IF;


/* ESTE ES OTRO EJEMPLO VERSION 2 */

BP_EXISTS INT;
CARD_NAME_VALID NVARCHAR(100);
EMAIL_VALID NVARCHAR(100);
PHONE_VALID NVARCHAR(20);
MAIN_USAGE NVARCHAR(10);
ADDRESS_VALID NVARCHAR(150);
STREET_VALID NVARCHAR(100);
COLONIA_VALID NVARCHAR(100);
CITY_VALID NVARCHAR(100);
ZIP_CODE_VALID NVARCHAR(50);
COUNTRY_VALID NVARCHAR(50);
PAYMENT_CONDITION_VALID INT;
PAYMENT_METHOD_CHECK_VALID INT;
LIC_TRAD_NUM_VALID INT;

-- Validación para agregar o actualizar en OCRD DATOS MAESTRO SOCIO NEGOCIO
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

    -- Contar al menos un tipo de socio de negocio
    SELECT COUNT(*) INTO BP_EXISTS
    FROM OCRD T0
    WHERE T0."CardType" IN ('C', 'S', 'L');
    
    -- Validaciones
    SELECT 
        MAX(
        	CASE 
        		WHEN T0."CardName" IS NULL OR T0."CardName" = ''
        		OR T0."CardName" LIKE '^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$'
        	THEN 1 ELSE 0 END
        ) AS CardNameCheck,
        MAX(
            CASE 
                WHEN T0."E_Mail" IS NULL OR T0."E_Mail" = '' 
                OR T0."E_Mail" NOT LIKE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$' 
            THEN 1 ELSE 0 END
        ) AS EmailCheck,
        MAX(CASE WHEN T0."Phone1" IS NULL OR LENGTH(T0."Phone1") < 10 THEN 1 ELSE 0 END) AS PhoneCheck,
        MAX(CASE WHEN T0."U_B1SYS_MainUsage" IS NULL OR T0."U_B1SYS_MainUsage" = '' THEN 1 ELSE 0 END) AS MainUsageCheck,
        MAX(CASE WHEN T1."Address" IS NULL OR T1."Address" = '' THEN 1 ELSE 0 END) AS AddressCheck,
        MAX(CASE WHEN T1."Street" IS NULL OR T1."Street" = '' THEN 1 ELSE 0 END) AS StreetCheck,
        MAX(CASE WHEN T1."Block" IS NULL OR T1."Block" = '' THEN 1 ELSE 0 END) AS ColoniaCheck,
        MAX(CASE WHEN T1."City" IS NULL OR T1."City" = '' THEN 1 ELSE 0 END) AS CityCheck,
        MAX(CASE WHEN T1."ZipCode" IS NULL OR T1."ZipCode" = '' THEN 1 ELSE 0 END) AS ZipCodeCheck,
        MAX(CASE WHEN T1."Country" IS NULL OR T1."Country" = '' THEN 1 ELSE 0 END) AS CountryCheck,
        MAX(
        	CASE WHEN T0."GroupNum" IS NULL 
        	OR NOT EXISTS (SELECT 1 FROM OCTG T2 WHERE T2."GroupNum" = T0."GroupNum") 
        	THEN 1 ELSE 0 END
        ) AS PaymentCondition,
        MAX(
            CASE 
                WHEN NOT EXISTS (
                    SELECT 1 
                    FROM OPYM T3 
                    WHERE T3."PayMethCod" IN ('Cheque', 'Transferencia') 
                    AND T3."PayMethCod" = T0."PymCode"
                 ) 
            THEN 1 ELSE 0 END
        ) AS PaymentMethodCheck,
         MAX(
             CASE 
                 WHEN EXISTS (
                      SELECT 1 
                      FROM OCQG T4 
                      WHERE T4."GroupName" = 'Comercio Exterior'
                 ) 
                 AND T0."LicTradNum" != 'XEXX010101000'
             THEN 1 ELSE 0 END
          ) AS LicTradNumCheck
        /*MAX(
        	CASE WHEN T0."GroupNum" IS NULL 
        	OR T0."GroupNum" NOT IN (SELECT "GroupNum" FROM OCTG) THEN 1 ELSE 0 END
        ) AS PaymentGroupCheck*/
    INTO 
        CARD_NAME_VALID, EMAIL_VALID, PHONE_VALID, MAIN_USAGE, 
        ADDRESS_VALID, STREET_VALID, COLONIA_VALID, CITY_VALID, ZIP_CODE_VALID, COUNTRY_VALID,
        PAYMENT_CONDITION_VALID, PAYMENT_METHOD_CHECK_VALID, LIC_TRAD_NUM_VALID
    FROM OCRD T0
    LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode" 
    WHERE T0."CardCode" = :list_of_cols_val_tab_del;
    
    -- Asignar errores
    IF BP_EXISTS = 0 THEN
        error := 1;
        error_message := N'Debe seleccionar al menos un cliente, proveedor o lead';
    END IF;

    IF CARD_NAME_VALID = 1 THEN
        error := 2;
        error_message := N'El nombre del cliente o proveedor es requerido y debe contener solo letras, espacios y tildes.';
    END IF;

    IF EMAIL_VALID = 1 THEN
        error := 3;
        error_message := N'No existe un correo electrónico válido';
    END IF;

    IF PHONE_VALID = 1 THEN
        error := 4;
        error_message := N'No existe un número de teléfono válido';
    END IF;

    IF MAIN_USAGE = 1 THEN
        error := 5;
        error_message := N'El uso principal es requerido';
    END IF;

    IF ADDRESS_VALID = 1 THEN
        error := 6;
        error_message := N'La dirección es requerida';
    END IF;

    IF STREET_VALID = 1 THEN
        error := 7;
        error_message := N'La calle/número es requerida';
    END IF;

    IF COLONIA_VALID = 1 THEN
        error := 8;
        error_message := N'La colonia es requerida';
    END IF;

    IF CITY_VALID = 1 THEN
        error := 9;
        error_message := N'La ciudad es requerida';
    END IF;

    IF ZIP_CODE_VALID = 1 THEN
        error := 10;
        error_message := N'El código postal es requerido';
    END IF;

    IF COUNTRY_VALID = 1 THEN
        error := 11;
        error_message := N'El país/región es requerido';
    END IF;
    
    IF PAYMENT_CONDITION_VALID = 1 THEN
    	error := 12;
    	error_message := N'La condición de pago es requerida.';
	END IF;
	
	IF PAYMENT_METHOD_CHECK_VALID = 1 THEN
        error := 13;
        error_message := N'El método de pago debe ser Cheque o Transferencia y debe estar marcado como fijo al menos uno.';
    END IF;
   
    IF LIC_TRAD_NUM_VALID = 1 THEN  
        error := 14;  
        error_message := N'El RFC debe ser XEXX010101000 cuando el grupo es Comercio Exterior.';  
    END IF;
    

END IF;



/* VERSION 3 Y ASI QUEDA POR EL MOMENTO */

-- Validación para agregar o actualizar en OCRD DATOS MAESTRO SOCIO NEGOCIO
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

    -- Contar al menos un tipo de socio de negocio
    SELECT COUNT(*) INTO BP_EXISTS
    FROM OCRD T0
    WHERE T0."CardType" IN ('C', 'S', 'L');
    
    -- Validaciones
    SELECT 
        MAX(
        	CASE 
        		WHEN T0."CardName" IS NULL OR T0."CardName" = ''
        		OR NOT T0."CardName" LIKE_REGEXPR '^[a-zA-ZáéíóúÁÉÍÓÚñÑ .]+$'
        	THEN 1 ELSE 0 END
        ) AS CardNameCheck,
        MAX(
		    CASE 
		        -- Si el campo de correo electrónico está vacío o nulo, debe ser requerido
		        WHEN T0."E_Mail" IS NULL OR T0."E_Mail" = '' 
		        THEN 1 
		        -- Validar formato del correo electrónico si el campo no está vacío
                WHEN T0."E_Mail" NOT LIKE_REGEXPR '^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,4}$'
                --WHEN T0."E_Mail" NOT LIKE_REGEXPR '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$' 
		        --WHEN T0."E_Mail" NOT LIKE_REGEXPR '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$' 
		        THEN 2 
		        ELSE 0 
		    END
		) AS EmailCheck,
        /*MAX(
            CASE 
                WHEN T0."E_Mail" IS NULL OR T0."E_Mail" = '' 
                OR T0."E_Mail" NOT LIKE_REGEXPR '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$'
                -- EJEMPLO DE VALIDACION DE CORREO : facturacion@valrani.com.mx 
            THEN 1 ELSE 0 END
        ) AS EmailCheck,*/
        MAX(CASE WHEN T0."Phone1" IS NULL OR LENGTH(T0."Phone1") < 10 THEN 1 ELSE 0 END) AS PhoneCheck,
        MAX(CASE WHEN T0."U_B1SYS_MainUsage" IS NULL OR T0."U_B1SYS_MainUsage" = '' THEN 1 ELSE 0 END) AS MainUsageCheck,
        MAX(CASE WHEN T1."Address" IS NULL OR T1."Address" = '' THEN 1 ELSE 0 END) AS AddressCheck,
        MAX(CASE WHEN T1."Street" IS NULL OR T1."Street" = '' THEN 1 ELSE 0 END) AS StreetCheck,
        MAX(CASE WHEN T1."Block" IS NULL OR T1."Block" = '' THEN 1 ELSE 0 END) AS ColoniaCheck,
        MAX(CASE WHEN T1."City" IS NULL OR T1."City" = '' THEN 1 ELSE 0 END) AS CityCheck,
        MAX(CASE WHEN T1."ZipCode" IS NULL OR T1."ZipCode" = '' THEN 1 ELSE 0 END) AS ZipCodeCheck,
        MAX(CASE WHEN T1."Country" IS NULL OR T1."Country" = '' THEN 1 ELSE 0 END) AS CountryCheck,
        MAX(
        	CASE WHEN T0."GroupNum" IS NULL 
        	OR NOT EXISTS (SELECT 1 FROM OCTG T2 WHERE T2."GroupNum" = T0."GroupNum") 
        	THEN 1 ELSE 0 END
        ) AS PaymentCondition,
        /*MAX(
            CASE 
                WHEN NOT EXISTS (
                    SELECT 1 
                    FROM OPYM T3 
                    WHERE T3."PayMethCod" IN ('Cheque', 'Transferencia') 
                    AND T3."PayMethCod" = T0."PymCode"
                 ) 
            THEN 1 ELSE 0 END
        ) AS PaymentMethodCheck,*/
         MAX(
             CASE 
                 WHEN EXISTS (
                      SELECT 1 
                      FROM OCQG T4 
                      WHERE T4."GroupName" = 'Comercio Exterior'
                      AND T4."GroupCode" = T0."GroupCode"
                 ) 
                 AND T0."LicTradNum" != 'XEXX010101000'
             THEN 1 ELSE 0 END
          ) AS LicTradNumCheck,
          MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck
        
    INTO 
        CARD_NAME_VALID, EMAIL_VALID, PHONE_VALID, MAIN_USAGE, 
        ADDRESS_VALID, STREET_VALID, COLONIA_VALID, CITY_VALID, ZIP_CODE_VALID, COUNTRY_VALID,
        PAYMENT_CONDITION_VALID, /*PAYMENT_METHOD_CHECK_VALID,*/ LIC_TRAD_NUM_VALID, ID_FISCAL_VALID
    FROM OCRD T0
    LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode" 
    WHERE T0."CardCode" = :list_of_cols_val_tab_del;
    
    -- Asignar errores
    IF BP_EXISTS = 0 THEN
        error := 1;
        error_message := N'Debe seleccionar al menos un cliente, proveedor o lead';
    END IF;

    IF CARD_NAME_VALID = 1 THEN
        error := 2;
        error_message := N'El nombre del cliente o proveedor es requerido y debe contener solo letras, espacios y tildes.';
    END IF;
    
    IF EMAIL_VALID = 1 THEN
	    error := 3;
	    error_message := N'El correo electrónico es requerido.';
	END IF;
	
	IF EMAIL_VALID = 2 THEN
	    error := 4;
	    error_message := N'El formato del correo electrónico no es válido.';
	END IF;

    IF PHONE_VALID = 1 THEN
        error := 5;
        error_message := N'No existe un número de teléfono válido';
    END IF;

    IF MAIN_USAGE = 1 THEN
        error := 6;
        error_message := N'El uso principal es requerido';
    END IF;

    IF ADDRESS_VALID = 1 THEN
        error := 7;
        error_message := N'La dirección es requerida';
    END IF;

    IF STREET_VALID = 1 THEN
        error := 8;
        error_message := N'La calle/número es requerida';
    END IF;

    IF COLONIA_VALID = 1 THEN
        error := 9;
        error_message := N'La colonia es requerida';
    END IF;

    IF CITY_VALID = 1 THEN
        error := 10;
        error_message := N'La ciudad es requerida';
    END IF;

    IF ZIP_CODE_VALID = 1 THEN
        error := 11;
        error_message := N'El código postal es requerido';
    END IF;

    IF COUNTRY_VALID = 1 THEN
        error := 12;
        error_message := N'El país/región es requerido';
    END IF;
    
    IF PAYMENT_CONDITION_VALID = 1 THEN
    	error := 13;
    	error_message := N'La condición de pago es requerida.';
	END IF;
	
	/*IF PAYMENT_METHOD_CHECK_VALID = 1 THEN
        error := 13;
        error_message := N'El método de pago debe ser Cheque o Transferencia y debe estar marcado como fijo al menos uno.';
    END IF;*/
   
    IF LIC_TRAD_NUM_VALID = 1 THEN  
        error := 14;  
        error_message := N'El RFC debe ser XEXX010101000 cuando el grupo es Comercio Exterior.';  
    END IF;
    
    IF ID_FISCAL_VALID = 1 THEN
        error := 15;
        error_message := N'El Id fiscal federal unificado es requerido';
    END IF;
    

END IF;




