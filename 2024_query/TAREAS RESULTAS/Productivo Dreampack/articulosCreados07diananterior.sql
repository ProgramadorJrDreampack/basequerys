/* TERMINADO CONSULTA 
 PRODUCTIVO - MODULO-> INVENTARIO -> DATOS DE MAESTRO DE ARTICULOS
  DATOS DE VENTAS - NOMBRE DE UNIDAD DE VENTA 
  OITM -> SalUnitMsr
 */

SELECT
    T0."ItemCode",
    T0."ItemName",
    T1."Name" AS "Familia",
    T2."Name" As "SubFamilia",
    T3."UgpName",
    T0."PriceUnit",
    T0."SalUnitMsr",
    T0."CntUnitMsr",
    T0."NumInCnt",
    T4."UomCode",
    T4."UomName",
    T0."CreateDate"
FROM OITM T0
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
INNER JOIN OUGP T3 ON T0."UgpEntry" = T3."UgpEntry"
INNER JOIN OUOM T4 ON T0."PriceUnit" = T4."UomEntry"
WHERE 
    T0."ItemType" = 'I'
    AND T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -1) 
   AND (T0."ItemCode" LIKE '07%' 
   OR T0."ItemCode" LIKE '04%')


  

    PARA DESBLOQUEAR UN USUARIO EN GESTION -> DEFINICION -> GENERAL -> USUARIO -> "AÑADIR CODIGO"

04DBL07280091

/* ACTUALIZADO EL ARCTICULO CREADOS 07 DIA ANTERIOR */
SELECT
    T0."ItemCode",
    SUBSTR(T0."ItemCode", 6) AS "Estructura",
    T0."ItemName",
    T1."Name" AS "Familia",
    T2."Name" As "SubFamilia",
    T3."UgpName",
    T0."PriceUnit",
    T0."SalUnitMsr",
    T0."CntUnitMsr",
    T0."NumInCnt",
    T4."UomCode",
    T4."UomName",
    T0."CreateDate"
FROM OITM T0
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
INNER JOIN OUGP T3 ON T0."UgpEntry" = T3."UgpEntry"
INNER JOIN OUOM T4 ON T0."PriceUnit" = T4."UomEntry"
WHERE 
    T0."ItemType" = 'I'
    AND T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -1) 
   AND (T0."ItemCode" LIKE '07%' 
   OR T0."ItemCode" LIKE '04%')
ORDER BY "Estructura" ASC;

/* ADD LISTA DE PRECIO   AUN FALTA POR VALIDAR 08-10-2024 Produccion */

SELECT
    T0."ItemCode",
    SUBSTR(T0."ItemCode", 6) AS "Estructura",
    T0."ItemName",
    T1."Name" AS "Familia",
    T2."Name" AS "SubFamilia",
    T3."UgpName",
    T0."PriceUnit",
    T0."SalUnitMsr",
    T0."CntUnitMsr",
    T0."NumInCnt",
    T4."UomCode",
    T4."UomName",
    T0."CreateDate",

    T6."ListName",
    T6."ListNum",
    T6."BASE_NUM"
    
FROM OITM T0
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
INNER JOIN OUGP T3 ON T0."UgpEntry" = T3."UgpEntry"
INNER JOIN OUOM T4 ON T0."PriceUnit" = T4."UomEntry" 
LEFT JOIN ITM1 T5 ON T0."ItemCode" = T5."ItemCode"
LEFT JOIN OPLN T6 ON T5."PriceList" = T6."ListNum" 
WHERE 
    T0."ItemType" = 'I'  
    AND T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -1) 
    AND (T0."ItemCode" LIKE '07%' OR T0."ItemCode" LIKE '04%')
ORDER BY "Estructura" ASC;

**********************

