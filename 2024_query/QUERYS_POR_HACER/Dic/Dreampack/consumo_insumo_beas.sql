
SELECT T0.*, T2."ItmsGrpNam"
FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_CONSUMOS_INSUMOS_BEAS" T0
INNER JOIN OITM T1 ON T0."ItemCode" = T1."ItemCode"
INNER JOIN OITB T2 ON T1."ItmsGrpCod" = T2."ItmsGrpCod"
WHERE
    "DocDate" BETWEEN '2024-01-01' AND '2024-01-01' 
     --CAST("DocDate" AS DATE) >= CAST([%0] AS DATE) AND  
     --CAST("DocDate" AS DATE) <= CAST([%1] AS DATE)

     --CAST("DocDate" AS DATE) >= CAST([%0] AS DATE) AND 
    --CAST("DocDate" AS DATE) <= CAST([%1] AS DATE) 

    --"DocDate" >= [%0] AND  "DocDate" <= [%1] 
  --"DocDate" BETWEEN [%0] AND [%1] 

--"DocDate" >= '2024-01-01'


/* query original */
SELECT T0.*, T2."ItmsGrpNam"
FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_CONSUMOS_INSUMOS_BEAS" T0
INNER JOIN OITM T1 ON T0."ItemCode" = T1."ItemCode"
INNER JOIN OITB T2 ON T1."ItmsGrpCod" = T2."ItmsGrpCod"
WHERE "DocDate" >= '2024-01-01'

/* query modificado filtro por fecha */

SELECT T0.*, T2."ItmsGrpNam"
FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_CONSUMOS_INSUMOS_BEAS" T0
INNER JOIN OITM T1 ON T0."ItemCode" = T1."ItemCode"
INNER JOIN OITB T2 ON T1."ItmsGrpCod" = T2."ItmsGrpCod"
WHERE "DocDate" BETWEEN [%0] AND [%1]


-- WHERE "DocDate" BETWEEN '2024-01-01' AND '2025-01-27'

WHERE "DocDate" BETWEEN TO_DATE([%0], 'YYYY-MM-DD') AND TO_DATE([%1], 'YYYY-MM-DD');
WHERE "DocDate" BETWEEN TO_DATE([%0], 'DD-MM-YYYY') AND TO_DATE([%1], 'DD-MM-YYYY');
WHERE "DocDate" BETWEEN TO_DATE('01-01-2023', 'DD-MM-YYYY') AND TO_DATE('31-12-2023', 'DD-MM-YYYY');

WHERE TO_DATE(T0."DocDate", 'YYYY-MM-DD') BETWEEN TO_DATE([%0], 'DD-MM-YYYY') AND TO_DATE([%1], 'DD-MM-YYYY');

-- *********************************************************************
DECLARE last_date DATE := (SELECT MAX("DocDate") FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_CONSUMOS_INSUMOS_BEAS");

SELECT 
    T0.*, 
    T2."ItmsGrpNam"
FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_CONSUMOS_INSUMOS_BEAS" T0
INNER JOIN OITM T1 ON T0."ItemCode" = T1."ItemCode"
INNER JOIN OITB T2 ON T1."ItmsGrpCod" = T2."ItmsGrpCod"
WHERE "DocDate" BETWEEN '2024-01-01' AND last_date;

