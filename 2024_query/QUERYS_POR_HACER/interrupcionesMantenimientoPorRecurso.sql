/* VIEW */

SELECT 
* 
FROM "SBO_FIGURETTI_PRO"."DPE_INTERRUPCION_RECURSOS"
WHERE 
"Fecha" BETWEEN '2024-08-01' AND '2024-08-31'

/* asi se queria llegar  */

SELECT 
   T0."APLATZ_ID" AS "Recurso",
   ROUND(SUM(ABS(SECONDS_BETWEEN(T0."DATUM_BIS", T0."DATUM_VON") / 60)), 2) AS "Suma de Duración en Minutos",  -- Suma de la duración en minutos
   COUNT(*) AS "Suma de Cantidad"
FROM 
    BEAS_APLATZ_STILLSTAND T0
INNER JOIN 
    BEAS_APLATZ T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
WHERE 
    T0."DATUM_VON" BETWEEN '2024-08-01' AND '2024-08-31' AND
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
   'Total General' AS "Recurso",
   ROUND(SUM(ABS(SECONDS_BETWEEN(T0."DATUM_BIS", T0."DATUM_VON") / 60)), 2) AS "Suma de Duración en Minutos",
   COUNT(*) AS "Suma de Cantidad" 
FROM 
    BEAS_APLATZ_STILLSTAND T0
INNER JOIN 
    BEAS_APLATZ T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
WHERE 
    T0."DATUM_VON" BETWEEN '2024-08-01' AND '2024-08-31' AND
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
   "Recurso";

/* y query por agrupacion */

