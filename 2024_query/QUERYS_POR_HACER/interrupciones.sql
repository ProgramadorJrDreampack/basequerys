/* 
    El query solicitado Mant Realizar query de interrupciones por rango de fecha, 
    filtrando grupo de recursos, Recursos, Motivo de interrupcion Realizando agrupacion por duracion, 
    y cantidad de eventos

 */

/* EJEMPLO BASE */
SELECT 
    T0."ResourceGroup", 
    T1."ResourceName", 
    T2."InterruptionReason", 
    SUM(T3."Duration") AS TotalDuration, 
    COUNT(T3."EventID") AS EventCount
FROM 
    ResourceGroups T0
INNER JOIN 
    Resources T1 ON T0."GroupID" = T1."GroupID"
INNER JOIN 
    Interruptions T3 ON T1."ResourceID" = T3."ResourceID"
INNER JOIN 
    InterruptionReasons T2 ON T3."ReasonID" = T2."ReasonID"
WHERE 
    T3."InterruptionDate" BETWEEN [%0] AND [%1]
GROUP BY 
    T0."ResourceGroup", 
    T1."ResourceName", 
    T2."InterruptionReason"
ORDER BY 
    TotalDuration DESC;  -- ordenar por duración total


    /* Agrupacion de recursos 
    SELECT 
        T0."GRUPPE", 
        T0."BEZ", 
        T1."APLATZ_ID", 
        T1."BEZ" 
    FROM BEAS_APLATZGRUPPE T0
    INNER JOIN BEAS_APLATZ T1 ON T0."GRUPPE" = T1."GRUPPE"
    WHERE T1."Active" = 'J'
    
    */

    /*Recursos con tiempos y subfamilia
    SELECT 
    DISTINCT(P0."APLATZ_ID") as "Recurso", 
    CAST(P0."BEZ" AS VARCHAR) "Descripcion",
    --P0."ItemCode", P0."ItemName", 
    P0."F" as "Familia", 
    P0."SF" as "SubFamilia", 
    P0."InvntryUom", 
    P0."TRAPLATZ" as "Setup", 
    P0."TR2APLATZ" as "Tiempo preparacion", 
    P0."TEAPLATZ" as "Procesing", 
    P0."MENGE_ZEITJE" as "Tiempo minuto", 
    P0."MENGE_JE" as "Articulo terminado",
    P0."ZEITGRAD" as "Eficiencia"
    FROM
    (SELECT 
        T0."ItemCode", 
        T1."ItemName", 
        T2."Name" AS "F", 
        T3."Name" AS "SF", 
        T0."POS_ID", 
        T0."POS_TEXT", 
        T0."SortId", 
        T0."AG_ID", 
        T0."APLATZ_ID", 
        T0."BEZ", 
        T0."TRAPLATZ", 
        T0."TR2APLATZ", 
        T0."TEAPLATZ", 
        T0."MENGE_JE", 
        T0."MENGE_ZEITJE", 
        T0."TRTIMETYPE_ID", 
        T0."TIMETYPE_ID", 
        T0."PTIMETYPE_ID", 
        T0."AUSSCHUSSFAKTOR", 
        T0."UEBLGRZ", 
        T1."InvntryUom", 
        A0."ZEITGRAD"
    FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
    INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
    INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
    INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
    INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
    WHERE T1."validFor" = 'Y'
    ORDER BY T0."ItemCode", T0."SortId"

    ) P0
    WHERE 
        P0."APLATZ_ID" LIKE 'G%' AND 
        P0."APLATZ_ID" NOT LIKE 'GM%'-- AND P0."APLATZ_ID" IN ('G061', 'G080', 'G083')
    order by P0."APLATZ_ID", P0."F"
     */


     /* Ordenes de trabajo activo con insumos 
     --SELECT  *  FROM BEAS_FTSTL WHERE "ABGKZ" = 'N'
    SELECT 
    --T0."BELDAT",
    --T1.*,
    T0."BELDAT" As "Fecha Orden", 
    T0."KNDNAME" AS "Nombre Cliente", 
    T0."BELNR_ID" AS "Orden de Trabajo",
    T1."BELPOS_ID" AS "Posicion_OT",
    T2."ItemCode" AS "Item_Posicion",
    T2."ItemName" AS "Name_Posicion",
    T1."POS_ID" AS "Sub_Posicion",
    T1."ART1_ID" AS "Item_Sub_Posicion",
    T1."ItemName" AS "Name_Sub_Posicion",
    --T0."APLATZ_ID" AS "Maquina",
    T3."WhsCode" AS "Bodega",
    T1."TOTALQUANTITY_WHUNIT" AS "Planificado",
    T1."BookedQty" AS "Consumido",
    (T1."TOTALQUANTITY_WHUNIT" - T1."BookedQty") AS "Restante",
    T3."OnHand" AS "Stock_BP",
    CASE
    WHEN (T1."TOTALQUANTITY_WHUNIT" - T1."BookedQty" - T3."OnHand") < 0 THEN '0'
    ELSE (T1."TOTALQUANTITY_WHUNIT" - T1."BookedQty" - T3."OnHand") END AS "Faltante_BP",
    T4."OnHand" AS "Stock_BI"

    FROM BEAS_FTHAUPT T0
    INNER JOIN BEAS_FTSTL T1 ON T0."BELNR_ID" = T1."BELNR_ID"

    LEFT JOIN BEAS_FTPOS T2 ON T1."BELNR_ID" = T2."BELNR_ID" AND T1."BELPOS_ID" = T2."BELPOS_ID"
    LEFT JOIN OITW T3 ON T1."ART1_ID" = T3."ItemCode" AND T3."WhsCode" = T1."WhsCode"
    LEFT JOIN OITW T4 ON T1."ART1_ID" = T4."ItemCode" AND T4."WhsCode" = '02IND'

    WHERE T0."ABGKZ" = 'N'

    ORDER BY T1."BELNR_ID" DESC, T1."BELPOS_ID" ASC, T1."POS_ID" ASC 
      */


      /* Ordenes de mantenimientos  
    SELECT T0."BELNR_ID" AS "N° Orden", /*T3."SortId", T1."BELPOS_ID", T1."POS_ID", T4."BELPOS_ID", T4."POS_ID",*/
        T1."DisplayName" AS "Empleado", 
        T4."AG_ID" AS "Recurso", 
        CASE WHEN LENGTH(T4."AG_ID") = 6 THEN RIGHT(T4."AG_ID", 4) ELSE T4."AG_ID" END AS "Recurs", T7."BEZ",
        T4."APLATZ_ID",(T0."WORKTIME" / 60 ) AS "Tiempo",  
        T1."PCOSTVK", 
        T1."KOSTEN_VK" AS "Costo mano de obra", 
        T1."EXTERNAL_COST", 
        T1."ANFZEIT" AS "Fecha inicio", 
        T1."ENDZEIT" AS "Fecha fin",
        T3."ART1_ID" AS "Número de artículo", 
        T3."ItemName" AS "Repuesto", 
        (SELECT MAX(A0."AvgPrice") FROM OITW A0 WHERE T3."ART1_ID" = A0."ItemCode" AND A0."AvgPrice" > 0) AS "PrecioW", 
        T3."MATERIALKOSTEN" AS "Costo de material", 
        T3."INPUT_QTY" AS "Cantidad", 
        (T3."MATERIALKOSTEN" * T3."INPUT_QTY") AS "Total",
        T2."ItemCode", 
        T2."ItemName" AS "Mantenimiento",
        T0."TYP" AS "Tipo mantenimiento", 
        T6."BaseAmnt" AS "Costo Servicio", 
        (T1."KOSTEN_VK" + T3."MATERIALKOSTEN" + T6."BaseAmnt") AS "Costo total", 
        T5."DocEntry", 
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
      */

    /* Cierre de ordenes mes actual 
    SELECT 
        T0."KENNUNG1" As "Orden", 
        T0."AENDERUNGSTYP" as "Tipo", 
        T0."ERFTSTAMP" as "Fecha", 
        T0."ERFUSER" as "User", 
        T0."AppOrigin" as "Origen", 
        T0."STATIONNAME" as "Station", 
        T0."PERS_ID" as "Person", 
        T0."ERFTSTAMP" as "ChangeDate", 
        T0."ERFUSER" as "UserId", 
        T1."U_NAME", 
        T3."BELPOS_ID" as "Posicion", 
        T3."ItemCode", 
        T3."ItemName", 
        T3."MENGE" as "Planificado", 
        T3."GEL_MENGE" as "Cerrado"

    FROM "SBO_FIGURETTI_PRO"."BEAS_AENDERUNG" T0
    LEFT OUTER JOIN "SBO_FIGURETTI_PRO"."OUSR" T1 on T1."USER_CODE"=T0."ERFUSER"
    left outer join "SBO_FIGURETTI_PRO"."BEAS_PERS" T2 on T2."PERS_ID"=T0."PERS_ID"
    LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T3 ON T0."KENNUNG1" = T3."BELNR_ID"
    WHERE T0."NEUINHALT" = 'schliessen' AND T0."ERFUSER" != 'MAN01' 
    AND substring(T0."ERFTSTAMP", 6, 2) =  substring((Select CURRENT_DATE FROM DUMMY), 6, 2)
    AND substring(T0."ERFTSTAMP", 1, 4) = substring((Select CURRENT_DATE FROM DUMMY), 1, 4)
    --GROUP BY T0."KENNUNG1", T0."AENDERUNGSTYP", T0."ERFTSTAMP", T0."ERFUSER", T0."AppOrigin", T0."STATIONNAME", T0."PERS_ID", T0."ERFTSTAMP", T0."ERFUSER", T1."U_NAME"
      */




    -- ********************************************
  /* 
    El query solicitado Mant Realizar query de interrupciones por rango de fecha, 
    filtrando grupo de recursos, 
    Recursos, 
    Motivo de interrupcion 
    Realizando agrupacion por duracion, y cantidad de eventos
   */
    SELECT * FROM "BEASV_RESOURCES" LIMIT 10



    /* TRABAJANDO EN EL QUERY DE INTERRUPCIONES */


    --SELECT
    --T0.* 
