/* traslado de cuarentena  original*/
SELECT 
    P0."DocNum", 
    P0."DocDate", 
    P0."Orden", 
    P0."Posicion", 
    P0."ItemCode", 
    P0."Dscription", 
    P0."Grupo_Articulo", 
    P0."Unidad_Medida", 
    P0."Numero_Lote", 
    P0."Desde_Bodega", 
    P0."A_Bodega",
    P0."Proceso", 
    P0."Motivo_Traslado", 
    P0."Peso_Unidad", 
    P0."Precio", 
    P0."Cantidad_Lote", 
    P0."Cantidad_Lote", 
    P0."Cantidad_Producida", 
    P0."Costo", 
    P0."KG", 
    P0."%_Afectado", 
    P1."PERS_ID", 
    P1."Operador", 
    P1."Recurso" 
FROM ( 
    SELECT 
        T0."DocNum",
        T0."DocDate",
        LEFT(T4."DistNumber",5) AS "Orden",
        CASE 
            WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3)
            WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3)
            ELSE SUBSTRING(T4."DistNumber",6,2) 
        END AS "Posicion",
        T1."ItemCode",
        T1."Dscription",
        T7."ItmsGrpNam" AS "Grupo_Articulo",
        T1."unitMsr" AS "Unidad_Medida",
        T4."DistNumber" AS "Numero_Lote",
        T1."FromWhsCod" AS "Desde_Bodega",
        T1."WhsCode" AS "A_Bodega",
        COALESCE(T8."U_DPE_PROCESS", 'S/M') AS "Proceso",
        COALESCE(T8."Name", 'S/M') AS "Motivo_Traslado",
        T6."U_SYP_PESOBRUTO" AS "Peso_Unidad",
        T1."StockPrice" AS "Precio",
        T3."Quantity" As "Cantidad_Lote",
        T5."GEL_MENGE" AS "Cantidad_Producida",
        (T1."StockPrice" * T3."Quantity") AS "Costo",
        CASE
            WHEN T1."unitMsr" = 'KG' THEN T3."Quantity"
            WHEN T1."unitMsr" = 'PACK' THEN (T6."U_SYP_UPPL" * T6."U_SYP_PESOBRUTO" * T3."Quantity")
            ELSE (T6."U_SYP_PESOBRUTO" * T3."Quantity") 
        END AS "KG",
        (T3."Quantity"/T5."GEL_MENGE") AS "%_Afectado",
        T9."PERS_ID", T9."DisplayName", T9."APLATZ_ID" as "RESOURCE"
            --, T9.*
        FROM OWTR T0
        INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
        INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
            AND T1."WhsCode" = T2."LocCode" 
            AND T2."DocType" = '67' 
            AND T1."LineNum" = T2."DocLine"
        INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
        INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
            AND CAST(T5."BELPOS_ID" AS VARCHAR) = (CASE WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3) WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3) ELSE SUBSTRING(T4."DistNumber",6,2) END)
            AND T1."ItemCode" = T5."ItemCode"
        INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
        INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod"
        LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
        LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" 
            AND T5."BELPOS_ID" = T9."BELPOS_ID" AND T4."DistNumber" = T9."BatchNum" AND T9."CANCEL" != '1'
        WHERE T1."WhsCode" IN ('11PCD', '12PCD', '20PCD')
        AND T0."DocDate" > '2024-01-01'
        --AND T0."DocNum" = '24002124'
        --AND T0."UserSign" = '41'
        AND T0."CANCELED" = 'N' AND T1."Quantity" > 0 
    ) P0 
INNER JOIN ( 
    SELECT
        T7."BELNR_ID" as "Orden", 
        T7."BELPOS_ID" as "Pos", 
        T6."ItemCode", 
        T4."DistNumber" as "LOTE", 
        T8."PERS_ID", 
        T8."DisplayName" as "Operador", 
        T8."APLATZ_ID" as "Recurso", 
        T1."Quantity"
    FROM OIGN T0
    INNER JOIN IGN1 T1 ON T0."DocEntry" = T1."DocEntry"
    INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T7 on T7."BELNR_ID" = T1."U_beas_belnrid"
    INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND T1."WhsCode" = T2."LocCode" AND T2."DocType" = '59'
    INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
    LEFT JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
    INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
    INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T8 on T8."BELNR_ID" = T7."BELNR_ID"  and T8."BELPOS_ID" = T7."BELPOS_ID" and T8."BUCHNR_ID" = T1."U_beas_basedocentry"
    where  T8."APLATZ_ID" not like 'GM%' 
)  P1 on  CAST(P1."Orden" as VARCHAR) = P0."Orden" and P1."Pos" = P0."Posicion" and P1."LOTE" = P0."Numero_Lote"

