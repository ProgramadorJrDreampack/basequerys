
/* vistas calculadas */
CREATE PROCEDURE SYP_SP_CONS_FORMATO_PT (
	 IN ot nvarchar(20),
	 IN pos nvarchar(20),
	 IN tipo nvarchar(20),
	 IN desde int,
	 IN hasta int
     )LANGUAGE SQLSCRIPT
AS
BEGIN
DECLARE LDESDE INT;
DECLARE LHASTA INT;
DECLARE LCODE NVARCHAR(100);
IF :tipo = 'I' THEN
	SELECT PT."CodigoProducto"
			--,T0."U_SYP_CODE_SKU"
		  ,PT."Descripcion"
		  ,PT."Lote"
		  ,PT."EAN_13"
		  ,PT."EAN_14"
		  --,PT."CODIGO_128"
		  ,'(01)'||PT."EAN_14"||'(17)'||TO_VARCHAR(TO_DATE(PT."FechaCaducidad",'DD/MM/YYYY'),'YYMMDD')||'(10)'||PT."Lote" as "CODIGO_128"
		  ,PT."UxC"
		  ,PT."Operador"
		  ,PT."Caja"
		  ,PT."Cliente"
		  ,PT."FechaFabricacion"
		  ,PT."FechaCaducidad"
		  ,PT."DatValue1"
		  ,PT."DatValue2"
		  --,PT."DatValue3"
          ,LPAD((PT."BELNR_ID"||PT."BELPOS_ID"),7,'0') AS "DatValue3"
		  --,PT."DatValue4"
	      ,(select IFNULL(MAX(R.U_LAB_FSC_DECLA),'') from OBTN R WHERE R."DistNumber" = PT."Lote") AS "DatValue4"
		  ,PT."BELNR_ID"
		  ,PT."BELPOS_ID"
		  ,PT."OperadorUser"
		  ,PT."U_SYP_CLIENTE"
		  ,PT."NombreExtranjero"
		  ,PT."UxFundas"
		  ,PT."FxCarton"
		  ,PT."PesoNeto"
		  ,PT."UserText"
		  ,PT."CODE_128_COD" AS "Code128Barras"
		  ,'' AS "DatValue5"		  
		  ,PT.CODE128KFC AS "DatValue6"
		  ,PT.CODE128KFCCOD AS "DatValue7"
		  ,'' AS "DatValue8"
		  ,'' AS "DatValue9"
		  ,PT."LOTE_EXT"
	  FROM "SYP_ETIQUETAS_PT" PT 
	  --INNER JOIN OITM T0 ON PT."CodigoProducto" = T0."ItemCode"
	  -- INNER JOIN "OITM" O ON O."ItemCode" = PT."CodigoProducto"
	 WHERE "BELNR_ID" = :ot
	   AND "BELPOS_ID" = :pos
	   AND CAST(PT."Caja" AS INT) BETWEEN :desde AND :hasta;
