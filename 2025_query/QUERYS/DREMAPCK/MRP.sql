

SELECT * FROM "BEAS_MRP_DETAIL" where "NR" = 26 AND "ItemCode" = '01DBC00100083' ORDER BY "DATUM" ASC LIMIT 1000

SELECT * FROM "BEAS_MRP_PLANUNG" LIMIT 100


SELECT T0."ItemCode",T0."DfltWH", T1."MinStock" 
FROM OITM T0 
INNER JOIN OITW T1 ON T0."ItemCode" = T1."ItemCode" AND T0."DfltWH" = T1."WhsCode" 
WHERE T0."ItemCode" = '01DBC00100083'

-- *************************************************************************************************


SELECT 
T1."DATUM" AS "Fecha",
T1."ItemCode" AS "Cod del Articulo",
T1."OnHand" AS "Inventario Inicial",
T3."MinStock" AS "Politica",
T1."BESTELLUNG_ZUGANG" AS "Compra",
T1."FERTIGUNG_ABGANG" AS "Consumo",
--T1."ONHAND2" AS "Inventario Final ONHAND2",
(T1."OnHand" + T1."BESTELLUNG_ZUGANG" - T3."MinStock" - T1."BESTELLUNG_ZUGANG" ) AS "Inventario Final"
FROM "BEAS_MRP_PLANUNG" T0
INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
WHERE T0."NR" = 26 AND T1."ItemCode" = '01DBC00100083'--'01DBC00100083'
ORDER BY T1."DATUM" ASC LIMIT 100;



-- ******************************************************************************************************

SELECT 
    YEAR(T1."DATUM") AS "Año",
    MONTH(T1."DATUM") AS "Mes",
    T1."ItemCode" AS "Cod del Articulo",
    SUM(T1."OnHand") AS "Inventario Inicial",
    MAX(T3."MinStock") AS "Politica",
    SUM(T1."BESTELLUNG_ZUGANG") AS "Compra",
    SUM(T1."FERTIGUNG_ABGANG") AS "Consumo",
    SUM(T1."OnHand" + T1."BESTELLUNG_ZUGANG" - T3."MinStock" - T1."BESTELLUNG_ZUGANG") AS "Inventario Final"
FROM "BEAS_MRP_PLANUNG" T0
INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
WHERE T0."NR" = 26 
    AND T1."ItemCode" = '01DBC00100083'
GROUP BY YEAR(T1."DATUM"), MONTH(T1."DATUM"), T1."ItemCode"
ORDER BY "Año" ASC, "Mes" ASC;




-- *********************************************************************************************************************
-- ASI ESTA QUEDANDO
-- Usamos la función LEAD() para obtener el consumo del mes siguiente dentro del mismo año.
-- Protección contra división por cero: NULLIF(..., 0)


SELECT 
    YEAR(T1."DATUM") AS "Año",
	CASE TO_VARCHAR(T1."DATUM", 'MM')
	    WHEN 1 THEN 'Enero'
	    WHEN 2 THEN 'Febrero'
	    WHEN 3 THEN 'Marzo'
	    WHEN 4 THEN 'Abril'
	    WHEN 5 THEN 'Mayo'
	    WHEN 6 THEN 'Junio'
	    WHEN 7 THEN 'Julio'
	    WHEN 8 THEN 'Agosto'
	    WHEN 9 THEN 'Septiembre'
	    WHEN 10 THEN 'Octubre'
	    WHEN 11 THEN 'Noviembre'
	    WHEN 12 THEN 'Diciembre'
	END AS "Mes",
    T1."ItemCode" AS "Cod del Articulo",
    SUM(T1."OnHand") AS "Inventario Inicial",
    MAX(T3."MinStock") AS "Politica",
    SUM(T1."BESTELLUNG_ZUGANG") AS "Compra",
    SUM(T1."FERTIGUNG_ABGANG") AS "Consumo",
    SUM(T1."OnHand" + T1."BESTELLUNG_ZUGANG" - T3."MinStock" - T1."BESTELLUNG_ZUGANG") AS "Inventario Final",
    ROUND(
        SUM(T1."OnHand" + T1."BESTELLUNG_ZUGANG" - T3."MinStock" - T1."BESTELLUNG_ZUGANG") 
        / NULLIF(LEAD(SUM(T1."FERTIGUNG_ABGANG")) OVER (PARTITION BY YEAR(T1."DATUM") ORDER BY MONTH(T1."DATUM")), 0),
        2
    ) AS "Cobertura"
FROM "BEAS_MRP_PLANUNG" T0
INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
WHERE T0."NR" = 26 
    AND T1."ItemCode" = '01DBC00100083'
GROUP BY YEAR(T1."DATUM"), MONTH(T1."DATUM"), TO_VARCHAR(T1."DATUM", 'MM'), T1."ItemCode"
ORDER BY "Año" ASC, MONTH(T1."DATUM") ASC;

-- *******************************************************************************************************************************
-- Inventario inicial solo la primera posicion del mes y año

WITH RankedInventories AS (
    SELECT 
        YEAR(T1."DATUM") AS "Año",
        MONTH(T1."DATUM") AS "MesNum",
        CASE MONTH(T1."DATUM")
            WHEN 1 THEN 'Enero'
            WHEN 2 THEN 'Febrero'
            WHEN 3 THEN 'Marzo'
            WHEN 4 THEN 'Abril'
            WHEN 5 THEN 'Mayo'
            WHEN 6 THEN 'Junio'
            WHEN 7 THEN 'Julio'
            WHEN 8 THEN 'Agosto'
            WHEN 9 THEN 'Septiembre'
            WHEN 10 THEN 'Octubre'
            WHEN 11 THEN 'Noviembre'
            WHEN 12 THEN 'Diciembre'
        END AS "Mes",
        T1."ItemCode" AS "Cod del Articulo",
        T2."ItemName" AS "Nombre del Articulo",
        T1."OnHand" AS "Inventario Inicial",
        T3."MinStock" AS "Politica",
        T1."BESTELLUNG_ZUGANG" AS "Compra",
        T1."FERTIGUNG_ABGANG" AS "Consumo",
        T1."OnHand" + T1."BESTELLUNG_ZUGANG" - T3."MinStock" - T1."BESTELLUNG_ZUGANG" AS "Inventario Final",
        ROW_NUMBER() OVER (PARTITION BY YEAR(T1."DATUM"), MONTH(T1."DATUM"), T1."ItemCode" ORDER BY T1."DATUM" ASC) AS RN
    FROM "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
    WHERE T0."NR" = 26 
        AND T1."ItemCode" = '01DBC00100083'
),
GroupedData AS (
    SELECT 
        "Año",
        "Mes",
         "MesNum",
        "Cod del Articulo",
        --"Nombre del Articulo",
        SUM("Compra") AS "Compra",
        SUM("Consumo") AS "Consumo",
        MAX("Politica") AS "Politica"
    FROM RankedInventories
    GROUP BY "Año", "Mes", "MesNum", "Cod del Articulo", "Politica"
)
SELECT 
    GD."Año",
    GD."Mes",
    --GD."MesNum",
    GD."Cod del Articulo",
    --GD."Nombre del Articulo",
    RI."Inventario Inicial",
    GD."Politica",
    GD."Compra",
    GD."Consumo",
    RI."Inventario Final",
    ROUND(
        RI."Inventario Final" 
        / NULLIF(LEAD(GD."Consumo") OVER (PARTITION BY GD."Año" ORDER BY GD."Mes"), 0),
        2
    ) AS "Cobertura"
FROM GroupedData GD
JOIN (
    SELECT 
        "Año",
        "Mes",
        "Cod del Articulo",
        "Inventario Inicial",
        "Inventario Final"
    FROM RankedInventories
    WHERE RN = 1
) RI ON GD."Año" = RI."Año" AND GD."Mes" = RI."Mes" AND GD."Cod del Articulo" = RI."Cod del Articulo"
ORDER BY GD."Año" ASC, GD."MesNum" ASC;