--FROM "BEAS_APLATZGRUPPE" T0
--WHERE T0."ERFTSTAMP" BETWEEN '2023-01-01' AND '2023-01-02'
--LIMIT 100;

--FROM BEAS_FTPLANUNG T0
--FROM BEAS_MRP_ORDER T0


SELECT 
    T0."BELNR_ID" AS "N° Orden",
    T1."AG_ID" AS "Recurso", 
    CASE 
             WHEN 
                       LENGTH(T1."AG_ID") = 6 
                       THEN RIGHT(T1."AG_ID", 4) 
             ELSE T1."AG_ID" 
     END AS "Recurs", 
    T2."BEZ" AS "Descripcion",
    T0."BELDAT" AS "Fecha Pedido",
    --T1."APLATZ_ID",

    T0.*
    
FROM 
    BEAS_FTHAUPT  T0 
INNER JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID"
LEFT JOIN BEAS_APLATZ T2 ON RIGHT(UPPER(T1."AG_ID"), 4) = T2."APLATZ_ID"
WHERE T0."BELDAT" BETWEEN '2024-10-01' AND '2024-10-29'
ORDER BY T0."BELDAT";




/* ************ */
SELECT 
    T0."BELNR_ID" AS "N° Orden",                   -- Número de la orden de producción o mantenimiento
    T0."TYP" AS "Tipo de Orden",                    -- Tipo de orden (Producción, Mantenimiento, etc.)
    --T1."AG_ID" AS "ID del Recurso",                 -- ID del recurso donde ocurrió la interrupción
    --T7."BEZ" AS "Nombre del Recurso",               -- Nombre del recurso
    T1."ANFZEIT" AS "Fecha de Inicio de Interrupción", -- Fecha y hora de inicio de la interrupción
    T1."ENDZEIT" AS "Fecha de Fin de Interrupción",    -- Fecha y hora de fin de la interrupción
    --DATEDIFF(MINUTE, T1."ANFZEIT", T1."ENDZEIT") AS "Duración de la Interrupción (minutos)",  -- Duración en minutos
    T1."GRUND" AS "Motivo de Interrupción"          -- Motivo de la interrupción
FROM 
    BEAS_FTHAUPT T0  -- Tabla de órdenes
LEFT JOIN 
    BEAS_ARBZEIT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  -- Tabla de actividades/interrupciones asociada a la orden
--LEFT JOIN 
    --BEAS_APLATZ T7 ON RIGHT(UPPER(T1."AG_ID"), 4) = T7."APLATZ_ID" -- Información del recurso
WHERE 
    T1."GRUND" IS NOT NULL  -- Filtra solo actividades que son interrupciones
    --AND T1."AG_ID" = 'RECURSO_ID'  -- Filtrar por ID específico del recurso
    AND T1."GRUND" = 'MOTIVO_INTER'  -- Filtrar por motivo específico de interrupción
ORDER BY 
    T0."BELNR_ID", T1."ANFZEIT" DESC;


    /* ultimo script interruciones */
SELECT 
    T0."AUFTRAG" AS "Número de orden",                             -- Número de la orden de trabajo
    T0."BELNR_ID" AS "Número de documento",                        -- Número de documento
    T1."APLATZ_ID" AS "ID del Recurso",                            -- ID del recurso donde ocurrió la interrupción
    T0."BELDAT"  AS "Fecha de orden o pedido",                        -- Fecha de la orden o pedido 

    T3."BEZ" AS "Descripción del Recurso",              -- Descripción del recurso

    
    T1."PERS_ID" AS "ID del Personal",                  -- ID del personal asignado a la tarea o interrupción
    T1."DisplayName" AS "Nombre del Personal",          -- Nombre del personal asignado
    T1."GRUND" AS "Motivo de Interrupción",             -- Motivo de interrupción (Producción, Correctivo, etc.)
    
    T3."GRUPPE" AS "Grupo de Recurso",                -- Grupo al que pertenece el recurso
    T1."MENGE_GUT" AS "Cantidad",                       -- Cantidad producida o trabajada durante la tarea/interrupción
    --DATEDIFF(MINUTE, T1."ANFZEIT", T1."ENDZEIT") AS "Duración (minutos)", -- Duración de la interrupción
    T1."KSTST_ID" AS "Centro de Costo"                  -- Centro de costo asociado
FROM 
    BEAS_FTHAUPT T0                                      -- Tabla de órdenes
INNER JOIN 
    BEAS_ARBZEIT T1 ON T0."BELNR_ID" = T1."BELNR_ID"      -- Tabla Recibo del tiempo de producción (Tabla de actividades/interrupciones)
INNER JOIN 
    BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" 
           AND T1."BELPOS_ID" = T2."BELPOS_ID"             -- Tabla de Enrutamiento de producción (de motivos, enlazada por ID de orden y posición)
