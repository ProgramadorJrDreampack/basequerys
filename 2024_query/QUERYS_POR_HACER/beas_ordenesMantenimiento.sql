SELECT 
T0."BELNR_ID" AS "N° Orden", /*T3."SortId", T1."BELPOS_ID", T1."POS_ID", T4."BELPOS_ID", T4."POS_ID",*/
T1."DisplayName" AS "Empleado", 
T4."AG_ID" AS "Recurso", 
CASE WHEN LENGTH(T4."AG_ID") = 6 THEN RIGHT(T4."AG_ID", 4) ELSE T4."AG_ID" END AS "Recurs", 
T7."BEZ",
T4."APLATZ_ID",(T0."WORKTIME" / 60 ) AS "Tiempo",  
T1."PCOSTVK", T1."KOSTEN_VK" AS "Costo mano de obra", T1."EXTERNAL_COST", T1."ANFZEIT" AS "Fecha inicio", T1."ENDZEIT" AS "Fecha fin",
T3."ART1_ID" AS "Número de artículo", T3."ItemName" AS "Repuesto", 
(SELECT MAX(A0."AvgPrice") FROM OITW A0 WHERE T3."ART1_ID" = A0."ItemCode" AND A0."AvgPrice" > 0) AS "PrecioW", 
T3."MATERIALKOSTEN" AS "Costo de material", T3."INPUT_QTY" AS "Cantidad", (T3."MATERIALKOSTEN" * T3."INPUT_QTY") AS "Total",
T2."ItemCode", 
T2."ItemName" AS "Mantenimiento", T0."TYP" AS "Tipo mantenimiento", T6."BaseAmnt" AS "Costo Servicio", 
(T1."KOSTEN_VK" + T3."MATERIALKOSTEN" + T6."BaseAmnt") AS "Costo total", T5."DocEntry", 
T4."BEZ"

FROM BEAS_FTHAUPT T0
LEFT JOIN BEAS_ARBZEIT T1 ON T0."BELNR_ID" = T1."BELNR_ID"
LEFT JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" 
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID"
LEFT JOIN BEAS_FTAPL T4 ON T0."BELNR_ID" = T4."BELNR_ID" AND T1."BELPOS_ID" = T4."BELPOS_ID" AND T1."POS_ID" = T4."POS_ID" --AND T3."SortId" = T4."SortId"
/*AND T3."BELPOS_ID" = T4."BELPOS_ID"  AND T4."POS_ID" = T3."POS_ID" AND T3."POS_TEXT" = T4."POS_TEXT" AND T3."SortId" = T4."SortId"
*/
LEFT JOIN PDN1 T5 ON T0."BELNR_ID" = T5."U_beas_belnrid" AND T4."BELPOS_ID" = T5."U_beas_belposid" AND T4."POS_ID" = T5."U_beas_posid"
LEFT JOIN OPDN T6 ON T5."DocEntry" = T6."DocEntry"
LEFT JOIN BEAS_APLATZ T7 ON RIGHT(UPPER(T4."AG_ID"), 4) = T7."APLATZ_ID"
WHERE T0."TYP" != 'Produccion' AND T0."BELNR_ID" 
--= '30710'
>= '15711'
ORDER BY T0."BELNR_ID" DESC



/* SE ACTULIZO  */
SELECT 
T0."BELNR_ID" AS "N° Orden", /*T3."SortId", T1."BELPOS_ID", T1."POS_ID", T4."BELPOS_ID", T4."POS_ID",*/
T1."DisplayName" AS "Empleado", 
T4."AG_ID" AS "Recurso", 
CASE WHEN LENGTH(T4."AG_ID") = 6 THEN RIGHT(T4."AG_ID", 4) ELSE T4."AG_ID" END AS "Recurs", 
T7."BEZ",
T4."APLATZ_ID",(T0."WORKTIME" / 60 ) AS "Tiempo",  
T1."PCOSTVK", 
T1."KOSTEN_VK" AS "Costo mano de obra", 
T1."EXTERNAL_COST", 
T1."ANFZEIT" AS "Fecha inicio", 
T1."ENDZEIT" AS "Fecha fin",
T3."ART1_ID" AS "Número de artículo", 
T3."ItemName" AS "Repuesto", 
(SELECT MAX(A0."AvgPrice") FROM OITW A0 WHERE T3."ART1_ID" = A0."ItemCode" AND A0."AvgPrice" > 0) AS "PrecioW", 
T3."MATERIALKOSTEN" AS "Costo de material", T3."INPUT_QTY" AS "Cantidad", (T3."MATERIALKOSTEN" * T3."INPUT_QTY") AS "Total",T2."ItemCode", 
T2."ItemName" AS "Mantenimiento", 
T0."TYP" AS "Tipo mantenimiento", 
T6."BaseAmnt" AS "Costo Servicio", 
(T1."KOSTEN_VK" + T3."MATERIALKOSTEN" + T6."BaseAmnt") AS "Costo total", 
T5."DocEntry",
T6."DocNum" AS "Num Documento",
T6."CardName",
T8."Dscription",
T4."BEZ",
T1."GRUND"

FROM BEAS_FTHAUPT T0
LEFT JOIN BEAS_ARBZEIT T1 ON T0."BELNR_ID" = T1."BELNR_ID"
LEFT JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" 
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID"
LEFT JOIN BEAS_FTAPL T4 ON T0."BELNR_ID" = T4."BELNR_ID" AND T1."BELPOS_ID" = T4."BELPOS_ID" AND T1."POS_ID" = T4."POS_ID" --AND T3."SortId" = T4."SortId"
/*AND T3."BELPOS_ID" = T4."BELPOS_ID"  AND T4."POS_ID" = T3."POS_ID" AND T3."POS_TEXT" = T4."POS_TEXT" AND T3."SortId" = T4."SortId"
*/
LEFT JOIN PDN1 T5 ON T0."BELNR_ID" = T5."U_beas_belnrid" AND T4."BELPOS_ID" = T5."U_beas_belposid" AND T4."POS_ID" = T5."U_beas_posid"
LEFT JOIN OPDN T6 ON T5."DocEntry" = T6."DocEntry"
LEFT JOIN BEAS_APLATZ T7 ON RIGHT(UPPER(T4."AG_ID"), 4) = T7."APLATZ_ID"
LEFT JOIN PDN1 T8 ON T6."DocEntry" = T8."DocEntry"
--LEFT JOIN OPOR T9 ON T6."DocEntry" = T9."DocEntry"
WHERE T0."TYP" != 'Produccion' AND T0."BELNR_ID" 
--= '30710'
>= '15711'
ORDER BY T0."BELNR_ID" DESC



/* revisar la query con raul */

SELECT 
T0."BELNR_ID" AS "N° Orden", /*T3."SortId", T1."BELPOS_ID", T1."POS_ID", T4."BELPOS_ID", T4."POS_ID",*/
T1."DisplayName" AS "Empleado", 
T4."AG_ID" AS "Recurso", 
CASE WHEN LENGTH(T4."AG_ID") = 6 THEN RIGHT(T4."AG_ID", 4) ELSE T4."AG_ID" END AS "Recurs", 
T7."BEZ",
T4."APLATZ_ID",(T0."WORKTIME" / 60 ) AS "Tiempo",  
T1."PCOSTVK", 
T1."KOSTEN_VK" AS "Costo mano de obra", 
T1."EXTERNAL_COST", 
T1."ANFZEIT" AS "Fecha inicio", 
T1."ENDZEIT" AS "Fecha fin",
T3."ART1_ID" AS "Número de artículo", 
T3."ItemName" AS "Repuesto", 
(SELECT MAX(A0."AvgPrice") FROM OITW A0 WHERE T3."ART1_ID" = A0."ItemCode" AND A0."AvgPrice" > 0) AS "PrecioW", 
T3."MATERIALKOSTEN" AS "Costo de material", T3."INPUT_QTY" AS "Cantidad", (T3."MATERIALKOSTEN" * T3."INPUT_QTY") AS "Total",T2."ItemCode", 
T2."ItemName" AS "Mantenimiento", 
T0."TYP" AS "Tipo mantenimiento", 
T6."BaseAmnt" AS "Costo Servicio", 
(T1."KOSTEN_VK" + T3."MATERIALKOSTEN" + T6."BaseAmnt") AS "Costo total", 
T5."DocEntry",
T6."DocNum" AS "Num Documento",
T6."CardName",
--T8."Dscription",
T4."BEZ",
T1."GRUND",
T9."DocEntry",
T9."DocNum",
T9."CardName",
T9."DocTotal"
--T9.*

FROM BEAS_FTHAUPT T0
LEFT JOIN BEAS_ARBZEIT T1 ON T0."BELNR_ID" = T1."BELNR_ID"
LEFT JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" 
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID"
LEFT JOIN BEAS_FTAPL T4 ON T0."BELNR_ID" = T4."BELNR_ID" AND T1."BELPOS_ID" = T4."BELPOS_ID" AND T1."POS_ID" = T4."POS_ID" --AND T3."SortId" = T4."SortId"
/*AND T3."BELPOS_ID" = T4."BELPOS_ID"  AND T4."POS_ID" = T3."POS_ID" AND T3."POS_TEXT" = T4."POS_TEXT" AND T3."SortId" = T4."SortId"
*/
LEFT JOIN PDN1 T5 ON T0."BELNR_ID" = T5."U_beas_belnrid" AND T4."BELPOS_ID" = T5."U_beas_belposid" AND T4."POS_ID" = T5."U_beas_posid"
LEFT JOIN OPDN T6 ON T5."DocEntry" = T6."DocEntry"
LEFT JOIN BEAS_APLATZ T7 ON RIGHT(UPPER(T4."AG_ID"), 4) = T7."APLATZ_ID"
--LEFT JOIN PDN1 T8 ON T5."DocEntry" = T8."DocEntry"
LEFT JOIN OPOR T9 ON T6."DocEntry" = T9."DocEntry"
WHERE T0."TYP" != 'Produccion' AND T0."BELNR_ID" 
--= '30710'
>= '15711'
ORDER BY T0."BELNR_ID" DESC


/*Productivo Query Manger -> Mantenimiento -> SOLICITUDES DE COMPRAS DE MANTENIMIENTOS */
SELECT
T0."DocNum" AS "Solicitud",
T1."DocDate" AS "Fecha SC",
T0."DocTime" AS "Hora SC",
T4."Name",
T3."DocNum" AS "DocNum Pedido",
CASE
WHEN T0."U_SYP_TIPCOMPRA" = '01' THEN 'NACIONAL'
WHEN T0."U_SYP_TIPCOMPRA" = '02' THEN 'IMPORTADO'
ELSE T0."U_SYP_TIPCOMPRA" END AS "TIPO DE COMPRA",
T1."ItemCode",
T1."Dscription",
--T1."LineNum",
T1."Quantity",
T1."Price",
T0."DocTotal",
T6."DocNum" AS "DocNum EM",
T6."DocDate" AS "Fecha EntradaM",
T5."Quantity",
T5."Price"


