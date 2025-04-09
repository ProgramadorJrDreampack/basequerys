/* 
Reporte de tiempos de produccion por rango de fecha, 
filtrando grupo de recurso, agregar familia y subfamilia de articulo, 
en estructura de articulo determinar velocidades del recurso
 */

/* EJEMPLO BASE */
 SELECT 
    RG."ResourceGroup", 
    R."ResourceName", 
    A."ItemFamily", 
    A."ItemSubFamily", 
    SUM(P."ProductionTime") AS TotalProductionTime, 
    COUNT(P."EventID") AS EventCount,
    AVG(R."Speed") AS AverageSpeed
FROM 
    ResourceGroups RG
INNER JOIN 
    Resources R ON RG."GroupID" = R."GroupID"
INNER JOIN 
    ProductionTimes P ON R."ResourceID" = P."ResourceID"
INNER JOIN 
    Articles A ON P."ArticleID" = A."ArticleID"
WHERE 
    P."ProductionDate" BETWEEN [%0] AND [%1]
GROUP BY 
    RG."ResourceGroup", 
    R."ResourceName", 
    A."ItemFamily", 
    A."ItemSubFamily"
ORDER BY 
    TotalProductionTime DESC;  -- ordenar por tiempo total de producción


/* BEAS RECURSOS CON TIEMPOS Y SUBFAMILIA */

SELECT DISTINCT(P0."APLATZ_ID") as "Recurso", 
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
(
    SELECT 
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
order by 
    P0."APLATZ_ID", P0."F"

    /* realizando el query 06-11-2024*/

SELECT 
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   T0."ZEIT" AS "Hora_Reportado",
   T0."MENGE_GUT" AS "OK",
   T0."BELNR_ID" AS "Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   T1.*,
   T2.* 
FROM BEAS_ARBZEIT T0
--INNER JOIN BEAS_FTPOS T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
WHERE  
   T0."PERS_ID" = 432 AND
   T0."ANFZEIT" BETWEEN '2024-08-20' AND '2024-08-24'
LIMIT 100

--SELECT * FROM BEAS_FTPOS LIMIT 10


---------------------------------------
SELECT 
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   T0."ZEIT" AS "Hora_Reportado",
   T0."MENGE_GUT" AS "OK",
   T0."BELNR_ID" AS "Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   T2."ItemCode" AS "Articulo",
   T2."ItemName" AS "Articulo_Descripcion",
   T3."BEZ" AS "Actividad"
   --T1.*,
   --T3.* 
FROM BEAS_ARBZEIT T0
--INNER JOIN BEAS_FTPOS T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
LEFT JOIN BEAS_FTAPL T3 ON T1."BELNR_ID" = T3."BELNR_ID"
WHERE 
   T0."MENGE_GUT" > 0 AND
   T0."ZEIT" > 0 AND
   T0."PERS_ID" = 432 AND
   T0."ANFZEIT" BETWEEN '2024-08-20' AND '2024-08-24'
GROUP BY 
  T0."PERS_ID",T0."DisplayName",T0."ANFZEIT", T0."ENDZEIT", T0."ZEIT", T0."MENGE_GUT",  T0."BELNR_ID",
  T1."AUFTRAG",T2."ItemCode", T2."ItemName", T3."BEZ"
--LIMIT 100

--SELECT * FROM BEAS_FTPOS LIMIT 10

--SELECT * FROM BEAS_FTAPL LIMIT 10


-----------------------------------------------------------------
SELECT 
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   T0."ZEIT" AS "Hora_Reportado",
   T0."MENGE_GUT" AS "OK",
   T0."BELNR_ID" AS "Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   T4."ItemCode" AS "Articulo",
   T4."ItemName" AS "Articulo_Descripcion",
   T0."APLATZ_ID" AS "Recurso",
   T3."BEZ" AS "Actividad"
   --T1.*,
   --T1.* 
FROM BEAS_ARBZEIT T0
--INNER JOIN BEAS_FTPOS T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
LEFT JOIN BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4)  = T3."APLATZ_ID" 
INNER JOIN OITM T4 ON T1."ItemCode" = T4."ItemCode"
WHERE 
   T0."MENGE_GUT" > 0 AND
   T0."ZEIT" > 0 AND
   T0."PERS_ID" = 432 AND
   T0."ANFZEIT" BETWEEN '2024-08-20' AND '2024-08-24'
--GROUP BY 
  /*T0."PERS_ID",T0."DisplayName",T0."ANFZEIT", T0."ENDZEIT", T0."ZEIT", T0."MENGE_GUT",  T0."BELNR_ID",
  T1."AUFTRAG",T3."ItemCode", T3."ItemName"*/
--LIMIT 100



/* CASI CERCA */
SELECT 
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   T0."ZEIT" AS "Hora_Reportado",
   T0."MENGE_GUT" AS "OK",
   T0."BELNR_ID" AS "Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   T4."ItemCode" AS "Articulo",
   T4."ItemName" AS "Articulo_Descripcion",
   T3."BEZ" AS "Actividad",
   T0."APLATZ_ID" AS "Recurso",
   T5."Name" AS "Familia",
   T6."Name" As "SubFamilia",
   (T0."MENGE_GUT" / T0."ZEIT") AS "Velocidad_Real" --,
   --A0.*
   --T1.* 
FROM BEAS_ARBZEIT T0
--INNER JOIN BEAS_FTPOS T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4)  = T3."APLATZ_ID" AND T3."Active" = 'J' 
--INNER JOIN BEAS_APL A0 ON T3."APLATZ_ID" = A0."APLATZ_ID"
LEFT JOIN OITM T4 ON T1."ItemCode" = T4."ItemCode"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T5 ON T4."U_SYP_SUBGRUPO3" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T6 ON T4."U_SYP_SUBGRUPO4" = T6."Code"
WHERE 
   T0."MENGE_GUT" > 0 AND
   T0."ZEIT" > 0 AND
   T0."PERS_ID" = 432 AND
   T0."ANFZEIT" BETWEEN '2024-08-20' AND '2024-08-24'



   --------------OTRA CONSULTA CON DISTINCT--------------------
SELECT DISTINCT
    P0."PERS_ID" AS "Personal",
    P0."DisplayName" AS "Nombre",
    P0."Iniciar",
    P0."Final",
    P0."ZEIT" AS "Hora_Reportado",
    P0."MENGE_GUT" AS "OK",
    P0."BELNR_ID" AS "Orden",
    P0."AUFTRAG" AS "Orden_Trabajo",
    P0."ItemCode" AS "Articulo",
    P0."ItemName" AS "Articulo_Descripcion",
    P0."BEZ" AS "Actividad",
    P0."APLATZ_ID" AS "Recurso",
    P0."F" AS "Familia",
    P0."SubF" AS "SubFamilia",
    P0."VTRF" AS "Velocidad_teorica_recurso_por_subfamilia",
    P0."VR" AS "Velocidad_Real"
FROM
(
SELECT 
   T0."PERS_ID",
   T0."DisplayName",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   T0."ZEIT",
   T0."MENGE_GUT",
   T0."BELNR_ID",
   T1."AUFTRAG",
   T4."ItemCode",
   T4."ItemName",
   T3."BEZ",
   T0."APLATZ_ID",
   T5."Name" AS "F",
   T6."Name" AS "SubF",
   A0."MENGE_JE" AS "VTRF",
   (T0."MENGE_GUT" / T0."ZEIT") AS "VR"
   --A0.*
   --T1.* 
FROM BEAS_ARBZEIT T0
--INNER JOIN BEAS_FTPOS T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4)  = T3."APLATZ_ID" AND T3."Active" = 'J' 
INNER JOIN BEAS_APL A0 ON T3."APLATZ_ID" = A0."APLATZ_ID"
LEFT JOIN OITM T4 ON T1."ItemCode" = T4."ItemCode"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T5 ON T4."U_SYP_SUBGRUPO3" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T6 ON T4."U_SYP_SUBGRUPO4" = T6."Code"
WHERE 
   T0."MENGE_GUT" > 0 AND
   T0."ZEIT" > 0 AND
   T0."PERS_ID" = 432 AND
   T0."ANFZEIT" BETWEEN '2024-08-20' AND '2024-08-24' AND
   T4."validFor" = 'Y'

)
P0
WHERE 
    P0."APLATZ_ID" LIKE 'G%' AND 
    P0."APLATZ_ID" NOT LIKE 'GM%'



    /* otro query de tiempo de produccion por probar sin rendimiento */
SELECT 
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   T0."ZEIT" AS "Hora_Reportado",
   T0."MENGE_GUT" AS "OK",
   T0."BELNR_ID" AS "Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   T4."ItemCode" AS "Articulo",
   T4."ItemName" AS "Articulo_Descripcion",
   T3."BEZ" AS "Actividad",
   T0."APLATZ_ID" AS "Recurso",
   T5."Name" AS "Familia",
   T6."Name" AS "SubFamilia",
   (T0."MENGE_GUT" / T0."ZEIT") AS "Velocidad_Real",
   P2."Articulo_terminado" AS "Articulo_Terminado",  -- Theoretical speed
   P2."Eficiencia" AS "Eficiencia_Teorica",  -- Efficiency from theoretical speeds
   P2."Tiempo minuto" AS "Tiempo_Minuto_Teorico"  -- Time in minutes from theoretical speeds
FROM BEAS_ARBZEIT T0
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"
INNER JOIN BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4) = T3."APLATZ_ID" AND T3."Active" = 'J'
LEFT JOIN OITM T4 ON T1."ItemCode" = T4."ItemCode"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T5 ON T4."U_SYP_SUBGRUPO3" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T6 ON T4."U_SYP_SUBGRUPO4" = T6."Code"
LEFT JOIN (
    SELECT 
        DISTINCT(P0."APLATZ_ID") as "Recurso", 
        P0."MENGE_JE" as "Articulo_terminado", 
        P0."ZEITGRAD" as "Eficiencia", 
        P0."MENGE_ZEITJE" as "Tiempo minuto"
    FROM (
        SELECT 
            T0."APLATZ_ID", 
            T0."MENGE_JE", 
            A0."ZEITGRAD", 
            T0."MENGE_ZEITJE"
        FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID"
        INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
        WHERE A0.Active = 'J' AND T1.validFor = 'Y'
    ) P0
    WHERE 
        P0."APLATZ_ID" LIKE 'G%' AND 
        P0."APLATZ_ID" NOT LIKE 'GM%'
) P2 ON P2.Recurso = T0.APLATZ_ID  -- Joining on Resource ID
WHERE 
   T0."MENGE_GUT" > 0 AND
   T0."ZEIT" > 0 AND
   T0."PERS_ID" = 432 AND
   T0."ANFZEIT" BETWEEN '2024-08-20' AND '2024-08-24';


   /* este si con rendimiento hay que probar */