LEFT JOIN 
    BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4)  = T3."APLATZ_ID"   -- Tabla de Recursos (de recursos para descripción y grupo de recurso)
WHERE 
    T1."PERS_ID" = '429' AND
    T0."BELDAT" BETWEEN '2024-10-01' AND '2024-10-29'
    --T1."TYP" = 'Interrupción'                           -- Filtrar por interrupciones, si corresponde
ORDER BY 
    T0."BELNR_ID", T1."ANFZEIT" DESC;



    -- ********************************************************


    SELECT 
    T0."AUFTRAG" AS "Número de orden",                             -- Número de la orden de trabajo
    T0."BELNR_ID" AS "Número de documento",                        -- Número de documento
    T1."APLATZ_ID" AS "ID del Recurso",                            -- ID del recurso donde ocurrió la interrupción
    T0."BELDAT"  AS "Fecha de orden o pedido",                        -- Fecha de la orden o pedido 

    --T3."BEZ" AS "Descripción del Recurso",              -- Descripción del recurso

    
    T1."PERS_ID" AS "ID del Personal",                  -- ID del personal asignado a la tarea o interrupción
    T1."DisplayName" AS "Nombre del Personal",          -- Nombre del personal asignado
    T1."GRUND" AS "Motivo de Interrupción",             -- Motivo de interrupción (Producción, Correctivo, etc.)
    
    --T3."GRUPPE" AS "Recurso Grupo",                -- Grupo al que pertenece el recurso
    T1."MENGE_GUT" AS "Cantidad",                       -- Cantidad producida o trabajada durante la tarea/interrupción
    --DATEDIFF(MINUTE, T1."ANFZEIT", T1."ENDZEIT") AS "Duración (minutos)", -- Duración de la interrupción
    T1."KSTST_ID" AS "Centro de Costo"                  -- Centro de costo asociado
FROM 
    BEAS_FTHAUPT T0                                      -- Tabla de órdenes
INNER JOIN 
    BEAS_ARBZEIT T1 ON T0."BELNR_ID" = T1."BELNR_ID"      -- Tabla Recibo del tiempo de producción (Tabla de actividades/interrupciones)
/*INNER JOIN 
    BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" 
           AND T1."BELPOS_ID" = T2."BELPOS_ID"           -- Tabla de Enrutamiento de producción (de motivos, enlazada por ID de orden y posición)
LEFT JOIN 
    BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4)  = T3."APLATZ_ID"*/     -- Tabla de Recursos (de recursos para descripción y grupo de recurso)
WHERE 
    T1."PERS_ID" = '429' AND
    T0."BELDAT" BETWEEN '2024-10-01' AND '2024-10-29'
    --T1."TYP" = 'Interrupción'                           -- Filtrar por interrupciones, si corresponde
ORDER BY 
    T0."BELNR_ID", T1."ANFZEIT" DESC;




    -- *****************PRUEBA**********************
    /*SELECT  
   T0."GRUPPE", 
   T0."BEZ", 
   T1."APLATZ_ID", 
   T1."BEZ",
   T1.*
FROM 
    BEAS_APLATZGRUPPE T0
INNER JOIN 
    BEAS_APLATZ T1 ON T0."GRUPPE" = T1."GRUPPE"
WHERE T1."Active" = 'J'*/

SELECT
  T0."APLATZ_ID"  AS "Recurso",
  CASE WHEN T1."RESOURCETYPE" = 'resource'   THEN 'Recurso'  ELSE ' ' END AS "Recurso Tipo",
  T0.*,
  T1.*
FROM 
   BEAS_APLATZ T0
INNER JOIN 
   BEAS_APLATZ_STILLSTAND T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
WHERE T0."Active" = 'J' AND
              T1."RESOURCETYPE" = 'resource' AND
              T0."BELDAT" BETWEEN '2024-10-28' AND '2024-10-30'
LIMIT 20


-- *************************************************

SELECT 
    T0."AUFTRAG" AS "Número de orden",                             -- Número de la orden de trabajo
    T0."BELNR_ID" AS "Número de documento",                        -- Número de documento
    T1."APLATZ_ID" AS "ID del Recurso",                            -- ID del recurso donde ocurrió la interrupción
    T0."BELDAT"  AS "Fecha de orden o pedido",                        -- Fecha de la orden o pedido 

    T3."BEZ" AS "Descripción del Recurso",              -- Descripción del recurso

    
    T1."PERS_ID" AS "ID del Personal",                  -- ID del personal asignado a la tarea o interrupción
    T1."DisplayName" AS "Nombre del Personal",          -- Nombre del personal asignado
    T1."GRUND" AS "Motivo de Interrupción",             -- Motivo de interrupción (Producción, Correctivo, etc.)
    
    T3."GRUPPE" AS "Recurso Grupo",                -- Grupo al que pertenece el recurso
    T3."COSTEXTENTED" AS "Cantidad", 
   -- T1."MENGE_GUT" AS "Cantidad",                       -- Cantidad producida o trabajada durante la tarea/interrupción
    --DATEDIFF(MINUTE, T1."ANFZEIT", T1."ENDZEIT") AS "Duración (minutos)", -- Duración de la interrupción
    T1."KSTST_ID" AS "Centro de Costo"                 -- Centro de costo asociado
    --T3.*
FROM 
    BEAS_FTHAUPT T0                                      -- Tabla de órdenes
INNER JOIN 
    BEAS_ARBZEIT T1 ON T0."BELNR_ID" = T1."BELNR_ID"      -- Tabla Recibo del tiempo de producción (Tabla de actividades/interrupciones)
INNER JOIN 
    BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" 
                        AND T1."BELPOS_ID" = T2."BELPOS_ID"             -- Tabla de Enrutamiento de producción (de motivos, enlazada por ID de orden y posición)
LEFT JOIN 
    BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4)  = T3."APLATZ_ID"   -- Tabla de Recursos (de recursos para descripción y grupo de recurso)
WHERE 
    T1."PERS_ID" = '429' AND
    T0."BELDAT" BETWEEN '2024-10-01' AND '2024-10-29'
/*GROUP BY T0."AUFTRAG" , T0."BELNR_ID" , T1."APLATZ_ID", T0."BELDAT", T3."BEZ", T1."PERS_ID", T1."DisplayName", T1."GRUND", 
    T3."GRUPPE" , T1."MENGE_GUT",  T1."KSTST_ID", T1."ANFZEIT" */
ORDER BY 
    T0."BELNR_ID", T1."ANFZEIT" DESC;



    -- _______________________________
-- ********************QUERY DE INTERRUPCIONES FILTRADO POR FECHA , RECURSOS Y SUS 45 RECURSOS **************************
SELECT 
   T0."INTNR" AS "Orden",
   T0."APLATZ_ID" AS "Recurso",
   CASE WHEN T0."RESOURCETYPE" = 'resource'   THEN 'Recurso'  ELSE ' ' END AS "Recurso Tipo",
   T1."BEZ" AS "Descripción",
   T0."DATUM_VON" AS "Desde",
   T0."PERS_ID" AS "Personal",
   T0."PERS_ID_Name" AS "Personal Nombre",
   T0."PERS_ID_END" AS "Personal",
   CASE WHEN T0."statusId" = 2   THEN 'Hecho'  ELSE ' ' END AS "Estatus",
   T0."PERS_ID_END_Name" AS "Personal Nombre",
   T0."GRUNDID" AS "Motivo",
   T0."GRUNDINFO" AS "Motivo Descripción",
   T1."GRUPPE" AS "Recurso Grupo",
   --T0."COUNTING_T" AS "Cantidad",
   --T1."COSTEXTENTED" AS "Cantidad",
   T1."KSTST_ID" AS "Centro de costo",
   T0.*
