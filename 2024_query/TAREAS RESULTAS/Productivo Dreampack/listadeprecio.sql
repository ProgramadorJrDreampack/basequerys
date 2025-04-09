/* 
Actualizado  PRODUCTIVO -> VENTAS -> LISTA DE PRECIO
 */

SELECT 
T0."ItemCode", T0."ItemName", 
T4."Name" AS "SG3", 
T5."Name" AS "SG4", 
T2."ListName", 
T1."Price", 
T3."UomName" AS "Unidad de Determinacion de Precio", 
T0."SalUnitMsr", 
T0."NumInSale" AS "Articulo por Unidad de Venta"
FROM OITM T0  
INNER JOIN ITM1 T1 ON T0."ItemCode" = T1."ItemCode" 
INNER JOIN OPLN T2 ON T1."PriceList" = T2."ListNum" 
INNER JOIN OUOM T3 ON T0."PriceUnit" = T3."UomEntry"
INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T4 ON T0."U_SYP_SUBGRUPO3" = T4."Code"
INNER JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T5 ON T0."U_SYP_SUBGRUPO4" = T5."Code"
WHERE T0."validFor" = 'Y' AND T0."ItemCode" LIKE '07%' 
ORDER BY T2."ListName", T0."ItemCode"