SELECT 
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   T0."ZEIT" AS "Hora_Reportado",
   T0."MENGE_GUT" AS "OK",
   T0."BELNR_ID" AS "Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   T4."ItemCode" AS "Articulo",
   T4."ItemName" AS "Articulo_Descripcion",
   T3."BEZ" AS "Actividad",
   T0."APLATZ_ID" AS "Recurso",
   T5."Name" AS "Familia",
   T6."Name" AS "SubFamilia",
   (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",  -- Real speed calculation
   P2."Articulo_terminado" AS "Articulo_Terminado",  -- Theoretical speed
   P2."Eficiencia" AS "Eficiencia_Teorica",  -- Efficiency from theoretical speeds
   P2."Tiempo minuto" AS "Tiempo_Minuto_Teorico",  -- Time in minutes from theoretical speeds
   (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF(P2."Articulo_terminado", 0) AS "Rendimiento"  -- Performance calculation
FROM BEAS_ARBZEIT T0
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"
INNER JOIN BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4) = T3."APLATZ_ID" AND T3."Active" = 'J'
LEFT JOIN OITM T4 ON T1."ItemCode" = T4."ItemCode"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T5 ON T4."U_SYP_SUBGRUPO3" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T6 ON T4."U_SYP_SUBGRUPO4" = T6."Code"
LEFT JOIN (
    SELECT 
        DISTINCT(P0."APLATZ_ID") as "Recurso", 
        P0."MENGE_JE" as "Articulo_terminado", 
        P0."ZEITGRAD" as "Eficiencia", 
        P0."MENGE_ZEITJE" as "Tiempo minuto"
    FROM (
        SELECT 
            T0."APLATZ_ID", 
            T0."MENGE_JE", 
            A0."ZEITGRAD", 
            T0."MENGE_ZEITJE"
        FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID"
        INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
        WHERE A0."Active" = 'J' AND 
              T1."validFor" = 'Y'
    ) P0
    WHERE 
        P0."APLATZ_ID" LIKE 'G%' AND 
        P0."APLATZ_ID" NOT LIKE 'GM%'
) P2 ON P2."Recurso" = T0."APLATZ_ID"  -- Joining on Resource ID
WHERE 
   T0."MENGE_GUT" > 0 AND
   T0."ZEIT" > 0 AND
   T0."PERS_ID" = 432 AND
   T0."ANFZEIT" BETWEEN '2024-08-20' AND '2024-08-24';


--    **************************************

SELECT 
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   T0."ZEIT" AS "Hora_Reportado",
   T0."MENGE_GUT" AS "OK",
   T0."BELNR_ID" AS "Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   P2."Articulo_terminado" AS "Articulo_Terminado",  -- Theoretical speed
   P2."Eficiencia" AS "Eficiencia_Teorica",  -- Efficiency from theoretical speeds
   P2."Tiempo minuto" AS "Tiempo_Minuto_Teorico",  -- Time in minutes from theoretical speeds
   (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",  -- Real speed calculation
   (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF(P2."Articulo_terminado", 0) AS "Rendimiento",  -- Performance calculation
   P2."F" AS "Familia",  -- Family from subquery
   P2."SF" AS "SubFamilia"  -- Subfamily from subquery
FROM BEAS_ARBZEIT T0
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"
INNER JOIN BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4) = T3."APLATZ_ID" AND T3."Active" = 'J'
LEFT JOIN (
    SELECT 
        DISTINCT(P0."APLATZ_ID") as "Recurso", 
        P0."MENGE_JE" as "Articulo_terminado", 
        P0."ZEITGRAD" as "Eficiencia", 
        P0."MENGE_ZEITJE" as "Tiempo minuto",
        T1."F" AS "Familia",  -- Family from OITM
        T2."SF" AS "SubFamilia"  -- Subfamily from OITM
    FROM (
        SELECT 
            T0."APLATZ_ID", 
            T0."MENGE_JE", 
            A0."ZEITGRAD", 
            T0."MENGE_ZEITJE",
            T1."ItemCode"
        FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID"
        INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
        WHERE A0.Active = 'J' AND T1.validFor = 'Y'
    ) P0
    LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON P0.ItemCode = T1.Code
    LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON P0.ItemCode = T2.Code
    WHERE 
        P0."APLATZ_ID" LIKE 'G%' AND 
        P0."APLATZ_ID" NOT LIKE 'GM%'
) P2 ON P2.Recurso = T0.APLATZ_ID  -- Joining on Resource ID
WHERE 
   T0."MENGE_GUT" > 0 AND
   T0."ZEIT" > 0 AND
   T0."PERS_ID" = 432 AND
   T0."ANFZEIT" BETWEEN '2024-08-20' AND '2024-08-24';



   /* este si salio perfecto por el moemnto  */
SELECT 
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   T0."ZEIT" AS "Hora_Reportado",
   T0."MENGE_GUT" AS "OK",
   T0."BELNR_ID" AS "Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   T4."ItemCode" AS "Articulo",
   T4."ItemName" AS "Articulo_Descripcion",
   T3."BEZ" AS "Actividad",
   T0."APLATZ_ID" AS "Recurso",
   T5."Name" AS "Familia",
   T6."Name" AS "SubFamilia",
   P2."Articulo_terminado" AS "Velocidad_teorica",
   (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
   
   --P2."Eficiencia" AS "Eficiencia_Teorica",
   --P2."Tiempo minuto" AS "Tiempo_Minuto_Teorico",
   (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF(P2."Articulo_terminado", 0) AS "Rendimiento"  
FROM BEAS_ARBZEIT T0
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"
INNER JOIN BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4) = T3."APLATZ_ID" AND T3."Active" = 'J'
LEFT JOIN OITM T4 ON T1."ItemCode" = T4."ItemCode"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T5 ON T4."U_SYP_SUBGRUPO3" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T6 ON T4."U_SYP_SUBGRUPO4" = T6."Code"
LEFT JOIN (
    SELECT 
        DISTINCT(P0."APLATZ_ID") as "Recurso", 
        P0."MENGE_JE" as "Articulo_terminado", 
        P0."ZEITGRAD" as "Eficiencia", 
        P0."MENGE_ZEITJE" as "Tiempo minuto"
    FROM (
        SELECT 
            T0."APLATZ_ID", 
            T0."MENGE_JE", 
            A0."ZEITGRAD", 
            T0."MENGE_ZEITJE"
        FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID"
        INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
        WHERE A0."Active" = 'J' AND 
              T1."validFor" = 'Y'
    ) P0
    WHERE 
        P0."APLATZ_ID" LIKE 'G%' AND 
        P0."APLATZ_ID" NOT LIKE 'GM%'
) P2 ON P2."Recurso" = T0."APLATZ_ID"
WHERE 
   T0."MENGE_GUT" > 0 AND
   T0."ZEIT" > 0 AND
   T0."PERS_ID" = 432 AND
   T0."ANFZEIT" BETWEEN '2024-08-20' AND '2024-08-24';



   


/*Por el momento tengo asi 7-11-2024  */

SELECT 
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   T0."ZEIT" AS "Hora_Reportado",
   T0."MENGE_GUT" AS "OK",
   T0."BELNR_ID" AS "Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   T4."ItemCode" AS "Articulo",
   T4."ItemName" AS "Articulo_Descripcion",
   T3."BEZ" AS "Actividad",
   T0."APLATZ_ID" AS "Recurso",
   T5."Name" AS "Familia",
   T6."Name" As "SubFamilia",
   (T0."MENGE_GUT" / T0."ZEIT") AS "Velocidad_Real" --,
   --A0.*
   --T1.* 
FROM BEAS_ARBZEIT T0
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4)  = T3."APLATZ_ID" AND T3."Active" = 'J'

LEFT JOIN OITM T4 ON T1."ItemCode" = T4."ItemCode"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T5 ON T4."U_SYP_SUBGRUPO3" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T6 ON T4."U_SYP_SUBGRUPO4" = T6."Code"

--LEFT JOIN BEAS_APL A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND T4."ItemCode" =  A0."ItemCode"

WHERE 
   T0."MENGE_GUT" > 0 AND
   T0."ZEIT" > 0 AND
   T0."PERS_ID" = 432 AND
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-22' AND
   T0."APLATZ_ID" LIKE 'G%' AND 
   T0."APLATZ_ID" NOT LIKE 'GM%'


   /* no salio */

   SELECT 
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   T0."ZEIT" AS "Hora_Reportado",
   T0."MENGE_GUT" AS "OK",
   T0."BELNR_ID" AS "Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   T4."ItemCode" AS "Articulo",
   T4."ItemName" AS "Articulo_Descripcion",
   T3."BEZ" AS "Actividad",
   T0."APLATZ_ID" AS "Recurso",
   T5."Name" AS "Familia",
   T6."Name" As "SubFamilia",
   (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real", -- Evitar división por cero
   P0."MENGE_JE" AS "Articulo_terminado"  -- Artículo terminado
FROM BEAS_ARBZEIT T0
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4) = T3."APLATZ_ID" AND T3."Active" = 'J'
LEFT JOIN OITM T4 ON T1."ItemCode" = T4."ItemCode"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T5 ON T4."U_SYP_SUBGRUPO3" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T6 ON T4."U_SYP_SUBGRUPO4" = T6."Code"
LEFT JOIN (
    SELECT 
        P0."APLATZ_ID", 
        P0."ItemCode", 
        P0."MENGE_JE"
    FROM (
        SELECT 
            T0."ItemCode", 
            T1."ItemName", 
            T2."Name" AS "F", 
            T3."Name" AS "SF", 
            T0."APLATZ_ID", 
            T0."BEZ", 
            T0."TRAPLATZ", 
            T0."TR2APLATZ", 
            T0."TEAPLATZ",           
            T0."MENGE_JE", 
            A0."ZEITGRAD"
        FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
        INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
        WHERE T1."validFor" = 'Y'
    ) P0
    WHERE P0."APLATZ_ID" LIKE 'G%' AND P0."APLATZ_ID" NOT LIKE 'GM%'
) P0 ON P0."ItemCode" = T4."ItemCode" AND P0."APLATZ_ID" = T0."APLATZ_ID"
WHERE 
   T0."MENGE_GUT" > 0 AND
   NULLIF(T0."ZEIT", 0) > 0 AND -- Evitar división por cero
   T0."PERS_ID" = 432 AND
   TO_DATE(T0.ANFZEIT) BETWEEN TO_DATE('2024-08-01') AND TO_DATE('2024-08-22') AND
   T0.APLATZ_ID LIKE 'G%' AND 
   T0.APLATZ_ID NOT LIKE 'GM%'
ORDER BY 
   T0."PERS_ID", T0."ANFZEIT";




   /* LISTO SOLO CONFIRMAR */

   SELECT 
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   T0."ZEIT" AS "Hora_Reportado",
   T0."MENGE_GUT" AS "OK",
   T0."BELNR_ID" AS "Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   T4."ItemCode" AS "Articulo",
   T4."ItemName" AS "Articulo_Descripcion",
   T3."BEZ" AS "Actividad",
   T0."APLATZ_ID" AS "Recurso",
   T5."Name" AS "Familia",
   T6."Name" AS "SubFamilia",
   (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
   A0."MENGE_JE" AS "Articulo_terminado"
FROM BEAS_ARBZEIT T0
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4) = T3."APLATZ_ID" AND T3."Active" = 'J'

INNER JOIN OITM T4 ON T1."ItemCode" = T4."ItemCode"

INNER JOIN BEAS_APL A0 ON T3."APLATZ_ID" = A0."APLATZ_ID" AND  T1."ItemCode" = A0."ItemCode"  AND  T0."POS_ID" = A0."POS_ID"

LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T5 ON T4."U_SYP_SUBGRUPO3" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T6 ON T4."U_SYP_SUBGRUPO4" = T6."Code"  

/*LEFT JOIN (
    SELECT DISTINCT
        P0."APLATZ_ID", 
        P0."ItemCode", 
        P0."MENGE_JE"
    FROM (
        SELECT 
            T0."ItemCode", 
            T1."ItemName", 
            T2."Name" AS "F", 
            T3."Name" AS "SF", 
            T0."APLATZ_ID", 
            T0."BEZ", 
            T0."TRAPLATZ", 
            T0."TR2APLATZ", 
            T0."TEAPLATZ",           
            T0."MENGE_JE", 
            A0."ZEITGRAD"
        FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
        INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
        WHERE T1."validFor" = 'Y'
    ) P0
    WHERE P0."APLATZ_ID" LIKE 'G%' AND P0."APLATZ_ID" NOT LIKE 'GM%'
) P0 ON P0."ItemCode" = T4."ItemCode" AND P0."APLATZ_ID" = T0."APLATZ_ID" */



WHERE 
   T0."MENGE_GUT" > 0 AND
   NULLIF(T0."ZEIT", 0) > 0 AND
   --T0."PERS_ID" = 432 AND
   TO_DATE(T0.ANFZEIT) BETWEEN TO_DATE('2024-08-01') AND TO_DATE('2024-08-22') AND
   T0.APLATZ_ID LIKE 'G%' AND 
   T0.APLATZ_ID NOT LIKE 'GM%'
ORDER BY 
   "Personal", "Iniciar";



   /* este si */

SELECT 
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   T0."ZEIT" AS "Hora_Reportado",
   T0."MENGE_GUT" AS "OK",
   T0."BELNR_ID" AS "Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   T4."ItemCode" AS "Articulo",
   T4."ItemName" AS "Articulo_Descripcion",
   T2."BEZ" AS "Actividad",
   T0."APLATZ_ID" AS "Recurso",
   T3."BEZ" AS "Recurso_Descripcion",
   T5."Name" AS "Familia",
   T6."Name" AS "SubFamilia",
   A0."MENGE_JE" AS "Velocidad_teorica",
   (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
   (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / (A0."MENGE_JE") AS "Rendimiento"
    
FROM BEAS_ARBZEIT T0
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4) = T3."APLATZ_ID" AND T3."Active" = 'J'
INNER JOIN OITM T4 ON T1."ItemCode" = T4."ItemCode"
INNER JOIN BEAS_APL A0 ON T3."APLATZ_ID" = A0."APLATZ_ID" AND  T1."ItemCode" = A0."ItemCode"  AND  T0."POS_ID" = A0."POS_ID"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T5 ON T4."U_SYP_SUBGRUPO3" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T6 ON T4."U_SYP_SUBGRUPO4" = T6."Code"  
WHERE 
   T0."MENGE_GUT" > 0 AND
   NULLIF(T0."ZEIT", 0) > 0 AND
   --T0."PERS_ID" = 717 AND
   TO_DATE(T0.ANFZEIT) BETWEEN TO_DATE('2024-08-01') AND TO_DATE('2024-08-23') AND
   T0.APLATZ_ID LIKE 'G%' AND 
   T0.APLATZ_ID NOT LIKE 'GM%'
ORDER BY 
    T0."ANFZEIT";


/* este si ya verificado con santiago */

SELECT 
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
   T0."ZEIT" AS "Hora_Reportado",
   T0."MENGE_GUT" AS "OK",
   T0."BELNR_ID" AS "Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   T4."ItemCode" AS "Articulo",
   T4."ItemName" AS "Articulo_Descripcion",
   T2."BEZ" AS "Actividad",
   T0."APLATZ_ID" AS "Recurso",
   T3."BEZ" AS "Recurso_Descripcion",
   T5."Name" AS "Familia",
   T6."Name" AS "SubFamilia",
   ((A0."MENGE_JE") / 60) AS "Velocidad_teorica",
   (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
   ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / ((A0."MENGE_JE") / 60) * 100) AS "Rendimiento",
   CASE 
       WHEN ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) IS NOT NULL AND (A0."MENGE_JE") > 0) THEN 
           ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / ((A0."MENGE_JE") / 60)) * 100 
       ELSE 
           NULL 
   END AS "Rendimiento_Real"
 /* ************************************* */   
