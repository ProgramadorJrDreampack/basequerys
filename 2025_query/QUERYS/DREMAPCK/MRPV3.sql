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

1.- me viene la info de muchos articulos con su fecha , codigo del articulo, inventario inicial , politica, compra, consumo. 
pero yo le filtro por item code para realizar la prueba de una articulo


SELECT 
T1."DATUM" AS "Fecha",
T1."ItemCode" AS "Cod del Articulo",
T1."OnHand" AS "Inventario Inicial",
T3."MinStock" AS "Politica",
T1."BESTELLUNG_ZUGANG" AS "Compra",
T1."FERTIGUNG_ABGANG" AS "Consumo"

FROM "BEAS_MRP_PLANUNG" T0
INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode" 
WHERE T0."NR" = 26 AND T1."ItemCode" = '01DBC00100083'
ORDER BY T1."DATUM"

Fecha	Cod del Articulo	Inventario Inicial	Politica	Compra	Consumo	
13/02/2025	01DBC00100083	8,829.0000	30,000.0000	0.0000	214.9875
28/03/2025	01DBC00100083	8,614.0125	30,000.0000	0.0000	289.0561	
28/03/2025	01DBC00100083	8,324.9564	30,000.0000	0.0000	5,259.6687	
01/04/2025	01DBC00100083	2,861.5832	30,000.0000	0.0000	125.1000	
01/04/2025	01DBC00100083	3,065.2877	30,000.0000	0.0000	197.0325	
01/04/2025	01DBC00100083	2,868.2552	30,000.0000	0.0000	6.6720	
01/04/2025	01DBC00100083	2,736.4832	30,000.0000	0.0000	479.4215	
01/04/2025	01DBC00100083	2,257.0617	30,000.0000	0.0000	26.4046	
01/04/2025	01DBC00100083	2,230.6571	30,000.0000	0.0000	2.6100	
02/04/2025	01DBC00100083	2,228.0471	30,000.0000	0.0000	133.0800	
03/04/2025	01DBC00100083	2,094.9671	30,000.0000	0.0000	43.8340	
04/04/2025	01DBC00100083	8,829.0000	30,000.0000	0.0000	0.0000	
09/04/2025	01DBC00100083	2,051.1331	30,000.0000	0.0000	155.5028	
17/04/2025	01DBC00100083	1,418.3317	30,000.0000	0.0000	399.2400	
17/04/2025	01DBC00100083	1,895.6304	30,000.0000	0.0000	466.4150	
17/04/2025	01DBC00100083	1,429.2154	30,000.0000	0.0000	10.8837	
24/04/2025	01DBC00100083	1,019.0917	30,000.0000	0.0000	351.6103	
28/04/2025	01DBC00100083	-44.8311	30,000.0000	0.0000	733.4600	
28/04/2025	01DBC00100083	-778.2911	30,000.0000	0.0000	4,293.7424	
28/04/2025	01DBC00100083	667.4814	30,000.0000	0.0000	712.3125	
29/04/2025	01DBC00100083	-5,072.0335	30,000.0000	0.0000	275.0475	
29/04/2025	01DBC00100083	-5,347.0810	30,000.0000	0.0000	1,079.6574	
29/04/2025	01DBC00100083	-6,426.7385	30,000.0000	0.0000	1,079.7244	
29/04/2025	01DBC00100083	-7,506.4629	30,000.0000	0.0000	366.7300	
30/04/2025	01DBC00100083	-7,873.1929	30,000.0000	0.0000	1,078.0308	
01/05/2025	01DBC00100083	-11,800.5169	30,000.0000	0.0000	2.9000	
01/05/2025	01DBC00100083	-8,951.2237	30,000.0000	0.0000	437.8500	
01/05/2025	01DBC00100083	-9,389.0737	30,000.0000	0.0000	93.8250	
01/05/2025	01DBC00100083	-9,482.8987	30,000.0000	0.0000	931.6173	
01/05/2025	01DBC00100083	-10,414.5160	30,000.0000	0.0000	475.3800	
01/05/2025	01DBC00100083	-10,889.8960	30,000.0000	0.0000	875.7700	
01/05/2025	01DBC00100083	-11,765.6660	30,000.0000	0.0000	5.5125	
01/05/2025	01DBC00100083	-11,771.1785	30,000.0000	0.0000	29.3384	
05/05/2025	01DBC00100083	-11,803.4169	30,000.0000	19,398.0000	0.0000	
26/05/2025	01DBC00100083	7,594.5831	30,000.0000	17,000.0000	0.0000	
02/06/2025	01DBC00100083	22,667.1765	30,000.0000	0.0000	8,240.0605	
02/06/2025	01DBC00100083	24,594.5831	30,000.0000	0.0000	344.0250	
02/06/2025	01DBC00100083	24,250.5581	30,000.0000	0.0000	93.8250	
02/06/2025	01DBC00100083	24,156.7331	30,000.0000	0.0000	1,236.7597	
02/06/2025	01DBC00100083	22,919.9734	30,000.0000	0.0000	252.7969	
02/06/2025	01DBC00100083	14,427.1160	30,000.0000	0.0000	663.0300	
02/06/2025	01DBC00100083	13,764.0860	30,000.0000	0.0000	1,100.9680	
02/06/2025	01DBC00100083	12,663.1180	30,000.0000	0.0000	29.3384	
02/06/2025	01DBC00100083	12,633.7796	30,000.0000	0.0000	2.1750	
01/07/2025	01DBC00100083	12,631.6046	30,000.0000	33,000.0000	0.0000	
01/07/2025	01DBC00100083	45,631.6046	30,000.0000	0.0000	312.7500	
01/07/2025	01DBC00100083	45,318.8546	30,000.0000	0.0000	93.8250	
01/07/2025	01DBC00100083	45,225.0296	30,000.0000	0.0000	140.0682	
01/07/2025	01DBC00100083	45,084.9614	30,000.0000	0.0000	2,541.7392	
01/07/2025	01DBC00100083	42,543.2222	30,000.0000	0.0000	590.8545	
01/07/2025	01DBC00100083	41,952.3677	30,000.0000	0.0000	9,017.3878	
01/07/2025	01DBC00100083	32,934.9799	30,000.0000	0.0000	475.3800	
01/07/2025	01DBC00100083	32,459.5999	30,000.0000	0.0000	1,100.9680	
01/07/2025	01DBC00100083	31,358.6319	30,000.0000	0.0000	5.5125	
01/07/2025	01DBC00100083	31,353.1194	30,000.0000	0.0000	29.3384	
01/07/2025	01DBC00100083	31,323.7810	30,000.0000	0.0000	3.9150	
01/08/2025	01DBC00100083	27,535.9484	30,000.0000	0.0000	8,084.5578	
01/08/2025	01DBC00100083	30,882.0160	30,000.0000	0.0000	3.7530	
01/08/2025	01DBC00100083	30,878.2630	30,000.0000	0.0000	297.0810	
01/08/2025	01DBC00100083	30,581.1820	30,000.0000	0.0000	2,261.1576	
01/08/2025	01DBC00100083	28,320.0244	30,000.0000	0.0000	193.2215	
01/08/2025	01DBC00100083	28,126.8029	30,000.0000	0.0000	590.8545	
01/08/2025	01DBC00100083	19,451.3907	30,000.0000	0.0000	562.9500	
01/08/2025	01DBC00100083	18,888.4407	30,000.0000	0.0000	1,226.0780	
01/08/2025	01DBC00100083	17,662.3627	30,000.0000	0.0000	78.5172	
01/08/2025	01DBC00100083	17,583.8455	30,000.0000	0.0000	29.3384	
01/08/2025	01DBC00100083	17,554.5071	30,000.0000	0.0000	5.0750	
01/08/2025	01DBC00100083	31,319.8660	30,000.0000	0.0000	437.8500	
01/09/2025	01DBC00100083	3,860.6902	30,000.0000	0.0000	5.0750	
01/09/2025	01DBC00100083	17,549.4321	30,000.0000	0.0000	312.7500	
01/09/2025	01DBC00100083	17,236.6821	30,000.0000	0.0000	11.2590	
01/09/2025	01DBC00100083	17,225.4231	30,000.0000	0.0000	280.5765	
01/09/2025	01DBC00100083	16,944.8466	30,000.0000	0.0000	2,129.1192	
01/09/2025	01DBC00100083	14,815.7274	30,000.0000	0.0000	590.8545	
01/09/2025	01DBC00100083	14,224.8728	30,000.0000	0.0000	8,550.9728	
01/09/2025	01DBC00100083	5,673.9001	30,000.0000	0.0000	475.3800	
01/09/2025	01DBC00100083	5,198.5201	30,000.0000	0.0000	1,063.4350	
01/09/2025	01DBC00100083	4,135.0851	30,000.0000	0.0000	239.5440	
01/09/2025	01DBC00100083	3,895.5411	30,000.0000	0.0000	5.5125	
01/09/2025	01DBC00100083	3,890.0286	30,000.0000	0.0000	29.3384	
01/10/2025	01DBC00100083	-29,516.3648	30,000.0000	0.0000	239.5440	
01/10/2025	01DBC00100083	3,855.6152	30,000.0000	0.0000	312.7500	
01/10/2025	01DBC00100083	3,542.8652	30,000.0000	0.0000	3.7530	
01/10/2025	01DBC00100083	3,539.1122	30,000.0000	0.0000	280.5765	
01/10/2025	01DBC00100083	3,258.5357	30,000.0000	0.0000	21,192.1632	
01/10/2025	01DBC00100083	-17,933.6275	30,000.0000	0.0000	590.8545	
01/10/2025	01DBC00100083	-29,755.9088	30,000.0000	0.0000	29.3384	
01/10/2025	01DBC00100083	-29,785.2472	30,000.0000	0.0000	5.0750	
01/10/2025	01DBC00100083	-18,524.4820	30,000.0000	0.0000	9,390.5198	
01/10/2025	01DBC00100083	-27,915.0018	30,000.0000	0.0000	562.9500	
01/10/2025	01DBC00100083	-28,477.9518	30,000.0000	0.0000	1,038.4130	
03/11/2025	01DBC00100083	-44,049.9457	30,000.0000	0.0000	587.9700	
03/11/2025	01DBC00100083	-29,790.3222	30,000.0000	0.0000	344.0250	
03/11/2025	01DBC00100083	-30,134.3472	30,000.0000	0.0000	3.7530	
03/11/2025	01DBC00100083	-30,138.1002	30,000.0000	0.0000	297.0810	
03/11/2025	01DBC00100083	-30,435.1812	30,000.0000	0.0000	3,135.9120	
03/11/2025	01DBC00100083	-33,571.0932	30,000.0000	0.0000	590.8545	
03/11/2025	01DBC00100083	-34,161.9477	30,000.0000	0.0000	9,887.9980	
03/11/2025	01DBC00100083	-44,637.9157	30,000.0000	0.0000	2,001.7600	
03/11/2025	01DBC00100083	-46,639.6757	30,000.0000	0.0000	239.5440	
03/11/2025	01DBC00100083	-46,879.2197	30,000.0000	0.0000	38.2928	
03/11/2025	01DBC00100083	-46,917.5125	30,000.0000	0.0000	5.5125	
03/11/2025	01DBC00100083	-46,923.0250	30,000.0000	0.0000	29.3384	
03/11/2025	01DBC00100083	-46,952.3634	30,000.0000	0.0000	3.4075	
01/12/2025	01DBC00100083	-58,409.9030	30,000.0000	0.0000	475.3800	
01/12/2025	01DBC00100083	-46,955.7709	30,000.0000	0.0000	344.0250	
01/12/2025	01DBC00100083	-47,299.7959	30,000.0000	0.0000	67.5540	
01/12/2025	01DBC00100083	-47,367.3499	30,000.0000	0.0000	280.5765	
01/12/2025	01DBC00100083	-47,647.9264	30,000.0000	0.0000	1,931.0616	
01/12/2025	01DBC00100083	-49,578.9880	30,000.0000	0.0000	590.8545	
01/12/2025	01DBC00100083	-50,169.8425	30,000.0000	0.0000	8,240.0605	
01/12/2025	01DBC00100083	-59,823.6080	30,000.0000	0.0000	239.5440	
01/12/2025	01DBC00100083	-58,885.2830	30,000.0000	0.0000	938.3250	
01/12/2025	01DBC00100083	-60,063.1520	30,000.0000	0.0000	29.3384	
01/12/2025	01DBC00100083	-60,092.4904	30,000.0000	0.0000	0.7250	



