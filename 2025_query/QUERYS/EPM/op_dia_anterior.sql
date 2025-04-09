/* EPM */

SELECT
"FechaOP",
"TIPO",
"U_beas_belnrid" AS "OP",
"U_beas_belposid" AS "Posicion",
"U_beas_posid" AS "Sub Posicion",
"U_beas_basedocentry" AS "Clave de Ingreso",
"ItemCode",
"Dscription" AS "ItemName",
"Cantidad",
"Plan_Cantidad" AS "Plan",
"INGRESO_TEORICO" AS "Teorico"

FROM "_SYS_BIC"."sap.b1hepmprod/EPM_CONSUMOS_INSUMOS_BEAS"
WHERE "TIPO" <> 'RC'
AND "U_beas_belnrid" IS NOT NULL
AND "FechaOP" = ADD_DAYS(CURRENT_DATE, - 1)

ORDER BY "U_beas_belnrid", "U_beas_basedocentry", "U_beas_belposid", "U_beas_posid" ASC;



/* ************************** */

SELECT
"FechaOP",
"TIPO",
"U_beas_belnrid" AS "OP",
"U_beas_belposid" AS "Posicion",
"U_beas_posid" AS "Sub Posicion",
"U_beas_basedocentry" AS "Clave de Ingreso",
"ItemCode",
"Dscription" AS "ItemName",
"Cantidad",
"Plan_Cantidad" AS "Plan",
"INGRESO_TEORICO" AS "Teorico"
FROM "_SYS_BIC"."NDB.sap.b1hepmprod/EPM_CONSUMOS_INSUMOS_BEAS" 
WHERE 
"TIPO" <> 'RC'
 AND "TIPO" = 'EM'
AND "U_beas_belnrid" IS NOT NULL
AND "FechaOP" = ADD_DAYS(CURRENT_DATE, - 1)
ORDER BY "U_beas_belnrid", "U_beas_basedocentry", "U_beas_belposid" ASC;

/* se va a modificar */

SELECT
"FechaOP",
"TIPO",
"U_beas_belnrid" AS "OP",
"U_beas_belposid" AS "Posicion",
"U_beas_posid" AS "Sub Posicion",
"U_beas_basedocentry" AS "Clave de Ingreso",
"ItemCode",
"Dscription" AS "ItemName",
"Cantidad",
"Plan_Cantidad" AS "Plan",
"INGRESO_TEORICO" AS "Teorico"
FROM "_SYS_BIC"."NDB.sap.b1hepmprod/EPM_CONSUMOS_INSUMOS_BEAS" 
WHERE 
"TIPO" <> 'RC'
AND "U_beas_belnrid" IS NOT NULL
AND "FechaOP" = ADD_DAYS(CURRENT_DATE, - 1)
ORDER BY "U_beas_belnrid", "U_beas_basedocentry", "U_beas_belposid", "U_beas_posid" ASC;






/* Productivo */


SELECT 
	"FechaOP",
	"TIPO",
	"U_beas_belnrid" AS "OP",
	"U_beas_belposid" AS "Posicion",
	"U_beas_posid" AS "Sub Posicion",
	"U_beas_basedocentry" AS "Clave de Ingreso",
	"ItemCode",
	"Dscription" AS "ItemName",
	"Cantidad",
	"Plan_Cantidad" AS "Plan",
	"INGRESO_TEORICO" AS "Teorico"

FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_CONSUMOS_INSUMOS_BEAS"
WHERE 
	"TIPO" <> 'RC' 
	AND "U_beas_belnrid" IS NOT NULL
	AND "FechaOP" = ADD_DAYS(CURRENT_DATE, - 2)
ORDER BY "U_beas_belnrid",  "U_beas_belposid","U_beas_basedocentry", "U_beas_posid" ASC
LIMIT 10

-- **************************************************************************************************************************************************************************







/* Modificando la op dia anterior */

