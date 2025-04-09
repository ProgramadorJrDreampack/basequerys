/*

el FORMATO de Traslados de la bodega 12 a la 20 (materiales para destrucción) 
Este documento es auditable y reemplaza el ACTA DE DESTRUCCIÓN. 

El cambio consiste en: 
-	Incluir LOTE por producto  --añadir al detalle  --LISTO
-	Motivo de la destrucción. Pro producto --añadir al detalle  --LISTO
-	Adicional podemos omitir la parte de REPRESENTANTE DE VEN, ahí aparece el nombre de Karla Almeida  --sacar
-	Me gustaría tener un espacio para colocar al RESPONSABLE de generar la solicitud.  -- remplazando  REPRESENTANTE DE VEN
-	 Y el espacio de comentarios --listo

-- anexos "imagenes"

  filtro = inicio y fin --NO 
    numero 

 */

--  OWTR

--11 kilo y 12 unidades a la 20

/* CON ANEXOS */
SELECT
 T0."DocNum", 
 T1."ItemCode", 
 T0."Attachment", 
 T2.*, 
 T3.* 
FROM "SBO_FIGURETTI_PRO"."OWTR"  T0 
INNER JOIN 
    "SBO_FIGURETTI_PRO"."WTR1"  T1 ON T0."DocEntry" = T1."DocEntry"
 LEFT JOIN 
    "SBO_FIGURETTI_PRO"."OATC" T2 ON T0."AtcEntry" = T2."AbsEntry"
LEFT JOIN 
    "SBO_FIGURETTI_PRO"."ATC1" T3 ON T2."AbsEntry" = T3."AbsEntry" 
WHERE T0."DocNum" = '24005870'

/* AQUI SACO LAS 4 IMAGEN DE NUM 24005870 */
SELECT 
    --T0."DocNum", 
    --T1."ItemCode",
    T3."Line",
    MAX(T3."FileName") AS "FileName", 
    MAX(T3."FileExt") AS "FileExt",  
    MAX(T3."Date") AS "Date",  
    MAX(TO_NVARCHAR(T3."srcPath")) AS "ViaAccesoFuente", 
    MAX(TO_NVARCHAR(T3."trgtPath")) AS "ViaAccesoDestino",
     MAX(TO_NVARCHAR(T3."trgtPath") || '\' || T3."FileName" || '.' || T3."FileExt") AS "UrlImage"
FROM 
    "SBO_FIGURETTI_PRO"."OWTR" T0 
INNER JOIN 
    "SBO_FIGURETTI_PRO"."WTR1" T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN 
    "SBO_FIGURETTI_PRO"."OATC" T2 ON T0."AtcEntry" = T2."AbsEntry"
INNER JOIN 
    "SBO_FIGURETTI_PRO"."ATC1" T3 ON T2."AbsEntry" = T3."AbsEntry"
WHERE 
    T0."DocNum" = '24005870'
GROUP BY 
    --T0."DocNum", 
    --T1."ItemCode",
    T3."Line";

url = \\10.0.0.35\AnexosDPE\PLANAS BURGER LIBERADO.jpeg


/* solo la url image */
SELECT 
    MAX(TO_NVARCHAR(T3."trgtPath") || '\' || T3."FileName" || '.' || T3."FileExt") AS "UrlImage"
FROM 
    "SBO_FIGURETTI_PRO"."OWTR" T0 
INNER JOIN 
    "SBO_FIGURETTI_PRO"."WTR1" T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN 
    "SBO_FIGURETTI_PRO"."OATC" T2 ON T0."AtcEntry" = T2."AbsEntry"
INNER JOIN 
    "SBO_FIGURETTI_PRO"."ATC1" T3 ON T2."AbsEntry" = T3."AbsEntry"
WHERE 
    T0."DocNum" = '24005870'
GROUP BY 
    T3."Line";

/* NEW QUERY DE TRASLADO DE LA 11PCD ,12PCD A LA 20PCD */

SELECT 
    P0."DocNum", 
    P0."DocDate", 
    P0."Orden", 
    P0."Posicion", 
    P0."ItemCode", 
    P0."Dscription", 
    P0."Grupo_Articulo", 
    P0."Unidad_Medida", 
    P0."Numero_Lote", 
    P0."Desde_Bodega", 
    P0."A_Bodega",
    P0."Proceso", 
    P0."Motivo_Traslado", 
    P0."Peso_Unidad", 
    P0."Precio", 
    P0."PrecioInfo",
    P0."Cantidad_Lote", 
    P0."Cantidad_Producida", 
    P0."Costo", 
    P0."KG", 
    P0."%_Afectado", 
    P1."PERS_ID", 
    P1."Operador", 
    P1."Recurso",
    P0."Subtotal",
    P0."Responsable",
    P0."Comentario",
    P1."FechaFabricacion"
   
    FROM ( 
        SELECT 
            T0."DocNum",
            T0."DocDate",
            LEFT(T4."DistNumber",5) AS "Orden",
            CASE 
                WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3)
                WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3)
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
            T3."Quantity" As "Cantidad_Lote",
            T5."GEL_MENGE" AS "Cantidad_Producida",
            (T1."StockPrice" * T3."Quantity") AS "Costo",
            CASE
                WHEN T1."unitMsr" = 'KG' THEN T3."Quantity"
                WHEN T1."unitMsr" = 'PACK' THEN (T6."U_SYP_UPPL" * T6."U_SYP_PESOBRUTO" * T3."Quantity")
                ELSE (T6."U_SYP_PESOBRUTO" * T3."Quantity") 
            END AS "KG",
            (T3."Quantity"/T5."GEL_MENGE") AS "%_Afectado",
            T9."PERS_ID", T9."DisplayName", T9."APLATZ_ID" as "RESOURCE",
            T1."Price" AS "PrecioInfo",
            T3."Quantity" * T1."Price" AS "Subtotal",
            T10."SlpName" AS "Responsable",
            T0."Comments" AS "Comentario"--,
            --T4."MnfDate" AS "FechaFabricacion"
            

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
        LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" AND T5."BELPOS_ID" = T9."BELPOS_ID" AND T4."DistNumber" = T9."BatchNum" AND T9."CANCEL" != '1'
        LEFT JOIN OSLP T10 ON T0."SlpCode" = T10."SlpCode"

        WHERE --T1."WhsCode" IN ('11PCD', '12PCD', '20PCD')

        (
            T1."FromWhsCod" IN ('11PCD', '12PCD') AND  -- Bodegas de origen
            T1."WhsCode" = '20PCD')  -- Bodega de destino
        AND T0."DocDate" > '2024-01-01'
        AND T0."DocNum" = '24005870' --'24002124'
        --AND T0."UserSign" = '41'
        AND T0."CANCELED" = 'N' AND T1."Quantity" > 0 ) P0 
