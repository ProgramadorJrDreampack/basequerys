/* Ordenes de mantenimiento en productivo dreampack */
SELECT
   T0."BELNR_ID" AS "N° Orden",
   T2."ANFZEIT" AS "Fecha inicio",
   TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio", 
   T2."ENDZEIT" AS "Fecha fin",
   TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Hora de finalizacion",
   T2."DisplayName" AS "Tecnico MTTO",
   T1."AG_ID" AS "Recurs",
   CASE WHEN LENGTH(T1."AG_ID") = 6 THEN RIGHT(T1."AG_ID", 4) ELSE T1."AG_ID" END AS "Recurso",
   (T0."WORKTIME" / 60) AS "Duracion Del MTTO",
   T3."ART1_ID" AS "Num de articulo",
   T3."ItemName" AS "Descripcion del articulo",
   T3."MENGE_LAGER" AS "Cantidad consumida",
   T3."MATERIALKOSTEN" AS "Precio unitario",
   (T3."MATERIALKOSTEN" * T3."MENGE_LAGER") AS "Precio Total",
   T4."ItemName" AS "MTTO",
   T0."TYP" AS "Tipo MTTO",

    NULL AS "Solicitud de compra",
    NULL AS "Proveedor",
    NULL AS "Orden de compra",
    NULL AS "Descripcion servicio externo",
    NULL AS "Costo servicio externo",
    NULL AS "Iva",
    NULL AS "Costo total servicio externo", 

   T1."BEZ" AS "Comentario en la orden",
   T2."GRUND" AS "Comentario del tecnico"

FROM BEAS_FTHAUPT T0  --Órdenes de trabajo
LEFT JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Enrutamiento de producción
LEFT JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"  --Recibo del tiempo de producción
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID" --Orden de trabajo Lista de materiales Artículo
LEFT JOIN BEAS_FTPOS T4 ON T0."BELNR_ID" = T4."BELNR_ID" --Orden de trabajo Posición

WHERE
    T0."TYP" != 'Produccion' 
    AND T0."BELNR_ID" >= '15711'
    AND T1."ABGKZ" = 'J'
    --AND T0."BELNR_ID" = '30095'
   
UNION ALL

SELECT 
    A1."U_beas_belnrid" AS "N° Orden", 
    NULL AS "Fecha inicio", 
    NULL AS "Hora de inicio", 
    NULL AS "Fecha fin", 
    NULL AS "Hora de finalizacion", 
    NULL AS "Tecnico MTTO",
    NULL AS "Recurs", 
    NULL AS "Recurso", 
    NULL AS "Duracion Del MTTO", 
    NULL AS "Num de articulo", 
    NULL AS "Descripcion del articulo", 
    NULL AS "Cantidad consumida", 
    NULL AS "Precio unitario", 
    NULL AS "Precio Total", 
    NULL AS "MTTO", 
    NULL AS "Tipo MTTO",
    A0."DocNum" AS "Solicitud de compra",
    A2."CardName" AS "Proveedor",
    A4."DocNum" AS "Orden de compra",
    A3."Dscription" AS "Descripcion servicio externo",
    A3."Price" AS "Costo servicio externo",
    A3."VatSumSy" AS "Iva",
    (A3."Price" + A3."VatSumSy") AS "Costo total servicio externo",

   NULL AS "Comentario en la orden",
   NULL AS "Comentario del tecnico"

FROM OPRQ A0  
LEFT JOIN PRQ1 A1 ON A0."DocEntry" = A1."DocEntry"
LEFT JOIN OCRD A2 ON A1."LineVendor" = A2."CardCode"
LEFT JOIN POR1 A3 ON A1."TrgetEntry" = A3."DocEntry" AND A1."LineNum" = A3."BaseLine"
LEFT JOIN OPOR A4 ON A3."DocEntry" = A4."DocEntry" 
--WHERE A1."U_beas_belnrid" = '30095'
   --AND A0."DocNum" = '24000770'



