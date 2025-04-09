SELECT 
  T0."ItemCode", 
  T0."ItemName",
  T0."DfltWH",
  T0."OnHand"
FROM OITM T0 
WHERE 
   (T0."ItemCode" LIKE '04%' OR T0."ItemCode" LIKE '07%')
ORDER BY T0."ItemCode";