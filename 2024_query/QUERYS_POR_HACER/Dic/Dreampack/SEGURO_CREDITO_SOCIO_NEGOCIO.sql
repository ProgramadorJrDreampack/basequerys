
SELECT 
T0."QryGroup19",
* 
FROM OCRD T0 
WHERE 
  T0."QryGroup19" = 'Y'
AND T0."CardType" = 'C'



/* REALIZANDO EL QUERY */
/*SELECT 
T0."CardCode",
T0."CardName"
FROM OCRD T0 
WHERE 
  T0."QryGroup19" = 'Y'
AND T0."CardType" = 'C'*/

SELECT 
    T0."CardCode",
    T0."CardName",
    (SELECT SUM(T1."Debit" - T1."Credit") FROM JDT1 T1 WHERE T1."ShortName" = T0."CardCode") AS "Saldo de Cuenta",
    (SELECT 
        SUM(T2."OpenQty") 
    FROM RDR1 T2 
    INNER JOIN ORDR T3 ON T2."DocEntry" = T3."DocEntry" 
    WHERE     
        T3."CardCode" = T0."CardCode" 
        AND T3."DocStatus" = 'O') AS "Saldo de Pedidos Pendientes",
    T0."CreditLine" AS "Límite de Crédito"
FROM 
    OCRD T0
WHERE 
    T0."CardType" = 'C'
    AND T0."QryGroup19" = 'Y'



    -- ***************************************
/* asi quedo en produccion Datos SN - Seguro de credito */
SELECT 
    T0."CardCode",
    T0."CardName", 
     T0."Balance",
     T0."OrdersBal",
     T0."CreditLine",
     T0."CreditLine" AS "Cupo Aprobado Asegurado",
     T0."CreditLine" - T0."Balance" AS "Utilizacion de cupo",
     T1."PymntGroup",
     --T0."GroupCode",
     T2."GroupName"
    
FROM 
    OCRD T0
INNER JOIN OCTG T1 ON T0."GroupNum" = T1."GroupNum"
LEFT JOIN OCRG T2 ON T0."GroupCode" = T2."GroupCode"
WHERE 
    T0."CardType" = 'C'
    AND T0."QryGroup19" = 'Y'
ORDER BY
   T0."CreditLine" DESC