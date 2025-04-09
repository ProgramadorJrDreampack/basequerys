-- Query DPE
SELECT 
(SELECT "PrintHeadr" FROM OADM) AS "NOM_SOC", 
(SELECT "CompnyAddr" FROM OADM) AS "DIR_SOC",
T0."DocEntry", 
T0."DocNum", 
T0."CardCode", 
T2."LicTradNum", 
T3."PymntGroup", 
T0."CardName", 
T0."Address", 
T0."DocDate", 
T0."DocDueDate", 
T0."Comments", 
T5."U_NAME", 
T0."Address2", 
T0."DocTotal", 
T0."VatSumSy",
CASE 
    WHEN T0."U_FIG_CON_REC" = 0 THEN 'SIN NOVEDAD'
    WHEN T0."U_FIG_CON_REC" = 1 THEN 'PLAGAS'
    WHEN T0."U_FIG_CON_REC" = 2 THEN 'SUCIEDAD'
    WHEN T0."U_FIG_CON_REC" = 3 THEN 'DAÑOS'
    WHEN T0."U_FIG_CON_REC" = 4 THEN 'OTROS'
    ELSE 'DESCONOCIDO'
END AS "CON_REC", 
--T0."U_FIG_CON_REC", 
T0."U_FIG_COMEN_REC" , 
T4."SlpName", 
T1."ItemCode", 
T1."Dscription", 
T1."Quantity", 
T1."Price", 
T1."LineTotal", 
T1."InvQty"
FROM OPDN T0 
INNER JOIN PDN1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"
INNER JOIN OCTG T3 ON T2."GroupNum" = T3."GroupNum"
INNER JOIN OSLP T4 ON  T0."SlpCode" = T4."SlpCode"
INNER JOIN OUSR T5 ON T0."UserSign" = T5."USERID"
where T0."DocEntry" = {?DocKey@}