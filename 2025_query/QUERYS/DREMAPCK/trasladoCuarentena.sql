SELECT DISTINCT  
    P0."DocNum", P0."DocDate", P0."Orden", P0."Posicion", P0."ItemCode", P0."Dscription", 
    P0."Grupo_Articulo", P0."Unidad_Medida", P0."Numero_Lote", P0."Desde_Bodega", P0."A_Bodega",
    P0."Proceso", P0."Motivo_Traslado", P0."Peso_Unidad", P0."Precio", 
    --P0."Cantidad_Lote",
    P1."Quantity" AS "Cantidad_Lote", 
    P0."Cantidad", 
    P0."Cantidad_Producida", P0."Costo", P0."KG", P0."%_Afectado", P1."PERS_ID", P1."Operador", P1."Recurso" FROM 
    ( 
    SELECT 
        T0."DocNum",
        T0."DocDate",
        LEFT(T4."DistNumber",5) AS "Orden",
        CASE WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3)
        WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3)
        ELSE SUBSTRING(T4."DistNumber",6,2) END AS "Posicion",
        T1."ItemCode",
        T1."Dscription",
        T7."ItmsGrpNam" AS "Grupo_Articulo",
        T1."unitMsr" AS "Unidad_Medida",
        T4."DistNumber" AS "Numero_Lote",
        T1."FromWhsCod" AS "Desde_Bodega",
        T1."WhsCode" AS "A_Bodega",
        COALESCE(T8."U_DPE_PROCESS", 'S/M') AS "Proceso",
        COALESCE(T8."Name", 'S/M') AS "Motivo_Traslado",
        T6."U_SYP_PESOBRUTO" AS "Peso_Unidad",
        T1."StockPrice" AS "Precio",
        T9."MENGE_GUT" AS "Cantidad_Lote",
        T3."Quantity" As "Cantidad",
        T5."GEL_MENGE" AS "Cantidad_Producida",
        (T1."StockPrice" * T3."Quantity") AS "Costo",
        CASE
            WHEN T1."unitMsr" = 'KG' THEN T3."Quantity"
            WHEN T1."unitMsr" = 'PACK' THEN (T6."U_SYP_UPPL" * T6."U_SYP_PESOBRUTO" * T3."Quantity")
            ELSE (T6."U_SYP_PESOBRUTO" * T3."Quantity") 
        END AS "KG",
        (T3."Quantity"/T5."GEL_MENGE") AS "%_Afectado",
        T9."PERS_ID", T9."DisplayName", T9."APLATZ_ID" as "RESOURCE"
        --, T9.*
        FROM OWTR T0
        INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
        INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND T1."WhsCode" = T2."LocCode" AND T2."DocType" = '67' AND T1."LineNum" = T2."DocLine"
        INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
        INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
        AND CAST(T5."BELPOS_ID" AS VARCHAR) = (CASE WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3) WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3) ELSE SUBSTRING(T4."DistNumber",6,2) END)
        AND T1."ItemCode" = T5."ItemCode"
        INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
        INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod"
        LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" AND T5."BELPOS_ID" = T9."BELPOS_ID" AND T4."DistNumber" = T9."BatchNum" 
        AND T9."CANCEL" != '1'

        WHERE T1."WhsCode" IN ('11PCD', '12PCD', '20PCD')
        AND T0."DocDate" > '2024-01-01'
        --AND T0."DocNum" = '24002124'
        --AND T0."UserSign" = '41'
        AND T0."CANCELED" = 'N' AND T1."Quantity" > 0 
    ) P0 
    INNER JOIN ( 
        SELECT
            T7."BELNR_ID" as "Orden", 
            T7."BELPOS_ID" as "Pos", 
            T6."ItemCode", 
            T4."DistNumber" as "LOTE", 
            T8."PERS_ID", 
            T8."DisplayName" as "Operador", 
            T8."APLATZ_ID" as "Recurso", 
            T1."Quantity"
        FROM OIGN T0 --Entrada de mercancías
        INNER JOIN IGN1 T1 ON T0."DocEntry" = T1."DocEntry" --linea Entrada de mercancías
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T7 on T7."BELNR_ID" = T1."U_beas_belnrid" --Work order Position
        INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND T1."WhsCode" = T2."LocCode" AND T2."DocType" = '59' --Log de transacciones de inventario
        INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry" --linea Log de transacciones de inventario
        LEFT JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry" --Datos maestros de los números de serie (lotes)
        INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode" -- maestro de articulo
        INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T8 on T8."BELNR_ID" = T7."BELNR_ID"  and T8."BELPOS_ID" = T7."BELPOS_ID" and T8."BUCHNR_ID" = T1."U_beas_basedocentry" --Production Time Recipt

        where  T8."APLATZ_ID" not like 'GM%' 
    )  P1 on  CAST(P1."Orden" as VARCHAR) = P0."Orden" and P1."Pos" = P0."Posicion" and P1."LOTE" = P0."Numero_Lote"
    --WHERE P0."Orden" = '28935'  25001907



    -- ****************************


    SELECT
            T7."BELNR_ID" as "Orden", 
            T7."BELPOS_ID" as "Pos", 
            T6."ItemCode", 
            T4."DistNumber" as "LOTE", 
            T8."PERS_ID", 
            T8."DisplayName" as "Operador", 
            T8."APLATZ_ID" as "Recurso", 
            T1."Quantity"