este seria mi primera posicion 
13/02/2025	01DBC00100083	8,829.0000	30,000.0000	0.0000	214.9875

ahora quiero realizar el MRP AQUE CONSITE EN

necesito en la primera linea la primera posicion del inventario inicial de mi articulo esa tiene que ir en mi primera fila

luego necito una columna para hacer el calculo del inventario final =  ( (INVENTARIO INICIAL + COMPRA) - (POLITICA - CONSUMO) ) agrupado DE CD MES Y AÑO PERO y del itemcode pero la sumatoria de cd mes de compra y consumo
en la segunda linea ya tiene que salir del otro mes pero el valor que sale del inventario final ese valor pasa en la posicion del inventario inicial y asi mimos se hace la suma de la compra y de la consumos de cd mes y año y el inventario final ya se realiza pero sin politca y asi sucesivamente para las siguites lineas dependes de la fecha y su agrupacion


Fecha	Cod del Articulo	Inventario Inicial	Politica	Compra	Consumo	
13/02/2025	01DBC00100083	8,829.0000	30,000.0000	0.0000	214.9875


WITH DatosAgrupados AS (
  SELECT
    TO_CHAR(T1."DATUM", 'YYYY-MM') AS "Mes-Año",
    T1."ItemCode" AS "Cod del Articulo",
    SUM(T1."BESTELLUNG_ZUGANG") AS "Compra",
    SUM(T1."FERTIGUNG_ABGANG") AS "Consumo",
    MAX(T3."MinStock") AS "Politica"
  FROM
    "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode"
  WHERE
    T0."NR" = 26
    AND T1."ItemCode" = '01DBC00100083'
  GROUP BY
    TO_CHAR(T1."DATUM", 'YYYY-MM'),
    T1."ItemCode"
),
ConInventarios AS (
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY "Mes-Año") AS fila
  FROM DatosAgrupados
),
PrimerValor AS (
  SELECT 
    "OnHand" AS "InventarioInicial"
  FROM "BEAS_MRP_DETAIL"
  WHERE "ItemCode" = '01DBC00100083'
  ORDER BY "DATUM"
  LIMIT 1
),
FinalCalculado AS (
  SELECT
    C."Mes-Año",
    C."Cod del Articulo",
    CASE 
      WHEN C.fila = 1 THEN (SELECT * FROM PrimerValor)
      ELSE NULL
    END AS "Inventario Inicial",
    C."Compra",
    C."Consumo",
    C."Politica",
    CASE 
      WHEN C.fila = 1 THEN 
        ((SELECT * FROM PrimerValor) + C."Compra") - (C."Politica" - C."Consumo")
      ELSE NULL
    END AS "Inventario Final",
    C.fila
  FROM ConInventarios C
),
InventarioRellenado AS (
  SELECT
    A."Mes-Año",
    A."Cod del Articulo",
    COALESCE(A."Inventario Inicial", LAG(A."Inventario Final") OVER (ORDER BY A.fila)) AS "Inventario Inicial",
    A."Compra",
    A."Consumo",
    A."Politica",
    CASE 
      WHEN A.fila = 1 THEN A."Inventario Final"
      ELSE 
        COALESCE(LAG(A."Inventario Final") OVER (ORDER BY A.fila), 0) + A."Compra" - A."Consumo"
    END AS "Inventario Final"
  FROM FinalCalculado A
)
SELECT
  "Mes-Año",
  "Cod del Articulo",
  ROUND("Inventario Inicial", 4) AS "Inventario Inicial",
  ROUND("Compra", 4) AS "Compra",
  ROUND("Consumo", 4) AS "Consumo",
  ROUND("Politica", 4) AS "Politica",
  ROUND("Inventario Final", 4) AS "Inventario Final"
