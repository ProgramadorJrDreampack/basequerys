SELECT T0."DocNum",
T0."DocDate",
T0."DocStatus",
T4."DocNum",
CASE WHEN T4."DocNum" IS NOT NULL THEN 'Aprobado'
ELSE 'No aprobado' END AS "Estado aprobacion",
T0."Filler", 
(SELECT A."WhsName" FROM OWHS A WHERE A."WhsCode" = T0."Filler") AS "Bodega Salida",
T0."ToWhsCode", 
(SELECT A."WhsName" FROM OWHS A WHERE A."WhsCode" = T0."ToWhsCode") AS "Bodega Entrada",
T1."ItemCode",
T1."Dscription",
T1."Quantity",
T1."Price",
T0."JrnlMemo",
T3."LineNum"
/*
T2."BatchNum" AS "Lote",
T2."InDate",
T2."Quantity" As "Cantidad Lote DISP"
*/

FROM OWTQ T0  
INNER JOIN WTQ1 T1 ON T0."DocEntry" = T1."DocEntry" 
--INNER JOIN OIBT T2 ON T1."ItemCode" = T2."ItemCode"
LEFT JOIN WTR1 T3 ON T1."TrgetEntry" = T3."DocEntry" AND T1."TargetType"= '67' AND T1."LineNum" = T3."BaseLine"
LEFT JOIN OWTR T4 ON T3."DocEntry" = T4."DocEntry"
WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."Filler" = '03RPF'
--AND T3."LineNum" = '0' OR T3."LineNum" IS NULL
--AND T2."BaseType" IN ('20', '59','10000071')
--AND T2."WhsCode" = '03RPF'
--AND T0."DocNum" IN ('24000137')
ORDER BY T0."DocDate" Desc, T0."DocNum"