/* TIPOS DE GASTOS */

Item Variable  normal
$[$Item.Variable.Tipo_de_dato] -- para base
$[$Item.Column.Tipo_de_dato]  --para detalle


-- numero de documento $[$13_U_E.24.0] --perfecto

-- NUMERO DE FACTURA $[$0_U_G.C_0_4.0] en el detalle

-- SALDO $[$0_U_G.C_0_6.0]

--ABONO $[$0_U_G.C_0_5.0]


-- SELECT $[$0_U_G.C_0_6.0] FROM DUMMY;

SELECT *  FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS";

SELECT $[$0_U_G.C_0_4.0] - $[$0_U_G.C_0_5.0] AS "Saldo" FROM  "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS";



/* BUSQUEDA FORMATEADA  TOTAL ANTES DESCUENTO*/
 
SELECT 
    
    SUM(T4."Quantity" * T4."Price") AS "Total Antes de Descuento"
FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PDN1 T2 ON  T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'  -- 22 = Tipo base para Órdenes de Compra
LEFT JOIN OPDN T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN PCH1 T4 ON T3."DocEntry" = T4."BaseEntry" AND T1."LineNum" = T4."BaseLine" AND T4."BaseType" = '20'  -- 20 = Tipo base para Entrada de Mercancía
LEFT JOIN OPCH T5 ON T4."DocEntry" = T5."DocEntry" 
WHERE  T0."DocNum" = $[$13_U_E.24.0] --'24000028'


/* BF SALDO PENDIENTE */
SELECT 
     SUM(T5."DocTotal" - T5."PaidToDate") AS "Saldo Pendiente"
FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PDN1 T2 ON  T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'  -- 22 = Tipo base para Órdenes de Compra
LEFT JOIN OPDN T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN PCH1 T4 ON T3."DocEntry" = T4."BaseEntry" AND T1."LineNum" = T4."BaseLine" AND T4."BaseType" = '20'  -- 20 = Tipo base para Entrada de Mercancía
LEFT JOIN OPCH T5 ON T4."DocEntry" = T5."DocEntry" 
WHERE  T0."DocNum" = $[$13_U_E.24.0] --'24000028'




/* Traer el total antes de descuento */
/* ASI QUEDO EL ORIGINAL PARA TRAER EL VALOR DE LA FACTURA */

SELECT 
    --T0."DocStatus",
    T0."DocNum",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T5."DocEntry" AS "Numero Interno de la Factura",
    T5."DocNum" AS "Numero de Documento de la factura",
    SUM(T4."Quantity" * T4."Price") AS "Total Antes de Descuento",
    SUM(T0."DocTotal" - T0."PaidToDate") AS "Saldo Pendiente"
    --T5."BaseAmnt" 
   
    --T2."DocNum" AS "Número Factura",
    --T2."DocDate" AS "Fecha Factura",
    --SUM(T3."Quantity" * T3."Price") AS "Total Antes de Descuento"
FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PDN1 T2 ON  T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'  -- 22 = Tipo base para Órdenes de Compra
LEFT JOIN OPDN T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN PCH1 T4 ON T3."DocEntry" = T4."BaseEntry" AND T1."LineNum" = T4."BaseLine" AND T4."BaseType" = '20'  -- 20 = Tipo base para Entrada de Mercancía
LEFT JOIN OPCH T5 ON T4."DocEntry" = T5."DocEntry" 
WHERE 
    T0."DocDate" >= '2024-01-01'
    AND T0."DocNum" = '24000028'
GROUP BY 
T0."DocNum",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T5."DocEntry",
   T5."DocNum"
ORDER BY T0."DocDate";


/* BF PESO CALCULADO */
SELECT $[$23.10.NUMBER] * T0."U_SYP_PESOBRUTO"
FROM OITM T0
WHERE T0."ItemCode" = $[$23.1.0]



-- Saldo pendiente
SELECT 
    T0."DocEntry",
    T0."DocNum" AS "Número Factura",
    T0."DocDate" AS "Fecha Factura",
    T0."DocTotal" AS "Total Factura",
    T0."PaidToDate" AS "Pagado hasta la fecha",
    (T0."DocTotal" - T0."PaidToDate") AS "Saldo Pendiente"
FROM 
    OPCH T0
WHERE 
    T0."DocStatus" = 'O'  -- O = Open, indica que la factura no está pagada del todo
   --AND 
--T0."DocNum" = '24000080'
LIMIT 2




SELECT 
      T0."DocEntry",
       T5."DocEntry",
     SUM(T5."DocTotal" - T5."PaidToDate") AS "Saldo Pendiente"
FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PDN1 T2 ON  T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'  -- 22 = Tipo base para Órdenes de Compra
LEFT JOIN OPDN T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN PCH1 T4 ON T3."DocEntry" = T4."BaseEntry" AND T1."LineNum" = T4."BaseLine" AND T4."BaseType" = '20'  -- 20 = Tipo base para Entrada de Mercancía
LEFT JOIN OPCH T5 ON T4."DocEntry" = T5."DocEntry" 
WHERE  T0."DocNum" = '24000028' --$[$13_U_E.24.0] --'24000028'
GROUP BY T0."DocEntry",
       T5."DocEntry";



       



    -- *************************************************************

    SELECT 
    SUM(T4."Quantity" * T4."Price") AS "Total Antes de Descuento"
FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PDN1 T2 ON  T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'  -- 22 = Tipo base para Órdenes de Compra
LEFT JOIN OPDN T3 ON T2."DocEntry" = T3."DocEntry"
LEFT JOIN PCH1 T4 ON T3."DocEntry" = T4."BaseEntry" AND T1."LineNum" = T4."BaseLine" AND T4."BaseType" = '20'  -- 20 = Tipo base para Entrada de Mercancía
LEFT JOIN OPCH T5 ON T4."DocEntry" = T5."DocEntry" 
WHERE  T0."DocNum" = '24000001' --$[$13_U_E.24.0] --'24000028'


-- ***********************************************************************************************************************************************************
    --    PEDIDO CON TIPO DE COMPRA IMPORTADA
-- ***********************************************************************************************************************************************************


SELECT 
    T0."DocEntry",
    T0."DocNum",
 
    T2."DocEntry",
   
    T3."BaseAmnt",
    CASE 
        WHEN T3."DocStatus" = 'O' THEN 'Abierto'
        WHEN T3."DocStatus" = 'C' THEN 'Cerrado'
        ELSE ''
    END AS "Estado"--,

    --T2."LineTotal",
    --T2."OpenSum"
    --T2."OpenSumSys",
    --T3.* 
FROM "SBO_TEST_FIGURETTI_20250217"."OPOR"  T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PCH1 T2 ON T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'  -- 22 = Tipo base para Órdenes de Compra
LEFT JOIN OPCH T3 ON T2."DocEntry" = T3."DocEntry"

WHERE 
    T0."DocNum" =  '24000055' 
    AND T3."CANCELED" = 'N'
    AND T3."DocStatus" IN ('C','O');


/* TIP GASTO _ TOTAL ANTES DESCUENTO  (VALOR DE LA FACTURA) */

    SELECT 
    --T0."DocEntry",
    T3."BaseAmnt" 
FROM "SBO_TEST_FIGURETTI_20250217"."OPOR"  T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PCH1 T2 ON T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'  -- 22 = Tipo base para Órdenes de Compra
LEFT JOIN OPCH T3 ON T2."DocEntry" = T3."DocEntry"
WHERE 
    T0."DocNum" =  '24000055' 
    AND T3."CANCELED" = 'N'
    AND T3."DocStatus" IN ('C','O')
GROUP BY T3."BaseAmnt";

SELECT 
    --T0."DocEntry",
    T3."BaseAmnt" 
FROM "SBO_TEST_FIGURETTI_20250217"."OPOR"  T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PCH1 T2 ON T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'  -- 22 = Tipo base para Órdenes de Compra
LEFT JOIN OPCH T3 ON T2."DocEntry" = T3."DocEntry"
WHERE 
    T0."DocNum" =  '24000055' 
    AND T3."CANCELED" = 'N'
    AND T3."DocStatus" IN ('C','O')
GROUP BY T3."BaseAmnt";

/* TIP GASTO _ NUMERO DE FACTURA */

 SELECT 
    T3."DocEntry" 
FROM "SBO_TEST_FIGURETTI_20250217"."OPOR"  T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PCH1 T2 ON T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'  -- 22 = Tipo base para Órdenes de Compra
LEFT JOIN OPCH T3 ON T2."DocEntry" = T3."DocEntry"
WHERE 
    T0."DocNum" = $[$13_U_E.24.0] --'24000055' 
    AND T3."CANCELED" = 'N'
    AND T3."DocStatus" IN ('C','O')
GROUP BY T3."DocEntry"; 

/* BF VALOR DE LA FACTURA  */

/* TIP GASTO _ SALDO */
SELECT
    --T3."DocEntry",
    (T3."DocTotal" - T3."PaidToDate") AS "Saldo Pendiente"