ELSE

 IF :tipo LIKE 'F%' THEN
	SELECT SUBSTR(:TIPO,3) INTO LCODE FROM DUMMY;
	SELECT PT."CodigoProducto"
			--,T0."U_SYP_CODE_SKU"
		  ,PT."Descripcion"
		  ,PT."Lote"
		  ,PT."EAN_13"
		  ,PT."EAN_14"
		  --,PT."CODIGO_128"
		  ,'(01)'||PT."EAN_14"||'(17)'||TO_VARCHAR(TO_DATE(PT."FechaCaducidad",'DD/MM/YYYY'),'YYMMDD')||'(10)'||PT."Lote" as "CODIGO_128"
		  ,PT."UxFundas" as "UxC"
		  ,PT."Operador"
		  ,PT."Caja"
		  ,PT."Cliente"
		  ,PT."FechaFabricacion"
		  ,PT."FechaCaducidad"
		  ,PT."DatValue1"
		  ,PT."DatValue2"
		  --,PT."DatValue3"
          ,LPAD((PT."BELNR_ID"||PT."BELPOS_ID"),7,'0') AS "DatValue3"
		  --,PT."DatValue4"
		  ,(select IFNULL(MAX(R.U_LAB_FSC_DECLA),'') from OBTN R WHERE R."DistNumber" = PT."Lote") AS "DatValue4"
		  ,PT."BELNR_ID"
		  ,PT."BELPOS_ID"
		  ,PT."OperadorUser"
		  ,PT."U_SYP_CLIENTE"
		  ,PT."NombreExtranjero"
		  ,CAST(CAST(PT."ETIQUETAS" AS INT) AS NVARCHAR) AS "UxFundas"
		  ,PT."FxCarton"
		  ,PT."PesoNeto"
		  ,PT."UserText"
		  ,PT."CODE_128_COD" AS "Code128Barras"
		  ,CAST(CAST(PT."FxCarton" AS INT) AS NVARCHAR) AS "DatValue5"
		  ,PT.CODE128KFC AS "DatValue6"
		  ,PT.CODE128KFCCOD AS "DatValue7"
		  ,'' AS "DatValue8"
		  ,'' AS "DatValue9"
	  FROM "SYP_ETIQUETAS_FUNDAS" PT 
	  --INNER JOIN OITM T0 ON PT."CodigoProducto" = T0."ItemCode"
	 WHERE "BELNR_ID" = :ot
	   AND "BELPOS_ID" = :pos
	   AND CAST(PT."Caja" AS INT) BETWEEN :desde AND :hasta 
	   AND PT."CODE_ID" = :LCODE;
	   
	ELSE
	SELECT PT."CodigoProducto"
			--,T0."U_SYP_CODE_SKU"
		  ,PT."Descripcion"
		  ,PT."Lote"
		  ,PT."EAN_13"
		  ,PT."EAN_14"
		  --,PT."CODIGO_128"
		  ,'(01)'||PT."EAN_14"||'(17)'||TO_VARCHAR(TO_DATE(PT."FechaCaducidad",'DD/MM/YYYY'),'YYMMDD')||'(10)'||PT."Lote" as "CODIGO_128"
		  ,PT."UxC"
		  ,PT."Operador"
		  ,PT."Caja"
		  ,PT."Cliente"
		  ,PT."FechaFabricacion"
		  ,PT."FechaCaducidad"
		  ,PT."DatValue1"
		  ,PT."DatValue2"
		  --,PT."DatValue3"
          ,LPAD((PT."BELNR_ID"||PT."BELPOS_ID"),7,'0') AS "DatValue3"
		  --,PT."DatValue4"
		  ,(select IFNULL(MAX(R.U_LAB_FSC_DECLA),'') from OBTN R WHERE R."DistNumber" = PT."Lote") AS "DatValue4"
		  ,PT."BELNR_ID"
		  ,PT."BELPOS_ID"
		  ,PT."OperadorUser"
		  ,PT."U_SYP_CLIENTE"
		  ,PT."NombreExtranjero"
		  ,PT."UxFundas"
		  ,PT."FxCarton"
		  ,PT."PesoNeto"
		  ,PT."UserText"
		  ,PT."CODE_128_COD" AS "Code128Barras"
		  ,'' AS "DatValue5"
		  ,PT.CODE128KFC AS "DatValue6"
		  ,PT.CODE128KFCCOD AS "DatValue7"
		  ,'' AS "DatValue8"
		  ,'' AS "DatValue9"
		  ,PT."LOTE_EXT"
	  FROM "SYP_ETIQUETAS_PT" PT 
	  --INNER JOIN OITM T0 ON PT."CodigoProducto" = T0."ItemCode"
	 WHERE "BELNR_ID" = :ot
	   AND "BELPOS_ID" = :pos
	   AND CAST(PT."Caja" AS INT) BETWEEN :desde AND :hasta ;
	END IF;
END IF;
END ;


/* STORE PROCEDURE SYP_SPCONSULTA_OT_POR_FECHA */

CREATE PROCEDURE SYP_SP_CONSULTA_OT_POR_FECHA (
IN FECHA_INI DATE,
IN FECHA_FIN DATE
)LANGUAGE SQLSCRIPT
AS
BEGIN