INNER JOIN ( 
    SELECT
        T7."BELNR_ID" as "Orden", 
        T7."BELPOS_ID" as "Pos", 
        T6."ItemCode", 
        T4."DistNumber" as "LOTE", 
        T8."PERS_ID", 
        T8."DisplayName" as "Operador", 
        T8."APLATZ_ID" as "Recurso", 
        T1."Quantity",
        T8."ANFZEIT" AS "FechaFabricacion"
    FROM OIGN T0
    INNER JOIN IGN1 T1 ON T0."DocEntry" = T1."DocEntry"
    INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T7 on T7."BELNR_ID" = T1."U_beas_belnrid"
    INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND T1."WhsCode" = T2."LocCode" AND T2."DocType" = '59'
    INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
    LEFT JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
    INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
    INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T8 on T8."BELNR_ID" = T7."BELNR_ID"  and T8."BELPOS_ID" = T7."BELPOS_ID" and T8."BUCHNR_ID" = T1."U_beas_basedocentry"
    WHERE T8."APLATZ_ID" NOT LIKE 'GM%' 
)  P1 ON CAST(P1."Orden" as VARCHAR) = P0."Orden" AND P1."Pos" = P0."Posicion" AND P1."LOTE" = P0."Numero_Lote"

/* ************* */
SELECT * FROM "SBO_FIGURETTI_PRO"."TRASLADO_BODEGA_11_12_A_20" 
WHERE "TRASLADO_BODEGA_11_12_A_20"."DocNum" =  {?DocNum@}



/* vamos a crear una vista */
DROP VIEW "SBO_FIGURETTI_PRO"."TRASLADO_BODEGA_11_12_A_20";

CREATE VIEW "SBO_FIGURETTI_PRO"."TRASLADO_BODEGA_11_12_A_20" (
    "DocNum", 
    "DocDate", 
    "Orden", 
    "Posicion", 
    "ItemCode", 
    "Dscription", 
    "Grupo_Articulo", 
    "Unidad_Medida", 
    "Numero_Lote", 
    "Desde_Bodega", 
    "A_Bodega",
    "Proceso", 
    "Motivo_Traslado", 
    "Peso_Unidad", 
    "Precio", 
    "PrecioInfo",
    "Cantidad_Lote", 
    "Cantidad_Producida", 
    "Costo", 
    "KG", 
    "%_Afectado", 
    "PERS_ID", 
    "Operador", 
    "Recurso" 
) AS (

    (
        SELECT 
            P0."DocNum", 
            P0."DocDate", 
            P0."Orden", 
            P0."Posicion", 
            P0."ItemCode", 
            P0."Dscription", 
            P0."Grupo_Articulo", 
            P0."Unidad_Medida", 
            P0."Numero_Lote", 
            P0."Desde_Bodega", 
            P0."A_Bodega",
            P0."Proceso", 
            P0."Motivo_Traslado", 
            P0."Peso_Unidad", 
            P0."Precio", 
            P0."PrecioInfo",
            P0."Cantidad_Lote", 
            P0."Cantidad_Producida", 
            P0."Costo", 
            P0."KG", 
            P0."%_Afectado", 
            P1."PERS_ID", 
            P1."Operador", 
            P1."Recurso" 
            FROM ( 
                SELECT 
                    T0."DocNum",
                    T0."DocDate",
                    LEFT(T4."DistNumber",5) AS "Orden",
                    CASE 
                        WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3)
                        WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3)
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
                    T3."Quantity" As "Cantidad_Lote",
                    T5."GEL_MENGE" AS "Cantidad_Producida",
                    (T1."StockPrice" * T3."Quantity") AS "Costo",
                    CASE
                        WHEN T1."unitMsr" = 'KG' THEN T3."Quantity"
                        WHEN T1."unitMsr" = 'PACK' THEN (T6."U_SYP_UPPL" * T6."U_SYP_PESOBRUTO" * T3."Quantity")
                        ELSE (T6."U_SYP_PESOBRUTO" * T3."Quantity") 
                    END AS "KG",
                    (T3."Quantity"/T5."GEL_MENGE") AS "%_Afectado",
                    T9."PERS_ID", T9."DisplayName", T9."APLATZ_ID" as "RESOURCE",
                    T1."Price" AS "PrecioInfo"
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
                LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" AND T5."BELPOS_ID" = T9."BELPOS_ID" AND T4."DistNumber" = T9."BatchNum" AND T9."CANCEL" != '1'

                WHERE --T1."WhsCode" IN ('11PCD', '12PCD', '20PCD')

                (
                    T1."FromWhsCod" IN ('11PCD', '12PCD') AND  -- Bodegas de origen
                    T1."WhsCode" = '20PCD')  -- Bodega de destino
                AND T0."DocDate" > '2024-01-01'
                --AND T0."DocNum" = '24005870' --'24002124'
                --AND T0."UserSign" = '41'
                AND T0."CANCELED" = 'N' AND T1."Quantity" > 0 ) P0 
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
                FROM OIGN T0
                INNER JOIN IGN1 T1 ON T0."DocEntry" = T1."DocEntry"
                INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T7 on T7."BELNR_ID" = T1."U_beas_belnrid"
                INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND T1."WhsCode" = T2."LocCode" AND T2."DocType" = '59'
                INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
                LEFT JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
                INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
                INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T8 on T8."BELNR_ID" = T7."BELNR_ID"  and T8."BELPOS_ID" = T7."BELPOS_ID" and T8."BUCHNR_ID" = T1."U_beas_basedocentry"
                WHERE T8."APLATZ_ID" NOT LIKE 'GM%' 
            )  P1 ON CAST(P1."Orden" as VARCHAR) = P0."Orden" AND P1."Pos" = P0."Posicion" AND P1."LOTE" = P0."Numero_Lote"
    )
) WITH READ ONLY

