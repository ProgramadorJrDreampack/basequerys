-- SELECT T0."ItemCode", T0."ItemName", T0."PriceUnit",T0."ExitPrice",T0."AvgPrice",T0."LstEvlPric", * FROM OITM T0 WHERE T0."ItemCode" = '99ARI03000007'


SELECT T0."ItemCode", T0."ItemName", T0."LastPurPrc" FROM OITM T0 WHERE T0."ItemCode" = '00FDM00000002' --'99ARI03000007'  00FDM00000002


-- SELECT TOP 1 T1.PriceAfVAT AS UltimoPrecioCompra
-- FROM POR1 T1
-- INNER JOIN OPOR T0 ON T0.DocEntry = T1.DocEntry
-- WHERE T1.ItemCode = '99ARI03000007' 
-- ORDER BY T0.DocDate DESC;


En la solicitud de compras quiere el stock que esta prederterminado del articulo siempre y cuando este en almacen predeterminado
-- Stock Actual Del Almacen

SELECT T0."ItemCode", T0."ItemName", T0."LastPurPrc", T1."WhsCode", T1."OnHand"  
FROM OITM T0
INNER JOIN OITW T1 ON T0."ItemCode" = T1."ItemCode" AND T0."DfltWH" = T1."WhsCode" 
WHERE T0."ItemCode" = '02DAD00000026' --'02DCE00000012' --'02DBR00000005'




