/* 
1. Definitivo
    * Proceso recomendado: Bloqueo total del proveedor.  (Analizado)
      - Razón: Este estado implica que el proveedor ha sido permanentemente incluido en la lista negra del SAT, 
        por lo tanto, no se debe realizar ninguna transacción ni interacción con este proveedor. 
        Al estar en este estado, representa un riesgo legal para la empresa al hacer negocios con ellos.

      - Acción en SAP: Al registrar o crear un proveedor con este estado, (En Proceso)
        se debe activar automáticamente un bloqueo en todas las transacciones con este proveedor, 
        incluyendo compras, pagos, y facturación. 
        Esto puede hacerse configurando una regla de bloqueo en SAP que impida cualquier acción con proveedores 
        en este estado.
      
 */

 /* EPM_Pruebas - B1H_EPM_PROD_20241231*/

 /* ORIGINAL 29-01-2025 */

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

--Variables Datos de maestro de articulos
SAL_UNIT_MSR_VALID INT;
INVNTRY_UOM_VALID INT;
UOM_CODE_VALID NVARCHAR(50);
IS_SELL_ITEM NVARCHAR(1);
ITEM_CODE NVARCHAR(50);  
UGPENTRY INT;

INVALID_ARTICLE_COUNT INT;
 

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

-- Validación para agregar o actualizar en OCRD (Datos Maestro Socio Negocio)
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

	-- Validaciones de datos del socio de negocio
	SELECT
		CASE 
	        WHEN COUNT(CASE WHEN T0."CardType" IN ('C', 'S', 'L') THEN 1 END) > 0 THEN 0 
	        ELSE 1 
	    END AS CardTypeCheck, 
        MAX(CASE 
	            WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
	            WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z0-9 .@]+$' THEN 2
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
		    WHEN T0."Phone1" NOT LIKE_REGEXPR '^\+?[0-9]+$' THEN 2  -- Teléfono contiene caracteres no numéricos
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
        --MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck,
 		MAX(CASE 
            WHEN T0."QryGroup1" = 'Y' AND (T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '') THEN 1 -- Comercio exterior sin ID fiscal
            ELSE 0 
        END) AS IdFiscalCheck,
        
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
	IF BP_EXISTS = 1 THEN
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
	    error_message := N'El número de teléfono debe contener el signo + y números.';
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
       --error_message := N'El id fiscal federal unificado es requerido';
       error_message := N'El ID fiscal es requerido para comercio exterior.';
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


--Maestro de Artículo
IF :object_type = '4' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
    SELECT 
        T0."NCMCode", 
        T0."SalUnitMsr", 
        T0."ItemType",
        T0."SellItem",  -- Indica si es un artículo de venta
        T0."ItemCode",  -- Código del artículo
        T0."UgpEntry",  -- Grupo de unidad de medida
        CASE 
            WHEN T0."SellItem" = 'Y' AND T0."SalUnitMsr" IS NULL OR T0."SalUnitMsr" = '' THEN 1 
            WHEN T0."SellItem" = 'Y' AND T0."SalUnitMsr" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT') THEN 2 
            ELSE 0 
        END AS SalUnitMsrCheck,
        CASE 
            WHEN T0."SellItem" = 'Y' AND T0."InvntryUom" IS NULL OR T0."InvntryUom" = '' THEN 1 
            WHEN T0."SellItem" = 'Y' AND T0."InvntryUom" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT') THEN 2 
            ELSE 0 
        END AS InvntryUomCheck
    INTO 
        CODCLAS, UNMED, TYPE_ITEM, 
		IS_SELL_ITEM, ITEM_CODE, UGPENTRY, 
		SAL_UNIT_MSR_VALID, INVNTRY_UOM_VALID
    FROM "OITM" T0 
    WHERE T0."ItemCode" = :list_of_cols_val_tab_del;

    IF TYPE_ITEM = 'I' THEN
        IF (:CODCLAS IS NULL OR :CODCLAS = '-1') THEN
            error := 1;
            error_message := N'DPE: Debe Ingresar el campo Código de Clasificación';
        END IF;

        IF (:UNMED IS NULL) THEN
            error := 2;
            error_message := N'DPE: Debe Ingresar el campo Unidad de Medida de Ventas'; 
        END IF;

        -- Validación del código del artículo
        /*IF ( LEFT(:ITEM_CODE, 2) IN ('01', '03', '04', '07') ) AND (:IS_SELL_ITEM = 'Y') AND (:UGPENTRY = '-1') THEN
            error := 3; 
            error_message := N'Error: Si el artículo comienza con 01, 03, 04 o 07 y está marcado como artículo de venta, no debería ser Manual.';  
        END IF;*/
        
        -- Validación del código del artículo
        IF (:IS_SELL_ITEM = 'Y') THEN
           IF ( LEFT(:ITEM_CODE, 2) IN ('01', '03', '04', '07') AND (:UGPENTRY = '-1')  ) THEN
            error := 3; 
            error_message := N'Error: Si el artículo comienza con 01, 03, 04 o 07 y está marcado como artículo de venta, no debería ser Manual.';
           END IF;
              
        END IF;

        -- Manejo de errores para las validaciones del maestro de artículos
        IF SAL_UNIT_MSR_VALID = 1 THEN
            error := 4;  
            error_message := N'El nombre de la unidad de medida de venta es requerido';
        END IF;

        IF SAL_UNIT_MSR_VALID = 2 THEN
            error := 5;  
            error_message := N'El nombre de la unidad de medida de venta debe ser XUN, KGM, PLIEGO, XBX, H87 o ACT.';
        END IF;

        IF INVNTRY_UOM_VALID = 1 THEN
            error := 6;  
            error_message := N'En datos de inventario: El nombre de la unidad es requerido';
        END IF;

        IF INVNTRY_UOM_VALID = 2 THEN
            error := 7;  
            error_message := N'En datos de inventario: El nombre de la unidad debe ser XUN, KGM, PLIEGO, XBX, H87 o ACT.';
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
                WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z0-9 .@]+$' THEN 2
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
            WHEN T0."Phone1" NOT LIKE_REGEXPR '^\+?[0-9]+$' THEN 2  
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
        --MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck,
		MAX(CASE 
            WHEN T0."QryGroup1" = 'Y' AND (T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '') THEN 1 -- Comercio exterior sin ID fiscal
            ELSE 0 
        END) AS IdFiscalCheck,
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