FROM BEAS_ARBZEIT T0
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4) = T3."APLATZ_ID" AND T3."Active" = 'J'
INNER JOIN OITM T4 ON T1."ItemCode" = T4."ItemCode"
INNER JOIN BEAS_APL A0 ON T3."APLATZ_ID" = A0."APLATZ_ID" AND  T1."ItemCode" = A0."ItemCode"  AND  T0."POS_ID" = A0."POS_ID"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T5 ON T4."U_SYP_SUBGRUPO3" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T6 ON T4."U_SYP_SUBGRUPO4" = T6."Code"  
WHERE 
   T0."MENGE_GUT" > 0 AND
   NULLIF(T0."ZEIT", 0) > 0 AND
   --T0."PERS_ID" = 717 AND
   TO_DATE(T0.ANFZEIT) BETWEEN TO_DATE('2024-08-01') AND TO_DATE('2024-08-31') AND
   T0.APLATZ_ID LIKE 'G%' AND 
   T0.APLATZ_ID NOT LIKE 'GM%' AND
   T2."BEZ" NOT LIKE '%DESCARNADO%'
ORDER BY 
    T0."ANFZEIT";

04DBL07280075
    ---------------------------------
SELECT 
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
   T0."ZEIT" AS "Hora_Reportado",
   T0."MENGE_GUT" AS "OK",
   T0."BELNR_ID" AS "Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   T4."ItemCode" AS "Articulo",
   T4."ItemName" AS "Articulo_Descripcion",
   T2."BEZ" AS "Actividad",
   T0."APLATZ_ID" AS "Recurso",
   T3."BEZ" AS "Recurso_Descripcion",
   T5."Name" AS "Familia",
   T6."Name" AS "SubFamilia",
   ((A0."MENGE_JE") / 60) AS "Velocidad_teorica",
   (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
   ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / ((A0."MENGE_JE") / 60) * 100) AS "Rendimiento",
   CASE 
       WHEN (A0."MENGE_JE" > 0) THEN 
           LEAST(ROUND((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / ((A0."MENGE_JE") / 60) * 100, 2), 100) 
       ELSE 
           NULL 
   END AS "Rendimiento_Ajustado"
    
FROM BEAS_ARBZEIT T0
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4) = T3."APLATZ_ID" AND T3."Active" = 'J'
INNER JOIN OITM T4 ON T1."ItemCode" = T4."ItemCode"
INNER JOIN BEAS_APL A0 ON T3."APLATZ_ID" = A0."APLATZ_ID" AND  T1."ItemCode" = A0."ItemCode"  AND  T0."POS_ID" = A0."POS_ID"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T5 ON T4."U_SYP_SUBGRUPO3" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T6 ON T4."U_SYP_SUBGRUPO4" = T6."Code"  
WHERE 
   T0."MENGE_GUT" > 0 AND
   NULLIF(T0."ZEIT", 0) > 0 AND
   TO_DATE(T0.ANFZEIT) BETWEEN TO_DATE('2024-08-01') AND TO_DATE('2024-08-31') AND
   T0.APLATZ_ID LIKE 'G%' AND 
   T0.APLATZ_ID NOT LIKE 'GM%' AND
   T2."BEZ" NOT LIKE '%DESCARNADO%' AND
   T2."BEZ" NOT LIKE '%TRABAJO%'