-- *******************************************************************************************************************
-- Compra-> Reporte MRP = Planificación de Requerimientos de Materiales
WITH RankedInventories AS (
    SELECT 
        YEAR(T1."DATUM") AS "Año",
        MONTH(T1."DATUM") AS "MesNum",
        CASE MONTH(T1."DATUM")
            WHEN 1 THEN 'Enero'
            WHEN 2 THEN 'Febrero'
            WHEN 3 THEN 'Marzo'
            WHEN 4 THEN 'Abril'
            WHEN 5 THEN 'Mayo'
            WHEN 6 THEN 'Junio'
            WHEN 7 THEN 'Julio'
            WHEN 8 THEN 'Agosto'
            WHEN 9 THEN 'Septiembre'
            WHEN 10 THEN 'Octubre'
            WHEN 11 THEN 'Noviembre'
            WHEN 12 THEN 'Diciembre'
        END AS "Mes",
        T1."ItemCode" AS "Cod del Articulo",
        T2."ItemName" AS "Nombre del Articulo",
        T1."OnHand" AS "Inventario Inicial",
        T3."MinStock" AS "Politica",
        T1."BESTELLUNG_ZUGANG" AS "Compra",
        T1."FERTIGUNG_ABGANG" AS "Consumo",
        ROW_NUMBER() OVER (PARTITION BY YEAR(T1."DATUM"), MONTH(T1."DATUM"), T1."ItemCode" ORDER BY T1."DATUM" ASC) AS RN
    FROM "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
    WHERE T0."NR" = 26 
        --AND T1."ItemCode" = '01DBC00100083'
),
FirstInventories AS (
    SELECT 
        "Año",
        "Mes",
        "MesNum",
        "Cod del Articulo",
        "Nombre del Articulo",
        "Inventario Inicial",
        "Politica",
        "Compra",
        "Consumo",
       ("Inventario Inicial" + "Compra" - "Politica" - "Consumo") AS "Inventario Final"  -- Calcula el inventario final correctamente
    FROM RankedInventories
    WHERE RN = 1
),
GroupedData AS (
    SELECT 
        "Año",
        "Mes",
         "MesNum",
        "Cod del Articulo",
         "Nombre del Articulo",
        SUM("Compra") AS "Compra",
        SUM("Consumo") AS "Consumo",
        MAX("Politica") AS "Politica"
    FROM RankedInventories
    GROUP BY "Año", "Mes", "MesNum", "Cod del Articulo","Nombre del Articulo","Politica"
),
NextMonthConsumptions AS (
    SELECT
        "Año",
        "Mes",
        "Cod del Articulo",
        LEAD(SUM("Consumo")) OVER (PARTITION BY "Año" ORDER BY "MesNum") AS "NextMonthConsumption"
    FROM GroupedData
    GROUP BY "Año", "Mes", "Cod del Articulo", "MesNum"
)
SELECT 
    GD."Año",
    GD."Mes",
    GD."Cod del Articulo",
    GD."Nombre del Articulo",
    FI."Inventario Inicial",
    GD."Politica",
    GD."Compra",
    GD."Consumo",
    FI."Inventario Final",
    ROUND(
        FI."Inventario Final" 
        / NULLIF(NMC."NextMonthConsumption", 0),
        2
    ) AS "Cobertura"
FROM GroupedData GD
JOIN FirstInventories FI ON GD."Año" = FI."Año" AND GD."Mes" = FI."Mes" AND GD."Cod del Articulo" = FI."Cod del Articulo"
LEFT JOIN NextMonthConsumptions NMC ON GD."Año" = NMC."Año" AND GD."Mes" = NMC."Mes" AND GD."Cod del Articulo" = NMC."Cod del Articulo"
ORDER BY GD."Año" ASC, GD."MesNum" ASC;
-- ***************************************************************************************************************************************************************

-- Nueva actualizacion

WITH RankedInventories AS (
    SELECT 
        YEAR(T1."DATUM") AS "Año",
        MONTH(T1."DATUM") AS "MesNum",
        CASE MONTH(T1."DATUM")
            WHEN 1 THEN 'Enero'
            WHEN 2 THEN 'Febrero'
            WHEN 3 THEN 'Marzo'
            WHEN 4 THEN 'Abril'
            WHEN 5 THEN 'Mayo'
            WHEN 6 THEN 'Junio'
            WHEN 7 THEN 'Julio'
            WHEN 8 THEN 'Agosto'
            WHEN 9 THEN 'Septiembre'
            WHEN 10 THEN 'Octubre'
            WHEN 11 THEN 'Noviembre'
            WHEN 12 THEN 'Diciembre'
        END AS "Mes",
        T1."ItemCode" AS "Cod del Articulo",
        T2."ItemName" AS "Nombre del Articulo",
        T1."OnHand" AS "Inventario Inicial",
        T3."MinStock" AS "Politica",
        T1."BESTELLUNG_ZUGANG" AS "Compra",
        T1."FERTIGUNG_ABGANG" AS "Consumo",
        ROW_NUMBER() OVER (PARTITION BY YEAR(T1."DATUM"), MONTH(T1."DATUM"), T1."ItemCode" ORDER BY T1."DATUM" ASC) AS RN
    FROM "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
    WHERE T0."NR" = 26 
        AND T1."ItemCode" = '01DBC00100083'
),
FirstInventories AS (
    SELECT 
        "Año",
        "Mes",
        "MesNum",
        "Cod del Articulo",
        "Nombre del Articulo",
        "Inventario Inicial",
        "Politica",
        "Compra",
        "Consumo",
       ("Inventario Inicial" + "Compra" - "Politica" - "Consumo") AS "Inventario Final"  -- Calcula el inventario final correctamente
    FROM RankedInventories
    WHERE RN = 1
),
GroupedData AS (
    SELECT 
        "Año",
        "Mes",
         "MesNum",
        "Cod del Articulo",
         "Nombre del Articulo",
        SUM("Compra") AS "Compra",
        SUM("Consumo") AS "Consumo",
        MAX("Politica") AS "Politica",
        -- Calcula inventario final sin política
        SUM("Inventario Inicial") + SUM("Compra") - SUM("Consumo") AS "Inventario Final Sin Politica"
    FROM RankedInventories
    GROUP BY "Año", "Mes", "MesNum", "Cod del Articulo","Nombre del Articulo","Politica"
),
NextMonthConsumptions AS (
    SELECT
        "Año",
        "Mes",
        "Cod del Articulo",
        LEAD(SUM("Consumo")) OVER (PARTITION BY "Año" ORDER BY "MesNum") AS "NextMonthConsumption"
    FROM GroupedData
    GROUP BY "Año", "Mes", "Cod del Articulo", "MesNum"
)
SELECT 
    GD."Año",
    GD."Mes",
    GD."Cod del Articulo",
    GD."Nombre del Articulo",
    FI."Inventario Inicial",
    GD."Politica",
    GD."Compra",
    GD."Consumo",
    -- Utiliza el inventario final sin política de GroupedData para la siguiente posición
    CASE 
        WHEN RN = 1 THEN FI."Inventario Final"
        ELSE GD."Inventario Final Sin Politica"
    END AS "Inventario_Final",
    ROUND(
        CASE 
            WHEN RN = 1 THEN FI."Inventario Final" 
            ELSE GD."Inventario Final Sin Politica"
        END 
        / NULLIF(NMC."NextMonthConsumption", 0),
        2
    ) AS "Cobertura"
FROM GroupedData GD
INNER JOIN FirstInventories FI ON GD."Año" = FI."Año" AND GD."Mes" = FI."Mes" AND GD."Cod del Articulo" = FI."Cod del Articulo"
LEFT JOIN NextMonthConsumptions NMC ON GD."Año" = NMC."Año" AND GD."Mes" = NMC."Mes" AND GD."Cod del Articulo" = NMC."Cod del Articulo"
ORDER BY GD."Año" ASC, GD."MesNum" ASC;