SELECT 
   T0."DocDate" AS "FechaOP",
   T0."TIPO",
   T0."U_beas_belnrid" AS "OP",
   T0."U_beas_belposid" AS "Posicion",
   --T0."U_beas_posid" AS "Sub Posicion",
    --"U_beas_basedocentry" AS "Clave de Ingreso",
* 
FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_CONSUMOS_INSUMOS_BEAS_EFI" T0
WHERE 
	T0."TIPO" <> 'RC' 
                 AND T0."U_beas_posid" = 0
                AND T0."TIPO" = 'EM' 
	AND T0."U_beas_belnrid" IS NOT NULL
	AND T0."DocDate" = ADD_DAYS(CURRENT_DATE, - 1)
LIMIT 10





-- OP DIA ANTERIOR DREAMPACK

SELECT 
"DocDate",
"TIPO",
"U_beas_belnrid" AS "OP",
"U_beas_belposid" AS "Posicion",
--"U_beas_posid" AS "Sub Posicion",
--"U_beas_basedocentry" AS "Clave de Ingreso",
"ItemCode",
"Dscription" AS "ItemName",
"Cantidad",
--"Plan_Cantidad" AS "Plan",
"INGRESO_TEORICO" AS "Teorico",
"APLATZ_ID"

FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_CONSUMOS_INSUMOS_BEAS_EFI"
WHERE 
	"TIPO" <> 'RC' 
    AND "U_beas_posid" = 0
    AND "TIPO" = 'EM' 
	AND "U_beas_belnrid" IS NOT NULL
	AND "DocDate" = ADD_DAYS(CURRENT_DATE, - 1)
ORDER BY "U_beas_belnrid",  "U_beas_belposid", "U_beas_posid" ASC


-- OP DIA ANTERIOR EPM


/* carga masiva  */

SELECT T0."ItemCode",T1."WhsCode", T0."InvntryUom" FROM OITM T0 INNER JOIN OITW T1 ON T0."ItemCode" = T1."ItemCode" WHERE T0."ItemCode" = '0200FIN00000093'



/* REVISION CON SANTIAGO QUEDA ESTA OP DIA ANTERIOS  -CONSUMOS_INSUMOS_BEAS_EFI*/


/* CONSULTA ANTERIO A LA OP */
SELECT 
	"FechaOP",
	"TIPO",
	"U_beas_belnrid" AS "OP",
	"U_beas_belposid" AS "Posicion",
	"U_beas_posid" AS "Sub Posicion",
	"U_beas_basedocentry" AS "Clave de Ingreso",
	"ItemCode",
	"Dscription" AS "ItemName",
	"Cantidad",
	"Plan_Cantidad" AS "Plan",
	"INGRESO_TEORICO" AS "Teorico"

FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_CONSUMOS_INSUMOS_BEAS"
WHERE 
	"TIPO" <> 'RC' 
	AND "U_beas_belnrid" IS NOT NULL
	AND "FechaOP" = ADD_DAYS(CURRENT_DATE, - 1)
ORDER BY "U_beas_belnrid",  "U_beas_belposid","U_beas_basedocentry", "U_beas_posid" ASC

/* 
ORIGINAL
 */
SELECT 
"DocDate",
"TIPO",
"U_beas_belnrid" AS "OP",
"U_beas_belposid" AS "Posicion",
--"U_beas_posid" AS "Sub Posicion",
--"U_beas_basedocentry" AS "Clave de Ingreso",
"ItemCode",
"Dscription" AS "ItemName",
"Cantidad",
--"Plan_Cantidad" AS "Plan",
"INGRESO_TEORICO" AS "Teorico",
"APLATZ_ID"

FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_CONSUMOS_INSUMOS_BEAS_EFI"
WHERE 
	"TIPO" <> 'RC' 
    AND "U_beas_posid" = 0
    AND "TIPO" = 'EM' 
	AND "U_beas_belnrid" IS NOT NULL
	AND "DocDate" = ADD_DAYS(CURRENT_DATE, - 1)
ORDER BY "U_beas_belnrid",  "U_beas_belposid", "U_beas_posid" ASC