FROM 
    BEAS_APLATZ_STILLSTAND T0
INNER JOIN 
    BEAS_APLATZ T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"   
WHERE 
    --T0."INTNR" = '137549' AND
    T0."DATUM_VON" BETWEEN '2024-10-28' AND '2024-10-30' AND
    T0."RESOURCETYPE" = 'resource' AND
    T0."GRUNDID" IN ('014','015','009','008') AND
    T0."APLATZ_ID" IN ('G061', 'G003', 'G083', 'G004', 'G006', 
                       'G008', 'G081', 'G082', 'G104', 'G009', 
                       'G010', 'G011', 'G013', 'G014', 'G015', 
                       'G016', 'G018', 'G019', 'G020', 'G023', 
                       'G028', 'G029', 'G037', 'G038', 'G039', 
                       'G040', 'G060', 'G044', 'G045', 'G046',
                       'G049', 'G050', 'G051', 'G052', 'G055',
                       'G056', 'G057', 'G058', 'G105', 'G106',
                       'G107', 'G108', 'G109', 'G110', 'G080');



/* Query de factura de deudores, 
donde el documento abierto traiga la fecha de vencimiento que supere el día actual por SN */
SELECT 
    T0."CardCode" AS "Código Cliente",
    T0."CardName" AS "Nombre Cliente",
    T0."DocEntry" AS "Número Documento",
    T0."DocNum" AS "Número Factura",
    T0."DocDate" AS "Fecha Contabilización",
    T0."DocDueDate" AS "Fecha Vencimiento",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días Vencidos",
    CASE WHEN T0."DocStatus" = 'O'   THEN 'Abierto'  ELSE ' ' END AS "Estado"
FROM 
    OINV T0
WHERE 
    T0."DocStatus" = 'O'
    AND T0."DocDueDate" < CURRENT_DATE 
ORDER BY 
    T0."CardCode", T0."DocDueDate";

/* SELECT 
    T0."CardCode" AS "Código Cliente",
    T0."CardName" AS "Nombre Cliente",
    T0."DocEntry" AS "Número Documento",
    T0."DocNum" AS "Número Factura",
    T0."DocDate" AS "Fecha Documento",
    T0."DocDueDate" AS "Fecha Vencimiento",
    T0."DocTotal" AS "Total Factura",
    T0."PaidToDate" AS "Monto Pagado",
    T0."DocTotal" - T0."PaidToDate" AS "Saldo Pendiente"
FROM 
    OINV T0 -- Tabla de facturas de deudores
WHERE 
    T0."DocStatus" = 'O' -- Solo documentos abiertos
    AND T0."DocDueDate" > CURRENT_DATE 
ORDER BY 
    T0."CardCode", T0."DocDueDate"; */


    -- *******************


    SELECT
    T0."CardCode" AS "Código Cliente",
    T0."CardName" AS "Nombre Cliente",
    T1."SlpName" AS "Ejecutivo",
    T2."CreditLine" AS "Límite de Crédito",
    SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) AS "Saldo Vencido",
    T0."DocEntry" AS "Número Documento",
    T0."DocNum" AS "Número Factura",
    T0."DocDate" AS "Fecha Contabilización",
    T0."DocDueDate" AS "Fecha Vencimiento",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Atraso",
    CASE WHEN T0."DocStatus" = 'O' THEN 'Abierto' ELSE ' ' END AS "Estado"
FROM 
    OINV T0
    LEFT JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  -- Información del socio de negocio
    LEFT JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"    -- Información del ejecutivo
WHERE 
    T0."DocStatus" = 'O'
    AND T0."DocDueDate" < CURRENT_DATE
GROUP BY 
    T0."CardCode", 
    T0."CardName", 
    T1."SlpName", 
    T2."CreditLine", 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."DocDueDate", 
    T0."DocStatus"
ORDER BY 
    T0."CardCode", 
     T0."DocDate",
    T0."DocDueDate";



    -- ********

    SELECT 
    T0."CardCode" AS "Código Cliente",
    T0."CardName" AS "Nombre Cliente",
    T1."SlpName" AS "Ejecutivo",
    T2."CreditLine" AS "Límite de Crédito",
    SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) AS "Saldo Vencido",
    T0."DocEntry" AS "Número Documento",
    T0."DocNum" AS "Número Factura",
    T0."DocDate" AS "Fecha Contabilización",
    T0."DocDueDate" AS "Fecha Vencimiento",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Atraso",
    CASE WHEN T0."DocStatus" = 'O' THEN 'Abierto' ELSE ' ' END AS "Estado"
FROM 
    OINV T0
    LEFT JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  -- Información del socio de negocio
    LEFT JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"    -- Información del ejecutivo
    INNER JOIN (
        SELECT "CardCode", MIN("DocDueDate") AS "MinDueDate"
        FROM OINV
        WHERE "DocStatus" = 'O' AND "DocDueDate" < CURRENT_DATE
        GROUP BY "CardCode"
    ) AS SubQuery ON T0."CardCode" = SubQuery."CardCode" AND T0."DocDueDate" = SubQuery."MinDueDate"
WHERE 
    T0."DocStatus" = 'O'
    AND T0."DocDueDate" < CURRENT_DATE
GROUP BY 
    T0."CardCode", 
    T0."CardName", 
    T1."SlpName", 
    T2."CreditLine", 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."DocDueDate", 
    T0."DocStatus"
ORDER BY 
    T0."CardCode", 
    T0."DocDueDate";


    -- ***************************
    SELECT 
    T0."CardCode" AS "Código Cliente",
    T0."CardName" AS "Nombre Cliente",
    T1."SlpName" AS "Ejecutivo",
    T2."CreditLine" AS "Límite de Crédito",
    T0."DocEntry" AS "Número Documento",
    T0."DocNum" AS "Número Factura",
    T0."DocDate" AS "Fecha Contabilización",
    T0."DocDueDate" AS "Fecha Vencimiento",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Atraso",
    T0."DocTotal" - T0."PaidToDate" AS "Saldo Vencido",
    CASE WHEN T0."DocStatus" = 'O' THEN 'Abierto' ELSE ' ' END AS "Estado"
FROM 
    OINV T0
    LEFT JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  -- Información del socio de negocio
    LEFT JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"    -- Información del ejecutivo
WHERE 
    T0."DocStatus" = 'O'
    AND T0."DocDueDate" < CURRENT_DATE
    AND T0."DocDueDate" = (
        SELECT MIN(T3."DocDueDate")
        FROM OINV T3
        WHERE T3."CardCode" = T0."CardCode"
          AND T3."DocStatus" = 'O'
          AND T3."DocDueDate" < CURRENT_DATE
    )
ORDER BY 
    T0."CardCode";


    -- ************************************

    SELECT 
    "Código Cliente",
    "Nombre Cliente",
    "Ejecutivo",
    "Límite de Crédito",
    "Número Documento",
    "Número Factura",
    "Fecha Contabilización",
    "Fecha Vencimiento",
    "Días de Atraso",
    "Saldo Vencido",
    "Estado"