-- *******************
WITH RankedInventories AS (
    SELECT 
        YEAR(T1."DATUM") AS "Año",
        MONTH(T1."DATUM") AS "MesNum",
        CASE MONTH(T1."DATUM")
            WHEN 1 THEN 'Enero'
            WHEN 2 THEN 'Febrero'
            WHEN 3 THEN 'Marzo'
            WHEN 4 THEN 'Abril'
            WHEN 5 THEN 'Mayo'
            WHEN 6 THEN 'Junio'
            WHEN 7 THEN 'Julio'
            WHEN 8 THEN 'Agosto'
            WHEN 9 THEN 'Septiembre'
            WHEN 10 THEN 'Octubre'
            WHEN 11 THEN 'Noviembre'
            WHEN 12 THEN 'Diciembre'
        END AS "Mes",
        T1."ItemCode" AS "Cod del Articulo",
        T2."ItemName" AS "Nombre del Articulo",
        T1."OnHand" AS "Inventario Inicial",
        T3."MinStock" AS "Politica",
        T1."BESTELLUNG_ZUGANG" AS "Compra",
        T1."FERTIGUNG_ABGANG" AS "Consumo",
        ROW_NUMBER() OVER (PARTITION BY YEAR(T1."DATUM"), MONTH(T1."DATUM"), T1."ItemCode" ORDER BY T1."DATUM" ASC) AS RN
    FROM "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
    WHERE T0."NR" = 26 
        AND T1."ItemCode" = '01DBC00100083'
),
FirstInventories AS (
    SELECT 
        "Año",
        "Mes",
        "MesNum",
        "Cod del Articulo",
        "Nombre del Articulo",
        "Inventario Inicial",
        "Politica",
        "Compra",
        "Consumo",
       ("Inventario Inicial" + "Compra" - "Politica" - "Consumo") AS "Inventario Final",  
        RN
    FROM RankedInventories
    WHERE RN = 1
),
GroupedData AS (
    SELECT 
        "Año",
        "Mes",
         "MesNum",
        "Cod del Articulo",
         "Nombre del Articulo",
        SUM("Compra") AS "Compra",
        SUM("Consumo") AS "Consumo",
        MAX("Politica") AS "Politica",
        -- Calcula inventario final sin política
        -- SUM("OnHand") + SUM("BESTELLUNG_ZUGANG") - SUM("FERTIGUNG_ABGANG") AS "Inventario Final Sin Politica",
         SUM("Inventario Inicial") + SUM("Compra") - SUM("Consumo") AS "Inventario Final Sin Politica",
        ROW_NUMBER() OVER (PARTITION BY "Año", "Cod del Articulo" ORDER BY "MesNum") AS RN_GD
    FROM RankedInventories
    GROUP BY "Año", "Mes", "MesNum", "Cod del Articulo","Nombre del Articulo","Politica"
),
NextMonthConsumptions AS (
    SELECT
        "Año",
        "Mes",
        "Cod del Articulo",
        LEAD(SUM("Consumo")) OVER (PARTITION BY "Año" ORDER BY "MesNum") AS "NextMonthConsumption"
    FROM GroupedData
    GROUP BY "Año", "Mes", "Cod del Articulo", "MesNum"
)
SELECT 
    GD."Año",
    GD."Mes",
    GD."Cod del Articulo",
    GD."Nombre del Articulo",
    FI."Inventario Inicial",
    GD."Politica",
    GD."Compra",
    GD."Consumo",
    -- Alternar entre inventario final con política y sin política
    CASE 
        WHEN MOD(GD.RN_GD, 2) = 1 THEN FI."Inventario Final"
        ELSE GD."Inventario Final Sin Politica"
    END AS "Inventario_Final",
    ROUND(
        CASE 
            WHEN MOD(GD.RN_GD, 2) = 1 THEN FI."Inventario Final" 
            ELSE GD."Inventario Final Sin Politica"
        END 
        / NULLIF(NMC."NextMonthConsumption", 0),
        2
    ) AS "Cobertura"
FROM GroupedData GD
JOIN FirstInventories FI ON GD."Año" = FI."Año" AND GD."Mes" = FI."Mes" AND GD."Cod del Articulo" = FI."Cod del Articulo"
LEFT JOIN NextMonthConsumptions NMC ON GD."Año" = NMC."Año" AND GD."Mes" = NMC."Mes" AND GD."Cod del Articulo" = NMC."Cod del Articulo"
ORDER BY GD."Año" ASC, GD."MesNum" ASC;




-- *********************************************************************************************************************************************

WITH RankedInventories AS (
    SELECT 
        YEAR(T1."DATUM") AS "Año",
        MONTH(T1."DATUM") AS "MesNum",
        CASE MONTH(T1."DATUM")
            WHEN 1 THEN 'Enero'
            WHEN 2 THEN 'Febrero'
            WHEN 3 THEN 'Marzo'
            WHEN 4 THEN 'Abril'
            WHEN 5 THEN 'Mayo'
            WHEN 6 THEN 'Junio'
            WHEN 7 THEN 'Julio'
            WHEN 8 THEN 'Agosto'
            WHEN 9 THEN 'Septiembre'
            WHEN 10 THEN 'Octubre'
            WHEN 11 THEN 'Noviembre'
            WHEN 12 THEN 'Diciembre'
        END AS "Mes",
        T1."ItemCode" AS "Cod del Articulo",
        T2."ItemName" AS "Nombre del Articulo",
        T1."OnHand" AS "Inventario Inicial",
        T3."MinStock" AS "Politica",
        T1."BESTELLUNG_ZUGANG" AS "Compra",
        T1."FERTIGUNG_ABGANG" AS "Consumo",
        ROW_NUMBER() OVER (PARTITION BY YEAR(T1."DATUM"), MONTH(T1."DATUM"), T1."ItemCode" ORDER BY T1."DATUM" ASC) AS RN
    FROM "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
    WHERE T0."NR" = 26 
        AND T1."ItemCode" = '01DBC00100083'
),
GroupedData AS (
    SELECT 
        "Año",
        "Mes",
         "MesNum",
        "Cod del Articulo",
         "Nombre del Articulo",
        SUM("Compra") AS "Compra",
        SUM("Consumo") AS "Consumo",
        MAX("Politica") AS "Politica",
        -- Calcula inventario final con política (INVENTARIO FINAL + COMPRA - POLITICA - CONSUMO)
        SUM("Inventario Inicial") + SUM("Compra") - SUM("Politica") - SUM("Consumo") AS "Inventario Final Con Politica",
        
        -- Calcula inventario final sin política
        SUM("Inventario Inicial") + SUM("Compra") - SUM("Consumo") AS "Inventario Final Sin Politica",
        ROW_NUMBER() OVER (PARTITION BY "Año", "Cod del Articulo" ORDER BY "MesNum") AS RN_GD
    FROM RankedInventories
    GROUP BY "Año", "Mes", "MesNum", "Cod del Articulo","Nombre del Articulo","Politica"
),
NextMonthConsumptions AS (
    SELECT
        "Año",
        "Mes",
        "Cod del Articulo",
        LEAD(SUM("Consumo")) OVER (PARTITION BY "Año" ORDER BY "MesNum") AS "NextMonthConsumption"
    FROM GroupedData
    GROUP BY "Año", "Mes", "Cod del Articulo", "MesNum"
)
SELECT 
    GD."Año",
    GD."Mes",
    GD."Cod del Articulo",
    GD."Nombre del Articulo",
    MIN(GD."Inventario Final Con Politica") AS "Inventario Inicial",
    GD."Politica",
    GD."Compra",
    GD."Consumo",
    -- Alternar entre inventario final con política y sin política
    CASE 
        WHEN GD.RN_GD = 1 THEN GD."Inventario Final Con Politica"
        ELSE GD."Inventario Final Sin Politica"
    END AS "Inventario_Final",
    ROUND(
        CASE 
            WHEN GD.RN_GD = 1 THEN GD."Inventario Final Con Politica" 
            ELSE GD."Inventario Final Sin Politica"
        END 
        / NULLIF(NMC."NextMonthConsumption", 0),
        2
    ) AS "Cobertura"
FROM GroupedData GD
LEFT JOIN NextMonthConsumptions NMC ON GD."Año" = NMC."Año" AND GD."Mes" = NMC."Mes" AND GD."Cod del Articulo" = NMC."Cod del Articulo"
ORDER BY GD."Año" ASC, GD."MesNum" ASC;



