-- valor del sueldo * 30% / por los dias trabajados

CREATE PROCEDURE SBO_SP_TransactionNotification_CLIENT
(
    IN object_type NVARCHAR(30),                -- SBO Object Type
    IN transaction_type NCHAR(1),               -- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
    IN num_of_cols_in_key INT,
    IN list_of_key_cols_tab_del NVARCHAR(255),
    IN list_of_cols_val_tab_del NVARCHAR(255), 
    -- Return values
    OUT error INT,                              -- Result (0 for no error)
    OUT error_message NVARCHAR(200)             -- Error string to be displayed
)
LANGUAGE SQLSCRIPT
AS
---- Custom Variables
DECLARE
    DOCNUM NVARCHAR(10);
    DOCENTRY NVARCHAR(10);
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

    BP_EXISTS INT;
    CARD_NAME_VALID INT;
    EMAIL_VALID INT;
    PHONE_VALID INT;
    MAIN_USAGE INT;
    ADDRESS_VALID INT;
    STREET_VALID INT;
    COLONIA_VALID INT;
    CITY_VALID INT;
    ZIP_CODE_VALID INT;
    COUNTRY_VALID INT;
    PAYMENT_CONDITION_VALID INT;
    
    LIC_TRAD_NUM_VALID INT;
    ID_FISCAL_VALID INT;

BEGIN  
-- Validaciones para artículos (tipo 4)
IF :object_type = '4' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
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

-- Validación para agregar o actualizar en OCRD (Datos Maestro Socio Negocio)
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

	-- Contar al menos un tipo de socio de negocio
	SELECT COUNT(*) INTO BP_EXISTS
	FROM OCRD T0
	WHERE T0."CardType" IN ('C', 'S', 'L');
	
	-- Validaciones de datos del socio de negocio
	SELECT 
        MAX(CASE 
            WHEN T0."CardName" IS NULL OR T0."CardName" = ''
            OR NOT T0."CardName" LIKE_REGEXPR '^[a-zA-ZáéíóúÁÉÍÓÚñÑ .]+$'
            THEN 1 ELSE 0 END) AS CardNameCheck,
        
        MAX(CASE 
            WHEN T0."E_Mail" IS NULL OR T0."E_Mail" = '' 
            THEN 1 
            WHEN T0."E_Mail" NOT LIKE_REGEXPR '^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}(\\.[a-z]{2,})?$' 
            THEN 2 ELSE 0 END) AS EmailCheck,
        
        MAX(CASE WHEN T0."Phone1" IS NULL OR LENGTH(T0."Phone1") < 10 THEN 1 ELSE 0 END) AS PhoneCheck,
        MAX(CASE WHEN T0."U_B1SYS_MainUsage" IS NULL OR T0."U_B1SYS_MainUsage" = '' THEN 1 ELSE 0 END) AS MainUsageCheck,
        MAX(CASE WHEN T1."Address" IS NULL OR T1."Address" = '' THEN 1 ELSE 0 END) AS AddressCheck,
        MAX(CASE WHEN T1."Street" IS NULL OR T1."Street" = '' THEN 1 ELSE 0 END) AS StreetCheck,
        MAX(CASE WHEN T1."Block" IS NULL OR T1."Block" = '' THEN 1 ELSE 0 END) AS ColoniaCheck,
        MAX(CASE WHEN T1."City" IS NULL OR T1."City" = '' THEN 1 ELSE 0 END) AS CityCheck,
        MAX(CASE WHEN T1."ZipCode" IS NULL OR T1."ZipCode" = '' THEN 1 ELSE 0 END) AS ZipCodeCheck,
        MAX(CASE WHEN T1."Country" IS NULL OR T1."Country" = '' THEN 1 ELSE 0 END) AS CountryCheck,
        
        MAX(CASE 
            WHEN T0."GroupNum" IS NULL 
            OR NOT EXISTS (SELECT 1 FROM OCTG T2 WHERE T2."GroupNum" = T0."GroupNum") 
            THEN 1 ELSE 0 END) AS PaymentCondition,

        MAX(CASE 
            WHEN EXISTS (
                SELECT 1 
                FROM OCQG T4 
                WHERE T4."GroupName" = 'Comercio Exterior'
                AND T4."GroupCode" = T0."GroupCode"
            ) AND T0."LicTradNum" != 'XEXX010101000'
            THEN 1 ELSE 0 END) AS LicTradNumCheck,

        MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck
        
	INTO 
        CARD_NAME_VALID, EMAIL_VALID, PHONE_VALID, MAIN_USAGE, 
        ADDRESS_VALID, STREET_VALID, COLONIA_VALID, CITY_VALID, ZIP_CODE_VALID, COUNTRY_VALID,
        PAYMENT_CONDITION_VALID, LIC_TRAD_NUM_VALID, ID_FISCAL_VALID
	FROM OCRD T0
	LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
	WHERE T0."CardCode" = :list_of_cols_val_tab_del;

	-- Asignar errores según las validaciones realizadas
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

   IF LIC_TRAD_NUM_VALID = 1 THEN  
       error := 14;  
       error_message := N'El RFC debe ser XEXX010101000 cuando el grupo es Comercio Exterior.';  
   END IF;

   IF ID_FISCAL_VALID = 1 THEN
       error := 15;
       error_message := N'El Id fiscal federal unificado es requerido';
   END IF;

END IF; -- Fin de la validación para OCRD

END; -- Fin del procedimiento almacenado




/* otra forma de validacion  */



CREATE PROCEDURE SBO_SP_TransactionNotification_CLIENT
(
    IN object_type NVARCHAR(30),                -- SBO Object Type
    IN transaction_type NCHAR(1),               -- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
    IN num_of_cols_in_key INT,
    IN list_of_key_cols_tab_del NVARCHAR(255),
    IN list_of_cols_val_tab_del NVARCHAR(255), 

    -- Return values
    OUT error INT,                              -- Result (0 for no error)
    OUT error_message NVARCHAR(200)             -- Error string to be displayed
)
LANGUAGE SQLSCRIPT AS

---- Custom Variables
DECLARE DOCNUM NVARCHAR(10);
DECLARE DOCENTRY NVARCHAR(10);
DECLARE DECLA NVARCHAR(10);
DECLARE ITEM NVARCHAR(13);
DECLARE ABSENTRY NVARCHAR(10);
DECLARE POS NVARCHAR(2);
DECLARE ALMACEN NVARCHAR(7);
DECLARE OT NVARCHAR(10);
DECLARE CODCLAS NVARCHAR(15);
DECLARE UNMED NVARCHAR(15);
DECLARE TYPE_ITEM NVARCHAR(2);

DECLARE CODMP NVARCHAR(15);
DECLARE DESCMP NVARCHAR(50);
DECLARE CODSKU NVARCHAR(15);
DECLARE DESCSKU NVARCHAR(50);

DECLARE PLMER INT;
DECLARE PLTOT INT;
DECLARE PLNEC INT; 
DECLARE FECHEN DATE;
DECLARE DESDE NVARCHAR(6);
DECLARE HASTA NVARCHAR(6);
DECLARE USRM INT;
DECLARE USR INT;
DECLARE BODEGA100 NVARCHAR(5);

-- Validaciones para datos del socio negocio
DECLARE BP_EXISTS INT;
DECLARE CARD_NAME_VALID NVARCHAR(100);  -- Cambiado a tipo adecuado
DECLARE EMAIL_VALID NVARCHAR(100);       -- Cambiado a tipo adecuado
DECLARE PHONE_VALID NVARCHAR(20);        -- Cambiado a tipo adecuado
DECLARE MAIN_USAGE NVARCHAR(10);         -- Cambiado a tipo adecuado
DECLARE ADDRESS_VALID NVARCHAR(150);      -- Cambiado a tipo adecuado
DECLARE STREET_VALID NVARCHAR(100);       -- Cambiado a tipo adecuado
DECLARE COLONIA_VALID NVARCHAR(100);      -- Cambiado a tipo adecuado
DECLARE CITY_VALID NVARCHAR(100);         -- Cambiado a tipo adecuado
DECLARE ZIP_CODE_VALID NVARCHAR(50);      -- Cambiado a tipo adecuado
DECLARE COUNTRY_VALID NVARCHAR(50);       -- Cambiado a tipo adecuado
DECLARE PAYMENT_CONDITION_VALID INT; 
DECLARE LIC_TRAD_NUM_VALID INT; 
DECLARE ID_FISCAL_VALID INT;