FROM OIGN T0 --Entrada de mercancías
INNER JOIN IGN1 T1 ON T0."DocEntry" = T1."DocEntry" --linea Entrada de mercancías
INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T7 on T7."BELNR_ID" = T1."U_beas_belnrid" --Work order Position
INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND T1."WhsCode" = T2."LocCode" AND T2."DocType" = '59' --Log de transacciones de inventario
INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry" --linea Log de transacciones de inventario
LEFT JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry" --Datos maestros de los números de serie (lotes)
INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode" -- maestro de articulo
INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T8 on T8."BELNR_ID" = T7."BELNR_ID"  and T8."BELPOS_ID" = T7."BELPOS_ID" and T8."BUCHNR_ID" = T1."U_beas_basedocentry" --Production Time Recipt

        WHERE  T8."APLATZ_ID" not like 'GM%'
        AND T7."BELNR_ID" = '25000139'


-- ***********************************************************************
SELECT 
T0."DocNum",
T0."DocDate",
LEFT(T4."DistNumber",5) AS "Orden",
CASE WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3)
WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3)
ELSE SUBSTRING(T4."DistNumber",6,2) END AS "Posicion",
T1."ItemCode",
T1."Dscription",
T7."ItmsGrpNam" AS "Grupo_Articulo",
T1."unitMsr" AS "Unidad_Medida",
T4."DistNumber" AS "Numero_Lote",
T1."FromWhsCod" AS "Desde_Bodega",
T1."WhsCode" AS "A_Bodega",
COALESCE(T8."U_DPE_PROCESS", 'S/M') AS "Proceso",
COALESCE(T8."Name", 'S/M') AS "Motivo_Traslado",
T6."U_SYP_PESOBRUTO" AS "Peso_Unidad",
T1."StockPrice" AS "Precio",
T9."MENGE_GUT" AS "Cantidad_Lote",
T3."Quantity" As "Cantidad",
T5."GEL_MENGE" AS "Cantidad_Producida",
(T1."StockPrice" * T3."Quantity") AS "Costo",
CASE
    WHEN T1."unitMsr" = 'KG' THEN T3."Quantity"
    WHEN T1."unitMsr" = 'PACK' THEN (T6."U_SYP_UPPL" * T6."U_SYP_PESOBRUTO" * T3."Quantity")
    ELSE (T6."U_SYP_PESOBRUTO" * T3."Quantity") 
