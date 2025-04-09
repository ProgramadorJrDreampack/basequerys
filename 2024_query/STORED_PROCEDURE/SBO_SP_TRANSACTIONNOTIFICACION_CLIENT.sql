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
DECLA NVARCHAR(20);
ITEM NVARCHAR(13);
ABSENTRY NVARCHAR(10);
POS NVARCHAR(2);
ALMACEN NVARCHAR(7);
OT NVARCHAR(10);

PESOBRUTO DECIMAL;
PROVEEDOR NVARCHAR(50);
GRUPO NVARCHAR(5); 
SG1 NVARCHAR(5); 
SG2 NVARCHAR(5); 
SG3 NVARCHAR(5);  
SG4 NVARCHAR(5); 
UNBEAS NVARCHAR(20);
CLIENTE NVARCHAR(50);
ETIQUETA INT;
TIPO_COMPRA NVARCHAR(5);
MTV_COMPRA NVARCHAR(6);
CARPIMP NVARCHAR(5);
TEMBAR NVARCHAR(10);
TIMPO NVARCHAR(10);
PUERTOO NVARCHAR(20);
PUERTOD NVARCHAR(20);
REGIMEN NVARCHAR(2);
NRODAU NVARCHAR(20);
FEMBAR DATE;
FLLPUERTO DATE;
FDESADUANA DATE;
TCONTEN NVARCHAR(10);
NROLIQIMP NVARCHAR(20);
FOB DECIMAL;
CIF DECIMAL;
FODINFA DECIMAL;
IVA_DAU DECIMAL;
COMEX_CCI NVARCHAR(10);
COMEX_REF_PG NVARCHAR(50);
DEST_MP NVARCHAR(10);
USR INT;
USRSM INT;
TYPE_ITEM NVARCHAR(2);
STATUS NVARCHAR(10);
BLOQ NVARCHAR(15);
DESDE NVARCHAR(8);
HASTA NVARCHAR(8);
DATE1 DATE;
DATE2 DATE;
PRICE INT;
PRICE2 INT;
BODEGA NVARCHAR(6);
BODEGA98 NVARCHAR(6);
BODEGA99 NVARCHAR(6);
PRICESM INT;
PRICE2SM INT;
BODEGASM NVARCHAR(6);
BODEGA98SM NVARCHAR(6);
BODEGA99SM NVARCHAR(6);
CODIGO_ITEM NVARCHAR(15);
TIPO_FABRICACION NVARCHAR(5);
MOT_TRASL INT;
IVA12 INT;
ERR_ENT INT;
MOTIVO NVARCHAR(3);

BEGIN
--=======================================================================================
-- STORE PROCEDURE PARA QUE EL AREA DE TI DE LA EMPRESA AGREGUE SUS PROPIAS VALIDACIONES
--=======================================================================================

--ENTRADA DE MERCANCIAS PARA PROCESO FSC
IF :object_type = '59' AND ( :transaction_type = 'A' OR :transaction_type = 'U') THEN
		--DOCUMENTO ACTUAL
		/*SELECT T0."DocNum", T0."DocEntry", T1."ItemCode", T1."U_beas_belposid", T1."U_beas_belnrid", T1."WhsCode", T4."AbsEntry"
		INTO DOCNUM,DOCENTRY,ITEM,POS,OT,ALMACEN,ABSENTRY
		FROM "OIGN" T0
		INNER JOIN "IGN1" T1 ON T1."DocEntry" = T0."DocEntry"  
		INNER JOIN "OITL" T2 ON T0."DocEntry" = T2."DocEntry" AND T2."DocNum" = T0."DocNum"
		INNER JOIN "ITL1" T3 ON T3."LogEntry" = T2."LogEntry"
		INNER JOIN "OBTN" T4 ON T4."ItemCode" = T3."ItemCode" and T3."MdAbsEntry" = T4."AbsEntry"
		WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
		
		IF :ALMACEN = '04FPDP' THEN
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
		END IF;
		*/

END IF;

