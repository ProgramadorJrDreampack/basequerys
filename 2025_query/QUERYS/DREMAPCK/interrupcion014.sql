--SELECT * FROM BEAS_QSFTHAUPT LIMIT 100;
--SELECT * FROM BEAS_QSFTPOS LIMIT 100;


--SELECT * FROM BEAS_APLATZGRUPPE LIMIT 100;

SELECT * FROM BEAS_APLATZ_STILLSTAND T0    --informe de parada
INNER JOIN BEAS_STILLSTANDGRUND T1 ON T0."GRUNDID" =  T1."GRUNDID"    --Causa de interrupcion
WHERE T0."GRUNDID" = '014' AND T0."DATUM_VON" >= ADD_DAYS(CURRENT_DATE, -30)  -- desde ayer
ORDER BY T0."DATUM_VON" DESC;
--LIMIT 100; 


--SELECT * FROM BEAS_STILLSTANDGRUND LIMIT 100; --Causa de interrupcion



-- ******************************************************************************************************
+ BEAS_APLATZ Resources
 + BEAS_APLATZ_STILLSTAND Standstill report
 + BEAS_APLATZ_TYPE Resource Type
 + BEAS_APLATZ_STL Work Center Material Requirements
 + BEAS_APLATZ_UEBGZEIT Resource Transfer Times
 + BEAS_APLATZ_COSTRATEHEAD Resources cost rates Description


--  **************************************************************************************

SELECT
T0."APLATZ_ID" AS "Recurso",
CASE 
  WHEN T0."RESOURCETYPE" = 'resource' THEN 'recurso'
  ELSE T0."RESOURCETYPE"
END AS "TipoRecurso",
T0."DATUM_VON" AS "FechaInicio",
TO_NVARCHAR(TO_TIME(T0."DATUM_VON"), 'HH24:MI:SS') AS "Hora de inicio",  
* 
FROM BEAS_APLATZ_STILLSTAND T0    --informe de parada
INNER JOIN BEAS_STILLSTANDGRUND T1 ON T0."GRUNDID" =  T1."GRUNDID"    --Causa de interrupcion
WHERE T0."GRUNDID" = '014' AND T0."DATUM_VON" >= ADD_DAYS(CURRENT_DATE, -2)  -- desde ayer
ORDER BY T0."DATUM_VON" DESC;


-- ********************************************************************************************************
SELECT 
T0."APLATZ_ID" AS "Recurso",
T0."BEZ" AS "DescripcionRecurso",
T0."RESOURCETYPE" AS "TipoRecurso",
T1."DATUM_VON" AS "FechaInicio",
TO_NVARCHAR(TO_TIME(T1."DATUM_VON"), 'HH24:MI:SS') AS "Hora de inicio", 
T1."DATUM_BIS" AS "FechaFin",
TO_NVARCHAR(TO_TIME(T1."DATUM_BIS"), 'HH24:MI:SS') AS "Hora fin",
T1."GRUNDID" AS "Motivo",

T1."GRUNDINFO" AS "MotivoDescripcion"
,

* 
FROM BEAS_APLATZ T0
INNER JOIN BEAS_APLATZ_STILLSTAND T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
INNER JOIN BEAS_STILLSTANDGRUND T2 ON T1."GRUNDID" =  T2."GRUNDID" 
WHERE T1."GRUNDID" = '014' AND T1."DATUM_VON" >= ADD_DAYS(CURRENT_DATE, -2)  -- desde ayer
ORDER BY T1."DATUM_VON" DESC;





-- *******************************************************************************************************************

SELECT 
T0."APLATZ_ID" AS "Recurso",
T0."BEZ" AS "DescripcionRecurso",
T0."RESOURCETYPE" AS "TipoRecurso",
T1."DATUM_VON" AS "FechaInicio",
TO_NVARCHAR(TO_TIME(T1."DATUM_VON"), 'HH24:MI:SS') AS "Hora de inicio", 
T1."DATUM_BIS" AS "FechaFin",
TO_NVARCHAR(TO_TIME(T1."DATUM_BIS"), 'HH24:MI:SS') AS "Hora fin",
T1."GRUNDID" AS "Motivo",
T1."GRUNDINFO" AS "MotivoDescripcion",
T1."PERS_ID" AS "PersonalIdEntrada",
T1."PERS_ID_Name" AS "NombrePersonalEntrada",
T1."PERS_ID_END" AS "PersonalIdSalida", 
T1."PERS_ID_END_Name" AS "NombrePersonalSalida",
T1."UDF1" AS "Comentario",
T1."ERFUSER" --,