--Orden de compra - Pedido OPOR 
-- Validaciones para el objeto tipo '22' (Orden de Compra)
IF :object_type = '22' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN 

	-- Validar que el socio de negocio tenga todos los campos requeridos llenos antes de permitir la creación de la orden de compra.
    SELECT
        CASE 
            WHEN COUNT(CASE WHEN T0."CardType" IN ('C', 'S', 'L') THEN 1 END) > 0 THEN 0 
            ELSE 1 
        END AS CardTypeCheck,
        MAX(CASE 
                WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
                WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z0-9 .@]+$' THEN 2
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
            WHEN T0."Phone1" NOT LIKE_REGEXPR '^\+?[0-9]+$' THEN 2  
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
		MAX(CASE 
            WHEN T0."QryGroup1" = 'Y' AND (T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '') THEN 1 -- Comercio exterior sin ID fiscal
            ELSE 0 
        END) AS IdFiscalCheck,
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
      FROM OPOR WHERE "DocEntry" IN (:list_of_cols_val_tab_del)
    );

	-- Asignar un error general si alguna validación falla
    IF BP_EXISTS > 0 OR CARD_NAME_VALID > 0 
    	OR EMAIL_VALID > 0 OR PHONE_VALID > 0 
    	OR MAIN_USAGE > 0 OR ADDRESS_VALID > 0 
    	OR STREET_VALID > 0 OR COLONIA_VALID > 0 
    	OR CITY_VALID > 0 OR ZIP_CODE_VALID > 0 OR COUNTRY_VALID > 0 
    	OR PAYMENT_CONDITION_VALID > 0 OR LIC_TRAD_NUM_VALID > 0 
    	OR ID_FISCAL_VALID > 0 OR REGIMEN_FISCAL_V4_VALID > 0 
    	OR PAYMENT_METHOD_CHECK_VALID > 0 OR ANEXOS_VALID > 0 
    	THEN
        error = 40;
        --error_message = 'Faltan campos por validar en el maestro socio negocio o en los artículos antes de crear la orden de compra.';
        error_message = 'Faltan campos por validar en el maestro socio negocio antes de crear la orden de compra.';
        RETURN;
    END IF;
    
    SELECT COUNT(*)
    INTO INVALID_ARTICLE_COUNT
    FROM OPOR A0
    INNER JOIN POR1 A1 ON A0."DocEntry" = A1."DocEntry"
    INNER JOIN OITM A2 ON A1."ItemCode" = A2."ItemCode"
    WHERE A0."DocEntry" IN (:list_of_cols_val_tab_del)
    AND(
	    (A2."SellItem" = 'Y' AND (A2."SalUnitMsr" IS NULL OR A2."SalUnitMsr" = '' OR A2."SalUnitMsr" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT'))) OR
	    (A2."SellItem" = 'Y' AND (A2."InvntryUom" IS NULL OR A2."InvntryUom" = '' OR A2."InvntryUom" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT'))) OR
	    (A2."SellItem" = 'Y' AND LEFT(A2."ItemCode", 2) IN ('01', '03', '04', '07') AND (A2."UgpEntry" = '-1'))
    );

    IF INVALID_ARTICLE_COUNT > 0 THEN
        error := 8;  
        error_message := N'Existen artículos inválidos en la orden de compra. Verifique las unidades de medida o el código del artículo.';
        RETURN;
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





END;

/* 
REPORTE LISTA NEGRA
SELECT RFC,Contribuyente,situacion,numeroyfecha,datosactualizacion,fecha from fe_listanegra


/* SENTENCIA FAVORABLE */
SELECT RFC,Contribuyente,situacion,numeroyfecha,datosactualizacion,fecha 
from fe_listanegra 
WHERE "SITUACION" = 'Sentencia Favorable'
 */

/* EMPEZAMOS EL PRIMER REQUERIMIENTO */
DROP PROCEDURE SBO_SP_TransactionNotification_CLIENT;

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
provider_code NVARCHAR(20);
is_blacklisted INT;  -- Verificar si el proveedor está en la lista negra
blacklist_status NVARCHAR(20);

BEGIN

--     -- Validaciones para el objeto tipo '22' (Orden de Compra)
-- IF :object_type = '22' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN 

-- 	-- Validar que el socio de negocio tenga todos los campos requeridos llenos antes de permitir la creación de la orden de compra.
--     SELECT
--         CASE 
--             WHEN COUNT(CASE WHEN T0."CardType" IN ('C', 'S', 'L') THEN 1 END) > 0 THEN 0 
--             ELSE 1 
--         END AS CardTypeCheck,
--         MAX(CASE 
--                 WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
--                 WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z0-9 .@]+$' THEN 2
--                 WHEN LENGTH(T0."CardName") > 60 THEN 3
--             ELSE 0 
--         END) AS CardNameCheck, 
--         MAX(CASE 
--                 WHEN T0."E_Mail" IS NULL OR T0."E_Mail" = '' THEN 1
--                 WHEN T0."E_Mail" NOT LIKE_REGEXPR '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN 2
--             ELSE 0 
--         END) AS EmailCheck,
--         MAX(CASE 
--             WHEN T0."Phone1" IS NULL OR T0."Phone1" = '' THEN 1
--             WHEN T0."Phone1" NOT LIKE_REGEXPR '^\+?[0-9]+$' THEN 2  
--             ELSE 0 
--         END) AS PhoneCheck,
--         MAX(CASE WHEN T0."U_B1SYS_MainUsage" IS NULL OR T0."U_B1SYS_MainUsage" = '' THEN 1 ELSE 0 END) AS MainUsageCheck,
--         MAX(CASE WHEN T1."Address" IS NULL OR T1."Address" = '' THEN 1 ELSE 0 END) AS AddressCheck,
--         MAX(CASE WHEN T1."Street" IS NULL OR T1."Street" = '' THEN 1 ELSE 0 END) AS StreetCheck,
--         MAX(CASE WHEN T1."Block" IS NULL OR T1."Block" = '' THEN 1 ELSE 0 END) AS ColoniaCheck,
--         MAX(CASE WHEN T1."City" IS NULL OR T1."City" = '' THEN 1 ELSE 0 END) AS CityCheck,
--         MAX(CASE WHEN T1."ZipCode" IS NULL OR T1."ZipCode" = '' THEN 1 ELSE 0 END) AS ZipCodeCheck,
--         MAX(CASE
--             WHEN T1."Country" IS NULL OR T1."Country" = '' THEN 1
--             WHEN LENGTH(T2."Code") = 3 THEN 2  
--             ELSE 0 
--         END) AS CountryCheck,  
--         MAX(CASE 
--             WHEN T0."GroupNum" IS NULL OR NOT EXISTS (SELECT 1 FROM OCTG T2 WHERE T2."GroupNum" = T0."GroupNum") THEN 1 
--             ELSE 0 
--         END) AS PaymentCondition,
--         MAX(CASE 
--             WHEN T0."QryGroup1" = 'Y' AND T0."LicTradNum" != 'XEXX010101000' THEN 1  
--             WHEN T0."QryGroup1" = 'N' AND T0."LicTradNum" = 'XEXX010101000' THEN 2  
--             WHEN T0."QryGroup1" = 'Y' AND T2."Code" = 'MX' THEN 3  
--             ELSE 0 
--         END) AS LicTradNumCheck,
-- 		MAX(CASE 
--             WHEN T0."QryGroup1" = 'Y' AND (T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '') THEN 1 -- Comercio exterior sin ID fiscal
--             ELSE 0 
--         END) AS IdFiscalCheck,
--         MAX(CASE WHEN T0."U_SYP_FPAGO" IS NULL OR T0."U_SYP_FPAGO" = '' THEN 1 ELSE 0 END) AS RegimenFiscalV4Check,
        
--         -- Validación de métodos de pago
-- 	     MAX(CASE 
-- 	        WHEN T5."CardCode" IS NULL AND T5."PymCode" IS NULL THEN 1 
-- 	        ELSE 0 
-- 	    END) AS PayMethCodCheck,
	    
-- 	   -- Validación de anexos (ATC1)
-- 		MAX(CASE 
-- 		    WHEN NOT EXISTS (SELECT 1 FROM ATC1 T4 WHERE T4."AbsEntry" = T0."AtcEntry") THEN 1 
-- 		    ELSE 0
-- 		END) AS AnexosCheck
        
--     INTO 
--         BP_EXISTS, CARD_NAME_VALID, EMAIL_VALID, PHONE_VALID, MAIN_USAGE, 
--         ADDRESS_VALID, STREET_VALID, COLONIA_VALID, CITY_VALID, ZIP_CODE_VALID, COUNTRY_VALID,
--         PAYMENT_CONDITION_VALID, LIC_TRAD_NUM_VALID, ID_FISCAL_VALID, REGIMEN_FISCAL_V4_VALID,
--         PAYMENT_METHOD_CHECK_VALID, ANEXOS_VALID
 
--     FROM OCRD T0
--     LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
--     LEFT JOIN OCRY T2 ON T1."Country" = T2."Code"
--     LEFT JOIN OPYM T3 ON T0."PymCode" = T3."PayMethCod"
-- 	LEFT JOIN CRD2 T5 ON T0."CardCode" = T5."CardCode"
	
--     WHERE T0."CardCode" IN (
--       SELECT "CardCode"
--       FROM OPOR WHERE "DocEntry" IN (:list_of_cols_val_tab_del)
--     );

-- 	-- Asignar un error general si alguna validación falla
--     IF BP_EXISTS > 0 OR CARD_NAME_VALID > 0 
--     	OR EMAIL_VALID > 0 OR PHONE_VALID > 0 
--     	OR MAIN_USAGE > 0 OR ADDRESS_VALID > 0 
--     	OR STREET_VALID > 0 OR COLONIA_VALID > 0 
--     	OR CITY_VALID > 0 OR ZIP_CODE_VALID > 0 OR COUNTRY_VALID > 0 
--     	OR PAYMENT_CONDITION_VALID > 0 OR LIC_TRAD_NUM_VALID > 0 
--     	OR ID_FISCAL_VALID > 0 OR REGIMEN_FISCAL_V4_VALID > 0 
--     	OR PAYMENT_METHOD_CHECK_VALID > 0 OR ANEXOS_VALID > 0 
--     	THEN
--         error = 40;
--         --error_message = 'Faltan campos por validar en el maestro socio negocio o en los artículos antes de crear la orden de compra.';
--         error_message = 'Faltan campos por validar en el maestro socio negocio antes de crear la orden de compra.';
--         RETURN;
--     END IF;
    
--     SELECT COUNT(*)
--     INTO INVALID_ARTICLE_COUNT
--     FROM OPOR A0
--     INNER JOIN POR1 A1 ON A0."DocEntry" = A1."DocEntry"
--     INNER JOIN OITM A2 ON A1."ItemCode" = A2."ItemCode"
--     WHERE A0."DocEntry" IN (:list_of_cols_val_tab_del)
--     AND(
-- 	    (A2."SellItem" = 'Y' AND (A2."SalUnitMsr" IS NULL OR A2."SalUnitMsr" = '' OR A2."SalUnitMsr" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT'))) OR
-- 	    (A2."SellItem" = 'Y' AND (A2."InvntryUom" IS NULL OR A2."InvntryUom" = '' OR A2."InvntryUom" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT'))) OR
-- 	    (A2."SellItem" = 'Y' AND LEFT(A2."ItemCode", 2) IN ('01', '03', '04', '07') AND (A2."UgpEntry" = '-1'))
--     );

--     IF INVALID_ARTICLE_COUNT > 0 THEN
--         error := 8;  
--         error_message := N'Existen artículos inválidos en la orden de compra. Verifique las unidades de medida o el código del artículo.';
--         RETURN;
--     END IF; 
-- END IF;

    /* SN OCRD  */
    IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

        -- Verificar si el proveedor está en la lista negra
        SELECT COUNT(*) INTO is_blacklisted
        FROM fe_listanegra 
        WHERE RFC = (SELECT "LicTradNum" FROM OCRD WHERE "CardCode" = provider_code);

        IF is_blacklisted > 0 THEN
            error := 1; 
            error_message := 'El socio de negocio está en la lista negra y no se puede realizar esta transacción.';
            RETURN;
        END IF;



    /* Compras OPOR  */
    IF :object_type = '22' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
     
        -- Obtener el código del proveedor desde la lista de claves
        SELECT SUBSTRING_INDEX(:list_of_key_cols_tab_del, '|', 1) INTO provider_code;

        SELECT COUNT(*) INTO is_blacklisted
        FROM fe_listanegra 
        WHERE RFC = (SELECT "LicTradNum" FROM OCRD WHERE "CardCode" = provider_code);

        IF is_blacklisted > 0 THEN
            error := 1; 
            error_message := 'El proveedor está en la lista negra y no se puede realizar esta transacción.';
            RETURN;
        END IF;
    END IF;

END;

-- ****************************************************************************************************************

DROP PROCEDURE IF EXISTS SBO_SP_TransactionNotification_CLIENT;

CREATE PROCEDURE SBO_SP_TransactionNotification_CLIENT
(
    in object_type nvarchar(30),                -- Tipo de objeto SBO
    in transaction_type nchar(1),               -- [A]gregar, [U]pdate, [D]elete, [C]ancelar
    in num_of_cols_in_key int,
    in list_of_key_cols_tab_del nvarchar(255),
    in list_of_cols_val_tab_del nvarchar(255), 
    -- Valores de retorno
    out error int,                               -- Resultado (0 para sin error)
    out error_message nvarchar(200)             -- Mensaje de error a mostrar
)
LANGUAGE SQLSCRIPT
AS
BEGIN
    DECLARE provider_code NVARCHAR(20);
    DECLARE is_blacklisted INT;
    DECLARE blacklist_status NVARCHAR(20);

    /* Obtener el código del proveedor desde la lista de claves */
    SELECT SUBSTRING_INDEX(:list_of_key_cols_tab_del, '|', 1) INTO provider_code;

    /* Validaciones para el objeto tipo '2' (Socio de Negocio) */
    IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

        -- Verificar si el proveedor está en la lista negra
        SELECT COUNT(*) INTO is_blacklisted,
               MAX(T1."SITUACION") INTO blacklist_status
        FROM fe_listanegra T1 
        WHERE T1.RFC = (SELECT "LicTradNum" FROM OCRD WHERE "CardCode" = provider_code);

        IF is_blacklisted > 0 AND blacklist_status = 'Definitivo' THEN
            error := 1; 
            error_message := 'El socio de negocio está en la lista negra con estado "Definitivo" y no se puede realizar esta transacción.';
            RETURN;
        END IF;

    END IF;

    /* Validaciones para compras OPOR */
    IF :object_type = '22' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

        -- Verificar nuevamente si el proveedor está en la lista negra
        SELECT COUNT(*) INTO is_blacklisted,
               MAX(T1."SITUACION") INTO blacklist_status
        FROM fe_listanegra T1 
        WHERE T1.RFC = (SELECT "LicTradNum" FROM OCRD WHERE "CardCode" = provider_code);

        IF is_blacklisted > 0 AND blacklist_status = 'Definitivo' THEN
            error := 1; 
            error_message := 'El proveedor está en la lista negra con estado "Definitivo" y no se puede realizar esta transacción.';
            RETURN;
        END IF;
    END IF;

END;

-- ******************************************************************************************************************

DROP PROCEDURE IF EXISTS SBO_SP_TransactionNotification_CLIENT;

CREATE PROCEDURE SBO_SP_TransactionNotification_CLIENT
(
    in object_type nvarchar(30),                -- Tipo de objeto SBO
    in transaction_type nchar(1),               -- [A]gregar, [U]pdate, [D]elete, [C]ancelar
    in num_of_cols_in_key int,
    in list_of_key_cols_tab_del nvarchar(255),
    in list_of_cols_val_tab_del nvarchar(255), 
    -- Valores de retorno
    out error int,                               -- Resultado (0 para sin error)
    out error_message nvarchar(200)             -- Mensaje de error a mostrar
)
LANGUAGE SQLSCRIPT
AS
is_blacklisted INT;
rfc nvarchar(30);   
BEGIN

 /* Verificar si se está creando o actualizando un socio de negocio */
    IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

        /* Verificar si el proveedor está en la lista negra */
        SELECT COUNT(*) INTO is_blacklisted
        FROM fe_listanegra T1 
        WHERE T1."RFC" = (SELECT "LicTradNum" FROM OCRD WHERE "LicTradNum" = :list_of_cols_val_tab_del);

        /* Bloquear transacciones si el proveedor está en la lista negra */
        IF is_blacklisted > 0 THEN
            error := 1; 
            error_message := 'El proveedor está en la lista negra y no se puede crear o actualizar.';
            RETURN;
        END IF;
    END IF;

    /* Solo proceder si se está creando o actualizando un proveedor Con Busqueda Formateada */
    IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

        /* Obtener el LicTradNum del proveedor ingresado usando la variable formateada */
        SELECT $[$41.1.0] INTO rfc FROM DUMMY; --campo LicTradNum

        /* Verificar si el proveedor está en la lista negra */
        SELECT COUNT(*) INTO is_blacklisted
        FROM fe_listanegra 
        WHERE "RFC" = rfc;

        /* Bloquear transacciones si el proveedor está en la lista negra */
        IF is_blacklisted > 0 THEN
            error := 1; 
            error_message := 'El proveedor está en la lista negra y no se puede crear o actualizar.';
            RETURN;
        END IF;
    END IF;
END;

        
    --     /* Verificar si el proveedor está en la lista negra */
    --     SELECT COUNT(*) INTO is_blacklisted
    --     FROM fe_listanegra T1 
    --     WHERE T1."RFC" = (SELECT "LicTradNum" FROM OCRD WHERE "LicTradNum" = :list_of_cols_val_tab_del);

    --     /* Bloquear transacciones si el proveedor está en la lista negra */
    --     IF is_blacklisted > 0 THEN
    --         error := 1; 
    --         error_message := 'El proveedor está en la lista negra y no se puede crear o actualizar.';
    --         RETURN;
    --     END IF;
    -- END IF;


    --  /* Verificar si se está creando o actualizando un socio de negocio */
    -- IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
    --     -- Obtener el código del proveedor desde la lista de claves
    --     SELECT SUBSTRING_INDEX(:list_of_key_cols_tab_del, '|', 1) INTO provider_code;

    --     /* Verificar si el proveedor está en la lista negra */
    --     SELECT COUNT(*) INTO is_blacklisted
    --     FROM fe_listanegra T1 
    --     WHERE T1."RFC" = (SELECT "LicTradNum" FROM OCRD WHERE "CardCode" = provider_code);

    --     /* Bloquear transacciones si el proveedor está en la lista negra */
    --     IF is_blacklisted > 0 THEN
    --         error := 1; 
    --         error_message := 'El proveedor está en la lista negra y no se puede crear o actualizar.';
    --         RETURN;
    --     END IF;
    -- END IF;

    /* Obtener el código del proveedor desde la lista de claves */
    -- SELECT SUBSTRING_INDEX(:list_of_key_cols_tab_del, '|', 1) INTO provider_code;


    /* Verificar si el proveedor está en la lista negra */
    /* SELECT COUNT(*) INTO is_blacklisted,
        --    MAX(T1."SITUACION") INTO blacklist_status
    FROM fe_listanegra T1 
    WHERE T1."RFC" = (SELECT "LicTradNum" FROM OCRD WHERE "LicTradNum" = :list_of_cols_val_tab_del);
    -- WHERE T1."RFC" = (SELECT "LicTradNum" FROM OCRD WHERE "CardCode" = :list_of_cols_val_tab_del);

    /* Bloquear transacciones si el estado es "Definitivo" */
    IF is_blacklisted > 0 THEN

        IF :object_type IN ('2', '22', '18', '46') AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
            -- 2: Socio de Negocio "OCRD", 22: Orden de Compra "OPOR", 18: Factura de Proveedores "OPCH", 46: Pagos efectuados OVPM  
            error := 1; 
            error_message := 'El proveedor está en la lista negra y no se puede realizar esta transacción.';
            RETURN;
        END IF;

    END IF; */
    -- IF is_blacklisted > 0 AND blacklist_status = 'Definitivo' THEN

    --     IF :object_type IN ('2', '22', '18') AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
    --         -- 2: Socio de Negocio "OCRD", 22: Orden de Compra "OPOR", 18: Factura de Proveedores "OPCH", 46: Pagos efectuados OVPM  
    --         error := 1; 
    --         error_message := 'El proveedor está en la lista negra con estado "Definitivo" y no se puede realizar esta transacción.';
    --         RETURN;
    --     END IF;

    -- END IF;

-- END;

-- ******************************************************************************************************************



/* 
REPORTE LISTA NEGRA
SELECT RFC,Contribuyente,situacion,numeroyfecha,datosactualizacion,fecha from fe_listanegra

ESTADOS => "SITUACION" = ["Definitivo","Sentencia Favorables", ""
 */

 /* LISTA SOLO PROVEEDORES  */
SELECT T0."CardCode", T0."CardName" FROM OCRD T0 WHERE T0."CardType" = 'S' ORDER BY T0."CardName";

/*  */
SELECT *
FROM fe_listanegra 
WHERE RFC = (SELECT "LicTradNum" FROM OCRD WHERE "CardCode" = 'PNSM1101288B1');

/* Consulta para Verificar Proveedores en la Lista Negra */
SELECT 
    T0."CardCode", 
    T0."CardName",
    T1."RFC", 
    T1."CONTRIBUYENTE", 
    T1."SITUACION"
FROM 
    OCRD T0
LEFT JOIN 
    fe_listanegra T1 ON T0."LicTradNum" = T1."RFC" 
WHERE 
    T0."CardType" = 'S'  -- Filtramos solo proveedores
    AND T1."RFC" IS NOT NULL  -- Solo aquellos que están en la lista negra
ORDER BY 
    T0."CardName";



/* 
REPLICAR LA BASE DE DATOS DE EMP MEXICO


IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

 SELECT 
 COUNT(*) INTO is_blacklisted,
 FROM fe_listanegra T1 
 WHERE T1."RFC" = (SELECT "LicTradNum" FROM OCRD WHERE "LicTradNum" = :list_of_cols_val_tab_del);

 IF is_blacklisted > 0 THEN
	error := 1; 
    error_message := 'El proveedor está en la lista negra y no se puede realizar esta transacción.';
    RETURN;
 END IF;

END IF;



 */



 /* 
 
 ALTER TABLE "TMP" 
ALTER ("IMP RENTA SOC" NVARCHAR(5000));

 
  */


/* EPM_Pruebas */
/*implementacion en la base de datos de pruebas de EPM STORE PROCEDURE LIMITACION*/

-- SELECT *  FROM "B1H_EPM_PROD_20241231"."@SYP_LISTAS_NEGRAS"  T0 LIMIT 5
-- SELECT T0."U_RFC", T0."Name"  FROM "B1H_EPM_PROD_20241231"."@SYP_LISTAS_NEGRAS"  T0 LIMIT 5

RFC             CONTRIBUYENTE                                             SITUACION
AAAM930220954   AMADO ACOSTA MARCOS                                       Definitivo
AAC08052734A    ASESORÍAS ADMINISTRATIVAS CANTÚ MARTÍNEZ, S.A. DE C.V.    Definitivo
AAA080808HL8    ASESORES EN AVALÚOS Y ACTIVOS, S.A. DE C.V.               Sentencia Favorable
AAC100420480    ACEROS Y ALAMBRES DEL CENTRO, S.A.  DE C.V.               Sentencia Favorable

DROP PROCEDURE IF EXISTS SBO_SP_TransactionNotification_CLIENT;

CREATE PROCEDURE SBO_SP_TransactionNotification_CLIENT
(
    in object_type nvarchar(30),                -- Tipo de objeto SBO
    in transaction_type nchar(1),               -- [A]gregar, [U]pdate, [D]elete, [C]ancelar
    in num_of_cols_in_key int,
    in list_of_key_cols_tab_del nvarchar(255),
    in list_of_cols_val_tab_del nvarchar(255), 
    -- Valores de retorno
    out error int,                               -- Resultado (0 para sin error)
    out error_message nvarchar(200)             -- Mensaje de error a mostrar
)
LANGUAGE SQLSCRIPT
AS
is_blacklisted INT;
rfc nvarchar(30);   
BEGIN

 /* Verificar si se está creando o actualizando un socio de negocio */
    IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

        /* Verificar si el proveedor está en la lista negra */
        SELECT COUNT(*) INTO is_blacklisted
        FROM "B1H_EPM_PROD_20241231"."@SYP_LISTAS_NEGRAS" T0
        WHERE T0."U_RFC" = (SELECT "LicTradNum" FROM OCRD WHERE "LicTradNum" = :list_of_cols_val_tab_del);

        /* Bloquear transacciones si el proveedor está en la lista negra */
        IF is_blacklisted > 0 THEN
            error := 1; 
            error_message := 'El proveedor está en la lista negra y no se puede crear o actualizar.';
            RETURN;
        END IF;
    END IF;

    /* Solo proceder si se está creando o actualizando un proveedor Con Busqueda Formateada */
    IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

        /* Obtener el LicTradNum del proveedor ingresado usando la variable formateada */
        SELECT $[$41.1.0] INTO rfc FROM DUMMY; --campo LicTradNum

        /* Verificar si el proveedor está en la lista negra */
        SELECT COUNT(*) INTO is_blacklisted
        FROM "B1H_EPM_PROD_20241231"."@SYP_LISTAS_NEGRAS" T0
        WHERE T0."U_RFC" = rfc

        /* Bloquear transacciones si el proveedor está en la lista negra */
        IF is_blacklisted > 0 THEN
            error := 1; 
            error_message := 'El proveedor está en la lista negra y no se puede crear o actualizar.';
            RETURN;
        END IF;
    END IF;
END;

-- **************************************************************************
/* ASI QUEDO EN EPM_PRUEBAS ACTUALIZADO CON EL BLOKERO DE LA LISTA NEGRA */
-- **************************************************************************

DROP PROCEDURE SBO_SP_TransactionNotification_CLIENT;

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

--Variables Datos de maestro de articulos
SAL_UNIT_MSR_VALID INT;
INVNTRY_UOM_VALID INT;
UOM_CODE_VALID NVARCHAR(50);
IS_SELL_ITEM NVARCHAR(1);
ITEM_CODE NVARCHAR(50);  
UGPENTRY INT;

INVALID_ARTICLE_COUNT INT;

--VARIABLES LISTA NEGRAS
IS_BLACKLISTED INT;
RFC NVARCHAR(30); 


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

-- Validación para agregar o actualizar en OCRD (Datos Maestro Socio Negocio)
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
    
    
	/* Verificar si el proveedor está en la lista negra */
    /*SELECT COUNT(*) INTO IS_BLACKLISTED
    FROM "B1H_EPM_PROD_20241231"."@SYP_LISTAS_NEGRAS" T0
    WHERE T0."U_RFC" = (SELECT "LicTradNum" FROM OCRD WHERE "LicTradNum" = :list_of_cols_val_tab_del);*/
    
    /* Bloquear transacciones si el proveedor está en la lista negra */
    /*IF IS_BLACKLISTED > 0 THEN
        error := 1; 
        error_message := 'El proveedor está en la lista negra y no se puede crear o actualizar.';
        RETURN;
    END IF;*/

	-- Validaciones de datos del socio de negocio
	SELECT
		CASE 
	        WHEN COUNT(CASE WHEN T0."CardType" IN ('C', 'S', 'L') THEN 1 END) > 0 THEN 0 
	        ELSE 1 
	    END AS CardTypeCheck, 
        MAX(CASE 
	            WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
	            WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z0-9 .@]+$' THEN 2
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
		    WHEN T0."Phone1" NOT LIKE_REGEXPR '^\+?[0-9]+$' THEN 2  -- Teléfono contiene caracteres no numéricos
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
            WHEN LENGTH(T2."Code") = 3 THEN 2  -- Si el código tiene 3 caracteres (inhabilitado)hice cambio por el 3 
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
        --MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck,
 		MAX(CASE 
            WHEN T0."QryGroup1" = 'Y' AND (T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '') THEN 1 -- Comercio exterior sin ID fiscal
            ELSE 0 
        END) AS IdFiscalCheck,
        
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
		END) AS AnexosCheck,
		CASE 
            WHEN EXISTS (SELECT 1 
                         FROM "B1H_EPM_PROD_20241231"."@SYP_LISTAS_NEGRAS" T0
                         WHERE T0."U_RFC" = (SELECT "LicTradNum" FROM OCRD WHERE "CardCode" = :list_of_cols_val_tab_del)) THEN 1
            ELSE 0 
        END AS IsBlacklisted
        
	INTO 
        BP_EXISTS, CARD_NAME_VALID, EMAIL_VALID, PHONE_VALID, MAIN_USAGE, 
        ADDRESS_VALID, STREET_VALID, COLONIA_VALID, CITY_VALID, ZIP_CODE_VALID, COUNTRY_VALID,
        PAYMENT_CONDITION_VALID, LIC_TRAD_NUM_VALID, ID_FISCAL_VALID, REGIMEN_FISCAL_V4_VALID, PAYMENT_METHOD_CHECK_VALID,
        ANEXOS_VALID, IS_BLACKLISTED 
	FROM OCRD T0
	LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
	LEFT JOIN OCRY T2 ON T1."Country" = T2."Code"
	LEFT JOIN OPYM T3 ON T0."PymCode" = T3."PayMethCod"
	LEFT JOIN CRD2 T5 ON T0."CardCode" = T5."CardCode"
	WHERE T0."CardCode" = :list_of_cols_val_tab_del;
	
	-- Asignar errores según las validaciones realizadas

	IF IS_BLACKLISTED > 0 THEN
        error := 1; 
        error_message := 'El proveedor está en la lista negra y no se puede crear o actualizar.';
        RETURN;
    END IF;

    -- VALICACION DEL TIPO DEL NEGOCIO
	IF BP_EXISTS = 1 THEN
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
	    error_message := N'El número de teléfono debe contener el signo + y números.';
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
       --error_message := N'El id fiscal federal unificado es requerido';
       error_message := N'El ID fiscal es requerido para comercio exterior.';
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


--Maestro de Artículo
IF :object_type = '4' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
    SELECT 
        T0."NCMCode", 
        T0."SalUnitMsr", 
        T0."ItemType",
        T0."SellItem",  -- Indica si es un artículo de venta
        T0."ItemCode",  -- Código del artículo
        T0."UgpEntry",  -- Grupo de unidad de medida
        CASE 
            WHEN T0."SellItem" = 'Y' AND T0."SalUnitMsr" IS NULL OR T0."SalUnitMsr" = '' THEN 1 
            WHEN T0."SellItem" = 'Y' AND T0."SalUnitMsr" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT') THEN 2 
            ELSE 0 
        END AS SalUnitMsrCheck,
        CASE 
            WHEN T0."SellItem" = 'Y' AND T0."InvntryUom" IS NULL OR T0."InvntryUom" = '' THEN 1 
            WHEN T0."SellItem" = 'Y' AND T0."InvntryUom" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT') THEN 2 
            ELSE 0 
        END AS InvntryUomCheck
    INTO 
        CODCLAS, UNMED, TYPE_ITEM, 
		IS_SELL_ITEM, ITEM_CODE, UGPENTRY, 
		SAL_UNIT_MSR_VALID, INVNTRY_UOM_VALID
    FROM "OITM" T0 
    WHERE T0."ItemCode" = :list_of_cols_val_tab_del;

    IF TYPE_ITEM = 'I' THEN
        IF (:CODCLAS IS NULL OR :CODCLAS = '-1') THEN
            error := 1;
            error_message := N'DPE: Debe Ingresar el campo Código de Clasificación';
        END IF;

        IF (:UNMED IS NULL) THEN
            error := 2;
            error_message := N'DPE: Debe Ingresar el campo Unidad de Medida de Ventas'; 
        END IF;

        -- Validación del código del artículo
        /*IF ( LEFT(:ITEM_CODE, 2) IN ('01', '03', '04', '07') ) AND (:IS_SELL_ITEM = 'Y') AND (:UGPENTRY = '-1') THEN
            error := 3; 
            error_message := N'Error: Si el artículo comienza con 01, 03, 04 o 07 y está marcado como artículo de venta, no debería ser Manual.';  
        END IF;*/
        
        -- Validación del código del artículo
        IF (:IS_SELL_ITEM = 'Y') THEN
           IF ( LEFT(:ITEM_CODE, 2) IN ('01', '03', '04', '07') AND (:UGPENTRY = '-1')  ) THEN
            error := 3; 
            error_message := N'Error: Si el artículo comienza con 01, 03, 04 o 07 y está marcado como artículo de venta, no debería ser Manual.';
           END IF;
              
        END IF;

        -- Manejo de errores para las validaciones del maestro de artículos
        IF SAL_UNIT_MSR_VALID = 1 THEN
            error := 4;  
            error_message := N'El nombre de la unidad de medida de venta es requerido';
        END IF;

        IF SAL_UNIT_MSR_VALID = 2 THEN
            error := 5;  
            error_message := N'El nombre de la unidad de medida de venta debe ser XUN, KGM, PLIEGO, XBX, H87 o ACT.';
        END IF;

        IF INVNTRY_UOM_VALID = 1 THEN
            error := 6;  
            error_message := N'En datos de inventario: El nombre de la unidad es requerido';
        END IF;

        IF INVNTRY_UOM_VALID = 2 THEN
            error := 7;  
            error_message := N'En datos de inventario: El nombre de la unidad debe ser XUN, KGM, PLIEGO, XBX, H87 o ACT.';
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
                WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z0-9 .@]+$' THEN 2
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
            WHEN T0."Phone1" NOT LIKE_REGEXPR '^\+?[0-9]+$' THEN 2  
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
        --MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck,
		MAX(CASE 
            WHEN T0."QryGroup1" = 'Y' AND (T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '') THEN 1 -- Comercio exterior sin ID fiscal
            ELSE 0 
        END) AS IdFiscalCheck,
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


--Orden de compra - Pedido OPOR 
-- Validaciones para el objeto tipo '22' (Orden de Compra)
IF :object_type = '22' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN 

	-- Validar que el socio de negocio tenga todos los campos requeridos llenos antes de permitir la creación de la orden de compra.
    SELECT
        CASE 
            WHEN COUNT(CASE WHEN T0."CardType" IN ('C', 'S', 'L') THEN 1 END) > 0 THEN 0 
            ELSE 1 
        END AS CardTypeCheck,
        MAX(CASE 
                WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
                WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z0-9 .@]+$' THEN 2
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
            WHEN T0."Phone1" NOT LIKE_REGEXPR '^\+?[0-9]+$' THEN 2  
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
		MAX(CASE 
            WHEN T0."QryGroup1" = 'Y' AND (T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '') THEN 1 -- Comercio exterior sin ID fiscal
            ELSE 0 
        END) AS IdFiscalCheck,
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
      FROM OPOR WHERE "DocEntry" IN (:list_of_cols_val_tab_del)
    );

	-- Asignar un error general si alguna validación falla
    IF BP_EXISTS > 0 OR CARD_NAME_VALID > 0 
    	OR EMAIL_VALID > 0 OR PHONE_VALID > 0 
    	OR MAIN_USAGE > 0 OR ADDRESS_VALID > 0 
    	OR STREET_VALID > 0 OR COLONIA_VALID > 0 
    	OR CITY_VALID > 0 OR ZIP_CODE_VALID > 0 OR COUNTRY_VALID > 0 
    	OR PAYMENT_CONDITION_VALID > 0 OR LIC_TRAD_NUM_VALID > 0 
    	OR ID_FISCAL_VALID > 0 OR REGIMEN_FISCAL_V4_VALID > 0 
    	OR PAYMENT_METHOD_CHECK_VALID > 0 OR ANEXOS_VALID > 0 
    	THEN
        error = 40;
        --error_message = 'Faltan campos por validar en el maestro socio negocio o en los artículos antes de crear la orden de compra.';
        error_message = 'Faltan campos por validar en el maestro socio negocio antes de crear la orden de compra.';
        RETURN;
    END IF;
    
    SELECT COUNT(*)
    INTO INVALID_ARTICLE_COUNT
    FROM OPOR A0
    INNER JOIN POR1 A1 ON A0."DocEntry" = A1."DocEntry"
    INNER JOIN OITM A2 ON A1."ItemCode" = A2."ItemCode"
    WHERE A0."DocEntry" IN (:list_of_cols_val_tab_del)
    AND(
	    (A2."SellItem" = 'Y' AND (A2."SalUnitMsr" IS NULL OR A2."SalUnitMsr" = '' OR A2."SalUnitMsr" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT'))) OR
	    (A2."SellItem" = 'Y' AND (A2."InvntryUom" IS NULL OR A2."InvntryUom" = '' OR A2."InvntryUom" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT'))) OR
	    (A2."SellItem" = 'Y' AND LEFT(A2."ItemCode", 2) IN ('01', '03', '04', '07') AND (A2."UgpEntry" = '-1'))
    );

    IF INVALID_ARTICLE_COUNT > 0 THEN
        error := 8;  
        error_message := N'Existen artículos inválidos en la orden de compra. Verifique las unidades de medida o el código del artículo.';
        RETURN;
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



END;

RFC             CONTRIBUYENTE                                             SITUACION
AAAM930220954   AMADO ACOSTA MARCOS                                       Definitivo
AAC08052734A    ASESORÍAS ADMINISTRATIVAS CANTÚ MARTÍNEZ, S.A. DE C.V.    Definitivo
AAA080808HL8    ASESORES EN AVALÚOS Y ACTIVOS, S.A. DE C.V.               Sentencia Favorable
AAC100420480    ACEROS Y ALAMBRES DEL CENTRO, S.A.  DE C.V.               Sentencia Favorable

/* algo asi */
--SELECT * FROM "B1H_EPM_PROD_20241231"."@SYP_LISTAS_NEGRAS" T0

SELECT *
FROM "B1H_EPM_PROD_20241231"."@SYP_LISTAS_NEGRAS" T0
WHERE
T0."U_RFC" = 'AAA080808HL8' --'AAC08052734A'
AND T0."U_SITUACION" = 'Sentencia Favorable'
-- ****************************************************

DECLARE CLIENTE VARCHAR(20);
DECLARE RFC_EN_LISTA_FAVORABLE INTEGER := 0;
DECLARE MENSAJE_ALERTA VARCHAR(255) := '';

BEGIN
  -- Obtener el CardCode del cliente
  SELECT $[$5.1.0] INTO CLIENTE FROM DUMMY;

  -- Verificar si el RFC del cliente está en la lista negra con 'Sentencia Favorable'
  SELECT COUNT(*) INTO RFC_EN_LISTA_FAVORABLE
  FROM "B1H_EPM_PROD_20241231"."@SYP_LISTAS_NEGRAS" T0
  INNER JOIN OCRD T1 ON T0."U_RFC" = T1."LicTradNum"
  WHERE T1."CardCode" = :CLIENTE
    AND T0."U_SITUACION" = 'Sentencia Favorable';

  -- Construir el mensaje de alerta
  IF (RFC_EN_LISTA_FAVORABLE > 0) THEN
    MENSAJE_ALERTA := 'El cliente tiene una Sentencia Favorable registrada.';
  END IF;

  -- Devolver el resultado
  IF (MENSAJE_ALERTA <> '') THEN
    SELECT 'TRUE - ' || MENSAJE_ALERTA FROM DUMMY;  -- Devolver la alerta
  ELSE
    SELECT 'FALSE' FROM DUMMY;  -- No hay alerta
  END IF;

END;





-- ********************************************************

-- Ejemplo
SELECT
    OCRD."CardCode",
    OCRD."LicTradNum",
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM "B1H_EPM_PROD_20241231"."@SYP_LISTAS_NEGRAS" T0
            WHERE
                T0."U_RFC" = OCRD."LicTradNum"
                AND T0."U_SITUACION" = 'Sentencia Favorable'
        ) THEN 1  -- Está en la lista negra (pero tiene Sentencia Favorable)
        ELSE 0  -- No está en la lista negra o no tiene Sentencia Favorable
    END AS IsBlacklisted
FROM
    OCRD
WHERE OCRD."CardCode" = :list_of_cols_val_tab_del;

IF IS_BLACKLISTED = 0 THEN  -- Cambiamos > 0 a = 0
    error := 1;
    error_message := 'El proveedor está en la lista negra y no se puede crear o actualizar.';
    RETURN;
END IF;



/*SELECT 
*
FROM "B1H_EPM_PROD_20241231"."@SYP_LISTAS_NEGRAS" T0
LEFT JOIN OCRD T1 ON T0."U_RFC" = 'AAA080808HL8'  --'AAAM930220954' --(SELECT "LicTradNum" FROM OCRD)
WHERE T0."U_SITUACION" = 'Sentencia */

-- ************************ALARMA EN EMP_PRUEBAS**********************

SELECT
    T0."U_RFC",
    T0."U_SITUACION",
    T1."CardCode",
    T1."CardName",
    T1."CreateDate"
FROM
    "B1H_EPM_PROD_20241231"."@SYP_LISTAS_NEGRAS" T0
INNER JOIN
    OCRD T1 ON T0."U_RFC" = T1."LicTradNum" 
WHERE
    T0."U_SITUACION" = 'Sentencia Favorable'
    AND T1."CreateDate" >= ADD_DAYS(CURRENT_DATE, -1)  -- Fecha de creación desde ayer
    AND T1."CreateDate" < CURRENT_DATE;   -- Fecha de creación hasta hoy (excluyendo hoy)


-- ************************ALARMA EN ENVASE PAPELEROS DE MEXICO**********************
--SELECT RFC,Contribuyente,situacion,numeroyfecha,datosactualizacion,fecha from fe_listanegra

--SELECT RFC,Contribuyente,situacion,numeroyfecha,datosactualizacion,fecha FROM fe_listanegra WHERE "SITUACION" = 'Sentencia Favorable'

SELECT
    T0."RFC",
    T0."SITUACION",
    T1."CardCode",
    T1."CardName",
    T1."CreateDate"
FROM
    fe_listanegra T0
INNER JOIN
    OCRD T1 ON T0."RFC" = T1."LicTradNum" 
WHERE
    T0."SITUACION" = 'Sentencia Favorable'
    AND T1."CreateDate" >= ADD_DAYS(CURRENT_DATE, -1)  -- Fecha de creación desde ayer
    AND T1."CreateDate" < CURRENT_DATE;   -- Fecha de creación hasta hoy (excluyendo hoy)



-- ***********ORIGINAL PRUEBAS EPM***********

SELECT * 
FROM fe_listanegra T0
WHERE 
T0."RFC" = 'AAA080808HL8' --(SELECT "LicTradNum" FROM OCRD WHERE "CardCode" = :list_of_cols_val_tab_del)
AND T0."SITUACION" = 'Sentencia Favorable'


-- *******************************PARA HACER PRUEBAS EN LA PRESENTACION*********************************************
RFC             CONTRIBUYENTE                                             SITUACION
AAAM930220954   AMADO ACOSTA MARCOS                                       Definitivo
AAC08052734A    ASESORÍAS ADMINISTRATIVAS CANTÚ MARTÍNEZ, S.A. DE C.V.    Definitivo
AAA080808HL8    ASESORES EN AVALÚOS Y ACTIVOS, S.A. DE C.V.               Sentencia Favorable
AAC100420480    ACEROS Y ALAMBRES DEL CENTRO, S.A.  DE C.V.               Sentencia Favorable

--SELECT * FROM fe_listanegra T0 LIMIT 2

SELECT * FROM fe_listanegra T0 WHERE T0."SITUACION" = 'Sentencia Favorable'  LIMIT 2
-- ******************************************************************************************************************

-- QM - General - BF - Almacenes PL
SELECT T0."WhsCode", T0."WhsName" FROM OWHS T0 WHERE T0."WhsCode" LIKE '10%'

-- ********************************************************************************************************************

/* ENVASE PAPELERO DE MEXICO  */

DROP PROCEDURE SBO_SP_TransactionNotification_CLIENT;

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

--Variables Datos de maestro de articulos
SAL_UNIT_MSR_VALID INT;
INVNTRY_UOM_VALID INT;
UOM_CODE_VALID NVARCHAR(50);
IS_SELL_ITEM NVARCHAR(1);
ITEM_CODE NVARCHAR(50);  
UGPENTRY INT;

INVALID_ARTICLE_COUNT INT;

--VARIABLES LISTA NEGRAS
IS_BLACKLISTED INT;
RFC NVARCHAR(30); 
 

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

-- Validación para agregar o actualizar en OCRD (Datos Maestro Socio Negocio)
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

	-- Validaciones de datos del socio de negocio
	SELECT
		CASE 
	        WHEN COUNT(CASE WHEN T0."CardType" IN ('C', 'S', 'L') THEN 1 END) > 0 THEN 0 
	        ELSE 1 
	    END AS CardTypeCheck, 
        MAX(CASE 
	            WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
	            WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z0-9 .@]+$' THEN 2
	            WHEN LENGTH(T0."CardName") > 75 THEN 3
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
		    WHEN T0."Phone1" NOT LIKE_REGEXPR '^\+?[0-9]+$' THEN 2  -- Teléfono contiene caracteres no numéricos
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
        --MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck,
 		MAX(CASE 
            WHEN T0."QryGroup1" = 'Y' AND (T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '') THEN 1 -- Comercio exterior sin ID fiscal
            ELSE 0 
        END) AS IdFiscalCheck,
        
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
		END) AS AnexosCheck,
		-- Validación de lista negras
		CASE 
            WHEN EXISTS (SELECT 1 
                         FROM fe_listanegra T0
                         WHERE 
                            T0."RFC" = (SELECT "LicTradNum" FROM OCRD WHERE "CardCode" = :list_of_cols_val_tab_del)
                            AND T0."SITUACION" = 'Sentencia Favorable'
                         ) THEN 1
            ELSE 0 
        END AS IsBlacklisted
        
	INTO 
        BP_EXISTS, CARD_NAME_VALID, EMAIL_VALID, PHONE_VALID, MAIN_USAGE, 
        ADDRESS_VALID, STREET_VALID, COLONIA_VALID, CITY_VALID, ZIP_CODE_VALID, COUNTRY_VALID,
        PAYMENT_CONDITION_VALID, LIC_TRAD_NUM_VALID, ID_FISCAL_VALID, REGIMEN_FISCAL_V4_VALID, PAYMENT_METHOD_CHECK_VALID,
        ANEXOS_VALID, IS_BLACKLISTED
	FROM OCRD T0
	LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
	LEFT JOIN OCRY T2 ON T1."Country" = T2."Code"
	LEFT JOIN OPYM T3 ON T0."PymCode" = T3."PayMethCod"
	LEFT JOIN CRD2 T5 ON T0."CardCode" = T5."CardCode"
	WHERE T0."CardCode" = :list_of_cols_val_tab_del;
	
	-- Asignar errores según las validaciones realizadas
    IF IS_BLACKLISTED = 0 THEN
        error := 1; 
        error_message := 'El proveedor está en la lista negra y no se puede crear o actualizar.';
        RETURN;
    END IF;

    -- VALICACION DEL TIPO DEL NEGOCIO
	IF BP_EXISTS = 1 THEN
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
	    error_message := N'El nombre no debe exceder los 75 caracteres.';
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
	    error_message := N'El número de teléfono debe contener el signo + y números.';
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
       --error_message := N'El id fiscal federal unificado es requerido';
       error_message := N'El ID fiscal es requerido para comercio exterior.';
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


--Maestro de Artículo
IF :object_type = '4' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
    SELECT 
        T0."NCMCode", 
        T0."SalUnitMsr", 
        T0."ItemType",
        T0."SellItem",  -- Indica si es un artículo de venta
        T0."ItemCode",  -- Código del artículo
        T0."UgpEntry",  -- Grupo de unidad de medida
        CASE 
            WHEN T0."SellItem" = 'Y' AND T0."SalUnitMsr" IS NULL OR T0."SalUnitMsr" = '' THEN 1 
            WHEN T0."SellItem" = 'Y' AND T0."SalUnitMsr" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT') THEN 2 
            ELSE 0 
        END AS SalUnitMsrCheck,
        CASE 
            WHEN T0."SellItem" = 'Y' AND T0."InvntryUom" IS NULL OR T0."InvntryUom" = '' THEN 1 
            WHEN T0."SellItem" = 'Y' AND T0."InvntryUom" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT') THEN 2 
            ELSE 0 
        END AS InvntryUomCheck
    INTO 
        CODCLAS, UNMED, TYPE_ITEM, 
		IS_SELL_ITEM, ITEM_CODE, UGPENTRY, 
		SAL_UNIT_MSR_VALID, INVNTRY_UOM_VALID
    FROM "OITM" T0 
    WHERE T0."ItemCode" = :list_of_cols_val_tab_del;

    IF TYPE_ITEM = 'I' THEN
        IF (:CODCLAS IS NULL OR :CODCLAS = '-1') THEN
            error := 1;
            error_message := N'DPE: Debe Ingresar el campo Código de Clasificación';
        END IF;

        IF (:UNMED IS NULL) THEN
            error := 2;
            error_message := N'DPE: Debe Ingresar el campo Unidad de Medida de Ventas'; 
        END IF;

        -- Validación del código del artículo
        /*IF ( LEFT(:ITEM_CODE, 2) IN ('01', '03', '04', '07') ) AND (:IS_SELL_ITEM = 'Y') AND (:UGPENTRY = '-1') THEN
            error := 3; 
            error_message := N'Error: Si el artículo comienza con 01, 03, 04 o 07 y está marcado como artículo de venta, no debería ser Manual.';  
        END IF;*/
        
        -- Validación del código del artículo
        IF (:IS_SELL_ITEM = 'Y') THEN
           IF ( LEFT(:ITEM_CODE, 2) IN ('01', '03', '04', '07') AND (:UGPENTRY = '-1')  ) THEN
            error := 3; 
            error_message := N'Error: Si el artículo comienza con 01, 03, 04 o 07 y está marcado como artículo de venta, no debería ser Manual.';
           END IF;
              
        END IF;

        -- Manejo de errores para las validaciones del maestro de artículos
        IF SAL_UNIT_MSR_VALID = 1 THEN
            error := 4;  
            error_message := N'El nombre de la unidad de medida de venta es requerido';
        END IF;

        IF SAL_UNIT_MSR_VALID = 2 THEN
            error := 5;  
            error_message := N'El nombre de la unidad de medida de venta debe ser XUN, KGM, PLIEGO, XBX, H87 o ACT.';
        END IF;

        IF INVNTRY_UOM_VALID = 1 THEN
            error := 6;  
            error_message := N'En datos de inventario: El nombre de la unidad es requerido';
        END IF;

        IF INVNTRY_UOM_VALID = 2 THEN
            error := 7;  
            error_message := N'En datos de inventario: El nombre de la unidad debe ser XUN, KGM, PLIEGO, XBX, H87 o ACT.';
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
                WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z0-9 .@]+$' THEN 2
                WHEN LENGTH(T0."CardName") > 75 THEN 3
            ELSE 0 
        END) AS CardNameCheck, 
        MAX(CASE 
                WHEN T0."E_Mail" IS NULL OR T0."E_Mail" = '' THEN 1
                WHEN T0."E_Mail" NOT LIKE_REGEXPR '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN 2
            ELSE 0 
        END) AS EmailCheck,
        MAX(CASE 
            WHEN T0."Phone1" IS NULL OR T0."Phone1" = '' THEN 1
            WHEN T0."Phone1" NOT LIKE_REGEXPR '^\+?[0-9]+$' THEN 2  
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
        --MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck,
		MAX(CASE 
            WHEN T0."QryGroup1" = 'Y' AND (T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '') THEN 1 -- Comercio exterior sin ID fiscal
            ELSE 0 
        END) AS IdFiscalCheck,
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


--Orden de compra - Pedido OPOR 
-- Validaciones para el objeto tipo '22' (Orden de Compra)
IF :object_type = '22' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN 

	-- Validar que el socio de negocio tenga todos los campos requeridos llenos antes de permitir la creación de la orden de compra.
    SELECT
        CASE 
            WHEN COUNT(CASE WHEN T0."CardType" IN ('C', 'S', 'L') THEN 1 END) > 0 THEN 0 
            ELSE 1 
        END AS CardTypeCheck,
        MAX(CASE 
                WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
                WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z0-9 .@]+$' THEN 2
                WHEN LENGTH(T0."CardName") > 75 THEN 3
            ELSE 0 
        END) AS CardNameCheck, 
        MAX(CASE 
                WHEN T0."E_Mail" IS NULL OR T0."E_Mail" = '' THEN 1
                WHEN T0."E_Mail" NOT LIKE_REGEXPR '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN 2
            ELSE 0 
        END) AS EmailCheck,
        MAX(CASE 
            WHEN T0."Phone1" IS NULL OR T0."Phone1" = '' THEN 1
            WHEN T0."Phone1" NOT LIKE_REGEXPR '^\+?[0-9]+$' THEN 2  
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
		MAX(CASE 
            WHEN T0."QryGroup1" = 'Y' AND (T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '') THEN 1 -- Comercio exterior sin ID fiscal
            ELSE 0 
        END) AS IdFiscalCheck,
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
      FROM OPOR WHERE "DocEntry" IN (:list_of_cols_val_tab_del)
    );

	-- Asignar un error general si alguna validación falla
    IF BP_EXISTS > 0 OR CARD_NAME_VALID > 0 
    	OR EMAIL_VALID > 0 OR PHONE_VALID > 0 
    	OR MAIN_USAGE > 0 OR ADDRESS_VALID > 0 
    	OR STREET_VALID > 0 OR COLONIA_VALID > 0 
    	OR CITY_VALID > 0 OR ZIP_CODE_VALID > 0 OR COUNTRY_VALID > 0 
    	OR PAYMENT_CONDITION_VALID > 0 OR LIC_TRAD_NUM_VALID > 0 
    	OR ID_FISCAL_VALID > 0 OR REGIMEN_FISCAL_V4_VALID > 0 
    	OR PAYMENT_METHOD_CHECK_VALID > 0 OR ANEXOS_VALID > 0 
    	THEN
        error = 40;
        --error_message = 'Faltan campos por validar en el maestro socio negocio o en los artículos antes de crear la orden de compra.';
        error_message = 'Faltan campos por validar en el maestro socio negocio antes de crear la orden de compra.';
        RETURN;
    END IF;
    
    SELECT COUNT(*)
    INTO INVALID_ARTICLE_COUNT
    FROM OPOR A0
    INNER JOIN POR1 A1 ON A0."DocEntry" = A1."DocEntry"
    INNER JOIN OITM A2 ON A1."ItemCode" = A2."ItemCode"
    WHERE A0."DocEntry" IN (:list_of_cols_val_tab_del)
    AND(
	    (A2."SellItem" = 'Y' AND (A2."SalUnitMsr" IS NULL OR A2."SalUnitMsr" = '' OR A2."SalUnitMsr" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT'))) OR
	    (A2."SellItem" = 'Y' AND (A2."InvntryUom" IS NULL OR A2."InvntryUom" = '' OR A2."InvntryUom" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT'))) OR
	    (A2."SellItem" = 'Y' AND LEFT(A2."ItemCode", 2) IN ('01', '03', '04', '07') AND (A2."UgpEntry" = '-1'))
    );

    IF INVALID_ARTICLE_COUNT > 0 THEN
        error := 8;  
        error_message := N'Existen artículos inválidos en la orden de compra. Verifique las unidades de medida o el código del artículo.';
        RETURN;
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





END;



/* nuevo proceso de lista negras */
IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

	--Guadalupe solo CardType =  lead
	SELECT T0."USERID" INTO USR FROM OUSR T0 
	
	IF(:USR = 24) THEN --Guadalupe Ramirez
	
	END IF;
	
	IF(:USR = 45) THEN --Christian Cevallos
	
	END IF;
	
END IF;


SELECT T0."UserSign", * FROM OCRD T0 WHERE T0."UserSign" = 24  --Guadalupe Ramirez


SELECT T0."UserSign", * FROM OCRD T0 WHERE T0."UserSign" = 45  --Christian Cevallos


/* 
SELECT 
  T0."UserSign", T0."CardType",
  T1."USERID", T1."USER_CODE" 
FROM OCRD T0 
LEFT JOIN OUSR T1 ON T0."UserSign" = T1."USERID"
WHERE T0."UserSign" = 24
 */

-- ******************************************************************************************************************************

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

IS_BLACKLISTED INT;
USER_SIGN INT;
CARD_TYPE NVARCHAR(1);
USER_CODE NVARCHAR;
BEGIN

    -- Validación para agregar o actualizar en OCRD (Datos Maestro Socio Negocio)
    IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

        --Guadalupe solo va a crear proveedores en CardType = L que pertenecen a lista negras 
        --pero si no pertenece en lista negra si puede crear Proveedores "CardType" IN ('C', 'S', 'L')
        -- tampo no puede editar el  ('C', 'S')
        --SELECT T0."UserSign", * FROM OCRD T0 WHERE T0."UserSign" = 24  --Guadalupe Ramirez

        --Christian y el puede crear y actualizar cualquier proveedor o cliente ejemplo si esta en lead entonces el lo puede cambias a Proveedor el CardType 
        --SELECT T0."UserSign", * FROM OCRD T0 WHERE T0."UserSign" = 45  --Christian Cevallos


        -- SELECT "UserSign" INTO USER_SIGN FROM OCRD WHERE "CardCode" = :list_of_cols_val_tab_del;



        -- Validaciones de datos del socio de negocio
        SELECT
            T0."UserSign", -- Get UserSign
            T0."CardType", -- Get CardType
            T6."USER_CODE", 
            CASE 
                WHEN COUNT(CASE WHEN T0."CardType" IN ('C', 'S', 'L') THEN 1 END) > 0 THEN 0 
                ELSE 1 
            END AS CardTypeCheck, 
            MAX(CASE 
                    WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
                    WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z0-9 .@]+$' THEN 2
                    WHEN LENGTH(T0."CardName") > 75 THEN 3
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
                WHEN T0."Phone1" NOT LIKE_REGEXPR '^\+?[0-9]+$' THEN 2  -- Teléfono contiene caracteres no numéricos
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
            --MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck,
            MAX(CASE 
                WHEN T0."QryGroup1" = 'Y' AND (T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '') THEN 1 -- Comercio exterior sin ID fiscal
                ELSE 0 
            END) AS IdFiscalCheck,
            
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
            END) AS AnexosCheck,
            -- Validación de lista negras
            CASE 
                WHEN EXISTS (SELECT 1 
                            FROM fe_listanegra T0
                            WHERE 
                                T0."RFC" = (SELECT "LicTradNum" FROM OCRD WHERE "CardCode" = :list_of_cols_val_tab_del)
                                --AND T0."SITUACION" = 'Sentencia Favorable'
                            ) THEN 1
                ELSE 0 
            END AS IsBlacklisted
            
        INTO 
            USER_SIGN, CARD_TYPE, USER_CODE,
            BP_EXISTS, CARD_NAME_VALID, EMAIL_VALID, PHONE_VALID, MAIN_USAGE, 
            ADDRESS_VALID, STREET_VALID, COLONIA_VALID, CITY_VALID, ZIP_CODE_VALID, COUNTRY_VALID,
            PAYMENT_CONDITION_VALID, LIC_TRAD_NUM_VALID, ID_FISCAL_VALID, REGIMEN_FISCAL_V4_VALID, PAYMENT_METHOD_CHECK_VALID,
            ANEXOS_VALID, IS_BLACKLISTED
        FROM OCRD T0
        LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
        LEFT JOIN OCRY T2 ON T1."Country" = T2."Code"
        LEFT JOIN OPYM T3 ON T0."PymCode" = T3."PayMethCod"
        LEFT JOIN CRD2 T5 ON T0."CardCode" = T5."CardCode"
        LEFT JOIN OUSR T6 ON T0."UserSign" = T6."USERID"
        WHERE T0."CardCode" = :list_of_cols_val_tab_del;
        
        -- Asignar errores según las validaciones realizadas
        /*IF IS_BLACKLISTED = 0 THEN
            error := 1; 
            error_message := 'El proveedor está en la lista negra y no se puede crear o actualizar.';
            RETURN;
        END IF;*/


         -- Guadalupe's logic (UserSign = 24)
        IF ( :USER_SIGN = 24 AND :USER_CODE = 'EPM03' ) THEN
            --Guadalupe solo va a crear proveedores en CardType = L que pertenecen a lista negras
            --pero si no pertenece en lista negra si puede crear Proveedores "CardType" IN ('C', 'S', 'L')
            -- tampo no puede editar el  ('C', 'S')
            IF :IS_BLACKLISTED = 1 THEN
                -- Si el Proveedor está en la lista negra, permita solo la creación/actualización como Lead (CardType = 'L')
                IF :CARD_TYPE <> 'L' THEN
                    error := 100; 
                    error_message := N'Guadalupe: Los proveedores incluidos en la lista negra solo se pueden crear/actualizar como Leads.';
                    RETURN;
                END IF;
            ELSE
               -- Si no está en la lista negra, Guadalupe solo puede crear/actualizar clientes Lead (L)
            IF :CARD_TYPE <> 'L' THEN
                    error := 101;  -- Assign a unique error code
                    error_message := N'Guadalupe:  can only create/update Leads.';
                    RETURN;
                END IF;
            END IF;
        END IF;


        -- Christian's logic (UserSign = 45)
        IF (:USER_SIGN = 45 AND :USER_CODE = 'EPM06' ) THEN
            --Christian y el puede crear y actualizar cualquier proveedor o cliente ejemplo si esta en lead entonces el lo puede cambias a Proveedor el CardType
    
        END IF;





        -- VALICACION DEL TIPO DEL NEGOCIO
        IF BP_EXISTS = 1 THEN
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
            error_message := N'El nombre no debe exceder los 75 caracteres.';
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
            error_message := N'El número de teléfono debe contener el signo + y números.';
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
        --error_message := N'El id fiscal federal unificado es requerido';
        error_message := N'El ID fiscal es requerido para comercio exterior.';
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


-- ***************************************BASE DE DATOS DE PRUEBAS EPM************************************************************
IS_BLACKLISTED INT;
USER_SIGN INT;
CARD_TYPE NVARCHAR(1);
USER_CODE NVARCHAR(255); 



-- Validación para agregar o actualizar en OCRD (Datos Maestro Socio Negocio)
    IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
    
    	 SELECT
            T0."UserSign", 
            T0."CardType", 
            CAST(T6."USER_CODE" AS VARCHAR),
            CASE 
            	WHEN EXISTS (
	            		SELECT 1 
	                    FROM "B1H_EPM_PROD_20241231"."@SYP_LISTAS_NEGRAS" T0
	                    WHERE T0."U_RFC" = (SELECT "LicTradNum" FROM OCRD WHERE "CardCode" = :list_of_cols_val_tab_del)
                    ) THEN 1
            	ELSE 0 
        	END AS IsBlacklisted
        	
        INTO 
            USER_SIGN, CARD_TYPE, USER_CODE, IS_BLACKLISTED
        FROM OCRD T0
        LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
        LEFT JOIN OCRY T2 ON T1."Country" = T2."Code"
        LEFT JOIN OPYM T3 ON T0."PymCode" = T3."PayMethCod"
        LEFT JOIN CRD2 T5 ON T0."CardCode" = T5."CardCode"
        LEFT JOIN OUSR T6 ON CAST(T0."UserSign" AS INT) = CAST(T6."USERID" AS INT)
        WHERE T0."CardCode" = :list_of_cols_val_tab_del;
        
      
         -- Guadalupe's logic (UserSign = 24)
        --IF :USER_SIGN = 1 AND :USER_CODE = 'manager' THEN
        --IF ( :USER_SIGN = 24 AND :USER_CODE = 'EPM03' ) THEN
        IF :USER_SIGN = 1 AND :USER_CODE = 'manager' THEN
        
            --Guadalupe solo va a crear proveedores en CardType = L que pertenecen a lista negras
            --pero si no pertenece en lista negra si puede crear Proveedores "CardType" IN ('C', 'S', 'L')
            -- tampo no puede editar el  ('C', 'S')
            IF :IS_BLACKLISTED = 1 THEN
                -- Si el Proveedor está en la lista negra, permita solo la creación/actualización como Lead (CardType = 'L')
                IF :CARD_TYPE <> 'L' THEN
                    error := 100; 
                    error_message := N': Los proveedores incluidos en la lista negra solo se pueden crear/actualizar como Leads.';
                    RETURN;
                END IF;
            
            ELSE
               -- Si no está en la lista negra, Guadalupe solo puede crear/actualizar clientes Lead (L)
	            IF :IS_BLACKLISTED = 0 AND :CARD_TYPE <> 'L' THEN
	                error := 101;
	                error_message := N': solo puede crear/actualizar proveedores Leads.';
	                RETURN;
	             END IF;
	        END IF; 
            
        END IF; 
    
    
    END IF; -- Fin de la validación para OCRD

END;

  

  /* ASI QUEDO LA PRUEBA */
  -- Validación para agregar o actualizar en OCRD (Datos Maestro Socio Negocio)
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

--Variables Datos de maestro de articulos
SAL_UNIT_MSR_VALID INT;
INVNTRY_UOM_VALID INT;
UOM_CODE_VALID NVARCHAR(50);
IS_SELL_ITEM NVARCHAR(1);
ITEM_CODE NVARCHAR(50);  
UGPENTRY INT;

INVALID_ARTICLE_COUNT INT;

--VARIABLES LISTA NEGRAS
--IS_BLACKLISTED INT;
RFC NVARCHAR(30);


IS_BLACKLISTED INT;
USER_SIGN INT;
CARD_TYPE NVARCHAR(1);
USER_CODE NVARCHAR(255); 


BEGIN
    IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
    
    	SELECT 
    		T0."UserSign", 
    		T0."CardType", 
    		CAST(T6."USER_CODE" AS VARCHAR),
    		CASE 
            	WHEN EXISTS (
	            		SELECT 1 
	                    FROM "B1H_EPM_PROD_20241231"."@SYP_LISTAS_NEGRAS" T0
	                    WHERE T0."U_RFC" = (SELECT "LicTradNum" FROM OCRD WHERE "CardCode" = :list_of_cols_val_tab_del)
                    ) THEN 1
            	ELSE 0 
        	END AS IsBlacklisted
        INTO USER_SIGN, CARD_TYPE, USER_CODE, IS_BLACKLISTED
        FROM OCRD T0
        LEFT JOIN OUSR T6 ON CAST(T0."UserSign" AS INT) = CAST(T6."USERID" AS INT)
        WHERE T0."CardCode" = :list_of_cols_val_tab_del;
        
      
         -- Guadalupe's logic (UserSign = 24)
        --IF :USER_SIGN = 1 AND :USER_CODE = 'manager' THEN
        --IF ( :USER_SIGN = 24 AND :USER_CODE = 'EPM03' ) THEN
        IF :USER_SIGN = 24 AND :USER_CODE = 'EPM03' THEN
            --Guadalupe solo va a crear proveedores en CardType = L que pertenecen a lista negras
            --pero si no pertenece en lista negra si puede crear Proveedores "CardType" IN ('C', 'S', 'L')
            -- tampo no puede editar el proveedor de lista negra "CardType" en Cliente o proveedor ('C', 'S')
            IF :IS_BLACKLISTED = 1 THEN
                -- Si el Proveedor está en la lista negra, permita solo la creación/actualización como Lead (CardType = 'L')
                IF :CARD_TYPE <> 'L' THEN
                    error := 1; 
                    error_message := N': El proveedor esta incluido en la lista negra solo se pueden crear/actualizar como Leads.';
                    RETURN;
                END IF;
	        END IF;   
        END IF;
        
        
        
        SELECT
			CASE 
		        WHEN COUNT(CASE WHEN T0."CardType" IN ('C', 'S', 'L') THEN 1 END) > 0 THEN 0 
		        ELSE 1 
		    END AS CardTypeCheck, 
	        MAX(CASE 
		            WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
		            WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z0-9 .@]+$' THEN 2
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
			    WHEN T0."Phone1" NOT LIKE_REGEXPR '^\+?[0-9]+$' THEN 2  -- Teléfono contiene caracteres no numéricos
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
	            WHEN LENGTH(T2."Code") = 3 THEN 2  -- Si el código tiene 3 caracteres (inhabilitado)hice cambio por el 3 
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
	        --MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck,
	 		MAX(CASE 
	            WHEN T0."QryGroup1" = 'Y' AND (T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '') THEN 1 -- Comercio exterior sin ID fiscal
	            ELSE 0 
	        END) AS IdFiscalCheck,
        
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
        
        
	    -- VALICACION DEL TIPO DEL NEGOCIO
		IF BP_EXISTS = 1 THEN
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
		    error_message := N'El número de teléfono debe contener el signo + y números.';
		END IF;
	
	
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
	       --error_message := N'El id fiscal federal unificado es requerido';
	       error_message := N'El ID fiscal es requerido para comercio exterior.';
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



