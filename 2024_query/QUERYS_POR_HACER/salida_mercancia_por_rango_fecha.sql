/* original */
SELECT 
  T0."CANCELED", 
  T0."DocNum", 
  T0."DocDate", 
  T1."ItemCode", 
  T1."Dscription",
  T3."Name" AS "Tipo Producto",
  T1."Quantity", 
  T1."UomCode",
  T1."WhsCode", 
  T4."AvgPrice" As "Costo", 
  T1."Price", 
  T1."U_beas_basetype",
  T1."U_beas_belnrid", 
  T1."U_beas_belposid", 
  T1."U_beas_posid",
  T0."U_SYP_TMOVING",
  T0."Comments",
  T2."ItmsGrpCod", 
  T1."AcctCode"
FROM OIGE T0  
INNER JOIN IGE1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode" 
INNER JOIN "@SYP_SUBGRUPO2" T3 ON T2."U_SYP_SUBGRUPO2"=T3."Code"
INNER JOIN OITW T4 ON T1."ItemCode" = T4."ItemCode" AND T1."WhsCode" = T4."WhsCode"
WHERE T0."DocDate" >=[%0] AND  T0."DocDate" <=[%1] 
--AND (T2."U_SYP_SUBGRUPO2"='BC' OR T2."U_SYP_SUBGRUPO2"='CV' OR T2."U_SYP_SUBGRUPO2"='RB' OR T2."U_SYP_SUBGRUPO2"='RC' OR T2."U_SYP_SUBGRUPO2"='PE' OR T2."U_SYP_SUBGRUPO2"='PC')

/* opcion 1 */

--entrada de mercancia 
SELECT 
  T0."CANCELED", 
  T0."DocNum", 
  T0."DocDate", 
  T1."ItemCode", 
  T1."Dscription",
  T3."Name" AS "Tipo Producto",
  T1."Quantity", 
  T1."UomCode",
  T1."WhsCode", 
  T4."AvgPrice" AS "Costo", 
  T1."Price", 
  T1."U_beas_basetype",
  T1."U_beas_belnrid", 
  T1."U_beas_belposid", 
  T1."U_beas_posid",
  T0."U_SYP_TMOVING",
  T0."Comments",
  T2."ItmsGrpCod", 
  T1."AcctCode"
FROM OIGN T0  
INNER JOIN IGN1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode" 
INNER JOIN "@SYP_SUBGRUPO2" T3 ON T2."U_SYP_SUBGRUPO2" = T3."Code"
INNER JOIN OITW T4 ON T1."ItemCode" = T4."ItemCode" AND T1."WhsCode" = T4."WhsCode"
WHERE T0."DocDate" >= [%0] AND T0."DocDate" <= [%1]

/* union de salida y entradas de mercancias */
--Logística - Salida de Mercancía por Rango de Fecha

SELECT 
  'Salida' AS "Tipo Movimiento",
  T0."CANCELED", 
  T0."DocNum", 
  T0."DocDate", 
  T1."ItemCode", 
  T1."Dscription",
  T3."Name" AS "Tipo Producto",
  T1."Quantity", 
  T1."UomCode",
  T1."WhsCode", 
  T4."AvgPrice" AS "Costo", 
  T1."Price", 
  T1."U_beas_basetype",
  T1."U_beas_belnrid", 
  T1."U_beas_belposid", 
  T1."U_beas_posid",
  T0."U_SYP_TMOVING",
  T0."Comments",
  T2."ItmsGrpCod", 
  T1."AcctCode"
 
FROM OIGE T0  
INNER JOIN IGE1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode" 
INNER JOIN "@SYP_SUBGRUPO2" T3 ON T2."U_SYP_SUBGRUPO2" = T3."Code"
INNER JOIN OITW T4 ON T1."ItemCode" = T4."ItemCode" AND T1."WhsCode" = T4."WhsCode"
WHERE T0."DocDate" >= [%0] AND  T0."DocDate" <= [%1]

UNION ALL

SELECT
  'Entrada' AS "Tipo Movimiento", 
  T0."CANCELED", 
  T0."DocNum", 
  T0."DocDate", 
  T1."ItemCode", 
  T1."Dscription",
  T3."Name" AS "Tipo Producto",
  T1."Quantity", 
  T1."UomCode",
  T1."WhsCode", 
  T4."AvgPrice" AS "Costo", 
  T1."Price", 
  T1."U_beas_basetype",
  T1."U_beas_belnrid", 
  T1."U_beas_belposid", 
  T1."U_beas_posid",
  T0."U_SYP_TMOVING",
  T0."Comments",
  T2."ItmsGrpCod", 
  T1."AcctCode"
  
FROM OIGN T0  
INNER JOIN IGN1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode" 
INNER JOIN "@SYP_SUBGRUPO2" T3 ON T2."U_SYP_SUBGRUPO2" = T3."Code"
INNER JOIN OITW T4 ON T1."ItemCode" = T4."ItemCode" AND T1."WhsCode" = T4."WhsCode"
WHERE T0."DocDate" >= [%0] AND  T0."DocDate" <= [%1]