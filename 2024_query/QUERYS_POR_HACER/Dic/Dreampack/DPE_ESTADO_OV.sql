



CREATE VIEW "SBO_FIGURETTI_PRO"."DPE_ESTADO_OV" ( 
    "Key Pedido",
    "Status OV",
    "Cancelado",
    "N° Pedido",
    "NumAtCard",
    "Fecha Pedido",
    "Fecha Entrega Actual",
    "FECHA Entrega INICIAL",
    "DIAS DIF",
    "CardCode",
    "CardName",
    "ItemCode",
    "Dscription",
    "Unidad de Medida",
    "Cant UoM",
    "Cantidad Pedida",
    "Cantidad Abierta Restante",
    "Enviado desde el Pedido",
    "DelivrdQty UND",
    "Cantidad Entregada",
    "Almacen",
    "QtyToShip",
    "OrderedQty",
    "Key Entrega",
    "Fecha Entrega",
    "Fecha Venc Entrega",
    "N° Entrega",
    "Cancelado Entrega",
    "Price",
    "SIS_FABRIC",
    "Tipo de error",
    "Causa de error" 
    ) AS SELECT
        T0."DocEntry",
        T0."DocStatus",
        T0."CANCELED",
        T0."DocNum",
        T0."NumAtCard" ,
        T0."DocDate",
        T0."DocDueDate",
        IFNULL(T5."DocDueDate",T0."DocDueDate") AS "FECHA INICIAL",
        DAYS_BETWEEN(IFNULL(T5."DocDueDate",T0."DocDueDate"),T3."DocDueDate") AS "DIAS DIF",
        T0."CardCode",
        T0."CardName",
        T1."ItemCode",
        T1."Dscription",
        T1."UomCode",
        T1."NumPerMsr",
        T1."Quantity"*T1."NumPerMsr" AS "Cantidad Pedida",
        T1."OpenQty"*T1."NumPerMsr" AS "Cantidad Abierta Restante",
        ROUND(T1."DelivrdQty"),
        IFNULL(T1."DelivrdQty"*T1."NumPerMsr",0) AS "DelivrdQty UND",
        IFNULL(T2."Quantity"*T2."NumPerMsr",0) AS "Cantidad Entregada",
        T1."WhsCode",
        T2."QtyToShip",
        T2."OrderedQty",
        T2."DocEntry" AS "Key Entrega",
        T3."DocDate" AS "Fecha Entrega",
        T3."DocDueDate" AS "Fecha Venc Entrega",
        T3."DocNum" AS "N° Entrega",
        T3."CANCELED" AS "Cancelado Entrega",
        T1."Price",
        T8."U_LAB_SIS_FABRIC",
        CASE 
            WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno' 
            WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo' 
            ELSE 'Sin error' 
        END AS "Tipo de error",
        CASE 
            WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción' 
            WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción' 
            WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega' 
            WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial' 
            WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario' 
            WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio' 
            WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago' 
            WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte' 
            ELSE 'Sin error' 
        END AS "Causa de error" 
    FROM ORDR T0 
    INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
    LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode" 
    LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry" --AND T3."CANCELED" = 'N'
    LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17' 
    LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode" 
    WHERE (T1."WhsCode" = '10PTD' 
        OR T1."WhsCode" = '10FPTD' 
        OR T1."WhsCode" = '10PTI' 
        OR T1."WhsCode" = '10EPTD' 
        OR T1."WhsCode" = '10PTA') 
    AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1' ) 
    AND T1."ItemCode" LIKE '07%' 
    ORDER BY 
        T0."DocDate",
        T1."ItemCode",
        T3."DocDate" ASC WITH READ ONLY



/* MODIFICANDO LA CONSULTA 2025-01-14
*SI ES UN ERROR EXTERNO DE ENTREGA POR ALGO DEL CLIENTE NO IMPORTA QUE QUEDE EN CERO
* SI ES INTERNO QUE SALGA TODA LA CANTIDAD
*/


SELECT
        T0."DocEntry",
        T0."DocStatus",
        T0."CANCELED",
        T0."DocNum",
        T0."NumAtCard" ,
        T0."DocDate",
        T0."DocDueDate",
        IFNULL(T5."DocDueDate",T0."DocDueDate") AS "FECHA INICIAL",
        DAYS_BETWEEN(IFNULL(T5."DocDueDate",T0."DocDueDate"),T3."DocDueDate") AS "DIAS DIF",
        T0."CardCode",
        T0."CardName",
        T1."ItemCode",
        T1."Dscription",
        T1."UomCode",
        T1."NumPerMsr",
        T1."Quantity"*T1."NumPerMsr" AS "Cantidad Pedida",
        T1."OpenQty"*T1."NumPerMsr" AS "Cantidad Abierta Restante",
        ROUND(T1."DelivrdQty"),
        IFNULL(T1."DelivrdQty"*T1."NumPerMsr",0) AS "DelivrdQty UND",
        IFNULL(T2."Quantity"*T2."NumPerMsr",0) AS "Cantidad Entregada",
        T1."WhsCode",
        T2."QtyToShip",
        T2."OrderedQty",
        T2."DocEntry" AS "Key Entrega",
        T3."DocDate" AS "Fecha Entrega",
        T3."DocDueDate" AS "Fecha Venc Entrega",
        T3."DocNum" AS "N° Entrega",
        T3."CANCELED" AS "Cancelado Entrega",
        T1."Price",
        T8."U_LAB_SIS_FABRIC",
        CASE 
            WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno' 
            WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo' 
            ELSE 'Sin error' 
        END AS "Tipo de error",
        CASE 
            WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción' 
            WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción' 
            WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega' 
            WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial' 
            WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario' 
            WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio' 
            WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago' 
            WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte' 
            ELSE 'Sin error' 
        END AS "Causa de error" 
    FROM ORDR T0 
    INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
    LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode" 
    LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry" --AND T3."CANCELED" = 'N'
    LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17' 
    LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode" 
    WHERE (T1."WhsCode" = '10PTD' 
        OR T1."WhsCode" = '10FPTD' 
        OR T1."WhsCode" = '10PTI' 
        OR T1."WhsCode" = '10EPTD' 
        OR T1."WhsCode" = '10PTA') 
    AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1' ) 
    AND T1."ItemCode" LIKE '07%' 
    AND T0."CardCode" = 'C0990004196001'
   AND T0."DocDate" BETWEEN '2024-12-01' AND '2024-12-31'
    ORDER BY 
        T0."DocDate",
        T1."ItemCode",
        T3."DocDate"



-- *****Haciendo pruebas********

SELECT
    T0."DocEntry",
    T0."DocStatus",
    T0."CANCELED",
    T0."DocNum",
    T0."NumAtCard",
    T0."DocDate",
    T0."DocDueDate",
    IFNULL(T5."DocDueDate", T0."DocDueDate") AS "FECHA INICIAL",
    DAYS_BETWEEN(IFNULL(T5."DocDueDate", T0."DocDueDate"), T3."DocDueDate") AS "DIAS DIF",
    T0."CardCode",
    T0."CardName",
    T1."ItemCode",
    T1."Dscription",
    T1."UomCode",
    T1."NumPerMsr",
    T1."Quantity",
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad Pedida",
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",
    ROUND(T1."DelivrdQty"),
    IFNULL(T1."DelivrdQty" * T1."NumPerMsr", 0) AS "DelivrdQty UND",
    IFNULL(T2."Quantity" * T2."NumPerMsr", 0) AS "Cantidad Entregada",
    T1."WhsCode",
    T2."QtyToShip",
    T2."OrderedQty",
    T2."DocEntry" AS "Key Entrega",
    T3."DocDate" AS "Fecha Entrega",
    T3."DocDueDate" AS "Fecha Venc Entrega",
    T3."DocNum" AS "N° Entrega",
    T3."CANCELED" AS "Cancelado Entrega",
    T1."Price",
    T8."U_LAB_SIS_FABRIC",
    CASE
        WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno'  
        WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo'
        ELSE 'Sin error'
    END AS "Tipo de error",
    CASE
        WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega'
        WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial'
        WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario'
        WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio'
        WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago'
        WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte'
        ELSE 'Sin error'
    END AS "Causa de error"
   
   
