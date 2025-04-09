SELECT
    --T0."UserSign",
    --T1."INTERNAL_K",
     
    T0."DocNum" AS "Numero de Pedido",
    T0."DocDate",
    T0."CreateDate",
    T0."DocTime" AS "Hora de Creacion",
    T1."USER_CODE",
    T1."U_NAME"
FROM 
    OPOR T0 
INNER JOIN 
    OUSR T1 ON T0."UserSign" = T1."INTERNAL_K"
WHERE
    (T0."UserSign" IN (43,147,72)
    OR T1."USER_CODE" IN ('COM01','COM04','COM03'))
    AND T0."DocDate" >= ADD_DAYS(CURRENT_DATE, -1)  -- desde ayer