SELECT OT."BELNR_ID" AS "OrdenProduccion"
       ,IFNULL(POS."BaseDocNum",0) AS "Pedido"
       ,IFNULL(PE."CardName",'ContraStock') AS "Cliente"
       ,POS."ItemCode"
       ,POS."ItemName"
       ,(SELECT MAX(MR."BEZ") AS "ResName"  FROM "BEAS_FTAPL" RS 
		 INNER JOIN "BEAS_APLATZ" MR ON MR."APLATZ_ID" = RS."APLATZ_ID"
		 WHERE RS."BELNR_ID" = OT."BELNR_ID" AND RS."BELPOS_ID" = POS."BELPOS_ID") AS "Maquina"
       ,POS."MENGE_VERBRAUCH" AS "CantidadPlanificada"
       ,IFNULL((SELECT TO_VARCHAR(MAX("CantidadReal")) FROM "SYP_DETALLE_NOTIFICACION" HF WHERE HF."DocEntry" = OT."BELNR_ID" AND HF."DocNum" = POS."BELPOS_ID" ),'') AS "CantidadReal"
       ,IFNULL(POS."ME_VERBRAUCH",'UN') AS "UnidadDeMedida"
       ,IFNULL((SELECT TO_VARCHAR(MAX("HoraInicio"),'YYYY/MM/DD HH:MI:SS') FROM "SYP_DETALLE_NOTIFICACION" HF WHERE HF."DocEntry" = OT."BELNR_ID" AND HF."DocNum" = POS."BELPOS_ID" ),'') AS "FechaInicioProceso"
	   ,IFNULL((SELECT TO_VARCHAR(MAX("HoraFin"),'YYYY/MM/DD HH:MI:SS') FROM "SYP_DETALLE_NOTIFICACION" HF WHERE HF."DocEntry" = OT."BELNR_ID" AND HF."DocNum" = POS."BELPOS_ID" ),'') AS "FechaFinProceso"
       ,U."U_SYP_APELLIDO"||' '||U."Name" AS "Operador", HR."Usuario"
       ,IFNULL((SELECT E."lastName"||' '||"firstName" AS "OPER" FROM "SYP_VW_OPER_ADD" F
		  INNER JOIN "OHEM" E ON E."empID" = F."empID" AND F."row_num" = 1 WHERE F."DocEntry" = OT."BELNR_ID" AND F."DocNum" = POS."BELPOS_ID" ),'N/A') AS "OperadorAdicional_1"
	   ,IFNULL((SELECT E."lastName"||' '||"firstName" AS "OPER" FROM "SYP_VW_OPER_ADD" F
		  INNER JOIN "OHEM" E ON E."empID" = F."empID" AND F."row_num" = 2 WHERE F."DocEntry" = OT."BELNR_ID" AND F."DocNum" = POS."BELPOS_ID"),'N/A') AS "OperadorAdicional_2"
	   ,IFNULL((SELECT E."lastName"||' '||"firstName" AS "OPER" FROM "SYP_VW_OPER_ADD" F
		  INNER JOIN "OHEM" E ON E."empID" = F."empID" AND F."row_num" = 3 WHERE F."DocEntry" = OT."BELNR_ID" AND F."DocNum" = POS."BELPOS_ID"),'N/A') AS "OperadorAdicional_3"
	   ,IFNULL((SELECT E."lastName"||' '||"firstName" AS "OPER" FROM "SYP_VW_OPER_ADD" F
		  INNER JOIN "OHEM" E ON E."empID" = F."empID" AND F."row_num" = 4 WHERE F."DocEntry" = OT."BELNR_ID" AND F."DocNum" = POS."BELPOS_ID"),'N/A') AS "OperadorAdicional_4"
from "BEAS_FTHAUPT" OT 
INNER JOIN "BEAS_FTPOS" POS ON POS."BELNR_ID" = OT."BELNR_ID" 
INNER JOIN "SYP_FECHAS_REALES_OF" HR ON HR."BELNR_ID" = OT."BELNR_ID" 
AND HR."BELPOS_ID" = POS."BELPOS_ID" 
INNER JOIN "@SYP_SWS_USUARIOS" U ON UPPER(U."U_SYP_USUARIO") = UPPER(HR."Usuario") 
LEFT JOIN "ORDR" PE ON PE."DocEntry" = POS."DocEntry"
WHERE HR."ESTADO" = 'O';



END;


/* SYP _SPFACTURAS_RETENCIONES */

CREATE PROCEDURE "SYP_SP_FACTURAS_RETENCIONES"(
  IN FECHA_INI DATETIME,
  IN FECHA_FIN DATETIME,
  OUT TMP SYP_TEMP_FAC_RET
	)
