SELECT 
  T0."ItemCode", 
  T0."ItemName", 
  T0."CardCode", 
  T1."Code", 
  T1."Name", 
  T1."U_FIGU_SG3_IN", 
  T2."Code", 
  T2."Name", 
  T2."U_FIGU_SG4_IN" 
FROM "SBO_FIGURETTI_PRO"."OITM"  T0 
INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3"  T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code" 
INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4"  T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
WHERE
  TO_NVARCHAR(T1."U_FIGU_SG3_IN") = 'Y' OR
  TO_NVARCHAR(T2."U_FIGU_SG4_IN") = 'Y'
  /*TO_NVARCHAR(T1."U_FIGU_SG3_IN") IS NULL OR
  TO_NVARCHAR(T2."U_FIGU_SG4_IN") IS NULL*/
LIMIT 10

/* codigo original de datos maestro de articulos  */

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

--Variables Datos de maestro de articulos
CODCLAS NVARCHAR(15);
UNMED NVARCHAR(15);
TYPE_ITEM NVARCHAR(2);
IS_SELL_ITEM NVARCHAR(1);
ITEM_CODE NVARCHAR(50);  
UGPENTRY INT;
SAL_UNIT_MSR_VALID INT;
INVNTRY_UOM_VALID INT;


 
BEGIN

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
END;

/* Esto es EMP */
/* limitar los grupos 3 y 4 que esten inactivos */
CREATE PROCEDURE SBO_SP_TransactionNotification_CLIENT
(
    in object_type nvarchar(30),              -- SBO Object Type
    in transaction_type nchar(1),             -- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
    in num_of_cols_in_key int,
    in list_of_key_cols_tab_del nvarchar(255),
    in list_of_cols_val_tab_del nvarchar(255), 
    -- Return values
    out error int,                             -- Result (0 for no error)
    out error_message nvarchar (200)          -- Error string to be displayed
)
LANGUAGE SQLSCRIPT
AS

-- Variables Datos de maestro de articulos
CODCLAS NVARCHAR(15);
UNMED NVARCHAR(15);
TYPE_ITEM NVARCHAR(2);
IS_SELL_ITEM NVARCHAR(1);
ITEM_CODE NVARCHAR(50);  
UGPENTRY INT;
SAL_UNIT_MSR_VALID INT;
INVNTRY_UOM_VALID INT;
SG3_INACTIVO NVARCHAR(1);
SG4_INACTIVO NVARCHAR(1);

BEGIN

    -- Maestro de Artículo
    IF :object_type = '4' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
        SELECT 
            T0."NCMCode", 
            T0."SalUnitMsr", 
            T0."ItemType",
            T0."SellItem",  
            T0."ItemCode",  
            T0."UgpEntry",  
            CASE 
                WHEN T0."SellItem" = 'Y' AND T0."SalUnitMsr" IS NULL OR T0."SalUnitMsr" = '' THEN 1 
                WHEN T0."SellItem" = 'Y' AND T0."SalUnitMsr" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT') THEN 2 
                ELSE 0 
            END AS SalUnitMsrCheck,
            CASE 
                WHEN T0."SellItem" = 'Y' AND T0."InvntryUom" IS NULL OR T0."InvntryUom" = '' THEN 1 
                WHEN T0."SellItem" = 'Y' AND T0."InvntryUom" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT') THEN 2 
                ELSE 0 
            END AS InvntryUomCheck,
            T1."U_FIGU_SG3_IN",  
            T2."U_FIGU_SG4_IN"
        INTO 
            CODCLAS, UNMED, TYPE_ITEM, 
            IS_SELL_ITEM, ITEM_CODE, UGPENTRY, 
            SAL_UNIT_MSR_VALID, INVNTRY_UOM_VALID,
            SG3_INACTIVO, SG4_INACTIVO
        FROM "OITM" T0 
        LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
        LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
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

            IF (:IS_SELL_ITEM = 'Y') THEN
                IF (LEFT(:ITEM_CODE, 2) IN ('01', '03', '04', '07') AND (:UGPENTRY = '-1')) THEN
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

             -- Validación de inactividad en grupos
            IF (:SG3_INACTIVO = 'Y') THEN
                error := 8;  
                error_message := N'Error: El grupo 3 se encuentra inactivo.';
            END IF;

            IF (:SG4_INACTIVO = 'Y') THEN
                error := 8;  
                error_message := N'Error: El grupo 4 se encuentra inactivo.';
            END IF;

        END IF;
    END IF;