ORDER BY 
    T0."ANFZEIT";


    /* ............ */

    SELECT 
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
   T0."ZEIT" AS "Hora_Reportado",
   T0."MENGE_GUT" AS "OK",
   T0."BELNR_ID" AS "Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   T4."ItemCode" AS "Articulo",
   T4."ItemName" AS "Articulo_Descripcion",
   T2."BEZ" AS "Actividad",
   T0."APLATZ_ID" AS "Recurso",
   T3."BEZ" AS "Recurso_Descripcion",
   T5."Name" AS "Familia",
   T6."Name" AS "SubFamilia",
   ((A0."MENGE_JE") / 60) AS "Velocidad_teorica",
   (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
   ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / ((A0."MENGE_JE") / 60) * 100) AS "Rendimiento",
   CASE 
       WHEN (A0."MENGE_JE" > 0) THEN 
           LEAST(ROUND((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / ((A0."MENGE_JE") / 60) * 100, 2), 100) 
       ELSE 
           NULL 
   END AS "Rendimiento_Ajustado"
    
FROM BEAS_ARBZEIT T0
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID" 
INNER JOIN BEAS_FTAPL T2 ON T1."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_APLATZ T3 ON RIGHT(UPPER(T2."AG_ID"), 4) = T3."APLATZ_ID" AND T3."Active" = 'J'
INNER JOIN OITM T4 ON T1."ItemCode" = T4."ItemCode"
LEFT JOIN BEAS_APL A0 ON T3."APLATZ_ID" = A0."APLATZ_ID" AND  T1."ItemCode" = A0."ItemCode"  AND  T0."POS_ID" = A0."POS_ID"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T5 ON T4."U_SYP_SUBGRUPO3" = T5."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T6 ON T4."U_SYP_SUBGRUPO4" = T6."Code"  
WHERE 
   T0."MENGE_GUT" > 0 AND
   NULLIF(T0."ZEIT", 0) > 0 AND
   --TO_DATE(T0.ANFZEIT) BETWEEN TO_DATE('2024-08-01') AND TO_DATE('2024-08-31') AND
   TO_DATE(T0.ANFZEIT) >= TO_DATE('2024-08-01') AND
   TO_DATE(T0.ANFZEIT) <= TO_DATE('2024-08-31') AND
   T0.APLATZ_ID LIKE 'G%' AND 
   T0.APLATZ_ID NOT LIKE 'GM%' AND
   T2."BEZ" NOT LIKE '%DESCARNADO%' AND
   T2."BEZ" NOT LIKE '%TRABAJO%'
ORDER BY 
    T0."ANFZEIT";




/* Realizando el queru de tiempos de producción */

/*SELECT
   T0."BELNR_ID" AS "N° Orden",
   T0."ABGKZ"
FROM BEAS_FTHAUPT T0  --Órdenes de trabajo
WHERE 
   TO_DATE(T0."ANFZEIT") BETWEEN TO_DATE('2024-08-02') AND TO_DATE('2024-08-30')
    AND T0."BELNR_ID" = '29757'
    --AND T0."BELNR_ID" = '024081'  NO SALIO ND*/

/* SELECT 
   T0."ABGKZ",
   T0."BELNR_ID" AS "N° Orden",
   T1."AUFTRAG" AS "Orden_Trabajo"
FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"   --Órdenes de trabajo
WHERE 
   --TO_DATE(T0."ANFZEIT") BETWEEN TO_DATE('2024-08-02') AND TO_DATE('2024-08-30')
    T0."ANFZEIT" BETWEEN '2024-08-02' AND '2024-08-30'
    --T0."ANFZEIT" >= '2024-08-02' AND T0."ANFZEIT" <= '2024-08-30'
    AND T0."BELNR_ID" = '29757'
    AND T0."ABGKZ" = 'J' */



/* SELECT 
   T0."APLATZ_ID",
   T0."ABGKZ" AS "Cerrado",
   T0."PERS_ID" AS "Personal",
   T0."DisplayName" AS "Nombre",
   TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   T0."BELNR_ID" AS "N° Orden",
   T1."AUFTRAG" AS "Orden_Trabajo",
   T1."ABGKZ" AS "Cerrado OT"
FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"   --Órdenes de trabajo
WHERE
    T0."ANFZEIT" BETWEEN '2024-08-02' AND '2024-08-31'
    AND T0."BELNR_ID" = '29757'
    --AND T0."PERS_ID" = '444' --'820' '829'
    --AND T0."ABGKZ" = 'J'
    --AND T1."ABGKZ" = 'J'
    AND T0."APLATZ_ID" LIKE 'G%' 
    AND T0.APLATZ_ID NOT LIKE 'GM%' */

   /*  SELECT
   T0."BELNR_ID",
   T2."PERS_ID" AS "Personal",
   T2."DisplayName" AS "Nombre",
   TO_NVARCHAR(T2."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T2."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T2."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T2."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T2."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T2."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
   T2."ZEIT" AS "Hora_Reportado",
   T2."MENGE_GUT" AS "OK",
   T2."BELNR_ID" AS "Orden",
   T0."AUFTRAG" AS "Orden_Trabajo",
   T3."ART1_ID" AS "Articulo",
   T3."ItemName" AS "Articulo_Descripcion",
   T0.*
FROM BEAS_FTHAUPT T0  --Órdenes de trabajo
INNER JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID" --AND  T0."BELPOS_ID" = T1."BELPOS_ID"   --Enrutamiento de producción
INNER JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"  --Recibo del tiempo de producción
INNER JOIN BEAS_FTSTL T3 ON T2."BELNR_ID" = T3."BELNR_ID" AND T2."BELPOS_ID" = T3."BELPOS_ID" --AND T2."POS_ID" = T3."POS_ID" --Orden de trabajo Lista de materiales Artículo
WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-02' AND '2024-08-31'
   AND T2."BELNR_ID" = '29757'
   AND  T2."PERS_ID" = '444'
   AND T2."APLATZ_ID" LIKE 'G%' 
   AND T2."APLATZ_ID" NOT LIKE 'GM%' */


/* SELECT
   T0."BELNR_ID",
   T2."PERS_ID" AS "Personal",
   T2."DisplayName" AS "Nombre",
   TO_NVARCHAR(T2."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T2."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T2."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T2."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T2."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T2."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
   T2."ZEIT" AS "Hora_Reportado",
   T2."MENGE_GUT" AS "OK",
   T2."BELNR_ID" AS "Orden",
   T0."AUFTRAG" AS "Orden_Trabajo",
   T3."ART1_ID" AS "Articulo",
   T3."ItemName" AS "Articulo_Descripcion",
   T1."BEZ" AS "Actividad",
   T4."APLATZ_ID" AS "Recurso",
   T4."BEZ" AS "Recurso_Descripcion",
   T6."Name" AS "Familia",
   T7."Name" AS "SubFamilia"--,
   --T5.*

   --T4.*
FROM BEAS_FTHAUPT T0  --Órdenes de trabajo
INNER JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"  --Recibo del tiempo de producción
INNER JOIN BEAS_FTSTL T3 ON T2."BELNR_ID" = T3."BELNR_ID" AND T2."BELPOS_ID" = T3."BELPOS_ID" --AND T2."POS_ID" = T3."POS_ID" --Orden de trabajo Lista de materiales Artículo
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T2."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J'
INNER JOIN BEAS_FTAPL T1 ON T2."BELNR_ID" = T1."BELNR_ID" AND  T3."BELPOS_ID" = T1."BELPOS_ID" AND T2."POS_ID" = T1."POS_ID"   --Enrutamiento de producción
INNER JOIN OITM T5 ON T3."ART1_ID" = T5."ItemCode"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"
INNER JOIN BEAS_APL A0 ON 

WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-02' AND '2024-08-31'
   AND T2."BELNR_ID" = '29757'
   AND  T2."PERS_ID" = '444'
   AND T2."APLATZ_ID" LIKE 'G%' 
   AND T2."APLATZ_ID" NOT LIKE 'GM%' */



/* pendiente por revisar con santiago */
SELECT
   --T0."ItemCode",
   --T0."BELNR_ID",
   --T1."POS_ID",

   T2."PERS_ID" AS "Personal",
   T2."DisplayName" AS "Nombre",
   TO_NVARCHAR(T2."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T2."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T2."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T2."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T2."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T2."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
   T2."ZEIT" AS "Hora_Reportado",
   T2."MENGE_GUT" AS "OK",
   T2."BELNR_ID" AS "Orden",
   T0."AUFTRAG" AS "Orden_Trabajo",
   T3."ART1_ID" AS "Articulo",
   T3."ItemName" AS "Articulo_Descripcion",
   T1."BEZ" AS "Actividad",
   T4."APLATZ_ID" AS "Recurso",
   T4."BEZ" AS "Recurso_Descripcion",
   T6."Name" AS "Familia",
   T7."Name" AS "SubFamilia",
   A0."MENGE_JE",
   ((A0."MENGE_JE") / 60) AS "Velocidad_teorica",
   (T2."MENGE_GUT" / NULLIF(T2."ZEIT", 0)) AS "Velocidad_Real",
   ((T2."MENGE_GUT" / NULLIF(T2."ZEIT", 0)) / ((A0."MENGE_JE") / 60) * 100) AS "Rendimiento",
   CASE 
       WHEN (A0."MENGE_JE" > 0) THEN 
           LEAST(ROUND((T2."MENGE_GUT" / NULLIF(T2."ZEIT", 0)) / ((A0."MENGE_JE") / 60) * 100, 2), 100) 
       ELSE 
           NULL 
   END AS "Rendimiento_Ajustado"
   

   --T4.*
FROM BEAS_FTHAUPT T0  --Órdenes de trabajo
INNER JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"  --Recibo del tiempo de producción
INNER JOIN BEAS_FTSTL T3 ON T2."BELNR_ID" = T3."BELNR_ID" AND T2."BELPOS_ID" = T3."BELPOS_ID"  --Orden de trabajo Lista de materiales Artículo
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T2."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN BEAS_FTAPL T1 ON T2."BELNR_ID" = T1."BELNR_ID" AND  T3."BELPOS_ID" = T1."BELPOS_ID" AND T2."POS_ID" = T1."POS_ID"   --Enrutamiento de producción
INNER JOIN OITM T5 ON T3."ART1_ID" = T5."ItemCode"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"
INNER JOIN BEAS_APL A0 ON  T0."ItemCode" = A0."ItemCode" --AND  T2."APLATZ_ID" =  A0."APLATZ_ID" AND

WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-02' AND '2024-08-31'
   AND T2."BELNR_ID" = '29757'
   AND  T2."PERS_ID" = '829' --'444'
   AND T1."APLATZ_ID" LIKE 'G%' 
   AND T1."APLATZ_ID" NOT LIKE 'GM%'
   AND T2."APLATZ_ID" LIKE 'G%' 
   AND T2."APLATZ_ID" NOT LIKE 'GM%'
   AND T1."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T1."BEZ" NOT LIKE '%TRABAJO%'


/* Recurso tiempo y subfamilia */

SELECT DISTINCT
  (P0."APLATZ_ID") as "Recurso", 
  CAST(P0."BEZ" AS VARCHAR) "Descripcion",
  P0."ItemCode", P0."ItemName", 
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
(
  SELECT 
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
WHERE P0."APLATZ_ID" LIKE 'G%' AND P0."APLATZ_ID" NOT LIKE 'GM%'-- AND P0."APLATZ_ID" IN ('G061', 'G080', 'G083')
order by P0."APLATZ_ID", P0."F"


/* REALIZANDO EL NUEVO QUERY  */
SELECT 
   T0."ItemCode",
   T0."BELNR_ID", --ORDEN
   T0."AUFTRAG", --ORDEN DE TRABAJO
   T0."TYP",
   T1."BELPOS_ID",
   T2."BELPOS_ID",
   T2."APLATZ_ID",

   T2."PERS_ID" AS "Personal",
   T2."DisplayName" AS "Nombre",
   TO_NVARCHAR(T2."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
   TO_NVARCHAR(T2."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Final",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T2."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T2."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T2."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T2."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
   T2."ZEIT" AS "Hora_Reportado",
   T2."MENGE_GUT" AS "OK",
   T2."BELNR_ID" AS "Orden",
   T0."AUFTRAG" AS "Orden_Trabajo",
   
   T3.*
FROM BEAS_FTHAUPT T0  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T1."BELPOS_ID" = T2."BELPOS_ID"  --Recibo del tiempo de producción
INNER JOIN BEAS_FTSTL T3 ON T2."BELNR_ID" = T3."BELNR_ID" AND  --Orden de trabajo Lista de materiales Artículo 
--INNER JOIN BEAS_APL T4 ON RIGHT(UPPER(T2."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T0. 
--INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T2."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos  
WHERE 
  T0."ANFZEIT" BETWEEN '2024-08-02' AND '2024-08-31'
  AND T0."BELNR_ID" = '29757'
  AND T2."PERS_ID" = '444' --'829' --'820' --444


  /* YA LA TENGO EL ITEM CODE */
SELECT 
    /*T0."BELNR_ID",
    T0."AUFTRAG",
    T0."TYP",
    T0."BELPOS_ID",*/

    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    --T0."POS_ID",
    T3."BEZ" AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    T4."BEZ" AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",
    A0."MENGE_JE",
    ((A0."MENGE_JE") / 60) AS "Velocidad_teorica",
     ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / ((A0."MENGE_JE") / 60) * 100) AS "Rendimiento",
   CASE 
       WHEN (A0."MENGE_JE" > 0) THEN 
           LEAST(ROUND((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / ((A0."MENGE_JE") / 60) * 100, 2), 100) 
       ELSE 
           NULL 
   END AS "Rendimiento_Ajustado"
FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID"
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"
LEFT JOIN BEAS_APL A0 ON  T5."ItemCode" = A0."ItemCode" AND  T3."APLATZ_ID" =  A0."APLATZ_ID"
WHERE 
   T1."ANFZEIT" BETWEEN '2024-08-02' AND '2024-08-31'
   AND T0."BELNR_ID" = '29757'
   AND T0."PERS_ID" = '444'

--SELECT * FROM BEAS_FTPOS WHERE "BELNR_ID" = '29757'  --LIMIT 10


/* verificando con santiago pre aprobado */
SELECT 
    /*T0."BELNR_ID",
    T0."AUFTRAG",
    T0."TYP",
    T0."BELPOS_ID",*/

    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    --T0."POS_ID",
    T3."BEZ" AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    T4."BEZ" AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",
    --A0."MENGE_JE",
    ((A0."MENGE_JE") / 60) AS "Velocidad_teorica",
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
     ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / ((A0."MENGE_JE") / 60) * 100) AS "Rendimiento",
   CASE 
       WHEN (A0."MENGE_JE" > 0) THEN 
           LEAST(ROUND((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / ((A0."MENGE_JE") / 60) * 100, 2), 100) 
       ELSE 
           NULL 
   END AS "Rendimiento_Ajustado"
FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID"
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"
LEFT JOIN BEAS_APL A0 ON  T5."ItemCode" = A0."ItemCode" AND  T3."APLATZ_ID" =  A0."APLATZ_ID"
WHERE 
   --T1."ANFZEIT" BETWEEN '2024-08-02' AND '2024-08-30'
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   AND T0."BELNR_ID" = '29635'
   AND T0."PERS_ID" = '851' --'829' --'444'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'

   /* *****PRE APROBADO CON SANTIAGO ****** */

SELECT 
    --T0."CANCEL",
    --T4."MENGE_JE",
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",
    A0."MENGE_JE",
    ((A0."MENGE_JE") / 60) AS "Velocidad_teorica",
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / ((A0."MENGE_JE") / 60) * 100) AS "Rendimiento"

FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode" --Artículo
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"
LEFT JOIN BEAS_APL A0 ON  T5."ItemCode" = A0."ItemCode" AND  T3."APLATZ_ID" =  A0."APLATZ_ID" --Posiciones de enrutamiento
WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   --AND T0."BELNR_ID" = '29409'
   --AND T0."PERS_ID" = '359' --'829' --'444'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 AND
   NULLIF(T0."ZEIT", 0) > 0 AND
   T0."CANCEL" != 1
GROUP BY
    --T0."CANCEL",
    --T4."MENGE_JE", 
    T0."PERS_ID",
    T0."DisplayName",
    T0."ANFZEIT",
    T0."ENDZEIT",
    T0."ZEIT",
    T0."MENGE_GUT",
    T0."BELNR_ID",
    T1."AUFTRAG",
    T2."ItemCode",
    T2."ItemName",
    TO_NVARCHAR(T3."BEZ"),
    T3."APLATZ_ID",
    TO_NVARCHAR(T4."BEZ"),
    T6."Name",
    T7."Name",
    A0."MENGE_JE",
    T0."MENGE_GUT";


    /* ULTIMA MODIFICACIÓN */
SELECT
    --T3."APLATZ_ID",
    --A0."APLATZ_ID",
    --T0."CANCEL",
    --T4."MENGE_JE",
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",
    A0."MENGE_JE",
    --NULLIF(A0."MENGE_JE",0),
    ( NULLIF(A0."MENGE_JE",0) / 60) AS "Velocidad_teorica",
    (NULLIF(T0."MENGE_GUT",0) / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((NULLIF(T0."MENGE_GUT",0) / NULLIF(T0."ZEIT", 0)) / (NULLIF(A0."MENGE_JE", 0) / 60) * 100) AS "Rendimiento"

FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode" --Artículo
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"
LEFT JOIN BEAS_APL A0 ON  T5."ItemCode" = A0."ItemCode" OR  T3."APLATZ_ID" =  A0."APLATZ_ID" --AND T0."POS_ID" = A0."POS_ID" --Posiciones de enrutamiento
WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   --AND T0."BELNR_ID" = '29600'
   --AND T0."PERS_ID" = '359' --'829' --'444'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND A0."APLATZ_ID" LIKE 'G%'
   AND A0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 AND
   NULLIF(T0."ZEIT", 0) > 0 AND
   T0."CANCEL" != 1
GROUP BY
    --T3."APLATZ_ID",
    --A0."APLATZ_ID", 
    --T0."CANCEL",
    --T4."MENGE_JE", 
    T0."PERS_ID",
    T0."DisplayName",
    T0."ANFZEIT",
    T0."ENDZEIT",
    T0."ZEIT",
    T0."MENGE_GUT",
    T0."BELNR_ID",
    T1."AUFTRAG",
    T2."ItemCode",
    T2."ItemName",
    TO_NVARCHAR(T3."BEZ"),
    T3."APLATZ_ID",
    TO_NVARCHAR(T4."BEZ"),
    T6."Name",
    T7."Name",
    A0."MENGE_JE",
    T0."MENGE_GUT"; 


--SELECT * FROM BEAS_APL WHERE "ItemCode" = '04DPK07122026'

/* OTRA MODIFICACION */
SELECT
    T3."APLATZ_ID",
    A0."APLATZ_ID",
    --T0."CANCEL",
    --T4."MENGE_JE",
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",
    A0."MENGE_JE",
    --NULLIF(A0."MENGE_JE",0),
    ( NULLIF(A0."MENGE_JE",0) / 60) AS "Velocidad_teorica",
    (NULLIF(T0."MENGE_GUT",0) / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((NULLIF(T0."MENGE_GUT",0) / NULLIF(T0."ZEIT", 0)) / (NULLIF(A0."MENGE_JE", 0) / 60) * 100) AS "Rendimiento"

FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode" --Artículo
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"
LEFT JOIN BEAS_APL A0 ON  T5."ItemCode" = A0."ItemCode" AND RIGHT(UPPER(T3."APLATZ_ID"), 4) = RIGHT(UPPER(A0."APLATZ_ID"), 4) --T3."APLATZ_ID" =  A0."APLATZ_ID" --AND T0."POS_ID" = A0."POS_ID" --Posiciones de enrutamiento
WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   --AND T0."BELNR_ID" = '29600'
   --AND T0."PERS_ID" = '359' --'829' --'444'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND A0."APLATZ_ID" LIKE 'G%'
   AND A0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 AND
   NULLIF(T0."ZEIT", 0) > 0 AND
   T0."CANCEL" != 1
GROUP BY
    T3."APLATZ_ID",
    A0."APLATZ_ID", 
    --T0."CANCEL",
    --T4."MENGE_JE", 
    T0."PERS_ID",
    T0."DisplayName",
    T0."ANFZEIT",
    T0."ENDZEIT",
    T0."ZEIT",
    T0."MENGE_GUT",
    T0."BELNR_ID",
    T1."AUFTRAG",
    T2."ItemCode",
    T2."ItemName",
    TO_NVARCHAR(T3."BEZ"),
    T3."APLATZ_ID",
    TO_NVARCHAR(T4."BEZ"),
    T6."Name",
    T7."Name",
    A0."MENGE_JE",
    T0."MENGE_GUT"; 


--SELECT * FROM BEAS_APL WHERE "ItemCode" = '04DPK07122026'


-- ************************************************************************************
   -- ANALIZANDO

   /*SELECT
     T3."APLATZ_ID",
     A0."APLATZ_ID",
      T4."APLATZ_ID", 
    --T0."CANCEL",
    --T4."MENGE_JE",
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",
    A0."MENGE_JE",
    ((A0."MENGE_JE") / 60) AS "Velocidad_teorica",
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / ((A0."MENGE_JE") / 60) * 100) AS "Rendimiento"

FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode" --Artículo
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"
LEFT JOIN BEAS_APL A0 ON  T5."ItemCode" = A0."ItemCode" AND  T4."APLATZ_ID" =  A0."APLATZ_ID" --Posiciones de enrutamiento
WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   --AND T0."BELNR_ID" = '29409'
   --AND T0."PERS_ID" = '359' --'829' --'444'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 AND
   NULLIF(T0."ZEIT", 0) > 0 AND
   T0."CANCEL" != 1
   --AND A0."APLATZ_ID" = 'G082'
   --AND A0."MENGE_JE"
GROUP BY
      T3."APLATZ_ID",
     A0."APLATZ_ID",
      T4."APLATZ_ID", 
    --T0."CANCEL",
    --T4."MENGE_JE", 
    T0."PERS_ID",
    T0."DisplayName",
    T0."ANFZEIT",
    T0."ENDZEIT",
    T0."ZEIT",
    T0."MENGE_GUT",
    T0."BELNR_ID",
    T1."AUFTRAG",
    T2."ItemCode",
    T2."ItemName",
    TO_NVARCHAR(T3."BEZ"),
    T3."APLATZ_ID",
    TO_NVARCHAR(T4."BEZ"),
    T6."Name",
    T7."Name",
    A0."MENGE_JE",
    T0."MENGE_GUT";*/

/*SELECT
    T0."POS_ID",
    A0."POS_ID",
    T3."APLATZ_ID",
    A0."APLATZ_ID",
    --T0."CANCEL",
    --T4."MENGE_JE",
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",
    A0."MENGE_JE",
    ( NULLIF(A0."MENGE_JE",0) / 60) AS "Velocidad_teorica",
    (NULLIF(T0."MENGE_GUT",0) / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((NULLIF(T0."MENGE_GUT",0) / NULLIF(T0."ZEIT", 0)) / (NULLIF(A0."MENGE_JE", 0) / 60) * 100) AS "Rendimiento"

FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode" --Artículo
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"
LEFT JOIN BEAS_APL A0 ON T5."ItemCode" = A0."ItemCode" AND RIGHT(UPPER(T4."APLATZ_ID"), 4) = RIGHT(UPPER(A0."APLATZ_ID"), 4) 
--T3."APLATZ_ID" =  A0."APLATZ_ID" AND T0."POS_ID" = A0."POS_ID" --Posiciones de enrutamiento
WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   --AND T0."BELNR_ID" = '29757'
   --AND T0."PERS_ID" = '925' -- '444' --'820' --'829' --'444'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND A0."APLATZ_ID" LIKE 'G%'
   AND A0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 AND
   NULLIF(T0."ZEIT", 0) > 0 AND
   T0."CANCEL" != 1
GROUP BY
    T0."POS_ID",
    A0."POS_ID",
    T3."APLATZ_ID",
    A0."APLATZ_ID", 
    --T0."CANCEL",
    --T4."MENGE_JE", 
    T0."PERS_ID",
    T0."DisplayName",
    T0."ANFZEIT",
    T0."ENDZEIT",
    T0."ZEIT",
    T0."MENGE_GUT",
    T0."BELNR_ID",
    T1."AUFTRAG",
    T2."ItemCode",
    T2."ItemName",
    TO_NVARCHAR(T3."BEZ"),
    T3."APLATZ_ID",
    TO_NVARCHAR(T4."BEZ"),
    T6."Name",
    T7."Name",
    A0."MENGE_JE",
    T0."MENGE_GUT"; */


--SELECT * FROM BEAS_APL WHERE "ItemCode" = '04DPK07122026'
-- *************************************************************************************






/* nuevo query */

SELECT
    --T3."APLATZ_ID",
    --A0."APLATZ_ID",
    --T4."APLATZ_ID", 
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    A0."ItemCode" AS "Articulo",
    A0."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    A0."Familia",
    A0."SubFamilia",
    COALESCE(A0."MENGE_JE", 0) AS "MENGE_JE",  -- Usar COALESCE para manejar valores nulos
    ((COALESCE(A0."MENGE_JE", 0)) / 60) AS "Velocidad_teorica",
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(A0."MENGE_JE", 1)) / 60, 0) * 100) AS "Rendimiento"

FROM BEAS_ARBZEIT T0  
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID"
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J'
--INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode"
LEFT JOIN (
    SELECT 
        P0."APLATZ_ID", 
        P0."ItemCode",
        P0."ItemName", 
        P0."MENGE_JE",
        P0."F" as "Familia", 
        P0."SF" as "SubFamilia"
    FROM (
        SELECT 
            T0."ItemCode", 
            T1."ItemName",
            T0."APLATZ_ID",
            T0."MENGE_JE",
            T2."Name" AS "F", 
            T3."Name" AS "SF"  
            
            FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
            INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
            INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
            INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
            INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
            WHERE 
                T1."validFor" = 'Y'
        ) P0
) A0 ON A0."ItemCode" = T2."ItemCode" AND A0."APLATZ_ID" = T4."APLATZ_ID"

WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
GROUP BY
    --T3."APLATZ_ID",
    --A0."ItemCode",
    --T4."APLATZ_ID",
     T0."PERS_ID",
     T0."DisplayName",
     T0."ANFZEIT",
     T0."ENDZEIT",
     T0."ZEIT",
     T0."MENGE_GUT",
     T0."BELNR_ID",
     T1."AUFTRAG",
     A0."ItemCode",
     A0."ItemName",
     T3."APLATZ_ID",
     TO_NVARCHAR(T3."BEZ"),
     TO_NVARCHAR(T4."BEZ"),
     A0."Familia",
    A0."SubFamilia",
    A0."MENGE_JE"


    /* OPCION 2 */

    SELECT
    --T3."APLATZ_ID",
    --A0."APLATZ_ID",
    --T4."APLATZ_ID", 
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    A0."ItemCode" AS "Articulo",
    A0."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(A0."BEZ") AS "Recurso_Descripcion",
    --TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    A0."Familia",
    A0."SubFamilia",
    COALESCE(A0."MENGE_JE", 0) AS "MENGE_JE",  -- Usar COALESCE para manejar valores nulos
    ((COALESCE(A0."MENGE_JE", 0)) / 60) AS "Velocidad_teorica",
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(A0."MENGE_JE", 1)) / 60, 0) * 100) AS "Rendimiento"

FROM BEAS_ARBZEIT T0  
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID"
LEFT JOIN (
    SELECT DISTINCT
        P0."APLATZ_ID", 
        P0."ItemCode",
        P0."ItemName", 
        P0."MENGE_JE",
        P0."F" as "Familia", 
        P0."SF" as "SubFamilia",
        P0."BEZ"
    FROM (
        SELECT 
            T0."ItemCode", 
            T1."ItemName",
            T0."APLATZ_ID",
            T0."MENGE_JE",
            T2."Name" AS "F", 
            T3."Name" AS "SF",
            A0."BEZ"  
            
            FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
            INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
            INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
            INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
            INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
            WHERE 
                T1."validFor" = 'Y'
        ) P0
) A0 ON A0."ItemCode" = T2."ItemCode" AND A0."APLATZ_ID" = RIGHT(UPPER(T3."APLATZ_ID"), 4)  --AND A0."APLATZ_ID" = T4."APLATZ_ID"

WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
    --AND T0."BELNR_ID" = '29757'
    --AND T0."PERS_ID" = '444' --'829' ,'444', 820 
    AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
GROUP BY
    --T3."APLATZ_ID",
    --A0."ItemCode",
    --T4."APLATZ_ID",
     T0."PERS_ID",
     T0."DisplayName",
     T0."ANFZEIT",
     T0."ENDZEIT",
     T0."ZEIT",
     T0."MENGE_GUT",
     T0."BELNR_ID",
     T1."AUFTRAG",
     A0."ItemCode",
     A0."ItemName",
     T3."APLATZ_ID",
     TO_NVARCHAR(T3."BEZ"),
     TO_NVARCHAR(A0."BEZ"),
     A0."Familia",
    A0."SubFamilia",
    A0."MENGE_JE"

    /* OPCION 3 - */

    SELECT
    --T3."APLATZ_ID",
    --A0."APLATZ_ID",
    --T4."APLATZ_ID",
    T3."APLATZ_ID", 
     A0."APLATZ_ID",
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    A0."ItemCode" AS "Articulo",
    A0."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(A0."BEZ") AS "Recurso_Descripcion",
    --TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    A0."Familia",
    A0."SubFamilia",
    COALESCE(A0."MENGE_JE", 0) AS "MENGE_JE",  -- Usar COALESCE para manejar valores nulos
    ((COALESCE(A0."MENGE_JE", 0)) / 60) AS "Velocidad_teorica",
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(A0."MENGE_JE", 1)) / 60, 0) * 100) AS "Rendimiento"