BEGIN  
    -- Validación para artículos (tipo 4)
    IF :object_type = '4' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
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

    -- Validación para agregar o actualizar en OCRD (Datos Maestro Socio Negocio)
    IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

        -- Contar al menos un tipo de socio de negocio
        SELECT COUNT(*) INTO BP_EXISTS
        FROM OCRD T0
        WHERE T0."CardType" IN ('C', 'S', 'L');

        -- Obtener los valores necesarios en una sola consulta
        SELECT 
            T0."CardName",
            T0."E_Mail",
            T0."Phone1",
            T0."U_B1SYS_MainUsage",
            T1."Address",
            T1."Street",
            T1."Block",
            T1."City",
            T1."ZipCode",
            T1."Country",
            T0."GroupNum",
            T0."LicTradNum",
            T0."VatIdUnCmp"
        INTO 
            CARD_NAME_VALID, EMAIL_VALID, PHONE_VALID, MAIN_USAGE,
            ADDRESS_VALID, STREET_VALID, COLONIA_VALID, CITY_VALID,
            ZIP_CODE_VALID, COUNTRY_VALID, PAYMENT_CONDITION_VALID,
            LIC_TRAD_NUM_VALID, ID_FISCAL_VALID 
        FROM OCRD T0 
        LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode" 
        WHERE T0."CardCode" = :list_of_cols_val_tab_del;

        -- Asignar errores según las validaciones realizadas

        IF BP_EXISTS = 0 THEN
            error := 1;
            error_message := N'Debe seleccionar al menos un cliente, proveedor o lead';
        END IF;

        IF CARD_NAME_VALID IS NULL OR CARD_NAME_VALID = '' OR NOT CARD_NAME_VALID LIKE_REGEXPR '^[a-zA-ZáéíóúÁÉÍÓÚñÑ .]+$' THEN
            error := 2;
            error_message := N'El nombre del cliente o proveedor es requerido y debe contener solo letras, espacios y tildes.';
        END IF;

        IF EMAIL_VALID IS NULL OR EMAIL_VALID = '' THEN
            error := 3;
            error_message := N'El correo electrónico es requerido.';
        ELSEIF EMAIL_VALID NOT LIKE_REGEXPR '^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}(\\.[a-z]{2,})?$' THEN
            error := 4;
            error_message := N'El formato del correo electrónico no es válido.';
        END IF;

        IF PHONE_VALID IS NULL OR LENGTH(PHONE_VALID) < 10 THEN
            error := 5;
            error_message := N'No existe un número de teléfono válido';
        END IF;

        IF MAIN_USAGE IS NULL OR MAIN_USAGE = '' THEN
            error := 6;
            error_message := N'El uso principal es requerido';
        END IF;

        IF ADDRESS_VALID IS NULL OR ADDRESS_VALID = '' THEN
            error := 7;
            error_message := N'La dirección es requerida';
        END IF;

        IF STREET_VALID IS NULL OR STREET_VALID = '' THEN
            error := 8;
            error_message := N'La calle/número es requerida';
        END IF;

        IF COLONIA_VALID IS NULL OR COLONIA_VALID = '' THEN
            error := 9;
            error_message := N'La colonia es requerida';
        END IF;

        IF CITY_VALID IS NULL OR CITY_VALID = '' THEN
            error := 10;
            error_message := N'La ciudad es requerida';
        END IF;

        IF ZIP_CODE_VALID IS NULL OR ZIP_CODE_VALID = '' THEN
            error := 11;
            error_message := N'El código postal es requerido';
        END IF;

        IF COUNTRY_VALID IS NULL OR COUNTRY_VALID = '' THEN
            error := 12;
            error_message := N'El país/región es requerido';
        END IF;

       -- Validación de condición de pago si es nula o no existe en OCTG 
       IF PAYMENT_CONDITION_VALID IS NULL OR NOT EXISTS (SELECT 1 FROM OCTG WHERE "GroupNum" = PAYMENT_CONDITION_VALID) THEN  
           error := 13;  
           error_message := N'La condición de pago es requerida.';  
       END IF;

       -- Validación del RFC para comercio exterior 
       IF LIC_TRAD_NUM_VALID != 'XEXX010101000' AND EXISTS (
           SELECT 1 
           FROM OCQG 
           WHERE "GroupName"='Comercio Exterior' AND "GroupCode"=(SELECT "GroupCode" FROM OCRD WHERE "CardCode"=:list_of_cols_val_tab_del)
       ) THEN  
           error := 14;  
           error_message := N'El RFC debe ser XEXX010101000 cuando el grupo es Comercio Exterior.';  
       END IF;

       -- Validación del Id fiscal unificado 
       IF ID_FISCAL_VALID IS NULL OR ID_FISCAL_VALID = '' THEN  
           error := 15;  
           error_message := N'El Id fiscal federal unificado es requerido';  
       END IF;

    END IF; -- Fin de la validación para OCRD

END; -- Fin del procedimiento almacenado


/* ORIGINAL 14/10/2024 */
--OCRD VALIDATION