/* SE ADD SUBTOTAL */
DROP VIEW "SBO_FIGURETTI_PRO"."TRASLADO_BODEGA_11_12_A_20";

CREATE VIEW "SBO_FIGURETTI_PRO"."TRASLADO_BODEGA_11_12_A_20" ( 
    "DocNum",
    "DocDate",
    "Orden",
    "Posicion",
    "ItemCode",
    "Dscription",
    "Grupo_Articulo",
    "Unidad_Medida",
    "Numero_Lote",
    "Desde_Bodega",
    "A_Bodega",
    "Proceso",
    "Motivo_Traslado",
    "Peso_Unidad",
    "Precio",
    "PrecioInfo",
    "Cantidad_Lote",
    "Cantidad_Producida",
    "Costo",
    "KG",
    "%_Afectado",
    "PERS_ID",
    "Operador",
    "Recurso",
    "Subtotal",
    "Responsable",
    "Comentario",
    "FechaFabricacion" ) AS SELECT
        P0."DocNum",
        P0."DocDate",
        P0."Orden",
        P0."Posicion",
        P0."ItemCode",
        P0."Dscription",
        P0."Grupo_Articulo",
        P0."Unidad_Medida",
        P0."Numero_Lote",
        P0."Desde_Bodega",
        P0."A_Bodega",
        P0."Proceso",
        P0."Motivo_Traslado",
        P0."Peso_Unidad",
        P0."Precio",
        P0."PrecioInfo",
        P0."Cantidad_Lote",
        P0."Cantidad_Producida",
        P0."Costo",
        P0."KG",
        P0."%_Afectado",
        P1."PERS_ID",
        P1."Operador",
        P1."Recurso",
        P0."Subtotal",
        P0."Responsable",
        P0."Comentario",
        P1."FechaFabricacion" 
        FROM ( 
            SELECT
                T0."DocNum",
                T0."DocDate",
	            LEFT(T4."DistNumber", 5) AS "Orden",
	            CASE 
                    WHEN 
                        LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber", 6, 3) 
                    WHEN 
                        LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber", 6, 3) 
	                ELSE SUBSTRING(T4."DistNumber", 6, 2) 
	            END AS "Posicion",
                T1."ItemCode",
                T1."Dscription",
                T7."ItmsGrpNam" AS "Grupo_Articulo",
                T1."unitMsr" AS "Unidad_Medida",
                T4."DistNumber" AS "Numero_Lote",
                T1."FromWhsCod" AS "Desde_Bodega",
                T1."WhsCode" AS "A_Bodega",
	            COALESCE(T8."U_DPE_PROCESS",'S/M') AS "Proceso",
	            COALESCE(T8."Name",'S/M') AS "Motivo_Traslado",
                T6."U_SYP_PESOBRUTO" AS "Peso_Unidad",
                T1."StockPrice" AS "Precio",
                T3."Quantity" As "Cantidad_Lote",
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
                T1."Price" AS "PrecioInfo",
                T3."Quantity" * T1."Price" AS "Subtotal",
                T10."SlpName" AS "Responsable",
                T0."Comments" AS "Comentario" --,
                --T4."MnfDate" AS "FechaFabricacion" --, T9.*
 
            FROM OWTR T0 
            INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry" 
            INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
            AND T1."WhsCode" = T2."LocCode" 
            AND T2."DocType" = '67' 
            AND T1."LineNum" = T2."DocLine" 
            INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry" 
            INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry" 
            INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber", 5) 
	            AND CAST(T5."BELPOS_ID" AS VARCHAR) = ( CASE 
                                                            WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber", 6, 3) 
                                                            WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber", 6, 3) 
		                                                    ELSE SUBSTRING(T4."DistNumber", 6, 2) 
                                                        END) 
                AND T1."ItemCode" = T5."ItemCode" 
            INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode" 
            INNER JOIN OITB T7 ON T6."ItmsGrpCod" = T7."ItmsGrpCod" 
            LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code" 
            LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" 
                AND T5."BELPOS_ID" = T9."BELPOS_ID" 
                AND T4."DistNumber" = T9."BatchNum" 
                AND T9."CANCEL" != '1' 
            LEFT JOIN OSLP T10 ON T0."SlpCode" = T10."SlpCode" 
	        WHERE --T1."WhsCode" IN ('11PCD', '12PCD', '20PCD')
            ( T1."FromWhsCod" IN ('11PCD','12PCD') AND -- Bodegas de origen
                T1."WhsCode" = '20PCD') -- Bodega de destino
 
            AND T0."DocDate" > '2024-01-01' --AND T0."DocNum" = '24005870' --'24002124'
            --AND T0."UserSign" = '41'
        
            AND T0."CANCELED" = 'N' 
            AND T1."Quantity" > 0 
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
                T1."Quantity",
                T8."ANFZEIT" AS "FechaFabricacion" 
            FROM OIGN T0 
            INNER JOIN IGN1 T1 ON T0."DocEntry" = T1."DocEntry" 
            INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T7 on T7."BELNR_ID" = T1."U_beas_belnrid" 
            INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
                AND T1."WhsCode" = T2."LocCode" 
                AND T2."DocType" = '59' 
            INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry" 
            LEFT JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry" 
            INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode" 
            INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T8 on T8."BELNR_ID" = T7."BELNR_ID" 
                and T8."BELPOS_ID" = T7."BELPOS_ID" 
                and T8."BUCHNR_ID" = T1."U_beas_basedocentry" 
            WHERE T8."APLATZ_ID" NOT LIKE 'GM%' ) P1 ON CAST(P1."Orden" as VARCHAR) = P0."Orden" 
            AND P1."Pos" = P0."Posicion" 
            AND P1."LOTE" = P0."Numero_Lote" WITH READ ONLY