END;

/* esto seria pruebas productivo */
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


SG3_INACTIVO NVARCHAR(1);
--SG4_INACTIVO NVARCHAR(1);



BEGIN

--Artículos, validación campos obligatorios al crear o actualizar un artículo
IF :object_type = '4' AND ( :transaction_type = 'A' OR :transaction_type = 'U') THEN
	SELECT 
        T0."U_SYP_PESOBRUTO", T0."CardCode", T0."U_SYP_GRUPO", T0."U_SYP_SUBGRUPO1", T0."U_SYP_SUBGRUPO2",
        T0."U_SYP_SUBGRUPO3", T0."U_SYP_SUBGRUPO4", T0."U_beas_me_verbr", T0."U_SYP_CLIENTE",
        T0."U_SYP_ETIQT_IMP", T0."ItemType", T0."ItemCode", T0."U_LAB_SIS_FABRIC",
        T1."U_Activo"

	INTO PESOBRUTO, PROVEEDOR, GRUPO, SG1, SG2, 
        SG3, SG4, UNBEAS, CLIENTE, ETIQUETA, 
        TYPE_ITEM, CODIGO_ITEM, TIPO_FABRICACION,
        SG3_INACTIVO --, SG4_INACTIVO

	FROM "OITM" T0
    LEFT JOIN "SBO_FIGURETTI_20240531"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
    --LEFT JOIN "SBO_FIGURETTI_20240531"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code" 
    WHERE T0."ItemCode" = :list_of_cols_val_tab_del;

	IF TYPE_ITEM = 'I' THEN
		IF (:PESOBRUTO <= 0 OR :PESOBRUTO IS NULL) THEN
			error := 1;
			error_message := N'DPE: Debe Ingresar el campo peso bruto del artículo mayor a 0';
		END IF;
		IF :PROVEEDOR IS NULL THEN
			error := 2;
			error_message := N'DPE: Debe Ingresar el campo proveedor en datos de compra';
		END IF;
		IF :GRUPO IS NULL OR :SG1 IS NULL OR :SG2 IS NULL OR :SG3 IS NULL OR :SG4 IS NULL THEN
			error := 3;
			error_message := N'DPE: Debe Ingresar el campo Grupo o Subgrupo del artículo';
		END IF;
		IF (:UNBEAS IS NULL) THEN
			error := 4;
			error_message := N'DPE: Debe Ingresar la unidad meidida de BEAS campo Mengeneinheit Verbrauch';
		END IF;
		IF (:CLIENTE IS NULL) THEN
			error := 5;
			error_message := N'DPE: Debe Ingresar el campo cliente';
		END IF;
	END IF;

	IF :CODIGO_ITEM LIKE '07%' AND :TIPO_FABRICACION = 'NA' THEN
		error := 1;
		error_message := N'DPE: Productos terminados debe colocar Sistema de Fabricacion';
	END IF;

    IF (:SG3_INACTIVO = 'Y') THEN
        error := 2;  
        error_message := N'Error: El grupo 3 se encuentra inactivo.';
    END IF;
	--IF (:ETIQUETA IS NULL) THEN
		--error := 6;
		--error_message := N'EPM: Debe Ingresar el campo Etiqueta a imprimir';
	--END IF;
END IF;


END;
/* este seria productivo */