READS SQL DATA WITH RESULT VIEW SYP_SP_FACTURAS_RETENCIONES_VIEW  
AS
BEGIN
TMP = 	SELECT DISTINCT
	  ifnull(T."U_SYP_MDTD", '') AS "COD DOC",
	  (SELECT
	    "U_SYP_TDDD"
	  FROM "@SYP_TPODOC" C1
	  WHERE C1."Code" = T."U_SYP_MDTD")
	  AS "DESCRIP DOC",
	  T5."U_SYP_CODVTA" AS "TIP. IDENTF",
	  T2."LicTradNum" AS "IDENTIFICACION",
	  T2."CardName" AS "RAZON SOCIAL",
	  CASE
	    WHEN T5."U_SYP_CODVTA" = '07' THEN NULL
	    ELSE T2."U_SYP_PARTREL"
	  END AS "PARTE REL",
	  T2."U_SYP_TIPPROV" AS "TIP SUJETO",
	  'V' AS "TIP. ANEXO",
	  'A' AS "TIP. OPERAC",
	  CASE
	    WHEN ifnull(T4B."U_SYP_NDFE", '') = 'Y' THEN 'E'
	    ELSE 'F'
	 END "EMISION",
	  T."U_SYP_SERIESUC" AS "COD ESTAB",
	  T."U_SYP_MDSD" AS "PTO VTA",
	  T."U_SYP_MDCD" AS "SECUENC.",
	  ifnull(T."U_SYP_NROAUTO", '') AS "NRO AUTORIZACION",
	  CAST(T."DocDate" AS date) AS "FCHA EMISI.",
	  ifnull(CAST(T."U_SYP_FECHAUTOR" AS date), '') AS "FCHA AUTORIZACION",
	  0 AS "BASE %0",
	  CAST ('0.00' AS DECIMAL(19,2)) AS "BASE DIF%0 REEMB",
	  ifnull((SELECT
	    CAST(SUM("BaseSum") AS decimal(19, 2)) AS "Expr1"
	  FROM "INV4" X
	  INNER JOIN "INV1" X1
	    ON (X."DocEntry" = X1."DocEntry"
	    AND X."LineNum" = X1."LineNum")
	  WHERE X."DocEntry" = T."DocEntry"
	  AND "StaCode" IN (SELECT
	    "Code"
	  FROM "@SYP_IVA_FE_ATS"
	  WHERE "U_SYP_COLATS" LIKE '%baseImpGrav12%')), 0) AS "BASE %12",
	  ifnull((SELECT
	    CAST(SUM("BaseSum") AS decimal(19, 2)) AS "Expr1"
	  FROM "INV4" AS X
	  INNER JOIN "INV1" X1
	    ON (X."DocEntry" = X1."DocEntry"
	    AND X."LineNum" = X1."LineNum")
	  WHERE X."DocEntry" = T."DocEntry"
	  AND "StaCode" IN (SELECT
	    "Code"
	  FROM "@SYP_IVA_FE_ATS"
	  WHERE "U_SYP_COLATS" LIKE '%baseImpGrav14%')), 0) AS "BASE %14",
	  ifnull((SELECT
	    CAST(SUM("BaseSum") AS decimal(19, 2)) AS "Expr1"
	  FROM "INV4" AS X
	  INNER JOIN "INV1" X1
	    ON (X."DocEntry" = X1."DocEntry"
	    AND X."LineNum" = X1."LineNum")
	  WHERE X."DocEntry" = T."DocEntry"
	  AND "StaCode" IN (SELECT
	    "Code"
	  FROM "@SYP_IVA_FE_ATS"
	  WHERE "U_SYP_COLATS" = 'baseNoGraIva')), 0) AS "BASE NO OBJ",
	  1 AS "NO. COMPROBANTES",
	  ifnull((SELECT
	    CAST(SUM("TaxSum") AS decimal(19, 2)) AS "Expr1"
	  FROM "INV4" AS X
	  INNER JOIN "INV1" X1
	    ON (X."DocEntry" = X1."DocEntry"
	    AND X."LineNum" = X1."LineNum")
	  WHERE X."DocEntry" = T."DocEntry"
	  AND "StaCode" IN (SELECT
	    "Code"
	  FROM "@SYP_IVA_FE_ATS"
	  WHERE "U_SYP_COLATS" LIKE '%baseImpGrav12%')), 0) AS "MONTO IVA 12",
	  ifnull((SELECT
	    CAST(SUM("TaxSum") AS decimal(19, 2)) AS "Expr1"
	  FROM "INV4" AS X
	  INNER JOIN "INV1" X1
	    ON (X."DocEntry" = X1."DocEntry"
	    AND X."LineNum" = X1."LineNum")
	  WHERE X."DocEntry" = T."DocEntry"
	  AND "StaCode" IN (SELECT
	    "Code"
	  FROM "@SYP_IVA_FE_ATS"
	  WHERE "U_SYP_COLATS" LIKE '%baseImpGrav14%')), 0) AS "MONTO IVA 14",
	  ifnull(T."U_SYP_ICE", 0) AS "MONTO ICE",
	  T."DocTotal" AS "TOTAL VENTA",
	  
	
	  P0."U_SYP_TIPOOPERACION",
	  P0."U_SYP_DETIPO"
	  
	
	
	  
	  
	FROM "OINV" T
	LEFT JOIN "RCT2" P1
	  ON T."DocEntry" = P1."DocEntry"
	LEFT JOIN "ORCT" P0
	  ON P1."DocNum"=P0."DocEntry" --and P0."DocEntry" = T."DocEntry"  
	INNER JOIN "OCRD" T2
	 ON T."CardCode" = T2."CardCode"
	LEFT JOIN "OCTG" T3
	  ON T."GroupNum" = T3."GroupNum"
	INNER JOIN "@SYP_TPODOC" T4
	  ON T4."Code" = T."U_SYP_MDTD"
	  AND ifnull(T4."U_SYP_DIN", 'N') = 'N'
	  AND ifnull(T4."U_SYP_ESTADO", 'N') = 'Y'
	  AND (ifnull(T4."U_SYP_REGVEN", 'N') = 'Y'
	  OR ifnull(T4."U_SYP_REGEXP", 'N') = 'Y')
	  AND ifnull(T4."U_SYP_REGINT", 'N') = 'N'
	INNER JOIN "@SYP_NUMDOC" T4B
	  ON T4B."Code" = T4."Code"
	  AND ifnull(T4B."U_SYP_NDAI", 'N') = 'Y'
	  AND T4B."U_SYP_NDCE" = T."U_SYP_SERIESUC"
	  AND T4B."U_SYP_NDSD" = T."U_SYP_MDSD"
	LEFT JOIN "@SYP_TIPIDENT" T5
	  ON T2."U_SYP_BPTD" = T5."Code"
	WHERE T."CANCELED" = 'N'
	AND T."U_SYP_STATUS" = 'V'
	
	
	AND T."DocDate" BETWEEN :FECHA_INI AND :FECHA_FIN;