/*SELECT T0.*  FROM "SBO_FIGURETTI_PRO"."OITM"  T0 INNER JOIN ITM1 T1 ON T0."ItemCode" = T1."ItemCode"  --AND T0."PriceUnit" = T1."PriceList"
--INNER JOIN OPLN t2 ON  T1."PriceList" = T2."ListNum"  
WHERE t0."ItemCode" = '07DTA07290081'*/
SELECT * FROM ITM1 T0 WHERE T0."ItemCode" = '07DTA07290081'



******************************************************************


SELECT
    T0."ItemCode",
    SUBSTR(T0."ItemCode", 6) AS "Estructura",
    T0."ItemName",
    T1."Name" AS "Familia",
    T2."Name" AS "SubFamilia",
    T3."UgpName",
    T0."PriceUnit",
    T0."SalUnitMsr",
    T0."CntUnitMsr",
    T0."NumInCnt",
    T4."UomCode",
    T4."UomName",
    T0."CreateDate",
    T6."BasePLNum",
    -- Subconsulta para obtener el nombre de la lista de precios basado en BasePLNum
    (SELECT T5."ListName" 
     FROM OPLN T5 
     WHERE T5."ListNum" = T6."BasePLNum") AS "NombreListaDePrecios"
FROM OITM T0
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
INNER JOIN OUGP T3 ON T0."UgpEntry" = T3."UgpEntry"
INNER JOIN OUOM T4 ON T0."PriceUnit" = T4."UomEntry"
LEFT JOIN ITM1 T6 ON T0."ItemCode" = T6."ItemCode"
WHERE 
    T0."ItemType" = 'I'
    AND T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -1) 
    AND (T0."ItemCode" LIKE '07%' 
    OR T0."ItemCode" LIKE '04%')
ORDER BY "Estructura" ASC;



*************************************************

SELECT
    T0."ItemCode",
    SUBSTR(T0."ItemCode", 6) AS "Estructura",
    T0."ItemName",
    T1."Name" AS "Familia",
    T2."Name" AS "SubFamilia",
    T3."UgpName",
    T0."PriceUnit",
    T0."SalUnitMsr",
    T0."CntUnitMsr",
    T0."NumInCnt",
    T4."UomCode",
    T4."UomName",
    T0."CreateDate",
    -- Selección de la lista de precios principal utilizando ROW_NUMBER
    T7."ListName" AS "NombreListaDePrecios"
FROM OITM T0
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
INNER JOIN OUGP T3 ON T0."UgpEntry" = T3."UgpEntry"
INNER JOIN OUOM T4 ON T0."PriceUnit" = T4."UomEntry"
LEFT JOIN (
    -- Subconsulta para obtener solo una fila por cada artículo
    SELECT 
        T6."ItemCode",
        T5."ListName",
        ROW_NUMBER() OVER (PARTITION BY T6."ItemCode" ORDER BY T5."ListNum") AS "RowNum"
    FROM ITM1 T6
    LEFT JOIN OPLN T5 ON T6."BasePLNum" = T5."ListNum"
) T7 ON T0."ItemCode" = T7."ItemCode" AND T7."RowNum" = 1
WHERE 
    T0."ItemType" = 'I'
    AND T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -1) 
    AND (T0."ItemCode" LIKE '07%' 
    OR T0."ItemCode" LIKE '04%')
ORDER BY "Estructura" ASC;

*****************************************************************************************

SELECT
    T0."ItemCode",
    SUBSTR(T0."ItemCode", 6) AS "Estructura",
    T0."ItemName",
    T1."Name" AS "Familia",
    T2."Name" AS "SubFamilia",
    T3."UgpName",
    T0."PriceUnit",
    T0."SalUnitMsr",
    T0."CntUnitMsr",
    T0."NumInCnt",
    T4."UomCode",
    T4."UomName",
    T0."CreateDate",
    -- Mostrar el nombre de la lista de precios de la subconsulta
    T7."ListName" AS "NombreListaDePrecios",
    T7."BasePLNum"
