SELECT 
    PT."CodigoProducto",
    T0."U_SYP_CODE_SKU",
    PT."Descripcion",
    PT."Lote",
    PT."EAN_13",
    PT."EAN_14",
    --PT."CODIGO_128",
    '(01)'||PT."EAN_14"||'(17)'||TO_VARCHAR(TO_DATE(PT."FechaCaducidad",'DD/MM/YYYY'),'YYMMDD')||'(10)'||PT."Lote" as "CODIGO_128",
    PT."UxFundas" as "UxC",
    PT."Operador",
    PT."Caja",
    PT."Cliente",
    PT."FechaFabricacion",
    PT."FechaCaducidad",
    PT."DatValue1",
    PT."DatValue2",
    --PT."DatValue3",
    LPAD((PT."BELNR_ID"||PT."BELPOS_ID"),7,'0') AS "DatValue3",
    --PT."DatValue4",
    (select IFNULL(MAX(R.U_LAB_FSC_DECLA),'') from OBTN R WHERE R."DistNumber" = PT."Lote") AS "DatValue4",
    PT."BELNR_ID",
    PT."BELPOS_ID",
    PT."OperadorUser",
    PT."U_SYP_CLIENTE",
    PT."NombreExtranjero",
    CAST(CAST(PT."ETIQUETAS" AS INT) AS NVARCHAR) AS "UxFundas",
    PT."FxCarton",
    PT."PesoNeto",
    T0."U_beas_brgew",
    PT."UserText",
    PT."CODE_128_COD" AS "Code128Barras",
    CAST(CAST(PT."FxCarton" AS INT) AS NVARCHAR) AS "DatValue5",
    PT.CODE128KFC AS "DatValue6",
    PT.CODE128KFCCOD AS "DatValue7",
    '' AS "DatValue8",
    '' AS "DatValue9"
FROM "SYP_ETIQUETAS_FUNDAS" PT 
LEFT JOIN OITM T0 ON PT."CodigoProducto" = T0."ItemCode"
WHERE "BELNR_ID" = '30121'
--AND "BELPOS_ID" = :pos
--AND CAST(PT."Caja" AS INT) BETWEEN :desde AND :hasta 
--AND PT."CODE_ID" = :LCODE;

/* PROCEDIMIENTO ALMACENADO ORIGINAL  PRODUCTIVO - SYP_SP_CONS_FORMATO_PT */
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
		  ,T0."U_SYP_CODE_SKU"
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
	  LEFT JOIN OITM T0 ON PT."CodigoProducto" = T0."ItemCode"
	 WHERE "BELNR_ID" = :ot
	   AND "BELPOS_ID" = :pos
	   AND CAST(PT."Caja" AS INT) BETWEEN :desde AND :hasta;
ELSE

 IF :tipo LIKE 'F%' THEN
	SELECT SUBSTR(:TIPO,3) INTO LCODE FROM DUMMY;
	SELECT PT."CodigoProducto"
		  ,T0."U_SYP_CODE_SKU"
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
	  LEFT JOIN OITM T0 ON PT."CodigoProducto" = T0."ItemCode"
	 WHERE "BELNR_ID" = :ot
	   AND "BELPOS_ID" = :pos
	   AND CAST(PT."Caja" AS INT) BETWEEN :desde AND :hasta 
	   AND PT."CODE_ID" = :LCODE;
	   
	ELSE
	SELECT PT."CodigoProducto"
		  ,T0."U_SYP_CODE_SKU"
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
	  LEFT JOIN OITM T0 ON PT."CodigoProducto" = T0."ItemCode"
	 WHERE "BELNR_ID" = :ot
	   AND "BELPOS_ID" = :pos
	   AND CAST(PT."Caja" AS INT) BETWEEN :desde AND :hasta ;
	END IF;
END IF;
END ;


/* SE AACTUALIZO SE ADD EL PESO BRUTO */
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
		  ,T0."U_SYP_CODE_SKU"
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
          ,T0."U_beas_brgew"
		  ,PT."UserText"
		  ,PT."CODE_128_COD" AS "Code128Barras"
		  ,'' AS "DatValue5"		  
		  ,PT.CODE128KFC AS "DatValue6"
		  ,PT.CODE128KFCCOD AS "DatValue7"
		  ,'' AS "DatValue8"
		  ,'' AS "DatValue9"
		  ,PT."LOTE_EXT"
	  FROM "SYP_ETIQUETAS_PT" PT 
	  LEFT JOIN OITM T0 ON PT."CodigoProducto" = T0."ItemCode"
	 WHERE "BELNR_ID" = :ot
	   AND "BELPOS_ID" = :pos
	   AND CAST(PT."Caja" AS INT) BETWEEN :desde AND :hasta;
ELSE

 IF :tipo LIKE 'F%' THEN
	SELECT SUBSTR(:TIPO,3) INTO LCODE FROM DUMMY;
	SELECT PT."CodigoProducto"
		  ,T0."U_SYP_CODE_SKU"
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
          ,T0."U_beas_brgew"
		  ,PT."UserText"
		  ,PT."CODE_128_COD" AS "Code128Barras"
		  ,CAST(CAST(PT."FxCarton" AS INT) AS NVARCHAR) AS "DatValue5"
		  ,PT.CODE128KFC AS "DatValue6"
		  ,PT.CODE128KFCCOD AS "DatValue7"
		  ,'' AS "DatValue8"
		  ,'' AS "DatValue9"
	  FROM "SYP_ETIQUETAS_FUNDAS" PT 
	  LEFT JOIN OITM T0 ON PT."CodigoProducto" = T0."ItemCode"
	 WHERE "BELNR_ID" = :ot
	   AND "BELPOS_ID" = :pos
	   AND CAST(PT."Caja" AS INT) BETWEEN :desde AND :hasta 
	   AND PT."CODE_ID" = :LCODE;
	   
	ELSE
	SELECT PT."CodigoProducto"
		  ,T0."U_SYP_CODE_SKU"
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
          ,T0."U_beas_brgew"
		  ,PT."UserText"
		  ,PT."CODE_128_COD" AS "Code128Barras"
		  ,'' AS "DatValue5"
		  ,PT.CODE128KFC AS "DatValue6"
		  ,PT.CODE128KFCCOD AS "DatValue7"
		  ,'' AS "DatValue8"
		  ,'' AS "DatValue9"
		  ,PT."LOTE_EXT"
	  FROM "SYP_ETIQUETAS_PT" PT 
	  LEFT JOIN OITM T0 ON PT."CodigoProducto" = T0."ItemCode"
	 WHERE "BELNR_ID" = :ot
	   AND "BELPOS_ID" = :pos
	   AND CAST(PT."Caja" AS INT) BETWEEN :desde AND :hasta ;
	END IF;
END IF;
END ;