END AS "KG",
(T3."Quantity"/T5."GEL_MENGE") AS "%_Afectado",
T9."PERS_ID", T9."DisplayName", T9."APLATZ_ID" as "RESOURCE"
--, T9.*
FROM OWTR T0 --Traslado de stocks
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"  --linea Traslado de stocks
INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND T1."WhsCode" = T2."LocCode" AND T2."DocType" = '67' AND T1."LineNum" = T2."DocLine" --Log de transacciones de inventario
INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry" --linea Log de transacciones de inventario
INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry" ----Datos maestros de los números de serie (lotes)
INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
AND CAST(T5."BELPOS_ID" AS VARCHAR) = (CASE WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3) WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3) ELSE SUBSTRING(T4."DistNumber",6,2) END) AND T1."ItemCode" = T5."ItemCode" ----Work order Position
INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode" ---- maestro de articulo
INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod" --Grupos de artículos
LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code" --motivo de traslado de cuarentena
INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" AND T5."BELPOS_ID" = T9."BELPOS_ID" AND T4."DistNumber" = T9."BatchNum" AND T9."CANCEL" != '1' ----Production Time Recipt

WHERE T1."WhsCode" IN ('11PCD', '12PCD', '20PCD')
AND T0."DocDate" > '2024-01-01'
--AND T0."DocNum" = '24002124'
--AND T0."UserSign" = '41'
AND T0."CANCELED" = 'N' AND T1."Quantity" > 0 


-- ************************************MOVIMIENTOS CUARENTENAS************************************************
--ESTO ES LIBERACION

SELECT
    T0."DocDate",
    T0."DocNum",
    T1."ItemCode",
    T1."Dscription",
    T1."WhsCode" AS "A_Bodega",
    T1."FromWhsCod" AS "Desde_Bodega",
    T1."unitMsr" AS "Unidad_Medida",
    T4."DistNumber" AS "Numero_Lote",
    COALESCE(T5."Name", 'S/M') AS "Motivo_Traslado",
    T3."Quantity" AS "Cantidad",
    T1."StockPrice" AS "Costo_Articulo",
    T1."Price" AS "Precio",
    T1."InvQty" AS "Cantidad_UM_Inv",
    T3."Quantity" * T1."Price" AS "Subtotal",
    T6."SlpName" AS "Responsable",
    T0."Comments" AS "Comentario",
    T4."CreateDate" AS "FechaFabricacion"
    
FROM OWTR T0  ----Traslado de stocks
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
    AND T1."WhsCode" = T2."LocCode" 
    AND T2."DocType" = '67' 
    AND T1."LineNum" = T2."DocLine" 
INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry" 
    AND T1."ItemCode"=T4."ItemCode" 
    AND T3."SysNumber" = T4."SysNumber"
LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T5 ON T1."U_SYP_OBS_ITEM" = T5."Code"
LEFT JOIN OSLP T6 ON T0."SlpCode" = T6."SlpCode"
WHERE 
    T1."FromWhsCod" IN ('11PCD', '12PCD')
    AND T0."DocNum" = '25000139'
ORDER BY T0."DocDate" DESC;



