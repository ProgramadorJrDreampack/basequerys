WITH DatosInventario AS (
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
),
Consolidado AS (
    SELECT
        "ItemCode",
        Anio,
        Mes,
        MAX("Inventario_Inicial") AS "Inventario_Inicial",
        SUM("Compra") AS "Compra",
        SUM("Consumo") AS "Consumo",
        MAX("Politica") AS "Politica",
        CASE
            WHEN ROW_NUMBER() OVER (PARTITION BY "ItemCode", Anio ORDER BY Mes) = 1 THEN
                MAX("Inventario_Inicial") + SUM("Compra") - MAX("Politica") - SUM("Consumo")
            ELSE
                MAX("Inventario_Inicial") + SUM("Compra") - SUM("Consumo")
        END AS "Inventario_Final"
    FROM DatosInventario
    GROUP BY "ItemCode", Anio, Mes
)
SELECT
    *,
    CASE
        WHEN LEAD("Consumo", 1) OVER (PARTITION BY "ItemCode" ORDER BY Anio, Mes) IS NULL THEN NULL
        WHEN LEAD("Consumo", 1) OVER (PARTITION BY "ItemCode" ORDER BY Anio, Mes) = 0 THEN 0
        ELSE ("Inventario_Final" / LEAD("Consumo", 1) OVER (PARTITION BY "ItemCode" ORDER BY Anio, Mes))
    END AS "Cobertura"
FROM Consolidado
ORDER BY Anio, Mes;



-- ********************************************OPCION 2********************************************
WITH DatosInventario AS (
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
),
Consolidado AS (
    SELECT
        "ItemCode",
        Anio,
        Mes,
        "Inventario_Inicial",
        SUM("Compra") AS "Compra",
        SUM("Consumo") AS "Consumo",
        MAX("Politica") AS "Politica",
        ROW_NUMBER() OVER (PARTITION BY "ItemCode" ORDER BY Anio, Mes) AS RowNum
    FROM DatosInventario
    GROUP BY "ItemCode", Anio, Mes, "Inventario_Inicial"
),
CalculoInventario AS (
    SELECT
        C."ItemCode",
        C.Anio,
        C.Mes,
        C."Inventario_Inicial",
        C."Compra",
        C."Consumo",
        C."Politica",
        CASE
            WHEN C.RowNum = 1 THEN (C."Inventario_Inicial" + C."Compra") - (C."Politica" + C."Consumo")
            ELSE 0 
        END AS Inventario_Final_Base
    FROM Consolidado C
),
FinalCalculo AS (
    SELECT
        "ItemCode",
        Anio,
        Mes,
        "Inventario_Inicial",
        "Compra",
        "Consumo",
        "Politica",
        CASE
            WHEN ROW_NUMBER() OVER (PARTITION BY "ItemCode" ORDER BY Anio, Mes) = 1 THEN Inventario_Final_Base
            ELSE (LAG(Inventario_Final_Base, 1, 0) OVER (PARTITION BY "ItemCode" ORDER BY Anio, Mes)) + "Compra" - "Consumo"
        END AS Inventario_Final
    FROM CalculoInventario
),
FinalResult AS (
    SELECT
        "ItemCode",
        Anio,
        Mes,
        "Inventario_Inicial",
        "Compra",
        "Consumo",
        "Politica",
        Inventario_Final,
        CASE
            WHEN LEAD("Consumo", 1, 0) OVER (PARTITION BY "ItemCode" ORDER BY Anio, Mes) = 0 THEN 0
            ELSE (Inventario_Final / LEAD("Consumo", 1, 1) OVER (PARTITION BY "ItemCode" ORDER BY Anio, Mes))
        END AS "Cobertura"
    FROM FinalCalculo
)
SELECT
    "ItemCode",
    Anio,
    Mes,
    "Inventario_Inicial",
    "Compra",
    "Consumo",
    "Politica",
    Inventario_Final AS "Inventario_Final",
    "Cobertura"
FROM FinalResult
ORDER BY Anio, Mes;


**************************************OPCION 3*****************************************************
WITH DatosInventario AS (
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
),
Consolidado AS (
    SELECT
        "ItemCode",
        Anio,
        Mes,
        "Inventario_Inicial",
        SUM("Compra") AS "Compra",
        SUM("Consumo") AS "Consumo",
        MAX("Politica") AS "Politica",
        ROW_NUMBER() OVER (PARTITION BY "ItemCode" ORDER BY Anio, Mes) AS RowNum
    FROM DatosInventario
    GROUP BY "ItemCode", Anio, Mes, "Inventario_Inicial"
),
CalculoInventario AS (
    SELECT
        C."ItemCode",
        C.Anio,
        C.Mes,
        C."Inventario_Inicial",
        C."Compra",
        C."Consumo",
        C."Politica",
        CASE
            WHEN C.RowNum = 1 THEN (C."Inventario_Inicial" + C."Compra") - (C."Politica" + C."Consumo")
            ELSE
                LAG(Inventario_Final_Base, 1, C."Inventario_Inicial") OVER (PARTITION BY C."ItemCode" ORDER BY C.Anio, C.Mes) + C."Compra" - C."Consumo"
        END AS Inventario_Final_Base
    FROM Consolidado C
),
FinalResult AS (
    SELECT
        "ItemCode",
        Anio,
        Mes,
        "Inventario_Inicial",
        "Compra",
        "Consumo",
        "Politica",
        Inventario_Final_Base,
        CASE
            WHEN LEAD("Consumo", 1, 0) OVER (PARTITION BY "ItemCode" ORDER BY Anio, Mes) = 0 THEN 0
            ELSE (Inventario_Final_Base / LEAD("Consumo", 1, 1) OVER (PARTITION BY "ItemCode" ORDER BY Anio, Mes))
        END AS "Cobertura"
    FROM CalculoInventario
)
SELECT
    "ItemCode",
    Anio,
    Mes,
    "Inventario_Inicial",
    "Compra",
    "Consumo",
    "Politica",
    Inventario_Final_Base AS "Inventario_Final",
    "Cobertura"
FROM FinalResult
ORDER BY Anio, Mes;


-- *********************************************************************************************