/* Traslados Cuarentena/Destruccion dia anterior */

SELECT
    T0."DocNum",
    T0."DocDate",
    LEFT(T4."DistNumber",5) AS "Orden",
    CASE WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3)
    WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3)
    ELSE SUBSTRING(T4."DistNumber",6,2) END AS "Posicion",
    T1."ItemCode",
    T1."Dscription",
    T7."ItmsGrpNam" AS "Grupo_Articulo",
    T1."unitMsr" AS "Unidad_Medida",
    T4."DistNumber" AS "Numero_Lote",
    T1."FromWhsCod" AS "Desde_Bodega",
    T1."WhsCode" AS "A_Bodega",
    COALESCE(T8."U_DPE_PROCESS", 'S/M') AS "Proceso",
    COALESCE(T8."Name", 'S/M') AS "Motivo_Traslado",
    T6."U_SYP_PESOBRUTO" AS "Peso_Unidad",
    T1."StockPrice" AS "Precio",
    T3."Quantity" As "Cantidad_Lote",
    T5."GEL_MENGE" AS "Cantidad_Producida",
    (T1."StockPrice" * T3."Quantity") AS "Costo",
    CASE
        WHEN T1."unitMsr" = 'KG' THEN T3."Quantity"
        WHEN T1."unitMsr" = 'PACK' THEN (T6."U_SYP_UPPL" * T6."U_SYP_PESOBRUTO" * T3."Quantity")
        ELSE (T6."U_SYP_PESOBRUTO" * T3."Quantity") 
    END AS "KG",
    (T3."Quantity"/T5."GEL_MENGE") AS "%_Afectado"

FROM OWTR T0
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND T1."WhsCode" = T2."LocCode" AND T2."DocType" = '67'
INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
    AND CAST(T5."BELPOS_ID" AS VARCHAR) = (CASE WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3) WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3) ELSE SUBSTRING(T4."DistNumber",6,2) END)
    AND T1."ItemCode" = T5."ItemCode"
INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod"
LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"

WHERE T1."WhsCode" IN ('11PCD', '12PCD', '20PCD')
AND T0."DocDate" = ADD_DAYS(CURRENT_DATE, - 1)
--AND T0."UserSign" = '41'
AND T0."CANCELED" = 'N' AND T1."Quantity" > 0


/* haciendo el query de traslado pt a bodega 04 */
/* Filtro cualquier PT código 07 -> itemcode
Desde cualquier bodega 
A todas las bodegas 04 de producción. 
 */

 SELECT
    T0."DocNum",
    T0."DocDate",
    LEFT(T4."DistNumber",5) AS "Orden",
    CASE WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3)
    WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3)
    ELSE SUBSTRING(T4."DistNumber",6,2) END AS "Posicion",
    T1."ItemCode",
    T1."Dscription",
    --T7."ItmsGrpNam" AS "Grupo_Articulo",
    T1."unitMsr" AS "Unidad_Medida",
    T4."DistNumber" AS "Numero_Lote",
    T1."FromWhsCod" AS "Desde_Bodega",
    T1."WhsCode" AS "A_Bodega",
    --COALESCE(T8."U_DPE_PROCESS", 'S/M') AS "Proceso",
    --COALESCE(T8."Name", 'S/M') AS "Motivo_Traslado",
    --T6."U_SYP_PESOBRUTO" AS "Peso_Unidad",
    T1."StockPrice" AS "Precio",
    T3."Quantity" As "Cantidad_Lote",
    --T5."GEL_MENGE" AS "Cantidad_Producida",
    (T1."StockPrice" * T3."Quantity") AS "Costo" --,
    --CASE
       -- WHEN T1."unitMsr" = 'KG' THEN T3."Quantity"
        --WHEN T1."unitMsr" = 'PACK' THEN (T6."U_SYP_UPPL" * T6."U_SYP_PESOBRUTO" * T3."Quantity")
        --ELSE (T6."U_SYP_PESOBRUTO" * T3."Quantity") 
    --END AS "KG",
    --(T3."Quantity"/T5."GEL_MENGE") AS "%_Afectado"

