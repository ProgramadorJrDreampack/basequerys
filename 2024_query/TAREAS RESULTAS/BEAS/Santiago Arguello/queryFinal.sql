/* QUERY FINAL DE SANTIAGO ARGUELLO */

SELECT
    T0."BELNR_ID" AS "Orden",
    T2."ItemCode" AS "Articulo",
    T0."BELNR_ID" || T2."ItemCode" AS "Clave",
    T2."ItemName" AS "Articulo_Descripcion",
    SUM(T0."MENGE_GUT") AS "Suma_Cantidad_OK",
    A0."Suma_Cantidad_Lote" AS "Cantidad_No_Conforme",
    A0."Suma_Cantidad_Producida"
    
    
FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
LEFT JOIN (
    SELECT 
        --T0."DocNum",
        --T0."DocDate",
        LEFT(T4."DistNumber",5) AS "Orden",
        T1."ItemCode",
        LEFT(T4."DistNumber",5) || T1."ItemCode" AS "Clave",
        SUM(T3."Quantity") As "Suma_Cantidad_Lote",
        SUM(T5."GEL_MENGE") AS "Suma_Cantidad_Producida"

    FROM OWTR T0
    INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
    INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
        AND T1."WhsCode" = T2."LocCode" 
        AND T2."DocType" = '67' 
        AND T1."LineNum" = T2."DocLine"
    INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
    INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
    INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
        AND CAST(T5."BELPOS_ID" AS VARCHAR) = (
            CASE 
                WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3) 
                WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3) 
                ELSE SUBSTRING(T4."DistNumber",6,2) 
            END)
        AND T1."ItemCode" = T5."ItemCode"
    INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
    INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod"
    LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
    LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" 
        AND T5."BELPOS_ID" = T9."BELPOS_ID" 
        AND T4."DistNumber" = T9."BatchNum" 
        AND T9."CANCEL" != '1'

    WHERE T1."WhsCode" IN ('11PCD', '12PCD')  --'20PCD'
        AND T0."DocDate" > '2024-01-01'
        AND T0."CANCELED" = 'N' AND T1."Quantity" > 0
    GROUP BY
      T4."DistNumber", T1."ItemCode"
) A0 ON A0."Clave" = (T0."BELNR_ID" || T2."ItemCode")

WHERE 
   T0."ANFZEIT" BETWEEN '2024-08-01' AND '2024-09-01' 
   --T0."ANFZEIT" > '2024-08-01' AND  T0."ANFZEIT" <= '2024-08-31'
   --AND T0."BELNR_ID" = '30121'  --'29757'  '29818' --'30099' --'29757' -- '29409'
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


/* ************ */
SELECT
    T0."BELNR_ID" AS "Orden",
    T2."ItemCode" AS "Articulo",
    T0."BELNR_ID" || T2."ItemCode" AS "Clave",
    T2."ItemName" AS "Articulo_Descripcion",
    SUM(T0."MENGE_GUT") AS "Suma_Cantidad_OK" --,
    --MAX(A0."Suma_Cantidad_Lote") AS "Cantidad_No_Conforme",
    --MAX(A0."Suma_Cantidad_Producida")  AS "Suma_Cantidad_Producida"  
    
FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
LEFT JOIN (
    SELECT
        P0."Orden",  
        P0."ItemCode", 
        P0."Orden" || P0."ItemCode" AS "Clave", 
        SUM(P0."Suma_Cantidad_Lote") As "Suma_Cantidad_Lote",
        SUM(P0."Suma_Cantidad_Producida") AS "Suma_Cantidad_Producida"
    FROM(
        SELECT 
            --T0."DocNum",
            --T0."DocDate",
            LEFT(T4."DistNumber",5) AS "Orden",
            T1."ItemCode",
            LEFT(T4."DistNumber",5) || T1."ItemCode" AS "Clave",
            SUM(T3."Quantity") As "Suma_Cantidad_Lote",
            SUM(T5."GEL_MENGE") AS "Suma_Cantidad_Producida"

        FROM OWTR T0
        INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
        INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
            AND T1."WhsCode" = T2."LocCode" 
            AND T2."DocType" = '67' 
            AND T1."LineNum" = T2."DocLine"
        INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
        INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
            AND CAST(T5."BELPOS_ID" AS VARCHAR) = (
                CASE 
                    WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3) 
                    WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3) 
                    ELSE SUBSTRING(T4."DistNumber",6,2) 
                END)
            AND T1."ItemCode" = T5."ItemCode"
        INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
        INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod"
        LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
        LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" 
            AND T5."BELPOS_ID" = T9."BELPOS_ID" 
            AND T4."DistNumber" = T9."BatchNum" 
            AND T9."CANCEL" != '1'

        WHERE T1."WhsCode" IN ('11PCD', '12PCD')  --'20PCD'
            AND T0."DocDate" > '2024-01-01'
            AND T0."CANCELED" = 'N' AND T1."Quantity" > 0
        GROUP BY
        T4."DistNumber", T1."ItemCode" --, T3."Quantity", T5."GEL_MENGE"
    ) P0
) A0 ON A0."Clave" = (T0."BELNR_ID" || T2."ItemCode")

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