END

/* 02-10-2024 */

/* para eliminar y editar un scrip de SYP
DROP PROCEDURE SBO_SP_TransactionNotification_CLIENT;

CREATE PROCEDURE SBO_SP_TransactionNotification_CLIENT */

/* 
	OPRQ - SOLICITUD DE COMPRA 
	OPOR - Pedido 
	POR1  

	SELECT T1.* FROM OPOR T0 INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry" WHERE T0."DocNum" = '24000924'
    --SELECT * FROM OPRQ T0 WHERE T0."DocNum" = '24000429'
*/

--limitar pedidos sino existe una solicitud de compra

--si tengo un pedido que no esta con su solicitud de compra deber salir un error 
-- ahora si tiene el pedido con su solicitud de compra deberia pasar y que se registre

CREATE PROCEDURE SBO_SP_ValidatePurchaseOrder
(
    in object_type nvarchar(30),
    in transaction_type nchar(1),
    in list_of_cols_val_tab_del nvarchar(255),
    out error int,
    out error_message nvarchar(200)
)
LANGUAGE SQLSCRIPT
AS
    -- Declaración de variables
    EXISTEORDENCOMPRA INT;

BEGIN
    -- Inicializar el error
    error := 0;
    
    -- Verificar si es un pedido y tipo de transacción es agregar o crear
    IF :object_type = '22' AND ( :transaction_type = 'A' ) THEN
        
        -- Comprobar si existe la solicitud de compra (OPRQ)
        SELECT COUNT(*)
        INTO EXISTEORDENCOMPRA
        FROM OPRQ
        WHERE DocEntry IN (
			--Se usa una subconsulta para verificar si hay solicitudes de compra asociadas al DocEntry del pedido
            SELECT DocEntry 
			FROM OPOR 
			WHERE DocEntry = :list_of_cols_val_tab_del  
        );

        -- Si no existe la solicitud de compra, establecer error
        IF EXISTEORDENCOMPRA = 0 THEN
            error := 1;
            error_message := N'DPE: No se puede crear un pedido sin una solicitud de compra válida (OPRQ).';
        END IF;
    END IF;