FROM InventarioRellenado
ORDER BY "Mes-Año";

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
WITH DatosAgrupados AS (
  SELECT
    TO_CHAR(T1."DATUM", 'YYYY-MM') AS "Mes-Año",
    T1."ItemCode" AS "Cod del Articulo",
    SUM(T1."BESTELLUNG_ZUGANG") AS "Compra",
    SUM(T1."FERTIGUNG_ABGANG") AS "Consumo",
    MAX(T3."MinStock") AS "Politica"
  FROM
    "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode"
  WHERE
    T0."NR" = 26
    AND T1."ItemCode" = '01DBC00100083'
  GROUP BY
    TO_CHAR(T1."DATUM", 'YYYY-MM'),
    T1."ItemCode"
),
ConInventarios AS (
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY "Mes-Año") AS fila
  FROM DatosAgrupados
),
PrimerValor AS (
  SELECT 
    "OnHand" AS "InventarioInicial"
  FROM "BEAS_MRP_DETAIL"
  WHERE "ItemCode" = '01DBC00100083'
  ORDER BY "DATUM"
  LIMIT 1
),
FinalCalculado AS (
  SELECT
    C."Mes-Año",
    C."Cod del Articulo",
    CASE 
      WHEN C.fila = 1 THEN (SELECT * FROM PrimerValor)
      ELSE NULL
    END AS "Inventario Inicial",
    C."Compra",
    C."Consumo",
    C."Politica",
    CASE 
      WHEN C.fila = 1 THEN 
        ((SELECT * FROM PrimerValor) + C."Compra") - (C."Politica" - C."Consumo")
      ELSE NULL
    END AS "Inventario Final",
    C.fila
  FROM ConInventarios C
),
InventarioRellenado AS (
  SELECT
    A."Mes-Año",
    A."Cod del Articulo",
    COALESCE(A."Inventario Inicial", LAG(A."Inventario Final") OVER (ORDER BY A.fila)) AS "Inventario Inicial",
    A."Compra",
    A."Consumo",
    A."Politica",
    CASE 
      WHEN A.fila = 1 THEN A."Inventario Final"
      ELSE 
        COALESCE(LAG(A."Inventario Final") OVER (ORDER BY A.fila), 0) + A."Compra" - A."Consumo"
    END AS "Inventario Final"
  FROM FinalCalculado A
)
SELECT
  "Mes-Año",
  "Cod del Articulo",
  ROUND("Inventario Inicial", 4) AS "Inventario Inicial",
  ROUND("Compra", 4) AS "Compra",
  ROUND("Consumo", 4) AS "Consumo",
  ROUND("Politica", 4) AS "Politica",
  ROUND("Inventario Final", 4) AS "Inventario Final"