-- Validación para agregar o actualizar en OCRD (Datos Maestro Socio Negocio)
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

	-- Contar al menos un tipo de socio de negocio
	SELECT COUNT(*) INTO BP_EXISTS
	FROM OCRD T0
	WHERE T0."CardType" IN ('C', 'S', 'L');
	
	-- Validaciones de datos del socio de negocio
	SELECT 
        MAX(CASE 
	            WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
	            WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z ]+$' THEN 2
	            WHEN LENGTH(T0."CardName") > 60 THEN 3
            ELSE 0 
        END) AS CardNameCheck,
        MAX(CASE 
	            WHEN T0."E_Mail" IS NULL OR T0."E_Mail" = '' THEN 1
	            WHEN T0."E_Mail" NOT LIKE_REGEXPR '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN 2
            ELSE 0 
        END) AS EmailCheck,
        MAX(CASE 
		    WHEN T0."Phone1" IS NULL OR T0."Phone1" = '' THEN 1
		    --WHEN LENGTH(T0."Phone1") < 10 THEN 2  -- Teléfono con menos de 10 caracteres
		    --WHEN LENGTH(T0."Phone1") > 15 THEN 3  -- Teléfono con más de 15 caracteres
		    WHEN T0."Phone1" NOT LIKE_REGEXPR '^[0-9]+$' THEN 2  -- Teléfono contiene caracteres no numéricos
		    ELSE 0 
		END) AS PhoneCheck,
        MAX(CASE WHEN T0."U_B1SYS_MainUsage" IS NULL OR T0."U_B1SYS_MainUsage" = '' THEN 1 ELSE 0 END) AS MainUsageCheck,
        MAX(CASE WHEN T1."Address" IS NULL OR T1."Address" = '' THEN 1 ELSE 0 END) AS AddressCheck,
        MAX(CASE WHEN T1."Street" IS NULL OR T1."Street" = '' THEN 1 ELSE 0 END) AS StreetCheck,
        MAX(CASE WHEN T1."Block" IS NULL OR T1."Block" = '' THEN 1 ELSE 0 END) AS ColoniaCheck,
        MAX(CASE WHEN T1."City" IS NULL OR T1."City" = '' THEN 1 ELSE 0 END) AS CityCheck,
        MAX(CASE WHEN T1."ZipCode" IS NULL OR T1."ZipCode" = '' THEN 1 ELSE 0 END) AS ZipCodeCheck,
        MAX(CASE
            WHEN T1."Country" IS NULL OR T1."Country" = '' THEN 1
            WHEN LENGTH(T2."Code") = 3 THEN 2  -- Si el código tiene 3 caracteres (inhabilitado) 
		    ELSE 0 
		END) AS CountryCheck,  
        MAX(CASE 
            WHEN T0."GroupNum" IS NULL OR NOT EXISTS (SELECT 1 FROM OCTG T2 WHERE T2."GroupNum" = T0."GroupNum") THEN 1 
            ELSE 0 
        END) AS PaymentCondition,
        -- Validación de RFC para Comercio Exterior
        MAX(CASE 
                WHEN EXISTS (SELECT 1 FROM OCQG T4 WHERE T4."GroupCode" = T0."GroupCode" AND T4."GroupCode" = 1) 
                     AND T0."LicTradNum" != 'XEXX010101000' THEN 1  -- Comercio Exterior y RFC incorrecto
                WHEN NOT EXISTS (SELECT 1 FROM OCQG T4 WHERE T4."GroupCode" = T0."GroupCode" AND T4."GroupCode" = 1) 
                     AND (T0."LicTradNum" IS NULL OR T0."LicTradNum" = '') THEN 2  -- RFC vacío cuando no es Comercio Exterior
            ELSE 0 
        END) AS LicTradNumCheck,
        /*MAX(CASE 
            WHEN EXISTS (
                SELECT 1 
                FROM OCQG T4 
                WHERE T4."GroupName" = 'Comercio Exterior'
                AND T4."GroupCode" = T0."GroupCode"
            ) AND T0."LicTradNum" != 'XEXX010101000'
            THEN 1 ELSE 0 END) AS LicTradNumCheck,*/
            
        MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck
        
	INTO 
        CARD_NAME_VALID, EMAIL_VALID, PHONE_VALID, MAIN_USAGE, 
        ADDRESS_VALID, STREET_VALID, COLONIA_VALID, CITY_VALID, ZIP_CODE_VALID, COUNTRY_VALID,
        PAYMENT_CONDITION_VALID, LIC_TRAD_NUM_VALID, ID_FISCAL_VALID
	FROM OCRD T0
	LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
	LEFT JOIN OCRY T2 ON T1."Country" = T2."Code"
	WHERE T0."CardCode" = :list_of_cols_val_tab_del;
	
	-- Asignar errores según las validaciones realizadas

    -- VALICACION DEL TIPO DEL NEGOCIO
	IF BP_EXISTS = 0 THEN
		error := 1;
		error_message := N'Debe seleccionar al menos un cliente, proveedor o lead';
	END IF;
	-- FIN VALICACION DEL TIPO DEL NEGOCIO

    -- VALICACION DEL CARD_NAME
	IF CARD_NAME_VALID = 1 THEN
		error := 2;
		error_message := N'El nombre del cliente o proveedor es requerido.';
	END IF;
	
	IF CARD_NAME_VALID = 2 THEN
		error := 3;
		error_message := N'El nombre del cliente o proveedor debe contener solo letras, No caracteres especiales o "Ñ"';
	END IF;
	
	IF CARD_NAME_VALID = 3 THEN
	    error := 4;
	    error_message := N'El nombre del cliente o proveedor no debe exceder los 60 caracteres.';
	END IF;
	-- FIN VALICACION DEL CARD_NAME
	
    -- VALICACION DEL EMAIL_VALID
	IF EMAIL_VALID = 1 THEN
	    error := 5;
	    error_message := N'El correo electrónico es requerido.';
	END IF;

	IF EMAIL_VALID = 2 THEN
	    error := 6;
	    error_message := N'El formato del correo electrónico no es válido.';
	END IF;
	-- FIN VALICACION DEL EMAIL_VALID

	-- VALICACION DEL PHONE_VALID
	IF PHONE_VALID = 1 THEN
	    error := 7;
	    error_message := N'El número de teléfono es requerido.';
	END IF;
	
	IF PHONE_VALID = 2 THEN
	    error := 8;
	    error_message := N'El número de teléfono debe contener solo números.';
	END IF;
	
	/*IF PHONE_VALID = 2 THEN
	    error := 8;
	    error_message := N'El número de teléfono debe tener al menos 10 dígitos.';
	END IF;
	
	IF PHONE_VALID = 3 THEN
	    error := 9;
	    error_message := N'El número de teléfono no debe exceder los 15 dígitos.';
	END IF;*/
	-- FIN VALICACION DEL PHONE_VALID

    -- VALICACION DEL MAIN_USAGE
	IF MAIN_USAGE = 1 THEN
	    error := 9;
	    error_message := N'El uso principal es requerido';
	END IF;
	-- FIN VALICACION DEL MAIN_USAGE

    -- VALICACION DEL ADDRESS_VALID
	IF ADDRESS_VALID = 1 THEN
	    error := 10;
	    error_message := N'La dirección es requerida';
	END IF;
	-- FIN VALICACION DEL ADDRESS_VALID

    -- VALICACION DEL STREET_VALID
	IF STREET_VALID = 1 THEN
	    error := 11;
	    error_message := N'La calle/número es requerida';
	END IF;
	-- FIN VALICACION DEL STREET_VALID

    -- VALICACION DEL COLONIA_VALID
	IF COLONIA_VALID = 1 THEN
	    error := 12;
	    error_message := N'La colonia es requerida';
	END IF;
	-- FIN VALICACION DEL COLONIA_VALID

    -- VALICACION DEL CITY_VALID
	IF CITY_VALID = 1 THEN
	    error := 13;
	    error_message := N'La ciudad es requerida';
	END IF;
	-- FIN VALICACION DEL CITY_VALID

    -- VALICACION DEL ZIP_CODE_VALID
	IF ZIP_CODE_VALID = 1 THEN
	    error := 14;
	    error_message := N'El código postal es requerido';
	END IF;
	-- FIN VALICACION DEL ZIP_CODE_VALID

    -- VALICACION DEL COUNTRY_VALID
	IF COUNTRY_VALID = 1 THEN
	    error := 15;
	    error_message := N'El país/región es requerido';
	END IF;
	
	IF COUNTRY_VALID = 2 THEN
	    error := 16;
	    error_message := N'El país/región que seleccionaste esta inabilitado.';
	END IF;
	-- VALICACION DEL COUNTRY_VALID

    -- VALICACION DEL PAYMENT_CONDITION_VALID
	IF PAYMENT_CONDITION_VALID = 1 THEN
    	error := 17;
    	error_message := N'La condición de pago es requerida.';
	END IF;
    -- FIN VALICACION DEL PAYMENT_CONDITION_VALID

    -- VALICACION DEL LIC_TRAD_NUM_VALID
	IF LIC_TRAD_NUM_VALID = 1 THEN
	    error := 18;
	    error_message := N'Para Comercio Exterior, el RFC debe ser "XEXX010101000".';
	END IF;

	IF LIC_TRAD_NUM_VALID = 2 THEN
	    error := 19;
	    error_message := N'El RFC es requerido cuando no es Comercio Exterior.';
	END IF;
	-- FIN VALICACION DEL LIC_TRAD_NUM_VALID

	
 

	
  
   IF ID_FISCAL_VALID = 1 THEN
       error := 20;
       error_message := N'El Id fiscal federal unificado es requerido';
   END IF;

END IF; -- Fin de la validación para OCRD


/* 
SELECT 
   T0."CardCode", 
   T0."CardName",
   T4.*
FROM OCRD T0  
LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
LEFT JOIN OCRY T2 ON T1."Country" = T2."Code"
LEFT JOIN OPYM T3 ON T0."PymCode" = T3."PayMethCod"
LEFT JOIN ATC1 T4 ON T0."AtcEntry" = T4."AbsEntry"
--WHERE T0."CardCode" = 'PZUMJ760508HM0'

 */


-- [Form=134 Item=217 Pane=8 Column=5 Row=22 Variable=93]
/* POR EL MOMENTO QUEDO ASI 15-10-2024 */

--OCRD VALIDATION
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
ID_FISCAL_VALID NVARCHAR(100);
REGIMEN_FISCAL_V4_VALID NVARCHAR(50);
ANEXOS_VALID INT;

--OCRD VALIDATION