--Artículos, validación campos obligatorios al crear o actualizar un artículo
IF :object_type = '4' AND ( :transaction_type = 'A' OR :transaction_type = 'U') THEN
	SELECT T0."U_SYP_PESOBRUTO", T0."CardCode", T0."U_SYP_GRUPO", T0."U_SYP_SUBGRUPO1", T0."U_SYP_SUBGRUPO2",
			T0."U_SYP_SUBGRUPO3", T0."U_SYP_SUBGRUPO4", T0."U_beas_me_verbr", T0."U_SYP_CLIENTE",
			T0."U_SYP_ETIQT_IMP", T0."ItemType", T0."ItemCode", T0."U_LAB_SIS_FABRIC"
	INTO PESOBRUTO, PROVEEDOR, GRUPO, SG1, SG2, SG3, SG4, UNBEAS, CLIENTE, ETIQUETA, TYPE_ITEM, CODIGO_ITEM, TIPO_FABRICACION
	FROM "OITM" T0 WHERE T0."ItemCode" = :list_of_cols_val_tab_del;
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
	--IF (:ETIQUETA IS NULL) THEN
		--error := 6;
		--error_message := N'EPM: Debe Ingresar el campo Etiqueta a imprimir';
	--END IF;
END IF;

--Pedido CREAR, validación campos obligatorios al crear un artículo

IF :object_type = '22' AND ( :transaction_type = 'A') THEN
	SELECT T0."U_SYP_TIPCOMPRA", T0."U_SYP_MTVCOMP", T0."U_SYP_CARPIMP", T0."U_SYP_TEMBAR", T0."U_SYP_TIMPO",
	T0."U_DEST_MP", T0."U_STTS_ORDEN_MPI", T0."DocDate"
	INTO 
	TIPO_COMPRA, MTV_COMPRA, CARPIMP, TEMBAR, TIMPO, DEST_MP, STATUS, DATE1
	FROM OPOR T0
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO IVA12
	FROM POR1 T0
	WHERE T0."TaxCode" IN ('IVA_12', 'IVA_GS12') AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	--Si el articulo lleva IVA_12
	IF (DATE1 >= '2024-04-01') THEN
		IF (IVA12 > 0) THEN
			error := 1001;
			error_message := N'DPE: No puede ingresar IVA_12';
		END IF;
	END IF;
	
	--Si el tipo de compra es importada aplicar validacion
	IF (TIPO_COMPRA = '02') THEN
		IF (MTV_COMPRA IS NULL) THEN
			error := 6;
			error_message := N'DPE: Debe Ingresar el motivo de compra';
		ELSEIF (CARPIMP IS NULL) THEN
			error := 7;
			error_message := N'DPE: Debe Ingresar el Nro de Carpeta de Importación (Seleccione la lupa)';
		ELSEIF (TEMBAR IS NULL) THEN
			error := 8;
			error_message := N'DPE: Debe Ingresar el Tipo de Embarque';
		ELSEIF (TIMPO = '0') THEN
			error := 9;
			error_message := N'DPE: Debe Ingresar el Término de Importación';
		ELSEIF (DEST_MP = '0') THEN
			error := 10;
			error_message := N'DPE: Debe Ingresar el Campo Destino de Materia Prima';
		ELSEIF (STATUS = '0') THEN
			error := 11;
			error_message := N'DPE: Debe Ingresar el Status de Orden de Materia Prima';
		END IF;
	END IF;