/* ************* este es el query de traslado de cuarentena ********** */
SELECT 
    P0."DocNum", 
    P0."DocDate", 
    P0."Orden", 
    P0."Posicion", 
    P0."ItemCode", 
    P0."Dscription", 
    P0."Grupo_Articulo", 
    P0."Unidad_Medida", 
    P0."Numero_Lote", 
    P0."Desde_Bodega", 
    P0."A_Bodega",
    P0."Proceso", 
    P0."Motivo_Traslado", 
    P0."Peso_Unidad", 
    P0."Precio", 
    P0."Cantidad_Lote", 
    P0."Cantidad_Lote", 
    P0."Cantidad_Producida", 
    P0."Costo", 
    P0."KG", 
    P0."%_Afectado", 
    P1."PERS_ID", 
    P1."Operador", 
    P1."Recurso" 
    FROM ( 
        SELECT 
            T0."DocNum",
            T0."DocDate",
            LEFT(T4."DistNumber",5) AS "Orden",
            CASE 
                WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3)
                WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3)
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
            T3."Quantity" As "Cantidad_Lote",
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
        LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" AND T5."BELPOS_ID" = T9."BELPOS_ID" AND T4."DistNumber" = T9."BatchNum" AND T9."CANCEL" != '1'

        WHERE T1."WhsCode" IN ('11PCD', '12PCD', '20PCD')
        AND T0."DocDate" > '2024-01-01'
        --AND T0."DocNum" = '24002124'
        --AND T0."UserSign" = '41'
        AND T0."CANCELED" = 'N' AND T1."Quantity" > 0 ) P0 
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
    FROM OIGN T0
    INNER JOIN IGN1 T1 ON T0."DocEntry" = T1."DocEntry"
    INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T7 on T7."BELNR_ID" = T1."U_beas_belnrid"
    INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND T1."WhsCode" = T2."LocCode" AND T2."DocType" = '59'
    INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
    LEFT JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
    INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
    INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T8 on T8."BELNR_ID" = T7."BELNR_ID"  and T8."BELPOS_ID" = T7."BELPOS_ID" and T8."BUCHNR_ID" = T1."U_beas_basedocentry"
    WHERE T8."APLATZ_ID" NOT LIKE 'GM%' 
)  P1 ON CAST(P1."Orden" as VARCHAR) = P0."Orden" AND P1."Pos" = P0."Posicion" AND P1."LOTE" = P0."Numero_Lote"



-- ****************************************************************************************
ESTOY HACIENDO UN NUEVO QUERY CON imagenes  

SELECT
    P0."DocNum", 
    P0."DocDate", 
    P0."Orden", 
    P0."Posicion", 
    P0."ItemCode", 
    P0."Dscription", 
    P0."Grupo_Articulo", 
    P0."Unidad_Medida", 
    P0."Numero_Lote", 
    P0."Desde_Bodega", 
    P0."A_Bodega",
    P0."Proceso", 
    P0."Motivo_Traslado", 
    P0."Peso_Unidad", 
    P0."Precio", 
    P0."PrecioInfo",
    P0."Cantidad_Lote", 
    P0."Cantidad_Producida", 
    P0."Costo", 
    P0."KG", 
    P0."%_Afectado", 
    P1."PERS_ID", 
    P1."Operador", 
    P1."Recurso",
    P0."Subtotal",
    P0."Responsable",
    P0."Comentario",
    P1."FechaFabricacion",
    NULL AS "UrlImage" 
   
    FROM ( 
        SELECT 
            T0."DocNum",
            T0."DocDate",
            LEFT(T4."DistNumber",5) AS "Orden",
            CASE 
                WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3)
                WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3)
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
            T3."Quantity" As "Cantidad_Lote",
            T5."GEL_MENGE" AS "Cantidad_Producida",
            (T1."StockPrice" * T3."Quantity") AS "Costo",
            CASE
                WHEN T1."unitMsr" = 'KG' THEN T3."Quantity"
                WHEN T1."unitMsr" = 'PACK' THEN (T6."U_SYP_UPPL" * T6."U_SYP_PESOBRUTO" * T3."Quantity")
                ELSE (T6."U_SYP_PESOBRUTO" * T3."Quantity") 
            END AS "KG",
            (T3."Quantity"/T5."GEL_MENGE") AS "%_Afectado",
            T9."PERS_ID", T9."DisplayName", T9."APLATZ_ID" as "RESOURCE",
            T1."Price" AS "PrecioInfo",
            T3."Quantity" * T1."Price" AS "Subtotal",
            T10."SlpName" AS "Responsable",
            T0."Comments" AS "Comentario"--,
            --T4."MnfDate" AS "FechaFabricacion"
            

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
        LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" AND T5."BELPOS_ID" = T9."BELPOS_ID" AND T4."DistNumber" = T9."BatchNum" AND T9."CANCEL" != '1'
        LEFT JOIN OSLP T10 ON T0."SlpCode" = T10."SlpCode"

        WHERE --T1."WhsCode" IN ('11PCD', '12PCD', '20PCD')

        (
            T1."FromWhsCod" IN ('11PCD', '12PCD') AND  -- Bodegas de origen
            T1."WhsCode" = '20PCD')  -- Bodega de destino
        AND T0."DocDate" > '2024-01-01'
        AND T0."DocNum" = '24005870' --'24005868' --'24006089' --'24005870' --'24002124'
        --AND T0."UserSign" = '41'
        AND T0."CANCELED" = 'N' AND T1."Quantity" > 0 ) P0 
INNER JOIN ( 
    SELECT
        T7."BELNR_ID" as "Orden", 
        T7."BELPOS_ID" as "Pos", 
        T6."ItemCode", 
        T4."DistNumber" as "LOTE", 
        T8."PERS_ID", 
        T8."DisplayName" as "Operador", 
        T8."APLATZ_ID" as "Recurso", 
        T1."Quantity",
        T8."ANFZEIT" AS "FechaFabricacion"
    FROM OIGN T0
    INNER JOIN IGN1 T1 ON T0."DocEntry" = T1."DocEntry"
    INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T7 on T7."BELNR_ID" = T1."U_beas_belnrid"
    INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND T1."WhsCode" = T2."LocCode" AND T2."DocType" = '59'
    INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
    LEFT JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
    INNER JOIN OITM T6 ON T1."ItemCode" = T6."ItemCode"
    INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T8 on T8."BELNR_ID" = T7."BELNR_ID"  and T8."BELPOS_ID" = T7."BELPOS_ID" and T8."BUCHNR_ID" = T1."U_beas_basedocentry"
    WHERE T8."APLATZ_ID" NOT LIKE 'GM%' 
)  P1 ON CAST(P1."Orden" as VARCHAR) = P0."Orden" AND P1."Pos" = P0."Posicion" AND P1."LOTE" = P0."Numero_Lote"