/* *************OPCION 1******************* */
SELECT
    T0."BELNR_ID" AS "Orden",
    T2."ItemCode" AS "Articulo",
    T0."BELNR_ID" || T2."ItemCode" AS "Clave",
    T2."ItemName" AS "Articulo_Descripcion",
    SUM(T0."MENGE_GUT") AS "Suma_Cantidad_OK",
    MAX(A0."Suma_Cantidad_Lote") AS "Cantidad_No_Conforme",
    MAX(A0."Suma_Cantidad_Producida")  AS "Suma_Cantidad_Producida"  
    
FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
LEFT JOIN (
    SELECT
        P0."Orden",  
        P0."ItemCode", 
        P0."Orden" || P0."ItemCode" AS "Clave", 
        SUM(P0."Suma_Cantidad_Lote") As "Suma_Cantidad_Lote",
        SUM(P0."Suma_Cantidad_Producida") AS "Suma_Cantidad_Producida"
    FROM(
        SELECT 
            --T0."DocNum",
            --T0."DocDate",
            LEFT(T4."DistNumber",5) AS "Orden",
            T1."ItemCode",
            LEFT(T4."DistNumber",5) || T1."ItemCode" AS "Clave",
            T3."Quantity" As "Suma_Cantidad_Lote",
            T5."GEL_MENGE" AS "Suma_Cantidad_Producida"

        FROM OWTR T0
        INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
        INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
            AND T1."WhsCode" = T2."LocCode" 
            AND T2."DocType" = '67' 
            AND T1."LineNum" = T2."DocLine"
        INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
        INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
            AND CAST(T5."BELPOS_ID" AS VARCHAR) = (
                CASE 
                    WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3) 
                    WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3) 
                    ELSE SUBSTRING(T4."DistNumber",6,2) 
                END)
            AND T1."ItemCode" = T5."ItemCode"
        INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
        INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod"
        LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
        LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" 
            AND T5."BELPOS_ID" = T9."BELPOS_ID" 
            AND T4."DistNumber" = T9."BatchNum" 
            AND T9."CANCEL" != '1'

        WHERE T1."WhsCode" IN ('11PCD', '12PCD')  --'20PCD'
            AND T0."DocDate" > '2024-01-01'
            AND T0."CANCELED" = 'N' AND T1."Quantity" > 0
        GROUP BY
        T4."DistNumber", T1."ItemCode" , T3."Quantity", T5."GEL_MENGE"
    ) P0 
     GROUP BY P0."Orden", P0."ItemCode"
) A0 ON A0."Clave" = (T0."BELNR_ID" || T2."ItemCode")
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

-- ******************OPCION 2************************************

SELECT
    T0."BELNR_ID" AS "Orden",
    T2."ItemCode" AS "Articulo",
    T0."BELNR_ID" || T2."ItemCode" AS "Clave",
    T2."ItemName" AS "Articulo_Descripcion",
    SUM(T0."MENGE_GUT") AS "Suma_Cantidad_OK",
    MAX(A0."Suma_Cantidad_Lote") AS "Cantidad_No_Conforme",
    CASE 
            WHEN MAX(A0."Suma_Cantidad_Producida") > 0 THEN  MAX(A0."Suma_Cantidad_Producida")
            ELSE  SUM(T0."MENGE_GUT")
    END AS "Suma_Cantidad_Producida"
    --MAX(A0."Suma_Cantidad_Producida")  AS "Suma_Cantidad_Producida"

    --(MAX(A0."Suma_Cantidad_Producida") - MAX(A0."Suma_Cantidad_Lote"))  / SUM(T0."MENGE_GUT") AS "Calidad"

    CASE 
        WHEN SUM(T0."MENGE_GUT") > 0 THEN 
            (MAX(A0."Suma_Cantidad_Producida") - MAX(A0."Suma_Cantidad_Lote")) / SUM(T0."MENGE_GUT")
        WHEN SUM(T0."MENGE_GUT") IS NULL  THEN 100
     
        ELSE '100'
    END AS "Calidad"  
    
FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
LEFT JOIN (
    SELECT
        P0."Orden",  
        P0."ItemCode", 
        P0."Orden" || P0."ItemCode" AS "Clave", 
        SUM(P0."Suma_Cantidad_Lote") As "Suma_Cantidad_Lote",
        SUM(P0."Suma_Cantidad_Producida") AS "Suma_Cantidad_Producida"
    FROM(
        SELECT 
            --T0."DocNum",
            --T0."DocDate",
            LEFT(T4."DistNumber",5) AS "Orden",
            T1."ItemCode",
            LEFT(T4."DistNumber",5) || T1."ItemCode" AS "Clave",
            T3."Quantity" As "Suma_Cantidad_Lote",
            T5."GEL_MENGE" AS "Suma_Cantidad_Producida"

        FROM OWTR T0
        INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
        INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
            AND T1."WhsCode" = T2."LocCode" 
            AND T2."DocType" = '67' 
            AND T1."LineNum" = T2."DocLine"
        INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
        INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
            AND CAST(T5."BELPOS_ID" AS VARCHAR) = (
                CASE 
                    WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3) 
                    WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3) 
                    ELSE SUBSTRING(T4."DistNumber",6,2) 
                END)
            AND T1."ItemCode" = T5."ItemCode"
        INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
        INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod"
        LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
        LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" 
            AND T5."BELPOS_ID" = T9."BELPOS_ID" 
            AND T4."DistNumber" = T9."BatchNum" 
            AND T9."CANCEL" != '1'

        WHERE T1."WhsCode" IN ('11PCD', '12PCD')  --'20PCD'
            AND T0."DocDate" > '2024-01-01'
            AND T0."CANCELED" = 'N' AND T1."Quantity" > 0
        GROUP BY
        T4."DistNumber", T1."ItemCode" , T3."Quantity", T5."GEL_MENGE"
    ) P0 
     GROUP BY P0."Orden", P0."ItemCode"
) A0 ON A0."Clave" = (T0."BELNR_ID" || T2."ItemCode")
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


/* revisar el query con santiago */
SELECT
    T0."BELNR_ID" AS "Orden",
    T2."ItemCode" AS "Articulo",
    T0."BELNR_ID" || T2."ItemCode" AS "Clave",
    T2."ItemName" AS "Articulo_Descripcion",
    SUM(T0."MENGE_GUT") AS "Suma_Cantidad_OK",
    MAX(A0."Suma_Cantidad_Lote") AS "Cantidad_No_Conforme",
    CASE 
            WHEN MAX(A0."Suma_Cantidad_Producida") > 0 THEN  MAX(A0."Suma_Cantidad_Producida")
            ELSE  SUM(T0."MENGE_GUT")
    END AS "Suma_Cantidad_Producida",
   CASE 
        WHEN MAX(A0."Suma_Cantidad_Producida") IS NULL OR MAX(A0."Suma_Cantidad_Producida") = 0 THEN 100.00
        ELSE 
            (MAX(A0."Suma_Cantidad_Producida") - MAX(A0."Suma_Cantidad_Lote")) * 100.0 / MAX(A0."Suma_Cantidad_Producida")
    END AS "Calidad"
    
FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
LEFT JOIN (
    SELECT
        P0."Orden",  
        P0."ItemCode", 
        P0."Orden" || P0."ItemCode" AS "Clave", 
        SUM(P0."Suma_Cantidad_Lote") As "Suma_Cantidad_Lote",
        SUM(P0."Suma_Cantidad_Producida") AS "Suma_Cantidad_Producida"
    FROM(
        SELECT 
            --T0."DocNum",
            --T0."DocDate",
            LEFT(T4."DistNumber",5) AS "Orden",
            T1."ItemCode",
            LEFT(T4."DistNumber",5) || T1."ItemCode" AS "Clave",
            T3."Quantity" As "Suma_Cantidad_Lote",
            T5."GEL_MENGE" AS "Suma_Cantidad_Producida"

        FROM OWTR T0
        INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
        INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
            AND T1."WhsCode" = T2."LocCode" 
            AND T2."DocType" = '67' 
            AND T1."LineNum" = T2."DocLine"
        INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
        INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
            AND CAST(T5."BELPOS_ID" AS VARCHAR) = (
                CASE 
                    WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3) 
                    WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3) 
                    ELSE SUBSTRING(T4."DistNumber",6,2) 
                END)
            AND T1."ItemCode" = T5."ItemCode"
        INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
        INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod"
        LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
        LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" 
            AND T5."BELPOS_ID" = T9."BELPOS_ID" 
            AND T4."DistNumber" = T9."BatchNum" 
            AND T9."CANCEL" != '1'

        WHERE T1."WhsCode" IN ('11PCD', '12PCD')  --'20PCD'
            AND T0."DocDate" > '2024-01-01'
            AND T0."CANCELED" = 'N' AND T1."Quantity" > 0
        GROUP BY
        T4."DistNumber", T1."ItemCode" , T3."Quantity", T5."GEL_MENGE"
    ) P0 
     GROUP BY P0."Orden", P0."ItemCode"
) A0 ON A0."Clave" = (T0."BELNR_ID" || T2."ItemCode")
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



    /* asi queda Query final */

SELECT
    T0."BELNR_ID" AS "Orden",
    T2."ItemCode" AS "Articulo",
    T0."BELNR_ID" || T2."ItemCode" AS "Clave",
    T2."ItemName" AS "Articulo_Descripcion",
    SUM(T0."MENGE_GUT") AS "Suma_Cantidad_OK",
    MAX(A0."Suma_Cantidad_Lote") AS "Cantidad_No_Conforme",
    CASE 
            WHEN MAX(A0."Suma_Cantidad_Producida") > 0 THEN  MAX(A0."Suma_Cantidad_Producida")
            ELSE  SUM(T0."MENGE_GUT")
    END AS "Suma_Cantidad_Producida",
   CASE 
        WHEN MAX(A0."Suma_Cantidad_Producida") IS NULL OR MAX(A0."Suma_Cantidad_Producida") = 0 THEN 100.00
        ELSE 
            (MAX(A0."Suma_Cantidad_Producida") - MAX(A0."Suma_Cantidad_Lote")) * 100.0 / MAX(A0."Suma_Cantidad_Producida")
    END AS "Calidad"
    
FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
LEFT JOIN (
    SELECT
        P0."Orden",  
        P0."ItemCode", 
        P0."Orden" || P0."ItemCode" AS "Clave", 
        SUM(P0."Suma_Cantidad_Lote") As "Suma_Cantidad_Lote",
        MAX(P0."Suma_Cantidad_Producida") AS "Suma_Cantidad_Producida"
        --SUM(P0."Suma_Cantidad_Producida") AS "Suma_Cantidad_Producida"
    FROM(
        SELECT 
            --T0."DocNum",
            --T0."DocDate",
           LEFT(T4."DistNumber",5) AS "Orden",
            T1."ItemCode",
            LEFT(T4."DistNumber",5) || T1."ItemCode" AS "Clave",
            T3."Quantity" As "Suma_Cantidad_Lote",
            T5."GEL_MENGE" AS "Suma_Cantidad_Producida"

        FROM OWTR T0
        INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
        INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
            AND T1."WhsCode" = T2."LocCode" 
            AND T2."DocType" = '67' 
            AND T1."LineNum" = T2."DocLine"
        INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
        INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
            AND CAST(T5."BELPOS_ID" AS VARCHAR) = (
                CASE 
                    WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3) 
                    WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3) 
                    ELSE SUBSTRING(T4."DistNumber",6,2) 
                END)
            AND T1."ItemCode" = T5."ItemCode"
        INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
        INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod"
        LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
        LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" 
            AND T5."BELPOS_ID" = T9."BELPOS_ID" 
            AND T4."DistNumber" = T9."BatchNum" 
            AND T9."CANCEL" != '1'

        WHERE T1."WhsCode" IN ('11PCD', '12PCD')  --'20PCD'
            AND T0."DocDate" > '2024-01-01'
            AND T0."CANCELED" = 'N' AND T1."Quantity" > 0
    ) P0 
     GROUP BY P0."Orden", P0."ItemCode"
) A0 ON A0."Clave" = (T0."BELNR_ID" || T2."ItemCode")
WHERE 
   T0."ANFZEIT" BETWEEN '2024-10-01' AND '2024-11-01' 
   --T0."ANFZEIT" > '2024-08-01' AND  T0."ANFZEIT" <= '2024-08-31'
   AND T0."BELNR_ID" = '30587'  --'29757'  '29818' --'30099' --'29757' -- '29409'
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


    /* 
    crystal report
    query final > 2024 con parametros de fecha inicio y fin 

    timpos de produccion > 2024 con parametros de fecha inicio y fin --listo

    query final tiempo produccion y traslado de cuarentena --pendiente 


     */

