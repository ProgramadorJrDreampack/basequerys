SELECT 
T0."DocNum",
T0."TaxDate",
T0."Filler" AS "Almacen Origen",
T0."ToWhsCode" AS "Almacen Destino" 
FROM OWTQ T0 
WHERE T0."DocStatus" = 'O';