FROM OPRQ T0
INNER JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN POR1 T2 ON T1."TrgetEntry" = T2."DocEntry" AND T1."LineNum" = T2."BaseLine"
LEFT JOIN OPOR T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN OUDP T4 ON T0."Department" = T4."Code"
LEFT JOIN PDN1 T5 ON T3."DocEntry" = T5."BaseEntry" AND T2."LineNum" = T5."BaseLine" ANd T5."BaseType" = '22'
LEFT JOIN OPDN T6 ON T5."DocEntry" = T6."DocEntry"

WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T4."Name" = 'Mantenimiento'
--AND T0."U_SYP_TIPCOMPRA" = '01' AND T0."CANCELED" = 'N' --AND T0."DocNum" IN ('23001060')
--AND T4."CANCELED" = 'N'
ORDER BY T0."DocDate" ASC


/* SE ESTA TRABAJANDO  */
SELECT
--T0."TYP",
--T0."BELDAT", 
T0."BELNR_ID" AS "N° Orden", /*T3."SortId", T1."BELPOS_ID", T1."POS_ID", T4."BELPOS_ID", T4."POS_ID",*/
T1."DisplayName" AS "Empleado", 
T4."AG_ID" AS "Recurso", 
CASE WHEN LENGTH(T4."AG_ID") = 6 THEN RIGHT(T4."AG_ID", 4) ELSE T4."AG_ID" END AS "Recurs", 
T7."BEZ",
T4."APLATZ_ID",(T0."WORKTIME" / 60 ) AS "Tiempo",  
T1."PCOSTVK", 
T1."KOSTEN_VK" AS "Costo mano de obra", 
T1."EXTERNAL_COST", 
T1."ANFZEIT" AS "Fecha inicio", 
T1."ENDZEIT" AS "Fecha fin",
T3."ART1_ID" AS "Número de artículo", 
T3."ItemName" AS "Repuesto", 
(SELECT MAX(A0."AvgPrice") FROM OITW A0 WHERE T3."ART1_ID" = A0."ItemCode" AND A0."AvgPrice" > 0) AS "PrecioW", 
T3."MATERIALKOSTEN" AS "Costo de material", T3."INPUT_QTY" AS "Cantidad", (T3."MATERIALKOSTEN" * T3."INPUT_QTY") AS "Total",T2."ItemCode", 
T2."ItemName" AS "Mantenimiento", 
T0."TYP" AS "Tipo mantenimiento", 
T6."BaseAmnt" AS "Costo Servicio", 
(T1."KOSTEN_VK" + T3."MATERIALKOSTEN" + T6."BaseAmnt") AS "Costo total", 
T5."DocEntry",
T6."DocNum" AS "Num Documento",
T6."CardName",
--T8."Dscription",
T4."BEZ",
T1."GRUND"--,
/*T9."DocEntry",
T9."DocNum",
T9."CardName",
T9."DocTotal"*/
--A1.*

FROM BEAS_FTHAUPT T0
LEFT JOIN BEAS_ARBZEIT T1 ON T0."BELNR_ID" = T1."BELNR_ID"
LEFT JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" 
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID"
LEFT JOIN BEAS_FTAPL T4 ON T0."BELNR_ID" = T4."BELNR_ID" AND T1."BELPOS_ID" = T4."BELPOS_ID" AND T1."POS_ID" = T4."POS_ID" --AND T3."SortId" = T4."SortId"

/*AND T3."BELPOS_ID" = T4."BELPOS_ID"  AND T4."POS_ID" = T3."POS_ID" AND T3."POS_TEXT" = T4."POS_TEXT" AND T3."SortId" = T4."SortId"
*/

LEFT JOIN PDN1 T5 ON T0."BELNR_ID" = T5."U_beas_belnrid" AND T4."BELPOS_ID" = T5."U_beas_belposid" AND T4."POS_ID" = T5."U_beas_posid"
LEFT JOIN OPDN T6 ON T5."DocEntry" = T6."DocEntry"
LEFT JOIN BEAS_APLATZ T7 ON RIGHT(UPPER(T4."AG_ID"), 4) = T7."APLATZ_ID"

--LEFT JOIN PDN1 A0 ON A0."BaseEntry" = T5."DocEntry" 
--LEFT JOIN OPOR A1 ON A1."DocEntry" = A0."BaseEntry" 

--LEFT JOIN PDN1 T8 ON T5."DocEntry" = T8."DocEntry"
--LEFT JOIN OPOR T9 ON T5."DocEntry" = T9."DocEntry"
--LEFT JOIN OPRQ T9 ON T6."DocEntry" = T9."DocEntry"

WHERE 
T0."TYP" != 'Produccion' AND 
T0."BELNR_ID" 
--= '30710'
>= '15711' --AND
---T0."BELNR_ID" = '30095'
--T0."BELDAT" BETWEEN '2024-08-01' AND '2024-09-30'
ORDER BY T0."BELNR_ID" DESC


/* realizado desde cero el query de ordenes de matenimiento */
SELECT
    T0."ABGKZ" AS "Cerrado : Yes (J), No (N)",
    T0."ANDTSTAMP" AS "Fecha y Hora de la ultima modificacion",
    T0."ANDUSER" AS "Usuario que realizo la ultima modificacion",
    T0."ANFZEIT" AS "Fecha inicio",
    TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio",
    T0."APSSTATUS" AS "Estado de planificación APS: Planned (1), No (0)",
    T0."AUFTRAG" AS "Num de la orden",
    T0."AUFTRAGINT" AS "Num base de la orden",
    T0."AUFTRAGPOS" AS "Línea base de la orden",
    T0."BELDAT" AS	"Fecha de la orden",
    T0."BELNR_ID" AS "Num del documento (numérico)",
    T0."BITMAPCLOSE" AS "Icono para cerrar la orden",
    T0."BITMAPLOCK" AS "Icono para bloquear la orden",
    T0."BPLId" AS "Identificador de la sucursal (Branch)",
    T0."BPLName" AS	"Nombre de la sucursal",
    T0."COLORNR" AS "Num de color asociado a la orden",
    T0."DocEntry" AS "Entrada del documento base",
    T0."DOCUMENTS" AS "Documentos asociados a la orden",
    T0."DRUCKKZ" AS "Indica si se ha impreso el documento: Yes (J), No (N)",
    T0."ENDZEIT" AS "Hora de finalización de la orden",
    T0."ERFTSTAMP" AS "Fecha y hora de creación de la orden",
    T0."ERFUSER" AS	"Usuario que creó la orden",
    T0."FLAG_ERROR" AS "Indica si hay un registro de errores disponible: Yes (1), No (0)",
    T0."GEMEINKOSTEN" AS "Indica si es una orden de costos generales: Yes (1), No (0)",
    T0."INFORMATION2" AS "Información adicional 2",
    T0."ISTZEIT" AS	"Último mensaje registrado sobre la orden",
    T0."ItemCode" AS "Num del ítem asociado a la orden",
    T0."KALKBELNR_ID" AS "Número de cálculo asociado a la orden",
    T0."KND_ID" AS "Identificador del cliente, lead o proveedor",
    T0."KND_SHIPTOCODE" AS "Código del cliente para entrega",
    T0."KNDLAND" AS "País del cliente",
    T0."KNDNAME" AS "Nombre del cliente",
    T0."KNDORT" AS "Ubicación del cliente (ciudad)",
    T0."KNDPLZ" AS "Código postal del cliente",
    T0."KNDSTRASSE" AS "Calle del cliente",
    T0."KNDTELEFON1" AS "Teléfono del cliente",
    T0."LASTCALCULATE_DATE" AS "Fecha del último cálculo realizado para la orden",
    T0."LFGDAT" AS "Fecha de entrega planificada",
    T0."PLANNEDCOSTS" AS "Costos planificados para la orden",
    T0."PLANNEDHOURS" AS "Horas planificadas para completar la orden",
    T0."PLANNINGORDER" AS "Indica si es una orden planificada: Yes (1), No (0)",
    T0."PRIOR_ID" AS "Prioridad asignada a la orden",
    T0."PRJINFO1" AS "Información 1",
    T0."PRJINFO2" AS "Información 2",
    T0."PRJUDF1" AS "Proyecto UDF 1",
    T0."PRJUDF2" AS "Proyecto UDF 2",
    T0."PRJUDF3" AS "Proyecto UDF 3",
    T0."PRJUDF4" AS "Proyecto UDF 4",
    T0."PRJUID" AS "Tarea",
    T0."Project" AS "Proyecto",
    T0."PROJECT_MANUAL" AS "Cantidad (importación) o cantidad a producir",
    T0."PROJECTSTATE" AS "Estado del proyecto",
    T0."PROJECTUSER1" AS "Gerente de proyecto 1",
    T0."PROJECTUSER2" AS "Gerente de proyecto 2",
    T0."REALCOSTS_GK" AS "Costos reales gk",
    T0."REALCOSTS_VK" AS "Costos reales vk",
    T0."REALHOURS" AS "Horas reales",
    T0."SAMMELAUFTRAG" AS "Orden resumida si es 1, entonces la orden de trabajo se crea como
