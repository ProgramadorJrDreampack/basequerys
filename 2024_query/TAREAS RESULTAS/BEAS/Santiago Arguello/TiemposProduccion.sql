/* ORIGINAL PERO AUN NO ESTA EN PRODUCCION  */
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

    COALESCE(P."MENGE_JE", T3."MENGE_JE") AS "Articulo_terminado", 

    CASE 
        WHEN P."MENGE_JE" IS NOT NULL THEN
            COALESCE(P."MENGE_JE", 0) / NULLIF(P."TEAPLATZ", 0)
        ELSE 
            COALESCE(T3."MENGE_JE", 0) / NULLIF(T3."TEAPLATZ", 0)
    END AS "Velocidad_teorica",

    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",

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
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-09-01'
   AND T0."BELNR_ID" = '30121'--'29757'  --'29818' --'30099' --'29757' -- '29409'
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
   --AND P."MENGE_JE" > 0
    AND (P."MENGE_JE" > 0 OR T3."MENGE_JE" > 0)
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

 
/*
PERFECTO 
tiempo de produccion Agrupacion y sumatoria ok 
  * orden, articulo, articulo descripcion, suma de cantidad ok 
*/
SELECT
    T0."BELNR_ID" AS "Orden",
    T2."ItemCode" AS "Articulo",
    T2."ItemName" AS "Articulo_Descripcion",
    SUM(T0."MENGE_GUT") AS "Suma_Cantidad_OK"
    
FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-09-01' 
   --T0."ANFZEIT" > '2024-08-01' AND  T0."ANFZEIT" <= '2024-08-31'
   AND T0."BELNR_ID" = '30121'  --'29757'  '29818' --'30099' --'29757' -- '29409'
   --AND T0."PERS_ID" = '444' --'820' --'829' --'444'
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
   AND (T3."MENGE_JE" > 0)
GROUP BY 
    T0."BELNR_ID",
    T2."ItemCode",
    T2."ItemName";





/* QUERY FINAL DE TIEMPOS DE PRODUCCION - BASE */

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

    COALESCE(P."MENGE_JE", T3."MENGE_JE") AS "Articulo_terminado", 

    CASE 
        WHEN P."MENGE_JE" IS NOT NULL THEN
            COALESCE(P."MENGE_JE", 0) / NULLIF(P."TEAPLATZ", 0)
        ELSE 
            COALESCE(T3."MENGE_JE", 0) / NULLIF(T3."TEAPLATZ", 0)
    END AS "Velocidad_teorica",

    (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",

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
    T0."ANFZEIT" > '2024-01-01' 
   --T0."ANFZEIT" BETWEEN '2024-10-01' AND '2024-11-01'
   --AND T0."BELNR_ID" = '30121'--'29757'  --'29818' --'30099' --'29757' -- '29409'
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
   --AND P."MENGE_JE" > 0
    AND (P."MENGE_JE" > 0 OR T3."MENGE_JE" > 0)
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


  /* crear la vista para tiempo de produccion */
DROP VIEW "SBO_FIGURETTI_PRO"."TIEMPOS_DE_PRODUCCION";
CREATE VIEW "SBO_FIGURETTI_PRO"."TIEMPOS_DE_PRODUCCION" ( 
    "Personal",
    "Nombre",
    "Fecha",
    "Iniciar",
    "Final",
    "Tiempo_Total_Produccion_Minutos",
    "Tiempo_Total_Produccion_Horas",
    "Hora_Reportado",
    "OK",
    "Orden",
    "Orden_Trabajo",
    "Articulo",
    "Articulo_Descripcion",
    "Actividad",
    "Recurso",
    "Recurso_Descripcion",
    "Familia",
    "SubFamilia",
    "Articulo_terminado",
    "Velocidad_teorica",
    "Velocidad_Real",
    "Rendimiento"
   ) AS (
    (
        SELECT
            T0."PERS_ID" AS "Personal",
            T0."DisplayName" AS "Nombre",
            T0."ANFZEIT" AS "Fecha",
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

            CASE 
                WHEN P."MENGE_JE" IS NOT NULL THEN
                    COALESCE(P."MENGE_JE", 0) / NULLIF(P."TEAPLATZ", 0)
                ELSE 
                    COALESCE(T3."MENGE_JE", 0) / NULLIF(T3."TEAPLATZ", 0)
            END AS "Velocidad_teorica",

            (T0."MENGE_GUT" / NULLIF(T0."ZEIT", 0)) AS "Velocidad_Real",

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
            T0."ANFZEIT" > '2024-01-01' 
        --T0."ANFZEIT" BETWEEN '2024-10-01' AND '2024-11-01'
        --AND T0."BELNR_ID" = '30121'--'29757'  --'29818' --'30099' --'29757' -- '29409'
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
        --AND P."MENGE_JE" > 0
            AND (P."MENGE_JE" > 0 OR T3."MENGE_JE" > 0)
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
    )
) WITH READ ONLY

-- **********************************************************

SELECT 
    *
FROM "SBO_FIGURETTI_PRO"."TIEMPOS_DE_PRODUCCION" T0
WHERE (
	T0."Fecha" >={ts '2024-01-01 00:00:00'} AND 
	T0."Fecha" < {ts '2024-01-31 00:00:00'}
)
ORDER BY T0."Fecha"

-- ********************
SELECT 
    *
FROM "SBO_FIGURETTI_PRO"."TIEMPOS_DE_PRODUCCION" T0
WHERE (
	T0."Fecha" >= {?Fecha_Inicio} AND 
	T0."Fecha" < {?Fecha_Fin}
)
ORDER BY T0."Fecha"


IF {DPE_INTERRUPCION_RECURSOS.Fecha} >= {?Fecha_Inicio} AND
{DPE_INTERRUPCION_RECURSOS.Fecha} <= {?Fecha_Fin} THEN TRUE
--  LIMIT 5






/* 

 SELECT *  FROM "SBO_FIGURETTI_PRO"."DPE_INTERRUPCION_RECURSOS" T0
 WHERE (T0."Fecha" >= '2024-01-01' AND T0."Fecha" < '2025-03-18')
 ORDER BY T0."Recurso"

 */