FROM (
    SELECT 
        T0."CardCode" AS "Código Cliente",
        T0."CardName" AS "Nombre Cliente",
        T1."SlpName" AS "Ejecutivo",
        T2."CreditLine" AS "Límite de Crédito",
        T0."DocEntry" AS "Número Documento",
        T0."DocNum" AS "Número Factura",
        T0."DocDate" AS "Fecha Contabilización",
        T0."DocDueDate" AS "Fecha Vencimiento",
        DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Atraso",
        T0."DocTotal" - T0."PaidToDate" AS "Saldo Vencido",
        CASE WHEN T0."DocStatus" = 'O' THEN 'Abierto' ELSE ' ' END AS "Estado",
        ROW_NUMBER() OVER (PARTITION BY T0."CardCode" ORDER BY T0."DocDueDate" ASC) AS "RowNum"
    FROM 
        OINV T0
        LEFT JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  -- Información del socio de negocio
        LEFT JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"    -- Información del ejecutivo
    WHERE 
        T0."DocStatus" = 'O'
        AND T0."DocDueDate" < CURRENT_DATE
) AS SubQuery
WHERE 
    "RowNum" = 1
ORDER BY 
    "Código Cliente";


    /* CON ESTO SALIO PERO FALTA VERIFICAR BIEN LA DATA DE SALDOS VENCIDOS */

    SELECT 
    T0."CardCode" AS "Código Cliente",
    T0."CardName" AS "Nombre Cliente",
    T1."SlpName" AS "Ejecutivo",
    T2."CreditLine" AS "Límite de Crédito",
    SUM(CASE 
        WHEN T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        THEN T0."DocTotal" - T0."PaidToDate"
        ELSE 0 
    END) AS "Saldo Vencido",
    T0."DocEntry" AS "Número Documento",
    T0."DocNum" AS "Número Factura",
    T0."DocDate" AS "Fecha Contabilización",
    T0."DocDueDate" AS "Fecha Vencimiento",
    DAYS_BETWEEN(T0."DocDueDate", CURRENT_DATE) AS "Días de Atraso",
    CASE WHEN T0."DocStatus" = 'O' THEN 'Abierto' ELSE ' ' END AS "Estado"
FROM 
    OINV T0
    LEFT JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"  -- Información del socio de negocio
    LEFT JOIN OSLP T1 ON T2."SlpCode" = T1."SlpCode"    -- Información del ejecutivo
    INNER JOIN (
        SELECT "CardCode", MIN("DocDueDate") AS "MinDueDate"
        FROM OINV
        WHERE "DocStatus" = 'O' AND "DocDueDate" < CURRENT_DATE
        GROUP BY "CardCode"
    ) AS SubQuery ON T0."CardCode" = SubQuery."CardCode" AND T0."DocDueDate" = SubQuery."MinDueDate"
WHERE 
    T0."DocStatus" = 'O'
    AND T0."DocDueDate" < CURRENT_DATE
GROUP BY 
    T0."CardCode", 
    T0."CardName", 
    T1."SlpName", 
    T2."CreditLine", 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."DocDueDate", 
    T0."DocStatus"
ORDER BY 
    T0."CardCode", 
    T0."DocDueDate";





    -- *************************************************

DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
DECLARE SALDO_VENCIDO BOOLEAN;

BEGIN
    -- Obtener el cliente y el total de órdenes de venta
    SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;

    -- Obtener el saldo y límite de crédito del cliente
    SELECT T0."Balance", T0."CreditLine" INTO SALDO, LIMITE_CREDITO 
    FROM OCRD T0 
    WHERE T0."CardType" = 'C' AND T0."CardCode" = :CLIENTE;

    -- Verificar si hay saldo vencido en las facturas abiertas
    SELECT COUNT(*) > 0 INTO SALDO_VENCIDO 
    FROM OINV T0 
    WHERE T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
      AND T0."CardCode" = :CLIENTE;

    -- Lógica para autorización de pedido
    IF ((:LIMITE_CREDITO = 0 AND SALDO = 0) OR :SALDO + :TOTAL_OV < :LIMITE_CREDITO) THEN
        SELECT 'FALSE' FROM DUMMY;
    ELSE IF SALDO_VENCIDO THEN
        SELECT 'TRUE' FROM DUMMY;  -- Marca como verdadero si hay saldo vencido
    ELSE
        SELECT 'TRUE' FROM DUMMY;  -- Marca como verdadero si no se excede el límite de crédito
    END IF;

END;




-- **********************************

DECLARE SALDO_VENCIDO INT;

BEGIN
         

        -- Verificar si hay saldo vencido en las facturas abiertas
        SELECT COUNT(*)  INTO SALDO_VENCIDO 
        FROM OINV T0 
        WHERE T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
        AND T0."CardCode" = :CLIENTE;

        IF( (:SALDO_VENCIDO=0) ) THEN
            SELECT 'FALSE' FROM DUMMY;
       ELSE
            SELECT 'TRUE' FROM DUMMY;
      END IF;

    --    IF( (:LIMITE_CREDITO=0 AND SALDO=0) OR :SALDO + :TOTAL_OV<:LIMITE_CREDITO) THEN
    --         SELECT 'FALSE' FROM DUMMY;
    --    ELSE
    --         SELECT 'TRUE' FROM DUMMY;
    --   END IF;

         /*IF((:LIMITE_CREDITO=0 AND SALDO=0) OR :SALDO + :TOTAL_OV<:LIMITE_CREDITO) THEN
              SELECT 'FALSE' FROM DUMMY;
         ELSEIF (:SALDO_VENCIDO  > 0) THEN
              SELECT 'TRUE' FROM DUMMY; 
         ELSE
              SELECT 'TRUE' FROM DUMMY;
         END IF;*/

END;

-- *************************************
DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
DECLARE SALDO_VENCIDO INT;

BEGIN
    -- Obtener el cliente y el total de órdenes de venta
    SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;
    -- SELECT 'C0102876901001' INTO CLIENTE FROM DUMMY;

    -- Obtener el saldo y límite de crédito del cliente
    SELECT T0."Balance", T0."CreditLine" INTO SALDO, LIMITE_CREDITO 
    FROM OCRD T0 
    WHERE T0."CardType" = 'C' AND T0."CardCode" = :CLIENTE;
    -- SELECT 500, 501 INTO SALDO, LIMITE_CREDITO FROM DUMMY;

    -- Verificar cuántas facturas están abiertas y vencidas
    SELECT COUNT(*) INTO SALDO_VENCIDO 
    FROM OINV T0 
    WHERE T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
      AND T0."CardCode" = :CLIENTE;

   IF (SALDO_VENCIDO > 0) THEN
        SELECT 'TRUE' AS Resultado, 'El cliente tiene saldo vencido.' AS Mensaje FROM DUMMY;   
    ELSE
        -- Lógica para autorización de pedido
        IF ((:LIMITE_CREDITO = 0 AND SALDO = 0) OR :SALDO + :TOTAL_OV < :LIMITE_CREDITO) THEN
            SELECT 'FALSE' AS Resultado FROM DUMMY;
        ELSE
            SELECT 'TRUE' AS Resultado FROM DUMMY;
        END IF;
    END IF;
END;



/* CODIGO ORIGINAL DE Aut - Autoriza Limite Credito */

DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
BEGIN
SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;
--SELECT 'C0102876901001' INTO CLIENTE FROM DUMMY;

SELECT T0."Balance" , T0."CreditLine" INTO SALDO, LIMITE_CREDITO FROM OCRD T0 WHERE T0."CardType"  = 'C' AND T0."CardCode" = :CLIENTE;
--SELECT 500, 501 INTO SALDO,LIMITE_CREDITO FROM DUMMY;

IF((:LIMITE_CREDITO=0 AND SALDO=0) OR :SALDO + :TOTAL_OV<:LIMITE_CREDITO) THEN
   SELECT 'FALSE' FROM DUMMY;
