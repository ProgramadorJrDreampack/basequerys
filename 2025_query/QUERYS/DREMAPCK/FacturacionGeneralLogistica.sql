/* El sr Andres Torres solicita un nuevo query para las facturas */

SELECT 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."CardName",
    T0."NumAtCard", 
     SUM(CASE 
        WHEN 
           T0."NumAtCard" LIKE '04-001%' THEN ((CASE WHEN T1."NoInvtryMv" = 'N' THEN T1."Quantity" ELSE 0 END) * -1) 
           ELSE T1."Quantity" 
    END) AS "CANTIDAD",
    T1."UomCode" AS "UoM",
    SUM(CASE 
        WHEN T0."NumAtCard" LIKE '04-001%' THEN (T1."TotalSumSy" * -1) 
        ELSE T1."TotalSumSy" 
    END) AS "Total Ingreso", 
    SUM(T1."GTotalSC") AS "Total Bruto",
    SUM(((T1."InvQty" * COALESCE(A1."U_SYP_UPPL", 1)) * (T2."U_SYP_PESOBRUTO" / COALESCE(A1."U_SYP_UPPL", 1))) / 1000) AS "Ton", 
    D1."CityS"

FROM OINV T0  
INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN INV12 D1 ON T0."DocEntry" = D1."DocEntry"
LEFT JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode" 
LEFT JOIN (
    SELECT *  FROM OITM A0 
    WHERE A0."ItemName" LIKE '%PACK%' AND 
        A0."ItemCode" LIKE '07%' AND 
        A0."PriceUnit" = '16'
) A1 ON T2."ItemCode" = A1."ItemCode"
GROUP BY 
    T0."DocEntry", 
    T0."DocNum", 
    T0."DocDate", 
    T0."CardName",
    T0."NumAtCard", 
    T1."UomCode",
    D1."CityS"
LIMIT 100