END IF;
--Pedido ACTUALIZAR, validación campos obligatorios al actualizar un artículo
IF :object_type = '22' AND ( :transaction_type = 'U') THEN
	SELECT T0."U_SYP_TIPCOMPRA", T0."U_SYP_MTVCOMP", T0."U_SYP_CARPIMP", T0."U_SYP_TEMBAR", T0."U_SYP_TIMPO",
	T0."U_SYP_PUERTOO", T0."U_SYP_PUERTOD", T0."U_SYP_REGIMEN", T0."U_SYP_NRDAU", T0."U_SYP_MDFE", 
	T0."U_SYP_FLLMERC", T0."U_SYP_FDESADUANA", T0."U_SYP_CONTENEDRO", T0."U_SYP_NROLIQIMP", T0."U_SYP_DUI_FOB",
	T0."U_SYP_DUI_CIF", T0."U_SYP_DUI_FONDINFA", T0."U_SYP_IVA_DAU", T0."U_COMEX_CCI", T0."U_COMEX_REF_PG",
	T0."U_DEST_MP", T0."U_STTS_ORDEN_MPI"
	INTO 
	TIPO_COMPRA, MTV_COMPRA, CARPIMP, TEMBAR, TIMPO, PUERTOO, PUERTOD, REGIMEN, NRODAU, FEMBAR, FLLPUERTO, FDESADUANA,
	TCONTEN, NROLIQIMP, FOB, CIF, FODINFA, IVA_DAU, COMEX_CCI, COMEX_REF_PG, DEST_MP, STATUS
	FROM OPOR T0
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
--Si el tipo de compra es importada aplicar validacion
	IF (TIPO_COMPRA = '02') THEN
		IF (MTV_COMPRA IS NULL) THEN
			error := 6;
			error_message := N'DPE: Debe Ingresar el motivo de compra';
		ELSEIF (CARPIMP IS NULL) THEN
			error := 7;
			error_message := N'DPE: Debe Ingresar el Nro de Carpeta de Importación (Seleccione la lupa)';
		ELSEIF (TEMBAR IS NULL) THEN
			error := 8;
			error_message := N'DPE: Debe Ingresar el Tipo de Embarque';
		ELSEIF (TIMPO = '0') THEN
			error := 9;
			error_message := N'DPE: Debe Ingresar el Término de Importación';
		ELSEIF (PUERTOO = '') THEN
			error := 10;
			error_message := N'DPE: Debe Ingresar el Puerto Origen';
		ELSEIF (PUERTOD = '') THEN
			error := 11;
			error_message := N'DPE: Debe Ingresar el Puerto Destino';
		ELSEIF (REGIMEN IS NULL) THEN
			error := 12;
			error_message := N'DPE: Debe Ingresar el Régimen de Importación';
		ELSEIF (FEMBAR IS NULL) THEN
			error := 14;
			error_message := N'DPE: Debe Ingresar la Fecha de Embarque';
		ELSEIF (FLLPUERTO IS NULL) THEN
			error := 15;
			error_message := N'DPE: Debe Ingresar la Fecha de llegada a Puerto';
		ELSEIF (TCONTEN IS NULL) THEN
			error := 17;
			error_message := N'DPE: Debe Ingresar el Tipo de Contenedor';
		ELSEIF (COMEX_CCI = '0') THEN
			error := 23;
			error_message := N'DPE: Debe Ingresar el campo CCI';
		ELSEIF (COMEX_REF_PG IS NULL AND COMEX_CCI = 'CCI') THEN
			error := 24;
			error_message := N'DPE: Debe Ingresar la Referencia de Pago';
		ELSEIF (DEST_MP = '0') THEN
			error := 25;
			error_message := N'DPE: Debe Ingresar el Campo Destino de Materia Prima';
		ELSEIF (STATUS = '0') THEN
			error := 11;
			error_message := N'DPE: Debe Ingresar el Status de Orden de Materia Prima';
		END IF;
		--Si se ingresa el Nro DAU validar los siguientes campos complementos
		IF (nrodau IS NOT NULL) THEN
			IF (FDESADUANA IS NULL) THEN
				error := 16;
				error_message := N'DPE: Debe Ingresar la Fecha de Desaduanización';
			ELSEIF (NROLIQIMP <= 0 OR NROLIQIMP IS NULL) THEN
				error := 18;
				error_message := N'DPE: Debe Ingresar el Número de Liquidación de Importación';
			ELSEIF (FOB <= 0 OR NROLIQIMP IS NULL) THEN
				error := 19;
				error_message := N'DPE: Debe Ingresar el campo FOB';
			ELSEIF (CIF <= 0 OR NROLIQIMP IS NULL) THEN
				error := 20;
				error_message := N'DPE: Debe Ingresar el campo CIF';
			ELSEIF (FODINFA <= 0 OR NROLIQIMP IS NULL) THEN
				error := 21;
				error_message := N'DPE: Debe Ingresar el campo FODINFA';
			ELSEIF (IVA_DAU <= 0 OR NROLIQIMP IS NULL) THEN
				error := 22;
				error_message := N'DPE: Debe Ingresar el IVA DAU';
			END IF;
		END IF;
	END IF;
	
END IF;