END;


/* OJO */

CREATE PROCEDURE SBO_SP_ValidatePurchaseOrder
(
    in object_type nvarchar(30),
    in transaction_type nchar(1),
    in list_of_cols_val_tab_del nvarchar(255),
    out error int,
    out error_message nvarchar(200)
)
LANGUAGE SQLSCRIPT
AS
    -- Declaración de variables
    EXISTEORDENCOMPRA INT;

BEGIN
    -- Inicializar el error
    error := 0;
    
    -- Verificar si es un pedido y tipo de transacción es agregar o crear
    IF :object_type = '22' AND ( :transaction_type = 'A' ) THEN
        
        -- Comprobar si existe la solicitud de compra (OPRQ) asociada al pedido
        SELECT COUNT(*)
        INTO EXISTEORDENCOMPRA
        FROM OPRQ
        WHERE DocNum IN (
            SELECT T1."BaseEntry"
            FROM OPOR T0
            INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
            WHERE T0."DocNum" = :list_of_cols_val_tab_del
        );

        -- Si no existe la solicitud de compra, establecer error
        IF EXISTEORDENCOMPRA = 0 THEN
            error := 1;
            error_message := N'DPE: No se puede crear un pedido sin una solicitud de compra válida (OPRQ).';
        END IF;
    END IF;
END;






/* no */
CREATE PROCEDURE SBO_SP_ValidatePurchaseOrder
(
    in object_type nvarchar(30),
    in transaction_type nchar(1),
    in list_of_cols_val_tab_del nvarchar(255),
    out error int,
    out error_message nvarchar(200)
)
LANGUAGE SQLSCRIPT
AS
    -- Declaración de variables
    EXISTEORDENCOMPRA INT;

BEGIN
    -- Inicializar el error
    error := 0;
    
    -- Verificar si es un pedido y tipo de transacción de crear
    IF :object_type = '22' AND ( :transaction_type = 'A' ) THEN
        
        -- Comprobar si existe la solicitud de compra (OPRQ)
        SELECT COUNT(*)
        INTO EXISTEORDENCOMPRA
        FROM OPRQ
        WHERE DocEntry IN (
            -- Verificamos en la tabla POR1 para encontrar solicitudes asociadas al pedido
            SELECT T1."BaseEntry" 
            FROM POR1 T1 
            WHERE T1."DocEntry" = :list_of_cols_val_tab_del
        );

        -- Si no existe la solicitud de compra, establecer error
        IF EXISTEORDENCOMPRA = 0 THEN
            error := 1;
            error_message := N'DPE: No se puede crear un pedido sin una solicitud de compra válida (OPRQ).';
        END IF;
    END IF;

	-- -- Verificar si es una solicitud de compra y tipo de transacción de crear
    -- IF :object_type = '1470000113' AND ( :transaction_type = 'A' ) THEN
        
    --     -- Comprobar si existe un pedido (OPOR) asociado a la solicitud de compra (OPRQ)
    --     SELECT COUNT(*)
    --     INTO EXISTEORDENCOMPRA
    --     FROM OPOR
    --     WHERE DocEntry IN (
    --         -- Verificamos en la tabla POR1 para encontrar pedidos asociados a la solicitud de compra
    --         SELECT T1."DocEntry" 
    --         FROM POR1 T1 
    --         WHERE T1."BaseEntry" = :list_of_cols_val_tab_del
    --     );

    --     -- Si no existe el pedido, establecer error
    --     IF EXISTEORDENCOMPRA = 0 THEN
    --         error := 1;
    --         error_message := N'DPE: No se puede crear una solicitud de compra sin un pedido válido (OPOR).';
    --     END IF;
    -- END IF;
END;

/*  prueba */


CREATE PROCEDURE SBO_SP_ValidatePurchaseOrder
(
    in object_type nvarchar(30),
    in transaction_type nchar(1),
    in list_of_cols_val_tab_del nvarchar(255),
    out error int,
    out error_message nvarchar(200)
)
LANGUAGE SQLSCRIPT
AS
    -- Declaración de variables
    EXISTEORDENCOMPRA INT;