/* ACTUALIZACIÓN DE MRP 27-03-2025 */
WITH InventarioMensual AS (
    SELECT 
        YEAR(T1."DATUM") AS "Año",
        MONTH(T1."DATUM") AS "MesNum",
        CASE MONTH(T1."DATUM")
            WHEN 1 THEN 'Enero'
            WHEN 2 THEN 'Febrero'
            WHEN 3 THEN 'Marzo'
            WHEN 4 THEN 'Abril'
            WHEN 5 THEN 'Mayo'
            WHEN 6 THEN 'Junio'
            WHEN 7 THEN 'Julio'
            WHEN 8 THEN 'Agosto'
            WHEN 9 THEN 'Septiembre'
            WHEN 10 THEN 'Octubre'
            WHEN 11 THEN 'Noviembre'
            WHEN 12 THEN 'Diciembre'
        END AS "Mes",
        T1."ItemCode" AS "Cod del Articulo",
        T2."ItemName" AS "Nombre del Articulo",
        SUM(T1."OnHand") AS "Inventario Inicial",
        MAX(T3."MinStock") AS "Politica",
        SUM(T1."BESTELLUNG_ZUGANG") AS "Compra",
        SUM(T1."FERTIGUNG_ABGANG") AS "Consumo",
        ROW_NUMBER() OVER (ORDER BY YEAR(T1."DATUM"), MONTH(T1."DATUM")) AS "OrdenMes"
        --ROW_NUMBER() OVER (PARTITION BY YEAR(T1."DATUM"), MONTH(T1."DATUM"), T1."ItemCode" ORDER BY T1."DATUM" ASC) AS RN"OrdenMes"


    FROM "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
    WHERE T0."NR" = 26 
        AND T1."ItemCode" = '01DBC00100083'
    GROUP BY YEAR(T1."DATUM"), MONTH(T1."DATUM"), T1."ItemCode", T2."ItemName"
)
SELECT 
    "Año",
    "MesNum",
    "Mes",
    "Cod del Articulo",
    "Nombre del Articulo",
    "Inventario Inicial",
    "Politica",
    "Compra",
    "Consumo",
    "OrdenMes",
    CASE 
        WHEN "OrdenMes" = 1 THEN "Inventario Inicial" + "Compra" - "Politica" - "Consumo"
        ELSE ("Inventario Inicial" + "Compra") - ("Consumo")
    END AS "Inventario Final"
FROM InventarioMensual
ORDER BY "Año" ASC, "MesNum" ASC;


/* CUANDO ES POR ARTICULO SALE BIEN  */
WITH InventarioMensual AS (
    SELECT 
        YEAR(T1."DATUM") AS "Año",
        MONTH(T1."DATUM") AS "MesNum",
        CASE MONTH(T1."DATUM")
            WHEN 1 THEN 'Enero'
            WHEN 2 THEN 'Febrero'
            WHEN 3 THEN 'Marzo'
            WHEN 4 THEN 'Abril'
            WHEN 5 THEN 'Mayo'
            WHEN 6 THEN 'Junio'
            WHEN 7 THEN 'Julio'
            WHEN 8 THEN 'Agosto'
            WHEN 9 THEN 'Septiembre'
            WHEN 10 THEN 'Octubre'
            WHEN 11 THEN 'Noviembre'
            WHEN 12 THEN 'Diciembre'
        END AS "Mes",
        T1."ItemCode" AS "Cod del Articulo",
        T2."ItemName" AS "Nombre del Articulo",
        SUM(T1."OnHand") AS "Inventario Inicial",
        MAX(T3."MinStock") AS "Politica",
        SUM(T1."BESTELLUNG_ZUGANG") AS "Compra",
        SUM(T1."FERTIGUNG_ABGANG") AS "Consumo",
        ROW_NUMBER() OVER (ORDER BY YEAR(T1."DATUM"), MONTH(T1."DATUM"),T1."ItemCode" ) AS "OrdenMes"
       
    FROM "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
    WHERE T0."NR" = 26 
        AND T1."ItemCode" = '01DBC00100083'
    GROUP BY YEAR(T1."DATUM"), MONTH(T1."DATUM"), T1."ItemCode", T2."ItemName"
),
ConsumoSiguienteMes AS (
    SELECT 
        "Año",
        "MesNum",
        LEAD("Consumo") OVER (ORDER BY "Año", "MesNum") AS "ConsumoSiguienteMes"
    FROM InventarioMensual
)
SELECT 
    IM."Año",
    IM."MesNum",
    IM."Mes",
    IM."Cod del Articulo",
    IM."Nombre del Articulo",
    IM."Inventario Inicial",
    IM."Politica",
    IM."Compra",
    IM."Consumo",
    IM."OrdenMes",
    CASE 
        WHEN IM."OrdenMes" = 1 THEN IM."Inventario Inicial" + IM."Compra" - IM."Politica" - IM."Consumo"
        ELSE (IM."Inventario Inicial" + IM."Compra") - (IM."Consumo")
    END AS "Inventario Final",
    ROUND(
        CASE 
            WHEN IM."OrdenMes" = 1 THEN IM."Inventario Inicial" + IM."Compra" - IM."Politica" - IM."Consumo"
            ELSE (IM."Inventario Inicial" + IM."Compra") - (IM."Consumo")
        END 
        / NULLIF(CSM."ConsumoSiguienteMes", 0),
        2
    ) AS "Cobertura"
FROM InventarioMensual IM
LEFT JOIN ConsumoSiguienteMes CSM ON IM."Año" = CSM."Año" AND IM."MesNum" = CSM."MesNum"
ORDER BY IM."Año" ASC, IM."MesNum";

/* ASI QUEDO CON LOS ULTIMOS CAMBIOS */
WITH InventarioMensual AS (
    SELECT 
        YEAR(T1."DATUM") AS "Año",
        MONTH(T1."DATUM") AS "MesNum",
        CASE MONTH(T1."DATUM")
            WHEN 1 THEN 'Enero'
            WHEN 2 THEN 'Febrero'
            WHEN 3 THEN 'Marzo'
            WHEN 4 THEN 'Abril'
            WHEN 5 THEN 'Mayo'
            WHEN 6 THEN 'Junio'
            WHEN 7 THEN 'Julio'
            WHEN 8 THEN 'Agosto'
            WHEN 9 THEN 'Septiembre'
            WHEN 10 THEN 'Octubre'
            WHEN 11 THEN 'Noviembre'
            WHEN 12 THEN 'Diciembre'
        END AS "Mes",
        T1."ItemCode" AS "Cod del Articulo",
        T2."ItemName" AS "Nombre del Articulo",
        SUM(T1."OnHand") AS "Inventario Inicial",
        MAX(T3."MinStock") AS "Politica",
        SUM(T1."BESTELLUNG_ZUGANG") AS "Compra",
        SUM(T1."FERTIGUNG_ABGANG") AS "Consumo",
        ROW_NUMBER() OVER (PARTITION BY T1."ItemCode" ORDER BY YEAR(T1."DATUM"), MONTH(T1."DATUM")) AS "OrdenMes"
       
    FROM "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
    WHERE T0."NR" = 26
     --AND T1."ItemCode" = '01DBC00100083' 
    GROUP BY YEAR(T1."DATUM"), MONTH(T1."DATUM"), T1."ItemCode", T2."ItemName"
),
ConsumoSiguienteMes AS (
    SELECT 
        "Año",
        "MesNum",
        "Cod del Articulo",
        LEAD("Consumo") OVER (PARTITION BY "Cod del Articulo" ORDER BY "Año", "MesNum") AS "ConsumoSiguienteMes"
    FROM InventarioMensual
)
SELECT 
    IM."Año",
    IM."MesNum",
    IM."Mes",
    IM."Cod del Articulo",
    IM."Nombre del Articulo",
    IM."Inventario Inicial",
    IM."Politica",
    IM."Compra",
    IM."Consumo",
    IM."OrdenMes",
    CASE 
        WHEN IM."OrdenMes" = 1 THEN IM."Inventario Inicial" + IM."Compra" - IM."Politica" - IM."Consumo"
        ELSE (IM."Inventario Inicial" + IM."Compra") - (IM."Consumo")
    END AS "Inventario Final",
    CASE 
        WHEN CSM."ConsumoSiguienteMes" IS NULL OR CSM."ConsumoSiguienteMes" = 0 THEN NULL
        ELSE ROUND(
            CASE 
                WHEN IM."OrdenMes" = 1 THEN IM."Inventario Inicial" + IM."Compra" - IM."Politica" - IM."Consumo"
                ELSE (IM."Inventario Inicial" + IM."Compra") - (IM."Consumo")
            END 
            / CSM."ConsumoSiguienteMes",
            2
        )
    END AS "Cobertura"