ELSE
     SELECT 'TRUE' FROM DUMMY;
END IF;

END;

-- *******************************

SELECT COUNT(*)  INTO SALDO_VENCIDO FROM OINV T0 WHERE T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE AND T0."CardCode" = :CLIENTE;

IF( :SALDO_VENCIDO > 0 ) THEN
      SELECT 'TRUE' FROM DUMMY;   
ELSE  
      SELECT 'FALSE' FROM DUMMY;    
END IF;




-- *************************************

DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO DECIMAL(19,2);
DECLARE LIMITE_CREDITO DECIMAL(19,2);
DECLARE TOTAL_OV DECIMAL(19,2);
DECLARE SALDO_VENCIDO INT;

BEGIN
    -- Obtener el cliente y el total de órdenes de venta
    SELECT $[$4.1.0], $[$29.91.NUMBER] INTO CLIENTE, TOTAL_OV FROM DUMMY;
    -- SELECT 'C0102876901001' INTO CLIENTE FROM DUMMY;

    -- Obtener el saldo y límite de crédito del cliente
    SELECT T0."Balance", T0."CreditLine" INTO SALDO, LIMITE_CREDITO 
    FROM OCRD T0 
    WHERE T0."CardType" = 'C' AND T0."CardCode" = :CLIENTE;
    -- SELECT 500, 501 INTO SALDO, LIMITE_CREDITO FROM DUMMY;

    -- Verificar cuántas facturas están abiertas y vencidas
    SELECT COUNT(*) INTO SALDO_VENCIDO 
    FROM OINV T0 
    WHERE T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
      AND T0."CardCode" = :CLIENTE;

    -- Lógica para autorización de pedido
    IF (SALDO_VENCIDO > 0) THEN
        SELECT 'FALSE' AS Resultado, 'El cliente tiene saldo vencido.' AS Mensaje FROM DUMMY;   
    ELSEIF ((:LIMITE_CREDITO = 0 AND SALDO = 0) OR :SALDO + :TOTAL_OV < :LIMITE_CREDITO) THEN
        SELECT 'FALSE' AS Resultado FROM DUMMY;
    ELSE
        SELECT 'TRUE' AS Resultado FROM DUMMY;
    END IF;

END;



-- *******************APROBADO Aut saldo vencido******************************

DECLARE CLIENTE VARCHAR(20);
DECLARE SALDO_VENCIDO INT;
BEGIN
   
     SELECT $[$4.1.0] INTO CLIENTE FROM DUMMY;

    -- Verificar cuántas facturas están abiertas y vencidas
    SELECT COUNT(*) INTO SALDO_VENCIDO 
    FROM OINV T0 
    WHERE T0."DocStatus" = 'O' AND T0."DocDueDate" < CURRENT_DATE 
    AND T0."CardCode" = :CLIENTE;

   IF (:SALDO_VENCIDO > 0) THEN
       SELECT 'TRUE'  FROM DUMMY;
    ELSE
        SELECT 'FALSE' FROM DUMMY;  
    END IF;
END;


********************************************
SELECT 
   T0."INTNR" AS "Orden",
   T0."APLATZ_ID" AS "Recurso",
   CASE WHEN T0."RESOURCETYPE" = 'resource'   THEN 'Recurso'  ELSE ' ' END AS "Recurso Tipo",
   T1."BEZ" AS "Descripción",
   --T0."DATUM_VON" AS "Desde",
   TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH:MI:SS') AS "Desde",
   T0."PERS_ID" AS "Personal",
   T0."PERS_ID_Name" AS "Personal Nombre",
   T0."DATUM_BIS" AS "A",
   T0."PERS_ID_END" AS "Personal",
   CASE WHEN T0."statusId" = 2   THEN 'Hecho'  ELSE ' ' END AS "Estatus",
   T0."PERS_ID_END_Name" AS "Personal Nombre",
   T0."GRUNDID" AS "Motivo",
   T0."GRUNDINFO" AS "Motivo Descripción",
   T1."GRUPPE" AS "Recurso Grupo",
   DATEDIFF(MICROSECOND, '2009-11-10 14:57:52.722001', '2009-11-10 14:57:52.722016') AS "Duracion",