--* 
FROM BEAS_APLATZ T0
INNER JOIN BEAS_APLATZ_STILLSTAND T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
INNER JOIN BEAS_STILLSTANDGRUND T2 ON T1."GRUNDID" =  T2."GRUNDID" 
WHERE T1."GRUNDID" = '014' AND T1."DATUM_VON" >= ADD_DAYS(CURRENT_DATE, -1)  -- desde ayer
ORDER BY T1."DATUM_VON" DESC;

-- ************************************************************************************************************************


SELECT 
    T0."APLATZ_ID" AS "Recurso",
    T0."BEZ" AS "DescripcionRecurso",
    T0."RESOURCETYPE" AS "TipoRecurso",
    T1."DATUM_VON" AS "FechaInicio",
    TO_NVARCHAR(TO_TIME(T1."DATUM_VON"), 'HH24:MI:SS') AS "Hora de inicio", 
    T1."DATUM_BIS" AS "FechaFin",
    TO_NVARCHAR(TO_TIME(T1."DATUM_BIS"), 'HH24:MI:SS') AS "Hora fin",
    T1."GRUNDID" AS "Motivo",
    T1."GRUNDINFO" AS "MotivoDescripcion",
    T1."PERS_ID" AS "PersonalIdEntrada",
    T1."PERS_ID_Name" AS "NombrePersonalEntrada",
    T1."PERS_ID_END" AS "PersonalIdSalida", 
    T1."PERS_ID_END_Name" AS "NombrePersonalSalida",
    T1."UDF1" AS "Comentario",
    T1."ERFUSER",
    -- Calcula la duración en horas, minutos y segundos
    /*CASE 
        WHEN SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") >= 3600 THEN 
            FLOOR(SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") / 3600) || ' horas ' || 
            TO_NVARCHAR(ROUND(MOD(SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"), 3600) / 60, 2), '99.99') || ' minutos ' || 
            MOD(SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"), 60) || ' segundos'
        WHEN SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") >= 60 THEN 
            FLOOR(SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") / 60) || ' minutos ' || 
            MOD(SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"), 60) || ' segundos'
        ELSE 
            SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") || ' segundos'
    END AS "Duración",*/

   -- Formato de duración en HH:MM:SS
    TO_NVARCHAR(TO_TIME(ADD_SECONDS('00:00:00', SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"))), 'HH24:MI:SS') AS "Duración"
FROM BEAS_APLATZ T0
INNER JOIN BEAS_APLATZ_STILLSTAND T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
INNER JOIN BEAS_STILLSTANDGRUND T2 ON T1."GRUNDID" =  T2."GRUNDID" 
WHERE T1."GRUNDID" = '014' AND T1."DATUM_VON" >= ADD_DAYS(CURRENT_DATE, -2)  -- desde ayer
ORDER BY T1."DATUM_VON" DESC;


-- **********************************************************************************************************************
-- LISTA MANTENIMIENTO CORRECTIVO
SELECT 
    T0."APLATZ_ID" AS "Recurso",
    T0."BEZ" AS "DescripcionRecurso",
    T1."DATUM_VON" AS "FechaInicio",
    TO_NVARCHAR(TO_TIME(T1."DATUM_VON"), 'HH24:MI:SS') AS "HoraInicio", 
    T1."DATUM_BIS" AS "FechaFin",
    TO_NVARCHAR(TO_TIME(T1."DATUM_BIS"), 'HH24:MI:SS') AS "HoraFin",
    
    CASE 
        WHEN SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 86400 THEN NULL -- Filtra valores mayores a 24 horas
        ELSE TO_NVARCHAR(TO_TIME(ADD_SECONDS('00:00:00', SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"))), 'HH24:MI:SS') 
    END AS "Duración",

    CAST(SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") AS DECIMAL(18,2)) / 3600 AS "DuraciónHoras",
    T1."GRUNDID" AS "Motivo",
    T1."GRUNDINFO" AS "MotivoDescripcion",
    T1."PERS_ID" AS "PersonalIdEntrada",
    T1."PERS_ID_Name" AS "NombrePersonalEntrada",
    T1."PERS_ID_END" AS "PersonalIdSalida", 
    T1."PERS_ID_END_Name" AS "NombrePersonalSalida",
    T1."UDF1" AS "Comentario",
    T1."ERFUSER"

FROM BEAS_APLATZ T0
INNER JOIN BEAS_APLATZ_STILLSTAND T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
INNER JOIN BEAS_STILLSTANDGRUND T2 ON T1."GRUNDID" =  T2."GRUNDID" 
WHERE T1."GRUNDID" = '014' 
ORDER BY T1."DATUM_VON" DESC;

-- *****************************************************************************************************************************
-- ALARMA MANTENIMIENTO CORRECTIVO
SELECT 
T0."APLATZ_ID" AS "Recurso",
T0."BEZ" AS "DescripcionRecurso",
--T0."RESOURCETYPE" AS "TipoRecurso",
T1."DATUM_VON" AS "FechaInicio",
TO_NVARCHAR(TO_TIME(T1."DATUM_VON"), 'HH24:MI:SS') AS "HoraInicio", 
T1."DATUM_BIS" AS "FechaFin",
TO_NVARCHAR(TO_TIME(T1."DATUM_BIS"), 'HH24:MI:SS') AS "HoraFin",

TO_NVARCHAR(TO_TIME(ADD_SECONDS('00:00:00', SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"))), 'HH24:MI:SS') AS "Duración",

CASE 
        WHEN SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 86400 THEN NULL -- Filtra valores mayores a 24 horas
        ELSE TO_NVARCHAR(TO_TIME(ADD_SECONDS('00:00:00', SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"))), 'HH24:MI:SS') 
    END AS "Duración",

/*CASE 
        WHEN SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600 THEN 'Si'
        ELSE 'No'
 END AS "Superado10Minutos",*/
T1."GRUNDID" AS "Motivo",
T1."GRUNDINFO" AS "MotivoDescripcion",
T1."PERS_ID" AS "PersonalIdEntrada",
T1."PERS_ID_Name" AS "NombrePersonalEntrada",
T1."PERS_ID_END" AS "PersonalIdSalida", 
T1."PERS_ID_END_Name" AS "NombrePersonalSalida",
T1."UDF1" AS "Comentario",
T1."ERFUSER"

FROM BEAS_APLATZ T0
INNER JOIN BEAS_APLATZ_STILLSTAND T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
INNER JOIN BEAS_STILLSTANDGRUND T2 ON T1."GRUNDID" =  T2."GRUNDID" 
WHERE 
T1."GRUNDID" = '014' 
AND T1."DATUM_VON" >= ADD_DAYS(CURRENT_DATE, -1) 
AND SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600  -- supera los 10 minutos
ORDER BY T1."DATUM_VON" DESC;



-- ***************************************************************************************************************************************


 SELECT 
        T0."APLATZ_ID" AS "Recurso",
        T0."BEZ" AS "DescripcionRecurso",
        T1."DATUM_VON" AS "FechaInicio",
        TO_NVARCHAR(TO_TIME(T1."DATUM_VON"), 'HH24:MI:SS') AS "HoraInicio", 
        T1."DATUM_BIS" AS "FechaFin",
        TO_NVARCHAR(TO_TIME(T1."DATUM_BIS"), 'HH24:MI:SS') AS "HoraFin",
        CASE 
            WHEN SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 86400 THEN NULL 
            ELSE TO_NVARCHAR(TO_TIME(ADD_SECONDS('00:00:00', SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"))), 'HH24:MI:SS') 
        END AS "Duración",
        T1."GRUNDID" AS "Motivo",
        T1."GRUNDINFO" AS "MotivoDescripcion",
        T1."PERS_ID" AS "PersonalIdEntrada",
        T1."PERS_ID_Name" AS "NombrePersonalEntrada",
        T1."PERS_ID_END" AS "PersonalIdSalida", 
        T1."PERS_ID_END_Name" AS "NombrePersonalSalida",
        T1."UDF1" AS "Comentario",
        T1."ERFUSER"

    FROM BEAS_APLATZ T0
    INNER JOIN BEAS_APLATZ_STILLSTAND T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
    INNER JOIN BEAS_STILLSTANDGRUND T2 ON T1."GRUNDID" =  T2."GRUNDID" 
    WHERE 
        T1."GRUNDID" = '014' 
        AND CAST(T1."DATUM_VON" AS DATE) = CAST(CURRENT_DATE AS DATE)  -- Filtra solo el día actual
        AND HOUR(T1."DATUM_VON") = HOUR(CURRENT_TIMESTAMP)  -- Filtra solo por la hora actual
        AND MINUTE(T1."DATUM_VON") = MINUTE(CURRENT_TIMESTAMP) 
        AND SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600  
    ORDER BY T1."DATUM_VON" DESC;




-- ********************************************************************************************************************************************

SELECT 
        T0."APLATZ_ID" AS "Recurso",
        T0."BEZ" AS "DescripcionRecurso",
        T1."DATUM_VON" AS "FechaInicio",
        TO_NVARCHAR(TO_TIME(T1."DATUM_VON"), 'HH24:MI:SS') AS "HoraInicio", 
        T1."DATUM_BIS" AS "FechaFin",
        TO_NVARCHAR(TO_TIME(T1."DATUM_BIS"), 'HH24:MI:SS') AS "HoraFin",
        CASE 
            WHEN SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 86400 THEN NULL 
            ELSE TO_NVARCHAR(TO_TIME(ADD_SECONDS('00:00:00', SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"))), 'HH24:MI:SS') 
        END AS "Duración",
        T1."GRUNDID" AS "Motivo",
        T1."GRUNDINFO" AS "MotivoDescripcion",
        T1."PERS_ID" AS "PersonalIdEntrada",
        T1."PERS_ID_Name" AS "NombrePersonalEntrada",
        T1."PERS_ID_END" AS "PersonalIdSalida", 
        T1."PERS_ID_END_Name" AS "NombrePersonalSalida",
        T1."UDF1" AS "Comentario",
        T1."ERFUSER"

    FROM BEAS_APLATZ T0
    INNER JOIN BEAS_APLATZ_STILLSTAND T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
    INNER JOIN BEAS_STILLSTANDGRUND T2 ON T1."GRUNDID" =  T2."GRUNDID" 
    WHERE 
        T1."GRUNDID" = '014' 
        AND CAST(T1."DATUM_VON" AS DATE) = '2025-04-02' --CAST(CURRENT_DATE AS DATE)  -- Filtra solo el día actual
        AND HOUR(T1."DATUM_VON") = 7 --HOUR(CURRENT_TIMESTAMP)  -- Filtra solo por la hora actual
        AND MINUTE(T1."DATUM_VON") = 53 --MINUTE(CURRENT_TIMESTAMP) --Filtra solo por el minuto actual
        AND SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600  --Filtra solo los que superan los 10 min
    ORDER BY T1."DATUM_VON" DESC;



-- *******************************************************************************************************************************
-- Ultima Modificación
SELECT 
        T0."APLATZ_ID" AS "Recurso",
        T0."BEZ" AS "DescripcionRecurso",
        T1."DATUM_VON" AS "FechaInicio",
        TO_NVARCHAR(TO_TIME(T1."DATUM_VON"), 'HH24:MI:SS') AS "HoraInicio", 
        -- T1."DATUM_BIS" AS "FechaFin",
        -- TO_NVARCHAR(TO_TIME(T1."DATUM_BIS"), 'HH24:MI:SS') AS "HoraFin",
        -- CASE 
        --     WHEN SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 86400 THEN NULL 
        --     ELSE TO_NVARCHAR(TO_TIME(ADD_SECONDS('00:00:00', SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"))), 'HH24:MI:SS') 
        -- END AS "Duración",
        CASE 
            WHEN CAST(T1."DATUM_BIS" AS DATE) = '2050-01-01' THEN NULL 
            ELSE T1."DATUM_BIS" 
        END AS "FechaFin",
        CASE 
            WHEN CAST(T1."DATUM_BIS" AS DATE) = '2050-01-01' THEN NULL 
            ELSE TO_NVARCHAR(TO_TIME(T1."DATUM_BIS"), 'HH24:MI:SS') 
        END AS "HoraFin",
        CASE 
            WHEN CAST(T1."DATUM_BIS" AS DATE) = '2050-01-01' THEN NULL 
            ELSE 
                CASE 
                    WHEN SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 86400 THEN NULL 
                    ELSE TO_NVARCHAR(TO_TIME(ADD_SECONDS('00:00:00', SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"))), 'HH24:MI:SS') 
                END 
        END AS "Duración",
        T1."GRUNDID" AS "Motivo",
        T1."GRUNDINFO" AS "MotivoDescripcion",
        T1."PERS_ID" AS "PersonalIdEntrada",
        T1."PERS_ID_Name" AS "NombrePersonalEntrada",
        T1."PERS_ID_END" AS "PersonalIdSalida", 
        T1."PERS_ID_END_Name" AS "NombrePersonalSalida",
        T1."UDF1" AS "Comentario",
        T1."ERFUSER" --,
        /*CASE 
            WHEN SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 600 THEN 'Si'
            ELSE 'No'
        END AS "Superado10Minutos"*/

    FROM BEAS_APLATZ T0
    INNER JOIN BEAS_APLATZ_STILLSTAND T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
    INNER JOIN BEAS_STILLSTANDGRUND T2 ON T1."GRUNDID" =  T2."GRUNDID" 
    WHERE 
        T1."GRUNDID" = '014' 
        AND CAST(T1."DATUM_VON" AS DATE) =  CAST(CURRENT_DATE AS DATE)  -- Filtra solo el día actual  '2025-04-04'
        AND HOUR(T1."DATUM_VON") = HOUR(CURRENT_TIMESTAMP)  -- Filtra solo por la hora actual  08 
        AND MINUTE(T1."DATUM_VON") =  MINUTE(CURRENT_TIMESTAMP) --Filtra solo por el minuto actual 55
        AND (SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 600 OR SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600)
        --AND SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 600  --Filtra solo los que superan los 10 min
    ORDER BY T1."DATUM_VON" DESC;




    -- *********************************************************************************************************************

-- OPCION1
SELECT 
    T0."APLATZ_ID" AS "Recurso",
    T0."BEZ" AS "DescripcionRecurso",
    T1."DATUM_VON" AS "FechaInicio",
    TO_NVARCHAR(TO_TIME(T1."DATUM_VON"), 'HH24:MI:SS') AS "HoraInicio", 
    T1."DATUM_BIS" AS "FechaFin",
    TO_NVARCHAR(TO_TIME(T1."DATUM_BIS"), 'HH24:MI:SS') AS "HoraFin",
    CASE 
        WHEN SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 86400 THEN NULL 
        ELSE TO_NVARCHAR(TO_TIME(ADD_SECONDS('00:00:00', SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"))), 'HH24:MI:SS') 
    END AS "Duración",
    T1."GRUNDID" AS "Motivo",
    T1."GRUNDINFO" AS "MotivoDescripcion",
    T1."PERS_ID" AS "PersonalIdEntrada",
    T1."PERS_ID_Name" AS "NombrePersonalEntrada",
    T1."PERS_ID_END" AS "PersonalIdSalida", 
    T1."PERS_ID_END_Name" AS "NombrePersonalSalida",
    T1."UDF1" AS "Comentario",
    T1."ERFUSER"

FROM BEAS_APLATZ T0
INNER JOIN BEAS_APLATZ_STILLSTAND T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
INNER JOIN BEAS_STILLSTANDGRUND T2 ON T1."GRUNDID" =  T2."GRUNDID" 
WHERE 
    T1."GRUNDID" = '014' 
    AND CAST(T1."DATUM_VON" AS DATE) = CAST(CURRENT_DATE AS DATE)  
    AND (
        (HOUR(T1."DATUM_VON") = HOUR(CURRENT_TIMESTAMP) AND MINUTE(T1."DATUM_VON") = MINUTE(CURRENT_TIMESTAMP)) 
        OR 
        (HOUR(T1."DATUM_VON") = HOUR(CURRENT_TIMESTAMP) AND MINUTE(T1."DATUM_VON") = MINUTE(CURRENT_TIMESTAMP) - 10)
    )
    AND SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 600  
ORDER BY T1."DATUM_VON" DESC;

-- OPCION2
SELECT 
    T0."APLATZ_ID" AS "Recurso",
    T0."BEZ" AS "DescripcionRecurso",
    T1."DATUM_VON" AS "FechaInicio",
    TO_NVARCHAR(TO_TIME(T1."DATUM_VON"), 'HH24:MI:SS') AS "HoraInicio", 
    T1."DATUM_BIS" AS "FechaFin",
    TO_NVARCHAR(TO_TIME(T1."DATUM_BIS"), 'HH24:MI:SS') AS "HoraFin",
    CASE 
        WHEN SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 86400 THEN NULL 
        ELSE TO_NVARCHAR(TO_TIME(ADD_SECONDS('00:00:00', SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"))), 'HH24:MI:SS') 
    END AS "Duración",
    T1."GRUNDID" AS "Motivo",
    T1."GRUNDINFO" AS "MotivoDescripcion",
    T1."PERS_ID" AS "PersonalIdEntrada",
    T1."PERS_ID_Name" AS "NombrePersonalEntrada",
    T1."PERS_ID_END" AS "PersonalIdSalida", 
    T1."PERS_ID_END_Name" AS "NombrePersonalSalida",
    T1."UDF1" AS "Comentario",
    T1."ERFUSER"

FROM BEAS_APLATZ T0
INNER JOIN BEAS_APLATZ_STILLSTAND T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
INNER JOIN BEAS_STILLSTANDGRUND T2 ON T1."GRUNDID" =  T2."GRUNDID" 
WHERE 
    T1."GRUNDID" = '014' 
    AND CAST(T1."DATUM_VON" AS DATE) = CAST(CURRENT_DATE AS DATE)  
    AND (
        (HOUR(T1."DATUM_VON") = HOUR(ADD_SECONDS(CURRENT_TIMESTAMP, -600)) AND MINUTE(T1."DATUM_VON") >= MINUTE(ADD_SECONDS(CURRENT_TIMESTAMP, -600))) 
        OR 
        (HOUR(T1."DATUM_VON") = HOUR(CURRENT_TIMESTAMP) AND MINUTE(T1."DATUM_VON") <= MINUTE(CURRENT_TIMESTAMP))
    )
    AND SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 600  
ORDER BY T1."DATUM_VON" DESC;


-- ******************************************************************************************************************************************************


SELECT 
    T0."APLATZ_ID" AS "Recurso",
    T0."BEZ" AS "DescripcionRecurso",
    T1."DATUM_VON" AS "FechaInicio",
    TO_NVARCHAR(TO_TIME(T1."DATUM_VON"), 'HH24:MI:SS') AS "HoraInicio", 
    CASE 
        WHEN CAST(T1."DATUM_BIS" AS DATE) = '2050-01-01' THEN NULL 
        ELSE T1."DATUM_BIS" 
    END AS "FechaFin",
    CASE 
        WHEN CAST(T1."DATUM_BIS" AS DATE) = '2050-01-01' THEN NULL 
        ELSE TO_NVARCHAR(TO_TIME(T1."DATUM_BIS"), 'HH24:MI:SS') 
    END AS "HoraFin",
    CASE 
        WHEN CAST(T1."DATUM_BIS" AS DATE) = '2050-01-01' THEN NULL 
        ELSE 
            CASE 
                WHEN SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 86400 THEN NULL 
                ELSE TO_NVARCHAR(TO_TIME(ADD_SECONDS('00:00:00', SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"))), 'HH24:MI:SS') 
            END 
    END AS "Duración",
    T1."GRUNDID" AS "Motivo",
    T1."GRUNDINFO" AS "MotivoDescripcion",
    T1."PERS_ID" AS "PersonalIdEntrada",
    T1."PERS_ID_Name" AS "NombrePersonalEntrada",
    T1."PERS_ID_END" AS "PersonalIdSalida", 
    T1."PERS_ID_END_Name" AS "NombrePersonalSalida",
    T1."UDF1" AS "Comentario",
    T1."ERFUSER"

FROM BEAS_APLATZ T0
INNER JOIN BEAS_APLATZ_STILLSTAND T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
INNER JOIN BEAS_STILLSTANDGRUND T2 ON T1."GRUNDID" =  T2."GRUNDID" 
WHERE 
    T1."GRUNDID" = '014' 
    AND CAST(T1."DATUM_VON" AS DATE) = '2025-04-04' 
    AND (
        --(HOUR(T1."DATUM_VON") = 8 AND MINUTE(T1."DATUM_VON") = 55) 
        --OR 
        (HOUR(T1."DATUM_VON") = 8 AND MINUTE(T1."DATUM_VON") < 55 AND SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600 AND SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) <= 660)
    )
    AND (SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 600 OR SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600)
ORDER BY T1."DATUM_VON" DESC;


1. T1."GRUNDID" = '014'
Motivo: Esta condición filtra los eventos para que solo se consideren aquellos con el motivo de mantenimiento correctivo, identificado por el código '014'.

2. CAST(T1."DATUM_VON" AS DATE) = '2025-04-04'
Fecha de inicio: Esta condición asegura que solo se consideren eventos que ocurrieron el día 4 de abril de 2025. 
La función CAST(T1."DATUM_VON" AS DATE) elimina la parte de hora y minutos de la fecha, dejando solo el día, mes y año.

3. (HOUR(T1."DATUM_VON") = 8 AND MINUTE(T1."DATUM_VON") < 55 AND SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600 AND SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) <= 660)
Hora y minuto de inicio: Esta condición filtra eventos que ocurrieron a las 8 de la mañana pero antes de las 8:55.

HOUR(T1."DATUM_VON") = 8: Asegura que el evento ocurrió a las 8 de la mañana.

MINUTE(T1."DATUM_VON") < 55: Asegura que el evento ocurrió antes de las 8:55.

SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600: Asegura que han pasado más de 10 minutos desde el inicio del evento hasta el momento actual.

SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) <= 660: Asegura que no hayan pasado más de 11 minutos desde el inicio del evento hasta el momento actual.

4. (SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 600 OR SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600)
Duración del evento: Esta condición asegura que se consideren eventos que han durado más de 10 minutos.

SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 600: Si el evento tiene una fecha de fin (DATUM_BIS), esta condición verifica que la duración del evento sea mayor a 10 minutos.

SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600: Si el evento no tiene una fecha de fin (o es muy lejana en el futuro), esta condición verifica que han pasado más de 10 minutos desde el inicio del evento hasta el momento actual.

En resumen, esta consulta busca eventos de mantenimiento correctivo que ocurrieron el 4 de abril de 2025, a las 8 de la mañana antes de las 8:55, 
y que han durado más de 10 minutos pero no más de 11 minutos desde su inicio. También considera eventos que han durado más de 10 minutos en total,
 ya sea porque tienen una fecha de fin o porque han pasado más de 10 minutos desde su inicio hasta el momento actual.

 SELECT 
    T0."APLATZ_ID" AS "Recurso",
    T0."BEZ" AS "DescripcionRecurso",
    T1."DATUM_VON" AS "FechaInicio",
    TO_NVARCHAR(TO_TIME(T1."DATUM_VON"), 'HH24:MI:SS') AS "HoraInicio", 
    CASE 
        WHEN CAST(T1."DATUM_BIS" AS DATE) = '2050-01-01' THEN NULL 
        ELSE T1."DATUM_BIS" 
    END AS "FechaFin",
    CASE 
        WHEN CAST(T1."DATUM_BIS" AS DATE) = '2050-01-01' THEN NULL 
        ELSE TO_NVARCHAR(TO_TIME(T1."DATUM_BIS"), 'HH24:MI:SS') 
    END AS "HoraFin",
    CASE 
        WHEN CAST(T1."DATUM_BIS" AS DATE) = '2050-01-01' THEN NULL 
        ELSE 
            CASE 
                WHEN SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 86400 THEN NULL 
                ELSE TO_NVARCHAR(TO_TIME(ADD_SECONDS('00:00:00', SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"))), 'HH24:MI:SS') 
            END 
    END AS "Duración",
    T1."GRUNDID" AS "Motivo",
    T1."GRUNDINFO" AS "MotivoDescripcion",
    T1."PERS_ID" AS "PersonalIdEntrada",
    T1."PERS_ID_Name" AS "NombrePersonalEntrada",
    T1."PERS_ID_END" AS "PersonalIdSalida", 
    T1."PERS_ID_END_Name" AS "NombrePersonalSalida",
    T1."UDF1" AS "Comentario",
    T1."ERFUSER"

FROM BEAS_APLATZ T0
INNER JOIN BEAS_APLATZ_STILLSTAND T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
INNER JOIN BEAS_STILLSTANDGRUND T2 ON T1."GRUNDID" =  T2."GRUNDID" 
WHERE 
    T1."GRUNDID" = '014' 
    AND CAST(T1."DATUM_VON" AS DATE) = '2025-04-04' 
    AND (
        --(HOUR(T1."DATUM_VON") = 8 AND MINUTE(T1."DATUM_VON") = 55) 
        --OR 
        (HOUR(T1."DATUM_VON") = 8 AND MINUTE(T1."DATUM_VON") < 55 AND SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600 AND SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) <= 660)
    )
    AND (SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 600 OR SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600)
ORDER BY T1."DATUM_VON" DESC;


-- ***********************************************************************************************

SELECT 
    T0."APLATZ_ID" AS "Recurso",
    T0."BEZ" AS "DescripcionRecurso",
    T1."DATUM_VON" AS "FechaInicio",
    TO_NVARCHAR(TO_TIME(T1."DATUM_VON"), 'HH24:MI:SS') AS "HoraInicio", 
    CASE 
        WHEN CAST(T1."DATUM_BIS" AS DATE) = '2050-01-01' THEN NULL 
        ELSE T1."DATUM_BIS" 
    END AS "FechaFin",
    CASE 
        WHEN CAST(T1."DATUM_BIS" AS DATE) = '2050-01-01' THEN NULL 
        ELSE TO_NVARCHAR(TO_TIME(T1."DATUM_BIS"), 'HH24:MI:SS') 
    END AS "HoraFin",
    CASE 
        WHEN CAST(T1."DATUM_BIS" AS DATE) = '2050-01-01' THEN NULL 
        ELSE 
            CASE 
                WHEN SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 86400 THEN NULL 
                ELSE TO_NVARCHAR(TO_TIME(ADD_SECONDS('00:00:00', SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"))), 'HH24:MI:SS') 
            END 
    END AS "Duración",
    T1."GRUNDID" AS "Motivo",
    T1."GRUNDINFO" AS "MotivoDescripcion",
    T1."PERS_ID" AS "PersonalIdEntrada",
    T1."PERS_ID_Name" AS "NombrePersonalEntrada",
    T1."PERS_ID_END" AS "PersonalIdSalida", 
    T1."PERS_ID_END_Name" AS "NombrePersonalSalida",
    T1."UDF1" AS "Comentario",
    T1."ERFUSER"

FROM BEAS_APLATZ T0
INNER JOIN BEAS_APLATZ_STILLSTAND T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
INNER JOIN BEAS_STILLSTANDGRUND T2 ON T1."GRUNDID" =  T2."GRUNDID" 
WHERE 
    T1."GRUNDID" = '014' 
    AND CAST(T1."DATUM_VON" AS DATE) = '2025-04-07' 
    AND (
        (HOUR(T1."DATUM_VON") = 12 AND MINUTE(T1."DATUM_VON") = 44) 
        OR 
        (HOUR(T1."DATUM_VON") = 12 AND MINUTE(T1."DATUM_VON") < 54 AND SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600)
    )
    AND (SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 600 OR SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600)
ORDER BY T1."DATUM_VON" DESC;


/* asi quedo la alarma de mantenimiento correctico 014 estamos en pruebas */
SELECT 
    T0."APLATZ_ID" AS "Recurso",
    T0."BEZ" AS "DescripcionRecurso",
    T1."DATUM_VON" AS "FechaInicio",
    TO_NVARCHAR(TO_TIME(T1."DATUM_VON"), 'HH24:MI:SS') AS "HoraInicio", 
    CASE 
        WHEN CAST(T1."DATUM_BIS" AS DATE) = '2050-01-01' THEN NULL 
        ELSE T1."DATUM_BIS" 
    END AS "FechaFin",
    CASE 
        WHEN CAST(T1."DATUM_BIS" AS DATE) = '2050-01-01' THEN NULL 
        ELSE TO_NVARCHAR(TO_TIME(T1."DATUM_BIS"), 'HH24:MI:SS') 
    END AS "HoraFin",
    CASE 
        WHEN CAST(T1."DATUM_BIS" AS DATE) = '2050-01-01' THEN NULL 
        ELSE 
            CASE 
                WHEN SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 86400 THEN NULL 
                ELSE TO_NVARCHAR(TO_TIME(ADD_SECONDS('00:00:00', SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS"))), 'HH24:MI:SS') 
            END 
    END AS "Duración",
    T1."GRUNDID" AS "Motivo",
    T1."GRUNDINFO" AS "MotivoDescripcion",
    T1."PERS_ID" AS "PersonalIdEntrada",
    T1."PERS_ID_Name" AS "NombrePersonalEntrada",
    T1."PERS_ID_END" AS "PersonalIdSalida", 
    T1."PERS_ID_END_Name" AS "NombrePersonalSalida",
    T1."UDF1" AS "Comentario",
    T1."ERFUSER"

FROM BEAS_APLATZ T0
INNER JOIN BEAS_APLATZ_STILLSTAND T1 ON T0."APLATZ_ID" = T1."APLATZ_ID"
INNER JOIN BEAS_STILLSTANDGRUND T2 ON T1."GRUNDID" =  T2."GRUNDID" 
WHERE 
    T1."GRUNDID" = '014' 
    AND CAST(T1."DATUM_VON" AS DATE) =  CAST(CURRENT_DATE AS DATE)  --'2025-04-07' 
    AND (
        (HOUR(T1."DATUM_VON") = HOUR(CURRENT_TIMESTAMP) AND MINUTE(T1."DATUM_VON") =  MINUTE(CURRENT_TIMESTAMP)) 
        OR 
        (HOUR(T1."DATUM_VON") = HOUR(CURRENT_TIMESTAMP) AND MINUTE(T1."DATUM_VON") < MINUTE(T1."DATUM_VON") AND SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600)
    )
    AND (SECONDS_BETWEEN(T1."DATUM_VON", T1."DATUM_BIS") > 600 OR SECONDS_BETWEEN(T1."DATUM_VON", CURRENT_TIMESTAMP) > 600)
ORDER BY T1."DATUM_VON" DESC;

MAN01 = coordinador.mantenimiento@dreampackgroup.com
MAN01 = 