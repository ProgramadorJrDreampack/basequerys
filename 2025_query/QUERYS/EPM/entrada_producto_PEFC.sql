SELECT 
    T0."CANCELED", 
    T0."DocNum", 
    T0."DocDate", 
    T0."DocTime", 
    T1."ItemCode", 
    T1."Dscription", 
    T3."Name" AS "Tipo Producto", 
    T1."Quantity", 
    T1."unitMsr", 
    T1."Price", 
    T1."LineTotal", 
    T1."WhsCode", 
    T1."U_beas_basetype", 
    T1."U_beas_belnrid", 
    T1."U_beas_belposid", 
    T1."U_beas_posid",
    T0."U_SYP_TMOVING", 
    T0."Comments"
FROM OIGN T0  
INNER JOIN IGN1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode" 
INNER JOIN "@SYP_SUBGRUPO4" T3 ON T2."U_SYP_SUBGRUPO4"=T3."Code"
WHERE T0."DocDate" BETWEEN [%0] AND [%1] AND T2."QryGroup14"='Y'

UNION ALL

SELECT 
    T0."CANCELED", 
    T0."DocNum", 
    T0."DocDate", 
    T0."DocTime", 
    T1."ItemCode", 
    T1."Dscription", 
    T3."Name" AS "Tipo Producto", 
    T1."Quantity", 
    T1."unitMsr", 
    T1."Price", 
    T1."LineTotal", 
    T1."WhsCode", 
    T1."U_beas_basetype", 
    T1."U_beas_belnrid", 
    T1."U_beas_belposid", 
    T1."U_beas_posid", 
    T0."U_SYP_TMOVING", 
    T0."Comments"
FROM OPDN T0  
INNER JOIN PDN1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode" 
INNER JOIN "@SYP_SUBGRUPO4" T3 ON T2."U_SYP_SUBGRUPO4"=T3."Code"
WHERE T0."DocDate" BETWEEN [%0] AND [%1] AND T2."QryGroup14"='Y'