SELECT
    --T0."UserSign",
     
    T0."DocNum" AS "Numero de Pedido",
    T0."DocDate",
    T0."CreateDate",
    T0."DocTime" AS "Hora de Creacion",
    T1."USER_CODE",
    T1."U_NAME" AS "Usuario Creador"
FROM 
    OPOR T0 
INNER JOIN 
    OUSR T1 ON T0."UserSign" = T1."INTERNAL_K"
WHERE
     --T1."USER_CODE" = 'BOD04'
     T0."DocDate" >= ADD_DAYS(CURRENT_DATE, -1)  -- desde ayer
    AND T0."DocDate" < CURRENT_DATE;   --  hoy


    --SELECT * FROM OUSR LIMIT 2;



