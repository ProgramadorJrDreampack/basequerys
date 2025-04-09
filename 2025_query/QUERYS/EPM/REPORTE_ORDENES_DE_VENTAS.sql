/*REPLICARLOS PARA EPM  */
SELECT
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
    (T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar",

    /*CASE 
        WHEN (T1."UomCode" = 'UN') THEN (T1."Quantity" - IFNULL(T2."Quantity",0)) * T1."NumPerMsr" 
        ELSE 0 
    END AS "Cantidad Sin Entregar",*/



    T1."UomCode",
    T8."U_SYP_UPPL",
    T1."Quantity",
    T2."Quantity"
  
 
   

  
FROM ORDR T0  
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode" AND T1."LineNum" = T2."LineNum" 
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17'
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode"
WHERE
  (T1."WhsCode" = '10PTE' 
   OR T1."WhsCode" = '10FPTE'
   OR T1."WhsCode" = '10EPTE')
  AND T1."ItemCode" LIKE '07%'
LIMIT 100


/* Opcion 2 para EPM REPORTE DE ORDENES DE VENTA */

SELECT
    --T5."LogInstanc",
    --T2."BaseDocNum",T0."DocNum",
   -- T1."ItemCode",T2."ItemCode",


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
    (T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar"
    
    /*CASE 
        WHEN (T1."UomCode" = 'UN') THEN (T1."Quantity" - IFNULL(T2."Quantity",0)) * T1."NumPerMsr" 
        ELSE 0 
    END AS "Cantidad Sin Entregar",*/
  
FROM ORDR T0  
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode" AND T1."LineNum" = T2."LineNum" 
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17'
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode"
WHERE
  (T1."WhsCode" = '10PTE' 
   OR T1."WhsCode" = '10FPTE'
   OR T1."WhsCode" = '10EPTE')
  AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1' ) 
  AND T1."ItemCode" LIKE '07%'
ORDER BY 
    T0."DocDate",
    T1."ItemCode",
    T3."DocDate"

    /* EPM OPCION 3 quedo la vista */

SELECT
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
    (T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar"
    
FROM ORDR T0  
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode" AND T1."LineNum" = T2."LineNum" 
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17'
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode"
WHERE
  (T1."WhsCode" = '10PTE' 
   OR T1."WhsCode" = '10FPTE'
   OR T1."WhsCode" = '10EPTE')
  AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1' ) 
  AND T1."ItemCode" LIKE '07%'
ORDER BY 
    T0."DocDate",
    T1."ItemCode",
    T3."DocDate"


    /* asi quedo la vista  */
    SELECT * FROM "B1H_EPM_PROD"."EPM_ESTADO_OV";
    
CREATE VIEW "B1H_EPM_PROD"."EPM_ESTADO_OV" ( 
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
	 --"Tipo de error",
	 --"Causa de error",
	 "Cantidad Sin Entregar" ) AS SELECT
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
    (T1."Quantity" - T1."DelivrdQty") AS "Cantidad Sin Entregar"
    
FROM ORDR T0  
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN DLN1 T2 ON T2."BaseDocNum" = T0."DocNum" AND T1."ItemCode" = T2."ItemCode" AND T1."LineNum" = T2."LineNum" 
LEFT JOIN ODLN T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN ADOC T5 ON T0."DocNum" = T5."DocNum" AND T5."ObjType" = '17'
LEFT JOIN OITM T8 ON T1."ItemCode" = T8."ItemCode"
WHERE
  (T1."WhsCode" = '10PTE' 
   OR T1."WhsCode" = '10FPTE'
   OR T1."WhsCode" = '10EPTE')
  AND (T5."LogInstanc" IS NULL OR T5."LogInstanc" = '1' ) 
  AND T1."ItemCode" LIKE '07%'
ORDER BY 
    T0."DocDate",
    T1."ItemCode",
    T3."DocDate" ASC WITH READ ONLY