-- Validación para agregar o actualizar en OCRD (Datos Maestro Socio Negocio)
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

	-- Contar al menos un tipo de socio de negocio
	SELECT COUNT(*) INTO BP_EXISTS
	FROM OCRD T0
	WHERE T0."CardType" IN ('C', 'S', 'L');
	
	-- Validaciones de datos del socio de negocio
	SELECT 
        MAX(CASE 
	            WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
	            WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z .]+$' THEN 2
	            WHEN LENGTH(T0."CardName") > 60 THEN 3
            ELSE 0 
        END) AS CardNameCheck, 
        MAX(CASE 
	            WHEN T0."E_Mail" IS NULL OR T0."E_Mail" = '' THEN 1
	            WHEN T0."E_Mail" NOT LIKE_REGEXPR '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN 2
            ELSE 0 
        END) AS EmailCheck,
        MAX(CASE 
		    WHEN T0."Phone1" IS NULL OR T0."Phone1" = '' THEN 1
		    --WHEN LENGTH(T0."Phone1") < 10 THEN 2  -- Teléfono con menos de 10 caracteres
		    --WHEN LENGTH(T0."Phone1") > 15 THEN 3  -- Teléfono con más de 15 caracteres
		    WHEN T0."Phone1" NOT LIKE_REGEXPR '^[0-9]+$' THEN 2  -- Teléfono contiene caracteres no numéricos
		    ELSE 0 
		END) AS PhoneCheck,
        MAX(CASE WHEN T0."U_B1SYS_MainUsage" IS NULL OR T0."U_B1SYS_MainUsage" = '' THEN 1 ELSE 0 END) AS MainUsageCheck,
        MAX(CASE WHEN T1."Address" IS NULL OR T1."Address" = '' THEN 1 ELSE 0 END) AS AddressCheck,
        MAX(CASE WHEN T1."Street" IS NULL OR T1."Street" = '' THEN 1 ELSE 0 END) AS StreetCheck,
        MAX(CASE WHEN T1."Block" IS NULL OR T1."Block" = '' THEN 1 ELSE 0 END) AS ColoniaCheck,
        MAX(CASE WHEN T1."City" IS NULL OR T1."City" = '' THEN 1 ELSE 0 END) AS CityCheck,
        MAX(CASE WHEN T1."ZipCode" IS NULL OR T1."ZipCode" = '' THEN 1 ELSE 0 END) AS ZipCodeCheck,
        MAX(CASE
            WHEN T1."Country" IS NULL OR T1."Country" = '' THEN 1
            WHEN LENGTH(T2."Code") = 3 THEN 2  -- Si el código tiene 3 caracteres (inhabilitado) 
		    ELSE 0 
		END) AS CountryCheck,  
        MAX(CASE 
            WHEN T0."GroupNum" IS NULL OR NOT EXISTS (SELECT 1 FROM OCTG T2 WHERE T2."GroupNum" = T0."GroupNum") THEN 1 
            ELSE 0 
        END) AS PaymentCondition,
        -- Validación de comercio exterior (QryGroup1) y LictradNum
	    MAX(CASE 
	        WHEN T0."QryGroup1" = 'Y' AND T0."LicTradNum" != 'XEXX010101000' THEN 1  -- Comercio exterior pero LicTradNum incorrecto
	        WHEN T0."QryGroup1" = 'N' AND T0."LicTradNum" = 'XEXX010101000' THEN 2  -- No es comercio exterior pero LicTradNum es incorrecto
	        WHEN T0."QryGroup1" = 'Y' AND T2."Code" = 'MX' THEN 3  -- Código del país es Mexico y está marcado como comercio exterior
	        ELSE 0 
	    END) AS LicTradNumCheck,
        MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck,
        MAX(CASE WHEN T0."U_SYP_FPAGO" IS NULL OR T0."U_SYP_FPAGO" = '' THEN 1 ELSE 0 END) AS RegimenFiscalV4Check,
        
        -- Validación de métodos de pago
	    /*MAX(CASE
	        WHEN T0."PymCode" IS NULL 
	        --OR T3."PayMethCod" IS NULL 
	        THEN 1 
	        --WHEN T0."PymCode" IS NULL OR NOT EXISTS (SELECT 1 FROM OPYM T3 WHERE T0."PymCode" = T3."PayMethCod") THEN 1
	        ELSE 0 
	    END) AS PayMethCodCheck,*/
	    
	   /*MAX(CASE
			WHEN T0."PymCode" IS NULL 
			OR NOT EXISTS (
				SELECT 1 FROM OPYM T3 WHERE T0."PymCode" = T3."PayMethCod" AND T3."Active" = 'Y'
			) THEN 1 
			ELSE 0 
		END) AS PayMethCodCheck,*/
		
		/*MAX(CASE
	        WHEN T0."PymCode" IS NULL 
	        OR T0."PymCode" = -1  -- Verifica si no hay un método de pago asignado
	        OR NOT EXISTS (SELECT 1 FROM OPYM T3 WHERE T0."PymCode" = T3."PayMethCod" AND T3."Active" = 'Y') -- Verifica si el método está activo
	        THEN 1 
	        ELSE 0 
	    END) AS PayMethCodCheck,*/
	    
	    /*MAX(CASE
	        WHEN T0."PymCode" = -1  -- Verifica si no hay un método de pago asignado
	        --OR NOT EXISTS (SELECT 1 FROM OPYM T3 WHERE T0."PymCode" = T3."PayMethCod" AND T3."Active" = 'Y') -- Verifica si el método está activo en OPYM
	        --OR NOT EXISTS (SELECT 1 FROM CRD2 T4 WHERE  T4."PymCode" = T0."PymCode") -- Verifica si el método de pago está incluido en CRD2
	        THEN 1 
	        ELSE 0 
    	END) AS PayMethCodCheck,*/
    	
    	 /*MAX(CASE
	        WHEN T0."PymCode" = -1 THEN 1  -- Verifica si no hay un método de pago asignado
	        WHEN NOT EXISTS (SELECT 1 FROM CRD2 T1 WHERE T1."CardCode" = T0."CardCode") THEN 1 -- Verifica si el método de pago está incluido en CRD2
	        ELSE 0 
	    END) AS PayMethCodCheck,*/
	     /*MAX(CASE
	        WHEN --T5."PymCode" = -1 THEN 1
              NOT EXISTS (SELECT 1 FROM CRD2 T1 WHERE T1."CardCode" = T0."CardCode" AND T1."PymCode" = T0."PymCode") THEN 1
             
	        --WHEN T0."PymCode" = -1 THEN 1  -- Verifica si no hay un método de pago asignado
	        --WHEN T0."PymCode" <> -1 AND NOT EXISTS (SELECT 1 FROM CRD2 T1 WHERE T1."CardCode" = T0."CardCode" AND T1."PymCode" = T0."PymCode") THEN 1 -- Verifica si el método de pago está incluido en CRD2 solo si PymCode es diferente de -1
	        ELSE 0 
	    END) AS PayMethCodCheck,*/
	    
	     MAX(CASE 
	        WHEN T5."CardCode" IS NULL AND T5."PymCode" IS NULL THEN 1 
	        ELSE 0 
	    END) AS PayMethCodCheck,
	    
	    -- Validación de anexos (ATC1)
		MAX(CASE 
		    WHEN NOT EXISTS (SELECT 1 FROM ATC1 T4 WHERE T4."AbsEntry" = T0."AtcEntry") THEN 1 
		    ELSE 0
		END) AS AnexosCheck
        
	INTO 
        CARD_NAME_VALID, EMAIL_VALID, PHONE_VALID, MAIN_USAGE, 
        ADDRESS_VALID, STREET_VALID, COLONIA_VALID, CITY_VALID, ZIP_CODE_VALID, COUNTRY_VALID,
        PAYMENT_CONDITION_VALID, LIC_TRAD_NUM_VALID, ID_FISCAL_VALID, REGIMEN_FISCAL_V4_VALID, PAYMENT_METHOD_CHECK_VALID,
        ANEXOS_VALID
	FROM OCRD T0
	LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
	LEFT JOIN OCRY T2 ON T1."Country" = T2."Code"
	LEFT JOIN OPYM T3 ON T0."PymCode" = T3."PayMethCod"
	LEFT JOIN CRD2 T5 ON T0."CardCode" = T5."CardCode"
	WHERE T0."CardCode" = :list_of_cols_val_tab_del;
	
	-- Asignar errores según las validaciones realizadas

    -- VALICACION DEL TIPO DEL NEGOCIO
	IF BP_EXISTS = 0 THEN
		error := 1;
		error_message := N'Debe seleccionar al menos un cliente, proveedor o lead';
	END IF;
	-- FIN VALICACION DEL TIPO DEL NEGOCIO

    -- VALICACION DEL CARD_NAME
	IF CARD_NAME_VALID = 1 THEN
		error := 2;
		error_message := N'El nombre del cliente o proveedor es requerido.';
	END IF;
	
	IF CARD_NAME_VALID = 2 THEN
		error := 3;
		error_message := N'El nombre del cliente o proveedor debe contener solo letras, No caracteres especiales o "Ñ"';
	END IF;
	
	IF CARD_NAME_VALID = 3 THEN
	    error := 4;
	    error_message := N'El nombre del cliente o proveedor no debe exceder los 60 caracteres.';
	END IF;
	-- FIN VALICACION DEL CARD_NAME
	
    -- VALICACION DEL EMAIL_VALID
	IF EMAIL_VALID = 1 THEN
	    error := 5;
	    error_message := N'El correo electrónico es requerido.';
	END IF;

	IF EMAIL_VALID = 2 THEN
	    error := 6;
	    error_message := N'El formato del correo electrónico no es válido.';
	END IF;
	-- FIN VALICACION DEL EMAIL_VALID

	-- VALICACION DEL PHONE_VALID
	IF PHONE_VALID = 1 THEN
	    error := 7;
	    error_message := N'El número de teléfono es requerido.';
	END IF;
	
	IF PHONE_VALID = 2 THEN
	    error := 8;
	    error_message := N'El número de teléfono debe contener solo números.';
	END IF;
	
	/*IF PHONE_VALID = 2 THEN
	    error := 8;
	    error_message := N'El número de teléfono debe tener al menos 10 dígitos.';
	END IF;
	
	IF PHONE_VALID = 3 THEN
	    error := 9;
	    error_message := N'El número de teléfono no debe exceder los 15 dígitos.';
	END IF;*/
	-- FIN VALICACION DEL PHONE_VALID

    -- VALICACION DEL MAIN_USAGE
	IF MAIN_USAGE = 1 THEN
	    error := 9;
	    error_message := N'El uso principal es requerido';
	END IF;
	-- FIN VALICACION DEL MAIN_USAGE

    -- VALICACION DEL ADDRESS_VALID
	IF ADDRESS_VALID = 1 THEN
	    error := 10;
	    error_message := N'La dirección es requerida';
	END IF;
	-- FIN VALICACION DEL ADDRESS_VALID

    -- VALICACION DEL STREET_VALID
	IF STREET_VALID = 1 THEN
	    error := 11;
	    error_message := N'La calle/número es requerida';
	END IF;
	-- FIN VALICACION DEL STREET_VALID

    -- VALICACION DEL COLONIA_VALID
	IF COLONIA_VALID = 1 THEN
	    error := 12;
	    error_message := N'La colonia es requerida';
	END IF;
	-- FIN VALICACION DEL COLONIA_VALID

    -- VALICACION DEL CITY_VALID
	IF CITY_VALID = 1 THEN
	    error := 13;
	    error_message := N'La ciudad es requerida';
	END IF;
	-- FIN VALICACION DEL CITY_VALID

    -- VALICACION DEL ZIP_CODE_VALID
	IF ZIP_CODE_VALID = 1 THEN
	    error := 14;
	    error_message := N'El código postal es requerido';
	END IF;
	-- FIN VALICACION DEL ZIP_CODE_VALID

    -- VALICACION DEL COUNTRY_VALID
	IF COUNTRY_VALID = 1 THEN
	    error := 15;
	    error_message := N'El país/región es requerido';
	END IF;
	
	IF COUNTRY_VALID = 2 THEN
	    error := 16;
	    error_message := N'El país/región que seleccionaste esta inabilitado.';
	END IF;
	-- VALICACION DEL COUNTRY_VALID

    -- VALICACION DEL PAYMENT_CONDITION_VALID
	IF PAYMENT_CONDITION_VALID = 1 THEN
    	error := 17;
    	error_message := N'La condición de pago es requerida.';
	END IF;
    -- FIN VALICACION DEL PAYMENT_CONDITION_VALID

    -- VALICACION DEL LIC_TRAD_NUM_VALID
    -- Validación de comercio exterior y LictradNum
	IF LIC_TRAD_NUM_VALID = 1 THEN
	    error := 18;
	    error_message := N'El campo RFC debe ser "XEXX010101000" para comercio exterior.';
	END IF;
	
	IF LIC_TRAD_NUM_VALID = 2 THEN
	    error := 19;
	    error_message := N'El campo RFC no debe ser "XEXX010101000" si no es comercio exterior.';
	END IF;
	
	IF LIC_TRAD_NUM_VALID = 3 THEN
	    error := 20;
	    error_message := N'El país Mexico Y NO deberia estar marcado como comercio exterior.';
	END IF;
	-- FIN VALICACION DEL LIC_TRAD_NUM_VALID
	
   -- VALICACION DEL ID_FISCAL_VALID
   IF ID_FISCAL_VALID = 1 THEN
       error := 21;
       error_message := N'El Id fiscal federal unificado es requerido';
   END IF;
   -- FIN VALICACION DEL ID_FISCAL_VALID

  -- VALICACION DEL REGIMEN_FISCAL_V4_VALID
	IF REGIMEN_FISCAL_V4_VALID = 1 THEN
	    error := 22;
	    error_message := N'El regimen fiscal v4 es requerido';
	END IF;
	-- FIN VALICACION DEL REGIMEN_FISCAL_V4_VALID

	-- Validación de métodos de pago
	IF PAYMENT_METHOD_CHECK_VALID = 1 THEN
	    error := 23;
	    error_message := N'El cliente o proveedor no tiene ningún método de pago válido asociado.';
	END IF;
	
	-- Validación de anexos (ATC1)
	IF ANEXOS_VALID = 1 THEN
	    error := 24;
	    error_message := N'El cliente o proveedor no tiene ningún anexo asociado.';
	END IF;

