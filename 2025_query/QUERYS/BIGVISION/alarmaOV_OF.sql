Orden de venta con fabricacion

revisar en la orden de venta todos los item 09 y que tenga en la orden de fabricacion 


SELECT T0."DocNum", T0."DocStatus", T1."ItemCode", T0."DocType" 
FROM ORDR T0  
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
WHERE T1."DocDate" BETWEEN [%0] AND [%1]