FROM BEAS_ARBZEIT T0  
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID"
LEFT JOIN (
    SELECT DISTINCT
        P0."APLATZ_ID", 
        P0."ItemCode",
        P0."ItemName", 
        P0."MENGE_JE",
        P0."F" as "Familia", 
        P0."SF" as "SubFamilia",
        P0."BEZ"
    FROM (
        SELECT 
            T0."ItemCode", 
            T1."ItemName",
            T0."APLATZ_ID",
            T0."MENGE_JE",
            T2."Name" AS "F", 
            T3."Name" AS "SF",
            A0."BEZ"  
            
            FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
            INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
            INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
            INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
            INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
            WHERE 
                T1."validFor" = 'Y'
        ) P0
) A0 ON A0."ItemCode" = T2."ItemCode" AND A0."APLATZ_ID" = RIGHT(UPPER(T3."APLATZ_ID"), 4)  --AND A0."APLATZ_ID" = T4."APLATZ_ID"

WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
    --AND T0."BELNR_ID" = '29757'
    --AND T0."PERS_ID" = '444' --'829' ,'444', 820 
    AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
    AND A0."APLATZ_ID" LIKE 'G%' AND A0."APLATZ_ID" NOT LIKE 'GM%'
GROUP BY
     T3."APLATZ_ID", 
     A0."APLATZ_ID",
    --T3."APLATZ_ID",
    --A0."ItemCode",
    --T4."APLATZ_ID",
     T0."PERS_ID",
     T0."DisplayName",
     T0."ANFZEIT",
     T0."ENDZEIT",
     T0."ZEIT",
     T0."MENGE_GUT",
     T0."BELNR_ID",
     T1."AUFTRAG",
     A0."ItemCode",
     A0."ItemName",
     T3."APLATZ_ID",
     TO_NVARCHAR(T3."BEZ"),
     TO_NVARCHAR(A0."BEZ"),
     A0."Familia",
    A0."SubFamilia",
    A0."MENGE_JE"