FROM InventarioMensual IM
LEFT JOIN ConsumoSiguienteMes CSM ON IM."Año" = CSM."Año" AND IM."MesNum" = CSM."MesNum" AND IM."Cod del Articulo" = CSM."Cod del Articulo"
ORDER BY IM."Año" ASC, IM."MesNum", IM."Cod del Articulo";



inventario inicial debe ser la primera posicion de cd mes y año no la sumatoria del mes
hago la formula para el inventario final = INVENTARIO INICIAL OSEA PRIMERA POSICION del cd mes y año + COMPRA - POLITICA - CONSUMO 

 las demas siguente columna deberia ser inventario inicial deb ser igual al inverntario final y add en la columnd del otro mes   hago la formula para el inventario final = INVENTARIO INICIAL  + COMPRA - CONSUMO 




WITH InventarioMensual AS (
    SELECT 
        YEAR(T1."DATUM") AS "Año",
        MONTH(T1."DATUM") AS "MesNum",
        CASE MONTH(T1."DATUM")
            WHEN 1 THEN 'Enero'
            WHEN 2 THEN 'Febrero'
            WHEN 3 THEN 'Marzo'
            WHEN 4 THEN 'Abril'
            WHEN 5 THEN 'Mayo'
            WHEN 6 THEN 'Junio'
            WHEN 7 THEN 'Julio'
            WHEN 8 THEN 'Agosto'
            WHEN 9 THEN 'Septiembre'
            WHEN 10 THEN 'Octubre'
            WHEN 11 THEN 'Noviembre'
            WHEN 12 THEN 'Diciembre'
        END AS "Mes",
        T1."ItemCode" AS "Cod del Articulo",
        T2."ItemName" AS "Nombre del Articulo",
        T1."OnHand" AS "Inventario Inicial",
        MAX(T3."MinStock") AS "Politica",
        SUM(T1."BESTELLUNG_ZUGANG") AS "Compra",
        SUM(T1."FERTIGUNG_ABGANG") AS "Consumo",
        ROW_NUMBER() OVER (PARTITION BY T1."ItemCode" ORDER BY YEAR(T1."DATUM"), MONTH(T1."DATUM")) AS "OrdenMes"
       
    FROM "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
    WHERE T0."NR" = 26
     AND T1."ItemCode" = '01DBC00100083'
    GROUP BY YEAR(T1."DATUM"), MONTH(T1."DATUM"), T1."ItemCode", T2."ItemName", T1."OnHand"
)

SELECT 
    IM."Año",
    IM."MesNum",
    IM."Mes",
    IM."Cod del Articulo",
    IM."Nombre del Articulo",
    IM."Inventario Inicial",
    IM."Politica",
    IM."Compra",
    IM."Consumo",
    IM."OrdenMes",
    CASE 
        WHEN IM."OrdenMes" = 1 THEN IM."Inventario Inicial" + IM."Compra" - IM."Politica" - IM."Consumo"
        ELSE (IM."Inventario Inicial" + IM."Compra") - (IM."Consumo")
    END AS "Inventario Final"
    

FROM InventarioMensual IM
ORDER BY IM."Año" ASC, IM."MesNum", IM."Cod del Articulo";

-- *****************************************************************************

-- *******
SELECT 
T1."DATUM" AS "Fecha",
T1."ItemCode" AS "Cod del Articulo",
T1."OnHand" AS "Inventario Inicial",
T3."MinStock" AS "Politica",
T1."BESTELLUNG_ZUGANG" AS "Compra",
T1."FERTIGUNG_ABGANG" AS "Consumo",
ROW_NUMBER() OVER (PARTITION BY YEAR(T1."DATUM"), MONTH(T1."DATUM") ORDER BY T1."DATUM" ASC) AS RowNum

FROM "BEAS_MRP_PLANUNG" T0
INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
WHERE T0."NR" = 26 AND T1."ItemCode" = '01DBC00100083'
ORDER BY T1."DATUM";
***
SELECT
        T1."DATUM",
        T1."ItemCode",
        T1."OnHand",
        YEAR(T1."DATUM") AS Anio,
        MONTH(T1."DATUM") AS Mes,
        ROW_NUMBER() OVER (PARTITION BY YEAR(T1."DATUM"), MONTH(T1."DATUM") ORDER BY T1."DATUM" ASC) AS RowNum
    FROM
        "BEAS_MRP_DETAIL" T1
    WHERE
        T1."NR" = 26 AND T1."ItemCode" = '01DBC00100083'
ORDER BY YEAR(T1."DATUM"), MONTH(T1."DATUM");



-- **************************************NUEVA IMPLEMENTACION EL MRP**********************************************************
WITH datos_iniciales AS (
    SELECT 
        T1."DATUM",
        YEAR(T1."DATUM") AS Anio,
        MONTH(T1."DATUM") AS Mes,
        T1."ItemCode",
        T2."ItemName",
        T1."OnHand" AS "Inventario Inicial", --Inventario Inicial
        ROW_NUMBER() OVER (PARTITION BY YEAR(T1."DATUM"), MONTH(T1."DATUM") ORDER BY T1."DATUM" ASC) AS RowNum

     FROM "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
    WHERE T0."NR" = 26 
        AND T1."ItemCode" = '01DBC00100083'
),
politica_maxima AS (
    SELECT 
        "ItemCode",
        MAX("MinStock") AS "Politica"
    FROM 
        OITW
    GROUP BY 
        "ItemCode"
),
compras_por_mes AS (
    SELECT 
        YEAR(T1."DATUM") AS Anio,
        MONTH(T1."DATUM") AS Mes,
        SUM(T1."BESTELLUNG_ZUGANG") AS "Compra"
    FROM 
        "BEAS_MRP_DETAIL" T1
    WHERE 
        T1."ItemCode" = '01DBC00100083'
    GROUP BY 
        YEAR(T1."DATUM"), MONTH(T1."DATUM")
),
consumo_por_mes AS (
    SELECT 
        YEAR(T1."DATUM") AS Anio,
        MONTH(T1."DATUM") AS Mes,
        SUM(T1."FERTIGUNG_ABGANG") AS "Consumo"
    FROM 
        "BEAS_MRP_DETAIL" T1
    WHERE 
        T1."ItemCode" = '01DBC00100083'
    GROUP BY 
        YEAR(T1."DATUM"), MONTH(T1."DATUM")
)
SELECT 
    di.*,
    pm."Politica",
    cp."Compra",
    cpm."Consumo"
FROM datos_iniciales di
LEFT JOIN politica_maxima pm ON di."ItemCode" = pm."ItemCode"
LEFT JOIN compras_por_mes cp ON di.Anio = cp.Anio AND di.Mes = cp.Mes
LEFT JOIN consumo_por_mes cpm ON di.Anio = cpm.Anio AND di.Mes = cpm.Mes
WHERE di.RowNum = 1
ORDER BY di.Anio, di.Mes;




/* asi es MRP ULTIMA VERSION */