SELECT 
   T0."INTNR" AS "Orden",
   T0."APLATZ_ID" AS "Recurso",
   CASE WHEN T0."RESOURCETYPE" = 'resource'   THEN 'Recurso'  ELSE ' ' END AS "Recurso Tipo",
   T1."BEZ" AS "Descripción",
   TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH24:MI:SS') AS "Desde",
   T0."PERS_ID" AS "Personal",
   T0."PERS_ID_Name" AS "Personal Nombre",
   TO_NVARCHAR(T0."DATUM_BIS", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_BIS"), 'HH24:MI:SS') AS "Hasta",
   T0."PERS_ID_END" AS "Personal",
   CASE WHEN T0."statusId" = 2   THEN 'Hecho'  ELSE ' ' END AS "Estatus",
   T0."PERS_ID_END_Name" AS "Personal Nombre",
   T0."GRUNDID" AS "Motivo",
   T0."GRUNDINFO" AS "Motivo Descripción",
   T1."GRUPPE" AS "Recurso Grupo",
   '1' AS "Cantidad",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."DATUM_BIS", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Duración en Minutos",
   T1."KSTST_ID" AS "Centro de costo"
   
FROM 
    BEAS_APLATZ_STILLSTAND T0
INNER JOIN 
    BEAS_APLATZ T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
WHERE 
    T0."DATUM_VON" BETWEEN '2024-08-01' AND '2024-08-31' AND
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


   /* query normal  */


SELECT 
   T0."INTNR" AS "Orden",
   T0."DATUM_VON",
   T0."APLATZ_ID" AS "Recurso",
   CASE WHEN T0."RESOURCETYPE" = 'resource'   THEN 'Recurso'  ELSE ' ' END AS "Recurso Tipo",
   T1."BEZ" AS "Descripción",
   TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH24:MI:SS') AS "Desde",
   T0."PERS_ID" AS "Personal",
   T0."PERS_ID_Name" AS "Personal Nombre",
   TO_NVARCHAR(T0."DATUM_BIS", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_BIS"), 'HH24:MI:SS') AS "Hasta",
   T0."PERS_ID_END" AS "Personal",
   CASE WHEN T0."statusId" = 2   THEN 'Hecho'  ELSE ' ' END AS "Estatus",
   T0."PERS_ID_END_Name" AS "Personal Nombre",
   T0."GRUNDID" AS "Motivo",
   T0."GRUNDINFO" AS "Motivo Descripción",
   T1."GRUPPE" AS "Recurso Grupo",
   1 AS "Cantidad",
   ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."DATUM_BIS", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Duración en Minutos",
   T1."KSTST_ID" AS "Centro de costo"
   
FROM 
    "SBO_FIGURETTI_PRO"."BEAS_APLATZ_STILLSTAND" T0
INNER JOIN 
    "SBO_FIGURETTI_PRO"."BEAS_APLATZ" T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
WHERE 
    T0."DATUM_VON" >= '2024-01-01' AND  
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


/* vista */
SELECT * FROM "SBO_FIGURETTI_PRO"."DPE_INTERRUPCION_RECURSOS"
WHERE "Fecha" BETWEEN '2024-08-01' AND '2024-08-31'





/* ASI QUEDO LA VISTA */

DROP VIEW "SBO_FIGURETTI_PRO"."DPE_INTERRUPCION_RECURSOS";

CREATE VIEW "SBO_FIGURETTI_PRO"."DPE_INTERRUPCION_RECURSOS" ( 
   "Orden",
   "Fecha",
   "Recurso",
   "Recurso_Tipo",
   "Descripcion", 
   "Desde",
   "Personal",
   "Personal_Nombre",
   "Hasta",
   "Personal_Fin",
   "Estatus",
   "Personal_Nombre_Fin",
   "Motivo",
   "Motivo_Descripcion",
   "Recurso_Grupo",
   "Cantidad",
   "Duracion_Minutos",
   "Centro_Costo"
   ) AS (
    (
        SELECT 
            T0."INTNR" AS "Orden",
            T0."DATUM_VON" AS "Fecha",
            T0."APLATZ_ID" AS "Recurso",
            CASE WHEN T0."RESOURCETYPE" = 'resource'   THEN 'Recurso'  ELSE ' ' END AS "Recurso_Tipo",
            T1."BEZ" AS "Descripcion",
            TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH24:MI:SS') AS "Desde",
            T0."PERS_ID" AS "Personal",
            T0."PERS_ID_Name" AS "Personal_Nombre",
            TO_NVARCHAR(T0."DATUM_BIS", 'YYYY-MM-DD') || ' ' || TO_NVARCHAR(TO_TIME(T0."DATUM_BIS"), 'HH24:MI:SS') AS "Hasta",
            T0."PERS_ID_END" AS "Personal_Fin",
            CASE WHEN T0."statusId" = 2   THEN 'Hecho'  ELSE ' ' END AS "Estatus",
            T0."PERS_ID_END_Name" AS "Personal_Nombre_Fin",
            T0."GRUNDID" AS "Motivo",
            T0."GRUNDINFO" AS "Motivo_Descripcion",
            T1."GRUPPE" AS "Recurso_Grupo",
            1 AS "Cantidad",
            ROUND(ABS(SECONDS_BETWEEN(TO_NVARCHAR(T0."DATUM_BIS", 'YYYY-MM-DD HH24:MI:SS'), TO_NVARCHAR(T0."DATUM_VON", 'YYYY-MM-DD HH24:MI:SS')) / 60), 2) AS "Duracion_Minutos",
            T1."KSTST_ID" AS "Centro_Costo"
        FROM 
            "SBO_FIGURETTI_PRO"."BEAS_APLATZ_STILLSTAND" T0
        INNER JOIN 
            "SBO_FIGURETTI_PRO"."BEAS_APLATZ" T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
        WHERE 
            T0."DATUM_VON" >= '2024-01-01' AND  
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
    )
) WITH READ ONLY





/* PARA CRYSTAL REPORT PARAMTRO DE FECHA INICIO Y FECHA FIN */
IF {DPE_INTERRUPCION_RECURSOS.Fecha} >= {?Fecha_Inicio} AND
{DPE_INTERRUPCION_RECURSOS.Fecha} <= {?Fecha_Fin} THEN TRUE


 SELECT 
    "DPE_INTERRUPCION_RECURSOS"."Recurso", 
    "DPE_INTERRUPCION_RECURSOS"."Fecha", 
    "DPE_INTERRUPCION_RECURSOS"."Duracion_Minutos", 
    "DPE_INTERRUPCION_RECURSOS"."Cantidad"
 FROM  "SBO_FIGURETTI_PRO"."DPE_INTERRUPCION_RECURSOS" "DPE_INTERRUPCION_RECURSOS"
 WHERE (
    "DPE_INTERRUPCION_RECURSOS"."Fecha">={ts '2024-08-01 00:00:00'} AND 
    "DPE_INTERRUPCION_RECURSOS"."Fecha"<{ts '2024-09-01 00:00:00'})
 ORDER BY "DPE_INTERRUPCION_RECURSOS"."Recurso"



                       