FROM OITM T0
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
INNER JOIN OUGP T3 ON T0."UgpEntry" = T3."UgpEntry"
INNER JOIN OUOM T4 ON T0."PriceUnit" = T4."UomEntry"
-- Subconsulta que selecciona la lista de precios principal
LEFT JOIN (
    SELECT 
        T6."ItemCode",
        T5."ListName",
        T6."BasePLNum"
    FROM ITM1 T6
    INNER JOIN OPLN T5 ON T6."BasePLNum" = T5."ListNum"
    -- Aquí se puede agregar un criterio para elegir la lista principal, si hay más de una
    WHERE T6."BasePLNum" IS NOT NULL
    GROUP BY T6."ItemCode", T6."BasePLNum", T5."ListName"
) T7 ON T0."ItemCode" = T7."ItemCode"
WHERE 
    T0."ItemType" = 'I'
    AND T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -1)
    AND (T0."ItemCode" LIKE '07%' 
    OR T0."ItemCode" LIKE '04%')
ORDER BY "Estructura" ASC;




SELECT
    T0."ItemCode",
    SUBSTR(T0."ItemCode", 6) AS "Estructura",
    T0."ItemName",
    T1."Name" AS "Familia",
    T2."Name" AS "SubFamilia",
    T3."UgpName",
    T0."PriceUnit",
    T0."SalUnitMsr",
    T0."CntUnitMsr",
    T0."NumInCnt",
    T4."UomCode",
    T4."UomName",
    T0."CreateDate",
    -- Mostrar el nombre de la lista de precios de la subconsulta
    T7."ListName" AS "NombreListaDePrecios",
    T7."BasePLNum"
FROM OITM T0
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
INNER JOIN OUGP T3 ON T0."UgpEntry" = T3."UgpEntry"
INNER JOIN OUOM T4 ON T0."PriceUnit" = T4."UomEntry"
-- Subconsulta que selecciona la lista de precios principal
LEFT JOIN (
    SELECT 
        T6."ItemCode",
        T5."ListName",
        T6."BasePLNum"
    FROM ITM1 T6
    INNER JOIN OPLN T5 ON T6."BasePLNum" = T5."ListNum"
    --WHERE T6."BasePLNum" IS NOT NULL 
    GROUP BY T6."ItemCode", T6."BasePLNum", T5."ListName"

) T7 ON T0."ItemCode" = T7."ItemCode"
WHERE 
    T0."ItemType" = 'I'
    AND T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -1)
    AND (T0."ItemCode" LIKE '07%' 
    OR T0."ItemCode" LIKE '04%')
ORDER BY "Estructura" ASC;


04DBI07370037
07DEC07370037

/* Este medio salio */

SELECT
    T0."ItemCode",
    SUBSTR(T0."ItemCode", 6) AS "Estructura",
    T0."ItemName",
    T1."Name" AS "Familia",
    T2."Name" AS "SubFamilia",
    T3."UgpName",
    T0."PriceUnit",
    T0."SalUnitMsr",
    T0."CntUnitMsr",
    T0."NumInCnt",
    T4."UomCode",
    T4."UomName",
    T0."CreateDate",
    (SELECT MIN(T6."ListName") 
     FROM ITM1 T5
     LEFT JOIN OPLN T6 ON T5."PriceList" = T6."ListNum"
     WHERE T5."ItemCode" = T0."ItemCode" AND T5."PriceList" = 65) AS "Nombre Lista De Precios" 
FROM OITM T0
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
INNER JOIN OUGP T3 ON T0."UgpEntry" = T3."UgpEntry"
INNER JOIN OUOM T4 ON T0."PriceUnit" = T4."UomEntry"
WHERE 
    T0."ItemType" = 'I'
    AND T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -1) 
    AND (T0."ItemCode" LIKE '07%' OR T0."ItemCode" LIKE '04%')
ORDER BY "Estructura" ASC;

***********************************************


