--SELECT * FROM "SBO_FIGURETTI_PRO"."DPE_LOTES_ES" LIMIT 10


--SELECT * FROM "SBO_FIGURETTI_PRO"."DPE_LOTES_ES_PT"


SELECT *
FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_MOV_LOTES"
WHERE "ItmsGrpNam" = 'MAT.PRIMA DREAMPACK'


/*SELECT 
	T0."FechaOP",
	T0."TIPO",
	T0."U_beas_belnrid" AS "OP",
	T0."U_beas_belposid" AS "Posicion",
	T0."U_beas_posid" AS "Sub Posicion",
	T0."U_beas_basedocentry" AS "Clave de Ingreso",
	T0."ItemCode",
	T0."Dscription" AS "ItemName",
	T0."Cantidad",
	T0."Plan_Cantidad" AS "Plan",
	T0."INGRESO_TEORICO" AS "Teorico",
                T1."APLATZ_ID"

FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_CONSUMOS_INSUMOS_BEAS" T0
LEFT JOIN BEAS_FTAPL T1 ON  T0."U_beas_belnrid" = T1."BELNR_ID"  --Enrutamiento de producción
LEFT JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"  --Recibo del tiempo de producción

--INNER JOIN "BEAS_ARBZEIT" T1 ON T0."U_beas_belnrid" = T1."BELNR_ID" AND T0."U_beas_belposid" = T1."BELPOS_ID"

WHERE 
	T0."TIPO" <> 'RC' 
                 AND T0."U_beas_posid" = 0
                AND T0."TIPO" = 'EM' 
	AND T0."U_beas_belnrid" IS NOT NULL
	AND T0."FechaOP" = ADD_DAYS(CURRENT_DATE, - 1)
ORDER BY T0."U_beas_belnrid",  T0."U_beas_belposid", T0."U_beas_basedocentry", T0."U_beas_posid" ASC *






SELECT 

              /*T0."FechaOP",
	T0."TIPO",
	T0."U_beas_belnrid" AS "OP",
	T0."U_beas_belposid" AS "Posicion",
	T0."U_beas_posid" AS "Sub Posicion",
	T0."U_beas_basedocentry" AS "Clave de Ingreso",
	T0."ItemCode",
	T0."Dscription" AS "ItemName",
	T0."Cantidad",
	T0."Plan_Cantidad" AS "Plan",
	T0."INGRESO_TEORICO" AS "Teorico",*/

 *
FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_CONSUMOS_INSUMOS_BEAS" T0
WHERE
T0."TIPO" <> 'RC' 
                 AND T0."U_beas_posid" = 0
                AND T0."TIPO" = 'EM' 
	AND T0."U_beas_belnrid" IS NOT NULL
	AND T0."FechaOP" = ADD_DAYS(CURRENT_DATE, - 1)
ORDER BY T0."U_beas_belnrid",  T0."U_beas_belposid", T0."U_beas_basedocentry", T0."U_beas_posid" ASC





*/






SELECT * FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_CONSUMOS_INSUMOS_BEAS_EFI" T0  LIMIT 10



