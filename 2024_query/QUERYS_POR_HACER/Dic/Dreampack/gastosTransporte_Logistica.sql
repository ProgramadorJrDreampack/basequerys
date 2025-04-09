SELECT
    -- T0.*,
    T0."Transaccion",
    T0."Number",
    T0."Origen",
    T0."BaseRef",
    T0."RefDate",
    T0."Memo",
    T0."Numero_Origen",
    T0."Reference2",
    T0."Account",
    T0."Nombre_Cuenta",
    T0."Debit",
    T0."Credit",
    T0."ShortName",
    T0."ContraAct",

    --T0."Cuenta_Mayor_SN",
    --T0."Ref1",
    --T0."Ref2",
    --T0."UserSign",
    T1."DocNum",
    T3."DocNum",
    CASE
        WHEN T0."Origen" IN ('AS', 'RC') THEN T2."Dscription"
        WHEN T0."Origen" = 'PC' THEN T4."Dscription"
        ELSE 'N/C' 
    END AS "Descripcion",
    CASE
        WHEN T0."Origen" IN ('AS', 'RC') THEN (CASE WHEN T0."Credit" > 0 THEN (-T2."TotalSumSy") ELSE T2."TotalSumSy" END)
        WHEN T0."Origen" = 'PC' THEN (CASE WHEN T0."Credit" > 0 THEN (-T4."TotalSumSy") ELSE T4."TotalSumSy" END)
        ELSE 0 
    END AS "Total",
    T2."TotalSumSy",
    CASE
        WHEN T0."Origen" IN ('AS', 'RC') THEN (
            CASE
                WHEN T2."U_DPE_MOT_TRNS" = 'V' THEN 'VENTA'
                WHEN T2."U_DPE_MOT_TRNS" = 'T' THEN 'TRANSPORTACION'
                WHEN T2."U_DPE_MOT_TRNS" = 'E' THEN 'EXPORTACION'
                WHEN T2."U_DPE_MOT_TRNS" = 'C' THEN 'CONSIGNACION'
                WHEN T2."U_DPE_MOT_TRNS" = 'EC' THEN 'ENTREGA A CLIENTE'
                WHEN T2."U_DPE_MOT_TRNS" = 'DV' THEN 'DEVOLUCION'
                WHEN T2."U_DPE_MOT_TRNS" = 'DP' THEN 'DESPERDICIO'
                WHEN T2."U_DPE_MOT_TRNS" = 'MP' THEN 'MATERIA PRIMA'
                WHEN T2."U_DPE_MOT_TRNS" = 'IM' THEN 'INSUMOS'
                WHEN T2."U_DPE_MOT_TRNS" = 'AE' THEN 'ALMACENAMIENTO EXTERNO'
                ELSE 'N/C' 
            END)
        WHEN T0."Origen" = 'PC' THEN (
            CASE
                WHEN T4."U_DPE_MOT_TRNS" = 'V' THEN 'VENTA'
                WHEN T4."U_DPE_MOT_TRNS" = 'T' THEN 'TRANSPORTACION'
                WHEN T4."U_DPE_MOT_TRNS" = 'E' THEN 'EXPORTACION'
                WHEN T4."U_DPE_MOT_TRNS" = 'C' THEN 'CONSIGNACION'
                WHEN T4."U_DPE_MOT_TRNS" = 'EC' THEN 'ENTREGA A CLIENTE'
                WHEN T4."U_DPE_MOT_TRNS" = 'DV' THEN 'DEVOLUCION'
                WHEN T4."U_DPE_MOT_TRNS" = 'DP' THEN 'DESPERDICIO'
                WHEN T4."U_DPE_MOT_TRNS" = 'MP' THEN 'MATERIA PRIMA'
                WHEN T4."U_DPE_MOT_TRNS" = 'IM' THEN 'INSUMOS'
                WHEN T4."U_DPE_MOT_TRNS" = 'AE' THEN 'ALMACENAMIENTO EXTERNO'
                ELSE 'N/C' END
            )
        ELSE 'N/C' 
    END AS "Motivo"

FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR" T0
LEFT JOIN OPCH T1 ON CAST(T0."Numero_Origen" AS int) = T1."DocNum" AND T0."Origen" IN ('AS', 'RC') AND T1."CANCELED" = 'N'
LEFT JOIN PCH1 T2 ON T1."DocEntry" = T2."DocEntry" AND T0."Origen" IN ('AS', 'RC') AND T0."Account" = T2."AcctCode"-- = '6010115001'
LEFT JOIN ORPC T3 ON CAST(T0."Numero_Origen" AS int) = T3."DocNum" AND T0."Origen" = 'PC' AND T3."CANCELED" = 'N'
LEFT JOIN RPC1 T4 ON T3."DocEntry" = T4."DocEntry" AND T0."Origen" = 'PC' AND T0."Account" = T4."AcctCode"-- = '6010115001'