SELECT 
    T0."ItemCode",
    SUBSTR(T0."ItemCode", 6) AS "Estructura",
    T0."ItemName",
    T1."Name" AS "Familia",
    T2."Name" AS "SubFamilia",
    T3."UgpName",
    T0."PriceUnit",
    T0."SalUnitMsr",
    T0."CntUnitMsr",
    T0."NumInCnt",
    T4."UomCode",
    T4."UomName",
    T0."CreateDate",
    (SELECT 
         MIN("ListName")
         FROM ITM1 T5
         INNER JOIN OPLN T6 ON T5."PriceList" = T6."ListNum"
         WHERE T5."ItemCode" = T0."ItemCode"
         ) AS "Nombre Lista De Precios"
FROM OITM T0
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
INNER JOIN OUGP T3 ON T0."UgpEntry" = T3."UgpEntry"
INNER JOIN OUOM T4 ON T0."PriceUnit" = T4."UomEntry"
WHERE 
    T0."ItemType" = 'I'
    AND T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -1) 
    AND (T0."ItemCode" LIKE '07%' OR T0."ItemCode" LIKE '04%')
    /* AND EXISTS (
        SELECT 1
        FROM ITM1 T5
        WHERE T5."ItemCode" = T0."ItemCode"
        AND T5."PriceList" IN (SELECT "ListNum" FROM OPLN)
    ) */
ORDER BY "Estructura" ASC;




*****************************

SELECT 
    T0."ItemCode",
    SUBSTR(T0."ItemCode", 6) AS "Estructura",
    T0."ItemName",
    T1."Name" AS "Familia",
    T2."Name" AS "SubFamilia",
    T3."UgpName",
    T0."PriceUnit",
    T0."SalUnitMsr",
    T0."CntUnitMsr",
    T0."NumInCnt",
    T4."UomCode",
    T4."UomName",
    T0."CreateDate",
    T5."ListName" AS "Nombre Lista De Precios"
FROM OITM T0
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
INNER JOIN OUGP T3 ON T0."UgpEntry" = T3."UgpEntry"
INNER JOIN OUOM T4 ON T0."PriceUnit" = T4."UomEntry"
LEFT JOIN (
    SELECT DISTINCT T5."ItemCode", T6."ListName"
    FROM ITM1 T5
    INNER JOIN OPLN T6 ON T5."PriceList" = T6."ListNum"
) T5 ON T0."ItemCode" = T5."ItemCode"
WHERE 
    T0."ItemType" = 'I'
    AND T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -1) 
    AND (T0."ItemCode" LIKE '07%' OR T0."ItemCode" LIKE '04%')
    AND T5."ItemCode" IS NOT NULL
ORDER BY "Estructura" ASC;


___________________________________________________


/* CON ESTE SALIO */

SELECT
    T0."ItemCode",
    SUBSTR(T0."ItemCode", 6) AS "Estructura",
    T0."ItemName",
    T1."Name" AS "Familia",
    T2."Name" AS "SubFamilia",
    T3."UgpName",
    T0."PriceUnit",
    T0."SalUnitMsr",
    T0."CntUnitMsr",
    T0."NumInCnt",
    T4."UomCode",
    T4."UomName",
    T0."CreateDate",
    (SELECT MIN(T6."ListName") 
     FROM ITM1 T5
     LEFT JOIN OPLN T6 ON T5."PriceList" = T6."ListNum"
     WHERE T5."ItemCode" = T0."ItemCode" OR T5."PriceList" = T6."ListNum") AS "Nombre Lista De Precios" 
FROM OITM T0
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
INNER JOIN OUGP T3 ON T0."UgpEntry" = T3."UgpEntry"
INNER JOIN OUOM T4 ON T0."PriceUnit" = T4."UomEntry"
WHERE 
    T0."ItemType" = 'I'
    AND T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -1) 
    AND (T0."ItemCode" LIKE '07%' OR T0."ItemCode" LIKE '04%')
ORDER BY "Estructura" ASC;


*********************************************

