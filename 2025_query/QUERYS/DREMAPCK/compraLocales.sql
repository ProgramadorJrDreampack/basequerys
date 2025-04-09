SELECT 
    P1."DocDate" AS "Fecha SC",
    P2."DocTime" AS "Hora SC",
    P3."Name",
    A2."CreateDate" AS "Fecha Solic Apr",
    A2."CreateTime",
    A2."UpdateDate" AS "Fecha Aut Apr",
    A2."UpdateTime",
    T0."CANCELED" AS "Cancelado PED",
    T0."DocNum" AS "DocNum Pedido",
    CASE 
        WHEN T0."U_LAB_CLASIFIC" = 'COR' THEN 'CORRECTIVO'
        WHEN T0."U_LAB_CLASIFIC" = 'PRE' THEN 'PREVENTIVO'
        WHEN T0."U_LAB_CLASIFIC" = 'COM' THEN 'COMPLEMENTO'
        WHEN T0."U_LAB_CLASIFIC" = 'EME' THEN 'CORRECTIVO EMERGENTE'
        ELSE T0."U_LAB_CLASIFIC" 
    END AS "Clasificacion",
    T0."DocType",
    T0."DocDate",
    T0."DocDueDate" AS "Fecha Entrega",
    T0."CreateDate",
    T0."CardName",
    --T2."SlpName",
    T6."U_NAME",
    T1."OcrCode4" AS "Cod Centro Costo",
    T5."OcrName" AS "Centro de Costo",
    T1."ItemCode",
    T1."Dscription",
    T8."Name",
    T1."LineNum",
    T1."Quantity",
    T1."Price",
    T0."DocTotal",
    T0."Header",
    T4."CANCELED" AS "Cancelado EM",
    T4."DocNum" AS "DocNum EM",
    T4."DocDate" AS "Fecha EntradaM",
    T3."Quantity",
    T3."Price"
FROM OPOR T0 
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN OWDD A1 ON T0."DocEntry" = A1."DocEntry" AND A1."ObjType" = '22'
LEFT JOIN WDD1 A2 ON A1."WddCode" = A2."WddCode" AND A2."Status" = 'Y'
LEFT JOIN PRQ1 P1 ON T1."BaseEntry" = P1."DocEntry" AND T1."BaseLine" = P1."LineNum"
LEFT JOIN OPRQ P2 ON P1."DocEntry" = P2."DocEntry"
LEFT JOIN OUDP P3 ON P2."Department" = P3."Code"
--LEFT JOIN OSLP T2 ON T0."SlpCode" = T2."SlpCode"

LEFT JOIN PDN1 T3 ON T0."DocEntry" = T3."BaseEntry" AND T1."LineNum" = T3."BaseLine" ANd T3."BaseType" = '22'
LEFT JOIN OPDN T4 ON T3."DocEntry" = T4."DocEntry" 
LEFT JOIN OOCR T5 ON T1."OcrCode4" = T5."OcrCode"
LEFT JOIN OUSR T6 ON T0."UserSign" = "USERID"
LEFT JOIN OITM T7 ON T1."ItemCode" = T7."ItemCode"
LEFT JOIN "SBO_FIGURETTI_PRO"."@SYP_SUBGRUPO2" T8 ON T7."U_SYP_SUBGRUPO2" = T8."Code"

WHERE T0."DocDate" BETWEEN [%0] AND [%1]
AND T0."U_SYP_TIPCOMPRA" = '01' AND T0."CANCELED" = 'N' --AND T0."DocNum" IN ('23001060')
--AND T4."CANCELED" = 'N'
ORDER BY T0."DocDate" ASC