--Pedido Entrada de Mercancía ACTUALIZAR, validación campos obligatorios al actualizar solo equipo COMEX permitidos
IF :object_type = '20' AND ( :transaction_type = 'U') THEN
	SELECT T0."U_SYP_TIPCOMPRA", T0."U_SYP_NRDAU", T0."U_SYP_FDESADUANA"
	, T0."U_SYP_NROLIQIMP", T0."U_SYP_DUI_FOB", T0."U_SYP_DUI_CIF", T0."U_SYP_DUI_FONDINFA"
	, T0."U_SYP_IVA_DAU",	T0."U_DEST_MP" , T0."UserSign2"
	INTO 
	TIPO_COMPRA, NRODAU, FDESADUANA, NROLIQIMP, FOB, CIF, FODINFA, IVA_DAU, DEST_MP, USR
	FROM OPDN T0
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO BODEGA98
	FROM PDN1 T0
	WHERE T0."WhsCode" = '98' AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO BODEGA99
	FROM PDN1 T0
	WHERE T0."WhsCode" = '99' AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO BODEGA
	FROM PDN1 T0
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO PRICE
	FROM PDN1 T0
	WHERE (T0."Price" != 0) AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO PRICE2
	FROM PDN1 T0
	WHERE (T0."Price" = 0 OR T0."Price" IS NULL) AND T0."DocEntry" = :list_of_cols_val_tab_del;

	--Si el tipo de compra es importada y los usuarios son de COMEX aplicar validacion
	IF (BODEGA = BODEGA98) THEN 
  		IF (:USR NOT IN (1,43,72,147)) THEN --NO ES USUARIO COMEX
			error := 2009;
			error_message := N'DPE: Solo usuarios comex permitidos';
		ELSE -- SON USUARIOS COMEX
			IF (:PRICE > 0) THEN--PRECIO NO PERMITIDO EN BODEGA 98
				error := 2009;
				error_message := N'DPE: No esta permitido precio en bodega 98';
			END IF;
		END IF;
	ELSEIF (BODEGA = BODEGA99) THEN 
  		IF (:PRICE2 = 0) THEN--PRECIO OBLIGATORIO EN BODEGA 99
			error := 2009;
			error_message := N'DPE: Debe ingresar un precio en bodega 99';
		END IF;
	ELSE 
  		IF (BODEGA98 > 0 OR BODEGA99 > 0) THEN
        		error := 2009;
			error_message := N'DPE: No puede ingresar bodegas de importación';
		ELSE
    			IF (:PRICE2 = 0) THEN--PRECIO OBLIGATORIO EN BODEGAS LOCALES
				error := 2009;
				error_message := N'DPE: Debe ingresar un precio en bodegas locales';
    			END IF;
  		END IF;
	END IF;
	IF (:TIPO_COMPRA = '02') THEN
		IF (:USR IN (1,43,72,147)) THEN
			IF (NRODAU IS NULL OR NRODAU = '') THEN
				error := 2001;
				error_message := N'DPE: Debe Ingresar el Nro DAU';
			ELSEIF (FDESADUANA IS NULL) THEN
				error := 2002;
				error_message := N'DPE: Debe Ingresar la Fecha de Desaduanización';
			ELSEIF (NROLIQIMP <= 0) THEN
				error := 2003;
				error_message := N'DPE: Debe Ingresar el Número de Liquidación de Importación';
			ELSEIF (FOB <= 0) THEN
				error := 2004;
				error_message := N'DPE: Debe Ingresar el campo FOB';
			ELSEIF (CIF <= 0) THEN
				error := 2005;
				error_message := N'DPE: Debe Ingresar el campo CIF';
			ELSEIF (FODINFA <= 0) THEN
				error := 2006;
				error_message := N'DPE: Debe Ingresar el campo FODINFA';
			ELSEIF (IVA_DAU <= 0) THEN
				error := 2007;
				error_message := N'DPE: Debe Ingresar el IVA DAU';
			ELSEIF (DEST_MP = '0') THEN
				error := 2008;
				error_message := N'DPE: Debe Ingresar el Campo Destino de Materia Prima';
			END IF;
		ELSE			
			error := 2000;
			error_message := N'DPE: Solo usuarios COMEX pueden actualizar PEM de Importación';
		END IF;
		/*IF (USR IS NULL) THEN
		 	error := 2000;
			error_message := N'DPE: Debe actualizar la fecha de Desaduanización';
		END IF;*/
	END IF;
END IF;