FROM InventarioRellenado
ORDER BY "Mes-Año";

asi deberia quedar 
Mes-Año	ItemCode	Inventario Inicial	Compra	Consumo	Politica	Inventario Final
2025-02	01DBC00100083	8829.0000	0.0000	214.9875	30,000	-20,956.0125
2025-03	01DBC00100083	-20,956.0125	0.0000	5,548.72	30,000	-26,504.7373
2025-04	01DBC00100083	-26,504.7373	0.0000	12,016.51	30,000	-38,521.2488
2025-05	01DBC00100083	-38,521.2488	36,398.00	2,852.19	30,000	33,545.8068
2025-06	01DBC00100083	33,545.8068	0.0000	11,962.98	30,000	21,582.8288
2025-07	01DBC00100083	21,582.8288	33,000.00	14,311.74	30,000	40,271.0884
2025-08	01DBC00100083	40,271.0884	0.0000	13,770.43	30,000	26,500.6584
2025-09	01DBC00100083	26,500.6584	0.0000	13,693.82	30,000	12,806.8364
2025-10	01DBC00100083	12,806.8364	0.0000	33,645.94	30,000	-20,839.1036
2025-11	01DBC00100083	-20,839.1036	0.0000	17,165.45	30,000	-38,004.5481
2025-12	01DBC00100083	-38,004.5481	0.0000	13,137.44	30,000	-51,141.9925