WITH datos_iniciales AS (
    SELECT 
        T1."DATUM" AS "Fecha",
        YEAR(T1."DATUM") AS Anio,
        MONTH(T1."DATUM") AS Mes,
        T1."ItemCode",
        T1."OnHand" AS "Inventario_Inicial",
        ROW_NUMBER() OVER (PARTITION BY T1."ItemCode", YEAR(T1."DATUM") ORDER BY T1."DATUM" ASC) AS "OrdenMes"

    FROM "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
    WHERE T0."NR" = 26 AND T1."ItemCode" = '01DBC00100083'
),
politica_maxima AS (
    SELECT 
        "ItemCode",
        MAX("MinStock") AS "Politica"
    FROM 
        OITW
    GROUP BY 
        "ItemCode"
),
compras_por_mes AS (
    SELECT 
        YEAR(T1."DATUM") AS Anio,
        MONTH(T1."DATUM") AS Mes,
        SUM(T1."BESTELLUNG_ZUGANG") AS "Compra"
    FROM 
        "BEAS_MRP_DETAIL" T1
    WHERE 
        T1."ItemCode" = '01DBC00100083'
    GROUP BY 
        YEAR(T1."DATUM"), MONTH(T1."DATUM")
),
consumo_por_mes AS (
    SELECT 
        YEAR(T1."DATUM") AS Anio,
        MONTH(T1."DATUM") AS Mes,
        SUM(T1."FERTIGUNG_ABGANG") AS "Consumo"
    FROM 
        "BEAS_MRP_DETAIL" T1
    WHERE 
        T1."ItemCode" = '01DBC00100083'
    GROUP BY 
        YEAR(T1."DATUM"), MONTH(T1."DATUM")
)
SELECT 
    di."Fecha",
    di."ItemCode",
    di."OrdenMes",
    CASE 
        WHEN di."OrdenMes" = 1 THEN di."Inventario_Inicial"
        ELSE 0
    END AS "Inventario Inicial",
    pm."Politica",
    cp."Compra",
    cpm."Consumo",
     CASE 
        WHEN di."OrdenMes" = 1 THEN (di."Inventario_Inicial" + cp."Compra") - (pm."Politica" - cpm."Consumo")
    END AS "Inventario Final"
    
FROM datos_iniciales di
LEFT JOIN politica_maxima pm ON di."ItemCode" = pm."ItemCode"
LEFT JOIN compras_por_mes cp ON di.Anio = cp.Anio AND di.Mes = cp.Mes
LEFT JOIN consumo_por_mes cpm ON di.Anio = cpm.Anio AND di.Mes = cpm.Mes
ORDER BY di.Anio, di.Mes;


/* GROUP BY di."Fecha", di."ItemCode", di."OrdenMes", di."Inventario_Inicial",
pm."Politica",cp."Compra",cpm."Consumo", di.Anio, di.Mes */






-- ya casi

WITH datos_iniciales AS (
    SELECT 
        T1."DATUM" AS "Fecha",
        YEAR(T1."DATUM") AS Anio,
        MONTH(T1."DATUM") AS Mes,
        T1."ItemCode",
        T1."OnHand" AS "Inventario_Inicial",
        T1."BESTELLUNG_ZUGANG" AS "Compra",
        T1."FERTIGUNG_ABGANG" AS "Consumo",
        T3."MinStock" AS "Politica",
        ROW_NUMBER() OVER (PARTITION BY YEAR(T1."DATUM"), MONTH(T1."DATUM"), T1."ItemCode" ORDER BY T1."DATUM" ASC) AS "OrdenMes"
    FROM "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
    WHERE T0."NR" = 26 AND T1."ItemCode" = '01DBC00100083'
),
compras_por_mes AS (
    SELECT 
        YEAR(T1."DATUM") AS Anio,
        MONTH(T1."DATUM") AS Mes,
        SUM(T1."BESTELLUNG_ZUGANG") AS "Compra"
    FROM 
        "BEAS_MRP_DETAIL" T1
    WHERE 
        T1."ItemCode" = '01DBC00100083'
    GROUP BY 
        YEAR(T1."DATUM"), MONTH(T1."DATUM")
),
consumo_por_mes AS (
    SELECT 
        YEAR(T1."DATUM") AS Anio,
        MONTH(T1."DATUM") AS Mes,
        SUM(T1."FERTIGUNG_ABGANG") AS "Consumo"
    FROM 
        "BEAS_MRP_DETAIL" T1
    WHERE 
        T1."ItemCode" = '01DBC00100083'
    GROUP BY 
        YEAR(T1."DATUM"), MONTH(T1."DATUM")
),
inventario_inicial_mes AS (
    SELECT
        di.Anio,
        di.Mes,
        SUM(CASE WHEN di."OrdenMes" = 1 THEN di."Inventario_Inicial" ELSE 0 END) AS "Inventario_Inicial"
    FROM
        datos_iniciales di
    GROUP BY
        di.Anio, di.Mes
),
inventario_final_anterior AS (
    SELECT
        iim.Anio,
        iim.Mes,
        (iim."Inventario_Inicial" + SUM(cp."Compra")) - (MAX(di."Politica") + SUM(cpm."Consumo")) AS "PrimerInventarioFinal"
    FROM datos_iniciales di
    LEFT JOIN compras_por_mes cp ON di.Anio = cp.Anio AND di.Mes = cp.Mes
    LEFT JOIN consumo_por_mes cpm ON di.Anio = cpm.Anio AND di.Mes = cpm.Mes
    LEFT JOIN inventario_inicial_mes iim ON di.Anio = iim.Anio AND di.Mes = iim.Mes
    GROUP BY iim.Anio, iim.Mes, iim."Inventario_Inicial"
)
SELECT 
    di.Anio,
    di.Mes,
    di."ItemCode",
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY di.Anio, di.Mes) = 1 
        THEN iim."Inventario_Inicial"
        ELSE LAG(ifa."PrimerInventarioFinal", 1, 0) OVER (ORDER BY di.Anio, di.Mes)
    END AS "Inventario Inicial",
    MAX(di."Politica") AS "Politica",
    SUM(cp."Compra") AS "Compra",
    SUM(cpm."Consumo") AS "Consumo",
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY di.Anio, di.Mes) = 1 
        THEN (iim."Inventario_Inicial" + SUM(cp."Compra")) - (MAX(di."Politica") + SUM(cpm."Consumo"))
        ELSE (LAG(ifa."PrimerInventarioFinal", 1, 0) OVER (ORDER BY di.Anio, di.Mes) + SUM(cp."Compra")) - SUM(cpm."Consumo")
    END AS "Inventario Final"
FROM datos_iniciales di
LEFT JOIN compras_por_mes cp ON di.Anio = cp.Anio AND di.Mes = cp.Mes
LEFT JOIN consumo_por_mes cpm ON di.Anio = cpm.Anio AND di.Mes = cpm.Mes
LEFT JOIN inventario_inicial_mes iim ON di.Anio = iim.Anio AND di.Mes = iim.Mes
LEFT JOIN inventario_final_anterior ifa ON di.Anio = ifa.Anio AND di.Mes = ifa.Mes
GROUP BY di.Anio, di.Mes, iim."Inventario_Inicial", ifa."PrimerInventarioFinal", di."ItemCode"
ORDER BY di.Anio, di.Mes;