BEGIN
    -- Inicializar el error
    error := 0;
    
    -- Verificar si es un pedido y tipo de transacción es agregar o crear
    IF :object_type = '22' AND ( :transaction_type = 'A' ) THEN
        
        -- Comprobar si existe la solicitud de compra (OPRQ) asociada al pedido
        SELECT COUNT(*)
        INTO EXISTEORDENCOMPRA
        FROM OPRQ
        WHERE EXISTS (
            SELECT 1
            FROM OPOR T0
            INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
            WHERE T0."DocNum" = :list_of_cols_val_tab_del
            AND T1."BaseEntry" = OPRQ.DocNum
        );

        -- Si no existe la solicitud de compra, establecer error
        IF EXISTEORDENCOMPRA = 0 THEN
            error := 1;
            error_message := N'DPE: No se puede crear un pedido sin una solicitud de compra válida (OPRQ).';
        END IF;
    END IF;
END;





/* prueba final */


CREATE PROCEDURE SBO_SP_ValidatePurchaseOrder
(
    in object_type nvarchar(30),
    in transaction_type nchar(1),
    in list_of_cols_val_tab_del nvarchar(255),
    out error int,
    out error_message nvarchar(200)
)
LANGUAGE SQLSCRIPT
AS
    -- Declaración de variables
    EXISTEORDENCOMPRA INT;

BEGIN
    -- Inicializar el error
    error := 0;

    -- Verificar si es un pedido y tipo de transacción de crear
    IF :object_type = '22' AND ( :transaction_type = 'A' ) THEN
        
        -- Comprobar si existe la solicitud de compra (OPRQ) asociada al pedido
        SELECT COUNT(*)
        INTO EXISTEORDENCOMPRA
        FROM OPRQ
        WHERE DocEntry IN (
            -- Verificamos en la tabla POR1 para encontrar solicitudes asociadas al pedido
            SELECT T1."BaseEntry" 
            FROM POR1 T1 
            WHERE T1."DocEntry" = :list_of_cols_val_tab_del
        );

        -- Si no existe la solicitud de compra, establecer error
        IF EXISTEORDENCOMPRA = 0 THEN
            error := 1;
            error_message := N'DPE: No se puede crear un pedido sin una solicitud de compra válida (OPRQ).';
        END IF;
    END IF;

    -- Verificar si se está creando una solicitud de compra
    IF :object_type = '1470000113' AND ( :transaction_type = 'A' ) THEN
        -- Comprobar si existe un pedido (OPOR) asociado a la solicitud de compra (OPRQ)
        SELECT COUNT(*)
        INTO EXISTEORDENCOMPRA
        FROM OPOR
        WHERE DocEntry IN (
            -- Verificamos en la tabla POR1 para encontrar pedidos asociados a la solicitud de compra
            SELECT T1."DocEntry" 
            FROM POR1 T1 
            WHERE T1."BaseEntry" = :list_of_cols_val_tab_del
        );

        -- Si no existe el pedido, establecer error
        IF EXISTEORDENCOMPRA = 0 THEN
            error := 2;
            error_message := N'DPE: No se puede crear una solicitud de compra sin un pedido válido (OPOR).';
        END IF;
    END IF;
END;






/* final */

CREATE PROCEDURE SBO_SP_ValidatePurchaseOrder
(
    in object_type nvarchar(30),
    in transaction_type nchar(1),
    in list_of_cols_val_tab_del nvarchar(255),
    out error int,
    out error_message nvarchar(200)
)
LANGUAGE SQLSCRIPT
AS
    -- Declaración de variables
    EXISTEORDENCOMPRA INT;
    EXISTESOLICITUDCOMPRA INT;