FROM ORDR T0
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode"
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17'
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode"
WHERE (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA'))
AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1')
AND T1."ItemCode" LIKE '07%'
AND T0."CardCode" = 'C0990004196001'
AND T0."DocNum" = '24004100' --'24004089'
AND T0."DocDate" BETWEEN '2024-12-01' AND '2024-12-31'
ORDER BY 
    T0."DocNum",
    T0."DocDate",
    T1."ItemCode",
    T3."DocDate";


    /* * */


SELECT
    T0."DocEntry",  -- ORDR (Orden de venta)
    T0."DocStatus",  -- ORDR (Orden de venta)
    T0."CANCELED",  -- ORDR (Orden de venta)
    T0."DocNum",  -- ORDR (Orden de venta)
    T0."NumAtCard",  -- ORDR (Orden de venta)
    T0."DocDate",  -- ORDR (Orden de venta)
    T0."DocDueDate",  -- ORDR (Orden de venta)
    IFNULL(T5."DocDueDate", T0."DocDueDate") AS "FECHA INICIAL",  -- ADOC (Documento de pago)
    DAYS_BETWEEN(IFNULL(T5."DocDueDate", T0."DocDueDate"), T3."DocDueDate") AS "DIAS DIF",  -- ODLN (Entregas)
    T0."CardCode",  -- ORDR (Orden de venta)
    T0."CardName",  -- ORDR (Orden de venta)
    T1."ItemCode",  -- RDR1 (Líneas de orden de venta)
    T1."Dscription",  -- RDR1 (Líneas de orden de venta)
    T1."UomCode",  -- RDR1 (Líneas de orden de venta)
    T1."NumPerMsr",  -- RDR1 (Líneas de orden de venta)
    T1."Quantity",  -- RDR1 (Líneas de orden de venta)
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad Pedida",  -- RDR1 (Líneas de orden de venta)
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante",  -- RDR1 (Líneas de orden de venta)
    ROUND(T1."DelivrdQty"),  -- RDR1 (Líneas de orden de venta)
    IFNULL(T1."DelivrdQty" * T1."NumPerMsr", 0) AS "DelivrdQty UND",  -- RDR1 (Líneas de orden de venta)
    IFNULL(T2."Quantity" * T2."NumPerMsr", 0) AS "Cantidad Entregada",  -- DLN1 (Líneas de entrega)
    T1."WhsCode",  -- RDR1 (Líneas de orden de venta)
    T2."QtyToShip",  -- DLN1 (Líneas de entrega)
    T2."OrderedQty",  -- DLN1 (Líneas de entrega)
    T2."DocEntry" AS "Key Entrega",  -- DLN1 (Líneas de entrega)
    T3."DocDate" AS "Fecha Entrega",  -- ODLN (Encabezado de entrega)
    T3."DocDueDate" AS "Fecha Venc Entrega",  -- ODLN (Encabezado de entrega)
    T3."DocNum" AS "N° Entrega",  -- ODLN (Encabezado de entrega)
    T3."CANCELED" AS "Cancelado Entrega",  -- ODLN (Encabezado de entrega)
    T1."Price",  -- RDR1 (Líneas de orden de venta)
    T8."U_LAB_SIS_FABRIC",  -- OITM (Artículos)
    CASE
        WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno'  -- Error Interno
        WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo' -- Error Externo
        ELSE 'Sin error'
    END AS "Tipo de error",  -- ORDR (Orden de venta)
    CASE
        WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega'
        WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial'
        WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario'
        WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio'
        WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago'
        WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte'
        ELSE 'Sin error'
    END AS "Causa de error"  -- ORDR (Orden de venta)
   
FROM ORDR T0  -- ORDR (Orden de venta)
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  -- RDR1 (Líneas de orden de venta)
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode"  -- DLN1 (Líneas de entrega)
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"  -- ODLN (Encabezado de entrega)
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17'  -- ADOC (Documentos de pago)
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode"  -- OITM (Artículos)
WHERE (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA'))  -- RDR1 (Líneas de orden de venta)
AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1')  -- ADOC (Documentos de pago)
AND T1."ItemCode" LIKE '07%'  -- RDR1 (Líneas de orden de venta)
AND T0."CardCode" = 'C0990004196001'  -- ORDR (Orden de venta)
AND T0."DocNum" = '24004100'  -- ORDR (Orden de venta)
AND T0."DocDate" BETWEEN '2024-12-01' AND '2024-12-31'  -- ORDR (Orden de venta)
ORDER BY 
    T0."DocNum",  -- ORDR (Orden de venta)
    T0."DocDate",  -- ORDR (Orden de venta)
    T1."ItemCode",  -- RDR1 (Líneas de orden de venta)
    T3."DocDate";  -- ODLN (Encabezado de entrega)


-- ********************************************************************************************

SELECT
    T0."DocEntry", 
    T0."DocStatus", 
    T0."CANCELED", 
    T0."DocNum", 
    T0."NumAtCard", 
    T0."DocDate", 
    T0."DocDueDate", 
    IFNULL(T5."DocDueDate", T0."DocDueDate") AS "FECHA INICIAL",  -- ADOC (Documento de pago)
    DAYS_BETWEEN(IFNULL(T5."DocDueDate", T0."DocDueDate"), T3."DocDueDate") AS "DIAS DIF",  -- ODLN (Entregas)
    T0."CardCode", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription", 
    T1."UomCode", 
    T1."NumPerMsr", 
    T1."Quantity", 
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad Pedida", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante", 
    ROUND(T1."DelivrdQty"), 
    IFNULL(T1."DelivrdQty" * T1."NumPerMsr", 0) AS "DelivrdQty UND", 
    IFNULL(T2."Quantity" * T2."NumPerMsr", 0) AS "Cantidad Entregada",  -- DLN1 (Líneas de entrega)
    T1."WhsCode", 
    T2."QtyToShip",  
    T2."OrderedQty",  
    T2."DocEntry" AS "Key Entrega",  
    T3."DocDate" AS "Fecha Entrega",  
    T3."DocDueDate" AS "Fecha Venc Entrega",  
    T3."DocNum" AS "N° Entrega",  
    T3."CANCELED" AS "Cancelado Entrega",  
    T1."Price",  
    T8."U_LAB_SIS_FABRIC",  
    CASE
        WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno'  -- Error Interno
        WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo' -- Error Externo
        ELSE 'Sin error'
    END AS "Tipo de error",  
    CASE
        WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega'
        WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial'
        WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario'
        WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio'
        WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago'
        WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte'
        ELSE 'Sin error'
    END AS "Causa de error",
     CASE        
         WHEN T0."U_ERR_ENTR" = '1' AND T0."U_MOT_ERR_ENTR" IN ('1.1', '1.2', '1.3', '1.4', '1.5') THEN 'Interno'        
         WHEN T0."U_ERR_ENTR" = '2' AND T0."U_MOT_ERR_ENTR" IN ('2.1', '2.2', '2.3') THEN 'Externo'        
         ELSE 'Sin Error'    
    END AS "Error de Entrega",
    T0."U_MOT_ERR_ENTR" 
   
FROM ORDR T0  -- ORDR (Orden de venta)
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  -- RDR1 (Líneas de orden de venta)
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode"  -- DLN1 (Líneas de entrega)
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"  -- ODLN (Encabezado de entrega)
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17'  -- ADOC (Documentos de pago)
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode"  -- OITM (Artículos)
WHERE (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA'))
AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1')
AND T1."ItemCode" LIKE '07%' 
AND T0."CardCode" = 'C0990004196001' 
AND T0."DocNum" = '24004100' 
AND T0."DocDate" BETWEEN '2024-12-01' AND '2024-12-31' 
ORDER BY 
    T0."DocNum",  
    T0."DocDate",  
    T1."ItemCode",  
    T3."DocDate"; 

  



-- *****************************
/* AÑADIR LA CANTIDAD SIN ENTREGAR */
CREATE VIEW "SBO_FIGURETTI_PRO"."DPE_ESTADO_OV" ( 
    "Key Pedido",
    "Status OV",
    "Cancelado",
    "N° Pedido",
    "NumAtCard",
    "Fecha Pedido",
    "Fecha Entrega Actual",
    "FECHA Entrega INICIAL",
    "DIAS DIF",
    "CardCode",
    "CardName",
    "ItemCode",
    "Dscription",
    "Unidad de Medida",
    "Cant UoM",
    "Cantidad Pedida",
    "Cantidad Abierta Restante",
    "Enviado desde el Pedido",
    "DelivrdQty UND",
    "Cantidad Entregada",
    "Almacen",
    "QtyToShip",
    "OrderedQty",
    "Key Entrega",
    "Fecha Entrega",
    "Fecha Venc Entrega",
    "N° Entrega",
    "Cancelado Entrega",
    "Price",
    "SIS_FABRIC",
    "Tipo de error",
	"Causa de error",
    "Cantidad Sin Entregar" ) AS 
        SELECT
            T0."DocEntry",
            T0."DocStatus",
            T0."CANCELED",
            T0."DocNum",
            T0."NumAtCard" ,
            T0."DocDate",
            T0."DocDueDate",
            IFNULL(T5."DocDueDate",
            T0."DocDueDate") AS "FECHA INICIAL",
            DAYS_BETWEEN(IFNULL(T5."DocDueDate",
            T0."DocDueDate"),
            T3."DocDueDate") AS "DIAS DIF",
            T0."CardCode",
            T0."CardName",
            T1."ItemCode",
            T1."Dscription",
            T1."UomCode",
            T1."NumPerMsr",
            T1."Quantity"*T1."NumPerMsr" AS "Cantidad Pedida",
            T1."OpenQty"*T1."NumPerMsr" AS "Cantidad Abierta Restante",
            ROUND(T1."DelivrdQty"),
            IFNULL(T1."DelivrdQty"*T1."NumPerMsr", 0) AS "DelivrdQty UND",
            IFNULL(T2."Quantity"*T2."NumPerMsr", 0) AS "Cantidad Entregada",
            T1."WhsCode",
            T2."QtyToShip",
            T2."OrderedQty",
            T2."DocEntry" AS "Key Entrega",
            T3."DocDate" AS "Fecha Entrega",
            T3."DocDueDate" AS "Fecha Venc Entrega",
            T3."DocNum" AS "N° Entrega",
            T3."CANCELED" AS "Cancelado Entrega",
            T1."Price",
            T8."U_LAB_SIS_FABRIC",
            CASE 
                WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno' 
                WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo' 
                ELSE 'Sin error' 
            END AS "Tipo de error",
            CASE 
                WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción' 
                WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción' 
                WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega' 
                WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial' 
                WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario' 
                WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio' 
                WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago' 
                WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte' 
                ELSE 'Sin error' 
            END AS "Causa de error",
            (T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar" 
        FROM ORDR T0 
        INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
        LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode" 
        LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry" --AND T3."CANCELED" = 'N'
        LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17' 
        LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode" 
        WHERE (T1."WhsCode" = '10PTD' 
            OR T1."WhsCode" = '10FPTD' 
            OR T1."WhsCode" = '10PTI' 
            OR T1."WhsCode" = '10EPTD' 
            OR T1."WhsCode" = '10PTA') 
        AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1' ) 
        AND T1."ItemCode" LIKE '07%' 
        ORDER BY 
            T0."DocDate",
            T1."ItemCode",
            T3."DocDate" ASC WITH READ ONLY



SELECT * FROM "SBO_FIGURETTI_PRO"."DPE_ESTADO_OV"
ORDER BY "N° Pedido"




-- *********************************************
/* revisar mñn  */
SELECT
    T0."DocEntry",
    T0."DocStatus",
    T0."CANCELED",
    T0."DocNum",
    T0."NumAtCard" ,
    T0."DocDate",
    T0."DocDueDate",
    IFNULL(T5."DocDueDate",T0."DocDueDate") AS "FECHA INICIAL",
    DAYS_BETWEEN(IFNULL(T5."DocDueDate",T0."DocDueDate"),T3."DocDueDate") AS "DIAS DIF",
    T0."CardCode",
    T0."CardName",
    T1."ItemCode",
    T1."Dscription",
    T1."UomCode",
    T1."NumPerMsr",
    T1."Quantity"*T1."NumPerMsr" AS "Cantidad Pedida",
    T1."OpenQty"*T1."NumPerMsr" AS "Cantidad Abierta Restante",
    ROUND(T1."DelivrdQty"),
    IFNULL(T1."DelivrdQty"*T1."NumPerMsr", 0) AS "DelivrdQty UND",
    IFNULL(T2."Quantity"*T2."NumPerMsr", 0) AS "Cantidad Entregada",
    T1."WhsCode",
    T2."QtyToShip",
    T2."OrderedQty",
    T2."DocEntry" AS "Key Entrega",
    T3."DocDate" AS "Fecha Entrega",
    T3."DocDueDate" AS "Fecha Venc Entrega",
    T3."DocNum" AS "N° Entrega",
    T3."CANCELED" AS "Cancelado Entrega",
    T1."Price",
    T8."U_LAB_SIS_FABRIC",
    CASE 
        WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno' 
        WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo' 
        ELSE 'Sin error' 
    END AS "Tipo de error",
    CASE 
        WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción' 
        WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción' 
        WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega' 
        WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial' 
        WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario' 
        WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio' 
        WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago' 
        WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte' 
        ELSE 'Sin error' 
    END AS "Causa de error",
    (T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar" 
    FROM ORDR T0 
    INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
    LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode" 
    LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry" --AND T3."CANCELED" = 'N'
    LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17' 
    LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode" 
    WHERE (T1."WhsCode" = '10PTD' 
        OR T1."WhsCode" = '10FPTD' 
        OR T1."WhsCode" = '10PTI' 
        OR T1."WhsCode" = '10EPTD' 
        OR T1."WhsCode" = '10PTA') 
    AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1' ) 
    AND T1."ItemCode" LIKE '07%' 
    AND T0."CardCode" = 'C0990004196001'   
    --AND T0."DocNum" = '24004100' 
    AND T0."DocDate" BETWEEN '2024-11-01' AND '2024-12-31'
    ORDER BY 
        T0."DocDate",
        T1."ItemCode",
        T3."DocDate"


            /* revisar en la vista 
            
            (T1."Quantity" - T1."DelivrdQty") * ( T ) AS "Cantidad Sin Entregar"
             */


             /* 
             
             
             SELECT 
* 
FROM "SBO_FIGURETTI_PRO"."DPE_ESTADO_OV" T0 
WHERE 
  T0."Fecha Pedido" BETWEEN '2024-12-12' AND '2024-12-12'
  AND T0."N° Pedido" = '24004100'
  
  
/*SELECT 
* 
FROM "SBO_FIGURETTI_PRO"."DPE_ESTADO_OV" T0 
WHERE 
  T0."Fecha Pedido" BETWEEN '2024-12-12' AND '2024-12-12'
  AND T0."N° Pedido" = '24004089'*/
 */


AXIONLOG ECUADOR S.A.

/* EL ACUMULADOR */
IF {Comando.Cantidad Entregada} = 0 THEN 0  
ELSE 
IF {Comando.Cantidad Pedida} = 0 THEN 100 
ELSE
( ({Comando.Cantidad Pedida} - {Comando.QtyToShip}) / {Comando.Cantidad Pedida} ) * 100





IF {Comando.Cantidad Pedida} = 0 THEN 100
ELSE IF {Comando.Cantidad Entregada} = 0 THEN 0
ELSE
( {Comando.Cantidad Entregada} / {Comando.Cantidad Pedida} ) * 100




/* 
    Datos Proporcionados
    Cantidad Pedida: 120 (artículos).
    Artículos por Unidad de Medida (cartón): 15 (esto indica cuántos artículos hay en cada cartón).
    Cantidad Total en Unidades de Medida (UoM): 1,800 (esto se calcula como 
    120 × 15 = 1,800
    
    Cantidad Entregada: 21 (artículos).
    Cálculo de Cantidad Sin Entregar
Para calcular la cantidad sin entregar en términos de unidades totales, primero necesitamos entender cómo se relacionan las cantidades:
Cantidad Total Pedida en Unidades:
Esto ya lo has mencionado como 1,800, que es el resultado de multiplicar la cantidad pedida (120) por los artículos por cartón (15):
Cantidad Total Pedida
= 120 × 15 = 1,800 art culos

Cantidad Total Pedida=120×15=1,800 art culos
Cantidad Entregada en Unidades:
La cantidad entregada es simplemente 21 artículos.
Calcular la Cantidad Sin Entregar:
Para encontrar la cantidad sin entregar, restamos la cantidad entregada de la cantidad total pedida:
Cantidad Sin Entregar
=
Cantidad Total Pedida
−
Cantidad Entregada
Cantidad Sin Entregar=Cantidad Total Pedida−Cantidad Entregada
Sustituyendo los valores:
Cantidad Sin Entregar
= 1,800
−
21
=
1
,
779
 art culos
Cantidad Sin Entregar=1,800−21=1,779 art culos
Resumen
Cantidad Total Pedida: 1,800 artículos
Cantidad Entregada: 21 artículos
Cantidad Sin Entregar: 1,779 artículos

 */



SELECT
    T0."DocEntry", 
    T0."DocStatus", 
    T0."CANCELED", 
    T0."DocNum", 
    T0."NumAtCard", 
    T0."DocDate", 
    T0."DocDueDate", 
    IFNULL(T5."DocDueDate", T0."DocDueDate") AS "FECHA INICIAL",  -- ADOC (Documento de pago)
    DAYS_BETWEEN(IFNULL(T5."DocDueDate", T0."DocDueDate"), T3."DocDueDate") AS "DIAS DIF",  -- ODLN (Entregas)
    T0."CardCode", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription", 
    T1."UomCode", 
    T1."NumPerMsr", 
    T1."Quantity", 
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad Pedida", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante", 
    ROUND(T1."DelivrdQty"), 
    IFNULL(T1."DelivrdQty" * T1."NumPerMsr", 0) AS "DelivrdQty UND", 
    IFNULL(T2."Quantity" * T2."NumPerMsr", 0) AS "Cantidad Entregada",  -- DLN1 (Líneas de entrega)
    T1."WhsCode", 
    T2."QtyToShip",  
    T2."OrderedQty",  
    T2."DocEntry" AS "Key Entrega",  
    T3."DocDate" AS "Fecha Entrega",  
    T3."DocDueDate" AS "Fecha Venc Entrega",  
    T3."DocNum" AS "N° Entrega",  
    T3."CANCELED" AS "Cancelado Entrega",  
    T1."Price",  
    T8."U_LAB_SIS_FABRIC",  
    CASE
        WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno'  -- Error Interno
        WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo' -- Error Externo
        ELSE 'Sin error'
    END AS "Tipo de error",  
    CASE
        WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega'
        WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial'
        WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario'
        WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio'
        WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago'
        WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte'
        ELSE 'Sin error'
    END AS "Causa de error",
     CASE        
         WHEN T0."U_ERR_ENTR" = '1' AND T0."U_MOT_ERR_ENTR" IN ('1.1', '1.2', '1.3', '1.4', '1.5') THEN 'Interno'        
         WHEN T0."U_ERR_ENTR" = '2' AND T0."U_MOT_ERR_ENTR" IN ('2.1', '2.2', '2.3') THEN 'Externo'        
         ELSE 'Sin Error'    
    END AS "Error de Entrega",
    T0."U_MOT_ERR_ENTR",
    (T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar",
     T1."UomCode",
    
  CASE 
       WHEN T1."UomCode" = 'CARTON' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * 15  -- Ejemplo: convertir a unidades si es CARTON
       WHEN T1."UomCode" = 'PACK' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * 10  -- Ejemplo: convertir a unidades si es PACK
       WHEN T1."UomCode" = 'UNIDAD' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0))      -- Unidades directas
       WHEN T1."UomCode" = 'FUNDA' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * 5   -- Ejemplo: convertir a unidades si es FUNDA
       ELSE 0  -- Valor por defecto si no coincide con ninguna unidad conocida
   END AS "Calculo"
   
FROM ORDR T0  -- ORDR (Orden de venta)
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  -- RDR1 (Líneas de orden de venta)
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode"  -- DLN1 (Líneas de entrega)
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"  -- ODLN (Encabezado de entrega)
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17'  -- ADOC (Documentos de pago)
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode"  -- OITM (Artículos)
WHERE (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA'))
AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1')
AND T1."ItemCode" LIKE '07%' 
--AND T0."CardCode" = 'C0990004196001' 
--AND T0."DocNum" = '24004100' 
AND T0."DocDate" BETWEEN '2024-12-01' AND '2024-12-31' 
ORDER BY 
    T0."DocNum",  
    T0."DocDate",  
    T1."ItemCode",  
    T3."DocDate";


    /* opcion 2 */

    SELECT
    T0."DocEntry", 
    T0."DocStatus", 
    T0."CANCELED", 
    T0."DocNum", 
    T0."NumAtCard", 
    T0."DocDate", 
    T0."DocDueDate", 
    IFNULL(T5."DocDueDate", T0."DocDueDate") AS "FECHA INICIAL",  -- ADOC (Documento de pago)
    DAYS_BETWEEN(IFNULL(T5."DocDueDate", T0."DocDueDate"), T3."DocDueDate") AS "DIAS DIF",  -- ODLN (Entregas)
    T0."CardCode", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription", 
    T1."UomCode", 
    T1."NumPerMsr", 
    T1."Quantity", 
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad Pedida", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante", 
    ROUND(T1."DelivrdQty"), 
    IFNULL(T1."DelivrdQty" * T1."NumPerMsr", 0) AS "DelivrdQty UND", 
    IFNULL(T2."Quantity" * T2."NumPerMsr", 0) AS "Cantidad Entregada",  -- DLN1 (Líneas de entrega)
    T1."WhsCode", 
    T2."QtyToShip",  
    T2."OrderedQty",  
    T2."DocEntry" AS "Key Entrega",  
    T3."DocDate" AS "Fecha Entrega",  
    T3."DocDueDate" AS "Fecha Venc Entrega",  
    T3."DocNum" AS "N° Entrega",  
    T3."CANCELED" AS "Cancelado Entrega",  
    T1."Price",  
    T8."U_LAB_SIS_FABRIC",  
    CASE
        WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno'  -- Error Interno
        WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo' -- Error Externo
        ELSE 'Sin error'
    END AS "Tipo de error",  
    CASE
        WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega'
        WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial'
        WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario'
        WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio'
        WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago'
        WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte'
        ELSE 'Sin error'
    END AS "Causa de error",
     CASE        
         WHEN T0."U_ERR_ENTR" = '1' AND T0."U_MOT_ERR_ENTR" IN ('1.1', '1.2', '1.3', '1.4', '1.5') THEN 'Interno'        
         WHEN T0."U_ERR_ENTR" = '2' AND T0."U_MOT_ERR_ENTR" IN ('2.1', '2.2', '2.3') THEN 'Externo'        
         ELSE 'Sin Error'    
    END AS "Error de Entrega",
    T0."U_MOT_ERR_ENTR",
    (T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar",
     T1."UomCode",
    
--   CASE 
--        WHEN T1."UomCode" = 'CARTON' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  -- Convertir a unidades si es CARTON
--        WHEN T1."UomCode" = 'PACK' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  -- Convertir a unidades si es PACK
--        WHEN T1."UomCode" = 'UNIDAD' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * 1          -- Unidades directas, no multiplicar
--        WHEN T1."UomCode" = 'FUNDA' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr" -- Convertir a unidades si es FUNDA
--        ELSE 0  -- Valor por defecto si no coincide con ninguna unidad conocida
--    END AS "Calculo"

   CASE 
       WHEN T1."UomCode" = 'CARTON' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  
       WHEN T1."UomCode" = 'PACK' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  
       WHEN T1."UomCode" = 'UNIDAD' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * 1          
       WHEN T1."UomCode" = 'FUNDA' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr" 
       ELSE 0  
   END AS "Calculo"
   
FROM ORDR T0  -- ORDR (Orden de venta)
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  -- RDR1 (Líneas de orden de venta)
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode"  -- DLN1 (Líneas de entrega)
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"  -- ODLN (Encabezado de entrega)
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17'  -- ADOC (Documentos de pago)
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode"  -- OITM (Artículos)
WHERE (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA'))
AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1')
AND T1."ItemCode" LIKE '07%' 
AND T0."CardCode" = 'C0990004196001' 
AND T0."DocNum" = '24003992' --'24004100' 
AND T0."DocDate" BETWEEN '2024-12-01' AND '2024-12-31' 
ORDER BY 
    T0."DocNum",  
    T0."DocDate",  
    T1."ItemCode",  
    T3."DocDate";



-- ***************************************************************

SELECT
    T0."DocEntry", 
    T0."DocStatus", 
    T0."CANCELED", 
    T0."DocNum", 
    T0."NumAtCard", 
    T0."DocDate", 
    T0."DocDueDate", 
    IFNULL(T5."DocDueDate", T0."DocDueDate") AS "FECHA INICIAL",  -- ADOC (Documento de pago)
    DAYS_BETWEEN(IFNULL(T5."DocDueDate", T0."DocDueDate"), T3."DocDueDate") AS "DIAS DIF",  -- ODLN (Entregas)
    T0."CardCode", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription", 
    T1."UomCode", 
    T1."NumPerMsr", 
    T1."Quantity", 
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad Pedida", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante", 
    ROUND(T1."DelivrdQty"), 
    IFNULL(T1."DelivrdQty" * T1."NumPerMsr", 0) AS "DelivrdQty UND", 
    IFNULL(T2."Quantity" * T2."NumPerMsr", 0) AS "Cantidad Entregada",  -- DLN1 (Líneas de entrega)
    T1."WhsCode", 
    T2."QtyToShip",  
    T2."OrderedQty",  
    T2."DocEntry" AS "Key Entrega",  
    T3."DocDate" AS "Fecha Entrega",  
    T3."DocDueDate" AS "Fecha Venc Entrega",  
    T3."DocNum" AS "N° Entrega",  
    T3."CANCELED" AS "Cancelado Entrega",  
    T1."Price",  
    T8."U_LAB_SIS_FABRIC",  
    CASE
        WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno'  -- Error Interno
        WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo' -- Error Externo
        ELSE 'Sin error'
    END AS "Tipo de error",  
    CASE
        WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega'
        WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial'
        WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario'
        WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio'
        WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago'
        WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte'
        ELSE 'Sin error'
    END AS "Causa de error",
     CASE        
         WHEN T0."U_ERR_ENTR" = '1' AND T0."U_MOT_ERR_ENTR" IN ('1.1', '1.2', '1.3', '1.4', '1.5') THEN 'Interno'        
         WHEN T0."U_ERR_ENTR" = '2' AND T0."U_MOT_ERR_ENTR" IN ('2.1', '2.2', '2.3') THEN 'Externo'        
         ELSE 'Sin Error'    
    END AS "Error de Entrega",
    T0."U_MOT_ERR_ENTR",
   
     T1."UomCode",
     T1."Quantity",
     T1."DelivrdQty",
     T1."NumPerMsr",
     (T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar",
    
  CASE 
       WHEN T1."UomCode" = 'CARTON' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  
       WHEN T1."UomCode" = 'PACK' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  
       WHEN T1."UomCode" = 'UNIDAD' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * 1          
       WHEN T1."UomCode" = 'FUNDA' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr" 
       ELSE 0  
   END AS "Calculo"
   
FROM ORDR T0  -- ORDR (Orden de venta)
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  -- RDR1 (Líneas de orden de venta)
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode"  -- DLN1 (Líneas de entrega)
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"  -- ODLN (Encabezado de entrega)
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17'  -- ADOC (Documentos de pago)
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode"  -- OITM (Artículos)
WHERE (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA'))
AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1')
AND T1."ItemCode" LIKE '07%' 
AND T0."CardCode" = 'C0990004196001' 
AND T0."DocNum" = '24003992' --'24004100' 
AND T0."DocDate" BETWEEN '2024-12-01' AND '2024-12-31' 
ORDER BY 
    T0."DocNum",  
    T0."DocDate",  
    T1."ItemCode",  
    T3."DocDate";



/* ultimo modificaciones */
SELECT
    T0."DocEntry", 
    T0."DocStatus", 
    T0."CANCELED", 
    T0."DocNum", 
    T0."NumAtCard", 
    T0."DocDate", 
    T0."DocDueDate", 
    IFNULL(T5."DocDueDate", T0."DocDueDate") AS "FECHA INICIAL",  -- ADOC (Documento de pago)
    DAYS_BETWEEN(IFNULL(T5."DocDueDate", T0."DocDueDate"), T3."DocDueDate") AS "DIAS DIF",  -- ODLN (Entregas)
    T0."CardCode", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription", 
    T1."UomCode", 
    T1."NumPerMsr", 
    T1."Quantity", 
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad Pedida", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante", 
    ROUND(T1."DelivrdQty"), 
    IFNULL(T1."DelivrdQty" * T1."NumPerMsr", 0) AS "DelivrdQty UND", 
    IFNULL(T2."Quantity" * T2."NumPerMsr", 0) AS "Cantidad Entregada",  -- DLN1 (Líneas de entrega)
    T1."WhsCode", 
    T2."QtyToShip",  
    T2."OrderedQty",  
    T2."DocEntry" AS "Key Entrega",  
    T3."DocDate" AS "Fecha Entrega",  
    T3."DocDueDate" AS "Fecha Venc Entrega",  
    T3."DocNum" AS "N° Entrega",  
    T3."CANCELED" AS "Cancelado Entrega",  
    T1."Price",  
    T8."U_LAB_SIS_FABRIC",  
    CASE
        WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno'  -- Error Interno
        WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo' -- Error Externo
        ELSE 'Sin error'
    END AS "Tipo de error",  
    CASE
        WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega'
        WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial'
        WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario'
        WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio'
        WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago'
        WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte'
        ELSE 'Sin error'
    END AS "Causa de error",
     CASE        
         WHEN T0."U_ERR_ENTR" = '1' AND T0."U_MOT_ERR_ENTR" IN ('1.1', '1.2', '1.3', '1.4', '1.5') THEN 'Interno'        
         WHEN T0."U_ERR_ENTR" = '2' AND T0."U_MOT_ERR_ENTR" IN ('2.1', '2.2', '2.3') THEN 'Externo'        
         ELSE 'Sin Error'    
    END AS "Error de Entrega",
    T0."U_MOT_ERR_ENTR",
   
     
     T1."Quantity",
     T1."UomCode",
    T1."NumPerMsr" AS "Articulos por unidad",
     T1."InvQty",
     T1."DelivrdQty",  

    T1."DelivrdQty" * T1."NumPerMsr" AS "Cantidad Pedida",

    T1."Quantity", T2."Quantity",
     (T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar",

  CASE 
       WHEN T1."UomCode" = 'CARTON' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  
       WHEN T1."UomCode" = 'PACK' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  
       WHEN T1."UomCode" = 'UN' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * 1          
       WHEN T1."UomCode" = 'FUNDA' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr" 
       ELSE 0  
   END AS "Cantidad Sin Entregar en Unidades"
   
FROM ORDR T0  -- ORDR (Orden de venta)
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  -- RDR1 (Líneas de orden de venta)
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode"  -- DLN1 (Líneas de entrega)
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"  -- ODLN (Encabezado de entrega)
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17'  -- ADOC (Documentos de pago)
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode"  -- OITM (Artículos)
WHERE (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA'))
AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1')
AND T1."ItemCode" LIKE '07%' 
AND T0."CardCode" = 'C0990004196001' 
AND T0."DocNum" = '24003992' --'24004100' 
AND T0."DocDate" BETWEEN '2024-12-01' AND '2024-12-31' 
ORDER BY 
    T0."DocNum",  
    T0."DocDate",  
    T1."ItemCode",  
    T3."DocDate";


    ORDR T0  INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry", 
    DLN1 T2 INNER JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"





    -- **************************************
SELECT 
    T0."ItemCode" AS "Código de Artículo", 
    T0."ItemName" AS "Nombre de Artículo", 
    T1."WhsCode" AS "Código de Bodega",
    T1."OnHand" AS "Stock Disponible"
FROM 
    OITM T0 
INNER JOIN 
    OITW T1 ON T0."ItemCode" = T1."ItemCode"
WHERE 
    (T0."ItemCode" LIKE '07%' 
   OR T0."ItemCode" LIKE '04%')
  AND T1."Locked" = 'N'
ORDER BY 
    T0."ItemCode"
LIMIT 15;




SELECT 
    T0."ItemCode" AS "Código de Artículo", 
    T0."ItemName" AS "Nombre de Artículo",
    (SELECT TOP 1 T1."WhsCode" 
     FROM OITW T1 
     WHERE T1."ItemCode" = T0."ItemCode" 
       AND T1."Locked" = 'N') AS "Código de Bodega",
    (SELECT TOP 1 T1."OnHand" 
     FROM OITW T1 
     WHERE T1."ItemCode" = T0."ItemCode" 
       AND T1."Locked" = 'N') AS "Stock Disponible"
FROM 
    OITM T0
WHERE 
    (T0."ItemCode" LIKE '04%' OR T0."ItemCode" LIKE '07%')
ORDER BY 
    T0."ItemCode"
LIMIT 15;




SELECT 
    T0."ItemCode" AS "Código de Artículo", 
    T0."ItemName" AS "Nombre de Artículo",
    T1."WhsCode" AS "Código de Bodega",
    T1."OnHand" AS "Stock Disponible"
FROM 
    OITM T0
LEFT JOIN (
    SELECT 
        "ItemCode", 
        "WhsCode", 
        "OnHand",
        ROW_NUMBER() OVER (PARTITION BY "ItemCode" ORDER BY "WhsCode") AS rn
    FROM 
        OITW
    WHERE 
        "Locked" = 'N'
) T1 ON T0."ItemCode" = T1."ItemCode" AND T1.rn = 1
WHERE 
    (T0."ItemCode" LIKE '04%' OR T0."ItemCode" LIKE '07%')
ORDER BY 
    T0."ItemCode"
LIMIT 15;


SELECT 
    T0."ItemCode" AS "Código de Artículo", 
    T0."ItemName" AS "Nombre de Artículo",
    (SELECT "WhsCode" 
     FROM OITW T1 
     WHERE T1."ItemCode" = T0."ItemCode" 
       AND T1."Locked" = 'N'
     LIMIT 1) AS "Código de Bodega",
    (SELECT "OnHand" 
     FROM OITW T1 
     WHERE T1."ItemCode" = T0."ItemCode" 
       AND T1."Locked" = 'N'
     LIMIT 1) AS "Stock Disponible"
FROM 
    OITM T0
WHERE 
    (T0."ItemCode" LIKE '04%' OR T0."ItemCode" LIKE '07%')
ORDER BY 
    T0."ItemCode"
LIMIT 15;


SELECT *  FROM OITM T0 WHERE T0."ItemCode" = '07DSB10630013' --DfltWH


-- ********************************************************************
SELECT 
  T0."ItemCode", 
  T0."ItemName",
  T0."DfltWH",
  T0."OnHand"
FROM OITM T0 
WHERE 
   (T0."ItemCode" LIKE '04%' OR T0."ItemCode" LIKE '07%');



-- **************************************************************************
-- Listado de los articulos con la bodega estandar
SELECT 
  T0."ItemCode", 
  T0."ItemName",
  T0."DfltWH",
  T0."OnHand"
FROM OITM T0 
WHERE 
   (T0."ItemCode" LIKE '04%' OR T0."ItemCode" LIKE '07%')
ORDER BY T0."ItemCode";


SELECT 
* 
FROM ORDR T0
WHERE T0."CardCode" = 'C0992233656001'




-- **********************************************************************************
-- revisar este query por se repite en "DocEntry" = '52874'


SELECT
    T0."DocEntry", 
    T0."DocStatus", 
    T0."CANCELED", 
    T0."DocNum", 
    T0."NumAtCard", 
    T0."DocDate", 
    T0."DocDueDate", 
    IFNULL(T5."DocDueDate", T0."DocDueDate") AS "FECHA INICIAL",  -- ADOC (Documento de pago)
    DAYS_BETWEEN(IFNULL(T5."DocDueDate", T0."DocDueDate"), T3."DocDueDate") AS "DIAS DIF",  -- ODLN (Entregas)
    T0."CardCode", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription", 
    T1."UomCode", 
    T1."NumPerMsr", 
    T1."Quantity", 
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad Pedida", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante", 
    ROUND(T1."DelivrdQty"), 
    IFNULL(T1."DelivrdQty" * T1."NumPerMsr", 0) AS "DelivrdQty UND", 
    IFNULL(T2."Quantity" * T2."NumPerMsr", 0) AS "Cantidad Entregada",  -- DLN1 (Líneas de entrega)
    T1."WhsCode", 
    T2."QtyToShip",  
    T2."OrderedQty",  
    T2."DocEntry" AS "Key Entrega",  
    T3."DocDate" AS "Fecha Entrega",  
    T3."DocDueDate" AS "Fecha Venc Entrega",  
    T3."DocNum" AS "N° Entrega",  
    T3."CANCELED" AS "Cancelado Entrega",  
    T1."Price",  
    T8."U_LAB_SIS_FABRIC",  
    CASE
        WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno'  -- Error Interno
        WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo' -- Error Externo
        ELSE 'Sin error'
    END AS "Tipo de error",  
    CASE
        WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega'
        WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial'
        WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario'
        WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio'
        WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago'
        WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte'
        ELSE 'Sin error'
    END AS "Causa de error",
     CASE        
         WHEN T0."U_ERR_ENTR" = '1' AND T0."U_MOT_ERR_ENTR" IN ('1.1', '1.2', '1.3', '1.4', '1.5') THEN 'Interno'        
         WHEN T0."U_ERR_ENTR" = '2' AND T0."U_MOT_ERR_ENTR" IN ('2.1', '2.2', '2.3') THEN 'Externo'        
         ELSE 'Sin Error'    
    END AS "Error de Entrega",
    T0."U_MOT_ERR_ENTR",
   
     
     T1."Quantity",
     T1."UomCode",
    T1."NumPerMsr" AS "Articulos por unidad",
     T1."InvQty",
     T1."DelivrdQty",  

    T1."DelivrdQty" * T1."NumPerMsr" AS "Cantidad Pedida",

    T1."Quantity", T2."Quantity",
     (T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar",

  CASE 
       WHEN T1."UomCode" = 'CARTON' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  
       WHEN T1."UomCode" = 'PACK' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  
       WHEN T1."UomCode" = 'UN' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * 1          
       WHEN T1."UomCode" = 'FUNDA' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr" 
       ELSE 0  
   END AS "Cantidad Sin Entregar en Unidades"
   
FROM ORDR T0  -- ORDR (Orden de venta)
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  -- RDR1 (Líneas de orden de venta)
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode"  -- DLN1 (Líneas de entrega)
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"  -- ODLN (Encabezado de entrega)
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17'  -- ADOC (Documentos de pago)
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode"  -- OITM (Artículos)
WHERE (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA'))
AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1')
AND T1."ItemCode" LIKE '07%' 
AND T0."CardCode" = 'C0992233656001' --'C0990004196001' 
--AND T0."DocNum" = '24004039' --'24003992' --'24004100' 
AND T0."DocDate" BETWEEN '2024-12-01' AND '2024-12-31' 
ORDER BY 
    T0."DocNum",  
    T0."DocDate",  
    T1."ItemCode",  
    T3."DocDate";




    /* CORRECION NUMERO DE LINEA */

    SELECT
T2."BaseDocNum",
T0."DocNum",

T1."LineNum",
T2."LineNum",

T1."TrgetEntry",
T2."TrgetEntry",

T1."BaseEntry",
T2."BaseEntry"--,
 
--* 
FROM ORDR T0
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN DLN1 T2 ON T1."ItemCode" = T2."ItemCode"  AND T2."BaseDocNum" = T0."DocNum" AND T1."LineNum" = T2."LineNum"
WHERE 
T0."DocEntry" = '52874'


/* POR EL MOMENTO QUEDA EL QUERY ASI */
SELECT
    T0."DocEntry", 
    T0."DocStatus", 
    T0."CANCELED", 
    T0."DocNum", 
    T0."NumAtCard", 
    T0."DocDate", 
    T0."DocDueDate", 
    IFNULL(T5."DocDueDate", T0."DocDueDate") AS "FECHA INICIAL",  -- ADOC (Documento de pago)
    DAYS_BETWEEN(IFNULL(T5."DocDueDate", T0."DocDueDate"), T3."DocDueDate") AS "DIAS DIF",  -- ODLN (Entregas)
    T0."CardCode", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription", 
    T1."UomCode", 
    T1."NumPerMsr", 
    T1."Quantity", 
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad Pedida", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante", 
    ROUND(T1."DelivrdQty"), 
    IFNULL(T1."DelivrdQty" * T1."NumPerMsr", 0) AS "DelivrdQty UND", 
    IFNULL(T2."Quantity" * T2."NumPerMsr", 0) AS "Cantidad Entregada",  -- DLN1 (Líneas de entrega)
    T1."WhsCode", 
    T2."QtyToShip",  
    T2."OrderedQty",  
    T2."DocEntry" AS "Key Entrega",  
    T3."DocDate" AS "Fecha Entrega",  
    T3."DocDueDate" AS "Fecha Venc Entrega",  
    T3."DocNum" AS "N° Entrega",  
    T3."CANCELED" AS "Cancelado Entrega",  
    T1."Price",  
    T8."U_LAB_SIS_FABRIC",  
    CASE
        WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno'  -- Error Interno
        WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo' -- Error Externo
        ELSE 'Sin error'
    END AS "Tipo de error",  
    CASE
        WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega'
        WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial'
        WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario'
        WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio'
        WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago'
        WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte'
        ELSE 'Sin error'
    END AS "Causa de error",
     CASE        
         WHEN T0."U_ERR_ENTR" = '1' AND T0."U_MOT_ERR_ENTR" IN ('1.1', '1.2', '1.3', '1.4', '1.5') THEN 'Interno'        
         WHEN T0."U_ERR_ENTR" = '2' AND T0."U_MOT_ERR_ENTR" IN ('2.1', '2.2', '2.3') THEN 'Externo'        
         ELSE 'Sin Error'    
    END AS "Error de Entrega",
    T0."U_MOT_ERR_ENTR",
   
     
     T1."Quantity",
     T1."UomCode",
    T1."NumPerMsr" AS "Articulos por unidad",
     T1."InvQty",
     T1."DelivrdQty",  

    T1."DelivrdQty" * T1."NumPerMsr" AS "Cantidad Pedida",

    T1."Quantity", T2."Quantity",
     (T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar",

  CASE 
       WHEN T1."UomCode" = 'CARTON' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  
       WHEN T1."UomCode" = 'PACK' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  
       WHEN T1."UomCode" = 'UN' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * 1          
       WHEN T1."UomCode" = 'FUNDA' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr" 
       ELSE 0  
   END AS "Cantidad Sin Entregar en Unidades"
   
FROM ORDR T0  -- ORDR (Orden de venta)
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  -- RDR1 (Líneas de orden de venta)
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode" AND T1."LineNum" = T2."LineNum"  -- DLN1 (Líneas de entrega)
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"  -- ODLN (Encabezado de entrega)
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17'  -- ADOC (Documentos de pago)
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode"  -- OITM (Artículos)
WHERE (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA'))
AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1')
AND T1."ItemCode" LIKE '07%' 
AND T0."CardCode" = 'C0992233656001' --'C0990004196001' 
AND T0."DocEntry" = '52874'
--AND T0."DocNum" = '24004039' --'24003992' --'24004100' 
AND T0."DocDate" BETWEEN '2024-12-01' AND '2024-12-31' 
ORDER BY 
    T0."DocNum",  
    T0."DocDate",  
    T1."ItemCode",  
    T3."DocDate";



-- *********************************ASI POR EL MOMENTO******************************************
SELECT
    T0."DocEntry", 
    T0."DocStatus", 
    T0."CANCELED", 
    T0."DocNum", 
    T0."NumAtCard", 
    T0."DocDate", 
    T0."DocDueDate", 
    IFNULL(T5."DocDueDate", T0."DocDueDate") AS "FECHA INICIAL",  -- ADOC (Documento de pago)
    DAYS_BETWEEN(IFNULL(T5."DocDueDate", T0."DocDueDate"), T3."DocDueDate") AS "DIAS DIF",  -- ODLN (Entregas)
    T0."CardCode", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription", 
    T1."UomCode", 
    T1."NumPerMsr", 
    T1."Quantity", 
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad Pedida", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante", 
    ROUND(T1."DelivrdQty"), 
    IFNULL(T1."DelivrdQty" * T1."NumPerMsr", 0) AS "DelivrdQty UND", 
    IFNULL(T2."Quantity" * T2."NumPerMsr", 0) AS "Cantidad Entregada",  -- DLN1 (Líneas de entrega)
    T1."WhsCode", 
    T2."QtyToShip",  
    T2."OrderedQty",  
    T2."DocEntry" AS "Key Entrega",  
    T3."DocDate" AS "Fecha Entrega",  
    T3."DocDueDate" AS "Fecha Venc Entrega",  
    T3."DocNum" AS "N° Entrega",  
    T3."CANCELED" AS "Cancelado Entrega",  
    T1."Price",  
    T8."U_LAB_SIS_FABRIC",  
    CASE
        WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno'  -- Error Interno
        WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo' -- Error Externo
        ELSE 'Sin error'
    END AS "Tipo de error",  
    CASE
        WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega'
        WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial'
        WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario'
        WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio'
        WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago'
        WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte'
        ELSE 'Sin error'
    END AS "Causa de error",
     CASE        
         WHEN T0."U_ERR_ENTR" = '1' AND T0."U_MOT_ERR_ENTR" IN ('1.1', '1.2', '1.3', '1.4', '1.5') THEN 'Interno'        
         WHEN T0."U_ERR_ENTR" = '2' AND T0."U_MOT_ERR_ENTR" IN ('2.1', '2.2', '2.3') THEN 'Externo'        
         ELSE 'Sin Error'    
    END AS "Error de Entrega",
    T0."U_MOT_ERR_ENTR",
   
     
     T1."Quantity",
     T1."UomCode",
    T1."NumPerMsr" AS "Articulos por unidad",
     T1."InvQty",
     T1."DelivrdQty",  

    T1."DelivrdQty" * T1."NumPerMsr" AS "Cantidad Pedida",

    T1."Quantity", T2."Quantity",
     (T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar",

  CASE 
       WHEN T1."UomCode" = 'CARTON' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  
       WHEN T1."UomCode" = 'PACK' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  
       WHEN T1."UomCode" = 'UN' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * 1          
       WHEN T1."UomCode" = 'FUNDA' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr" 
       ELSE 0  
   END AS "Cantidad Sin Entregar en Unidades"
   
FROM ORDR T0  -- ORDR (Orden de venta)
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  -- RDR1 (Líneas de orden de venta)
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode" AND T1."LineNum" = T2."LineNum"  -- DLN1 (Líneas de entrega)
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"  -- ODLN (Encabezado de entrega)
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17'  -- ADOC (Documentos de pago)
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode"  -- OITM (Artículos)
WHERE (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA'))
AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1')
AND T1."ItemCode" LIKE '07%' 
--AND T0."CardCode" = 'C0992233656001' --'C0990004196001' 
--AND T0."DocEntry" = '52874'
AND T0."DocNum" = '24004100' --'24004039' --'24003992' --'24004100' 
AND T0."DocDate" BETWEEN '2024-12-01' AND '2024-12-31' 
ORDER BY 
    T0."DocNum",  
    T0."DocDate",  
    T1."ItemCode",  
    T3."DocDate";


    /* 28/01/2025 */
/* ASI QUE DO LA CONSULTA VALIDADO POR LA CONVERSION DE SOLO PACK */
SELECT
    T0."DocEntry", 
    T0."DocStatus", 
    T0."CANCELED", 
    T0."DocNum", 
    T0."NumAtCard", 
    T0."DocDate", 
    T0."DocDueDate", 
    IFNULL(T5."DocDueDate", T0."DocDueDate") AS "FECHA INICIAL",  -- ADOC (Documento de pago)
    DAYS_BETWEEN(IFNULL(T5."DocDueDate", T0."DocDueDate"), T3."DocDueDate") AS "DIAS DIF",  -- ODLN (Entregas)
    T0."CardCode", 
    T0."CardName", 
    T1."ItemCode", 
    T1."Dscription", 
    T1."UomCode", 
    T1."NumPerMsr", 
    T1."Quantity", 
    T1."Quantity" * T1."NumPerMsr" AS "Cantidad Pedida", 
    T1."OpenQty" * T1."NumPerMsr" AS "Cantidad Abierta Restante", 
    ROUND(T1."DelivrdQty"), 
    IFNULL(T1."DelivrdQty" * T1."NumPerMsr", 0) AS "DelivrdQty UND", 
    IFNULL(T2."Quantity" * T2."NumPerMsr", 0) AS "Cantidad Entregada",  -- DLN1 (Líneas de entrega)
    T1."WhsCode", 
    T2."QtyToShip",  
    T2."OrderedQty",  
    T2."DocEntry" AS "Key Entrega",  
    T3."DocDate" AS "Fecha Entrega",  
    T3."DocDueDate" AS "Fecha Venc Entrega",  
    T3."DocNum" AS "N° Entrega",  
    T3."CANCELED" AS "Cancelado Entrega",  
    T1."Price",  
    T8."U_LAB_SIS_FABRIC",  
    CASE
        WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno'  -- Error Interno
        WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo' -- Error Externo
        ELSE 'Sin error'
    END AS "Tipo de error",  
    CASE
        WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción'
        WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega'
        WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial'
        WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario'
        WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio'
        WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago'
        WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte'
        ELSE 'Sin error'
    END AS "Causa de error",
     CASE        
         WHEN T0."U_ERR_ENTR" = '1' AND T0."U_MOT_ERR_ENTR" IN ('1.1', '1.2', '1.3', '1.4', '1.5') THEN 'Interno'        
         WHEN T0."U_ERR_ENTR" = '2' AND T0."U_MOT_ERR_ENTR" IN ('2.1', '2.2', '2.3') THEN 'Externo'        
         ELSE 'Sin Error'    
    END AS "Error de Entrega",
    T0."U_MOT_ERR_ENTR",
   
     
     T1."Quantity",
     T1."UomCode",
    T1."NumPerMsr" AS "Articulos por unidad",
     T1."InvQty",
     T1."DelivrdQty",  

    T1."DelivrdQty" * T1."NumPerMsr" AS "Cantidad Pedida",

    T1."Quantity", T2."Quantity",
     (T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar",

  /*CASE 
       WHEN T1."UomCode" = 'CARTON' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  
       WHEN T1."UomCode" = 'PACK' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr"  
       WHEN T1."UomCode" = 'UN' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * 1          
       WHEN T1."UomCode" = 'FUNDA' THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) * T1."NumPerMsr" 
       ELSE 0  
   END AS "Cantidad Sin Entregar en Unidades Anterior",*/
   
   
 CASE 
     WHEN (T1."UomCode" = 'PACK' AND T8."U_SYP_UPPL" IS NOT NULL) THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) *  T8."U_SYP_UPPL"
     WHEN (T1."UomCode" = 'PACK') THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) *  T1."NumPerMsr"
     WHEN (T1."UomCode" = 'CARTON') THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) *  T1."NumPerMsr"  
     WHEN (T1."UomCode" = 'UN') THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) *  1          
     WHEN (T1."UomCode" = 'FUNDA') THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) *  T1."NumPerMsr"
     ELSE 0  
 END AS "Cantidad Sin Entregar en Unidades"
  /*CASE
     WHEN T8."U_SYP_UPPL" IS NOT NULL THEN 'Existe'
     ELSE 'No Existe'
  END AS "Estado U_SYP_UPPL"*/
  --T8."U_SYP_UPPL",
  --T1."NumPerMsr"
     
   
FROM ORDR T0  -- ORDR (Orden de venta)
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"  -- RDR1 (Líneas de orden de venta)
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode" AND T1."LineNum" = T2."LineNum"  -- DLN1 (Líneas de entrega)
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"  -- ODLN (Encabezado de entrega)
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17'  -- ADOC (Documentos de pago)
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode"  -- OITM (Artículos)
WHERE (T1."WhsCode" IN ('10PTD', '10FPTD', '10PTI', '10EPTD', '10PTA'))
AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1')
AND T1."ItemCode" LIKE '07%' 
--AND T0."CardCode" = 'C0992233656001' --'C0990004196001' 
--AND T0."DocEntry" = '52874'
AND T0."DocNum" = '24004100' --'24004039' --'24003992' --'24004100' 
AND T0."DocDate" BETWEEN '2024-12-01' AND '2024-12-31'
 
ORDER BY 
    T0."DocNum",  
    T0."DocDate",  
    T1."ItemCode",  
    T3."DocDate";


/* asi quedaria mi vista  con los ultimos cambios */
DROP VIEW "SBO_FIGURETTI_PRO"."DPE_ESTADO_OV";

CREATE VIEW "SBO_FIGURETTI_PRO"."DPE_ESTADO_OV" ( 
 "Key Pedido",
 "Status OV",
 "Cancelado",
 "N° Pedido",
 "NumAtCard",
 "Fecha Pedido",
 "Fecha Entrega Actual",
 "FECHA Entrega INICIAL",
 "DIAS DIF",
 "CardCode",
 "CardName",
 "ItemCode",
 "Dscription",
 "Unidad de Medida",
 "Cant UoM",
 "Cantidad Pedida",
 "Cantidad Abierta Restante",
 "Enviado desde el Pedido",
 "DelivrdQty UND",
 "Cantidad Entregada",
 "Almacen",
 "QtyToShip",
 "OrderedQty",
 "Key Entrega",
 "Fecha Entrega",
 "Fecha Venc Entrega",
 "N° Entrega",
 "Cancelado Entrega",
 "Price",
 "SIS_FABRIC",
 "Tipo de error",
 "Causa de error",
 "Cantidad Sin Entregar" 
 ) AS SELECT
	 T0."DocEntry",
	 T0."DocStatus",
	 T0."CANCELED",
	 T0."DocNum",
	 T0."NumAtCard" ,
	 T0."DocDate",
	 T0."DocDueDate",
	 IFNULL(T5."DocDueDate",
	 T0."DocDueDate") AS "FECHA INICIAL",
	 DAYS_BETWEEN(IFNULL(T5."DocDueDate",T0."DocDueDate"),T3."DocDueDate") AS "DIAS DIF",
	 T0."CardCode",
	 T0."CardName",
	 T1."ItemCode",
	 T1."Dscription",
	 T1."UomCode",
	 T1."NumPerMsr",
	 T1."Quantity"*T1."NumPerMsr" AS "Cantidad Pedida",
	 T1."OpenQty"*T1."NumPerMsr" AS "Cantidad Abierta Restante",
	 ROUND(T1."DelivrdQty"),
	 IFNULL(T1."DelivrdQty"*T1."NumPerMsr",0) AS "DelivrdQty UND",
	 IFNULL(T2."Quantity"*T2."NumPerMsr",0) AS "Cantidad Entregada",
	 T1."WhsCode",
	 T2."QtyToShip",
	 T2."OrderedQty",
	 T2."DocEntry" AS "Key Entrega",
	 T3."DocDate" AS "Fecha Entrega",
	 T3."DocDueDate" AS "Fecha Venc Entrega",
	 T3."DocNum" AS "N° Entrega",
	 T3."CANCELED" AS "Cancelado Entrega",
	 T1."Price",
	 T8."U_LAB_SIS_FABRIC",
	 CASE 
	 	WHEN T0."U_ERR_ENTR" = '1' THEN 'Interno' 
	 	WHEN T0."U_ERR_ENTR" = '2' THEN 'Externo' 
		ELSE 'Sin error' 
	 END AS "Tipo de error",
	 CASE 
	 	WHEN T0."U_MOT_ERR_ENTR" = '1.1' THEN 'Faltantes Producción' 
	 	WHEN T0."U_MOT_ERR_ENTR" = '1.2' THEN 'Traslado Producción' 
	 	WHEN T0."U_MOT_ERR_ENTR" = '1.3' THEN 'Traslado Bodega' 
	 	WHEN T0."U_MOT_ERR_ENTR" = '1.4' THEN 'Mala Gestión Comercial' 
	 	WHEN T0."U_MOT_ERR_ENTR" = '1.5' THEN 'Error Inventario' 
	 	WHEN T0."U_MOT_ERR_ENTR" = '2.1' THEN 'Cliente Sin Espacio' 
	 	WHEN T0."U_MOT_ERR_ENTR" = '2.2' THEN 'Cliente No Pago' 
	 	WHEN T0."U_MOT_ERR_ENTR" = '2.3' THEN 'Transporte' 
	 	ELSE 'Sin error' 
     END AS "Causa de error",
	 --(T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar"
	 CASE 
	     WHEN (T1."UomCode" = 'PACK' AND T8."U_SYP_UPPL" IS NOT NULL) THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) *  T8."U_SYP_UPPL"
	     WHEN (T1."UomCode" = 'PACK') THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) *  T1."NumPerMsr"
	     WHEN (T1."UomCode" = 'CARTON') THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) *  T1."NumPerMsr"  
	     WHEN (T1."UomCode" = 'UN') THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) *  1          
	     WHEN (T1."UomCode" = 'FUNDA') THEN (T1."Quantity" - IFNULL(T2."Quantity", 0)) *  T1."NumPerMsr"
	     ELSE 0  
	 END AS "Cantidad Sin Entregar"
	 
	FROM ORDR T0 
	INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
	LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode" AND T1."LineNum" = T2."LineNum" 
	LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry" --AND T3."CANCELED" = 'N'
 	LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17' 
	LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode" 
	WHERE (T1."WhsCode" = '10PTD' 
		OR T1."WhsCode" = '10FPTD' 
		OR T1."WhsCode" = '10PTI' 
		OR T1."WhsCode" = '10EPTD' 
		OR T1."WhsCode" = '10PTA') 	
		AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1' ) 
		AND T1."ItemCode" LIKE '07%' 
		ORDER BY T0."DocDate",
			 T1."ItemCode",
			 T3."DocDate" ASC WITH READ ONLY


  C0990004196001 - CORPORACION EL ROSADO S.A.
  C1790016919001 - CORPORACION FAVORITA C.A.
  C0993006351001 - SUPEREASY MARKET & DELIVERY S.A.
  C0990865477001 - LIRIS S. A.