orden de trabajo resumida
si=1
no=0",
    T0."SPERRUNG" AS "Bloquear : Yes (1), No (0)",
    T0."STATUS_ID" AS "Estado",
    T0."TIMECALCULATE" AS "Programar automáticamente : Yes (1), No (0)",
    T0."TYP" AS "Tipo de orden de trabajo",
    T0."UDF1" AS "Campo de usuario 1",
    T0."UDF2" AS "Campo de usuario 2",
    T0."UDF3" AS "Campo de usuario 3",
    T0."UDF4" AS "Campo de usuario 4",
    T0."UDF5" AS "Campo de usuario 5",
    T0."UDF6" AS "Campo de usuario 6",
    T0."UDF7" AS "Campo de usuario 7",
    T0."UDF8" AS "Campo de usuario 8",
    T0."UDF9" AS "Campo de usuario 9",
    T0."UDF10" AS "Campo de usuario 10",
    T0."UDF11" AS "Campo de usuario 11",
    T0."UDF12" AS "Campo de usuario 12",
    T0."UDF13" AS "Campo de usuario 13",
    T0."UDF14" AS "Campo de usuario 14",
    T0."UDF15" AS "Campo de usuario 15",
    T0."UNVISIBLE" AS "Invisible :  Yes (1), No (0)",
    T0."ZUSATZTEXT" AS "Informacion",
    (T0."WORKTIME" / 60 ) AS "Tiempo",
    T1."ABGKZ" AS "Production routing - Cerrado : Yes (J), No (N)",
    T1."AG_ID" AS "ID de operación predeterminada",
    T1."ANDTSTAMP" AS "Fecha de la ultima modificación",
    TO_NVARCHAR(TO_TIME(T1."ANDTSTAMP"), 'HH24:MI:SS') AS "Hora de ultima modificacion",
    T1."ANDUSER" AS "Cambiador",
    T1."ANFZEIT" AS "Fecha de inicio",
    TO_NVARCHAR(TO_TIME(T1."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio",
    T1."ANFZEIT_FIX" AS "Corrección de hora de inicio",
    T1."ANWEISUNGEN" AS "descripción adicional",
    T1."ANZAHL" AS "Número",
    T1."ANZLS" AS "Número de nóminas",
    T1."APLATZ_ID" AS "Centro de Trabajo",
    --T1."aplatz_maschine"
    T1."AUSSCHUSSFAKTOR" AS "Factor de desecho",
    T1."BA_ID" AS "Tipo de edición",
    T1."BDE" AS "Fichar entrada/salida Obligatorio",
    T1."BEARBEITUNGS_ART" AS "Tipo de Tratamiento",
    T1."BELNR_ID" AS "Número de documento",
    T1."BELPOS_ID" AS "Posición del documento",
    T1."BEREITGESTELLT" AS "Reservado",
    T1."BEZ" AS "Descripción",
    T1."BILD1" AS "Foto 1",
    T1."BILD2" AS "Foto 2",
    T1."BILD2" AS "Foto 3",
    T1."BOM_FIRSTSTART" AS "Control de materiales primero Inicio",
    T1."CardCode" AS "Proveedor",
    T1."ENDZEIT" AS "Fecha Fin",
    TO_NVARCHAR(TO_TIME(T1."ENDZEIT"), 'HH24:MI:SS') AS "Hora Fin",
    T1."ERFTSTAMP" AS "Fecha de creación",
    T1."ERFUSER" AS "Mecanógrafo",
    T1."FAG" AS "Operación externa",
    T1."FAG_CURRENCY" AS "Operación externa Moneda",
    T1."FAG_ITEMCODE" AS "Código de artículo",
    T1."FAG_MINPRICE" AS "Operación externa Precio mínimo",
    T1."FAG_PRICE" AS "Operación externa Precio",
    T1."FAG_PRICEJE" AS "Operación externa Precio por",
    T1."FAG_TRANSPORTPRICE" AS "Operación externa Precio de envío",
    T1."FAG_TRANSPORTPRICEA" AS "Operación externa Tamaño del lote de envío",
    --T1."Fl_aplatz"
    T1."FREIGABE" AS "identificación de inicio",
    --T1."Ft_aplatz"
     T1."GEBUCHT" AS "como reservado resaltado",
     T1."GESAMT_ANFZEIT" AS "Inicio total",
     T1."GESAMT_ENDZEIT" AS "Fin Total",
     T1."GRENZKOSTEN_MINUTE" AS "Tasa de costo marginal",
     T1."ISTZEIT" AS "Hora real",
     T1."KSTST_ID" AS "Centro de costos",
     T1."LIEFERTERMINUEBERSCHNEIDUNG" AS "Cambiar Superposición de fechas de entrega",
     T1."LIEGEZEIT_ANFZEIT" AS "Fecha de Inicio del tiempo de inactividad",
     TO_NVARCHAR(TO_TIME(T1."LIEGEZEIT_ANFZEIT"), 'HH24:MI:SS') AS "Inicio del tiempo de inactividad",
     T1."LIEGEZEIT_ENDZEIT" AS "Fin del tiempo de inactividad",
     TO_NVARCHAR(TO_TIME(T1."LIEGEZEIT_ENDZEIT"), 'HH24:MI:SS') AS "Fin del tiempo de inactividad",
     T1."LOHNGRUPPE" AS "Grupo salarial",
     T1."MEHRMASCH_BED" AS "Agrupación de máquinas",
     T1."MEHRMASCHINENBELEGUNG" AS "Agrupación de máquinas permitida",
     T1."MEHRMASCHINENBELEGUNG_ANZ" AS "Tipo de asignación de recursos",
     T1."MENGE_JE" AS "Cantidad por artículo terminado",
     T1."MENGE_ZEITJE" AS "Tiempo en (h/min)",
     T1."MENGENAUSSCHUSS" AS "Lista de materiales del factor de desecho",
     T1."NUMMER" AS "Número de código de barras",
     T1."NUTZEN" AS "Usar",
     --T1."org_aplatz_id"
     --T1."org_menge_je"
     --T1."org_menge_zeitje"
     --T1."org_te"
     --T1."org_tr"
      T1."PERS_ID" AS "Número de empleado",
     --T1."PERSGRP_ID"
     T1."POS_ID" AS "Posición",
     T1."QS_ID" AS "Plan de Inspección",
     T1."RM_FAKTOR" AS "Factor por unidad de almacén",
     T1."RM_ME_ID" AS "Entrada de mercancías en unidad",
     T1."STRUKTURINFO" AS "Información estructural",
     T1."TEAPLATZ" AS "Mach + Tiempo de Trabajo/Unidad Centro de Trabajo",
     --T1."TEPersGrp"
     T1."TERMINUEBERSCHNEIDUNG" AS "Cambio de cita",
     T1."THAPLATZ" AS "Máquina Tiempo/unidad Centro de Trabajo",
     --T1."THPersGrp"
     T1."TIMETYPE_ID" AS "Tipo de tiempo",
     T1."TL" AS "Tiempo inactivo",
     T1."TNAPLATZ" AS "Tiempo de mano de obra / unidad Centro de trabajo",
     --T1."TNPersGrp"
     T1."TR2APLATZ" AS "Configuración para Sched+Cap. Centro de Trabajo",
     --T1."TR2PersGrp"
     T1."TRAPLATZ" AS "tiempo de preparación Centro de trabajo",
     --T1."TRPersGrp"
     T1."UDF1" AS "Usuario 1",
     T1."UDF2" AS "Usuario 2",
     T1."UDF3" AS "Usuario 3",
     T1."UDF4" AS "Usuario 4",
     T1."UEBERGABE_ANFZEIT" AS "Fecha de inicio de la transferencia",
     TO_NVARCHAR(TO_TIME(T1."UEBERGABE_ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio de la transferencia",
     T1."UEBERGABE_ENDZEIT" AS "Fecha fin de la transferencia",
     TO_NVARCHAR(TO_TIME(T1."UEBERGABE_ENDZEIT"), 'HH24:MI:SS') AS "Hora fin de la transferencia",
     T1."UEBLGRZ" AS "Límite de superposición",
     T1."VOLLKOSTEN_MINUTE" AS "Tarifa de costo total",
     T1."ZEILENNUMMER" AS "Línea No.",
     T1."ZEITAUFNDAT" AS "Grabación de fecha y hora",
     T1."ZEITAUFNKZ" AS "ID de inicio de hora",
     T1."ZTART" AS "Tipo de tiempo",

     T2."ABGKZ" AS "Recibo del tiempo de producción - Cerrado - Cerrar ruta Posición=Y, No cerrar rutas Posición=N",
     T2."ADDITIONAL_COST_GK" AS "Costos adicionales Monto Costo marginal",
     T2."ADDITIONAL_COST_VK" AS "Costos Adicionales Monto Costo Total",
     T2."ADDITIONAL_PC_GK" AS "Costos adicionales % Costo marginal",
     T2."ADDITIONAL_PC_VK" AS "Costos Adicionales % Costo Total",
     T2."ADDITIONAL_PCOSTGK" AS "Costos adicionales Costo marginal de personal",
     T2."ADDITIONAL_PCOSTVK" AS "Costos Adicionales Personal Costo Total",
     T2."ANDTSTAMP" AS "Fecha del último cambio",
     T2."ANDUSER" AS "Usuario del último cambio",
     T2."ANFZEIT" AS "Fecha de Inicio",
     TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio",
     T2."APLATZ_ID" AS "Recurso",
     T2."AUFTRAG" AS "Orden",
     T2."AUSWAERTSBEARBEITUNG" AS "Procesamiento externo",
     T2."BatchNum" AS "Número de lote",
     T2."BELNR_ID" AS "Número de orden de trabajo",
     T2."BELPOS_ID" AS "Número de posición de orden de trabajo",
     T2."BPLId" AS "Sucursal o Industria",
     T2."BPLName" AS "Nombre Sucursal o Industria",
     T2."BUCHNR_ID" AS "Número de reserva",
     T2."CANCELD" AS "Mensaje de recibo cancelado",
     T2."DisplayName" AS "Nombre del personal",
     T2."DocDate" AS "Fecha válida",
     TO_NVARCHAR(TO_TIME(T2."DocDate"), 'HH24:MI:SS') AS "Hora de inicio válida",
     T2."ENDZEIT" AS "Fecha de finalización",
     TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Hora de finalización",
     T2."ERFTSTAMP" AS "Fecha de creación",
     T2."ERFUSER" AS "Usuario de creación",
     T2."EXTERNAL_COST" AS "Costo externo",
     T2."GRUND" AS "Motivo de entrada",
     T2."KOSTEN_GK" AS "Costo límite",
     T2."KOSTEN_VK" AS "Costo total",
     T2."KSTST_ID" AS "Centro de costos",
     --T2."manualbooking"
     T2."MENGE_GUT" AS "Primera Calidad Cantidad",
     T2."MENGE_GUT_RM" AS "Buena cantidad",
     T2."MENGE_SCHLECHT" AS "Cantidad de chatarra",
     T2."MENGE_SCHLECHT_RM" AS "Cantidad de chatarra en unidad de recepción de tiempo",
     T2."PCOSTGK" AS "Costos laborales Costo marginal",
     T2."PCOSTVK" AS "Costos laborales Costo total",
     T2."PERS_ID" AS "Número de empleado",
     T2."POS_ID" AS "Número de posición de ruta",
     T2."PostInDocEntry" AS "Enlace al recibo",
     T2."PostOutDocEntry" AS "Enlace al problema",
     T2."PRJUID" AS "Tarea del proyecto",
     T2."Project" AS "Proyecto",
     T2."PTIMETYPE_ID" AS "Tipo de tiempo personal",
     T2."RESOURCENPOS_ID" AS "Posición de recursos", --Número de posición interna del recurso paralelo vinculado a BEAS_FTAPL.WKZPOS_ID!
     T2."RM_FAKTOR" AS "Factor por unidad de tiempo",
     T2."RM_ME" AS "unidad de tiempo",
     T2."RUEST_GK" AS "Costo de instalación Costo marginal",
     T2."RUEST_VK" AS "Costo de instalación Costo total",
     T2."STATIONNAME" AS "Nombre de la estación de trabajo",
     T2."TIMEFACTOR" AS "Factor de tiempo",
     T2."TIMETYPE_ID" AS "Tipo de tiempo",
     T2."TYP" AS "tipo de mensaje - hora normal=A, tiempo de herramienta = R, tiempo 2 (H)=H, tiempo 3 (N)=N",
     T2."UDF1" AS "Usuario 1",
     T2."UDF2" AS "Usuario 2",
     T2."UDF3" AS "Usuario 3",
     T2."UDF3" AS "Usuario 4",
     T2."WKZ_ID" AS "Identificación de herramienta",
     T2."ZEIT" AS "Tiempo",
     
     T3."ABGKZ" AS "cerrado lista de materiales",
     T3."ABM1" AS "Longitud",
     T3."ABM2" AS "Ancho / o.d",
     T3."ABM3" AS "H / i.d",
     --T3."ad"
     T3."ANDTSTAMP" AS "Fecha del último cambio",
     T3."ANDUSER" AS "Usuario del último cambio",
     T3."APLANPOS_ID" AS "Posición de enrutamiento - 10=10, 40=100, 50=110, 60=120, 70=130",
     T3."ART1_ID" AS "ItemCode - Código de artículo",
     T3."AUSSCHUSS" AS "Chatarra calculada",
     --T3."b"
     T3."BASEDOCENTRY" AS "doctrina básica",
     T3."BaseDocNum" AS "documento base",
     T3."BaseLine" AS "línea base",
     T3."BASELINE2" AS "línea base 2",
     T3."BaseType" AS "tipo base",
     T3."BELNR_ID" AS "Número de orden de trabajo",
     T3."BELPOS_ID" AS "Orden de trabajo Posición",
     T3."BEREITGESTELLT" AS "reservado",
     T3."BITMAPNAME" AS "Imagen bmp=bmp",
     T3."BookedQty" AS "Cantidad reservada",
     T3."CAFTINFO",
     T3."COLORID" AS "Color",
     T3."DELIVERYDATE" AS "Fecha de entrega",
     T3."DICHTE" AS "Densidad",
     T3."DIN",
     T3."DISPO" AS "disponer",
     T3."DontBookScrap" AS "No publicar chatarra",
     T3."ERFTSTAMP" AS "Fecha de creación",
     T3."ERFUSER" AS "Usuario de creación",
     T3."FORM" AS "Forma",
     T3."GK_ZUSCHLAG" AS "% de costos de margen de recargo",
     T3."GRUPPE" AS "Grupo de materiales",
     --T3."h"
     --T3."ID"
     T3."INFO" AS "Información",
     T3."ItemName" AS "ItemName - Descripcion",
     --T3."I",
     T3."Match" AS "Código de coincidencia",
     T3."MATERIALKOSTEN" AS "Costos de materiales",
     T3."ME_LAGER" AS "Unidad de almacén Cant.",
     T3."ME_UMR" AS "factor unitario",
     T3."ME_VERBRAUCH" AS "Lista de materiales de la unidad",
     T3."MENGE_GEBUCHT_LAGER" AS "Cantidad reservada",
     T3."MENGE_JE" AS "MENGE_JE - Cant cd Uno",
     T3."MENGE_LAGER" AS "Cantidad en unidad de tienda",
     T3."MENGE_VERBRAUCH" AS "Cantidad.  'En la lista de materiales de producción la cantidad siempre es
proporcionado en unidades de consumo'",
     T3."MENGE_VERSCHNITT_LA" AS "Corte en unidad de almacén",
     T3."MENGE_VERSCHNITT_VE" AS "Recargo por cantidad fija",
     T3."NUMMER" AS "Código de barras",
     T3."OnlyReservation" AS "Sólo Reserva Reserva : Sí=1, No=0",
     T3."PlaningSysNoSubMaterial" AS "Método de planificación",
     T3."POS_ID" AS "posición de nacimiento interno",
     T3."POS_ID_ORIGINAL" AS "identificación posicion original",
     T3."POS_TEXT" AS "Posición de la lista de materiales",
     T3."PrjCode" AS "Código de proyecto",
     T3."PRJUID" AS "Tarea",
     T3."RestChargeOff" AS "El problema persiste con la cantidad",
     T3."ROUND_DEC" AS "Disminución del redondeo",
     T3."ROUND_TYPE" AS "Tipo de redondeo - Redondeando a 0,5=0, Redondeando hacia arriba=1, Redondeando hacia abajo=2, Múltiplo de=3, Sin redondeo=-1",
     T3."SCHEINBAUGRUPPE" AS "creado por Phantom ItemCode",
     T3."SCHEINBAUGRUPPE_POS" AS "creado por Phantom Position",
     T3."SCHEINBAUGRUPPE_QTY" AS "creado por Phantom quantity",
     T3."SCHEINBAUGRUPPE_VERSION" AS "creado por Phantom IVersion",
     T3."ScrapPercent" AS "% de escaneo",
     T3."SHORTVARIANT" AS "Variante",
     T3."SortId" AS "Clasificar",
     T3."StlItemCode" AS "Creado por bom",
     T3."TOTALQUANTITY_WHUNIT" AS "total",
     T3."U_beas_ver" AS "Version",
     T3."U_znr" AS "Número de dibujo",
     T3."UDF1" AS "Campo de usuario 1",
     T3."UDF2" AS "Campo de usuario 2",
     T3."UDF3" AS "Campo de usuario 3",
     T3."UDF4" AS "Campo de usuario 4",
     T3."UDF5" AS "Campo de usuario 5",
     T3."UDF6" AS "Campo de usuario 6",
     T3."UDF7" AS "Campo de usuario 7",
     T3."UDF8" AS "Campo de usuario 8",
     T3."UDF9" AS "Campo de usuario 9",
     T3."UDF10" AS "Campo de usuario 10",
     T3."UDF11" AS "Campo de usuario 11",
     T3."UDF12" AS "Campo de usuario 12",
     T3."UDF13" AS "Campo de usuario 13",
     T3."UDF14" AS "Campo de usuario 14",
     T3."UDF15" AS "Campo de usuario 15",
     T3."UserText" AS "Texto adicional",
     T3."VK_ZUSCHLAG" AS "Recargo Costos Totales %",
     T3."VRI" AS "Configuracion",
     T3."WhsCode" AS "Deposito",
     T3."WST_ID" AS "Materia prima",
     T3."ZU_BELPOS_ID" AS "alineado para la posición de orden de trabajo"
     T3."INPUT_QTY" AS "Cantidad",

     T4."ABGKZ" AS "Cerrado - Orden de trabajo posicion",
     T4."ABGKZ_DATE",
     T4."ABGKZ_USER",
     T4."ACCOUNT_ITEM" AS "elemento de cuenta",
     T4."ACCOUNT_VARIANCE" AS "Variación de cuenta",
     T4."ACCOUNT_WIP" AS "Cuenta WIA",
     T4."ANDTSTAMP",
     T4."ANDUSER",
     T4."ANFZEIT" AS "hora de inicio",
     T4."ANFZEIT_FIX",
     T4."AUFTRAGHERKUNFT" AS "tipo base",
     T4."AUFTRAGINT" AS "Número base",
     T4."AUFTRAGPOS" AS "Número de línea base",
     T4."BarCode",
     T4."BaseDocNum",
     T4."BaseLine",
     T4."BASELINE2",
     T4."BaseType",
     T4."BELNR_ID",
     T4."BELPOS_ID",
     T4."BINCODE" AS "Ubicación del contenedor",
     T4."BOM_FIRSTDATE" AS "Requisitos de materiales Fecha de inicio",
     T4."BOM_ITEMS" AS "Artículo de requisitos de materiales",
     T4."BOM_OK" AS "Requisitos de materiales correctos",
     T4."BOM_TOLATE" AS "Material Requirements Shortage",
     T4."BOM_VERZUG" AS "Requisitos de materiales Verzug",
     T4."BPLId",
     T4."BPLName",
     T4."CanModifyWo",
     T4."CHARGE_ID" AS "Lote",
     T4."Confirmed",
     T4."DIN",
     T4."DocEntry",
     T4."DOCUMENTS",
     T4."DRUCKKZ" AS "Impreso",
     T4."ENDZEIT",
     T4."ERFTSTAMP",
     T4."ERFUSER",
     T4."EXPANDALL" AS "Descomponer siempre los subconjuntos",
     T4."FAG_GK_IST" AS "Operación externa MC Real",
     T4."FAG_GK_SOLL" AS "Plan MC de operación externa",
     T4."FAG_VK_IST" AS "Operación externa FC Real",
     T4."FAG_VK_SOLL",
     T4."FERTIGUNG_GEBUCHT" AS "ruta reservada",
     T4."FERTIGUNG_GK_IST" AS "Producción MC Real",
     T4."FERTIGUNG_GK_SOLL" AS "Plan MC de producción",
     T4."FERTIGUNG_VK_IST" AS "Plan de producción FC",
     T4."FERTIGUNG_VK_SOLL" AS "Plan de producción FC",
     T4."GEL_MENGE" AS "Completo",
     T4."GRUPPE",
     T4."HERSTELLUNG_GK_IST" AS "Production MC Actual",
     T4."HERSTELLUNG_GK_SOLL" AS "Production MC Plan",
     T4."HERSTELLUNG_VK_IST" AS "Production FC Actual",
     T4."HERSTELLUNG_VK_SOLL" AS "Production FC Plan",
     T4."InvntItem",
     T4."ISTZEIT",
     T4."ItemCode",
     T4."ItemName",
     T4."KALKBELNR_ID" AS "Precálculo",
     T4."KALKPOS" AS "Número de posición de cálculo",
     T4."LETZTE_NAKA",
     T4."LIEFERDATUM",
     T4."LK_BEWERTUNGSZEITRAUM" AS "último tiempo de cálculo",
     T4."LOHNZUSCHLAG_GK_IST" AS "Wage Allowance MC Actual",
     T4."LOHNZUSCHLAG_VK_IST" AS "Wage Allowance FC Actual",
     T4."Match",
     T4."MATERIAL_GEBUCHT",
     T4."MATERIAL_GK_IST" AS "Material MC real",
     T4."MATERIAL_GK_SOLL" AS "Plan MC de materiales",
     T4."MATERIAL_VK_IST" AS "Material FC real",
     T4."MATERIAL_VK_SOLL" AS "Plan de FC de materiales",
    T4."MATZUSCHLAG_GK_IST" AS "Provisión para material MC Real",
     T4."MATZUSCHLAG_VK_IST" AS "Provisión para material ME Real",
     T4."ME_LAGER",
     T4."ME_UMR",
     T4."ME_VERBRAUCH",
     T4."MENGE" AS "Qty. to produce in Whs Store unit",
     T4."MENGE_BESTELLT" AS "Quantity ordered",
     T4."MENGE_FERTIG_MAUELL" AS "Manually Finished Message Quantity",
     T4."MENGE_VERBRAUCH" AS "Qty. to produce in Usage inut",
     T4."MENGE_VERSCHNITT" AS "Cut-Off Quantity",
     T4."MIN_IST" AS "Actual Time",
     T4."MIN_SOLL" AS "Plan Time",
     T4."PrintDate" AS  "Print Date",
     T4."PRJUID" AS "Task",
     T4."Project" AS "Project",
     T4."QS_ID" AS "QC Inspection plan",
     T4."RevisionLevel" AS  "Revision",
     T4."RoutingId" AS  "Routing",
     T4."SCHEMA_ID" AS "Schema",
     T4."SELBSTKOSTEN_GK_IST" AS "Costo de ventas MC real",
     T4."SELBSTKOSTEN_GK_SOLL" AS "Cost of Sales MC Plan",
     T4."SELBSTKOSTEN_VK_IST" AS "Cost of Sales FC Actual",
     T4."SELBSTKOSTEN_VK_SOLL" AS "Cost of Sales FC Plan", 
     T4."SHORTVARIANT" AS "Variant"
    
     --T2.*
    
FROM BEAS_FTHAUPT T0  --Órdenes de trabajo
INNER JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Enrutamiento de producción
INNER JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"  --Recibo del tiempo de producción
INNER JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID" --Orden de trabajo Lista de materiales Artículo
INNER JOIN BEAS_FTPOS T4 ON T0."BELNR_ID" = T4."BELNR_ID" --Orden de trabajo Posición
WHERE 
 T0."BELNR_ID" = '31135'
--T0."ABGKZ" =  'N'
LIMIT 100

/* SOLICITUD DE COMPRAS DE MANTENIMIENTOS */
SELECT
    T0."DocNum" AS "Solicitud",
    T1."DocDate" AS "Fecha SC",
    T0."DocTime" AS "Hora SC",
    T4."Name",
    T3."DocNum" AS "DocNum Pedido",
    CASE
    WHEN T0."U_SYP_TIPCOMPRA" = '01' THEN 'NACIONAL'
    WHEN T0."U_SYP_TIPCOMPRA" = '02' THEN 'IMPORTADO'
    ELSE T0."U_SYP_TIPCOMPRA" END AS "TIPO DE COMPRA",
    T1."ItemCode",
    T1."Dscription",
    --T1."LineNum",
    T1."Quantity",
    T1."Price",
    T0."DocTotal",
    T6."DocNum" AS "DocNum EM",
    T6."DocDate" AS "Fecha EntradaM",
    T5."Quantity",
    T5."Price"
FROM OPRQ T0
INNER JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN POR1 T2 ON T1."TrgetEntry" = T2."DocEntry" AND T1."LineNum" = T2."BaseLine"
LEFT JOIN OPOR T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN OUDP T4 ON T0."Department" = T4."Code"
LEFT JOIN PDN1 T5 ON T3."DocEntry" = T5."BaseEntry" AND T2."LineNum" = T5."BaseLine" ANd T5."BaseType" = '22'
LEFT JOIN OPDN T6 ON T5."DocEntry" = T6."DocEntry"

WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T4."Name" = 'Mantenimiento'
--AND T0."U_SYP_TIPCOMPRA" = '01' AND T0."CANCELED" = 'N' --AND T0."DocNum" IN ('23001060')
--AND T4."CANCELED" = 'N'
ORDER BY T0."DocDate" ASC

/* sacar el precio de Articulo de almacen por ItemCode de la tabla OITW */
SELECT 
T0."WhsCode",T0."ItemCode", T0."AvgPrice" 
FROM OITW T0 
WHERE T0."AvgPrice" > 0 AND T0."ItemCode" = '03FEL03080525' AND T0."WhsCode" = '04PDP'



/* aqui se va a ñadir solo los campos que requiere el sr raul para ordenes de matenimientos  */
SELECT 
   T0."BELNR_ID" AS "N° Orden",
   T2."DisplayName" AS "Empleado",
   T1."AG_ID" AS "Recurso",
   CASE WHEN LENGTH(T1."AG_ID") = 6 THEN RIGHT(T1."AG_ID", 4) ELSE T1."AG_ID" END AS "Recurs",
   T1."BEZ" AS "Descripcion",
   T1."APLATZ_ID" AS "Centro de Trabajo",
   (T0."WORKTIME" / 60 ) AS "Tiempo",
   T2."PCOSTGK" AS "Costos laborales Costo marginal",
   T2."PCOSTVK" AS "Costo mano de obra",
   T2."EXTERNAL_COST" AS "Costo externo",
   T2."ANFZEIT" AS "Fecha inicio",
   TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio", 
   T2."ENDZEIT" AS "Fecha fin",
   TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Hora de finalizacion",
   T3."ART1_ID" AS "Codigo de articulo",
   T3."ItemName" AS "Repuesto",
   (
    SELECT MAX(A0."AvgPrice") 
    FROM OITW A0 
    WHERE 
      T3."ART1_ID" = A0."ItemCode"
      AND T3."WhsCode" = A0."WhsCode" 
      AND A0."AvgPrice" > 0
   ) AS "PrecioW",
   T3."MATERIALKOSTEN" AS "Costo de material",
   T3."INPUT_QTY" AS "Cantidad",
   --T3."MENGE_VERBRAUCH" AS "Cantidad.",
   (T3."MATERIALKOSTEN" * T3."INPUT_QTY") AS "Total",
    T4."ItemCode",
    T4."ItemName" AS "Mantenimiento",
    T0."TYP" AS "Tipo mantenimiento",
    
    T1."BEZ",
    T2."GRUND",
    --T0."DocEntry"

    A0."DocNum" AS "Solicitud",
    A0."DocDate" AS "Fecha SC",
    A0."DocTime" AS "Hora SC"
    
FROM BEAS_FTHAUPT T0  --Órdenes de trabajo
LEFT JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Enrutamiento de producción
LEFT JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"  --Recibo del tiempo de producción
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID" --Orden de trabajo Lista de materiales Artículo
LEFT JOIN BEAS_FTPOS T4 ON T0."BELNR_ID" = T4."BELNR_ID" --Orden de trabajo Posición

LEFT JOIN OPRQ A0 ON A0."DocEntry" = (SELECT MAX(D0."DocEntry") FROM PRQ1 D0 WHERE D0."ItemCode" = T3."ART1_ID") 

WHERE
   T0."TYP" != 'Produccion' 
   --AND T0."ABGKZ" =  'J'
    --AND T3."ART1_ID" = '03FMC03030164'
   AND T0."BELNR_ID" >= '15711'
ORDER BY 
  T0."BELNR_ID" DESC

/* example 1  */
SELECT 
   T0."BELNR_ID" AS "N° Orden",
   T2."DisplayName" AS "Empleado",
   T1."AG_ID" AS "Recurso",
   CASE WHEN LENGTH(T1."AG_ID") = 6 THEN RIGHT(T1."AG_ID", 4) ELSE T1."AG_ID" END AS "Recurs",
   T1."BEZ" AS "Descripcion",
   T1."APLATZ_ID" AS "Centro de Trabajo",
   (T0."WORKTIME" / 60 ) AS "Tiempo",
   T2."PCOSTGK" AS "Costos laborales Costo marginal",
   T2."PCOSTVK" AS "Costo mano de obra",
   T2."EXTERNAL_COST" AS "Costo externo",
   T2."ANFZEIT" AS "Fecha inicio",
   TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio", 
   T2."ENDZEIT" AS "Fecha fin",
   TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Hora de finalizacion",
   T3."ART1_ID" AS "Codigo de articulo",
   T3."ItemName" AS "Repuesto",
   (SELECT MAX(A0."AvgPrice") FROM OITW A0 
    WHERE T3."ART1_ID" = A0."ItemCode" AND T3."WhsCode" = A0."WhsCode" AND A0."AvgPrice" > 0
   ) AS "PrecioW",
   T3."MATERIALKOSTEN" AS "Costo de material",
   T3."INPUT_QTY" AS "Cantidad",
   --T3."MENGE_VERBRAUCH" AS "Cantidad.",
   (T3."MATERIALKOSTEN" * T3."INPUT_QTY") AS "Total",
    T4."ItemCode",
    T4."ItemName" AS "Mantenimiento",
    T0."TYP" AS "Tipo mantenimiento",
    
    T1."BEZ",
    T2."GRUND",
    
    A0."DocEntry",
    A0."DocNum" AS "Solicitud",
    A0."DocDate" AS "Fecha SC",
    A0."DocTime" AS "Hora SC",
    A1."Name",
    A2."DocNum" AS "DocNum Pedido",
    CASE
      WHEN A0."U_SYP_TIPCOMPRA" = '01' THEN 'NACIONAL'
      WHEN A0."U_SYP_TIPCOMPRA" = '02' THEN 'IMPORTADO'
      ELSE A0."U_SYP_TIPCOMPRA" 
    END AS "TIPO DE COMPRA"

  
    --B0."ItemCode"

    /*A01."ItemCode",
    A01."Dscription",
    A01."Quantity",
    A01."Price"*/
   

  
FROM BEAS_FTHAUPT T0  --Órdenes de trabajo
LEFT JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Enrutamiento de producción
LEFT JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"  --Recibo del tiempo de producción
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID" --Orden de trabajo Lista de materiales Artículo
LEFT JOIN BEAS_FTPOS T4 ON T0."BELNR_ID" = T4."BELNR_ID" --Orden de trabajo Posición

LEFT JOIN OPRQ A0 ON A0."DocEntry" = (
  SELECT 
    MAX(D0."DocEntry")
  FROM PRQ1 D0 
  WHERE D0."ItemCode" = T3."ART1_ID"
) 
 
--LEFT JOIN PRQ1 A01 ON A01."DocEntry" = A0."DocEntry"
LEFT JOIN OUDP A1 ON A1."Code" = A0."Department"

LEFT JOIN OPOR A2 ON A2."DocEntry" = A0."DocEntry"

WHERE
   T0."TYP" != 'Produccion' 
   --AND T0."ABGKZ" =  'J'
    --AND T3."ART1_ID" = '03FMC03030164'
   AND T0."BELNR_ID" >= '15711'
   AND A1."Name" = 'Mantenimiento'
ORDER BY 
  T0."BELNR_ID" DESC

/* example 2  SOLO QUEDA QUE APRUEBE EL SR RAUL */
SELECT 
   T0."BELNR_ID" AS "N° Orden",
   T2."DisplayName" AS "Empleado",
   T1."AG_ID" AS "Recurso",
   CASE WHEN LENGTH(T1."AG_ID") = 6 THEN RIGHT(T1."AG_ID", 4) ELSE T1."AG_ID" END AS "Recurs",
   T1."BEZ" AS "Descripcion",
   T1."APLATZ_ID" AS "Centro de Trabajo",
   (T0."WORKTIME" / 60) AS "Tiempo",
   T2."PCOSTGK" AS "Costos laborales Costo marginal",
   T2."PCOSTVK" AS "Costo mano de obra",
   T2."EXTERNAL_COST" AS "Costo externo",
   T2."ANFZEIT" AS "Fecha inicio",
   TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio", 
   T2."ENDZEIT" AS "Fecha fin",
   TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Hora de finalizacion",
   T3."ART1_ID" AS "Codigo de articulo",
   T3."ItemName" AS "Repuesto",

   -- Subconsulta para obtener el PrecioW
   (SELECT MAX(A0."AvgPrice") FROM OITW A0 
    WHERE T3."ART1_ID" = A0."ItemCode" AND T3."WhsCode" = A0."WhsCode" AND A0."AvgPrice" > 0
   ) AS "PrecioW",

   T3."MATERIALKOSTEN" AS "Costo de material",
   T3."INPUT_QTY" AS "Cantidad",
   (T3."MATERIALKOSTEN" * T3."INPUT_QTY") AS "Total",
    T4."ItemCode",
    T4."ItemName" AS "Mantenimiento",
    T0."TYP" AS "Tipo mantenimiento",

    -- Campos del segundo query
    A0."DocNum" AS "Solicitud",
    A0."Fecha SC",
    A0."DocTime",
    A0."Name",
    A0."DocNum Pedido",
    A0."TIPO DE COMPRA",
    A0."ItemCode",
    A0."Dscription",
    A0."CantidadC",
    A0."PrecioDescuento",
    A0."DocTotal",
    A0."DocNum EM",
    A0."Fecha EntradaM",
    A0."CantidadM",
    A0."Price"

FROM BEAS_FTHAUPT T0  -- Órdenes de trabajo
LEFT JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID"
LEFT JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID"
LEFT JOIN BEAS_FTPOS T4 ON T0."BELNR_ID" = T4."BELNR_ID"


LEFT JOIN (
    SELECT 
        T0."DocNum" AS "DocNum", 
        T1."DocDate" AS "Fecha SC", 
        T0."DocTime", 
        T4."Name", 
        T3."DocNum" AS "DocNum Pedido", 
        CASE
            WHEN T0."U_SYP_TIPCOMPRA" = '01' THEN 'NACIONAL'
            WHEN T0."U_SYP_TIPCOMPRA" = '02' THEN 'IMPORTADO'
            ELSE T0."U_SYP_TIPCOMPRA"
        END AS "TIPO DE COMPRA", 
        T1."ItemCode", 
        T1."Dscription", 
        T1."Quantity" AS "CantidadC", 
        T1."Price" AS "PrecioDescuento", 
        T0."DocTotal", 
        T6."DocNum" AS "DocNum EM", 
        T6."DocDate" AS "Fecha EntradaM", 
        T5."Quantity"  AS "CantidadM", 
        T5."Price"
    FROM OPRQ T0
    INNER JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"
    LEFT JOIN POR1 T2 ON T1."TrgetEntry" = T2."DocEntry" AND T1."LineNum" = T2."BaseLine"
    LEFT JOIN OPOR T3 ON T2."DocEntry" = T3."DocEntry"
    LEFT JOIN OUDP T4 ON T0."Department"= T4."Code"
    LEFT JOIN PDN1 T5 ON T3."DocEntry" = T5."BaseEntry" AND T2."LineNum" = T5."BaseLine" AND T5."BaseType" = '22'
    LEFT JOIN OPDN T6 ON T5."DocEntry" = T6."DocEntry"
    WHERE T4."Name" = 'Mantenimiento'
) A0 ON A0."ItemCode" = T3."ART1_ID" 

WHERE
   T0."TYP" != 'Produccion' 
   AND T0."BELNR_ID" >= '15711'
ORDER BY 
     T2."ANFZEIT"
  --T0."BELNR_ID" DESC;


  /* example 3 */


  SELECT 
   T0."BELNR_ID" AS "N° Orden",
   T2."DisplayName" AS "Empleado",
   T1."AG_ID" AS "Recurso",
   CASE WHEN LENGTH(T1."AG_ID") = 6 THEN RIGHT(T1."AG_ID", 4) ELSE T1."AG_ID" END AS "Recurs",
   T1."BEZ" AS "Descripcion",
   T1."APLATZ_ID" AS "Centro de Trabajo",
   (T0."WORKTIME" / 60) AS "Tiempo",
   T2."PCOSTGK" AS "Costos laborales Costo marginal",
   T2."PCOSTVK" AS "Costo mano de obra",
   T2."EXTERNAL_COST" AS "Costo externo",
   T2."ANFZEIT" AS "Fecha inicio",
   TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio", 
   T2."ENDZEIT" AS "Fecha fin",
   TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Hora de finalizacion",
   T3."ART1_ID" AS "Codigo de articulo",
   T3."ItemName" AS "Repuesto",

   -- Subconsulta para obtener el PrecioW
   (SELECT MAX(A0."AvgPrice") FROM OITW A0 
    WHERE T3."ART1_ID" = A0."ItemCode" AND T3."WhsCode" = A0."WhsCode" AND A0."AvgPrice" > 0
   ) AS "PrecioW",

   T3."MATERIALKOSTEN" AS "Costo de material",
   T3."INPUT_QTY" AS "Cantidad",
   (T3."MATERIALKOSTEN" * T3."INPUT_QTY") AS "Total",
    T4."ItemCode",
    T4."ItemName" AS "Mantenimiento",
    T0."TYP" AS "Tipo mantenimiento",

    -- Campos del segundo query
    A0."DocNum" AS "Solicitud",
    A0."Fecha SC",
    A0."DocTime",
    A0."Name",
    A0."DocNum Pedido",
    A0."TIPO DE COMPRA",
    A0."ItemCode",
    A0."Dscription",
    A0."CantidadC",
    A0."PrecioDescuento",
    A0."DocTotal",
    A0."DocNum EM",
    A0."Fecha EntradaM",
    A0."CantidadM",
    A0."Price"

FROM BEAS_FTHAUPT T0  -- Órdenes de trabajo
LEFT JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID"
LEFT JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID"
LEFT JOIN BEAS_FTPOS T4 ON T0."BELNR_ID" = T4."BELNR_ID"


LEFT JOIN (
    SELECT 
        T0."DocNum" AS "DocNum", 
        T1."DocDate" AS "Fecha SC", 
        T0."DocTime", 
        T4."Name", 
        T3."DocNum" AS "DocNum Pedido", 
        CASE
            WHEN T0."U_SYP_TIPCOMPRA" = '01' THEN 'NACIONAL'
            WHEN T0."U_SYP_TIPCOMPRA" = '02' THEN 'IMPORTADO'
            ELSE T0."U_SYP_TIPCOMPRA"
        END AS "TIPO DE COMPRA", 
        T1."ItemCode", 
        T1."Dscription", 
        T1."Quantity" AS "CantidadC", 
        T1."Price" AS "PrecioDescuento", 
        T0."DocTotal", 
        T6."DocNum" AS "DocNum EM", 
        T6."DocDate" AS "Fecha EntradaM", 
        T5."Quantity"  AS "CantidadM", 
        T5."Price"
    FROM OPRQ T0  --SOLICITUD DE COMPRA
    INNER JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"  --SOLICITUD DE COMPRA FILA
    LEFT JOIN POR1 T2 ON T1."TrgetEntry" = T2."DocEntry" AND T1."LineNum" = T2."BaseLine" --Pedido Lineas
    LEFT JOIN OPOR T3 ON T2."DocEntry" = T3."DocEntry"  --PEDIDO
    LEFT JOIN OUDP T4 ON T0."Department"= T4."Code"  --departamento
    LEFT JOIN PDN1 T5 ON T3."DocEntry" = T5."BaseEntry" AND T2."LineNum" = T5."BaseLine" AND T5."BaseType" = '22' --Pedido de entrada de mercancías - Filas
    LEFT JOIN OPDN T6 ON T5."DocEntry" = T6."DocEntry" --Pedido de entrada de mercancías
    WHERE T4."Name" = 'Mantenimiento'
) A0 ON A0."ItemCode" = T3."ART1_ID" 

WHERE
   T0."TYP" != 'Produccion' 
   --AND T0."BELNR_ID" >= '15711'
  AND T0."BELNR_ID" = '30095'
ORDER BY 
     T2."ANFZEIT"
  --T0."BELNR_ID" DESC;

  /* NUEVA QUERY  */
  SELECT
    --T0."ABGKZ",
   T1."ABGKZ", 
   T0."BELNR_ID" AS "N° Orden",
   T2."ANFZEIT" AS "Fecha inicio",
   TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio", 
   T2."ENDZEIT" AS "Fecha fin",
   TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Hora de finalizacion",
   T2."DisplayName" AS "Tecnico MTTO",
   CASE WHEN LENGTH(T1."AG_ID") = 6 THEN RIGHT(T1."AG_ID", 4) ELSE T1."AG_ID" END AS "Recurso",
   (T0."WORKTIME" / 60) AS "Duracion Del MTTO",
   T3."ART1_ID" AS "Codigo de articulo",
   T3."ItemName" AS "Descripcion del articulo",
   T3."MENGE_LAGER" AS "Cantidad consumida",
   T3."MATERIALKOSTEN" AS "Precio unitario",
   (T3."MATERIALKOSTEN" * T3."MENGE_LAGER") AS "Precio Total",
   T4."ItemName" AS "MTTO",
   T0."TYP" AS "Tipo MTTO",
   
   T1."BEZ" AS "Comentario en la orden",
   T2."GRUND" AS "Comentario del tecnico"
  
    
  

FROM BEAS_FTHAUPT T0  --Órdenes de trabajo
LEFT JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Enrutamiento de producción
LEFT JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"  --Recibo del tiempo de producción
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID" --Orden de trabajo Lista de materiales Artículo
LEFT JOIN BEAS_FTPOS T4 ON T0."BELNR_ID" = T4."BELNR_ID" --Orden de trabajo Posición

WHERE
   T0."TYP" != 'Produccion' 
    AND T0."BELNR_ID" = '30095'
    AND T1."ABGKZ" = 'J'
   --AND T0."BELNR_ID" >= '15711'
ORDER BY 
  T0."BELNR_ID" DESC


  /* otra query */
  SELECT
    --T0."ABGKZ",
   T1."BELPOS_ID",
   T1."ABGKZ", 
   T0."BELNR_ID" AS "N° Orden",
   T2."ANFZEIT" AS "Fecha inicio",
   TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio", 
   T2."ENDZEIT" AS "Fecha fin",
   TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Hora de finalizacion",
   T2."DisplayName" AS "Tecnico MTTO",
   CASE WHEN LENGTH(T1."AG_ID") = 6 THEN RIGHT(T1."AG_ID", 4) ELSE T1."AG_ID" END AS "Recurso",
   (T0."WORKTIME" / 60) AS "Duracion Del MTTO",
   T3."ART1_ID" AS "Codigo de articulo",
   T3."ItemName" AS "Descripcion del articulo",
   T3."MENGE_LAGER" AS "Cantidad consumida",
   T3."MATERIALKOSTEN" AS "Precio unitario",
   (T3."MATERIALKOSTEN" * T3."MENGE_LAGER") AS "Precio Total",
   T4."ItemName" AS "MTTO",
   T0."TYP" AS "Tipo MTTO",
   
   T1."BEZ" AS "Comentario en la orden",
   T2."GRUND" AS "Comentario del tecnico",
   
   A0."U_beas_belnrid",
   A0."U_beas_belposid"
    
  
    

FROM BEAS_FTHAUPT T0  --Órdenes de trabajo
LEFT JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Enrutamiento de producción
LEFT JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"  --Recibo del tiempo de producción
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID" --Orden de trabajo Lista de materiales Artículo
LEFT JOIN BEAS_FTPOS T4 ON T0."BELNR_ID" = T4."BELNR_ID" --Orden de trabajo Posición

LEFT JOIN (
  SELECT
    T1."U_beas_belnrid",
    T1."U_beas_belposid",
    T0."DocNum", 
    --T0."DocType", 
    --T0."CANCELED", 
    T2."CardName",
    T4."DocNum", --orden de compra
    T3."Dscription",
    T3."Price",
    T3."VatSumSy" AS "Iva",
    (T3."Price" + T3."VatSumSy") AS "Costo total servicio externo"
  
     --T3.*
     --T4.*

     /*T1."DocEntry",
     T1."ItemCode", 
     T1."Dscription", 
     T1."LineVendor",
     T1."U_beas_belnrid",  --Num OT
     T1."U_beas_belposid",
     T1."U_beas_posid"*/
  FROM OPRQ T0  
  INNER JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"
  INNER JOIN OCRD T2 ON T1."LineVendor" = T2."CardCode"
  INNER JOIN POR1 T3 ON  T1."TrgetEntry" = T3."DocEntry" AND T1."LineNum" = T3."BaseLine"
  INNER JOIN OPOR T4 ON T3."DocEntry" = T4."DocEntry" 
  WHERE
    T0."DocType" = 'S'
    AND T0."CANCELED" = 'N' 
    AND T0."DocNum" = '24000770'
) A0 ON A0."U_beas_belnrid" = T0."BELNR_ID"  AND A0."U_beas_belposid" = T1."BELPOS_ID"

WHERE
   T0."TYP" != 'Produccion' 
    AND T0."BELNR_ID" = '30095'
    AND T1."ABGKZ" = 'J'
   --AND T0."BELNR_ID" >= '15711'
ORDER BY 
  T0."BELNR_ID" DESC


  /* Solicitud de compra */
SELECT 
  T0."DocNum", 
  --T0."DocType", 
  --T0."CANCELED", 
  T2."CardName",
  T4."DocNum", --orden de compra
  T3."Dscription",
  T3."Price",
  T3."VatSumSy" AS "Iva",
  (T3."Price" + T3."VatSumSy") AS "Costo total servicio externo"
  
   --T3.*
  --T4.*

  /*T1."DocEntry",
  T1."ItemCode", 
  T1."Dscription", 
  T1."LineVendor",
  T1."U_beas_belnrid",  --Num OT
  T1."U_beas_belposid",
  T1."U_beas_posid"*/
FROM OPRQ T0  
INNER JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OCRD T2 ON T1."LineVendor" = T2."CardCode"
INNER JOIN POR1 T3 ON  T1."TrgetEntry" = T3."DocEntry" AND T1."LineNum" = T3."BaseLine"
INNER JOIN OPOR T4 ON T3."DocEntry" = T4."DocEntry" 
WHERE
  T0."DocType" = 'S'
  AND T0."CANCELED" = 'N' 
  AND T0."DocNum" = '24000770'



  /* pruebas union*/

  -- Primera consulta
SELECT
    T1."BELPOS_ID",
    T1."ABGKZ", 
    T0."BELNR_ID" AS "N° Orden",
    T2."ANFZEIT" AS "Fecha inicio",
    TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio", 
    T2."ENDZEIT" AS "Fecha fin",
    TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Hora de finalizacion",
    T2."DisplayName" AS "Tecnico MTTO",
    CASE WHEN LENGTH(T1."AG_ID") = 6 THEN RIGHT(T1."AG_ID", 4) ELSE T1."AG_ID" END AS "Recurso",
    (T0."WORKTIME" / 60) AS "Duracion Del MTTO",
    T3."ART1_ID" AS "Codigo de articulo",
    T3."ItemName" AS "Descripcion del articulo",
    T3."MENGE_LAGER" AS "Cantidad consumida",
    T3."MATERIALKOSTEN" AS "Precio unitario",
    (T3."MATERIALKOSTEN" * T3."MENGE_LAGER") AS "Precio Total",
    T4."ItemName" AS "MTTO",
    T0."TYP" AS "Tipo MTTO",
    T1."BEZ" AS "Comentario en la orden",
    T2."GRUND" AS "Comentario del tecnico",
    
    NULL AS "DocNum",  -- Columna para DocNum de la segunda consulta
    NULL AS "CardName", -- Columna para CardName de la segunda consulta
    NULL AS "Orden de compra", -- Columna para Orden de compra
    NULL AS "Dscription", -- Columna para Dscription
    NULL AS "Price", -- Columna para Price
    NULL AS "Iva", -- Columna para Iva
    NULL AS "Costo total servicio externo" -- Columna para Costo total servicio externo

FROM BEAS_FTHAUPT T0  -- Órdenes de trabajo
LEFT JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID"
LEFT JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID"
LEFT JOIN BEAS_FTPOS T4 ON T0."BELNR_ID" = T4."BELNR_ID"

WHERE
   T0."TYP" != 'Produccion' 
   AND T0."BELNR_ID" = '30095'
   AND T1."ABGKZ" = 'J'

UNION ALL

-- Segunda consulta
SELECT 
    NULL AS "BELPOS_ID",  -- Columna para BELPOS_ID de la primera consulta
    NULL AS "ABGKZ",      -- Columna para ABGKZ de la primera consulta
    OPRQ.DocNum AS "N° Orden", 
    NULL AS "Fecha inicio", 
    NULL AS "Hora de inicio", 
    NULL AS "Fecha fin", 
    NULL AS "Hora de finalizacion", 
    NULL AS "Tecnico MTTO", 
    NULL AS "Recurso", 
    NULL AS "Duracion Del MTTO", 
    NULL AS "Codigo de articulo", 
    NULL AS "Descripcion del articulo", 
    NULL AS "Cantidad consumida", 
    NULL AS "Precio unitario", 
    NULL AS "Precio Total", 
    NULL AS "MTTO", 
    NULL AS "Tipo MTTO", 

    PRQ1.LineVendor,  -- Puedes ajustar esto según lo que necesites
    OCRD.CardName,
    OPOR.DocNum, -- Orden de compra
    POR1.Dscription,
    POR1.Price,
    POR1.VatSumSy AS "Iva",
    (POR1.Price + POR1.VatSumSy) AS "Costo total servicio externo"

FROM OPRQ  
INNER JOIN PRQ1 ON OPRQ.DocEntry = PRQ1.DocEntry
INNER JOIN OCRD ON PRQ1.LineVendor = OCRD.CardCode
INNER JOIN POR1 ON PRQ1.TrgetEntry = POR1.DocEntry AND PRQ1.LineNum = POR1.BaseLine
INNER JOIN OPOR ON POR1.DocEntry = OPOR.DocEntry 

WHERE
   OPRQ.DocType = 'S'
   AND OPRQ.CANCELED = 'N' 
   AND OPRQ.DocNum = '24000770'; -- NumOrdenTrabajo




----------------
  SELECT
    -- Datos de la primera consulta
    T1."BELPOS_ID",
    T1."ABGKZ", 
    T0."BELNR_ID" AS "N° Orden",
    T2."ANFZEIT" AS "Fecha inicio",
    TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio", 
    T2."ENDZEIT" AS "Fecha fin",
    TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Hora de finalizacion",
    T2."DisplayName" AS "Tecnico MTTO",
    CASE WHEN LENGTH(T1."AG_ID") = 6 THEN RIGHT(T1."AG_ID", 4) ELSE T1."AG_ID" END AS "Recurso",
    (T0."WORKTIME" / 60) AS "Duracion Del MTTO",
    T3."ART1_ID" AS "Codigo de articulo",
    T3."ItemName" AS "Descripcion del articulo",
    T3."MENGE_LAGER" AS "Cantidad consumida",
    T3."MATERIALKOSTEN" AS "Precio unitario",
    (T3."MATERIALKOSTEN" * T3."MENGE_LAGER") AS "Precio Total",
    T4."ItemName" AS "MTTO",
    T0."TYP" AS "Tipo MTTO",
    T1."BEZ" AS "Comentario en la orden",
    T2."GRUND" AS "Comentario del tecnico",

    -- Datos de la segunda consulta
    OPRQ.DocNum, 
    OCRD.CardName,
    OPOR.DocNum AS "Orden de compra", 
    POR1.Dscription,
    POR1.Price,
    POR1.VatSumSy AS "Iva",
    (POR1.Price + POR1.VatSumSy) AS "Costo total servicio externo"
    
FROM BEAS_FTHAUPT T0  -- Órdenes de trabajo
LEFT JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID"  -- Enrutamiento de producción
LEFT JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"  -- Recibo del tiempo de producción
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID" -- Orden de trabajo Lista de materiales Artículo
LEFT JOIN BEAS_FTPOS T4 ON T0."BELNR_ID" = T4."BELNR_ID" -- Orden de trabajo Posición 

-- Unir con la segunda consulta
INNER JOIN OPRQ ON OPRQ.DocNum = T0.BELNR_ID -- Relación entre la orden de trabajo y la orden de compra
INNER JOIN PRQ1 ON OPRQ.DocEntry = PRQ1.DocEntry
INNER JOIN OCRD ON PRQ1.LineVendor = OCRD.CardCode
INNER JOIN POR1 ON PRQ1.TrgetEntry = POR1.DocEntry AND PRQ1.LineNum = POR1.BaseLine
INNER JOIN OPOR ON POR1.DocEntry = OPOR.DocEntry 

WHERE
   T0."TYP" != 'Produccion' 
   AND T0."BELNR_ID" = '30095'
   AND T1."ABGKZ" = 'J'
   AND OPRQ.DocType = 'S'
   AND OPRQ.CANCELED = 'N' 
   AND OPRQ.DocNum = '24000770' -- NumOrdenTrabajo

ORDER BY 
  T0."BELNR_ID" DESC;


  -- *******************************************************************

  SELECT
   T0."BELNR_ID" AS "N° Orden",
   T2."ANFZEIT" AS "Fecha inicio",
   TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio", 
   T2."ENDZEIT" AS "Fecha fin",
   TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Hora de finalizacion",
   T2."DisplayName" AS "Tecnico MTTO",
   CASE WHEN LENGTH(T1."AG_ID") = 6 THEN RIGHT(T1."AG_ID", 4) ELSE T1."AG_ID" END AS "Recurso",
   (T0."WORKTIME" / 60) AS "Duracion Del MTTO",
   T3."ART1_ID" AS "Codigo de articulo",
   T3."ItemName" AS "Descripcion del articulo",
   T3."MENGE_LAGER" AS "Cantidad consumida",
   T3."MATERIALKOSTEN" AS "Precio unitario",
   (T3."MATERIALKOSTEN" * T3."MENGE_LAGER") AS "Precio Total",
   T4."ItemName" AS "MTTO",
   T0."TYP" AS "Tipo MTTO",
   
   T1."BEZ" AS "Comentario en la orden",
   T2."GRUND" AS "Comentario del tecnico",

    NULL AS "DocNum" --,
 
    /*NULL AS "CardName", 
    NULL AS "Orden de compra", 
    NULL AS "Dscription", 
    NULL AS "Price",
    NULL AS "Iva", 
    NULL AS "Costo total servicio externo" */ 
   
FROM BEAS_FTHAUPT T0  --Órdenes de trabajo
LEFT JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Enrutamiento de producción
LEFT JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"  --Recibo del tiempo de producción
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID" --Orden de trabajo Lista de materiales Artículo
LEFT JOIN BEAS_FTPOS T4 ON T0."BELNR_ID" = T4."BELNR_ID" --Orden de trabajo Posición

WHERE
   T0."TYP" != 'Produccion' 
    AND T0."BELNR_ID" = '30095'
    AND T1."ABGKZ" = 'J'
   --AND T0."BELNR_ID" >= '15711'
ORDER BY 
  T0."BELNR_ID" DESC

UNION ALL

SELECT 
    A0."DocNum" AS "N° Orden", 
    NULL AS "Fecha inicio", 
    NULL AS "Hora de inicio", 
    NULL AS "Fecha fin", 
    NULL AS "Hora de finalizacion", 
    NULL AS "Tecnico MTTO", 
    NULL AS "Recurso", 
    NULL AS "Duracion Del MTTO", 
    NULL AS "Codigo de articulo", 
    NULL AS "Descripcion del articulo", 
    NULL AS "Cantidad consumida", 
    NULL AS "Precio unitario", 
    NULL AS "Precio Total", 
    NULL AS "MTTO", 
    NULL AS "Tipo MTTO", 

    A0."DocNum" AS "DocNum"

    /*PRQ1.LineVendor,  
    OCRD.CardName,
    POR1.Dscription,
    POR1.Price,
    POR1.VatSumSy AS "Iva",
    (POR1.Price + POR1.VatSumSy) AS "Costo total servicio externo"*/


FROM OPRQ A0  
INNER JOIN PRQ1 A1 ON A0."DocEntry" = A1."DocEntry"
INNER JOIN OCRD A2 ON A1."LineVendor" = A2."CardCode"
INNER JOIN POR1 A3 ON A1."TrgetEntry" = A3."DocEntry" AND A1."LineNum" = A3."BaseLine"
INNER JOIN OPOR A4 ON A3."DocEntry" = A4."DocEntry" 

WHERE
   A0."DocType" = 'S'
   AND A0."CANCELED" = 'N' 
   AND A0."DocNum" = '24000770'; -- NumOrdenTrabajo


/* APROBADO 22-11-2024 Listo terminado las ordenes de mantenimiento incluido la Solictud de compra */
SELECT
   T0."BELNR_ID" AS "N° Orden",
   T2."ANFZEIT" AS "Fecha inicio",
   TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio", 
   T2."ENDZEIT" AS "Fecha fin",
   TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Hora de finalizacion",
   T2."DisplayName" AS "Tecnico MTTO",
   T1."AG_ID" AS "Recurs",
   CASE WHEN LENGTH(T1."AG_ID") = 6 THEN RIGHT(T1."AG_ID", 4) ELSE T1."AG_ID" END AS "Recurso",
   (T0."WORKTIME" / 60) AS "Duracion Del MTTO",
   T3."ART1_ID" AS "Num de articulo",
   T3."ItemName" AS "Descripcion del articulo",
   T3."MENGE_LAGER" AS "Cantidad consumida",
   T3."MATERIALKOSTEN" AS "Precio unitario",
   (T3."MATERIALKOSTEN" * T3."MENGE_LAGER") AS "Precio Total",
   T4."ItemName" AS "MTTO",
   T0."TYP" AS "Tipo MTTO",

    NULL AS "Solicitud de compra",
    NULL AS "Proveedor",
    NULL AS "Orden de compra",
    NULL AS "Descripcion servicio externo",
    NULL AS "Costo servicio externo",
    NULL AS "Iva",
    NULL AS "Costo total servicio externo", 

   T1."BEZ" AS "Comentario en la orden",
   T2."GRUND" AS "Comentario del tecnico"

FROM BEAS_FTHAUPT T0  --Órdenes de trabajo
LEFT JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Enrutamiento de producción
LEFT JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"  --Recibo del tiempo de producción
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID" --Orden de trabajo Lista de materiales Artículo
LEFT JOIN BEAS_FTPOS T4 ON T0."BELNR_ID" = T4."BELNR_ID" --Orden de trabajo Posición

WHERE
    T0."TYP" != 'Produccion' 
    AND T0."BELNR_ID" >= '15711'
    AND T1."ABGKZ" = 'J'
    --AND T0."BELNR_ID" = '30095'

   
UNION ALL

SELECT 
    A1."U_beas_belnrid" AS "N° Orden", 
    NULL AS "Fecha inicio", 
    NULL AS "Hora de inicio", 
    NULL AS "Fecha fin", 
    NULL AS "Hora de finalizacion", 
    NULL AS "Tecnico MTTO",
    NULL AS "Recurs", 
    NULL AS "Recurso", 
    NULL AS "Duracion Del MTTO", 
    NULL AS "Num de articulo", 
    NULL AS "Descripcion del articulo", 
    NULL AS "Cantidad consumida", 
    NULL AS "Precio unitario", 
    NULL AS "Precio Total", 
    NULL AS "MTTO", 
    NULL AS "Tipo MTTO",
    A0."DocNum" AS "Solicitud de compra",
    A2."CardName" AS "Proveedor",
    A4."DocNum" AS "Orden de compra",
    A3."Dscription" AS "Descripcion servicio externo",
    A3."Price" AS "Costo servicio externo",
    A3."VatSumSy" AS "Iva",
    (A3."Price" + A3."VatSumSy") AS "Costo total servicio externo",

   NULL AS "Comentario en la orden",
   NULL AS "Comentario del tecnico"

FROM OPRQ A0  
LEFT JOIN PRQ1 A1 ON A0."DocEntry" = A1."DocEntry"
LEFT JOIN OCRD A2 ON A1."LineVendor" = A2."CardCode"
LEFT JOIN POR1 A3 ON A1."TrgetEntry" = A3."DocEntry" AND A1."LineNum" = A3."BaseLine"
LEFT JOIN OPOR A4 ON A3."DocEntry" = A4."DocEntry"
--WHERE A1."U_beas_belnrid" = '30095'
   --AND A0."DocNum" = '24000770'

--ORDER BY "N° Orden" DESC


/* Ordenes de mantenimiento anterior se va a remplazar */
SELECT T0."BELNR_ID" AS "N° Orden", /*T3."SortId", T1."BELPOS_ID", T1."POS_ID", T4."BELPOS_ID", T4."POS_ID",*/
T1."DisplayName" AS "Empleado", T4."AG_ID" AS "Recurso", 
CASE WHEN LENGTH(T4."AG_ID") = 6 THEN RIGHT(T4."AG_ID", 4) ELSE T4."AG_ID" END AS "Recurs", T7."BEZ",
T4."APLATZ_ID",(T0."WORKTIME" / 60 ) AS "Tiempo",  
T1."PCOSTVK", T1."KOSTEN_VK" AS "Costo mano de obra", T1."EXTERNAL_COST", T1."ANFZEIT" AS "Fecha inicio", T1."ENDZEIT" AS "Fecha fin",
T3."ART1_ID" AS "Número de artículo", T3."ItemName" AS "Repuesto", 
(SELECT MAX(A0."AvgPrice") FROM OITW A0 WHERE T3."ART1_ID" = A0."ItemCode" AND A0."AvgPrice" > 0) AS "PrecioW", 
T3."MATERIALKOSTEN" AS "Costo de material", T3."INPUT_QTY" AS "Cantidad", (T3."MATERIALKOSTEN" * T3."INPUT_QTY") AS "Total",T2."ItemCode", 
T2."ItemName" AS "Mantenimiento", T0."TYP" AS "Tipo mantenimiento", T6."BaseAmnt" AS "Costo Servicio", 
(T1."KOSTEN_VK" + T3."MATERIALKOSTEN" + T6."BaseAmnt") AS "Costo total", T5."DocEntry", T4."BEZ",
T1."GRUND"

FROM BEAS_FTHAUPT T0
LEFT JOIN BEAS_ARBZEIT T1 ON T0."BELNR_ID" = T1."BELNR_ID"
LEFT JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" 
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID"
LEFT JOIN BEAS_FTAPL T4 ON T0."BELNR_ID" = T4."BELNR_ID" AND T1."BELPOS_ID" = T4."BELPOS_ID" AND T1."POS_ID" = T4."POS_ID" --AND T3."SortId" = T4."SortId"
/*AND T3."BELPOS_ID" = T4."BELPOS_ID"  AND T4."POS_ID" = T3."POS_ID" AND T3."POS_TEXT" = T4."POS_TEXT" AND T3."SortId" = T4."SortId"
*/
LEFT JOIN PDN1 T5 ON T0."BELNR_ID" = T5."U_beas_belnrid" AND T4."BELPOS_ID" = T5."U_beas_belposid" AND T4."POS_ID" = T5."U_beas_posid"
LEFT JOIN OPDN T6 ON T5."DocEntry" = T6."DocEntry"
LEFT JOIN BEAS_APLATZ T7 ON RIGHT(UPPER(T4."AG_ID"), 4) = T7."APLATZ_ID"
WHERE T0."TYP" != 'Produccion' AND T0."BELNR_ID" 
--= '30710'
>= '15711'
ORDER BY T0."BELNR_ID" DESC
