
SELECT
    CASE 
        WHEN T0."RefObjType" = 22 THEN 'Pedido'
        ELSE ''
    END AS "ObjctType",
    *  
FROM VPM9 T0 
WHERE T0."RefObjType" = 22  ----$[VPM9."RefObjType".0]
LIMIT 10



SELECT 
    T0."DocEntry",
    T0."DocNum" AS "NumPedido",
    T0."CardCode" AS "CodigoSocioNegocio",
    T0."CardName" AS "NombreSocioNegocio",
    T0."DocDate" AS "FechaPedido",
    T0."DocTotal" AS "TotalPedido"
    
FROM OPOR T0
WHERE T0."DocStatus" = 'O' -- Solo pedidos abiertos
AND T0."CardCode" = 'P0992726512001'  --$[OVPM."CardCode".0]
ORDER BY T0."DocDate" DESC;
-- *************************************************************************

if  $[VPM9."RefObjType"]='22'  then
        SELECT 
            T0."DocNum" AS "NumPedido"  
        FROM OPOR T0
        WHERE T0."DocStatus" = 'O' -- Solo pedidos abiertos
        AND T0."CardCode" = $[OVPM."CardCode".0] --'P0992726512001'
        ORDER BY T0."DocDate" DESC;
        
end if;


if  $[VPM9."RefObjType"]=22  then
        SELECT 
            T0."DocNum" AS "NumPedido"  
        FROM OPOR T0
        WHERE T0."DocStatus" = 'O' 
        AND T0."CardCode" = $[OVPM."CardCode"] 
        ORDER BY T0."DocDate" DESC;
       
end if;

BF Pedido abiertos del SN
SELECT 
    /*T0."DocNum" AS "NumPago",
    T0."CardCode" AS "CodigoProveedor",
    T0."CardName" AS "NombreProveedor",*/
    T2."DocNum" AS "NumPedido",
    T2."DocDate" AS "FechaPedido"
FROM OVPM T0
INNER JOIN VPM2 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN OPCH T3 ON T1."DocNum" = T3."DocEntry" -- Relacion con facturas
LEFT JOIN POR1 T4 ON T3."DocEntry" = T4."BaseEntry" -- Relacion con pedidos
LEFT JOIN OPOR T2 ON T4."DocEntry" = T2."DocEntry" AND T2."DocStatus" = 'O' -- Pedidos abiertos
WHERE T0."CardCode" = $[OVPM."CardCode"] --'P0990129363001'
ORDER BY T2."DocDate" DESC;