SELECT
    T0."BELNR_ID" AS "Orden",
    T2."ItemCode" AS "Articulo",
    T0."BELNR_ID" || T2."ItemCode" AS "Clave",
    T2."ItemName" AS "Articulo_Descripcion",
    SUM(T0."MENGE_GUT") AS "Suma_Cantidad_OK",
    MAX(A0."Suma_Cantidad_Lote") AS "Cantidad_No_Conforme",
    CASE 
            WHEN MAX(A0."Suma_Cantidad_Producida") > 0 THEN  MAX(A0."Suma_Cantidad_Producida")
            ELSE  SUM(T0."MENGE_GUT")
    END AS "Suma_Cantidad_Producida",
   CASE 
        WHEN MAX(A0."Suma_Cantidad_Producida") IS NULL OR MAX(A0."Suma_Cantidad_Producida") = 0 THEN 100.00
        ELSE 
            (MAX(A0."Suma_Cantidad_Producida") - MAX(A0."Suma_Cantidad_Lote")) * 100.0 / MAX(A0."Suma_Cantidad_Producida")
    END AS "Calidad"
    
FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
LEFT JOIN (
    SELECT
        P0."Orden",  
        P0."ItemCode", 
        P0."Orden" || P0."ItemCode" AS "Clave", 
        SUM(P0."Suma_Cantidad_Lote") As "Suma_Cantidad_Lote",
        MAX(P0."Suma_Cantidad_Producida") AS "Suma_Cantidad_Producida"
        --SUM(P0."Suma_Cantidad_Producida") AS "Suma_Cantidad_Producida"
    FROM(
        SELECT 
            --T0."DocNum",
            --T0."DocDate",
           LEFT(T4."DistNumber",5) AS "Orden",
            T1."ItemCode",
            LEFT(T4."DistNumber",5) || T1."ItemCode" AS "Clave",
            T3."Quantity" As "Suma_Cantidad_Lote",
            T5."GEL_MENGE" AS "Suma_Cantidad_Producida"

        FROM OWTR T0
        INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
        INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
            AND T1."WhsCode" = T2."LocCode" 
            AND T2."DocType" = '67' 
            AND T1."LineNum" = T2."DocLine"
        INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
        INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
            AND CAST(T5."BELPOS_ID" AS VARCHAR) = (
                CASE 
                    WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3) 
                    WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3) 
                    ELSE SUBSTRING(T4."DistNumber",6,2) 
                END)
            AND T1."ItemCode" = T5."ItemCode"
        INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
        INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod"
        LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
        LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" 
            AND T5."BELPOS_ID" = T9."BELPOS_ID" 
            AND T4."DistNumber" = T9."BatchNum" 
            AND T9."CANCEL" != '1'

        WHERE T1."WhsCode" IN ('11PCD', '12PCD')  --'20PCD'
            AND T0."DocDate" > '2024-01-01'
            AND T0."CANCELED" = 'N' AND T1."Quantity" > 0
    ) P0 
     GROUP BY P0."Orden", P0."ItemCode"
) A0 ON A0."Clave" = (T0."BELNR_ID" || T2."ItemCode")
WHERE 
    T0."ANFZEIT" > '2024-01-01' 
   --T0."ANFZEIT" BETWEEN '2024-10-01' AND '2024-11-01' 
   --T0."ANFZEIT" > '2024-08-01' AND  T0."ANFZEIT" <= '2024-08-31'
   --AND T0."BELNR_ID" = '30587'  --'29757'  '29818' --'30099' --'29757' -- '29409'
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