-- **************************************************************
WITH datos_iniciales AS (
    SELECT 
        T1."DATUM" AS "Fecha",
        YEAR(T1."DATUM") AS Anio,
        MONTH(T1."DATUM") AS Mes,
        T1."ItemCode",
        T1."OnHand" AS "Inventario_Inicial",
        --T1."BESTELLUNG_ZUGANG" AS "Compra",
        --T1."FERTIGUNG_ABGANG" AS "Consumo",
        T3."MinStock" AS "Politica",
        ROW_NUMBER() OVER (PARTITION BY YEAR(T1."DATUM"), MONTH(T1."DATUM"), T1."ItemCode" ORDER BY T1."DATUM" ASC) AS "OrdenMes"
    FROM "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
    WHERE T0."NR" = 26 AND T1."ItemCode" = '01DBC00100083'
),
compras_por_mes AS (
    SELECT 
        YEAR(T1."DATUM") AS Anio,
        MONTH(T1."DATUM") AS Mes,
        SUM(T1."BESTELLUNG_ZUGANG") AS "Compra"
    FROM 
        "BEAS_MRP_DETAIL" T1
    WHERE 
        T1."NR" = 26 AND T1."ItemCode" = '01DBC00100083'
    GROUP BY 
        YEAR(T1."DATUM"), MONTH(T1."DATUM")
),
consumo_por_mes AS (
    SELECT 
        YEAR(T1."DATUM") AS Anio,
        MONTH(T1."DATUM") AS Mes,
        SUM(T1."FERTIGUNG_ABGANG") AS "Consumo"
    FROM 
        "BEAS_MRP_DETAIL" T1
    WHERE 
        T1."NR" = 26 AND T1."ItemCode" = '01DBC00100083'
    GROUP BY 
        YEAR(T1."DATUM"), MONTH(T1."DATUM")
),
inventario_inicial_mes AS (
    SELECT
        di.Anio,
        di.Mes,
        SUM(CASE WHEN di."OrdenMes" = 1 THEN di."Inventario_Inicial" ELSE 0 END) AS "Inventario_Inicial"
    FROM
        datos_iniciales di
    GROUP BY
        di.Anio, di.Mes
),
inventario_final_anterior AS (
    SELECT
        iim.Anio,
        iim.Mes,
        (iim."Inventario_Inicial" + (cp."Compra")) - (MAX(di."Politica") + (cpm."Consumo")) AS "PrimerInventarioFinal"
    FROM datos_iniciales di
    LEFT JOIN compras_por_mes cp ON di.Anio = cp.Anio AND di.Mes = cp.Mes
    LEFT JOIN consumo_por_mes cpm ON di.Anio = cpm.Anio AND di.Mes = cpm.Mes
    LEFT JOIN inventario_inicial_mes iim ON di.Anio = iim.Anio AND di.Mes = iim.Mes
    GROUP BY iim.Anio, iim.Mes, iim."Inventario_Inicial", cp."Compra", cpm."Consumo"
)
SELECT 
    di.Anio,
    di.Mes,
    di."ItemCode",
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY di.Anio, di.Mes) = 1 
        THEN iim."Inventario_Inicial"
        ELSE LAG(ifa."PrimerInventarioFinal", 1, 0) OVER (ORDER BY di.Anio, di.Mes)
    END AS "Inventario Inicial",
    MAX(di."Politica") AS "Politica",
    (cp."Compra") AS "Compra",
    (cpm."Consumo") AS "Consumo",
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY di.Anio, di.Mes) = 1 
        THEN (iim."Inventario_Inicial" + SUM(cp."Compra")) - (MAX(di."Politica") + SUM(cpm."Consumo"))
        ELSE (LAG(ifa."PrimerInventarioFinal", 1, 0) OVER (ORDER BY di.Anio, di.Mes) + SUM(cp."Compra")) - SUM(cpm."Consumo")
    END AS "Inventario Final"
FROM datos_iniciales di
LEFT JOIN compras_por_mes cp ON di.Anio = cp.Anio AND di.Mes = cp.Mes
LEFT JOIN consumo_por_mes cpm ON di.Anio = cpm.Anio AND di.Mes = cpm.Mes
LEFT JOIN inventario_inicial_mes iim ON di.Anio = iim.Anio AND di.Mes = iim.Mes
LEFT JOIN inventario_final_anterior ifa ON di.Anio = ifa.Anio AND di.Mes = ifa.Mes
GROUP BY di.Anio, di.Mes, iim."Inventario_Inicial", ifa."PrimerInventarioFinal", di."ItemCode", cp."Compra", cpm."Consumo"
ORDER BY di.Anio, di.Mes;


-- **************************************************
mira es es la data de este item lo que yo quiero es hacer una agrupacion que solo eliga el orden 1 poque es el 
primer registro de mi inventario inicial entonces ahi ya tendria el inventario inicial ahora quiero mostras la compra maxima 
la sumatoria de cd mes y año en compra y la sumatoria de cd mes y año del consumo una vez que tenga eso valores entonces haria 
el calculo de mi inventario final que es la formular el inventario inicial de mi primera posicio del orden = 1 + las compra 
sumatoria de cd mes y año de cd articulo - la politica maxima - la sumatoria de consumo de cd mes y año de cd articulos saldria 
mi inventario final, ahora ese valor del invnrario final se tiene que add en el otra linea como inventario inicial y hacer los 
calculos en el inventario final pero ya no va la politica entonces cuando ya sale el valor del inventario fianl ese valor pasae 
al inventario inicial y asi sucesivamente solo en la primera linea es lo que te pedi 
SELECT
T1."DATUM" AS "Fecha",
YEAR(T1."DATUM") AS Anio,
MONTH(T1."DATUM") AS Mes,
T1."ItemCode",
T1."OnHand" AS "Inventario_Inicial",
T1."BESTELLUNG_ZUGANG" AS "Compra",
T1."FERTIGUNG_ABGANG" AS "Consumo",
T3."MinStock" AS "Politica",
ROW_NUMBER() OVER (PARTITION BY YEAR(T1."DATUM"), T1."ItemCode" ORDER BY T1."DATUM" ASC) AS "OrdenMes"
FROM "BEAS_MRP_PLANUNG" T0
INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode"
WHERE T0."NR" = 26 AND T1."ItemCode" = '01DBC00100083'


-- *******************************************************

-- 07-04-2025
SELECT  
Sub."ItemCode",  
Sub."Periodo",
Sub."Inventario_Inicial",  
Sub."Politica", 
Sub."Compra",  
Sub."Consumo",  
 
CASE    
      WHEN Sub."RowNum" = 1 THEN Sub."Inventario_Inicial"    
      ELSE 
          SUM(  
              CASE 
                   WHEN Sub."RowNum" = 1  THEN Sub."Inventario_Inicial" + Sub."Compra" - Sub."Consumo" - Sub."Politica"             
                   ELSE Sub."Compra" - Sub."Consumo" END      
           ) OVER (
              PARTITION BY Sub."ItemCode" ORDER BY Sub."Periodo" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           )  END AS "Inventario_Final"
FROM (  
        SELECT  
             T1."ItemCode",    
             TO_VARCHAR(T1."DATUM", 'YYYY-MM') AS "Periodo",
             T1."OnHand" AS "Inventario_Inicial",   
             SUM(T1."BESTELLUNG_ZUGANG") AS "Compra",    
            SUM(T1."FERTIGUNG_ABGANG") AS "Consumo",    
            MAX(T3."MinStock") AS "Politica",    
                
            ROW_NUMBER() OVER (PARTITION BY T1."ItemCode" ORDER BY TO_VARCHAR(T1."DATUM", 'YYYY-MM')) AS "RowNum"  
            
           FROM "BEAS_MRP_PLANUNG" T0  
           INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"  
           INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"  
           INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode"  
           WHERE T0."NR" = 26   AND T1."ItemCode" = '01DBC00100083'  
           GROUP BY T1."ItemCode", TO_VARCHAR(T1."DATUM", 'YYYY-MM'), T1."OnHand"
) Sub ORDER BY Sub."ItemCode", Sub."Periodo";


-- ***************************************************************************

WITH MonthlyData AS (
  SELECT
    T1."ItemCode",
    TO_VARCHAR(T1."DATUM", 'YYYY-MM') AS "Periodo",
    T1."OnHand" AS "Inventario_Inicial",
    SUM(T1."BESTELLUNG_ZUGANG") AS "Compra",
    SUM(T1."FERTIGUNG_ABGANG") AS "Consumo",
    MAX(T3."MinStock") AS "Politica",
    ROW_NUMBER() OVER (PARTITION BY T1."ItemCode" ORDER BY TO_VARCHAR(T1."DATUM", 'YYYY-MM')) AS "RowNum"

  FROM "BEAS_MRP_PLANUNG" T0
  INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
  INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
  INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode"
  WHERE T0."NR" = 26 AND T1."ItemCode" = '01DBC00100083'
  GROUP BY T1."ItemCode", TO_VARCHAR(T1."DATUM", 'YYYY-MM'), T1."OnHand"
),
InventarioCalculado AS (
  SELECT
    M."ItemCode",
    M."Periodo",
    M."Inventario_Inicial",
    M."Compra",
    M."Consumo",
    M."Politica",
    CASE
      WHEN M."RowNum" = 1 THEN
        M."Inventario_Inicial" + M."Compra" - M."Consumo" - M."Politica"
      ELSE
        LAG(M."Inventario_Inicial", 1) OVER (PARTITION BY M."ItemCode" ORDER BY M."Periodo") + M."Compra" - M."Consumo"
    END AS "Inventario_Final"
  FROM (
    SELECT
      MD."ItemCode",
      MD."Periodo",
      MD."RowNum",
      CASE
        WHEN MD."RowNum" = 1 THEN MD."Inventario_Inicial"
        ELSE
          LAG(MD."Inventario_Inicial", 1) OVER (PARTITION BY MD."ItemCode" ORDER BY MD."Periodo")
      END AS "Inventario_Inicial",
      MD."Compra",
      MD."Consumo",
      MD."Politica"
    FROM MonthlyData MD
  ) M
),
FinalMRP AS (
  SELECT
    "ItemCode",
    "Periodo",
    "Inventario_Inicial",
    "Compra",
    "Consumo",
    "Politica",
    "Inventario_Final"
  FROM InventarioCalculado
)
SELECT
  "ItemCode",
  "Periodo",
  "Inventario_Inicial",
  "Compra",
  "Consumo",
  "Politica",
  "Inventario_Final"