WHERE T0."Account" IN ('6010115001', '6010125001')
AND T0."RefDate" >= '2023-01-01'
-- ****************************************************************************************************************************
-- SUS TIPOS DE "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"
-- Transacion es INTEGER, Number es INTEGER, Origen es VARCHAR, BaseRef es NVARCHAR, 
-- RefDate es TIMESTAMP, Memo es NVARCHAR, Numero_Origen es NVARCHAR,  
-- Reference2 es  NVARCHAR, Account es NVARCHAR, Nombre_Cuenta es NVARCHAR, 
-- Debit es DECIMAL, Credit es DECIMAL, ShortName es NVARCHAR, ContraAct es NVARCHAR, 
-- Cuenta_Mayor_SN es VARCHAR, Ref1 es NVARCHAR, Ref2 es NVARCHAR, UserSign es NVARCHAR

-- **************************************************************************************************************************
-- _SYS_BIC -> Column View -> sap.sbofigurettipro/DPE_LIBRO_MAYOR

CREATE CALCULATION SCENARIO "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR" USING 
CREATE COLUMN VIEW "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR" WITH PARAMETERS (indexType=11,
	 'PARENTCALCINDEXSCHEMA'='_SYS_BIC',
	'PARENTCALCINDEX'='sap.sbofigurettipro/DPE_LIBRO_MAYOR',
	'PARENTCALCNODE'='finalProjection')
;
COMMENT ON VIEW "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR" is 'DPE_LIBRO_MAYOR'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."Transaccion" is 'Transaccion'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."Number" is 'Number'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."Origen" is 'Origen'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."BaseRef" is 'BaseRef'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."RefDate" is 'RefDate'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."Memo" is 'Memo'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."Numero_Origen" is 'Numero_Origen'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."Reference2" is 'Reference2'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."Account" is 'Account'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."Nombre_Cuenta" is 'Nombre_Cuenta'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."Debit" is 'Debit'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."Credit" is 'Credit'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."ShortName" is 'ShortName'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."ContraAct" is 'ContraAct'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."Cuenta_Mayor_SN" is 'Cuenta_Mayor_SN'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."Ref1" is 'Ref1'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."Ref2" is 'Ref2'
;
COMMENT ON COLUMN "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR"."UserSign" is 'UserSign'