/* creacion de la vista del query final */
CREATE VIEW "SBO_FIGURETTI_PRO"."QUERYFINAL" ( 
    "Orden",
    "Articulo",
    "Fecha",
    "Clave",
    "Articulo_Descripcion",
    "Suma_Cantidad_OK",
    "Cantidad_No_Conforme",
    "Suma_Cantidad_Producida",
    "Calidad"
   ) AS (
    (
        SELECT
            T0."BELNR_ID" AS "Orden",
            T2."ItemCode" AS "Articulo",
            T0."ANFZEIT" AS "Fecha",
            T0."BELNR_ID" || T2."ItemCode" AS "Clave",
            T2."ItemName" AS "Articulo_Descripcion",
            SUM(T0."MENGE_GUT") AS "Suma_Cantidad_OK",
            MAX(A0."Suma_Cantidad_Lote") AS "Cantidad_No_Conforme",
            CASE 
                WHEN MAX(A0."Suma_Cantidad_Producida") > 0 THEN  MAX(A0."Suma_Cantidad_Producida")
                ELSE  SUM(T0."MENGE_GUT")
            END AS "Suma_Cantidad_Producida",
            CASE 
                WHEN MAX(A0."Suma_Cantidad_Producida") IS NULL OR MAX(A0."Suma_Cantidad_Producida") = 0 THEN 100.00
                ELSE 
                    (MAX(A0."Suma_Cantidad_Producida") - MAX(A0."Suma_Cantidad_Lote")) * 100.0 / MAX(A0."Suma_Cantidad_Producida")
            END AS "Calidad"
    
        FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
        INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
        INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
        INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
        LEFT JOIN (
            SELECT
                P0."Orden",  
                P0."ItemCode", 
                P0."Orden" || P0."ItemCode" AS "Clave", 
                SUM(P0."Suma_Cantidad_Lote") As "Suma_Cantidad_Lote",
                MAX(P0."Suma_Cantidad_Producida") AS "Suma_Cantidad_Producida"
                --SUM(P0."Suma_Cantidad_Producida") AS "Suma_Cantidad_Producida"
            FROM(
                SELECT 
                    --T0."DocNum",
                    --T0."DocDate",
                LEFT(T4."DistNumber",5) AS "Orden",
                    T1."ItemCode",
                    LEFT(T4."DistNumber",5) || T1."ItemCode" AS "Clave",
                    T3."Quantity" As "Suma_Cantidad_Lote",
                    T5."GEL_MENGE" AS "Suma_Cantidad_Producida"

                FROM OWTR T0
                INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
                INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
                    AND T1."WhsCode" = T2."LocCode" 
                    AND T2."DocType" = '67' 
                    AND T1."LineNum" = T2."DocLine"
                INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
                INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
                INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
                    AND CAST(T5."BELPOS_ID" AS VARCHAR) = (
                        CASE 
                            WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3) 
                            WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3) 
                            ELSE SUBSTRING(T4."DistNumber",6,2) 
                        END)
                    AND T1."ItemCode" = T5."ItemCode"
                INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
                INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod"
                LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
                LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" 
                    AND T5."BELPOS_ID" = T9."BELPOS_ID" 
                    AND T4."DistNumber" = T9."BatchNum" 
                    AND T9."CANCEL" != '1'

                WHERE T1."WhsCode" IN ('11PCD', '12PCD')  --'20PCD'
                    AND T0."DocDate" > '2024-01-01'
                    AND T0."CANCELED" = 'N' AND T1."Quantity" > 0
            ) P0 
            GROUP BY P0."Orden", P0."ItemCode"
        ) A0 ON A0."Clave" = (T0."BELNR_ID" || T2."ItemCode")
        WHERE 
            T0."ANFZEIT" > '2024-01-01' 
        --T0."ANFZEIT" BETWEEN '2024-10-01' AND '2024-11-01' 
        --T0."ANFZEIT" > '2024-08-01' AND  T0."ANFZEIT" <= '2024-08-31'
        --AND T0."BELNR_ID" = '30587'  --'29757'  '29818' --'30099' --'29757' -- '29409'
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
        
    )
) WITH READ ONLY

