/* Productivo Solicitud de compra de mantenimiento */
SELECT
T0."DocNum" AS "Solicitud",
T1."DocDate" AS "Fecha SC",
T0."DocTime" AS "Hora SC",
T4."Name",
T3."DocNum" AS "DocNum Pedido",
CASE
WHEN T0."U_SYP_TIPCOMPRA" = '01' THEN 'NACIONAL'
WHEN T0."U_SYP_TIPCOMPRA" = '02' THEN 'IMPORTADO'
ELSE T0."U_SYP_TIPCOMPRA" END AS "TIPO DE COMPRA",
T1."ItemCode",
T1."Dscription",
--T1."LineNum",
T1."Quantity",
T1."Price",
T0."DocTotal",
T6."DocNum" AS "DocNum EM",
T6."DocDate" AS "Fecha EntradaM",
T5."Quantity",
T5."Price"


FROM OPRQ T0
INNER JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN POR1 T2 ON T1."TrgetEntry" = T2."DocEntry" AND T1."LineNum" = T2."BaseLine"
LEFT JOIN OPOR T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN OUDP T4 ON T0."Department" = T4."Code"
LEFT JOIN PDN1 T5 ON T3."DocEntry" = T5."BaseEntry" AND T2."LineNum" = T5."BaseLine" ANd T5."BaseType" = '22'
LEFT JOIN OPDN T6 ON T5."DocEntry" = T6."DocEntry"

WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T4."Name" = 'Mantenimiento'
--AND T0."U_SYP_TIPCOMPRA" = '01' AND T0."CANCELED" = 'N' --AND T0."DocNum" IN ('23001060')
--AND T4."CANCELED" = 'N'
ORDER BY T0."DocDate" ASC

/* EPM - Solicitud de compra de matenimiento  */

/* opcion 1 trabajado*/

SELECT 
    /*T1."TrgetEntry",
    T2."DocEntry",

    T1."LineNum",
    T2."BaseLine",*/
  
    T0."DocNum" AS"Solicitud",
    T1."DocDate" AS "Fecha SC",
    T0."DocTime" AS "Hora SC",
    T4."Name",
    T3."DocNum" AS "DocNum Pedido",
    CASE
        WHEN T0."U_SYP_TIPCOMPRA" = '01' THEN 'NACIONAL'
        WHEN T0."U_SYP_TIPCOMPRA" = '02' THEN 'IMPORTADO'
        ELSE T0."U_SYP_TIPCOMPRA" 
    END AS "TIPO DE COMPRA",
    T1."ItemCode",
    T1."Dscription",
    T0."DocTotal",
    T5."Currency",
    T6."DocCur",
    T6.* 

FROM OPRQ T0
LEFT JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN POR1 T2 ON  T1."TrgetEntry" = T2."DocEntry" AND T1."LineNum" = T2."BaseLine"

LEFT JOIN OPOR T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN OUDP T4 ON T0."Department" = T4."Code"
LEFT JOIN PCH1 T5 ON  T1."TrgetEntry" = T5."DocEntry" AND T1."LineNum" = T5."BaseLine"
LEFT JOIN OPCH T6 ON T2."DocEntry" = T6."DocEntry"

WHERE
    T4."Name" = 'Mantenimiento'  
ORDER BY 
    T0."DocDate"
LIMIT 100;



/* ******* OPCION 2 */
SELECT 
    /*T1."TrgetEntry",
    T2."DocEntry",

    T1."LineNum",
    T2."BaseLine",*/
  
    T0."DocNum" AS"Solicitud",
    T1."DocDate" AS "Fecha SC",
    T0."DocTime" AS "Hora SC",
    T4."Name",
    T3."DocNum" AS "DocNum Pedido",
    CASE
        WHEN T0."U_SYP_TIPCOMPRA" = '01' THEN 'NACIONAL'
        WHEN T0."U_SYP_TIPCOMPRA" = '02' THEN 'IMPORTADO'
        ELSE T0."U_SYP_TIPCOMPRA" 
    END AS "TIPO DE COMPRA",
    T1."ItemCode",
    T1."Dscription",
    T0."DocTotal",
    T5."Currency",
    T6."DocCur",
    T6.* 

FROM OPRQ T0
LEFT JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN POR1 T2 ON  T1."TrgetEntry" = T2."DocEntry" AND T1."LineNum" = T2."BaseLine"

LEFT JOIN OPOR T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN OUDP T4 ON T0."Department" = T4."Code"
LEFT JOIN PCH1 T5 ON  T1."TrgetEntry" = T5."DocEntry" AND T1."LineNum" = T5."BaseLine"
LEFT JOIN OPCH T6 ON T2."DocEntry" = T6."DocEntry"