/* asi quedo en producción 17-01-2025 */
/* SE MODIFICO EL QUERY DE PRODUCCION LOGISTICA - GASTO TRANSPORTE */
SELECT
    CAST(T0."Transaccion" AS VARCHAR) "Transaccion",
    CAST(T0."Number" AS VARCHAR) "Number",
    CAST(T0."Origen" AS VARCHAR) "Origen",
    CAST(T0."BaseRef" AS NVARCHAR) "BaseRef",
    CAST(T0."RefDate" AS DATE) "RefDate",
    CAST(T0."Memo" AS NVARCHAR) "Memo",
    CAST(T0."Numero_Origen" AS NVARCHAR) "Numero_Origen",
    CAST(T0."Reference2" AS NVARCHAR) "Reference2",
    CAST(T0."Account" AS NVARCHAR) "Account",
    CAST(T0."Nombre_Cuenta" AS NVARCHAR) "Nombre_Cuenta",
    CAST(T0."Debit" AS DECIMAL) "Debit",
    CAST(T0."Credit" AS DECIMAL) "Credit",
    CAST(T0."ShortName" AS NVARCHAR) "ShortName",
    CAST(T0."ContraAct" AS NVARCHAR) "ContraAct",
    CAST(T0."Cuenta_Mayor_SN" AS VARCHAR) "Cuenta_Mayor_SN",
    CAST(T0."Ref1" AS NVARCHAR) "Ref1",
    CAST(T0."Ref2" AS NVARCHAR) "Ref2",
    CAST(T0."UserSign" AS NVARCHAR) "UserSign",
    
    CAST(T1."DocNum" AS VARCHAR) "DocNum",
    CAST(T3."DocNum" AS VARCHAR) "DocNum",
    
    CASE
        WHEN CAST(T0."Origen" AS VARCHAR) IN ('AS', 'RC') THEN T2."Dscription"
        WHEN CAST(T0."Origen" AS VARCHAR) = 'PC' THEN T4."Dscription"
        ELSE 'N/C' 
    END AS "Descripcion",
    CASE
        WHEN CAST(T0."Origen" AS VARCHAR) IN ('AS', 'RC') THEN (CASE WHEN T0."Credit" > 0 THEN (-T2."TotalSumSy") ELSE T2."TotalSumSy" END)
        WHEN CAST(T0."Origen" AS VARCHAR) = 'PC' THEN (CASE WHEN T0."Credit" > 0 THEN (-T4."TotalSumSy") ELSE T4."TotalSumSy" END)
        ELSE 0 
    END AS "Total",
    T2."TotalSumSy",
    CASE
        WHEN CAST(T0."Origen" AS VARCHAR) IN ('AS', 'RC') THEN (
            CASE
                WHEN T2."U_DPE_MOT_TRNS" = 'V' THEN 'VENTA'
                WHEN T2."U_DPE_MOT_TRNS" = 'T' THEN 'TRANSPORTACION'
                WHEN T2."U_DPE_MOT_TRNS" = 'E' THEN 'EXPORTACION'
                WHEN T2."U_DPE_MOT_TRNS" = 'C' THEN 'CONSIGNACION'
                WHEN T2."U_DPE_MOT_TRNS" = 'EC' THEN 'ENTREGA A CLIENTE'
                WHEN T2."U_DPE_MOT_TRNS" = 'DV' THEN 'DEVOLUCION'
                WHEN T2."U_DPE_MOT_TRNS" = 'DP' THEN 'DESPERDICIO'
                WHEN T2."U_DPE_MOT_TRNS" = 'MP' THEN 'MATERIA PRIMA'
                WHEN T2."U_DPE_MOT_TRNS" = 'IM' THEN 'INSUMOS'
                WHEN T2."U_DPE_MOT_TRNS" = 'AE' THEN 'ALMACENAMIENTO EXTERNO'
                ELSE 'N/C' 
            END)
        WHEN CAST(T0."Origen" AS VARCHAR) = 'PC' THEN (
            CASE
                WHEN T4."U_DPE_MOT_TRNS" = 'V' THEN 'VENTA'
                WHEN T4."U_DPE_MOT_TRNS" = 'T' THEN 'TRANSPORTACION'
                WHEN T4."U_DPE_MOT_TRNS" = 'E' THEN 'EXPORTACION'
                WHEN T4."U_DPE_MOT_TRNS" = 'C' THEN 'CONSIGNACION'
                WHEN T4."U_DPE_MOT_TRNS" = 'EC' THEN 'ENTREGA A CLIENTE'
                WHEN T4."U_DPE_MOT_TRNS" = 'DV' THEN 'DEVOLUCION'
                WHEN T4."U_DPE_MOT_TRNS" = 'DP' THEN 'DESPERDICIO'
                WHEN T4."U_DPE_MOT_TRNS" = 'MP' THEN 'MATERIA PRIMA'
                WHEN T4."U_DPE_MOT_TRNS" = 'IM' THEN 'INSUMOS'
                WHEN T4."U_DPE_MOT_TRNS" = 'AE' THEN 'ALMACENAMIENTO EXTERNO'
                ELSE 'N/C' END
            )
        ELSE 'N/C' 
    END AS "Motivo"
FROM "_SYS_BIC"."sap.sbofigurettipro/DPE_LIBRO_MAYOR" T0
LEFT JOIN OPCH T1 ON CAST(T0."Numero_Origen" AS NVARCHAR) = CAST(T1."DocNum" AS VARCHAR) AND T1."CANCELED" = 'N'   
LEFT JOIN PCH1 T2 ON T1."DocEntry" = T2."DocEntry" AND T0."Origen" IN ('AS', 'RC') AND T0."Account" = T2."AcctCode"
LEFT JOIN ORPC T3 ON CAST(T0."Numero_Origen" AS NVARCHAR) = CAST(T1."DocNum" AS VARCHAR) AND T0."Origen" = 'PC' AND T3."CANCELED" = 'N'
LEFT JOIN RPC1 T4 ON T3."DocEntry" = T4."DocEntry" AND T0."Origen" = 'PC' AND T0."Account" = T4."AcctCode"
WHERE T0."Account" IN ('6010115001', '6010125001')
AND T0."RefDate" >= '2023-01-01'