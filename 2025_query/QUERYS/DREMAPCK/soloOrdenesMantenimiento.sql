SELECT
   T0."BELNR_ID" AS "N° Orden",
   T2."ANFZEIT" AS "Fecha inicio",
   TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio", 
   T2."ENDZEIT" AS "Fecha fin",
   TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Hora de finalizacion",
   T2."DisplayName" AS "Tecnico MTTO",
   T1."AG_ID" AS "Operacion",
   CASE WHEN LENGTH(T1."AG_ID") = 6 THEN RIGHT(T1."AG_ID", 4) ELSE T1."AG_ID" END AS "Recurso",
   T5."APLATZ_ID" AS "NombreRecurso",
   T5."BEZ",
   (T0."WORKTIME" / 60) AS "Duracion Del MTTO",
   T3."ART1_ID" AS "Num de articulo",
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
LEFT JOIN BEAS_APLATZ T5 ON T1."APLATZ_ID" = T5."APLATZ_ID"  --Recursos

WHERE
    T0."TYP" != 'Produccion' 
    AND T0."BELNR_ID" >= '15711'
    AND T1."ABGKZ" = 'J'
    AND T3."MENGE_LAGER" > 0
    AND T0."BELNR_ID" = '33334'
ORDER BY T2."ANFZEIT"

-- ************************************************************************************+
asi quedo el query OM sin sc
SELECT
    "N° Orden",
    "Fecha inicio",
    "Hora de inicio",
    "Fecha fin",
    "Hora de finalizacion",
    "Tecnico MTTO",
    "Operacion",
    "Recurso",
    "NombreRecurso",
    "BEZ",
    "Duracion Del MTTO",
    "Num de articulo",
    "Descripcion del articulo",
    "Cantidad consumida",
    "Precio unitario",
    "Precio Total",
    "MTTO",
    "Tipo MTTO",
    "Comentario en la orden",
    "Comentario del tecnico"
FROM (
    SELECT
        T0."BELNR_ID" AS "N° Orden",
        T2."ANFZEIT" AS "Fecha inicio",
        TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio",
        T2."ENDZEIT" AS "Fecha fin",
        TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Hora de finalizacion",
        T2."DisplayName" AS "Tecnico MTTO",
        T1."AG_ID" AS "Operacion",
        CASE WHEN LENGTH(T1."AG_ID") = 6 THEN RIGHT(T1."AG_ID", 4) ELSE T1."AG_ID" END AS "Recurso",
        T5."APLATZ_ID" AS "NombreRecurso",
        T5."BEZ",
        (T0."WORKTIME" / 60) AS "Duracion Del MTTO",
        T3."ART1_ID" AS "Num de articulo",
        T3."ItemName" AS "Descripcion del articulo",
        T3."MENGE_LAGER" AS "Cantidad consumida",
        T3."MATERIALKOSTEN" AS "Precio unitario",
        (T3."MATERIALKOSTEN" * T3."MENGE_LAGER") AS "Precio Total",
        T4."ItemName" AS "MTTO",
        T0."TYP" AS "Tipo MTTO",
        T1."BEZ" AS "Comentario en la orden",
        T2."GRUND" AS "Comentario del tecnico",
        ROW_NUMBER() OVER (PARTITION BY T0."BELNR_ID", T3."ART1_ID" ORDER BY T2."ANFZEIT") AS rn
    FROM BEAS_FTHAUPT T0
    LEFT JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID"
    LEFT JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"
    LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID"
    LEFT JOIN BEAS_FTPOS T4 ON T0."BELNR_ID" = T4."BELNR_ID"
    LEFT JOIN BEAS_APLATZ T5 ON T1."APLATZ_ID" = T5."APLATZ_ID"
    WHERE
        T0."TYP" != 'Produccion'
        AND T0."BELNR_ID" >= '15711'
        AND T1."ABGKZ" = 'J'
        AND T3."MENGE_LAGER" > 0
        --AND T0."BELNR_ID" = '33334'
) AS subconsulta
WHERE rn = 1
ORDER BY "Fecha inicio";
