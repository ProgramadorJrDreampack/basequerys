
/* aprobado por omar -- solo falta el nombre del query */
SELECT 
    --T0."DocEntry" AS "Número de Factura",
    --T0."DocDate" AS "Fecha de Factura",
   
    T2."ItemCode" AS "Numero_Articulo",
    T2."Dscription" AS "Descripcion_Articulo",
    T4."Name" as "FAMILIA", 
    T5."Name" AS "SUBFAMILIA",
    T6."UomName" AS "Codigo de Medida",
    T2."Quantity" AS "Cantidad",
    T3."U_SYP_PADRE_BOB",
    T3."U_LAB_SIS_FABRIC" AS "Tipo",
    T3."U_SYP_PESOBRUTO" AS "Peso",
    --T0."CardCode" AS "Código de Cliente",
    T1."CardName" AS "Nombre de Cliente",
    T2."ItemCode" || T1."CardName" AS "Key",
    T2."ItemCode" || T0."CardCode" AS "Key2"

FROM 
    OINV T0
INNER JOIN 
    OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN 
    INV1 T2 ON T0."DocEntry" = T2."DocEntry"
INNER JOIN 
    OITM T3 ON T2."ItemCode" = T3."ItemCode" 
INNER JOIN 
    "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3"  T4 ON T3."U_SYP_SUBGRUPO3" = T4."Code" 
INNER JOIN 
    "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4"  T5 ON T3."U_SYP_SUBGRUPO4" = T5."Code"
INNER JOIN 
     OUOM T6 ON T2."UomEntry" = T6."UomEntry"
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1]
    /*
    T0."DocDate" >= '2024-01-01' AND  T0."DocDate" <= '2024-01-02'
    YEAR(T0."DocDate") BETWEEN YEAR([%0]) AND YEAR([%1])
    */
ORDER BY 
    T0."DocDate" DESC;