-- 20 validacion de entrada de mercancia para crear
IF :object_type = '20' AND ( :transaction_type = 'A') THEN
--PRICE := 0;
	SELECT T0."DocDate"
	INTO 
	DATE1
	FROM OPDN T0
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO BODEGA98
	FROM PDN1 T0
	WHERE T0."WhsCode" = '98' AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO BODEGA99
	FROM PDN1 T0
	WHERE T0."WhsCode" = '99' AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO BODEGA
	FROM PDN1 T0
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT T0."UserSign2"
	INTO USR
	FROM OPDN T0
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO PRICE
	FROM PDN1 T0
	WHERE (T0."Price" != 0) AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO PRICE2
	FROM PDN1 T0
	WHERE (T0."Price" = 0 OR T0."Price" IS NULL) AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO IVA12
	FROM PDN1 T0
	WHERE T0."TaxCode" IN ('IVA_12', 'IVA_GS12') AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	--Valida que no sea IVA_12
	IF (DATE1 >= '2024-04-01') THEN
		IF (IVA12 > 0) THEN
			error := 1001;
			error_message := N'DPE: No puede ingresar IVA_12';
		END IF;
	END IF;
	
		IF (BODEGA = BODEGA98) THEN 
  			IF (:USR NOT IN (1,43,72,147)) THEN --NO ES USUARIO COMEX
				error := 2009;
				error_message := N'DPE: Solo usuarios comex permitidos';
			ELSE -- SON USUARIOS COMEX
				IF (:PRICE > 0) THEN--PRECIO NO PERMITIDO EN BODEGA 98
					error := 2009;
					error_message := N'DPE: No esta permitido precio en bodega 98';
				END IF;
			END IF;
		ELSEIF (BODEGA = BODEGA99) THEN 
  			IF (:PRICE2 > 0) THEN--PRECIO NO PERMITIDO EN BODEGA 98
				error := 2009;
				error_message := N'DPE: Debe ingresar un precio en bodega 99';
			END IF;
		ELSE 
  			IF (BODEGA98 > 0 OR BODEGA99 > 0) THEN
        		error := 2009;
				error_message := N'DPE: No puede ingresar bodegas de importación';
			ELSE
    			IF (:PRICE2 > 0) THEN--PRECIO NO PERMITIDO EN BODEGA 98
					error := 2009;
					error_message := N'DPE: Debe ingresar un precio en bodegas locales';
    			END IF;
  			END IF;
		END IF;
END IF;

-- 60 Salida de mercancia
IF :object_type = '60' AND ( :transaction_type = 'A') THEN
--PRICE := 0;
	SELECT COALESCE(COUNT(*), 0)
	INTO BODEGA98SM
	FROM IGE1 T0
	WHERE T0."WhsCode" = '98' AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO BODEGA99SM
	FROM IGE1 T0
	WHERE T0."WhsCode" = '99' AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO BODEGASM
	FROM IGE1 T0
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT T0."UserSign2"
	INTO USRSM
	FROM OIGE T0
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO PRICESM
	FROM IGE1 T0
	WHERE (T0."Price" != 0) AND T0."DocEntry" = :list_of_cols_val_tab_del;
	                                                                                                                                                                                                    
	SELECT COALESCE(COUNT(*), 0)
	INTO PRICE2SM
	FROM IGE1 T0
	WHERE (T0."Price" = 0 OR T0."Price" IS NULL) AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	IF (BODEGASM = BODEGA98SM) THEN 
  		IF (:USRSM NOT IN (1,43,72,147)) THEN --NO ES USUARIO COMEX
			error := 2009;
			error_message := N'DPE: Solo usuarios comex permitidos';
		ELSE -- SON USUARIOS COMEX
			IF (:PRICESM > 0) THEN--PRECIO NO PERMITIDO EN BODEGA 98
				error := 2009;
				error_message := N'DPE: No esta permitido precio en bodega 98';
			END IF;
		END IF;
	ELSEIF (BODEGASM = BODEGA99SM) THEN 
  		IF (:PRICE2SM > 0) THEN--PRECIO NO PERMITIDO EN BODEGA 98
			error := 2009;
			error_message := N'DPE: Debe ingresar un precio en bodega 99';
		END IF;
	ELSE 
  		IF (BODEGA98SM > 0 OR BODEGA99SM > 0) THEN
        		error := 2009;
			error_message := N'DPE: No puede ingresar bodegas de importación';
		/*ELSE
    			IF (:PRICE2SM > 0) THEN--PRECIO NO PERMITIDO EN BODEGA 98
				error := 2009;
				error_message := N'DPE: Debe ingresar un precio en bodegas locales';
    			END IF;*/
  		END IF;
	END IF;