UNION ALL 

SELECT
       T0."DocNum", 
       NULL as "DocDate", 
       NULL as "Orden",  
       NULL as "Posicion",  
       NULL as "ItemCode",  
       NULL as "Dscription",  
       NULL as "Grupo_Articulo",  
       NULL as "Unidad_Medida",  
       NULL as "Numero_Lote",  
       NULL as "Desde_Bodega",  
       NULL as "A_Bodega", 
       NULL as "Proceso",  
       NULL as "Motivo_Traslado",  
       NULL as "Peso_Unidad", 
       NULL as "Precio", 
       NULL as "PrecioInfo",  
       NULL as "Cantidad_Lote", 
       NULL as "Cantidad_Producida", 
       NULL as "Costo",  
       NULL as "KG",  
       NULL as "%_Afectado",  
       NULL AS "PERS_ID",  
       NULL AS "Operador",
       NULL AS "Recurso",
       NULL AS "Subtotal",
       NULL AS "Responsable",
       NULL AS "Comentario",
       MAX(TO_NVARCHAR(T3."trgtPath") || '\' || T3."FileName" || '.' || T3."FileExt") AS "UrlImage"
FROM 
    "SBO_FIGURETTI_PRO"."OWTR" T0 
INNER JOIN 
    "SBO_FIGURETTI_PRO"."WTR1" T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN 
    "SBO_FIGURETTI_PRO"."OATC" T2 ON T0."AtcEntry" = T2."AbsEntry"
INNER JOIN 
    "SBO_FIGURETTI_PRO"."ATC1" T3 ON T2."AbsEntry" = T3."AbsEntry"
GROUP BY
   T0."DocNum"; 


   /* query modificado de traslado bodega 11 -12 a 20 fecha: 09/01/2025 */


SELECT
  MAX(T0."DocNum") AS "DocNum" ,
  T1."ItemCode",
  MAX(T1."Dscription") AS "Dscription",
  MAX(T1."WhsCode") AS "A_Bodega",
  MAX(T1."FromWhsCod") AS "Desde_Bodega",
  MAX(T1."unitMsr") AS "Unidad_Medida",
  MAX(T4."DistNumber") AS "Numero_Lote",
  MAX(COALESCE(T8."Name", 'S/M'))AS "Motivo_Traslado",
  MAX(T1."Quantity") AS "Cantidad",
  MAX(T1."StockPrice") AS "Costo_Articulo",
  MAX(T1."Price") AS "Precio",
  MAX(T1."Quantity" * T1."Price") AS "Subtotal",
  MAX(T10."SlpName") AS "Responsable",
  MAX(T0."Comments") AS "Comentario",
  MAX(T0."JrnlMemo") AS "Comentario_2",
  MAX(T9."ANFZEIT") AS "FechaFabricacion"
 
FROM OWTR T0  
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND  T1."WhsCode" = T2."LocCode" AND T2."DocType" = '67' AND T1."LineNum" = T2."DocLine" 
INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"

LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON LEFT(T4."DistNumber",5) = T9."BELNR_ID"
LEFT JOIN OSLP T10 ON T0."SlpCode" = T10."SlpCode"


/*INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND  T1."WhsCode" = T2."LocCode" AND T2."DocType" = '67' AND T1."LineNum" = T2."DocLine"  
INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"
INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
        AND CAST(T5."BELPOS_ID" AS VARCHAR) = (CASE WHEN LENGTH(T4."DistNumber") = '10' THEN SUBSTRING(T4."DistNumber",6,3) WHEN LENGTH(T4."DistNumber") = '14' THEN SUBSTRING(T4."DistNumber",6,3) ELSE SUBSTRING(T4."DistNumber",6,2) END)
        AND T1."ItemCode" = T5."ItemCode"

LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" AND T5."BELPOS_ID" = T9."BELPOS_ID" AND T4."DistNumber" = T9."BatchNum" AND T9."CANCEL" != '1'
LEFT JOIN OSLP T10 ON T0."SlpCode" = T10."SlpCode"*/

WHERE 
  (T1."FromWhsCod" IN ('11PCD', '12PCD') AND  T1."WhsCode" = '20PCD')
  AND  T0."DocNum" = '24006278'
GROUP BY T1."ItemCode"


/* OPCION 2 VERIFICANDO CON ROMMY */
SELECT
  MAX(T0."DocNum") AS "DocNum", --listo
  T1."ItemCode", --listo
  MAX(T1."Dscription") AS "Dscription", --listo
  MAX(T1."WhsCode") AS "A_Bodega", --listo
  MAX(T1."FromWhsCod") AS "Desde_Bodega", --listo
  MAX(T1."unitMsr") AS "Unidad_Medida", --listo
  MAX(T4."DistNumber") AS "Numero_Lote",
  --MAX(T9."ANFZEIT") AS "FechaFabricacion",
  MAX(T9."ERFTSTAMP") AS "FechaFabricacion",
  MAX(COALESCE(T8."Name", 'S/M'))AS "Motivo_Traslado", --listo
  MAX(T1."Quantity") AS "Cantidad",--listo   
  MAX(T1."StockPrice") AS "Costo_Articulo", --listo            
  MAX(T1."Price") AS "Precio",--listo
  MAX(T1."Quantity" * T1."Price") AS "Subtotal",--listo
  MAX(T10."SlpName") AS "Responsable", --listo
  MAX(T0."Comments") AS "Comentario", --listo
  T1."InvQty" AS "Cantidad_UM_Inv",  --listo añadi
  
FROM OWTR T0  
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND  T1."WhsCode" = T2."LocCode" AND T2."DocType" = '67' AND T1."LineNum" = T2."DocLine" 
INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"

INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
      
LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" AND T5."BELPOS_ID" = T9."BELPOS_ID" AND T4."DistNumber" = T9."BatchNum" AND T9."CANCEL" != '1'

--INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON LEFT(T4."DistNumber",5) = T9."BELNR_ID"

LEFT JOIN OSLP T10 ON T0."SlpCode" = T10."SlpCode"


WHERE 
  (T1."FromWhsCod" IN ('11PCD', '12PCD') AND  T1."WhsCode" = '20PCD')
  AND  T0."DocNum" = '24006278' --'24005870' --
GROUP BY T1."ItemCode"


/* ****ARREGLANDO***** */


SELECT
    LEFT(T7."DistNumber",5) AS "Orden",
    CASE 
        WHEN LENGTH(T7."DistNumber") = '10' THEN SUBSTRING(T7."DistNumber",6,3)
        WHEN LENGTH(T7."DistNumber") = '14' THEN SUBSTRING(T7."DistNumber",6,3)
        ELSE SUBSTRING(T7."DistNumber",6,2) 
    END AS "Posicion", 

    T0."DocNum",
    T1."ItemCode",
    T1."Dscription",
    T1."WhsCode" AS "A_Bodega",
    T1."FromWhsCod" AS "Desde_Bodega",
    T1."unitMsr" AS "Unidad_Medida",
    COALESCE(T3."Name", 'S/M') AS "Motivo_Traslado",
    T1."Quantity" AS "Cantidad",
    T1."StockPrice" AS "Costo_Articulo",
    T1."Price" AS "Precio",
    T1."Quantity" * T1."Price" AS "Subtotal",
    T1."InvQty" AS "Cantidad_UM_Inv",
    T4."SlpName" AS "Responsable",
    T0."Comments" AS "Comentario",
    T7."DistNumber"
    --T3.*

FROM OWTR T0  
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
-- INNER JOIN OBTN T2 ON T1."ItemCode" = T2."ItemCode" AND T2."WhsCode" = T1."WhsCode"

LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T3 ON T1."U_SYP_OBS_ITEM" = T3."Code"
LEFT JOIN OSLP T4 ON T0."SlpCode" = T4."SlpCode"

INNER JOIN OITL T5 ON T0."DocEntry" = T5."DocEntry" AND T1."WhsCode" = T5."LocCode" AND T5."DocType" = '67' AND T1."LineNum" = T5."DocLine"
INNER JOIN ITL1 T6 ON T5."LogEntry" = T6."LogEntry"
INNER JOIN OBTN T7 ON T6."MdAbsEntry" = T7."AbsEntry"


WHERE 
  (T1."FromWhsCod" IN ('11PCD', '12PCD') AND  T1."WhsCode" = '20PCD')
  AND  T0."DocNum" = '24006280' --'24006278'


  OWTR T0  
  INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry", 
  ITL1 T2 
  INNER JOIN OITL T3 ON T2."LogEntry" = T3."LogEntry"

  OWTR  T0 
  INNER JOIN WTR1  T1 ON T0."DocEntry" = T1."DocEntry", 
  OITL T2 
  INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"



  /* feccha de creacion puede ser la fecha de fabricación 
  ultimo query revisado por romy */
  SELECT  
    T0."DocNum",
    T1."ItemCode",
    T1."Dscription",
    T1."WhsCode" AS "A_Bodega",
    T1."FromWhsCod" AS "Desde_Bodega",
    T1."unitMsr" AS "Unidad_Medida",
    T4."DistNumber" AS "Numero_Lote",
    COALESCE(T5."Name", 'S/M') AS "Motivo_Traslado",
    T1."Quantity" AS "Cantidad",
    T1."StockPrice" AS "Costo_Articulo",
    T1."Price" AS "Precio",
    T1."InvQty" AS "Cantidad_UM_Inv",
    T1."Quantity" * T1."Price" AS "Subtotal",
    T6."SlpName" AS "Responsable",
    T0."Comments" AS "Comentario",
    T4."CreateDate" AS "FechaFabricacion"
    --T4."MnfDate",
    --T4."InDate",
    --T4."UpdateDate",
    

FROM OWTR T0  
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"

INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND  T1."WhsCode" = T2."LocCode" AND T2."DocType" = '67' AND T1."LineNum" = T2."DocLine" 
INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"

LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T5 ON T1."U_SYP_OBS_ITEM" = T5."Code"
LEFT JOIN OSLP T6 ON T0."SlpCode" = T6."SlpCode"

WHERE 
  (T1."FromWhsCod" IN ('11PCD', '12PCD') AND  T1."WhsCode" = '20PCD')
  AND  T0."DocNum" =  '24006279' --'24006278' --'24006279' --'24006280' -- --'24006278'

-- ***************Otra forma si esta bien el codigo de arriba *************************
SELECT
    T0."DocNum",
    T1."ItemCode",
    T1."Dscription",
    T1."WhsCode" AS "A_Bodega",
    T1."FromWhsCod" AS "Desde_Bodega",
    T1."unitMsr" AS "Unidad_Medida",
    --T4."DistNumber" AS "Numero_Lote",
    COALESCE(T5."Name", 'S/M') AS "Motivo_Traslado",
    T1."Quantity" AS "Cantidad",
    T1."StockPrice" AS "Costo_Articulo",
    T1."Price" AS "Precio",
    T1."InvQty" AS "Cantidad_UM_Inv",
    T1."Quantity" * T1."Price" AS "Subtotal",
    T6."SlpName" AS "Responsable",
    T0."Comments" AS "Comentario",
    --T4."CreateDate" AS "FechaFabricacion"
    T1."Quantity",T3."Quantity", T4."DistNumber"

FROM OWTR T0  
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"

INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
AND  T1."WhsCode" = T2."LocCode" AND T2."DocType" = '67' 
AND T1."LineNum" = T2."DocLine" 

INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"

INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry" 
AND T1."ItemCode"=T4."ItemCode" 
AND T3."SysNumber" = T4."SysNumber"

LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T5 ON T1."U_SYP_OBS_ITEM" = T5."Code"
LEFT JOIN OSLP T6 ON T0."SlpCode" = T6."SlpCode"

WHERE 
  (T1."FromWhsCod" IN ('11PCD', '12PCD') AND  T1."WhsCode" = '20PCD')
  AND  T0."DocNum" =  '24006280'

-- ******************************************




  /* este ya no va */
  SELECT
  MAX(T0."DocNum") AS "DocNum" ,
  T1."ItemCode",
  MAX(T1."Dscription") AS "Dscription",
  MAX(T1."WhsCode") AS "A_Bodega",
  MAX(T1."FromWhsCod") AS "Desde_Bodega",
  MAX(T1."unitMsr") AS "Unidad_Medida",
  MAX(T4."DistNumber") AS "Numero_Lote",
  MAX(COALESCE(T8."Name", 'S/M'))AS "Motivo_Traslado",
  MAX(T1."Quantity") AS "Cantidad",
  MAX(T1."StockPrice") AS "Costo_Articulo",
  MAX(T1."Price") AS "Precio",
  MAX(T1."Quantity" * T1."Price") AS "Subtotal",
  MAX(T10."SlpName") AS "Responsable",
  MAX(T0."Comments") AS "Comentario",
  MAX(T0."JrnlMemo") AS "Comentario_2",
 MAX(T9."ERFTSTAMP") AS "FechaFabricacion"
  --MAX(T9."ANFZEIT") AS "FechaFabricacion"
 
FROM OWTR T0  
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND  T1."WhsCode" = T2."LocCode" AND T2."DocType" = '67' AND T1."LineNum" = T2."DocLine" 
INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"

INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_FTPOS" T5 ON CAST(T5."BELNR_ID" AS VARCHAR) = LEFT(T4."DistNumber",5)
      
LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON T5."BELNR_ID" = T9."BELNR_ID" AND T5."BELPOS_ID" = T9."BELPOS_ID" AND T4."DistNumber" = T9."BatchNum" AND T9."CANCEL" != '1'

/*LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T8 ON T1."U_SYP_OBS_ITEM" = T8."Code"
INNER JOIN "SBO_FIGURETTI_PRO"."BEAS_ARBZEIT" T9 ON LEFT(T4."DistNumber",5) = T9."BELNR_ID"*/

LEFT JOIN OSLP T10 ON T0."SlpCode" = T10."SlpCode"


WHERE 
  (T1."FromWhsCod" IN ('11PCD', '12PCD') AND  T1."WhsCode" = '20PCD')
  AND  T0."DocNum" = {?DocNum@}
GROUP BY T1."ItemCode"


-- ***************************************************



SELECT
    T0."DocNum",
    T1."ItemCode",
    T1."Dscription",
    T1."WhsCode" AS "A_Bodega",
    T1."FromWhsCod" AS "Desde_Bodega",
    T1."unitMsr" AS "Unidad_Medida",
    --T4."DistNumber" AS "Numero_Lote",
    COALESCE(T5."Name", 'S/M') AS "Motivo_Traslado",
    T1."Quantity" AS "Cantidad",
    T1."StockPrice" AS "Costo_Articulo",
    T1."Price" AS "Precio",
    T1."InvQty" AS "Cantidad_UM_Inv",
    T1."Quantity" * T1."Price" AS "Subtotal",
    T6."SlpName" AS "Responsable",
    T0."Comments" AS "Comentario"
    --T4."CreateDate" AS "FechaFabricacion"
    ,T3."Quantity", T4."DistNumber"

FROM OWTR T0  
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"

INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
AND  T1."WhsCode" = T2."LocCode" AND T2."DocType" = '67' 
AND T1."LineNum" = T2."DocLine" 

INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"

INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry" 
AND T1."ItemCode"=T4."ItemCode" 
AND T3."SysNumber" = T4."SysNumber"

LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T5 ON T1."U_SYP_OBS_ITEM" = T5."Code"
LEFT JOIN OSLP T6 ON T0."SlpCode" = T6."SlpCode"

WHERE 
  (T1."FromWhsCod" IN ('11PCD', '12PCD') AND  T1."WhsCode" = '20PCD')
  AND  T0."DocNum" =  '24006280'
/*GROUP BY     
T0."DocNum", T1."ItemCode", T1."Dscription", T1."WhsCode", T1."FromWhsCod",     T1."unitMsr", T4."DistNumber", T5."Name", T1."Quantity", T1."StockPrice",   T1."Price", T1."InvQty", T6."SlpName", T0."Comments";*/


/* anterior query del sistema  */
SELECT  
    T0."DocNum",
    T1."ItemCode",
    T1."Dscription",
    T1."WhsCode" AS "A_Bodega",
    T1."FromWhsCod" AS "Desde_Bodega",
    T1."unitMsr" AS "Unidad_Medida",
    T4."DistNumber" AS "Numero_Lote",
    COALESCE(T5."Name", 'S/M') AS "Motivo_Traslado",
    T1."Quantity" AS "Cantidad",
    T1."StockPrice" AS "Costo_Articulo",
    T1."Price" AS "Precio",
    T1."InvQty" AS "Cantidad_UM_Inv",
    T1."Quantity" * T1."Price" AS "Subtotal",
    T6."SlpName" AS "Responsable",
    T0."Comments" AS "Comentario",
    T4."CreateDate" AS "FechaFabricacion"  

FROM OWTR T0  
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"

INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" AND  T1."WhsCode" = T2."LocCode" AND T2."DocType" = '67' AND T1."LineNum" = T2."DocLine" 
INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"
INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry"

LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T5 ON T1."U_SYP_OBS_ITEM" = T5."Code"
LEFT JOIN OSLP T6 ON T0."SlpCode" = T6."SlpCode"

WHERE 
  (T1."FromWhsCod" IN ('11PCD', '12PCD') AND  T1."WhsCode" = '20PCD')
  AND  T0."DocNum" =  {?DocNum@}

/* perfecto asi queda el trasladoBodega 11,12 a 20 */
SELECT
    T0."DocNum",
    T1."ItemCode",
    T1."Dscription",
    T1."WhsCode" AS "A_Bodega",
    T1."FromWhsCod" AS "Desde_Bodega",
    T1."unitMsr" AS "Unidad_Medida",
    T4."DistNumber" AS "Numero_Lote",
    COALESCE(T5."Name", 'S/M') AS "Motivo_Traslado",
    T1."Quantity" AS "Cantidad",
    T3."Quantity" AS "Cantidad_Real",
    T1."StockPrice" AS "Costo_Articulo",
    T1."Price" AS "Precio",
    T1."InvQty" AS "Cantidad_UM_Inv",
    T1."Quantity" * T1."Price" AS "Subtotal",
    T6."SlpName" AS "Responsable",
    T0."Comments" AS "Comentario",
    T4."CreateDate" AS "FechaFabricacion"
    

FROM OWTR T0  
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"

INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
AND  T1."WhsCode" = T2."LocCode" AND T2."DocType" = '67' 
AND T1."LineNum" = T2."DocLine" 

INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"

INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry" 
AND T1."ItemCode"=T4."ItemCode" 
AND T3."SysNumber" = T4."SysNumber"

LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T5 ON T1."U_SYP_OBS_ITEM" = T5."Code"
LEFT JOIN OSLP T6 ON T0."SlpCode" = T6."SlpCode"

WHERE 
  (T1."FromWhsCod" IN ('11PCD', '12PCD') AND  T1."WhsCode" = '20PCD')
  AND  T0."DocNum" = {?DocNum@} --'24006280'




--   *****************
/* listo asi quedo en produccion 2025-01-23 */
SELECT
    T0."DocNum",
    T1."ItemCode",
    T1."Dscription",
    T1."WhsCode" AS "A_Bodega",
    T1."FromWhsCod" AS "Desde_Bodega",
    T1."unitMsr" AS "Unidad_Medida",
    T4."DistNumber" AS "Numero_Lote",
    COALESCE(T5."Name", 'S/M') AS "Motivo_Traslado",
    --T1."Quantity" AS "Cantidad",
    T3."Quantity" AS "Cantidad",
    T1."StockPrice" AS "Costo_Articulo",
    T1."Price" AS "Precio",
    T1."InvQty" AS "Cantidad_UM_Inv",
    --T1."Quantity" * T1."Price" AS "Subtotal",
    T3."Quantity" * T1."Price" AS "Subtotal",
    T6."SlpName" AS "Responsable",
    T0."Comments" AS "Comentario",
    T4."CreateDate" AS "FechaFabricacion"
  
FROM OWTR T0  
INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"

INNER JOIN OITL T2 ON T0."DocEntry" = T2."DocEntry" 
AND  T1."WhsCode" = T2."LocCode" AND T2."DocType" = '67' 
AND T1."LineNum" = T2."DocLine" 

INNER JOIN ITL1 T3 ON T2."LogEntry" = T3."LogEntry"

INNER JOIN OBTN T4 ON T3."MdAbsEntry" = T4."AbsEntry" 
AND T1."ItemCode"=T4."ItemCode" 
AND T3."SysNumber" = T4."SysNumber"

LEFT JOIN "SBO_FIGURETTI_PRO"."@DPE_MOT_TRAS" T5 ON T1."U_SYP_OBS_ITEM" = T5."Code"
LEFT JOIN OSLP T6 ON T0."SlpCode" = T6."SlpCode"

WHERE 
  (T1."FromWhsCod" IN ('11PCD', '12PCD') AND  T1."WhsCode" = '20PCD')
  AND  T0."DocNum" = {?DocNum@} --'24006280'









-- *********PROVEDORES CON P****************
SELECT
    --T0."CardType",
    T0."CardCode" AS "Código_Proveedor",
    T0."CardName" AS "Nombre_Proveedor",
    T0."LicTradNum" AS "RUC/Cédula",
    T0."Phone1" AS "Teléfono_1",
    T0."E_Mail" AS "Correo_Electrónico",
    T0."CntctPrsn" AS "Persona_Contacto",
    T0."Balance" AS "Saldo",
    T0."GroupNum",
    T1."PymntGroup"
FROM OCRD T0
INNER JOIN OCTG T1 ON T0."GroupNum" = T1."GroupNum"
WHERE 
    T0."CardType" = 'S' 
   --AND T0."CardName" LIKE 'P%'
   AND LOWER(T0."CardName") LIKE 'p%'
ORDER BY T0."CardName";



















-- ***********************************************


SELECT 
    T0."CardCode", T0."CardName", T3."GroupName", T0."validFor", T2."SlpName", T0."CreditLine", T4."PymntGroup"
FROM OCRD T0  
INNER JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN OSLP T2 ON T0."SlpCode" = T2."SlpCode"
INNER JOIN OCRG T3 ON T3."GroupCode" = T0."GroupCode"
LEFT JOIN OCTG T4 ON T0."GroupNum" = T4."GroupNum"
WHERE
   LOWER(T0."CardName") LIKE 'p%'
GROUP BY T0."CardCode", T0."CardName", T3."GroupName", T0."validFor", T2."SlpName", T0."CreditLine", T4."PymntGroup"

-- ******************************************************
SELECT 
    
    CASE 
        WHEN T0."CardType" = 'C' THEN 'Cliente'
        WHEN T0."CardType" = 'S' THEN 'Proveedor'
        WHEN T0."CardType" = 'L' THEN 'Lead'
        ELSE 'Desconocido' 
    END AS "Tipo",
    T0."CardCode", T0."CardName", T3."GroupName", T0."validFor", T2."SlpName", T0."CreditLine", T4."PymntGroup"
FROM OCRD T0  
INNER JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN OSLP T2 ON T0."SlpCode" = T2."SlpCode"
INNER JOIN OCRG T3 ON T3."GroupCode" = T0."GroupCode"
LEFT JOIN OCTG T4 ON T0."GroupNum" = T4."GroupNum"
WHERE
   T0."CardType" = 'S' AND
   LOWER(T0."CardName") LIKE 'p%'
GROUP BY T0."CardType", T0."CardCode", T0."CardName", T3."GroupName", T0."validFor", T2."SlpName", T0."CreditLine", T4."PymntGroup"




-- ******************************