BEGIN
    -- Inicializar el error
    error := 0;

    -- Verificar si es un pedido y tipo de transacción de crear
    IF :object_type = '22' AND ( :transaction_type = 'A' ) THEN
        
        -- Comprobar si existe la solicitud de compra (OPRQ) asociada al pedido
        SELECT COUNT(*)
        INTO EXISTESOLICITUDCOMPRA
        FROM OPRQ
        WHERE DocEntry IN (
            -- Verificamos en la tabla POR1 para encontrar solicitudes asociadas al pedido
            SELECT T1."BaseEntry" 
            FROM POR1 T1 
            WHERE T1."DocEntry" = :list_of_cols_val_tab_del
        );

        -- Si no existe la solicitud de compra, establecer error
        IF EXISTESOLICITUDCOMPRA = 0 THEN
            error := 1;
            error_message := N'DPE: No se puede crear un pedido sin una solicitud de compra válida (OPRQ).';
        END IF;
    END IF;

    -- Verificar si se está creando una solicitud de compra
    IF :object_type = '1470000113' AND ( :transaction_type = 'A' ) THEN
        -- Comprobar si existe un pedido (OPOR) asociado a la solicitud de compra (OPRQ)
        SELECT COUNT(*)
        INTO EXISTEORDENCOMPRA
        FROM OPOR
        WHERE DocEntry IN (
            -- Verificamos en la tabla POR1 para encontrar pedidos asociados a la solicitud de compra
            SELECT T1."DocEntry" 
            FROM POR1 T1 
            WHERE T1."BaseEntry" = :list_of_cols_val_tab_del
        );

        -- Si no existe el pedido, establecer error
        IF EXISTEORDENCOMPRA = 0 THEN
            error := 2;
            error_message := N'DPE: No se puede crear una solicitud de compra sin un pedido válido (OPOR).';
        END IF;
    END IF;

    -- Verificar si el pedido ya existe y no tiene una solicitud de compra asociada
    IF :object_type = '22' AND ( :transaction_type = 'U' ) THEN
        SELECT COUNT(*)
        INTO EXISTESOLICITUDCOMPRA
        FROM OPRQ
        WHERE DocEntry IN (
            -- Verificamos en la tabla POR1 para encontrar solicitudes asociadas al pedido
            SELECT T1."BaseEntry" 
            FROM POR1 T1 
            WHERE T1."DocEntry" = :list_of_cols_val_tab_del
        );

        -- Si no existe la solicitud de compra, establecer error
        IF EXISTESOLICITUDCOMPRA = 0 THEN
            error := 3;
            error_message := N'DPE: El pedido ya existe y no tiene una solicitud de compra válida (OPRQ).';
        END IF;
    END IF;

        -- Verificar si la solicitud de compra ya existe y no tiene un pedido asociado
    IF :object_type = '1470000113' AND ( :transaction_type = 'U' ) THEN
        SELECT COUNT(*)
        INTO EXISTEORDENCOMPRA
        FROM OPOR
        WHERE DocEntry IN (
            -- Verificamos en la tabla POR1 para encontrar pedidos asociados a la solicitud de compra
            SELECT T1."DocEntry" 
            FROM POR1 T1 
            WHERE T1."BaseEntry" = :list_of_cols_val_tab_del
        );

        -- Si no existe el pedido, establecer error
        IF EXISTEORDENCOMPRA = 0 THEN
            error := 4;
            error_message := N'DPE: La solicitud de compra ya existe y no tiene un pedido válido (OPOR).';
        END IF;
    END IF;
END;
   



   /* hacer pruebas */
CREATE PROCEDURE SBO_SP_ValidatePurchaseOrder
(
    in object_type nvarchar(30),
    in transaction_type nchar(1),
    in list_of_cols_val_tab_del nvarchar(255),
    out error int,
    out error_message nvarchar(200)
)
LANGUAGE SQLSCRIPT
AS
    -- Declaración de variables
    DECLARE EXISTEORDENCOMPRA INT;

BEGIN
    -- Inicializar el error
    error := 0;
    
    -- Verificar si es un Pedido de Compra (Object Type '22') y si la transacción es agregar ('A')
    IF :object_type = '22' AND :transaction_type = 'A' THEN

        -- Comprobar si existe al menos una línea en el pedido con una solicitud de compra asociada (BaseEntry en POR1)
        SELECT COUNT(*)
        INTO EXISTEORDENCOMPRA
        FROM POR1 T1
        LEFT JOIN OPRQ T2 ON T1."BaseEntry" = T2."DocEntry"
        WHERE T1."DocEntry" = :list_of_cols_val_tab_del
        AND T1."BaseEntry" IS NOT NULL; -- Verifica que hay una solicitud de compra asociada

        -- Si no existe una solicitud de compra asociada, establecer error
        IF EXISTEORDENCOMPRA = 0 THEN
            error := 1;
            error_message := N'No se puede crear un pedido sin una solicitud de compra válida (OPRQ).';
        END IF;

    END IF;
END;
   



--

/* 
Ahora quiero delimitar si ese campo es correo o es numerico si es string
 */