END IF; -- Fin de la validación para OCRD





/* 

Campo "Include": Según los resultados, parece que no hay una tabla directa que almacene el estado del checkbox "Include". 
Este checkbox se relaciona con los métodos de pago que están activos y disponibles para su uso en el sistema, 
pero no se puede consultar directamente desde una tabla específica.
Uso del DTW: Para gestionar métodos de pago a través del Data Transfer Workbench (DTW), 
es necesario definir primero el método en la base de datos y luego utilizar el template adecuado para asignarlo a los socios comerciales. 
Esto puede implicar marcar el checkbox "Include" al importar.


SELECT 
  T0."CardCode", 
  T0."CardName", 
  T0."CardType",
  T2.*, 
  T3.* 
FROM OCRD  T0 
LEFT JOIN CRD2  T2 ON T0."CardCode" = T2."CardCode" 
LEFT JOIN OPYM T3 ON T0."PymCode" = T3."PayMethCod"
 */


 /* 
 CEPM200319CK1

 SELECT *  FROM CRD2 T0 WHERE T0."CardCode" = 'C100006834000'
 

 SELECT  T0."PymCode", *  FROM OCRD T0 WHERE T0."CardCode" = 'C100006834000'
  */



/* asi quedo en produccion EPM maestro socio negocio */
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

--Variables de socio de negocio
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
ID_FISCAL_VALID NVARCHAR(100);
REGIMEN_FISCAL_V4_VALID NVARCHAR(50);
ANEXOS_VALID INT;

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
	
	IF (:USRM NOT IN ('1', '10', '50')) THEN
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