END IF;

--Transferencia de STOCK limitar a producción a solo las bodegas autorizadas
IF :object_type = '67' AND ( :transaction_type = 'A' OR :transaction_type = 'U') THEN
	SELECT T0."Filler", T0."ToWhsCode", T1."U_BLOQ_BOD_PROD"
	INTO DESDE, HASTA, BLOQ
	FROM OWTR T0
	INNER JOIN OUSR T1 ON T0."UserSign" = T1."USERID"
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	IF (:BLOQ = 'SI') THEN
		IF NOT (:DESDE LIKE '04%' OR :DESDE LIKE '06%') THEN
			error := 1;
			error_message := N'DPE: No tienes permisos para transferir desde bodegas no autorizadas, solo producción 04 - 06';
		END IF;
		IF NOT (:HASTA LIKE '04%' OR :HASTA LIKE '06%') THEN
			error := 2;
			error_message := N'DPE: No tienes permisos para transferir a bodegas no autorizadas, solo producción 04 - 06';
		END IF;
	END IF;
	IF (:HASTA IN ('11PCD', '12PCD')) THEN
		SELECT COALESCE(COUNT(T0."U_SYP_OBS_ITEM"), 0) 
		INTO MOT_TRASL
		FROM WTR1 T0
		WHERE (T0."U_SYP_OBS_ITEM" IS NULL OR T0."U_SYP_OBS_ITEM" = 0) AND T0."DocEntry" = :list_of_cols_val_tab_del;
		IF MOT_TRASL > 0 THEN
			error := 1;
			error_message := N'DPE: Debe ingresar el motivo del traslado por cada item';
		END IF;
	END IF;
END IF;

--Ordenes de venta ADD and UPD
--Se valida que la fecha de contabilización sea mayor que la fecha de entrega
IF :object_type = '17' AND ( :transaction_type = 'A' OR :transaction_type = 'U') THEN
	SELECT T0."DocDate", T0."DocDueDate", T0."U_ERR_ENTR", CAST(LEFT(T0."U_MOT_ERR_ENTR", 1) AS INT)
	INTO DATE1,DATE2, ERR_ENT, MOTIVO
	FROM ORDR T0 
	WHERE T0."DocEntry" = list_of_cols_val_tab_del;
	
	--VALIDA QUE NO HAYA IVA_12
	SELECT COALESCE(COUNT(*), 0)
	INTO IVA12
	FROM RDR1 T0
	WHERE T0."TaxCode" IN ('IVA_12', 'IVA_GS12') AND T0."DocEntry" = :list_of_cols_val_tab_del;

	IF (DATE1 >= '2024-04-01') THEN
		IF (IVA12 > 0) THEN
			error := 1001;
			error_message := N'DPE: No puede ingresar IVA_12';
		END IF;
	END IF;
	
	IF (:DATE1 > :DATE2) THEN
		error := 1002;
		error_message:= N'DPE: La fecha de entrega no puede ser menor a la fecha de contabilización';
	END IF;
	
	-- VALIDA QUE SE COLOQUE BIEN LOS ERRORES DE ENTREGA
	IF ((:ERR_ENT + :MOTIVO) > 0)  THEN
		IF ((:ERR_ENT = 1 ) AND (:ERR_ENT != :MOTIVO)) THEN
			error := 1002;
			error_message:= N'DPE: Debe seleccionar un motivo de error de entrega interno';
		END IF;
		IF ((:ERR_ENT = 2 ) AND (:ERR_ENT != :MOTIVO)) THEN
			error := 1003;
			error_message:= N'DPE: Debe seleccionar un motivo de error de entrega externo';
		END IF;
		IF (:ERR_ENT = 0) THEN
			error := 1004;
			error_message:= N'DPE: Debe seleccionar el error de entrega';
		END IF;
	END IF;
	
END IF;

