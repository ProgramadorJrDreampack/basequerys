/*SELECT DISTINCT 
    C."CardCode" AS "Código de Cliente",
    C."CardName" AS "Nombre de Cliente",
    C."Currency" AS "Moneda",
    C."GroupCode" AS "Grupo de Cliente",
    C."LicTradNum" AS "Número de Registro Fiscal",
    C."Email" AS "Correo Electrónico",
    C."Phone1" AS "Teléfono"
FROM 
    OCRD C
INNER JOIN 
    ORCT P ON C."CardCode" = P."CardCode"
WHERE 
    P."CashAccount" IS NOT NULL -- Verificamos que el pago sea al contado
    AND P."DocDate" BETWEEN [%0] AND [%1] -- Opcional: filtrar por fecha
ORDER BY 
    C."CardCode";*/


-- SELECT T1."GroupNum", T1."PymntGroup" FROM "SBO_FIGURETTI_PRO"."OCTG"  T1

/* lista de clientes solo que que tiene condicion de pago 'CONTADO' */
SELECT 
    T0."CardCode" AS "Código del Cliente",
    T0."CardName" AS "Nombre del Cliente",
    T1."GroupNum" AS "Número de Grupo",
    T1."PymntGroup" AS "Condicion de Pago"
FROM 
    OCRD T0
INNER JOIN 
    OCTG T1 ON T0."GroupNum" = T1."GroupNum"
WHERE 
   T1."GroupNum" = -1 --'Contado';