/* ordens de matenimiento EPM */
SELECT
   T0."BELNR_ID" AS "N° Orden",
   T2."ANFZEIT" AS "Fecha inicio",
   TO_NVARCHAR(TO_TIME(T2."ANFZEIT"), 'HH24:MI:SS') AS "Hora de inicio", 
   T2."ENDZEIT" AS "Fecha fin",
   TO_NVARCHAR(TO_TIME(T2."ENDZEIT"), 'HH24:MI:SS') AS "Hora de finalizacion",
   T2."DisplayName" AS "Tecnico MTTO",
   T1."AG_ID" AS "Recurs",
   CASE WHEN LENGTH(T1."AG_ID") = 6 THEN RIGHT(T1."AG_ID", 4) ELSE T1."AG_ID" END AS "Recurso",
   (T0."WORKTIME" / 60) AS "Duracion Del MTTO",
   T3."ART1_ID" AS "Num de articulo",
   T3."ItemName" AS "Descripcion del articulo",
   T3."MENGE_LAGER" AS "Cantidad consumida",
   T3."MATERIALKOSTEN" AS "Precio unitario",
   (T3."MATERIALKOSTEN" * T3."MENGE_LAGER") AS "Precio Total",
   T4."ItemName" AS "MTTO",
   T0."TYP" AS "Tipo MTTO",

    NULL AS "Solicitud de compra",
    NULL AS "Proveedor",
    NULL AS "Orden de compra",
    NULL AS "Descripcion servicio externo",
    NULL AS "Costo servicio externo",
    NULL AS "Iva",
    NULL AS "Costo total servicio externo", 

   T1."BEZ" AS "Comentario en la orden",
   T2."GRUND" AS "Comentario del tecnico"

FROM BEAS_FTHAUPT T0  --Órdenes de trabajo
LEFT JOIN BEAS_FTAPL T1 ON T0."BELNR_ID" = T1."BELNR_ID"  --Enrutamiento de producción
LEFT JOIN BEAS_ARBZEIT T2 ON T0."BELNR_ID" = T2."BELNR_ID"  --Recibo del tiempo de producción
LEFT JOIN BEAS_FTSTL T3 ON T0."BELNR_ID" = T3."BELNR_ID" --Orden de trabajo Lista de materiales Artículo
LEFT JOIN BEAS_FTPOS T4 ON T0."BELNR_ID" = T4."BELNR_ID" --Orden de trabajo Posición

WHERE
    T0."TYP" != 'Produccion' 
    AND T1."ABGKZ" = 'J'
   
UNION ALL

SELECT 
    A1."U_beas_belnrid" AS "N° Orden", 
    NULL AS "Fecha inicio", 
    NULL AS "Hora de inicio", 
    NULL AS "Fecha fin", 
    NULL AS "Hora de finalizacion", 
    NULL AS "Tecnico MTTO",
    NULL AS "Recurs", 
    NULL AS "Recurso", 
    NULL AS "Duracion Del MTTO", 
    NULL AS "Num de articulo", 
    NULL AS "Descripcion del articulo", 
    NULL AS "Cantidad consumida", 
    NULL AS "Precio unitario", 
    NULL AS "Precio Total", 
    NULL AS "MTTO", 
    NULL AS "Tipo MTTO",
    A0."DocNum" AS "Solicitud de compra",
    A2."CardName" AS "Proveedor",
    A4."DocNum" AS "Orden de compra",
    A3."Dscription" AS "Descripcion servicio externo",
    A3."Price" AS "Costo servicio externo",
    A3."VatSumSy" AS "Iva",
    (A3."Price" + A3."VatSumSy") AS "Costo total servicio externo",

   NULL AS "Comentario en la orden",
   NULL AS "Comentario del tecnico"

FROM OPRQ A0  
LEFT JOIN PRQ1 A1 ON A0."DocEntry" = A1."DocEntry"
LEFT JOIN OCRD A2 ON A1."LineVendor" = A2."CardCode"
LEFT JOIN POR1 A3 ON A1."TrgetEntry" = A3."DocEntry" AND A1."LineNum" = A3."BaseLine"
LEFT JOIN OPOR A4 ON A3."DocEntry" = A4."DocEntry" 
--WHERE A1."U_beas_belnrid" = '30095'
   --AND A0."DocNum" = '24000770'