FROM "SBO_TEST_FIGURETTI_20250217"."OPOR" T0
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PCH1 T2 ON T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine" AND T2."BaseType" = '22' -- 22 = Tipo base para Órdenes de Compra
LEFT JOIN OPCH T3 ON T2."DocEntry" = T3."DocEntry"
WHERE
T0."DocNum" = $[$13_U_E.24.0] --'24001526' 
AND T3."CANCELED" = 'N'
AND T3."DocStatus" IN ('C','O')
GROUP BY T3."DocTotal", T3."PaidToDate";

/* bf status Pagos */
-- Item Variable  normal
-- $[$Item.Column.Tipo_de_dato]  --para detalle
-- SELECT $[$0_U_G.C_0_6.0] AS "Saldo" FROM  "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS";


SELECT
     CASE 
       WHEN SUM(T3."DocTotal" - T3."PaidToDate") > 0 THEN  'PENDIENTE'
       WHEN SUM(T3."DocTotal" - T3."PaidToDate") = 0 THEN  'PAGADO'
       ELSE 'NA'
     END AS "Estado"
FROM "SBO_TEST_FIGURETTI_20250217"."OPOR" T0
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN PCH1 T2 ON T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine" AND T2."BaseType" = '22' -- 22 = Tipo base para Órdenes de Compra
LEFT JOIN OPCH T3 ON T2."DocEntry" = T3."DocEntry"
WHERE
T0."DocNum" = '24001526' --$[$13_U_E.24.0] --'24000055'
AND T3."CANCELED" = 'N'
AND T3."DocStatus" IN ('C','O')



/* BF NUMERO DE TRANSPORTE */
SELECT 
    T0."U_SYP_TRANSPREF"
FROM OPOR T0 
WHERE T0."DocNum" = $[$13_U_E.24.0]
LIMIT 1

/* BF Total dias de vencimiento */
SELECT 
    T0."ExtraDays"
FROM OPOR T0 
WHERE T0."DocNum" = $[$13_U_E.24.0]
LIMIT 1


/* BF ABONO CALCULAR*/

SELECT ($[$0_U_G.C_0_4.0] - COALESCE($[$0_U_G.C_0_5.0]), 0) AS "NewSaldo" FROM  "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS" LIMIT 1;

/* Fecha Maxima de pago y semanas */

SELECT 
    T0."U_SYP_MDFE",
    T2."ExtraDays",
   
   CASE 
        WHEN T2."GroupNum" = -1 THEN T0."U_SYP_MDFE"
        WHEN T2."ExtraDays" IS NOT NULL THEN ADD_DAYS(T0."U_SYP_MDFE", T2."ExtraDays") 
        ELSE T0."U_SYP_MDFE" 
    END AS "FechaMaximaPago",
    T2."ExtraDays" / 7 AS "Semanas", -- Número de semanas
    CASE 
    WHEN T2."ExtraDays" / 7 - FLOOR(T2."ExtraDays" / 7) < 0.5 THEN FLOOR(T2."ExtraDays" / 7)
    ELSE CEIL(T2."ExtraDays" / 7)
END AS "SemanasRedondeadas",


    T1."CardCode",
    T1."GroupNum",
    T2."PymntGroup"
FROM OPOR T0 
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
WHERE T0."DocNum" = '24000859' --$[$13_U_E.24.0]
LIMIT 1


-- ******************************Sacar los dias de las lista de pedidos de solo tipo de compra "Importada"******************************************
SELECT
    --T0."U_SYP_TIPCOMPRA", 
    --T0."CANCELED",
    --,
    T0."DocNum",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    CASE 
      WHEN T0."DocStatus" = 'O' THEN 'Abierto'
       WHEN T0."DocStatus" = 'C' THEN 'Cerrado'
      ELSE ''
    END AS "Estado",
    T2."GroupNum",
    T2."PymntGroup",
    T2."ExtraDays"
    

    --T1."ItemCode",
    --T1."Dscription",
    --T1."Quantity",
    --T1."OpenCreQty"
FROM 
    OPOR T0 
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
--INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
WHERE 
     --T0."DocStatus" = 'O' AND
    T0."U_SYP_TIPCOMPRA" = 02 AND  --02 Importada 
    T0."DocDate" >= '2024-01-01'
ORDER BY T0."DocDate";
-- ************************************************************************


-- *************************************************************************************************
-- LISTA DE PEDIDOS ABIERTO Y CERRADOS CON SUS FACTURAS

