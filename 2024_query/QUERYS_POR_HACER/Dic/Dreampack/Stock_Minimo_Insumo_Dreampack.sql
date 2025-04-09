/* query manager 03.Compras-> Stock Minimo Insumo Dreampack */
/* query original- Problematica de que sale inactivo un producto */
Select OI."ItemCode", OI."ItemName",
       WS."WhsCode" AS "Bodega", 
       --WS."OnHand", WS."IsCommited", WS."OnOrder",
       (WS."OnHand" - WS."IsCommited" + WS."OnOrder") AS "Disponible",
       WS."MinStock"
  FROM "OITM" OI, "OITW" WS
 WHERE OI."ItemCode" = WS."ItemCode"
    AND OI."validFor" = 'Y'  -- Filtrar solo artículos activos  (actualice)
    AND OI."ItmsGrpCod" = 120
AND WS."MinStock" >= (Select (WSD."OnHand" - WSD."IsCommited" + WSD."OnOrder") AS "Disponible"
                           From "OITW" WSD 
                          Where WSD."ItemCode" = OI."ItemCode"
                            And WSD."WhsCode" = WS."WhsCode")
GROUP BY OI."ItemCode", OI."ItemName", WS."WhsCode", WS."OnHand", WS."IsCommited",  WS."OnOrder", WS."MinStock"
HAVING WS."MinStock" != 0