--ROUND((T0."DATUM_BIS" - T0."DATUM_VON") * 24 * 60, 2) AS "Duracion (Minutos)", 
  --TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH:MI:SS') as "buu",
     --DAYS_BETWEEN(TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH:MI:SS'), TO_NVARCHAR(TO_TIME(T0."DATUM_BIS"), 'HH:MI:SS') ) AS "Duracion",
   --ROUND((DAYS_BETWEEN(TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH:MI:SS'), TO_NVARCHAR(TO_TIME(T0."DATUM_BIS"), 'HH:MI:SS')) * 24 * 60), 2) / 60.0 AS "Duracion Decimal (Horas)", 

   --DAYS_BETWEEN(T0."DATUM_VON", T0."DATUM_BIS") AS "Duracion",
   T1."KSTST_ID" AS "Centro de costo"
FROM 
    BEAS_APLATZ_STILLSTAND T0
INNER JOIN 
    BEAS_APLATZ T1 ON T0."APLATZ_ID" = T1."APLATZ_ID" 
--INNER JOIN BEAS_APLATZ_UEBGZEIT T2 0N  T0."APLATZ_ID" = T2.""
WHERE 
    --T0."INTNR" = '137549' AND
    T0."DATUM_VON" BETWEEN '2024-10-28' AND '2024-10-30' AND
    T0."RESOURCETYPE" = 'resource' AND
    T0."GRUNDID" IN ('014','015','009','008') AND
    T0."APLATZ_ID" IN ('G061', 'G003', 'G083', 'G004', 'G006', 
                       'G008', 'G081', 'G082', 'G104', 'G009', 
                       'G010', 'G011', 'G013', 'G014', 'G015', 
                       'G016', 'G018', 'G019', 'G020', 'G023', 
                       'G028', 'G029', 'G037', 'G038', 'G039', 
                       'G040', 'G060', 'G044', 'G045', 'G046',
                       'G049', 'G050', 'G051', 'G052', 'G055',
                       'G056', 'G057', 'G058', 'G105', 'G106',
                       'G107', 'G108', 'G109', 'G110', 'G080');



-- **********************************************************************

SELECT 
   T0."INTNR" AS "Orden",
   T0."APLATZ_ID" AS "Recurso",
   CASE WHEN T0."RESOURCETYPE" = 'resource'   THEN 'Recurso'  ELSE ' ' END AS "Recurso Tipo",
   T1."BEZ" AS "Descripción",
   --T0."DATUM_VON" AS "Desde",
   TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH:MI:SS') AS "Desde",
   T0."PERS_ID" AS "Personal",
   T0."PERS_ID_Name" AS "Personal Nombre",
   TO_NVARCHAR(T0."DATUM_BIS", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_BIS"), 'HH:MI:SS') AS "Hasta",
   --T0."DATUM_BIS" AS "A",
   T0."PERS_ID_END" AS "Personal",
   CASE WHEN T0."statusId" = 2   THEN 'Hecho'  ELSE ' ' END AS "Estatus",
   T0."PERS_ID_END_Name" AS "Personal Nombre",
   T0."GRUNDID" AS "Motivo",
   T0."GRUNDINFO" AS "Motivo Descripción",
   T1."GRUPPE" AS "Recurso Grupo",
   --DATEDIFF(DAY , TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD') , TO_NVARCHAR(TO_TIME(T0."DATUM_VON")) ) AS "Duracion",

    DATEDIFF(DAY, TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH:MI:SS'), TO_NVARCHAR(T0."DATUM_BIS", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_BIS"), 'HH:MI:SS')) AS "Duracion",

   --DATEDIFF(MINUTE, TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH:MI'), TO_NVARCHAR(TO_TIME(T0."DATUM_BIS"), 'HH:MI')) AS "Duracion",

TO_NVARCHAR(TO_TIME(T0."DATUM_VON")) AS "d",

   T1."KSTST_ID" AS "Centro de costo"
FROM 
    BEAS_APLATZ_STILLSTAND T0
INNER JOIN 
    BEAS_APLATZ T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
WHERE 
    --T0."INTNR" = '137549' AND
    T0."DATUM_VON" BETWEEN '2024-10-28' AND '2024-10-30' AND
    T0."RESOURCETYPE" = 'resource' AND
    T0."GRUNDID" IN ('014','015','009','008') AND
    T0."APLATZ_ID" IN ('G061', 'G003', 'G083', 'G004', 'G006', 
                       'G008', 'G081', 'G082', 'G104', 'G009', 
                       'G010', 'G011', 'G013', 'G014', 'G015', 
                       'G016', 'G018', 'G019', 'G020', 'G023', 
                       'G028', 'G029', 'G037', 'G038', 'G039', 
                       'G040', 'G060', 'G044', 'G045', 'G046',
                       'G049', 'G050', 'G051', 'G052', 'G055',
                       'G056', 'G057', 'G058', 'G105', 'G106',
                       'G107', 'G108', 'G109', 'G110', 'G080');


-- *****************************************************

SELECT 
   T0."INTNR" AS "Orden",
   T0."APLATZ_ID" AS "Recurso",
   CASE WHEN T0."RESOURCETYPE" = 'resource'   THEN 'Recurso'  ELSE ' ' END AS "Recurso Tipo",
   T1."BEZ" AS "Descripción",
   --T0."DATUM_VON" AS "Desde",
   TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH:MI:SS') AS "Desde",
   T0."PERS_ID" AS "Personal",
   T0."PERS_ID_Name" AS "Personal Nombre",
   TO_NVARCHAR(T0."DATUM_BIS", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_BIS"), 'HH:MI:SS') AS "Hasta",
   --T0."DATUM_BIS" AS "A",
   T0."PERS_ID_END" AS "Personal",
   CASE WHEN T0."statusId" = 2   THEN 'Hecho'  ELSE ' ' END AS "Estatus",
   T0."PERS_ID_END_Name" AS "Personal Nombre",
   T0."GRUNDID" AS "Motivo",
   T0."GRUNDINFO" AS "Motivo Descripción",
   T1."GRUPPE" AS "Recurso Grupo",
   --DATEDIFF(DAY , TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD') , TO_NVARCHAR(TO_TIME(T0."DATUM_VON")) ) AS "Duracion",

   --DATEDIFF("h", '2003/08/03 14:00', '2003/08/08 14:00' ) AS "EXAMPLE",
   --Cast(Substring(TO_NVARCHAR(TO_TIME(T0."DATUM_BIS"), 'HH:MI'), 1, 2) As Int) - Cast(Substring(TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH:MI'), 1, 2) As Int) AS "Duracion",


     --SECONDS_BETWEEN('2024-11-05 07:51:57', '2024-11-05 07:33:25') / 60 AS "Duración en Minutos",

     --ROUND(ABS(SECONDS_BETWEEN('2024-11-05 07:51:57', '2024-11-05 07:33:25') / 60), 2) AS "Duración en Minutos",

      ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."DATUM_BIS", 'YYYY-MM-DD HH:MI:SS'), TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD HH:MI:SS')) / 60), 2) AS "Duración en Minutos",

   -- Calcular la diferencia en minutos
   --DATEDIFF(MINUTE, T0."DATUM_VON", T0."DATUM_BIS") AS "Duracion (minutos)",

   -- Calcular la diferencia en minutos
   --DATEDIFF('SECOND', T0."DATUM_VON", T0."DATUM_BIS") / 60 AS "Duracion (minutos)",
     --TIMESTAMPDIFF('MINUTE', T0."DATUM_VON", T0."DATUM_BIS") AS "Duracion (minutos)",

   --DATEDIFF("h", TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH:MI:SS'), TO_NVARCHAR(TO_TIME(T0."DATUM_BIS"), 'HH:MI:SS')) AS "Duracion",

   --DATEDIFF(MINUTE, TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH:MI'), TO_NVARCHAR(TO_TIME(T0."DATUM_BIS"), 'HH:MI')) AS "Duracion",



   T1."KSTST_ID" AS "Centro de costo"
FROM 
    BEAS_APLATZ_STILLSTAND T0
INNER JOIN 
    BEAS_APLATZ T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
WHERE 
    --T0."INTNR" = '137549' AND
    T0."DATUM_VON" BETWEEN '2024-10-28' AND '2024-10-30' AND
    T0."RESOURCETYPE" = 'resource' AND
    T0."GRUNDID" IN ('014','015','009','008') AND
    T0."APLATZ_ID" IN ('G061', 'G003', 'G083', 'G004', 'G006', 
                       'G008', 'G081', 'G082', 'G104', 'G009', 
                       'G010', 'G011', 'G013', 'G014', 'G015', 
                       'G016', 'G018', 'G019', 'G020', 'G023', 
                       'G028', 'G029', 'G037', 'G038', 'G039', 
                       'G040', 'G060', 'G044', 'G045', 'G046',
                       'G049', 'G050', 'G051', 'G052', 'G055',
                       'G056', 'G057', 'G058', 'G105', 'G106',
                       'G107', 'G108', 'G109', 'G110', 'G080');











/* Interrupciones mantenimiento por recurso */

SELECT 
   /*T0."INTNR" AS "Orden",
   T0."APLATZ_ID" AS "Recurso",
   CASE WHEN T0."RESOURCETYPE" = 'resource'   THEN 'Recurso'  ELSE ' ' END AS "Recurso Tipo",
   T1."BEZ" AS "Descripción",
   TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH:MI:SS') AS "Desde",
   T0."PERS_ID" AS "Personal",
   T0."PERS_ID_Name" AS "Personal Nombre",
   TO_NVARCHAR(T0."DATUM_BIS", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_BIS"), 'HH:MI:SS') AS "Hasta",
   T0."PERS_ID_END" AS "Personal",
   CASE WHEN T0."statusId" = 2   THEN 'Hecho'  ELSE ' ' END AS "Estatus",
   T0."PERS_ID_END_Name" AS "Personal Nombre",
   T0."GRUNDID" AS "Motivo",
   T0."GRUNDINFO" AS "Motivo Descripción",
   T1."GRUPPE" AS "Recurso Grupo",
   '1' AS "Cantidad",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."DATUM_BIS", 'YYYY-MM-DD HH:MI:SS'), TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD HH:MI:SS')) / 60), 2) AS "Duración en Minutos",
   T1."KSTST_ID" AS "Centro de costo"*/

   T0."APLATZ_ID" AS "Recurso",
   COUNT(*) AS "Cantidad",
   ROUND(SUM(ABS(SECONDS_BETWEEN(T0."DATUM_BIS", T0."DATUM_VON") / 60)), 2) AS "Duración en Minutos"  -- Suma de la duración en minutos
   
FROM 
    BEAS_APLATZ_STILLSTAND T0
INNER JOIN 
    BEAS_APLATZ T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
WHERE 
    --T0."INTNR" = '137549' AND
    T0."DATUM_VON" BETWEEN '2024-08-01' AND '2024-08-30' AND
    T0."RESOURCETYPE" = 'resource' AND
    T0."GRUNDID" IN ('014','015','009','008') AND
    T0."APLATZ_ID" IN ('G061', 'G003', 'G083', 'G004', 'G006', 
                       'G008', 'G081', 'G082', 'G104', 'G009', 
                       'G010', 'G011', 'G013', 'G014', 'G015', 
                       'G016', 'G018', 'G019', 'G020', 'G023', 
                       'G028', 'G029', 'G037', 'G038', 'G039', 
                       'G040', 'G060', 'G044', 'G045', 'G046',
                       'G049', 'G050', 'G051', 'G052', 'G055',
                       'G056', 'G057', 'G058', 'G105', 'G106',
                       'G107', 'G108', 'G109', 'G110', 'G080')
GROUP BY 
   T0."APLATZ_ID"
ORDER BY 
   T0."APLATZ_ID"


    --T0."DATUM_VON" BETWEEN [%0] AND [%1] AND 

     --T0."DATUM_VON" BETWEEN [%0] AND [%1] AND

     --T0."DATUM_VON" = [%0]  AND

      --T0."DATUM_VON" >= '2024-01-01' AND 
    --   T0."DATUM_VON" BETWEEN '2024-08-01' AND '2024-08-30' AND
-- 24/02/2022

/* --T0."DATUM_VON" >= TO_DATE('[%0]', 'YYYY-MM-DD') 
    --AND T0."DATUM_VON" < TO_DATE('[%1]', 'YYYY-MM-DD') + INTERVAL '1' DAY */
    --  **********************************


    SELECT * FROM (

SELECT 
   T0."INTNR" AS "Orden",
   T0."APLATZ_ID" AS "Recurso",
   CASE WHEN T0."RESOURCETYPE" = 'resource'   THEN 'Recurso'  ELSE ' ' END AS "Recurso Tipo",
   T1."BEZ" AS "Descripción",
   TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH:MI:SS') AS "Desde",
   T0."PERS_ID" AS "Personal",
   T0."PERS_ID_Name" AS "Personal Nombre",
   TO_NVARCHAR(T0."DATUM_BIS", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_BIS"), 'HH:MI:SS') AS "Hasta",
   T0."PERS_ID_END" AS "Personal",
   CASE WHEN T0."statusId" = 2   THEN 'Hecho'  ELSE ' ' END AS "Estatus",
   T0."PERS_ID_END_Name" AS "Personal Nombre",
   T0."GRUNDID" AS "Motivo",
   T0."GRUNDINFO" AS "Motivo Descripción",
   T1."GRUPPE" AS "Recurso Grupo",
   '1' AS "Cantidad",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."DATUM_BIS", 'YYYY-MM-DD HH:MI:SS'), TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD HH:MI:SS')) / 60), 2) AS "Duración en Minutos",
   T1."KSTST_ID" AS "Centro de costo"

   /*T0."APLATZ_ID" AS "Recurso",
   ROUND(SUM(ABS(SECONDS_BETWEEN(T0."DATUM_BIS", T0."DATUM_VON") / 60)), 2) AS "Suma de Duración en Minutos",  -- Suma de la duración en minutos
   COUNT(*) AS "Suma de Cantidad"*/
   
FROM 
    "SBO_FIGURETTI_PRO"."BEAS_APLATZ_STILLSTAND" T0
INNER JOIN 
     "SBO_FIGURETTI_PRO"."BEAS_APLATZ" T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
WHERE 
    T0."DATUM_VON" BETWEEN '2024-08-01' AND '2024-08-30' AND
    T0."RESOURCETYPE" = 'resource' AND
    T0."GRUNDID" IN ('014','015','009','008') AND
    T0."APLATZ_ID" IN ('G061', 'G003', 'G083', 'G004', 'G006', 
                       'G008', 'G081', 'G082', 'G104', 'G009', 
                       'G010', 'G011', 'G013', 'G014', 'G015', 
                       'G016', 'G018', 'G019', 'G020', 'G023', 
                       'G028', 'G029', 'G037', 'G038', 'G039', 
                       'G040', 'G060', 'G044', 'G045', 'G046',
                       'G049', 'G050', 'G051', 'G052', 'G055',
                       'G056', 'G057', 'G058', 'G105', 'G106',
                       'G107', 'G108', 'G109', 'G110', 'G080')  
) P 
WHERE P."Desde" =  [%0]





----------------------------------------------------------------------
-- Consulta principal
SELECT 
   T0."APLATZ_ID" AS "Recurso",
   ROUND(SUM(ABS(SECONDS_BETWEEN(T0."DATUM_BIS", T0."DATUM_VON") / 60)), 2) AS "Suma de Duración en Minutos",  -- Suma de la duración en minutos
   COUNT(*) AS "Suma de Cantidad"
FROM 
    BEAS_APLATZ_STILLSTAND T0
INNER JOIN 
    BEAS_APLATZ T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
WHERE 
    T0."DATUM_VON" BETWEEN '2024-08-01' AND '2024-08-30' AND
    T0."RESOURCETYPE" = 'resource' AND
    T0."GRUNDID" IN ('014','015','009','008') AND
    T0."APLATZ_ID" IN ('G061', 'G003', 'G083', 'G004', 'G006', 
                       'G008', 'G081', 'G082', 'G104', 'G009', 
                       'G010', 'G011', 'G013', 'G014', 'G015', 
                       'G016', 'G018', 'G019', 'G020', 'G023', 
                       'G028', 'G029', 'G037', 'G038', 'G039', 
                       'G040', 'G060', 'G044', 'G045', 'G046',
                       'G049', 'G050', 'G051', 'G052', 'G055',
                       'G056', 'G057', 'G058', 'G105', 'G106',
                       'G107', 'G108', 'G109', 'G110', 'G080')
GROUP BY 
   T0."APLATZ_ID"

UNION ALL

-- Consulta de totales
SELECT 
   'Total General' AS "Recurso",  -- Etiqueta para el total general
   ROUND(SUM(ABS(SECONDS_BETWEEN(T0."DATUM_BIS", T0."DATUM_VON") / 60)), 2) AS "Suma de Duración en Minutos",
   COUNT(*) AS "Suma de Cantidad"
FROM 
    BEAS_APLATZ_STILLSTAND T0
INNER JOIN 
    BEAS_APLATZ T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
WHERE 
    T0."DATUM_VON" BETWEEN '2024-08-01' AND '2024-08-30' AND
    T0."RESOURCETYPE" = 'resource' AND
    T0."GRUNDID" IN ('014','015','009','008') AND
    T0."APLATZ_ID" IN ('G061', 'G003', 'G083', 'G004', 'G006', 
                       'G008', 'G081', 'G082', 'G104', 'G009', 
                       'G010', 'G011', 'G013', 'G014', 'G015', 
                       'G016', 'G018', 'G019', 'G020', 'G023', 
                       'G028', 'G029', 'G037', 'G038', 'G039', 
                       'G040', 'G060', 'G044', 'G045', 'G046',
                       'G049', 'G050', 'G051', 'G052', 'G055',
                       'G056', 'G057', 'G058', 'G105', 'G106',
                       'G107', 'G108', 'G109', 'G110', 'G080')
ORDER BY 
   --CASE WHEN "Recurso" = 'Total General' THEN 1 ELSE 0 END,
   "Recurso";