/* OPCION 4 */
SELECT
    --T3."APLATZ_ID",
    --A0."APLATZ_ID",
    --T4."APLATZ_ID",
    T3."APLATZ_ID", 
     A0."APLATZ_ID",
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    A0."ItemCode" AS "Articulo",
    A0."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(A0."BEZ") AS "Recurso_Descripcion",
    --TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    A0."Familia",
    A0."SubFamilia",
    COALESCE(A0."MENGE_JE", 0) AS "MENGE_JE",  -- Usar COALESCE para manejar valores nulos
    ((COALESCE(A0."MENGE_JE", 0)) / 60) AS "Velocidad_teorica",
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(A0."MENGE_JE", 1)) / 60, 0) * 100) AS "Rendimiento"

FROM BEAS_ARBZEIT T0  
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID"
LEFT JOIN (
    SELECT DISTINCT
        P0."APLATZ_ID", 
        P0."ItemCode",
        P0."ItemName", 
        P0."MENGE_JE",
        P0."F" as "Familia", 
        P0."SF" as "SubFamilia",
        P0."BEZ",
        P0."POS_ID"
    FROM (
        SELECT 
            T0."ItemCode", 
            T1."ItemName",
            T0."APLATZ_ID",
            T0."MENGE_JE",
            T2."Name" AS "F", 
            T3."Name" AS "SF",
            A0."BEZ",
            T0."POS_ID"  
            
            FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
            INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
            INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
            INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
            INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
            WHERE 
                T1."validFor" = 'Y'
        ) P0
) A0 ON A0."ItemCode" = T2."ItemCode" AND A0."APLATZ_ID" = RIGHT(UPPER(T3."APLATZ_ID"), 4) --AND T3."POS_ID" = A0."POS_ID" --AND A0."APLATZ_ID" = T4."APLATZ_ID"

WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
    AND T0."BELNR_ID" = '29757'
    AND T0."PERS_ID" = '444' --'829' ,'444', 820 
    AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
    AND A0."APLATZ_ID" LIKE 'G%' AND A0."APLATZ_ID" NOT LIKE 'GM%'
GROUP BY
     T3."APLATZ_ID", 
     A0."APLATZ_ID",
    --T3."APLATZ_ID",
    --A0."ItemCode",
    --T4."APLATZ_ID",
     T0."PERS_ID",
     T0."DisplayName",
     T0."ANFZEIT",
     T0."ENDZEIT",
     T0."ZEIT",
     T0."MENGE_GUT",
     T0."BELNR_ID",
     T1."AUFTRAG",
     A0."ItemCode",
     A0."ItemName",
     T3."APLATZ_ID",
     TO_NVARCHAR(T3."BEZ"),
     TO_NVARCHAR(A0."BEZ"),
     A0."Familia",
    A0."SubFamilia",
    A0."MENGE_JE"


    /* opcion 5 */

    SELECT
    --T3."APLATZ_ID",
    --A0."APLATZ_ID",
    --T4."APLATZ_ID",
    --T0."POS_ID",
    --T3."POS_ID",
    --A0."POS_ID",

    --T3."APLATZ_ID", 
     --A0."APLATZ_ID",
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    A0."ItemCode" AS "Articulo",
    A0."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(A0."BEZ") AS "Recurso_Descripcion",
    --TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    A0."Familia",
    A0."SubFamilia",
    COALESCE(A0."MENGE_JE", 0) AS "MENGE_JE",  -- Usar COALESCE para manejar valores nulos
    ((COALESCE(A0."MENGE_JE", 0)) / 60) AS "Velocidad_teorica",
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(A0."MENGE_JE", 1)) / 60, 0) * 100) AS "Rendimiento"

FROM BEAS_ARBZEIT T0  
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID"
LEFT JOIN (
    SELECT DISTINCT
        P0."APLATZ_ID", 
        P0."ItemCode",
        P0."ItemName", 
        P0."MENGE_JE",
        P0."F" as "Familia", 
        P0."SF" as "SubFamilia",
        P0."BEZ",
        P0."POS_ID"
    FROM (
        SELECT 
            T0."ItemCode", 
            T1."ItemName",
            T0."APLATZ_ID",
            T0."MENGE_JE",
            T2."Name" AS "F", 
            T3."Name" AS "SF",
            A0."BEZ",
            T0."POS_ID"  
            
            FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
            INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
            INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
            INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
            INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
            WHERE 
                T1."validFor" = 'Y'
        ) P0
) A0 ON A0."ItemCode" = T2."ItemCode" --AND A0."APLATZ_ID" = RIGHT(UPPER(T3."APLATZ_ID"), 4) --AND T3."POS_ID" = A0."POS_ID" --AND A0."APLATZ_ID" = T4."APLATZ_ID"

WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
    --AND T0."BELNR_ID" = '29757'
    --AND T0."PERS_ID" = '820' --'829' ,'444', 820 
    AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
    AND A0."APLATZ_ID" LIKE 'G%' AND A0."APLATZ_ID" NOT LIKE 'GM%'
GROUP BY
      --T0."POS_ID",
    --T3."POS_ID",
     --A0."POS_ID",

     --T3."APLATZ_ID", 
     --A0."APLATZ_ID",
    --T3."APLATZ_ID",
    --A0."ItemCode",
    --T4."APLATZ_ID",
     T0."PERS_ID",
     T0."DisplayName",
     T0."ANFZEIT",
     T0."ENDZEIT",
     T0."ZEIT",
     T0."MENGE_GUT",
     T0."BELNR_ID",
     T1."AUFTRAG",
     A0."ItemCode",
     A0."ItemName",
     T3."APLATZ_ID",
     TO_NVARCHAR(T3."BEZ"),
     TO_NVARCHAR(A0."BEZ"),
     A0."Familia",
    A0."SubFamilia",
    A0."MENGE_JE"


    /* POR EL MOMENTO  */

SELECT
    --T3."APLATZ_ID",
    --A0."APLATZ_ID",
    --T4."APLATZ_ID",
    --T0."POS_ID",
    --T3."POS_ID",
    --A0."POS_ID",

    --T3."APLATZ_ID", 
     --A0."APLATZ_ID",
   

    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    A0."ItemCode" AS "Articulo",
    A0."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(A0."BEZ") AS "Recurso_Descripcion",
    --TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    A0."Familia",
    A0."SubFamilia",
    COALESCE(A0."MENGE_JE", 0) AS "MENGE_JE",  -- Usar COALESCE para manejar valores nulos
    ((COALESCE(A0."MENGE_JE", 0)) / 60) AS "Velocidad_teorica",
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(A0."MENGE_JE", 1)) / 60, 0) * 100) AS "Rendimiento"

FROM BEAS_ARBZEIT T0  
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID"

LEFT JOIN (
    SELECT
        P0."APLATZ_ID", 
        P0."ItemCode",
        P0."ItemName", 
        P0."MENGE_JE",
        P0."F" as "Familia", 
        P0."SF" as "SubFamilia",
        P0."BEZ",
        P0."POS_ID"
    FROM (
        SELECT 
            T0."ItemCode", 
            T1."ItemName",
            T0."APLATZ_ID",
            T0."MENGE_JE",
            T2."Name" AS "F", 
            T3."Name" AS "SF",
            A0."BEZ",
            T0."POS_ID"  
            
            FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
            INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
            INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
            INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
            INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
            WHERE 
                T1."validFor" = 'Y'
        ) P0
) A0 ON A0."APLATZ_ID" = RIGHT(UPPER(T3."APLATZ_ID"), 4) AND A0."ItemCode" = T2."ItemCode" 

--A0."ItemCode" = T2."ItemCode" -- A0."APLATZ_ID" = RIGHT(UPPER(T3."APLATZ_ID"), 4) AND  --AND T3."POS_ID" = A0."POS_ID" --AND A0."APLATZ_ID" = T4."APLATZ_ID"

WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
    AND T0."BELNR_ID" = '29757'
    AND T0."PERS_ID" = '820' --'829' ,'444', 820 
    --AND T3."APLATZ_ID" = 'G019'
    AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
    AND A0."APLATZ_ID" LIKE 'G%' AND A0."APLATZ_ID" NOT LIKE 'GM%'
GROUP BY
      --T0."POS_ID",
    --T3."POS_ID",
     --A0."POS_ID",

     --T3."APLATZ_ID", 
     --A0."APLATZ_ID",
    --T3."APLATZ_ID",
    --A0."ItemCode",
    --T4."APLATZ_ID",
       

     T0."PERS_ID",
     T0."DisplayName",
     T0."ANFZEIT",
     T0."ENDZEIT",
     T0."ZEIT",
     T0."MENGE_GUT",
     T0."BELNR_ID",
     T1."AUFTRAG",
     A0."ItemCode",
     A0."ItemName",
     T3."APLATZ_ID",
     TO_NVARCHAR(T3."BEZ"),
     TO_NVARCHAR(A0."BEZ"),
     A0."Familia",
    A0."SubFamilia",
    A0."MENGE_JE"



    -- ****************TRABAJANDO PERO SIN VELOCIDAD TEORICA *************************
SELECT
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",
    
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real"
    

FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode" --Artículo
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"


WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   --AND T0."BELNR_ID" = '29409'
   --AND T0."PERS_ID" = '359' --'829' --'444'
   AND T3."APLATZ_ID" = 'G019'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
GROUP BY 
    T0."PERS_ID",
    T0."DisplayName",
    T0."ANFZEIT",
    T0."ENDZEIT",
    T0."ZEIT",
    T0."MENGE_GUT",
    T0."BELNR_ID",
    T1."AUFTRAG",
    T2."ItemCode",
    T2."ItemName",
    TO_NVARCHAR(T3."BEZ"),
    T3."APLATZ_ID",
    TO_NVARCHAR(T4."BEZ"),
    T6."Name",
    T7."Name";


    /* por el momento lo tengo asi estoy sacando el velocidad teorica  */
    SELECT
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",
    P."MENGE_JE" AS "Articulo_terminado",
     ((P."MENGE_JE") / 60) AS "Velocidad_teorica",
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real"
    

FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode" --Artículo
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"


LEFT JOIN (
    SELECT 
        --P0."ItemCode", 
        P0."APLATZ_ID", 
        SUM(P0."MENGE_JE") AS "MENGE_JE",
        P0."SF" as "SubFamilia"
    FROM (
        SELECT 
            --T0."ItemCode", 
            T0."APLATZ_ID", 
            T0."MENGE_JE",
            T3."Name" AS "SF"
        FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
        INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
        WHERE T1."validFor" = 'Y'    
        ) P0
    WHERE P0."APLATZ_ID" LIKE 'G%' AND P0."APLATZ_ID" NOT LIKE 'GM%'
    GROUP BY P0."APLATZ_ID", P0."SF"
) P ON P."APLATZ_ID" = T3."APLATZ_ID" AND P."SubFamilia" = T7."Name"


WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   AND T0."BELNR_ID" = '29757' -- '29409'
   AND T0."PERS_ID" = '444' --'829' --'444'
   --AND T3."APLATZ_ID" = 'G019'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
GROUP BY 
     P."MENGE_JE",
    T0."PERS_ID",
    T0."DisplayName",
    T0."ANFZEIT",
    T0."ENDZEIT",
    T0."ZEIT",
    T0."MENGE_GUT",
    T0."BELNR_ID",
    T1."AUFTRAG",
    T2."ItemCode",
    T2."ItemName",
    TO_NVARCHAR(T3."BEZ"),
    T3."APLATZ_ID",
    TO_NVARCHAR(T4."BEZ"),
    T6."Name",
    T7."Name";
    
    /* buscando recuso y sub familia */
SELECT DISTINCT
  (P0."APLATZ_ID") as "Recurso", 
  CAST(P0."BEZ" AS VARCHAR) "Descripcion",
  P0."ItemCode", P0."ItemName", 
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
(
  SELECT 
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
WHERE P0."APLATZ_ID" LIKE 'G%' AND P0."APLATZ_ID" NOT LIKE 'GM%'-- AND P0."APLATZ_ID" IN ('G061', 'G080', 'G083')
order by P0."APLATZ_ID", P0."F"


/* REVISAR CON SANTIAGO */
SELECT
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",

    P."MENGE_JE" AS "Articulo_terminado",

    ((P."MENGE_JE") / 60) AS "Velocidad_teorica",
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(P."MENGE_JE", 1)) / 60, 0) * 100) AS "Rendimiento"
    

FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode" --Artículo
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"