-- Validación para agregar o actualizar en OCRD (Datos Maestro Socio Negocio)
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

	-- Contar al menos un tipo de socio de negocio
	SELECT COUNT(*) INTO BP_EXISTS
	FROM OCRD T0
	WHERE T0."CardType" IN ('C', 'S', 'L');
	
	-- Validaciones de datos del socio de negocio
	SELECT 
        MAX(CASE 
	            WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
	            WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z .]+$' THEN 2
	            WHEN LENGTH(T0."CardName") > 60 THEN 3
            ELSE 0 
        END) AS CardNameCheck, 
        MAX(CASE 
	            WHEN T0."E_Mail" IS NULL OR T0."E_Mail" = '' THEN 1
	            WHEN T0."E_Mail" NOT LIKE_REGEXPR '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN 2
            ELSE 0 
        END) AS EmailCheck,
        MAX(CASE 
		    WHEN T0."Phone1" IS NULL OR T0."Phone1" = '' THEN 1
		    --WHEN LENGTH(T0."Phone1") < 10 THEN 2  -- Teléfono con menos de 10 caracteres
		    --WHEN LENGTH(T0."Phone1") > 15 THEN 3  -- Teléfono con más de 15 caracteres
		    WHEN T0."Phone1" NOT LIKE_REGEXPR '^[0-9]+$' THEN 2  -- Teléfono contiene caracteres no numéricos
		    ELSE 0 
		END) AS PhoneCheck,
        MAX(CASE WHEN T0."U_B1SYS_MainUsage" IS NULL OR T0."U_B1SYS_MainUsage" = '' THEN 1 ELSE 0 END) AS MainUsageCheck,
        MAX(CASE WHEN T1."Address" IS NULL OR T1."Address" = '' THEN 1 ELSE 0 END) AS AddressCheck,
        MAX(CASE WHEN T1."Street" IS NULL OR T1."Street" = '' THEN 1 ELSE 0 END) AS StreetCheck,
        MAX(CASE WHEN T1."Block" IS NULL OR T1."Block" = '' THEN 1 ELSE 0 END) AS ColoniaCheck,
        MAX(CASE WHEN T1."City" IS NULL OR T1."City" = '' THEN 1 ELSE 0 END) AS CityCheck,
        MAX(CASE WHEN T1."ZipCode" IS NULL OR T1."ZipCode" = '' THEN 1 ELSE 0 END) AS ZipCodeCheck,
        MAX(CASE
            WHEN T1."Country" IS NULL OR T1."Country" = '' THEN 1
            WHEN LENGTH(T2."Code") = 3 THEN 2  -- Si el código tiene 3 caracteres (inhabilitado) 
		    ELSE 0 
		END) AS CountryCheck,  
        MAX(CASE 
            WHEN T0."GroupNum" IS NULL OR NOT EXISTS (SELECT 1 FROM OCTG T2 WHERE T2."GroupNum" = T0."GroupNum") THEN 1 
            ELSE 0 
        END) AS PaymentCondition,
        -- Validación de comercio exterior (QryGroup1) y LictradNum
	    MAX(CASE 
	        WHEN T0."QryGroup1" = 'Y' AND T0."LicTradNum" != 'XEXX010101000' THEN 1  -- Comercio exterior pero LicTradNum incorrecto
	        WHEN T0."QryGroup1" = 'N' AND T0."LicTradNum" = 'XEXX010101000' THEN 2  -- No es comercio exterior pero LicTradNum es incorrecto
	        WHEN T0."QryGroup1" = 'Y' AND T2."Code" = 'MX' THEN 3  -- Código del país es Mexico y está marcado como comercio exterior
	        ELSE 0 
	    END) AS LicTradNumCheck,
        MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck,
        MAX(CASE WHEN T0."U_SYP_FPAGO" IS NULL OR T0."U_SYP_FPAGO" = '' THEN 1 ELSE 0 END) AS RegimenFiscalV4Check,
        
        -- Validación de métodos de pago
	     MAX(CASE 
	        WHEN T5."CardCode" IS NULL AND T5."PymCode" IS NULL THEN 1 
	        ELSE 0 
	    END) AS PayMethCodCheck,
	    
	    -- Validación de anexos (ATC1)
		MAX(CASE 
		    WHEN NOT EXISTS (SELECT 1 FROM ATC1 T4 WHERE T4."AbsEntry" = T0."AtcEntry") THEN 1 
		    ELSE 0
		END) AS AnexosCheck
        
	INTO 
        CARD_NAME_VALID, EMAIL_VALID, PHONE_VALID, MAIN_USAGE, 
        ADDRESS_VALID, STREET_VALID, COLONIA_VALID, CITY_VALID, ZIP_CODE_VALID, COUNTRY_VALID,
        PAYMENT_CONDITION_VALID, LIC_TRAD_NUM_VALID, ID_FISCAL_VALID, REGIMEN_FISCAL_V4_VALID, PAYMENT_METHOD_CHECK_VALID,
        ANEXOS_VALID
	FROM OCRD T0
	LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
	LEFT JOIN OCRY T2 ON T1."Country" = T2."Code"
	LEFT JOIN OPYM T3 ON T0."PymCode" = T3."PayMethCod"
	LEFT JOIN CRD2 T5 ON T0."CardCode" = T5."CardCode"
	WHERE T0."CardCode" = :list_of_cols_val_tab_del;
	
	-- Asignar errores según las validaciones realizadas

    -- VALICACION DEL TIPO DEL NEGOCIO
	IF BP_EXISTS = 0 THEN
		error := 1;
		error_message := N'Debe seleccionar al menos un cliente, proveedor o lead';
	END IF;
	-- FIN VALICACION DEL TIPO DEL NEGOCIO

    -- VALICACION DEL CARD_NAME
	IF CARD_NAME_VALID = 1 THEN
		error := 2;
		error_message := N'El nombre es requerido.';
	END IF;
	
	IF CARD_NAME_VALID = 2 THEN
		error := 3;
		error_message := N'El nombre debe contener solo letras, No caracteres especiales o "Ñ"';
	END IF;
	
	IF CARD_NAME_VALID = 3 THEN
	    error := 4;
	    error_message := N'El nombre no debe exceder los 60 caracteres.';
	END IF;
	-- FIN VALICACION DEL CARD_NAME
	
    -- VALICACION DEL EMAIL_VALID
	IF EMAIL_VALID = 1 THEN
	    error := 5;
	    error_message := N'El correo electrónico es requerido.';
	END IF;

	IF EMAIL_VALID = 2 THEN
	    error := 6;
	    error_message := N'El formato del correo electrónico no es válido.';
	END IF;
	-- FIN VALICACION DEL EMAIL_VALID

	-- VALICACION DEL PHONE_VALID
	IF PHONE_VALID = 1 THEN
	    error := 7;
	    error_message := N'El número de teléfono es requerido.';
	END IF;
	
	IF PHONE_VALID = 2 THEN
	    error := 8;
	    error_message := N'El número de teléfono debe contener solo números.';
	END IF;
	
	/*IF PHONE_VALID = 2 THEN
	    error := 8;
	    error_message := N'El número de teléfono debe tener al menos 10 dígitos.';
	END IF;
	
	IF PHONE_VALID = 3 THEN
	    error := 9;
	    error_message := N'El número de teléfono no debe exceder los 15 dígitos.';
	END IF;*/
	-- FIN VALICACION DEL PHONE_VALID

    -- VALICACION DEL MAIN_USAGE
	IF MAIN_USAGE = 1 THEN
	    error := 9;
	    error_message := N'El uso principal es requerido';
	END IF;
	-- FIN VALICACION DEL MAIN_USAGE

    -- VALICACION DEL ADDRESS_VALID
	IF ADDRESS_VALID = 1 THEN
	    error := 10;
	    error_message := N'La dirección es requerida';
	END IF;
	-- FIN VALICACION DEL ADDRESS_VALID

    -- VALICACION DEL STREET_VALID
	IF STREET_VALID = 1 THEN
	    error := 11;
	    error_message := N'La calle/número es requerida';
	END IF;
	-- FIN VALICACION DEL STREET_VALID

    -- VALICACION DEL COLONIA_VALID
	IF COLONIA_VALID = 1 THEN
	    error := 12;
	    error_message := N'La colonia es requerida';
	END IF;
	-- FIN VALICACION DEL COLONIA_VALID

    -- VALICACION DEL CITY_VALID
	IF CITY_VALID = 1 THEN
	    error := 13;
	    error_message := N'La ciudad es requerida';
	END IF;
	-- FIN VALICACION DEL CITY_VALID

    -- VALICACION DEL ZIP_CODE_VALID
	IF ZIP_CODE_VALID = 1 THEN
	    error := 14;
	    error_message := N'El código postal es requerido';
	END IF;
	-- FIN VALICACION DEL ZIP_CODE_VALID

    -- VALICACION DEL COUNTRY_VALID
	IF COUNTRY_VALID = 1 THEN
	    error := 15;
	    error_message := N'El país/región es requerido';
	END IF;
	
	IF COUNTRY_VALID = 2 THEN
	    error := 16;
	    error_message := N'El país/región que seleccionaste no está habilitado.';
	END IF;
	-- VALICACION DEL COUNTRY_VALID

    -- VALICACION DEL PAYMENT_CONDITION_VALID
	IF PAYMENT_CONDITION_VALID = 1 THEN
    	error := 17;
    	error_message := N'La condición de pago es requerida.';
	END IF;
    -- FIN VALICACION DEL PAYMENT_CONDITION_VALID

    -- VALICACION DEL LIC_TRAD_NUM_VALID
    -- Validación de comercio exterior y LictradNum
	IF LIC_TRAD_NUM_VALID = 1 THEN
	    error := 18;
	    error_message := N'El campo RFC debe ser "XEXX010101000" para comercio exterior.';
	END IF;
	
	IF LIC_TRAD_NUM_VALID = 2 THEN
	    error := 19;
	    error_message := N'El campo RFC no debe ser "XEXX010101000" si no es comercio exterior.';
	END IF;
	
	IF LIC_TRAD_NUM_VALID = 3 THEN
	    error := 20;
	    error_message := N'El país Mexico no deberia estar marcado como comercio exterior.';
	END IF;
	-- FIN VALICACION DEL LIC_TRAD_NUM_VALID
	
   -- VALICACION DEL ID_FISCAL_VALID
   IF ID_FISCAL_VALID = 1 THEN
       error := 21;
       error_message := N'El id fiscal federal unificado es requerido';
   END IF;
   -- FIN VALICACION DEL ID_FISCAL_VALID

  -- VALICACION DEL REGIMEN_FISCAL_V4_VALID
	IF REGIMEN_FISCAL_V4_VALID = 1 THEN
	    error := 22;
	    error_message := N'El régimen fiscal v4 es requerido';
	END IF;
	-- FIN VALICACION DEL REGIMEN_FISCAL_V4_VALID

	-- Validación de métodos de pago
	IF PAYMENT_METHOD_CHECK_VALID = 1 THEN
	    error := 23;
	    error_message := N'Por favor, seleccione al menos un método de pago.';
	END IF;
	
	-- Validación de anexos (ATC1)
	IF ANEXOS_VALID = 1 THEN
	    error := 24;
	    error_message := N'Por favor, seleccione al menos un anexo.';
	END IF;

END IF; -- Fin de la validación para OCRD

END;