SELECT 
    T0."DocNum",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    CASE 
      WHEN T0."DocStatus" = 'O' THEN 'Abierto'
       WHEN T0."DocStatus" = 'C' THEN 'Cerrado'
      ELSE ''
    END AS "Estado",
    --T0."U_SYP_TRANSPREF",
    T0."U_SYP_CARPIMP",
    T0."U_SYP_MDFE",
     CASE 
        WHEN T2."GroupNum" = -1 THEN T0."U_SYP_MDFE"
        WHEN T2."ExtraDays" IS NOT NULL THEN ADD_DAYS(T0."U_SYP_MDFE", T2."ExtraDays") 
        ELSE T0."U_SYP_MDFE" 
    END AS "FechaMaximaPago",
    T1."GroupNum",
    T2."PymntGroup",
     T0."ExtraDays",
    T2."ExtraDays" / 7 AS "Semanas", -- Número de semanas
    CASE 
         WHEN T2."ExtraDays" / 7 - FLOOR(T2."ExtraDays" / 7) < 0.5 THEN FLOOR(T2."ExtraDays" / 7)
         ELSE CEIL(T2."ExtraDays" / 7)
    END AS "SemanasRedondeadas",
    A3."DocNum" AS "Num Doc Factura"
    
FROM OPOR T0
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
INNER JOIN POR1 A1 ON T0."DocEntry" = A1."DocEntry"
LEFT JOIN PCH1 A2 ON A1."DocEntry" = A2."BaseEntry" AND A1."LineNum" = A2."BaseLine" AND A2."BaseType" = '22'  -- 22 = Tipo base para Órdenes de Compra
LEFT JOIN OPCH A3 ON A2."DocEntry" = A3."DocEntry"

WHERE 
     --T0."DocStatus" = 'O' AND
    T0."U_SYP_TIPCOMPRA" = 02 AND  --02 Importada 
    T0."DocDate" >= '2024-01-01'
    AND A3."CANCELED" = 'N' AND A3."DocStatus" IN ('C','O')
   --AND T0."DocNum" = '24000055'
GROUP BY 
   T0."DocNum",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T0."DocStatus",
    T0."U_SYP_CARPIMP",
    T0."U_SYP_MDFE",
    T2."GroupNum",
    T1."GroupNum",
    T2."PymntGroup",
    T0."ExtraDays",
    T2."ExtraDays",
    A3."DocNum"
ORDER BY T0."DocDate";
-- *************************************************************************************************


-- VALIDAR QUE NO SE REPITA EL TIPO DE GASTO EN LA SIGUIENTE LINEA
SELECT * 
FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS" 
WHERE "U_DPE_TP_GASTO" =  $[$0_U_G.C_0_1.0];

IF EXISTS (
    SELECT 1 
    FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS"
    WHERE "U_DPE_TP_GASTO" = $[$0_U_G.C_0_1.0]
)
BEGIN
    SET @error = -1;
    SET @error_message = 'El tipo ya existe en otra línea';
END;


-- ***************************************************************************************************

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS" 
            WHERE "U_DPE_TP_GASTO" <> $[$0_U_G.C_0_1.0]
        ) THEN 'El tipo ya existe en otra línea'
        ELSE NULL
    END AS "Mensaje"
FROM DUMMY;


TRUNCATE TABLE "SBO_TEST_FIGURETTI_20250217"."@ADPE_TIP_GASTO";
TRUNCATE TABLE "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS";




SELECT
* 
FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS"
WHERE "Code" = '1';  --"U_DPE_TP_GASTO" = 'PROVEEDOR'



/*SELECT 
T0.* 
FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_TIP_GASTO" T0
;
--WHERE T0."Code" = '0001';*/

--INNER JOIN "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS" T1 ON T0."Code" = T1."Code";



-- *************************************

SELECT
* 
FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_TIP_GASTO" T0
INNER JOIN "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS" T1 ON T0."Code" = T1."Code" AND T0."LogInst" = T1."LogInst"
WHERE T0."U_DPE_DOC_NUM" = '24000018' --'24001027';


-- ********************secuencial**********************
SELECT
    LPAD(ROW_NUMBER() OVER (ORDER BY T0."Code"), 5, '0') AS "Secuencia",
    T0.*,
    T1.*
FROM
    "SBO_TEST_FIGURETTI_20250217"."@ADPE_TIP_GASTO" T0
INNER JOIN
    "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS" T1
ON
    T0."Code" = T1."Code" AND T0."LogInst" = T1."LogInst"

-- *****************************************************
BEGIN 