-- ***************************************************************************************
SELECT 
    -- T0."UpdateDate",
    T0."DocNum",
    T0."DocDate",
    T0."TaxDate",
    LEFT(T4."DistNumber",5) AS "Orden",
    CASE 
        WHEN LENGTH(T4."DistNumber") = 10 THEN SUBSTRING(T4."DistNumber",6,3)
        WHEN LENGTH(T4."DistNumber") = 14 THEN SUBSTRING(T4."DistNumber",6,3)
        ELSE SUBSTRING(T4."DistNumber",6,2) 
    END AS "Posicion",
    T1."ItemCode",
    T1."Dscription",
    T7."ItmsGrpNam" AS "Grupo_Articulo",
    T1."unitMsr" AS "Unidad_Medida",
    T4."DistNumber" AS "Numero_Lote",
    T1."FromWhsCod" AS "Desde_Bodega",
    T1."WhsCode" AS "A_Bodega",
    COALESCE(T8."U_DPE_PROCESS", 'S/M') AS "Proceso",
    COALESCE(T8."Name", 'S/M') AS "Motivo_Traslado",
    T6."U_SYP_PESOBRUTO" AS "Peso_Unidad",
    T1."StockPrice" AS "Precio",
    T9."MENGE_GUT" AS "Cantidad_Lote",
    T3."Quantity" As "Cantidad",
    T5."GEL_MENGE" AS "Cantidad_Producida",
    (T1."StockPrice" * T3."Quantity") AS "Costo",
    CASE
        WHEN T1."unitMsr" = 'KG' THEN T3."Quantity"
        WHEN T1."unitMsr" = 'PACK' THEN (T6."U_SYP_UPPL" * T6."U_SYP_PESOBRUTO" * T3."Quantity")
        ELSE (T6."U_SYP_PESOBRUTO" * T3."Quantity") 
    END AS "KG",
    (T3."Quantity"/T5."GEL_MENGE") AS "%_Afectado",
    T9."PERS_ID", 
    T9."DisplayName", 
    T9."APLATZ_ID" as "RESOURCE",
    -- Subconsulta para obtener la fecha de liberación por lote
  (
    SELECT MIN(Lib."DocDate")
    FROM OWTR Lib
    INNER JOIN WTR1 LibL ON Lib."DocEntry" = LibL."DocEntry"
    INNER JOIN OITL LibT ON Lib."DocEntry" = LibT."DocEntry" 
        AND LibL."WhsCode" = LibT."LocCode" 
        AND LibT."DocType" = '67' 
        AND LibL."LineNum" = LibT."DocLine"
    INNER JOIN ITL1 LibITL ON LibT."LogEntry" = LibITL."LogEntry"
    INNER JOIN OBTN LibOBTN ON LibITL."MdAbsEntry" = LibOBTN."AbsEntry"
        AND LibITL."ItemCode" = LibOBTN."ItemCode"
        AND LibITL."SysNumber" = LibOBTN."SysNumber"
    WHERE 
        LibL."FromWhsCod" IN ('11PCD', '12PCD') -- filtro para liberación
        AND LibOBTN."DistNumber" = T4."DistNumber" 
        AND Lib."CANCELED" = 'N'
) AS "Fecha_Liberacion"

FROM OWTR T0 -- Traslado de stocks
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"  -- línea Traslado de stocks
INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
    AND T1."WhsCode" = T2."LocCode" 
    AND T2."DocType" = '67' 
    AND T1."LineNum" = T2."DocLine" -- Log de transacciones de inventario
INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry" -- línea Log de transacciones de inventario
INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry" -- Datos maestros de los números de serie (lotes)
INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
    AND CAST(T5."BELPOS_ID" AS VARCHAR) = (
        CASE 
            WHEN LENGTH(T4."DistNumber") = 10 THEN SUBSTRING(T4."DistNumber",6,3) 
            WHEN LENGTH(T4."DistNumber") = 14 THEN SUBSTRING(T4."DistNumber",6,3) 
            ELSE SUBSTRING(T4."DistNumber",6,2) 
        END
    ) 
    AND T1."ItemCode" = T5."ItemCode" -- Work order Position
INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode" -- maestro de artículo
INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod" -- Grupos de artículos
LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code" -- motivo de traslado de cuarentena
INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" 
    AND T5."BELPOS_ID" = T9."BELPOS_ID" 
    AND T4."DistNumber" = T9."BatchNum" 
    AND T9."CANCEL" != '1' -- Production Time Receipt
WHERE T1."WhsCode" IN ('11PCD', '12PCD', '20PCD')
    AND T0."DocDate" > '2024-01-01'
    AND T4."DistNumber" = '31784102501220705' -- filtro por lote específico
    AND T0."CANCELED" = 'N' 
    AND T1."Quantity" > 0;


    -- **********************************************************************************************************************
    /* REVISAR CON WILIAN */
