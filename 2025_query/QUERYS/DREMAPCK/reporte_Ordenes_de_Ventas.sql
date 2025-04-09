SELECT * FROM "SBO_FIGURETTI_PRO"."DPE_ESTADO_OV" WHERE "Fecha Pedido" >= '2023-01-01'

/* esta es la vista */
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
    T0."NumAtCard",
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
    END AS "Causa de error",
	 --(T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar"
    CASE 
        WHEN (T1."UomCode" = 'PACK' AND T8."U_SYP_UPPL" IS NOT NULL) THEN (T1."Quantity" - IFNULL(T2."Quantity",0)) * T8."U_SYP_UPPL" 
        WHEN (T1."UomCode" = 'PACK') THEN (T1."Quantity" - IFNULL(T2."Quantity",0)) * T1."NumPerMsr" 
        WHEN (T1."UomCode" = 'CARTON') THEN (T1."Quantity" - IFNULL(T2."Quantity",0)) * T1."NumPerMsr" 
        WHEN (T1."UomCode" = 'UN') THEN (T1."Quantity" - IFNULL(T2."Quantity",0)) * T1."NumPerMsr" 
        WHEN (T1."UomCode" = 'FUNDA') THEN (T1."Quantity" - IFNULL(T2."Quantity",0)) * T1."NumPerMsr" 
        ELSE 0 
    END AS "Cantidad Sin Entregar" 
FROM ORDR T0 
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode" AND T1."LineNum" = T2."LineNum" 
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry" --AND T3."CANCELED" = 'N'
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17' 
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode" 
WHERE 
    (T1."WhsCode" = '10PTD' 
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