DECLARE CODE  NVARCHAR(15);
DECLARE NEWSEC  NVARCHAR(15);
DECLARE SEC INTEGER;

SELECT IFNULL($[@DPE_TIP_GASTO."Code".0],'') INTO CODE FROM dummy;

if (:CODE) THEN
    SELECT MAX(T0."Code") INTO SEC FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_TIP_GASTO" T0;
    SELECT (IFNULL(:SEC, 0) + 1 ) INTO SEC fROM DUMMY;

    SELECT LPAD ( (SELECT :SEC fROm dUMMY ),4,'0') iNTO NEWSEC fROM dUMMY;

END IF;


END;

-- ****************************************************************

BEGIN 

    DECLARE CODE  NVARCHAR(15);

    
    SELECT IFNULL(T0."Code", '') INTO CODE 
    FROM (
        SELECT 
            T0."Code"
        FROM 
            "SBO_TEST_FIGURETTI_20250217"."@ADPE_TIP_GASTO" T0
        INNER JOIN 
            "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS" T1
        ON 
            T0."Code" = T1."Code" AND T0."LogInst" = T1."LogInst"
        ORDER BY T0."Code"
        LIMIT 1
    ) AS T0;

    IF CODE <> '' THEN
        
        SELECT 'El código es: ' || CODE AS Mensaje;
    ELSE
        
        SELECT 'No se encontró ningún código' AS Mensaje;
    END IF;

END;

-- *******************

/*BEGIN 

DECLARE CODE  NVARCHAR(15);
DECLARE NEWSEC  NVARCHAR(15);
DECLARE SEC INTEGER;

--SELECT IFNULL($[@DPE_TIP_GASTO."Code".0],'') INTO CODE FROM dummy;

/*if (:CODE = '') then
    SELECT MAX(CAST(SUBSTRING(T0."Code", 3,4) AS INTEGER)) INTO SEC FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_TIP_GASTO" T0;
    SELECT (IFNULL(:SEC, 0) + 1 ) INTO SEC fROM DUMMY;

    SELECT LPAD ( (SELECT :SEC fROm dUMMY ),4,'0') iNTO NEWSEC fROM dUMMY;
            SELECT CONCAT(:NEWSEC ) fROM dUMMY;

   else
   if (:CODE !='' ) then

      Select :CODE from dummy;

    end if;

end if;*/

 -- Obtener el código del tipo de gasto
    SELECT IFNULL($[@DPE_TIP_GASTO."Code".0], '') INTO CODE FROM DUMMY;

    -- Verificar si el código es válido
    IF (:CODE <> '') THEN
        -- Obtener el máximo código existente
        SELECT MAX(T0."Code") INTO SEC FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_TIP_GASTO" T0;

        -- Incrementar el código máximo
        SELECT (IFNULL(:SEC, 0) + 1) INTO SEC FROM DUMMY;

        -- Formatear el nuevo código con ceros a la izquierda
        SELECT LPAD((SELECT :SEC FROM DUMMY), 4, '0') INTO NEWSEC FROM DUMMY;

    END IF;


END;*/


SELECT
T0."U_DPE_DOC_NUM",
T1."U_DPE_TP_GASTO"
--* 
FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_TIP_GASTO" T0
INNER JOIN "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS" T1 ON T0."Code" = T1."Code" AND T0."LogInst" = T1."LogInst"
WHERE T0."U_DPE_DOC_NUM" = '24002173' --'24000018';







IF :object_type = 'TIPOS_GASTOS' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
    -- Declarar variables
    DECLARE DOCNUM NVARCHAR(20);
    DECLARE TIPO_GASTO NVARCHAR(50);
    DECLARE DUPLICADOS INT DEFAULT 0;
    DECLARE CODIGO NVARCHAR(20);  -- Para el "Code" de la cabecera
    DECLARE LOGINST INT;         -- Para el "LogInst" de la cabecera
    
    -- Extraer el número de pedido desde list_of_cols_val_tab_del
    DOCNUM := :list_of_cols_val_tab_del;
    
    -- Obtener el "Code", "LogInst" y "TIPO_GASTO" desde la tabla detalle (asumiendo que hay un único registro que se está agregando/actualizando)
    SELECT T1."Code", T1."LogInst", T1."U_DPE_TP_GASTO" 
    INTO CODIGO, LOGINST, TIPO_GASTO
    FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS" T1
    WHERE T1."U_DPE_DOC_NUM" = :DOCNUM  -- Filtrar por número de pedido
    LIMIT 1;  -- Asumimos que solo se inserta/actualiza una línea a la vez
    
    -- Validar si se encontraron valores válidos
    IF :CODIGO IS NULL OR :LOGINST IS NULL OR :TIPO_GASTO IS NULL THEN
        error := 1004;
        error_message := N'DPE: No se encontró información del tipo de gasto';
        RETURN;
    END IF;
    
    -- Buscar duplicados (ahora comparando en toda la tabla detalle)
    SELECT COUNT(*) INTO DUPLICADOS
    FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS" T1
    INNER JOIN "SBO_TEST_FIGURETTI_20250217"."@ADPE_TIP_GASTO" T0 
        ON T1."Code" = T0."Code" 
        AND T1."LogInst" = T0."LogInst"
    WHERE T0."U_DPE_DOC_NUM" = :DOCNUM
    AND T1."U_DPE_TP_GASTO" = :TIPO_GASTO;
    
    -- Control de resultado
    IF :DUPLICADOS > 0 THEN
        error := 1002;
        error_message := N'DPE: Tipo de gasto "' || :TIPO_GASTO || '" ya existe en el pedido "' || :DOCNUM || '"';
        RETURN;
    END IF;