SELECT 
    -- T0."UpdateDate",
    T0."DocNum",
    T0."DocDate",
    T0."TaxDate",
      -- Subconsulta para obtener la fecha de liberación por lote
  (
    SELECT MAX(Lib."DocDate")
    FROM OWTR Lib
    INNER JOIN WTR1 LibL ON Lib."DocEntry" = LibL."DocEntry"
    INNER JOIN OITL LibT ON Lib."DocEntry" = LibT."DocEntry" 
        AND LibL."WhsCode" = LibT."LocCode" 
        AND LibT."DocType" = '67' 
        AND LibL."LineNum" = LibT."DocLine"
    INNER JOIN ITL1 LibITL ON LibT."LogEntry" = LibITL."LogEntry"
    INNER JOIN OBTN LibOBTN ON LibITL."MdAbsEntry" = LibOBTN."AbsEntry"
        AND LibITL."ItemCode" = LibOBTN."ItemCode"
        AND LibITL."SysNumber" = LibOBTN."SysNumber"
    WHERE 
        LibL."FromWhsCod" IN ('11PCD', '12PCD') -- filtro para liberación
        AND LibOBTN."DistNumber" = T4."DistNumber" 
        AND Lib."CANCELED" = 'N'
) AS "Fecha_Liberacion",
    LEFT(T4."DistNumber",5) AS "Orden",
    CASE 
        WHEN LENGTH(T4."DistNumber") = 10 THEN SUBSTRING(T4."DistNumber",6,3)
        WHEN LENGTH(T4."DistNumber") = 14 THEN SUBSTRING(T4."DistNumber",6,3)
        ELSE SUBSTRING(T4."DistNumber",6,2) 
    END AS "Posicion",
    T1."ItemCode",
    T1."Dscription",
    T7."ItmsGrpNam" AS "Grupo_Articulo",
    T1."unitMsr" AS "Unidad_Medida",
    T4."DistNumber" AS "Numero_Lote",
    T1."FromWhsCod" AS "Desde_Bodega",
    T1."WhsCode" AS "A_Bodega",
    COALESCE(T8."U_DPE_PROCESS", 'S/M') AS "Proceso",
    COALESCE(T8."Name", 'S/M') AS "Motivo_Traslado",
    T6."U_SYP_PESOBRUTO" AS "Peso_Unidad",
    T1."StockPrice" AS "Precio",
    T9."MENGE_GUT" AS "Cantidad_Lote",
    T3."Quantity" As "Cantidad",
    T5."GEL_MENGE" AS "Cantidad_Producida",
    (T1."StockPrice" * T3."Quantity") AS "Costo",
    CASE
        WHEN T1."unitMsr" = 'KG' THEN T3."Quantity"
        WHEN T1."unitMsr" = 'PACK' THEN (T6."U_SYP_UPPL" * T6."U_SYP_PESOBRUTO" * T3."Quantity")
        ELSE (T6."U_SYP_PESOBRUTO" * T3."Quantity") 
    END AS "KG",
    (T3."Quantity"/T5."GEL_MENGE") AS "%_Afectado",
    T9."PERS_ID", 
    T9."DisplayName", 
    T9."APLATZ_ID" as "RESOURCE"
  

FROM OWTR T0 -- Traslado de stocks
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"  -- línea Traslado de stocks
INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
    AND T1."WhsCode" = T2."LocCode" 
    AND T2."DocType" = '67' 
    AND T1."LineNum" = T2."DocLine" -- Log de transacciones de inventario
INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry" -- línea Log de transacciones de inventario
INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry" -- Datos maestros de los números de serie (lotes)
INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
    AND CAST(T5."BELPOS_ID" AS VARCHAR) = (
        CASE 
            WHEN LENGTH(T4."DistNumber") = 10 THEN SUBSTRING(T4."DistNumber",6,3) 
            WHEN LENGTH(T4."DistNumber") = 14 THEN SUBSTRING(T4."DistNumber",6,3) 
            ELSE SUBSTRING(T4."DistNumber",6,2) 
        END
    ) 
    AND T1."ItemCode" = T5."ItemCode" -- Work order Position
INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode" -- maestro de artículo
INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod" -- Grupos de artículos
LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code" -- motivo de traslado de cuarentena
INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" 
    AND T5."BELPOS_ID" = T9."BELPOS_ID" 
    AND T4."DistNumber" = T9."BatchNum" 
    AND T9."CANCEL" != '1' -- Production Time Receipt
WHERE T1."WhsCode" IN ('11PCD', '12PCD', '20PCD')
    AND T0."DocDate" > '2024-01-01'
    --AND T4."DistNumber" = '31784102501220705' -- filtro por lote específico
    AND T0."CANCELED" = 'N' 
    AND T1."Quantity" > 0;