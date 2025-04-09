
SELECT T0."Code", T0."Name" FROM "@SYP_PROV" T0

SELECT T0."U_SYP_PROV", T0."U_SYP_DESCCANTON" FROM "@SYP_CANTON" T0 WHERE T0."U_SYP_PROV" = '24'

SELECT T0."U_DPE_CODE", T0."U_DPE_NAME" FROM "@DPE_ZONAS" T0

SELECT 
--T0."U_SYP_PROV", 
T0."U_SYP_DESCCANTON" 
FROM "@SYP_CANTON" T0 
WHERE T0."U_SYP_PROV" = $[$38.U_DPE_PROVINCIAS.0];


/* 
ELECT $[$Item.Column.Tipo_de_dato]  --para detalle

El tipo de datos es:

0 para alfanumérico
DATE para fecha.
MONEY para moneda.
NUMBER para número. */

/* BF FECHA FAC CLEINTE */
SELECT ADD_DAYS($[$10.1.DATE], T2."ExtraDays") AS "FechaVen"
--, T2."TolDays" 
FROM OINV T0  
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode" 
INNER JOIN OCTG T2 ON T1."GroupNum" = T2."GroupNum" 
WHERE $[$4.1.0] = T1."CardCode"
LIMIT 1


/* BF PESO CALCULADO */
SELECT $[$23.10.NUMBER] * T0."U_SYP_PESOBRUTO"
FROM OITM T0
WHERE T0."ItemCode" = $[$23.1.0]



-- ********************************************************************************************************

SELECT 
 T0."ItemCode",
 T1."WhsCode",
 T1."Locked"
FROM OITM T0  
INNER JOIN OITW T1 ON T0."ItemCode" = T1."ItemCode" 
LIMIT 100
--WHERE T0."ItemCode" = '0200FIN00000093'



ParentKey	LineNum	WarehouseCode	Locked
ItemCode	LineNum	WhsCode	Locked