END IF;



-- *******************************************************************************************************************


IF :object_type = 'TIPOS_GASTOS' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
    -- Declarar variable para verificar la existencia del tipo de gasto
    DECLARE EXISTE_TIPO INT DEFAULT 0;
    
    -- Verificar si el tipo de gasto ya existe en otra línea para el mismo pedido
    SELECT 
        CASE 
            WHEN EXISTS (
                SELECT 1 
                FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS" T1
                INNER JOIN "SBO_TEST_FIGURETTI_20250217"."@ADPE_TIP_GASTO" T0 ON T1."Code" = T0."Code" AND T1."LogInst" = T0."LogInst"
                WHERE T0."U_DPE_DOC_NUM" = :list_of_cols_val_tab_del  -- Filtrar por número de pedido
                  AND T1."U_DPE_TP_GASTO" = (SELECT "U_DPE_TP_GASTO" FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS" WHERE "Code" = T1."Code" AND "LogInst" = T1."LogInst" LIMIT 1)  -- Asegurarse de comparar con el tipo de gasto actual
            ) THEN 1
            ELSE 0
        END
    INTO EXISTE_TIPO
    FROM DUMMY;  -- No necesitamos las tablas aquí, solo ejecutar la consulta
    
    -- Si el tipo de gasto ya existe, retornar un error
    IF :EXISTE_TIPO = 1 THEN
        error := 1002;  -- Usar un código de error específico
        error_message := 'El tipo de gasto ya existe en otra línea para este pedido.';
        RETURN;
    END IF;
END IF;




-- **************************************************************************************************************************


IF :object_type = 'TIPOS_GASTOS' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
    -- Declarar variable para verificar la existencia del tipo de gasto
    DECLARE EXISTE_TIPO INT DEFAULT 0;
    DECLARE DOCNUM NVARCHAR(20);

    -- Obtener el número de documento del pedido de :list_of_cols_val_tab_del
    DOCNUM := :list_of_cols_val_tab_del;

    -- Verificar si el tipo de gasto ya existe en otra línea para el mismo pedido
    SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    INTO EXISTE_TIPO
    FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS" T1
    INNER JOIN "SBO_TEST_FIGURETTI_20250217"."@ADPE_TIP_GASTO" T0 ON T1."Code" = T0."Code" AND T1."LogInst" = T0."LogInst"
    WHERE T0."U_DPE_DOC_NUM" = :DOCNUM
      AND T1."U_DPE_TP_GASTO" IN (SELECT U_DPE_TP_GASTO FROM "SBO_TEST_FIGURETTI_20250217"."@ADPE_DET_TIP_GASTOS" WHERE "Code" = T1."Code" AND "LogInst" = T1."LogInst");

    -- Si el tipo de gasto ya existe, retornar un error
    IF :EXISTE_TIPO = 1 THEN
        error := 1002;  -- Usar un código de error específico
        error_message := 'El tipo de gasto ya existe en otra línea para este pedido.';
        RETURN;
    END IF;
END IF;

****************************************************

SELECT
* 
FROM "SBO_TEST_FIGURETTI_20250217"."@DPE_TIP_GASTO" T0
INNER JOIN "SBO_TEST_FIGURETTI_20250217"."@DPE_DET_TIP_GASTOS" T1 ON T0."Code" = T1."Code" 




--SELECT * FROM "SBO_TEST_FIGURETTI_20250217"."@DPE_DET_TIP_GASTOS";



DROP PROCEDURE SBO_SP_TransactionNotification_CLIENT;

CREATE PROCEDURE SBO_SP_TransactionNotification_CLIENT
(
    in object_type nvarchar(30),                -- SBO Object Type
    in transaction_type nchar(1),            -- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
    in num_of_cols_in_key int,
    in list_of_key_cols_tab_del nvarchar(255),
    in list_of_cols_val_tab_del nvarchar(255), 
    -- Return values
    out error int,                             -- Result (0 for no error)
    out error_message nvarchar (200)           -- Error string to be displayed
)
LANGUAGE SQLSCRIPT
AS
BEGIN
    -- Declarar variables
    DECLARE EXISTE_TIPO INT DEFAULT 0;
    DECLARE NUM_PEDIDO NVARCHAR(15);

    -- Asignar el valor de list_of_cols_val_tab_del a NUM_PEDIDO
    NUM_PEDIDO := :list_of_cols_val_tab_del;

    -- Validar tipo de objeto y transacción
    IF :object_type = 'TIPOS_GASTOS' and (:transaction_type = 'A' OR :transaction_type = 'U') THEN

        -- Verificar si el tipo de gasto ya existe en otra línea para el mismo pedido
        SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
        INTO EXISTE_TIPO
        FROM "SBO_TEST_FIGURETTI_20250217"."@DPE_DET_TIP_GASTOS" T1
        WHERE T1."Code" IN (SELECT "Code" FROM "SBO_TEST_FIGURETTI_20250217"."@DPE_TIP_GASTO" WHERE "U_DPE_DOC_NUM" = :NUM_PEDIDO)
          AND T1."U_DPE_TP_GASTO" IN (SELECT "U_DPE_TP_GASTO" FROM "SBO_TEST_FIGURETTI_20250217"."@DPE_DET_TIP_GASTOS" WHERE "U_DPE_DOC_NUM" = :NUM_PEDIDO)
          AND T1."U_DPE_DOC_NUM" = :NUM_PEDIDO;

        -- Si el tipo de gasto ya existe, retornar un error
        IF EXISTE_TIPO > 0 THEN
            error := 1000; 
            error_message := 'Ya existe este tipo de gasto para este número de pedido.';
            RETURN;
        END IF;
    END IF;

    -- Validación para agregar o actualizar en OCRD (Datos Maestro Socio Negocio)
    IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
       
        -- [EL RESTO DE TU CODIGO PARA OCRD]
       
    END IF;
END;



-- ************************************************************************************************

DROP PROCEDURE SBO_SP_TransactionNotification_CLIENT;

CREATE PROCEDURE SBO_SP_TransactionNotification_CLIENT
(
    in object_type nvarchar(30),                -- SBO Object Type
    in transaction_type nchar(1),            -- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
    in num_of_cols_in_key int,
    in list_of_key_cols_tab_del nvarchar(255),
    in list_of_cols_val_tab_del nvarchar(255), 
    -- Return values
    out error int,                             -- Result (0 for no error)
    out error_message nvarchar (200)           -- Error string to be displayed
)
LANGUAGE SQLSCRIPT
AS
BEGIN
    -- Declaración de variables
    DECLARE EXISTE_TIPO INT DEFAULT 0;
    DECLARE NUM_PEDIDO NVARCHAR(15);
    DECLARE TIPO_GASTO NVARCHAR(50);

    -- Validar tipo de objeto y transacción
    IF :object_type = 'TIPOS_GASTOS' and (:transaction_type = 'A' OR :transaction_type = 'U') THEN
        
        -- Extraer NUM_PEDIDO de list_of_cols_val_tab_del
        NUM_PEDIDO := :list_of_cols_val_tab_del;

        -- Iterar sobre la lista de tipos de gasto
        FOR TIPO_GASTO IN ('PROVEEDOR', 'FLETE', 'GASTOS LOCALES', 'TRIBUTOS', 'MANIOBRAS', 'GASTOS LOGISTICOS') DO
            -- Verificar si el tipo de gasto ya existe para el mismo número de pedido
            SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END INTO EXISTE_TIPO
            FROM "SBO_TEST_FIGURETTI_20250217"."@DPE_DET_TIP_GASTOS" T1
            INNER JOIN "SBO_TEST_FIGURETTI_20250217"."@DPE_TIP_GASTO" T0 ON T1."Code" = T0."Code"
            WHERE T0."U_DPE_DOC_NUM" = :NUM_PEDIDO
              AND T1."U_DPE_TP_GASTO" = :TIPO_GASTO;

            -- Si el tipo de gasto ya existe, retornar un error
            IF EXISTE_TIPO > 0 THEN
                error := 1000;
                error_message := 'El tipo de gasto "' || :TIPO_GASTO || '" ya existe para el número de pedido "' || :NUM_PEDIDO || '".';
                RETURN;
            END IF;
        END FOR;
    END IF;

    -- Resto del código para otras validaciones (OCRD, etc.)
    IF :object_type = '2' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
        -- [EL RESTO DE TU CODIGO PARA OCRD]
    END IF;
END;




-- *********************************************


DROP PROCEDURE SBO_SP_TransactionNotification_CLIENT;

CREATE PROCEDURE SBO_SP_TransactionNotification_CLIENT
(
    in object_type nvarchar(30),              -- SBO Object Type
    in transaction_type nchar(1),            -- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
    in num_of_cols_in_key int,
    in list_of_key_cols_tab_del nvarchar(255),
    in list_of_cols_val_tab_del nvarchar(255), 
    -- Return values
    out error int,                           -- Result (0 for no error)
    out error_message nvarchar (200)         -- Error string to be displayed
)
LANGUAGE SQLSCRIPT
AS
-- Variables
DOCNUM NVARCHAR(10);
DOCENTRY nvarchar(10);
TIPO_GASTO NVARCHAR(100);
CODIGO_GASTO NVARCHAR(20);
EXISTE_TIPO INT;

BEGIN
    -- Inicializar variables de salida
    error := 0;
    error_message := '';
    
    -- Validar tipo de objeto y transacción
    IF :object_type = 'TIPOS_GASTOS' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
        -- Obtener el código del tipo de gasto que se está insertando/actualizando
        CODIGO_GASTO := :list_of_cols_val_tab_del;
        
        -- Obtener el tipo de gasto que se está intentando insertar
        SELECT "Tipo de Gastos" INTO TIPO_GASTO 
        FROM "SBO_TEST_FIGURETTI_20250217"."@DPE_DET_TIP_GASTOS"
        WHERE "Code" = :CODIGO_GASTO
        LIMIT 1;
        
        -- Verificar si este tipo de gasto ya existe para este código
        SELECT COUNT(*) INTO EXISTE_TIPO
        FROM "SBO_TEST_FIGURETTI_20250217"."@DPE_DET_TIP_GASTOS"
        WHERE "Code" = :CODIGO_GASTO
        AND "Tipo de Gastos" = :TIPO_GASTO;
        
        -- Si ya existe, retornar error
        IF :EXISTE_TIPO > 1 THEN
            error := 1;
            error_message := 'Error: El tipo de gasto ' || :TIPO_GASTO || ' ya existe para este documento. No se permiten duplicados.';
            RETURN;
        END IF;
    END IF;
    
    -- Si todo está bien, continuar con la operación normal
    error := 0;
    error_message := 'Operación completada con éxito';
END;


/* Extra day - TOTAL DE DIAS DE VENCIMIENTOS */

SELECT 
    --T0."DocNum",
    --T0."ExtraDays",
    --T1."CardName",
    --T1."GroupNum",
    --T2."PymntGroup",
   T2."ExtraDays"
FROM OPOR T0
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode" 
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
WHERE T0."DocNum" = '24000018' --$[$13_U_E.24.0]
--WHERE T0."GroupNum" IN ('11','12','13','14','15','16')
--ORDER BY T0."DocDate" DESC
--LIMIT 1000


/* Fecha maxima de pago */

SELECT
   /*T0."DocNum", 
   T2."GroupNum",
   T2."PymntGroup",
   T2."ExtraDays",
   T0."U_SYP_MDFE" AS "Fecha de Embarque",
   T0."U_SYP_FLLMERC" AS "Fecha llegada a Puerto",*/

   CASE 
        WHEN T2."GroupNum" = -1 THEN ADD_DAYS(T0."U_SYP_FLLMERC", -10)   --Si es al contado = Fecha llegada a puerto - 10 días
        WHEN 
             T2."GroupNum" IN ('12','15','16') THEN ADD_DAYS(T0."U_SYP_MDFE", T2."ExtraDays") -- Si tiene credito = Fecha de Embarque + Cantidad de dias adicionales (Días de credito registrados)
        ELSE '' --T0."U_SYP_MDFE" 
    END AS "FechaMaximaPagoCorregido"
  
      
FROM OPOR T0 
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
WHERE T0."DocNum" = $[$13_U_E.24.0] --'24000330'  --'24000018'
LIMIT 1