/* REVISAR 30912 AGRUPAR SOLO POR LA FECHA LA SUMA CANT OK */

/* INDICADOR DE CALIDAD ASI ES EL QUERY FINAL */
SELECT
    MAX(T0."ANFZEIT") AS "Fecha",
    T0."BELNR_ID" AS "Orden",
    T2."ItemCode" AS "Articulo",
    T0."BELNR_ID" || T2."ItemCode" AS "Clave",
    MAX(T2."ItemName") AS "Articulo_Descripcion",
    SUM(T0."MENGE_GUT") AS "Suma_Cantidad_OK",
    MAX(A0."Suma_Cantidad_Lote") AS "Cantidad_No_Conforme",
    CASE 
            WHEN MAX(A0."Suma_Cantidad_Producida") > 0 THEN  MAX(A0."Suma_Cantidad_Producida")
            ELSE  SUM(T0."MENGE_GUT")
    END AS "Suma_Cantidad_Producida",
   CASE 
        WHEN MAX(A0."Suma_Cantidad_Producida") IS NULL OR MAX(A0."Suma_Cantidad_Producida") = 0 THEN 100.00
        ELSE 
            (MAX(A0."Suma_Cantidad_Producida") - MAX(A0."Suma_Cantidad_Lote")) * 100.0 / MAX(A0."Suma_Cantidad_Producida")
    END AS "Calidad"
    
FROM BEAS_ARBZEIT T0  --Recibo del tiempo de producción
INNER JOIN BEAS_FTHAUPT T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Órdenes de trabajo
INNER JOIN BEAS_FTPOS T2 ON T0."BELNR_ID" = T2."BELNR_ID" AND T0."BELPOS_ID" = T2."BELPOS_ID"  --Orden de trabajo Posición
INNER JOIN BEAS_FTAPL T3 ON T0."BELNR_ID" = T3."BELNR_ID" AND T0."BELPOS_ID" = T3."BELPOS_ID" AND T0."POS_ID" = T3."POS_ID" --Enrutamiento de producción
LEFT JOIN (
    SELECT
        P0."Orden",  
        P0."ItemCode", 
        P0."Orden" || P0."ItemCode" AS "Clave", 
        SUM(P0."Suma_Cantidad_Lote") As "Suma_Cantidad_Lote",
        MAX(P0."Suma_Cantidad_Producida") AS "Suma_Cantidad_Producida"
        --SUM(P0."Suma_Cantidad_Producida") AS "Suma_Cantidad_Producida"
    FROM(
        SELECT 
            --T0."DocNum",
            --T0."DocDate",
           LEFT(T4."DistNumber",5) AS "Orden",
            T1."ItemCode",
            LEFT(T4."DistNumber",5) || T1."ItemCode" AS "Clave",
            T3."Quantity" As "Suma_Cantidad_Lote",
            T5."GEL_MENGE" AS "Suma_Cantidad_Producida"

        FROM OWTR T0
        INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
        INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
            AND T1."WhsCode" = T2."LocCode" 
            AND T2."DocType" = '67' 
            AND T1."LineNum" = T2."DocLine"
        INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
        INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
            AND CAST(T5."BELPOS_ID" AS VARCHAR) = (
                CASE 
                    WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3) 
                    WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3) 
                    ELSE SUBSTRING(T4."DistNumber",6,2) 
                END)
            AND T1."ItemCode" = T5."ItemCode"
        INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
        INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod"
        LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
        LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" 
            AND T5."BELPOS_ID" = T9."BELPOS_ID" 
            AND T4."DistNumber" = T9."BatchNum" 
            AND T9."CANCEL" != '1'

        WHERE T1."WhsCode" IN ('11PCD', '12PCD')  --'20PCD'
            AND T0."DocDate" > '2024-01-01'
            AND T0."CANCELED" = 'N' AND T1."Quantity" > 0
    ) P0 
     GROUP BY P0."Orden", P0."ItemCode"
) A0 ON A0."Clave" = (T0."BELNR_ID" || T2."ItemCode")
WHERE 
   T0."ANFZEIT" BETWEEN {?Fecha_Inicio} AND {?Fecha_Fin}
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
    T2."ItemCode";
    --T2."ItemName";








    

    