FROM OWTR T0
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND T1."WhsCode" = T2."LocCode" AND T2."DocType" = '67'
INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"

/*INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
    AND CAST(T5."BELPOS_ID" AS VARCHAR) = (CASE WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3) WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3) ELSE SUBSTRING(T4."DistNumber",6,2) END)
    AND T1."ItemCode" = T5."ItemCode"
INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod"
LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"*/

WHERE T1."WhsCode" IN ('11PCD', '12PCD', '20PCD')
AND T0."DocDate" = ADD_DAYS(CURRENT_DATE, - 7)
--AND T0."UserSign" = '41'
AND T0."CANCELED" = 'N' AND T1."Quantity" > 0
AND T1."ItemCode" LIKE '07%'



/* opcion 2 */
SELECT
    T0."DocNum",
    T0."DocDate",
    LEFT(T4."DistNumber", 5) AS "Orden",
    CASE 
        WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber", 6, 3)
        WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber", 6, 3)
        ELSE SUBSTRING(T4."DistNumber", 6, 2) 
    END AS "Posicion",
    T1."ItemCode",
    T1."Dscription",
    T7."ItmsGrpNam" AS "Grupo_Articulo",
    T1."unitMsr" AS "Unidad_Medida",
    T4."DistNumber" AS "Numero_Lote",
    T1."FromWhsCod" AS "Desde_Bodega",
    T1."WhsCode" AS "A_Bodega",
    COALESCE(T8."U_DPE_PROCESS", 'S/M') AS "Proceso",
    COALESCE(T8."Name", 'S/M') AS "Motivo_Traslado",
    T6."U_SYP_PESOBRUTO" AS "Peso_Unidad",
    T1."StockPrice" AS "Precio",
    T3."Quantity" AS "Cantidad_Lote",
    T5."GEL_MENGE" AS "Cantidad_Producida",
    (T1."StockPrice" * T3."Quantity") AS "Costo",
    CASE
        WHEN T1."unitMsr" = 'KG' THEN T3."Quantity"
        WHEN T1."unitMsr" = 'PACK' THEN (T6."U_SYP_UPPL" * T6."U_SYP_PESOBRUTO" * T3."Quantity")
        ELSE (T6."U_SYP_PESOBRUTO" * T3."Quantity") 
    END AS "KG",
    (T3."Quantity"/T5."GEL_MENGE") AS "%_Afectado"

FROM OWTR T0  --Traslado de stock
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry" --Traslado de stock - filas
INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND T1."WhsCode" = T2."LocCode" AND T2."DocType" = '67' --Log de transaciones de inventario
INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry" --Detalles de num de serie y lote en transaccion
INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry" --Datos maestro de numero de series
INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber", 5)
    AND CAST(T5."BELPOS_ID" AS VARCHAR) = (CASE 
        WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber", 6, 3) 
        WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber", 6, 3) 
        ELSE SUBSTRING(T4."DistNumber", 6, 2) END)
    AND T1."ItemCode" = T5."ItemCode"
INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"  --Item o "Artículos"
INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod"  --Grupo de artículos
LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code" --Motivo traslado cuarentena

WHERE 
    -- Filtrar por códigos de artículos que comienzan con '07'
    LEFT(T1."ItemCode", 2) = '07'
    
    -- Desde cualquier bodega
    AND T1."WhsCode" <> ''
    
    -- A todas las bodegas de producción (que comienzan con '04')
    AND LEFT(T1."WhsCode", 2) = '04'
    
    -- Filtrar por la fecha del documento
    AND T0."DocDate" = ADD_DAYS(CURRENT_DATE, -1)
    
    -- Asegurarse de que el documento no esté cancelado y que la cantidad sea mayor a cero
    AND T0."CANCELED" = 'N' 
    AND T1."Quantity" > 0;