SELECT
    T0."ItemCode",
    SUBSTR(T0."ItemCode", 6) AS "Estructura",
    T0."ItemName",
    T6."ListName" AS "Nombre Lista De Precios"
FROM 
    OITM T0
LEFT JOIN 
    ITM1 T5 ON T0."ItemCode" = T5."ItemCode"
LEFT JOIN 
    OPLN T6 ON T5."PriceList" = T6."ListNum"
WHERE 
    T0."ItemType" = 'I'
    AND T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -1) 
    AND (T0."ItemCode" LIKE '07%' OR T0."ItemCode" LIKE '04%')
ORDER BY 
    "Estructura" ASC;



    *******************

SELECT
    T0."ItemCode",
    SUBSTR(T0."ItemCode", 6) AS "Estructura",
    T0."ItemName",
   T5."Price",
    T6.*
FROM 
    OITM T0
INNER JOIN 
    ITM1 T5 ON T0."ItemCode" = T5."ItemCode"
INNER JOIN 
    OPLN T6 ON T5."PriceList" = T6."ListNum"
WHERE 
    T0."ItemCode" = '07DTF07820005'
    AND T5."Price" > 0
    --AND T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -1) 
    --AND (T0."ItemCode" LIKE '07%' OR T0."ItemCode" LIKE '04%')
ORDER BY 
    "Estructura" ASC;


    /* QUEDARIA ASI  */

SELECT
    T0."ItemCode",
    SUBSTR(T0."ItemCode", 6) AS "Estructura",
    T0."ItemName",
    T1."Name" AS "Familia",
    T2."Name" AS "SubFamilia",
    T3."UgpName",
    T0."PriceUnit",
    T0."SalUnitMsr",
    T0."CntUnitMsr",
    T0."NumInCnt",
    T4."UomCode",
    T4."UomName",
    T0."CreateDate",
    T5."Price"
FROM OITM T0
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
INNER JOIN OUGP T3 ON T0."UgpEntry" = T3."UgpEntry"
INNER JOIN OUOM T4 ON T0."PriceUnit" = T4."UomEntry"
LEFT JOIN ITM1 T5 ON T0."ItemCode" = T5."ItemCode"
LEFT JOIN OPLN T6 ON T5."PriceList" = T6."ListNum"
WHERE 
    --T0."ItemType" = 'I'
    --AND T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -1) 
    --AND (T0."ItemCode" LIKE '07%' OR T0."ItemCode" LIKE '04%')
   (T5."Price" > 0)
ORDER BY "Estructura" ASC;



/* HAY CONFLITO SE VAN HACER 2 QUERY MEJOR  */

SELECT
    T0."ItemCode",
 T5."Price",
    SUBSTR(T0."ItemCode", 6) AS "Estructura",
    T0."ItemName",
    T1."Name" AS "Familia",
    T2."Name" AS "SubFamilia",
    T3."UgpName",
    T0."PriceUnit",
    T0."SalUnitMsr",
    T0."CntUnitMsr",
    T0."NumInCnt",
    T4."UomCode",
    T4."UomName",
    T0."CreateDate"
   
FROM OITM T0
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO3" T1 ON T0."U_SYP_SUBGRUPO3" = T1."Code"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO4" T2 ON T0."U_SYP_SUBGRUPO4" = T2."Code"
INNER JOIN OUGP T3 ON T0."UgpEntry" = T3."UgpEntry"
INNER JOIN OUOM T4 ON T0."PriceUnit" = T4."UomEntry"
INNER JOIN ITM1 T5 ON T0."ItemCode" = T5."ItemCode"
INNER JOIN OPLN T6 ON T5."PriceList" = T6."ListNum"
WHERE 
    --T0."ItemType" = 'I'
--(T5."Price" >= 0)    AND 
T0."CreateDate" = ADD_DAYS(CURRENT_DATE, -2) 
    AND (T0."ItemCode" LIKE '07%' OR T0."ItemCode" LIKE '04%')
   
ORDER BY "Estructura" ASC;
