/* Query original */
SELECT
    LEFT(T0."ItemCode", 2) AS "TIPO",
    T0."ItemCode",
    CASE
        WHEN LEFT(T0."ItemCode", 2) = '01' THEN 'Materia Prima' 
        ELSE 'Insumo'
    END AS "Tipo de Producto",
    T0."ItemName" AS "Nombre",
    T0."ItemName" AS "Descripcion",
    T0."U_SYP_GRAMAJE",
    T0."U_SYP_ANCHO",
    T0."BWidth1",
    T0."U_SYP_CALIBRE",
    CASE 
        WHEN T0."InvntryUom" = 'KG' THEN 'kg'
        WHEN T0."InvntryUom" = 'UN' THEN 'Unidades'
        WHEN T0."InvntryUom" = 'MTS' THEN 'metros'
        WHEN T0."InvntryUom" = 'LB' THEN 'libras'
        WHEN T0."InvntryUom" = 'LTRS' THEN 'Litros'
        WHEN T0."InvntryUom" = 'GL' THEN 'galones'
        ELSE T0."InvntryUom"
    END AS "Unidad de Medida1",
    CASE 
        WHEN T0."InvntryUom" = 'KG' THEN 'kg'
        WHEN T0."InvntryUom" = 'UN' THEN 'Unidades'
        WHEN T0."InvntryUom" = 'MTS' THEN 'metros'
        WHEN T0."InvntryUom" = 'LB' THEN 'libras'
        WHEN T0."InvntryUom" = 'LTRS' THEN 'Litros'
        WHEN T0."InvntryUom" = 'GL' THEN 'galones'
        ELSE T0."InvntryUom"
    END AS "Unidad de Medida2",
    T1."AvgPrice",
    T1."OnHand",
    T1."AvgPrice",
    T0."OnHand" As "Stock General",
    --T1."IsCommited" AS "Comprometido",
    --T1."OnOrder",
    --(T1."OnHand" - T1."IsCommited" + T1."OnOrder") AS "Disponible",
    --T0."LstEvlPric", 
    --T0."LastPurPrc",
    T1."WhsCode"
FROM OITM T0
INNER JOIN OITW T1 ON T0."ItemCode" = T1."ItemCode" AND T0."DfltWH" = T1."WhsCode"
--AND T1."OnHand" > 0 
AND (T1."WhsCode" LIKE '01%'  OR T1."WhsCode" LIKE '02%' OR T1."WhsCode" LIKE '04%' OR T1."WhsCode" LIKE '10%')

WHERE 
--T0."ItemCode" LIKE '01%' OR T0."ItemCode" LIKE '02%' OR T0."ItemName" LIKE 'PLANA%' AND 
"frozenFor" = 'N' AND (T0."ItemCode" LIKE '01%' OR T0."ItemCode" LIKE '02%')
--GROUP BY T0."ItemCode", T0."ItemName",  T0."InvntryUom", T0."OnHand", T0."LastPurPrc", T0."LstEvlPric", T0."BWidth1", T0."U_SYP_GRAMAJE", T0."U_SYP_CALIBRE", T0."U_SYP_ANCHO"



/* codigo resuelto */

SELECT
    T0."frozenFor",
    LEFT(T0."ItemCode", 2) AS "TIPO",
    T0."ItemCode",
    CASE
        WHEN LEFT(T0."ItemCode", 2) = '01' THEN 'Materia Prima' 
        ELSE 'Insumo'
    END AS "Tipo de Producto",
    T0."ItemName" AS "Nombre",
    T0."ItemName" AS "Descripcion",
    T0."U_SYP_GRAMAJE",
    T0."U_SYP_ANCHO",
    T0."BWidth1",
    T0."U_SYP_CALIBRE",
    CASE 
        WHEN T0."InvntryUom" = 'KG' THEN 'kg'
        WHEN T0."InvntryUom" = 'UN' THEN 'Unidades'
        WHEN T0."InvntryUom" = 'MTS' THEN 'metros'
        WHEN T0."InvntryUom" = 'LB' THEN 'libras'
        WHEN T0."InvntryUom" = 'LTRS' THEN 'Litros'
        WHEN T0."InvntryUom" = 'GL' THEN 'galones'
        ELSE T0."InvntryUom"
    END AS "Unidad de Medida1",
    CASE 
        WHEN T0."InvntryUom" = 'KG' THEN 'kg'
        WHEN T0."InvntryUom" = 'UN' THEN 'Unidades'
        WHEN T0."InvntryUom" = 'MTS' THEN 'metros'
        WHEN T0."InvntryUom" = 'LB' THEN 'libras'
        WHEN T0."InvntryUom" = 'LTRS' THEN 'Litros'
        WHEN T0."InvntryUom" = 'GL' THEN 'galones'
        ELSE T0."InvntryUom"
    END AS "Unidad de Medida2",
    T1."AvgPrice",
    T1."OnHand",
    T1."AvgPrice",
     T1."OnHand",
    --SUM(T1."OnHand") As "Stock por Almacen",  -- Suma el stock por almacén
    T1."WhsCode"

FROM OITM T0
LEFT JOIN OITW T1 ON T0."ItemCode" = T1."ItemCode"
--AND (T1."WhsCode" LIKE '01%' OR T1."WhsCode" LIKE '02%' OR T1."WhsCode" LIKE '04%' OR T1."WhsCode" LIKE '10%') 
WHERE  
  (T1."OnHand" > 0)
 AND (T0."ItemCode" LIKE '01%' OR T0."ItemCode" LIKE '02%') 
 --AND (T1."WhsCode" LIKE '01%'  OR T1."WhsCode" LIKE '02%' OR T1."WhsCode" LIKE '04%' OR T1."WhsCode" LIKE '10%')
 AND T0."ItemCode" = '01DBN00010016'
/*GROUP BY 
T0."frozenFor", LEFT(T0."ItemCode", 2), T0."ItemCode", T0."ItemName", T0."U_SYP_GRAMAJE", T0."U_SYP_ANCHO", T0."BWidth1", T0."U_SYP_CALIBRE", T0."InvntryUom", T1."AvgPrice", T1."WhsCode", T1."OnHand"*/
ORDER BY T0."ItemCode", T1."WhsCode";