LEFT JOIN (
    SELECT 
        P0."ItemCode", 
        P0."APLATZ_ID", 
        SUM(P0."MENGE_JE") AS "MENGE_JE",
        P0."SF" as "SubFamilia"
    FROM (
        SELECT 
            T0."ItemCode", 
            T0."APLATZ_ID", 
            T0."MENGE_JE",
            T3."Name" AS "SF"
        FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
        INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
        WHERE T1."validFor" = 'Y'    
        ) P0
    WHERE P0."APLATZ_ID" LIKE 'G%' AND P0."APLATZ_ID" NOT LIKE 'GM%'
    GROUP BY P0."APLATZ_ID", P0."SF", P0."ItemCode" 
) P ON P."ItemCode" = T2."ItemCode" AND  P."APLATZ_ID" = T3."APLATZ_ID" AND P."SubFamilia" = T7."Name"


WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   --AND T0."BELNR_ID" = '29757' -- '29409'
   --AND T0."PERS_ID" = '829' --'829' --'444'
   --AND T3."APLATZ_ID" = 'G019'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
GROUP BY 
     P."MENGE_JE",
    T0."PERS_ID",
    T0."DisplayName",
    T0."ANFZEIT",
    T0."ENDZEIT",
    T0."ZEIT",
    T0."MENGE_GUT",
    T0."BELNR_ID",
    T1."AUFTRAG",
    T2."ItemCode",
    T2."ItemName",
    TO_NVARCHAR(T3."BEZ"),
    T3."APLATZ_ID",
    TO_NVARCHAR(T4."BEZ"),
    T6."Name",
    T7."Name";

/* 02-12-2024 TIEMPO DE PRODUCCION  */

SELECT
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",

    P."MENGE_JE" AS "Articulo_terminado",

    ((P."MENGE_JE") / 60) AS "Velocidad_teorica",
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(P."MENGE_JE", 1)) / 60, 0) * 100) AS "Rendimiento"
    

FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode" --Artículo
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"


LEFT JOIN (
    SELECT 
        P0."ItemCode", 
        P0."APLATZ_ID", 
        SUM(P0."MENGE_JE") AS "MENGE_JE",
        P0."F" as "Familia", 
        P0."SF" as "SubFamilia",
        TO_NVARCHAR(P0."Desc") AS "Descripcion"
    FROM (
        SELECT 
            T0."ItemCode", 
            T0."APLATZ_ID", 
            T0."MENGE_JE",
            T2."Name" AS "F", 
            T3."Name" AS "SF",
            TO_NVARCHAR(T0."BEZ") AS "Desc"
        FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
        INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
        WHERE T1."validFor" = 'Y'    
        ) P0
    WHERE P0."APLATZ_ID" LIKE 'G%' AND P0."APLATZ_ID" NOT LIKE 'GM%'
    GROUP BY P0."APLATZ_ID", P0."F", P0."SF", P0."ItemCode", TO_NVARCHAR(P0."Desc")
) P ON 
    --P."ItemCode" = T2."ItemCode" AND  
    P."APLATZ_ID" = T3."APLATZ_ID" AND 
    TO_NVARCHAR(P."Descripcion") = TO_NVARCHAR(T3."BEZ") AND
    P."Familia" = T6."Name" AND 
    P."SubFamilia" = T7."Name"


WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   --AND T0."BELNR_ID" =  '29757' --'30099' --'29757' -- '29409'
   --AND T0."PERS_ID" = '444' --'820' --'829' --'444'
   --AND T3."APLATZ_ID" = 'G019'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
GROUP BY 
    P."MENGE_JE",
    TO_NVARCHAR(P."Descripcion"),
    T0."PERS_ID",
    T0."DisplayName",
    T0."ANFZEIT",
    T0."ENDZEIT",
    T0."ZEIT",
    T0."MENGE_GUT",
    T0."BELNR_ID",
    T1."AUFTRAG",
    T2."ItemCode",
    T2."ItemName",
    TO_NVARCHAR(T3."BEZ"),
    T3."APLATZ_ID",
    TO_NVARCHAR(T4."BEZ"),
    T6."Name",
    T7."Name";


/* SANTIAGO TIEMPOS DE PRODUCCION */

SELECT
    T3."MENGE_JE",
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",

    T3."MENGE_JE" AS "Articulo_terminado",

    ((T3."MENGE_JE") / 60) AS "Velocidad_teorica",
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(T3."MENGE_JE", 1)) / 60, 0) * 100) AS "Rendimiento"
    

FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode" --Artículo
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"

WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   AND T0."BELNR_ID" =  '29748' --'30099' --'29757' -- '29409'
   AND T0."PERS_ID" = '834' --'820' --'829' --'444'
   --AND T3."APLATZ_ID" = 'G019'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
GROUP BY 
    T3."MENGE_JE",
    T0."PERS_ID",
    T0."DisplayName",
    T0."ANFZEIT",
    T0."ENDZEIT",
    T0."ZEIT",
    T0."MENGE_GUT",
    T0."BELNR_ID",
    T1."AUFTRAG",
    T2."ItemCode",
    T2."ItemName",
    TO_NVARCHAR(T3."BEZ"),
    T3."APLATZ_ID",
    TO_NVARCHAR(T4."BEZ"),
    T6."Name",
    T7."Name"
ORDER BY 
  T0."ANFZEIT"


  /* Dalton tiempo de produccion */
SELECT
    T3."MENGE_JE",
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",

    P."MENGE_JE" AS "Articulo_terminado",

    ((P."MENGE_JE") / 60) AS "Velocidad_teorica",
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(P."MENGE_JE", 1)) / 60, 0) * 100) AS "Rendimiento"
    

FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode" --Artículo
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"


LEFT JOIN (
    SELECT 
        P0."ItemCode", 
        P0."APLATZ_ID", 
        SUM(P0."MENGE_JE") AS "MENGE_JE",
        P0."F" as "Familia", 
        P0."SF" as "SubFamilia",
        TO_NVARCHAR(P0."Desc") AS "Descripcion"
    FROM (
        SELECT 
            T0."ItemCode", 
            T0."APLATZ_ID", 
            T0."MENGE_JE",
            T2."Name" AS "F", 
            T3."Name" AS "SF",
            TO_NVARCHAR(T0."BEZ") AS "Desc"
        FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
        INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
        WHERE T1."validFor" = 'Y'    
        ) P0
    WHERE P0."APLATZ_ID" LIKE 'G%' AND P0."APLATZ_ID" NOT LIKE 'GM%'
    GROUP BY P0."APLATZ_ID", P0."F", P0."SF", P0."ItemCode", TO_NVARCHAR(P0."Desc")
) P ON 
    --P."ItemCode" = T2."ItemCode" AND  
    (P."APLATZ_ID" = T3."APLATZ_ID" AND 
    TO_NVARCHAR(P."Descripcion") = TO_NVARCHAR(T3."BEZ") AND
    P."Familia" = T6."Name" AND 
    P."SubFamilia" = T7."Name" ) OR (P."APLATZ_ID" = T3."APLATZ_ID") 


WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   AND T0."BELNR_ID" =  '29748' --'30099' --'29757' -- '29409'
   AND T0."PERS_ID" = '834' --'820' --'829' --'444'
   --AND T3."APLATZ_ID" = 'G019'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
   --AND P."MENGE_JE" > 0
GROUP BY 
    T3."MENGE_JE",
    P."MENGE_JE",
    TO_NVARCHAR(P."Descripcion"),
    T0."PERS_ID",
    T0."DisplayName",
    T0."ANFZEIT",
    T0."ENDZEIT",
    T0."ZEIT",
    T0."MENGE_GUT",
    T0."BELNR_ID",
    T1."AUFTRAG",
    T2."ItemCode",
    T2."ItemName",
    TO_NVARCHAR(T3."BEZ"),
    T3."APLATZ_ID",
    TO_NVARCHAR(T4."BEZ"),
    T6."Name",
    T7."Name"
ORDER BY 
  T0."ANFZEIT"


/* ************************** */
SELECT
    --T3."MENGE_JE",
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",

    COALESCE(P."MENGE_JE", T3."MENGE_JE") AS "Articulo_terminado",  
    (COALESCE(P."MENGE_JE", T3."MENGE_JE") / 60) AS "Velocidad_teorica", 
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",

    CASE 
        WHEN COALESCE(P."MENGE_JE", T3."MENGE_JE") > 0 THEN 
            ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(P."MENGE_JE", T3."MENGE_JE") / 60), 0) * 100)
        ELSE 
            NULL 
    END AS "Rendimiento"

    /*COALESCE(P."MENGE_JE", 0) AS "Articulos_terminado", 
    P."MENGE_JE" AS "Articulo_terminado",

    ((P."MENGE_JE") / 60) AS "Velocidad_teorica",
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",
    ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(P."MENGE_JE", 1)) / 60, 0) * 100) AS "Rendimiento"*/
    

FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode" --Artículo
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"


LEFT JOIN (
    SELECT 
        P0."ItemCode", 
        P0."APLATZ_ID", 
        SUM(P0."MENGE_JE") AS "MENGE_JE",
        P0."F" as "Familia", 
        P0."SF" as "SubFamilia",
        TO_NVARCHAR(P0."Desc") AS "Descripcion"
    FROM (
        SELECT 
            T0."ItemCode", 
            T0."APLATZ_ID", 
            T0."MENGE_JE",
            T2."Name" AS "F", 
            T3."Name" AS "SF",
            TO_NVARCHAR(T0."BEZ") AS "Desc"
        FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
        INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
        WHERE T1."validFor" = 'Y'    
        ) P0
    WHERE P0."APLATZ_ID" LIKE 'G%' AND P0."APLATZ_ID" NOT LIKE 'GM%'
    GROUP BY P0."APLATZ_ID", P0."F", P0."SF", P0."ItemCode", TO_NVARCHAR(P0."Desc")
) P ON 
    --P."ItemCode" = T2."ItemCode" AND  
  
    (P."APLATZ_ID" = T3."APLATZ_ID" AND 
    TO_NVARCHAR(P."Descripcion") = TO_NVARCHAR(T3."BEZ") AND
    P."Familia" = T6."Name" AND 
    P."SubFamilia" = T7."Name" ) --OR (P."APLATZ_ID" = T3."APLATZ_ID") 


WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   --AND T0."BELNR_ID" =  '30027' --'30099' --'29757' -- '29409'
   --AND T0."PERS_ID" = '429' --'820' --'829' --'444'
   --AND T3."APLATZ_ID" = 'G019'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
   --AND P."MENGE_JE" > 0
GROUP BY 
    T3."MENGE_JE",
    P."MENGE_JE",
    TO_NVARCHAR(P."Descripcion"),
    T0."PERS_ID",
    T0."DisplayName",
    T0."ANFZEIT",
    T0."ENDZEIT",
    T0."ZEIT",
    T0."MENGE_GUT",
    T0."BELNR_ID",
    T1."AUFTRAG",
    T2."ItemCode",
    T2."ItemName",
    TO_NVARCHAR(T3."BEZ"),
    T3."APLATZ_ID",
    TO_NVARCHAR(T4."BEZ"),
    T6."Name",
    T7."Name"
ORDER BY 
  T0."ANFZEIT"


  /* otro codigo asi quedo */
SELECT
    --T3."MENGE_JE",
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",

    COALESCE(P."MENGE_JE", T3."MENGE_JE") AS "Articulo_terminado",  
    (COALESCE(P."MENGE_JE", T3."MENGE_JE") / 60) AS "Velocidad_teorica", 
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",

    CASE 
        WHEN COALESCE(P."MENGE_JE", T3."MENGE_JE") > 0 THEN 
            ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(P."MENGE_JE", T3."MENGE_JE") / 60), 0) * 100)
        ELSE 
            0 
    END AS "Rendimiento"
    

FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode" --Artículo
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"


LEFT JOIN (
    SELECT 
        P0."ItemCode", 
        P0."APLATZ_ID", 
        SUM(P0."MENGE_JE") AS "MENGE_JE",
        P0."F" as "Familia", 
        P0."SF" as "SubFamilia",
        TO_NVARCHAR(P0."Desc") AS "Descripcion"
    FROM (
        SELECT 
            T0."ItemCode", 
            T0."APLATZ_ID", 
            T0."MENGE_JE",
            T2."Name" AS "F", 
            T3."Name" AS "SF",
            TO_NVARCHAR(T0."BEZ") AS "Desc"
        FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
        INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
        WHERE T1."validFor" = 'Y'    
        ) P0
    WHERE P0."APLATZ_ID" LIKE 'G%' AND P0."APLATZ_ID" NOT LIKE 'GM%'
    GROUP BY P0."APLATZ_ID", P0."F", P0."SF", P0."ItemCode", TO_NVARCHAR(P0."Desc")
) P ON 
    --P."ItemCode" = T2."ItemCode" AND  
  
    (P."APLATZ_ID" = T3."APLATZ_ID" AND 
    TO_NVARCHAR(P."Descripcion") = TO_NVARCHAR(T3."BEZ") AND
    P."Familia" = T6."Name" AND 
    P."SubFamilia" = T7."Name" )

WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   --AND T0."BELNR_ID" =  '29757' --'30099' --'29757' -- '29409'
   --AND T0."PERS_ID" = '820' --'820' --'829' --'444'
   --AND T3."APLATZ_ID" = 'G019'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
   AND P."MENGE_JE" > 0
GROUP BY 
    T3."MENGE_JE",
    P."MENGE_JE",
    TO_NVARCHAR(P."Descripcion"),
    T0."PERS_ID",
    T0."DisplayName",
    T0."ANFZEIT",
    T0."ENDZEIT",
    T0."ZEIT",
    T0."MENGE_GUT",
    T0."BELNR_ID",
    T1."AUFTRAG",
    T2."ItemCode",
    T2."ItemName",
    TO_NVARCHAR(T3."BEZ"),
    T3."APLATZ_ID",
    TO_NVARCHAR(T4."BEZ"),
    T6."Name",
    T7."Name"
ORDER BY 
  T0."ANFZEIT"


/* ULTIMAS MODIFICACIONES */
SELECT
    --T3."MENGE_JE",
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",

    COALESCE(P."MENGE_JE", T3."MENGE_JE") AS "Articulo_terminado",  
    --(COALESCE(P."MENGE_JE", T3."MENGE_JE") / COALESCE(P."TEAPLATZ", T3."TEAPLATZ" ) ) AS "Velocidad_teorica", 
    (COALESCE(P."MENGE_JE", T3."MENGE_JE") / P."TEAPLATZ") AS "Velocidad_teorica", 
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",

    CASE 
        WHEN COALESCE(P."MENGE_JE", T3."MENGE_JE") > 0 THEN
            ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(P."MENGE_JE", T3."MENGE_JE") /  T3."TEAPLATZ" ), 0) * 100) 
            --((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(P."MENGE_JE", T3."MENGE_JE") / COALESCE(P."TEAPLATZ", T3."TEAPLATZ" ) ), 0) * 100)
        ELSE 
            0 
    END AS "Rendimiento"
    

FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode" --Artículo
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"


LEFT JOIN (
    SELECT 
        P0."ItemCode", 
        P0."APLATZ_ID", 
        SUM(P0."MENGE_JE") AS "MENGE_JE",
        P0."F" as "Familia", 
        P0."SF" as "SubFamilia",
        TO_NVARCHAR(P0."Desc") AS "Descripcion",
        P0."TEAPLATZ"
    FROM (
        SELECT 
            T0."ItemCode", 
            T0."APLATZ_ID", 
            T0."MENGE_JE",
            T2."Name" AS "F", 
            T3."Name" AS "SF",
            TO_NVARCHAR(T0."BEZ") AS "Desc",
            T0."TEAPLATZ"
        
        FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
        INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
        WHERE T1."validFor" = 'Y'    
        ) P0
    WHERE P0."APLATZ_ID" LIKE 'G%' AND P0."APLATZ_ID" NOT LIKE 'GM%'
    GROUP BY P0."APLATZ_ID", P0."F", P0."SF", P0."ItemCode", TO_NVARCHAR(P0."Desc"),  P0."TEAPLATZ"
) P ON 
    --P."ItemCode" = T2."ItemCode" AND  
  
    (P."APLATZ_ID" = T3."APLATZ_ID" AND 
    TO_NVARCHAR(P."Descripcion") = TO_NVARCHAR(T3."BEZ") AND
    P."Familia" = T6."Name" AND 
    P."SubFamilia" = T7."Name" )

WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   --AND T0."BELNR_ID" =  '29818' --'30099' --'29757' -- '29409'
   --AND T0."PERS_ID" = '820' --'820' --'829' --'444'
   --AND T3."APLATZ_ID" = 'G019'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
   AND P."MENGE_JE" > 0
GROUP BY 
    T3."MENGE_JE",
    P."MENGE_JE",
    TO_NVARCHAR(P."Descripcion"),
    T0."PERS_ID",
    T0."DisplayName",
    T0."ANFZEIT",
    T0."ENDZEIT",
    T0."ZEIT",
    T0."MENGE_GUT",
    T0."BELNR_ID",
    T1."AUFTRAG",
    T2."ItemCode",
    T2."ItemName",
    TO_NVARCHAR(T3."BEZ"),
    T3."APLATZ_ID",
    TO_NVARCHAR(T4."BEZ"),
    T6."Name",
    T7."Name",
    P."TEAPLATZ",
    T3."TEAPLATZ"
ORDER BY 
  T0."ANFZEIT"

  /* REVISA CON SANTIAGO ULTIMA MODIFICACIONES 05-12-2024*/
SELECT
    --T3."MENGE_JE",
    T0."PERS_ID" AS "Personal",
    T0."DisplayName" AS "Nombre",
    TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ANFZEIT"), 'HH24:MI:SS') AS "Iniciar",
    TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."ENDZEIT"), 'HH24:MI:SS') AS "Final",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Tiempo_Total_Produccion_Minutos",
    ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."ANFZEIT", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."ENDZEIT", 'YYYY-MM-DD HH24:MI:SS')) / 3600), 2) AS "Tiempo_Total_Produccion_Horas",
    T0."ZEIT" AS "Hora_Reportado",
    T0."MENGE_GUT" AS "OK",
    T0."BELNR_ID" AS "Orden",
    T1."AUFTRAG" AS "Orden_Trabajo",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    TO_NVARCHAR(T3."BEZ")  AS "Actividad",
    T3."APLATZ_ID" AS "Recurso",
    TO_NVARCHAR(T4."BEZ") AS "Recurso_Descripcion",
    T6."Name" AS "Familia",
    T7."Name" AS "SubFamilia",

    COALESCE(P."MENGE_JE", T3."MENGE_JE") AS "Articulo_terminado", 

   -- Velocidad teórica
    CASE 
        WHEN P."MENGE_JE" IS NOT NULL THEN
            COALESCE(P."MENGE_JE", 0) / NULLIF(P."TEAPLATZ", 0)
        ELSE 
            COALESCE(T3."MENGE_JE", 0) / NULLIF(T3."TEAPLATZ", 0)
    END AS "Velocidad_teorica",

    -- Velocidad real
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",

   -- Rendimiento
    CASE 
        WHEN COALESCE(P."MENGE_JE", T3."MENGE_JE") > 0 THEN
            (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / 
            NULLIF(
                (CASE 
                    WHEN P."MENGE_JE" IS NOT NULL THEN 
                        COALESCE(P."MENGE_JE", 0) / NULLIF(P."TEAPLATZ", 0)
                    ELSE 
                        COALESCE(T3."MENGE_JE", 0) / NULLIF(T3."TEAPLATZ", 0)
                END), 0) * 100
        ELSE 
            0 
    END AS "Rendimiento"

   /*-- Rendimiento
    CASE 
        WHEN COALESCE(P."MENGE_JE", T3."MENGE_JE") > 0 THEN
            ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / 
            NULLIF((COALESCE(P."MENGE_JE", T3."MENGE_JE") / 
            COALESCE(P."TEAPLATZ", T3."TEAPLATZ")), 0) * 100)
        ELSE 
            0 
    END AS "Rendimiento" */


   /* --(COALESCE(P."MENGE_JE", T3."MENGE_JE") / COALESCE(P."TEAPLATZ", T3."TEAPLATZ" ) ) AS "Velocidad_teorica", 
    (COALESCE(P."MENGE_JE", T3."MENGE_JE") / P."TEAPLATZ") AS "Velocidad_teorica", 
    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",

    CASE 
        WHEN COALESCE(P."MENGE_JE", T3."MENGE_JE") > 0 THEN
            ((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(P."MENGE_JE", T3."MENGE_JE") /  T3."TEAPLATZ" ), 0) * 100) 
            --((T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) / NULLIF((COALESCE(P."MENGE_JE", T3."MENGE_JE") / COALESCE(P."TEAPLATZ", T3."TEAPLATZ" ) ), 0) * 100)
        ELSE 
            0 
    END AS "Rendimiento" */
    

FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
INNER JOIN BEAS_APLATZ T4 ON RIGHT(UPPER(T3."APLATZ_ID"), 4) = T4."APLATZ_ID" AND T4."Active" = 'J' --Recursos
INNER JOIN OITM T5 ON T2."ItemCode" = T5."ItemCode" --Artículo
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T6 ON T5."U_SYP_SUBGRUPO3" = T6."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T7 ON T5."U_SYP_SUBGRUPO4" = T7."Code"


LEFT JOIN (
    SELECT 
        P0."ItemCode", 
        P0."APLATZ_ID", 
        SUM(P0."MENGE_JE") AS "MENGE_JE",
        P0."F" as "Familia", 
        P0."SF" as "SubFamilia",
        TO_NVARCHAR(P0."Desc") AS "Descripcion",
        P0."TEAPLATZ"
    FROM (
        SELECT DISTINCT
            T0."ItemCode", 
            T0."APLATZ_ID", 
            T0."MENGE_JE",
            T2."Name" AS "F", 
            T3."Name" AS "SF",
            TO_NVARCHAR(T0."BEZ") AS "Desc",
            T0."TEAPLATZ"
        
        FROM "SBO_FIGURETTI_PRO"."BEAS_APL" T0 
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_APLATZ" A0 ON T0."APLATZ_ID" = A0."APLATZ_ID" AND A0."Active" = 'J'
        INNER JOIN "SBO_FIGURETTI_PRO"."OITM" T1 ON T0."ItemCode" = T1."ItemCode"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T2 ON T1."U_SYP_SUBGRUPO3" = T2."Code"
        INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T3 ON T1."U_SYP_SUBGRUPO4" = T3."Code"
        WHERE T1."validFor" = 'Y'    
        ) P0
    WHERE P0."APLATZ_ID" LIKE 'G%' AND P0."APLATZ_ID" NOT LIKE 'GM%'
    GROUP BY P0."APLATZ_ID", P0."F", P0."SF", P0."ItemCode", TO_NVARCHAR(P0."Desc"),  P0."TEAPLATZ"
) P ON 
    --P."ItemCode" = T2."ItemCode" AND  
  
    (P."APLATZ_ID" = T3."APLATZ_ID" AND 
    TO_NVARCHAR(P."Descripcion") = TO_NVARCHAR(T3."BEZ") AND
    P."Familia" = T6."Name" AND 
    P."SubFamilia" = T7."Name" )

WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-08-31'
   AND T0."BELNR_ID" = '29757'  --'29818' --'30099' --'29757' -- '29409'
   AND T0."PERS_ID" = '820' --'820' --'829' --'444'
   --AND T3."APLATZ_ID" = 'G019'
   AND T3."APLATZ_ID" LIKE 'G%' 
   AND T3."APLATZ_ID" NOT LIKE 'GM%'
   AND T0."APLATZ_ID" LIKE 'G%' 
   AND T0."APLATZ_ID" NOT LIKE 'GM%'
   AND T3."BEZ" NOT LIKE '%DESCARNADO%' 
   AND T3."BEZ" NOT LIKE '%TRABAJO%'
   AND T2."ItemCode" NOT LIKE '00%'
   AND T0."MENGE_GUT" > 0 
   AND NULLIF(T0."ZEIT", 0) > 0 
   AND (T0."CANCEL" IS NULL OR T0."CANCEL" != 1)
   AND ( P."MENGE_JE" > 0 OR T3."MENGE_JE" > 0)
   --AND P."MENGE_JE" > 0
GROUP BY 
    T3."MENGE_JE",
    P."MENGE_JE",
    TO_NVARCHAR(P."Descripcion"),
    T0."PERS_ID",
    T0."DisplayName",
    T0."ANFZEIT",
    T0."ENDZEIT",
    T0."ZEIT",
    T0."MENGE_GUT",
    T0."BELNR_ID",
    T1."AUFTRAG",
    T2."ItemCode",
    T2."ItemName",
    TO_NVARCHAR(T3."BEZ"),
    T3."APLATZ_ID",
    TO_NVARCHAR(T4."BEZ"),
    T6."Name",
    T7."Name",
    P."TEAPLATZ",
    T3."TEAPLATZ"
ORDER BY 
  T0."ANFZEIT"