/* por el momento en prueba de EPM  */

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
ID_FISCAL_VALID NVARCHAR(100);
REGIMEN_FISCAL_V4_VALID NVARCHAR(50);
ANEXOS_VALID INT;

BEGIN

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


-- Validación para agregar o actualizar en OCRD (Datos Maestro Socio Negocio)
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
  
	-- Validaciones de datos del socio de negocio
	SELECT
		-- Contar al menos un tipo de socio de negocio 
	    CASE 
	        WHEN COUNT(CASE WHEN T0."CardType" IN ('C', 'S', 'L') THEN 1 END) > 0 THEN 0 
	        ELSE 1 
	    END AS CardTypeCheck,
        MAX(CASE 
	            WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
	            WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z .]+$' THEN 2
	            WHEN LENGTH(T0."CardName") > 60 THEN 3
            ELSE 0 
        END) AS CardNameCheck, 
        MAX(CASE 
	            WHEN T0."E_Mail" IS NULL OR T0."E_Mail" = '' THEN 1
	            WHEN T0."E_Mail" NOT LIKE_REGEXPR '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN 2
            ELSE 0 
        END) AS EmailCheck,
        MAX(CASE 
		    WHEN T0."Phone1" IS NULL OR T0."Phone1" = '' THEN 1
		    --WHEN LENGTH(T0."Phone1") < 10 THEN 2  -- Teléfono con menos de 10 caracteres
		    --WHEN LENGTH(T0."Phone1") > 15 THEN 3  -- Teléfono con más de 15 caracteres
		    WHEN T0."Phone1" NOT LIKE_REGEXPR '^[0-9]+$' THEN 2  -- Teléfono contiene caracteres no numéricos
		    ELSE 0 
		END) AS PhoneCheck,
        MAX(CASE WHEN T0."U_B1SYS_MainUsage" IS NULL OR T0."U_B1SYS_MainUsage" = '' THEN 1 ELSE 0 END) AS MainUsageCheck,
        MAX(CASE WHEN T1."Address" IS NULL OR T1."Address" = '' THEN 1 ELSE 0 END) AS AddressCheck,
        MAX(CASE WHEN T1."Street" IS NULL OR T1."Street" = '' THEN 1 ELSE 0 END) AS StreetCheck,
        MAX(CASE WHEN T1."Block" IS NULL OR T1."Block" = '' THEN 1 ELSE 0 END) AS ColoniaCheck,
        MAX(CASE WHEN T1."City" IS NULL OR T1."City" = '' THEN 1 ELSE 0 END) AS CityCheck,
        MAX(CASE WHEN T1."ZipCode" IS NULL OR T1."ZipCode" = '' THEN 1 ELSE 0 END) AS ZipCodeCheck,
        MAX(CASE
            WHEN T1."Country" IS NULL OR T1."Country" = '' THEN 1
            WHEN LENGTH(T2."Code") = 3 THEN 2  -- Si el código tiene 3 caracteres (inhabilitado) 
		    ELSE 0 
		END) AS CountryCheck,  
        MAX(CASE 
            WHEN T0."GroupNum" IS NULL OR NOT EXISTS (SELECT 1 FROM OCTG T2 WHERE T2."GroupNum" = T0."GroupNum") THEN 1 
            ELSE 0 
        END) AS PaymentCondition,
        -- Validación de comercio exterior (QryGroup1) y LictradNum
	    MAX(CASE 
	        WHEN T0."QryGroup1" = 'Y' AND T0."LicTradNum" != 'XEXX010101000' THEN 1  -- Comercio exterior pero LicTradNum incorrecto
	        WHEN T0."QryGroup1" = 'N' AND T0."LicTradNum" = 'XEXX010101000' THEN 2  -- No es comercio exterior pero LicTradNum es incorrecto
	        WHEN T0."QryGroup1" = 'Y' AND T2."Code" = 'MX' THEN 3  -- Código del país es Mexico y está marcado como comercio exterior
	        ELSE 0 
	    END) AS LicTradNumCheck,
        MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck,
        MAX(CASE WHEN T0."U_SYP_FPAGO" IS NULL OR T0."U_SYP_FPAGO" = '' THEN 1 ELSE 0 END) AS RegimenFiscalV4Check,
        
        -- Validación de métodos de pago
	     MAX(CASE 
	        WHEN T5."CardCode" IS NULL AND T5."PymCode" IS NULL THEN 1 
	        ELSE 0 
	    END) AS PayMethCodCheck,
	    
	    -- Validación de anexos (ATC1)
		MAX(CASE 
		    WHEN NOT EXISTS (SELECT 1 FROM ATC1 T4 WHERE T4."AbsEntry" = T0."AtcEntry") THEN 1 
		    ELSE 0
		END) AS AnexosCheck
        
	INTO 
        BP_EXISTS, CARD_NAME_VALID, EMAIL_VALID, PHONE_VALID, MAIN_USAGE, 
        ADDRESS_VALID, STREET_VALID, COLONIA_VALID, CITY_VALID, ZIP_CODE_VALID, COUNTRY_VALID,
        PAYMENT_CONDITION_VALID, LIC_TRAD_NUM_VALID, ID_FISCAL_VALID, REGIMEN_FISCAL_V4_VALID, PAYMENT_METHOD_CHECK_VALID,
        ANEXOS_VALID
	FROM OCRD T0
	LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
	LEFT JOIN OCRY T2 ON T1."Country" = T2."Code"
	LEFT JOIN OPYM T3 ON T0."PymCode" = T3."PayMethCod"
	LEFT JOIN CRD2 T5 ON T0."CardCode" = T5."CardCode"
	WHERE T0."CardCode" = :list_of_cols_val_tab_del;
	
	-- Asignar errores según las validaciones realizadas

    -- VALICACION DEL TIPO DEL NEGOCIO
	IF BP_EXISTS = 0 THEN
		error := 1;
		error_message := N'Debe seleccionar al menos un cliente, proveedor o lead';
	END IF;
	-- FIN VALICACION DEL TIPO DEL NEGOCIO

    -- VALICACION DEL CARD_NAME
	IF CARD_NAME_VALID = 1 THEN
		error := 2;
		error_message := N'El nombre es requerido.';
	END IF;
	
	IF CARD_NAME_VALID = 2 THEN
		error := 3;
		error_message := N'El nombre debe contener solo letras, No caracteres especiales o "Ñ"';
	END IF;
	
	IF CARD_NAME_VALID = 3 THEN
	    error := 4;
	    error_message := N'El nombre no debe exceder los 60 caracteres.';
	END IF;
	-- FIN VALICACION DEL CARD_NAME
	
    -- VALICACION DEL EMAIL_VALID
	IF EMAIL_VALID = 1 THEN
	    error := 5;
	    error_message := N'El correo electrónico es requerido.';
	END IF;

	IF EMAIL_VALID = 2 THEN
	    error := 6;
	    error_message := N'El formato del correo electrónico no es válido.';
	END IF;
	-- FIN VALICACION DEL EMAIL_VALID

	-- VALICACION DEL PHONE_VALID
	IF PHONE_VALID = 1 THEN
	    error := 7;
	    error_message := N'El número de teléfono es requerido.';
	END IF;
	
	IF PHONE_VALID = 2 THEN
	    error := 8;
	    error_message := N'El número de teléfono debe contener solo números.';
	END IF;
	
	
	-- FIN VALICACION DEL PHONE_VALID

    -- VALICACION DEL MAIN_USAGE
	IF MAIN_USAGE = 1 THEN
	    error := 9;
	    error_message := N'El uso principal es requerido';
	END IF;
	-- FIN VALICACION DEL MAIN_USAGE

    -- VALICACION DEL ADDRESS_VALID
	IF ADDRESS_VALID = 1 THEN
	    error := 10;
	    error_message := N'La dirección es requerida';
	END IF;
	-- FIN VALICACION DEL ADDRESS_VALID

    -- VALICACION DEL STREET_VALID
	IF STREET_VALID = 1 THEN
	    error := 11;
	    error_message := N'La calle/número es requerida';
	END IF;
	-- FIN VALICACION DEL STREET_VALID

    -- VALICACION DEL COLONIA_VALID
	IF COLONIA_VALID = 1 THEN
	    error := 12;
	    error_message := N'La colonia es requerida';
	END IF;
	-- FIN VALICACION DEL COLONIA_VALID

    -- VALICACION DEL CITY_VALID
	IF CITY_VALID = 1 THEN
	    error := 13;
	    error_message := N'La ciudad es requerida';
	END IF;
	-- FIN VALICACION DEL CITY_VALID

    -- VALICACION DEL ZIP_CODE_VALID
	IF ZIP_CODE_VALID = 1 THEN
	    error := 14;
	    error_message := N'El código postal es requerido';
	END IF;
	-- FIN VALICACION DEL ZIP_CODE_VALID

    -- VALICACION DEL COUNTRY_VALID
	IF COUNTRY_VALID = 1 THEN
	    error := 15;
	    error_message := N'El país/región es requerido';
	END IF;
	
	IF COUNTRY_VALID = 2 THEN
	    error := 16;
	    error_message := N'El país/región que seleccionaste no está habilitado.';
	END IF;
	-- VALICACION DEL COUNTRY_VALID

    -- VALICACION DEL PAYMENT_CONDITION_VALID
	IF PAYMENT_CONDITION_VALID = 1 THEN
    	error := 17;
    	error_message := N'La condición de pago es requerida.';
	END IF;
    -- FIN VALICACION DEL PAYMENT_CONDITION_VALID

    -- VALICACION DEL LIC_TRAD_NUM_VALID
    -- Validación de comercio exterior y LictradNum
	IF LIC_TRAD_NUM_VALID = 1 THEN
	    error := 18;
	    error_message := N'El campo RFC debe ser "XEXX010101000" para comercio exterior.';
	END IF;
	
	IF LIC_TRAD_NUM_VALID = 2 THEN
	    error := 19;
	    error_message := N'El campo RFC no debe ser "XEXX010101000" si no es comercio exterior.';
	END IF;
	
	IF LIC_TRAD_NUM_VALID = 3 THEN
	    error := 20;
	    error_message := N'El país Mexico no deberia estar marcado como comercio exterior.';
	END IF;
	-- FIN VALICACION DEL LIC_TRAD_NUM_VALID
	
   -- VALICACION DEL ID_FISCAL_VALID
   IF ID_FISCAL_VALID = 1 THEN
       error := 21;
       error_message := N'El id fiscal federal unificado es requerido';
   END IF;
   -- FIN VALICACION DEL ID_FISCAL_VALID

  -- VALICACION DEL REGIMEN_FISCAL_V4_VALID
	IF REGIMEN_FISCAL_V4_VALID = 1 THEN
	    error := 22;
	    error_message := N'El régimen fiscal v4 es requerido';
	END IF;
	-- FIN VALICACION DEL REGIMEN_FISCAL_V4_VALID

	-- Validación de métodos de pago
	IF PAYMENT_METHOD_CHECK_VALID = 1 THEN
	    error := 23;
	    error_message := N'Por favor, seleccione al menos un método de pago.';
	END IF;
	
	-- Validación de anexos (ATC1)
	IF ANEXOS_VALID = 1 THEN
	    error := 24;
	    error_message := N'Por favor, seleccione al menos un anexo.';
	END IF;