WITH DatosAgrupados AS (
  SELECT
    TO_CHAR(T1."DATUM", 'YYYY-MM') AS "Mes-Año",
    T1."ItemCode",
    SUM(T1."BESTELLUNG_ZUGANG") AS "Compra",
    SUM(T1."FERTIGUNG_ABGANG") AS "Consumo",
    MAX(T3."MinStock") AS "Politica"
  FROM
    "BEAS_MRP_PLANUNG" T0
    INNER JOIN "BEAS_MRP_DETAIL" T1 ON T0."NR" = T1."NR"
    INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
    INNER JOIN OITW T3 ON T1."ItemCode" = T3."ItemCode" AND T2."DfltWH" = T3."WhsCode"
  WHERE
    T0."NR" = 26
    AND T1."ItemCode" = '01DBC00100083'
  GROUP BY
    TO_CHAR(T1."DATUM", 'YYYY-MM'),
    T1."ItemCode"
),
ConInventarios AS (
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY "Mes-Año") AS fila
  FROM DatosAgrupados
),
PrimerValor AS (
  SELECT 
    "OnHand" AS "InventarioInicial"
  FROM "BEAS_MRP_DETAIL"
  WHERE "ItemCode" = '01DBC00100083'
  ORDER BY "DATUM"
  LIMIT 1
),
FinalCalculado AS (
  SELECT
    C."Mes-Año",
    "ItemCode",
    -- Asignamos el Inventario Inicial
    CASE 
      WHEN C.fila = 1 THEN (SELECT "InventarioInicial" FROM PrimerValor)
      ELSE LAG(
        ((SELECT "InventarioInicial" FROM PrimerValor) + C."Compra") - (C."Politica" - C."Consumo"),
        1, 0
      ) OVER (ORDER BY C.fila)
    END AS "Inventario Inicial",
    C."Compra",
    C."Consumo",
    C."Politica",
    -- Calculamos el Inventario Final usando la fórmula correcta
    CASE 
      WHEN C.fila = 1 THEN 
        ((SELECT "InventarioInicial" FROM PrimerValor) + C."Compra") - (C."Politica" - C."Consumo")
      ELSE 
        LAG(
          (SELECT "InventarioInicial" FROM PrimerValor) + C."Compra" - ( C."Consumo"),
          1, 0
        ) OVER (ORDER BY C.fila) + C."Compra" - (C."Politica" - C."Consumo")
    END AS "Inventario Final",
    C.fila
  FROM ConInventarios C
)
SELECT
  "Mes-Año",
  "ItemCode",
  ROUND("Inventario Inicial", 4) AS "Inventario Inicial",
  ROUND("Compra", 4) AS "Compra",
  ROUND("Consumo", 4) AS "Consumo",
  ROUND("Politica", 4) AS "Politica",
  ROUND("Inventario Final", 4) AS "Inventario Final"
FROM FinalCalculado
ORDER BY "Mes-Año";