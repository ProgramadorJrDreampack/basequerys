


SELECT 
  T0."ItemCode",
  CASE
    WHEN T0."U_SYP_TIPEXIST" = '01' THEN 'Materiales o Servicios Comprados'
    WHEN T0."U_SYP_TIPEXIST" = '02' THEN 'Producto en Proceso'
    WHEN T0."U_SYP_TIPEXIST" = '03' THEN 'Producto Terminado'
    WHEN T0."U_SYP_TIPEXIST" = '99' THEN 'Otros (Especificar)'
    ELSE ''
  END AS "Tipo existencia",
  --T0."U_SYP_GRUPO",
  T1."Name" AS "Grupo Base",
  --T0."U_SYP_SUBGRUPO1",
  T2."Name" AS "Sub Grupo 1",
  T3."Name" AS "Sub Grupo 2",
  T4."Name" AS "Sub Grupo 3",
  T5."Name" AS "Sub Grupo 4"
   
FROM OITM T0
LEFT JOIN "@SYP_GRUPO" T1 ON T0."U_SYP_GRUPO" = T1."Code"
LEFT JOIN "@SYP_SUBGRUPO1" T2 ON T0."U_SYP_SUBGRUPO1" = T2."Code"
LEFT JOIN "@SYP_SUBGRUPO2" T3 ON T0."U_SYP_SUBGRUPO2" = T3."Code"
LEFT JOIN "@SYP_SUBGRUPO3" T4 ON T0."U_SYP_SUBGRUPO3" = T4."Code"
LEFT JOIN "@SYP_SUBGRUPO4" T5 ON T0."U_SYP_SUBGRUPO4" = T5."Code"
--WHERE T0."ItemCode" = '02DLM00000001' --'02DCE00000005' --'02BTB00000006'
ORDER BY T0."ItemCode";

--LIMIT 10