FROM FinalMRP
ORDER BY "ItemCode", "Periodo";

WITH MonthlyData AS (
  SELECT
    T1."ItemCode",
    TO_VARCHAR(T1."DATUM", 'YYYY-MM') AS "Periodo",
    T1."OnHand" AS "Inventario",
    T1."BESTELLUNG_ZUGANG" AS "Compra",
    T1."FERTIGUNG_ABGANG" AS "Consumo",
    T3."MinStock" AS "Politica",
    ROW_NUMBER() OVER (PARTITION BY T1."ItemCode", TO_VARCHAR(T1."DATUM", 'YYYY-MM') ORDER BY T1."DATUM") AS "RowNum"
  FROM "BEAS_MRP_PLANUNG" T0
  INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
  INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
  INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode"
  WHERE T0."NR" = 26 AND T1."ItemCode" = '01DBC00100083'
),
InventarioInicial AS (
  SELECT
    "ItemCode",
    "Periodo",
    "Inventario" AS "Inventario_Inicial",
    SUM("Compra") AS "Compra",
    SUM("Consumo") AS "Consumo",
    MAX("Politica") AS "Politica",
    ROW_NUMBER() OVER (PARTITION BY "ItemCode" ORDER BY "Periodo") AS "RowNum"
  FROM MonthlyData
  GROUP BY "ItemCode", "Periodo", "Inventario"
),
InventarioCalculado AS (
  SELECT
    "ItemCode",
    "Periodo",
    "Inventario_Inicial",
    "Compra",
    "Consumo",
    "Politica",
    CASE
      WHEN "RowNum" = 1 THEN
        "Inventario_Inicial" + "Compra" - "Consumo" - "Politica"
      ELSE
        LAG("Inventario_Final", 1) OVER (PARTITION BY "ItemCode" ORDER BY "Periodo") + "Compra" - "Consumo"
    END AS "Inventario_Final"
  FROM (
    SELECT
      II."ItemCode",
      II."Periodo",
      II."RowNum",
      CASE
        WHEN II."RowNum" = 1 THEN II."Inventario_Inicial"
        ELSE LAG(II."Inventario_Final", 1) OVER (PARTITION BY II."ItemCode" ORDER BY II."Periodo")
      END AS "Inventario_Inicial",
      II."Compra",
      II."Consumo",
      II."Politica",
      CASE
        WHEN II."RowNum" = 1 THEN II."Inventario_Inicial" + II."Compra" - II."Consumo" - II."Politica"
        ELSE LAG(II."Inventario_Final", 1) OVER (PARTITION BY II."ItemCode" ORDER BY II."Periodo") + II."Compra" - II."Consumo"
      END AS "Inventario_Final"
    FROM (
      SELECT
        "ItemCode",
        "Periodo",
        "RowNum",
        "Inventario_Inicial",
        "Compra",
        "Consumo",
        "Politica",
        CASE
          WHEN "RowNum" = 1 THEN "Inventario_Inicial" + "Compra" - "Consumo" - "Politica"
          ELSE LAG("Inventario_Inicial", 1) OVER (PARTITION BY "ItemCode" ORDER BY "Periodo") + "Compra" - "Consumo"
        END AS "Inventario_Final"
      FROM InventarioInicial
    ) II
  ) T
),
FinalMRP AS (
  SELECT
    "ItemCode",
    "Periodo",
    "Inventario_Inicial",
    "Compra",
    "Consumo",
    "Politica",
    "Inventario_Final"
  FROM InventarioCalculado
)
SELECT
  "ItemCode",
  "Periodo",
  "Inventario_Inicial",
  "Compra",
  "Consumo",
  "Politica",
  "Inventario_Final"
FROM FinalMRP

ORDER BY "ItemCode", "Periodo";


-- ************************

WITH MonthlyData AS (
  SELECT
    T1."ItemCode",
    TO_VARCHAR(T1."DATUM", 'YYYY-MM') AS "Periodo",
    T1."DATUM",
    T1."OnHand" AS "Inventario",
    T3."MinStock" AS "Politica",
    T1."BESTELLUNG_ZUGANG" AS "Compra",
    T1."FERTIGUNG_ABGANG" AS "Consumo"
    
  FROM "BEAS_MRP_PLANUNG" T0
  INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
  INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
  INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode"
  WHERE T0."NR" = 26 AND T1."ItemCode" = '01DBC00100083'
),
FirstPosition AS (
  SELECT
    "ItemCode",
    "Periodo",
    MIN("DATUM") AS "FirstDate"
  FROM MonthlyData
  GROUP BY "ItemCode", "Periodo"
),
InventarioInicial AS (
  SELECT
    MD."ItemCode",
    MD."Periodo",
    MD."Inventario" AS "Inventario_Inicial",
    SUM(MD."Compra") AS "Compra",
    SUM(MD."Consumo") AS "Consumo",
    MAX(MD."Politica") AS "Politica",
    ROW_NUMBER() OVER (PARTITION BY MD."ItemCode" ORDER BY MD."Periodo") AS "RowNum"
  FROM MonthlyData MD
  INNER JOIN FirstPosition FP ON MD."ItemCode" = FP."ItemCode" AND MD."Periodo" = FP."Periodo" AND MD."DATUM" = FP."FirstDate"
  GROUP BY MD."ItemCode", MD."Periodo", MD."Inventario"
),
InventarioCalculado AS (
  SELECT
    "ItemCode",
    "Periodo",
    "Inventario_Inicial",
    "Compra",
    "Consumo",
    "Politica",
    CASE
      WHEN "RowNum" = 1 THEN
        "Inventario_Inicial" + "Compra" - "Consumo" - "Politica"
      ELSE
        LAG("Inventario_Final", 1, 0) OVER (PARTITION BY "ItemCode" ORDER BY "Periodo") + "Compra" - "Consumo"
    END AS "Inventario_Final"
  FROM (
    SELECT
      II."ItemCode",
      II."Periodo",
      II."Inventario_Inicial",
      II."Compra",
      II."Consumo",
      II."Politica",
      II."RowNum"
    FROM InventarioInicial II
  ) T
)
SELECT
  "ItemCode",
  "Periodo",
  "Inventario_Inicial",
  "Compra",
  "Consumo",
  "Politica",
  "Inventario_Final"
FROM InventarioCalculado
ORDER BY "ItemCode", "Periodo";


-- ****************************************************************************************

SELECT
        T1."ItemCode",
         T1."DATUM" AS "Fecha",
        YEAR(T1."DATUM") AS Anio,
        MONTH(T1."DATUM") AS Mes,
        FIRST_VALUE(T1."OnHand") OVER (PARTITION BY T1."ItemCode", YEAR(T1."DATUM"), MONTH(T1."DATUM") ORDER BY T1."DATUM") AS "Inventario_Inicial",
        SUM(T1."BESTELLUNG_ZUGANG") AS "Compra",
        SUM(T1."FERTIGUNG_ABGANG") AS "Consumo",
        MAX(T3."MinStock") AS "Politica"
       
    FROM "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode"
    WHERE T0."NR" = 26 AND T1."ItemCode" = '01DBC00100083'
    GROUP BY T1."ItemCode", YEAR(T1."DATUM"), MONTH(T1."DATUM"), T1."DATUM", T1."OnHand"
ORDER BY  T1."DATUM";