--FACTURA DE DEUDORES
IF :object_type = '13' AND ( :transaction_type = 'A') THEN
	SELECT T0."DocDate" 
	INTO DATE1
	FROM OINV T0 
	WHERE T0."DocEntry" = list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO IVA12
	FROM INV1 T0
	WHERE T0."TaxCode" IN ('IVA_12', 'IVA_GS12') AND T0."DocEntry" = :list_of_cols_val_tab_del;

	IF (DATE1 >= '2024-04-01') THEN
		IF (IVA12 > 0) THEN
			error := 1001;
			error_message := N'DPE: No puede ingresar IVA_12';
		END IF;
	END IF;
END IF;

--ENTREGA
IF :object_type = '15' AND ( :transaction_type = 'A') THEN
	SELECT T0."DocDate" 
	INTO DATE1
	FROM ODLN T0 
	WHERE T0."DocEntry" = list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO IVA12
	FROM DLN1 T0
	WHERE T0."TaxCode" IN ('IVA_12', 'IVA_GS12') AND T0."DocEntry" = :list_of_cols_val_tab_del;

	IF (DATE1 >= '2024-04-01') THEN
		IF (IVA12 > 0) THEN
			error := 1001;
			error_message := N'DPE: No puede ingresar IVA_12';
		END IF;
	END IF;
END IF;

--FACTURA DE PROVEEDORES
IF :object_type = '18' AND ( :transaction_type = 'A') THEN
	SELECT T0."DocDate" 
	INTO DATE1
	FROM OPCH T0 
	WHERE T0."DocEntry" = list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO IVA12
	FROM PCH1 T0
	WHERE T0."TaxCode" IN ('IVA_12', 'IVA_GS12') AND T0."DocEntry" = :list_of_cols_val_tab_del;

	IF (DATE1 >= '2024-04-01') THEN
		IF (IVA12 > 0) THEN
			error := 1001;
			error_message := N'DPE: No puede ingresar IVA_12';
		END IF;
	END IF;
END IF;

-- 59 validacion de Entrada de mercancia para crear
IF :object_type = '59' AND ( :transaction_type = 'A') THEN
--PRICE := 0;
	SELECT T0."DocDate"
	INTO 
	DATE1
	FROM OIGN T0
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;

	SELECT COALESCE(COUNT(*), 0)
	INTO BODEGA98
	FROM IGN1 T0
	WHERE T0."WhsCode" = '98' AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO BODEGA99
	FROM IGN1 T0
	WHERE T0."WhsCode" = '99' AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO BODEGA
	FROM IGN1 T0
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT T0."UserSign2"
	INTO USR
	FROM OIGN T0
	WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO PRICE
	FROM IGN1 T0
	WHERE (T0."Price" != 0) AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO PRICE2
	FROM IGN1 T0
	WHERE (T0."Price" = 0 OR T0."Price" IS NULL) AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	SELECT COALESCE(COUNT(*), 0)
	INTO IVA12
	FROM IGN1 T0
	WHERE T0."TaxCode" IN ('IVA_12', 'IVA_GS12') AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
	--Valida que no sea IVA_12
	IF (DATE1 >= '2024-04-01') THEN
		IF (IVA12 > 0) THEN
			error := 1001;
			error_message := N'DPE: No puede ingresar IVA_12';
		END IF;
	END IF;
	
		IF (BODEGA = BODEGA98) THEN 
  			IF (:USR NOT IN (1,43,72,147)) THEN --NO ES USUARIO COMEX
				error := 2009;
				error_message := N'DPE: Solo usuarios comex permitidos';
			ELSE -- SON USUARIOS COMEX
				IF (:PRICE > 0) THEN--PRECIO NO PERMITIDO EN BODEGA 98
					error := 2009;
					error_message := N'DPE: No esta permitido precio en bodega 98';
				END IF;
			END IF;
		ELSEIF (BODEGA = BODEGA99) THEN 
  			IF (:PRICE2 > 0) THEN--PRECIO OBLIGATORIO EN BODEGA 99
				error := 2009;
				error_message := N'DPE: Debe ingresar un precio en bodega 99';
			END IF;
		ELSE 
  			IF (BODEGA98 > 0 OR BODEGA99 > 0) THEN
        		error := 2009;
				error_message := N'DPE: No puede ingresar bodegas de importación';
			ELSE
    			IF (:PRICE2 > 0) THEN--PRECIO OBLIGATORIO EN BODEGAS LOCALES
					error := 2009;
					error_message := N'DPE: Debe ingresar un precio en bodegas locales';
    			END IF;
  			END IF;
		END IF;
END IF;

END;