END IF; -- Fin de la validación para OCRD

END;


-- Validaciones para el objeto tipo '17' (Orden de Venta)
IF :object_type = '17' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN 

	-- Validar que el socio de negocio tenga todos los campos requeridos llenos antes de permitir la creación de la orden de venta.
    SELECT
        CASE 
            WHEN COUNT(CASE WHEN T0."CardType" IN ('C', 'S', 'L') THEN 1 END) > 0 THEN 0 
            ELSE 1 
        END AS CardTypeCheck,
        MAX(CASE 
                WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
                WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z .]+$' THEN 2
                WHEN LENGTH(T0."CardName") > 60 THEN 3
            ELSE 0 
        END) AS CardNameCheck, 
        MAX(CASE 
                WHEN T0."E_Mail" IS NULL OR T0."E_Mail" = '' THEN 1
                WHEN T0."E_Mail" NOT LIKE_REGEXPR '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN 2
            ELSE 0 
        END) AS EmailCheck,
        MAX(CASE 
            WHEN T0."Phone1" IS NULL OR T0."Phone1" = '' THEN 1
            WHEN T0."Phone1" NOT LIKE_REGEXPR '^[0-9]+$' THEN 2  
            ELSE 0 
        END) AS PhoneCheck,
        MAX(CASE WHEN T0."U_B1SYS_MainUsage" IS NULL OR T0."U_B1SYS_MainUsage" = '' THEN 1 ELSE 0 END) AS MainUsageCheck,
        MAX(CASE WHEN T1."Address" IS NULL OR T1."Address" = '' THEN 1 ELSE 0 END) AS AddressCheck,
        MAX(CASE WHEN T1."Street" IS NULL OR T1."Street" = '' THEN 1 ELSE 0 END) AS StreetCheck,
        MAX(CASE WHEN T1."Block" IS NULL OR T1."Block" = '' THEN 1 ELSE 0 END) AS ColoniaCheck,
        MAX(CASE WHEN T1."City" IS NULL OR T1."City" = '' THEN 1 ELSE 0 END) AS CityCheck,
        MAX(CASE WHEN T1."ZipCode" IS NULL OR T1."ZipCode" = '' THEN 1 ELSE 0 END) AS ZipCodeCheck,
        MAX(CASE
            WHEN T1."Country" IS NULL OR T1."Country" = '' THEN 1
            WHEN LENGTH(T2."Code") = 3 THEN 2  
            ELSE 0 
        END) AS CountryCheck,  
        MAX(CASE 
            WHEN T0."GroupNum" IS NULL OR NOT EXISTS (SELECT 1 FROM OCTG T2 WHERE T2."GroupNum" = T0."GroupNum") THEN 1 
            ELSE 0 
        END) AS PaymentCondition,
        MAX(CASE 
            WHEN T0."QryGroup1" = 'Y' AND T0."LicTradNum" != 'XEXX010101000' THEN 1  
            WHEN T0."QryGroup1" = 'N' AND T0."LicTradNum" = 'XEXX010101000' THEN 2  
            WHEN T0."QryGroup1" = 'Y' AND T2."Code" = 'MX' THEN 3  
            ELSE 0 
        END) AS LicTradNumCheck,
        MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck,
        MAX(CASE WHEN T0."U_SYP_FPAGO" IS NULL OR T0."U_SYP_FPAGO" = '' THEN 1 ELSE 0 END) AS RegimenFiscalV4Check,
        -- Validación de métodos de pago
	     MAX(CASE 
	        WHEN T5."CardCode" IS NULL AND T5."PymCode" IS NULL THEN 1 
	        ELSE 0 
	    END) AS PayMethCodCheck,
	    
	    -- Validación de anexos (ATC1)
		MAX(CASE 
		    WHEN NOT EXISTS (SELECT 1 FROM ATC1 T4 WHERE T4."AbsEntry" = T0."AtcEntry") THEN 1 
		    ELSE 0
		END) AS AnexosCheck
        
    INTO 
        BP_EXISTS, CARD_NAME_VALID, EMAIL_VALID, PHONE_VALID, MAIN_USAGE, 
        ADDRESS_VALID, STREET_VALID, COLONIA_VALID, CITY_VALID, ZIP_CODE_VALID, COUNTRY_VALID,
        PAYMENT_CONDITION_VALID, LIC_TRAD_NUM_VALID, ID_FISCAL_VALID, REGIMEN_FISCAL_V4_VALID,
        PAYMENT_METHOD_CHECK_VALID, ANEXOS_VALID
    FROM OCRD T0
    LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
    LEFT JOIN OCRY T2 ON T1."Country" = T2."Code"
    LEFT JOIN OPYM T3 ON T0."PymCode" = T3."PayMethCod"
	LEFT JOIN CRD2 T5 ON T0."CardCode" = T5."CardCode"
    WHERE T0."CardCode" IN (
      SELECT "CardCode"
      FROM ORDR WHERE "DocEntry" IN (:list_of_cols_val_tab_del)
    );

	-- Asignar un error general si alguna validación falla
    IF BP_EXISTS > 0 OR CARD_NAME_VALID > 0 
    	OR EMAIL_VALID > 0 OR PHONE_VALID > 0 
    	OR MAIN_USAGE > 0 OR ADDRESS_VALID > 0 
    	OR STREET_VALID > 0 OR COLONIA_VALID > 0 
    	OR CITY_VALID > 0 OR ZIP_CODE_VALID > 0 OR COUNTRY_VALID > 0 
    	OR PAYMENT_CONDITION_VALID > 0 OR LIC_TRAD_NUM_VALID > 0 
    	OR ID_FISCAL_VALID > 0 OR REGIMEN_FISCAL_V4_VALID > 0 
    	OR PAYMENT_METHOD_CHECK_VALID > 0 OR ANEXOS_VALID > 0 THEN
        error = -100;
        error_message = 'Faltan campos por validar en el maestro socio negocio antes de crear la orden de venta.';
        RETURN;
    END IF;
    
   
END IF;