WHERE
    T0."DocDate" BETWEEN [%0] AND [%1] AND
    T4."Name" = 'Mantenimiento'  
ORDER BY 
    T0."DocDate"
LIMIT 100;




/* 
 --,
    -T8."DocNum" AS "Numero de Documento Entrada Mercancia",
    --T8."DocDate" AS "Fecha Entrada Mercancia",
    --T7."ItemCode",
    
    --T8.* 
 */


 SELECT 
    T0."DocNum" AS "Numero de Documento SC",
    T1."DocDate" AS "Fecha SC",
    T0."DocTime" AS "Hora SC",
    T4."Name",
    T3."DocNum" AS "Numero de Documento Pedido",
    CASE
        WHEN T0."U_SYP_TIPCOMPRA" = '01' THEN 'NACIONAL'
        WHEN T0."U_SYP_TIPCOMPRA" = '02' THEN 'IMPORTADO'
        ELSE T0."U_SYP_TIPCOMPRA" 
    END AS "TIPO DE COMPRA",
    T1."ItemCode" AS "Articulo del Pedido",
    T1."Dscription" AS "Descripcion del Pedido",
    T6."DocCur",
    T1."Quantity" AS "Cantidad del Pedido",
    T2."Price",
    T3."DocTotalFC"

FROM OPRQ T0  --Solicitud de compra
LEFT JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"  --Solicitud de compra - Filas
LEFT JOIN POR1 T2 ON  T1."TrgetEntry" = T2."DocEntry" AND T1."LineNum" = T2."BaseLine"  --Pedido: Lineas 

LEFT JOIN OPOR T3 ON T2."DocEntry" = T3."DocEntry"  --Pedido
LEFT JOIN OUDP T4 ON T0."Department" = T4."Code"  --Departamento
LEFT JOIN PCH1 T5 ON  T1."TrgetEntry" = T5."DocEntry" AND T1."LineNum" = T5."BaseLine" --Factura de acreedor: Líneas
LEFT JOIN OPCH T6 ON T2."DocEntry" = T6."DocEntry"  --Factura de proveedores

--LEFT JOIN PDN1 T7 ON T1."TrgetEntry" = T7."DocEntry" AND T1."LineNum" = T7."BaseLine" --AND T7."BaseType" = '22'
--LEFT JOIN OPDN T8 ON T2."DocEntry" = T7."DocEntry"

WHERE
    T4."Name" = 'Mantenimiento'  
ORDER BY 
    T0."DocDate"
LIMIT 100;



/* SOLICITUD DE COMPRA EPM  asi quedo 23-12-2024*/
SELECT 
    T0."DocNum" AS "Numero de Documento SC",
    T1."DocDate" AS "Fecha SC",
    T0."DocTime" AS "Hora SC",
    T4."Name",
    T3."DocNum" AS "Numero de Documento Pedido",
    CASE
        WHEN T0."U_SYP_TIPCOMPRA" = '01' THEN 'NACIONAL'
        WHEN T0."U_SYP_TIPCOMPRA" = '02' THEN 'IMPORTADO'
        ELSE T0."U_SYP_TIPCOMPRA" 
    END AS "TIPO DE COMPRA",
    T1."ItemCode" AS "Articulo del Pedido",
    T1."Dscription" AS "Descripcion del Pedido",
    T6."DocCur",
    T1."Quantity" AS "Cantidad del Pedido",
    T2."Price",
    T3."DocTotalFC"

FROM OPRQ T0  --Solicitud de compra
LEFT JOIN PRQ1 T1 ON T0."DocEntry" = T1."DocEntry"  --Solicitud de compra - Filas
LEFT JOIN POR1 T2 ON  T1."TrgetEntry" = T2."DocEntry" AND T1."LineNum" = T2."BaseLine"  --Pedido: Lineas 

LEFT JOIN OPOR T3 ON T2."DocEntry" = T3."DocEntry"  --Pedido
LEFT JOIN OUDP T4 ON T0."Department" = T4."Code"  --Departamento
LEFT JOIN PCH1 T5 ON  T1."TrgetEntry" = T5."DocEntry" AND T1."LineNum" = T5."BaseLine" --Factura de acreedor: Líneas
LEFT JOIN OPCH T6 ON T2."DocEntry" = T6."DocEntry"  --Factura de proveedores


WHERE
    T0."DocDate" BETWEEN [%0] AND [%1] AND
    T4."Name" = 'Mantenimiento'  
ORDER BY 
    T0."DocDate"
LIMIT 100;