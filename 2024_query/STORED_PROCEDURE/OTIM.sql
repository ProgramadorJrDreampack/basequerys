-- Validaciones de datos del maestro de artículos
SELECT
    MAX(CASE 
        WHEN T0."SalUnitMsr" IS NULL OR T0."SalUnitMsr" = '' THEN 1 
        WHEN T0."SalUnitMsr" NOT IN ('XUN', 'XBX', 'H87', 'ACT') THEN 2 
        ELSE 0 
    END) AS SalUnitMsrCheck,
    
    /* MAX(CASE 
        WHEN T0."ItemName" IS NULL OR T0."ItemName" = '' THEN 1 
        ELSE 0 
    END) AS ItemNameCheck,
    
    MAX(CASE 
        WHEN T0."ItmsGrpCod" IS NULL OR T0."ItmsGrpCod" = '' THEN 1 
        ELSE 0 
    END) AS ItemGroupCheck */

INTO 
    SAL_UNIT_MSR_VALID --, ITEM_NAME_VALID, ITEM_GROUP_VALID
FROM OITM T0
WHERE T0."ItemCode" = :list_of_cols_val_tab_del; 


-- Manejo de errores para las validaciones del maestro de artículos
IF SAL_UNIT_MSR_VALID = 1 THEN
    error := 1;
    error_message := N'La unidad de medida de venta es requerido';
    RETURN;
END IF;

IF SAL_UNIT_MSR_VALID = 2 THEN
    error := 1;
    error_message := N'Error en la unidad de medida de venta. Debe ser XUN, XBX, H87 o ACT.';
    RETURN;
END IF;

/* IF ITEM_NAME_VALID = 2 THEN
    error := 3;
    error_message := N'El nombre del artículo no puede estar vacío.';
    RETURN;
END IF;

IF ITEM_GROUP_VALID > 0 THEN
    error := 4;
    error_message := N'El grupo del artículo no puede estar vacío.';
    RETURN;
END IF; */





/*  */

-- Orden de compra - Pedido OPOR
IF :object_type = '22' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

    -- Validar que el socio de negocio y el maestro de artículos tengan todos los campos requeridos llenos antes de permitir la creación de la orden de compra.
    SELECT
        COUNT(CASE WHEN T0."CardType" IN ('C', 'S', 'L') THEN 1 END) AS BP_EXISTS,
        MAX(CASE 
            WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
            WHEN LENGTH(T0."CardName") > 60 THEN 2
            ELSE 0 
        END) AS CardNameCheck,
        MAX(CASE 
            WHEN T0."E_Mail" IS NULL OR T0."E_Mail" = '' THEN 1
            WHEN T0."E_Mail" NOT LIKE_REGEXPR '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN 2
            ELSE 0 
        END) AS EmailCheck,
        MAX(CASE 
            WHEN T0."Phone1" IS NULL OR T0."Phone1" = '' THEN 1
            WHEN T0."Phone1" NOT LIKE_REGEXPR '^[0-9]+$' THEN 2  
            ELSE 0 
        END) AS PhoneCheck,
        MAX(CASE WHEN T0."U_B1SYS_MainUsage" IS NULL OR T0."U_B1SYS_MainUsage" = '' THEN 1 ELSE 0 END) AS MainUsageCheck,
        MAX(CASE WHEN T1."Address" IS NULL OR T1."Address" = '' THEN 1 ELSE 0 END) AS AddressCheck,
        MAX(CASE WHEN T1."Street" IS NULL OR T1."Street" = '' THEN 1 ELSE 0 END) AS StreetCheck,
        MAX(CASE WHEN T1."Block" IS NULL OR T1."Block" = '' THEN 1 ELSE 0 END) AS ColoniaCheck,
        MAX(CASE WHEN T1."City" IS NULL OR T1."City" = '' THEN 1 ELSE 0 END) AS CityCheck,
        MAX(CASE WHEN T1."ZipCode" IS NULL OR T1."ZipCode" = '' THEN 1 ELSE 0 END) AS ZipCodeCheck,
        MAX(CASE
            WHEN T1."Country" IS NULL OR T1."Country" = '' THEN 1
            WHEN LENGTH(T2."Code") != 3 THEN 2  
            ELSE 0 
        END) AS CountryCheck,  
        MAX(CASE 
            WHEN T0."GroupNum" IS NULL OR NOT EXISTS (SELECT 1 FROM OCTG T2 WHERE T2."GroupNum" = T0."GroupNum") THEN 1 
            ELSE 0 
        END) AS PaymentConditionCheck,
        MAX(CASE 
            WHEN T0."QryGroup1" = 'Y' AND (T0."LicTradNum" IS NULL OR T0."LicTradNum" != 'XEXX010101000') THEN 1  
            WHEN T0."QryGroup1" = 'N' AND (T0."LicTradNum" IS NULL OR T0."LicTradNum" = 'XEXX010101000') THEN 2  
            ELSE 0 
        END) AS LicTradNumCheck,
        MAX(CASE WHEN T0."VatIdUnCmp" IS NULL OR T0."VatIdUnCmp" = '' THEN 1 ELSE 0 END) AS IdFiscalCheck,
        MAX(CASE WHEN T0."U_SYP_FPAGO" IS NULL OR T0."U_SYP_FPAGO" = '' THEN 1 ELSE 0 END) AS RegimenFiscalV4Check,

        -- Validación de métodos de pago
        MAX(CASE 
            WHEN NOT EXISTS (SELECT * FROM OPYM WHERE "PayMethCod" = T5."PymCode") THEN 1 
            ELSE 0 
        END) AS PayMethCodCheck,

        -- Validación de anexos (ATC1)
        MAX(CASE 
            WHEN NOT EXISTS (SELECT * FROM ATC1 WHERE "AbsEntry" = T0."AtcEntry") THEN 1 
            ELSE 0
        END) AS AnexosCheck,

        -- Validaciones del maestro de artículos usando el alias T6
        MAX(CASE 
            WHEN T6."SalUnitMsr" IS NULL OR T6."SalUnitMsr" = '' THEN 1 
            WHEN T6."SalUnitMsr" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT') THEN 2 
            ELSE 0
        END) AS SalUnitMsrStatus,

        MAX(CASE 
            WHEN T6."InvntryUom" IS NULL OR T6."InvntryUom" = '' THEN 1 
            WHEN T6."InvntryUom" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT') THEN 2 
            ELSE 0
        END) AS InvntryUomStatus

    INTO 
        BP_EXISTS, CARD_NAME_VALID, EMAIL_VALID, PHONE_VALID, MAIN_USAGE, 
        ADDRESS_VALID, STREET_VALID, COLONIA_VALID, CITY_VALID, ZIP_CODE_VALID, COUNTRY_VALID,
        PAYMENT_CONDITION_VALID, LIC_TRAD_NUM_VALID, ID_FISCAL_VALID, REGIMEN_FISCAL_V4_VALID,
        PAYMENT_METHOD_CHECK_VALID, ANEXOS_VALID, SAL_UNIT_MSR_STATUS, INVNTRY_UOM_STATUS
    FROM OCRD T0
    LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
    LEFT JOIN OCRY T2 ON T1."Country" = T2."Code"
    LEFT JOIN CRD2 T5 ON T0."CardCode" = T5."CardCode"
    LEFT JOIN OITM T6 ON OITM."ItemCode" IN (
      SELECT "ItemCode"
      FROM OPOR WHERE "DocEntry" IN (:list_of_cols_val_tab_del)
    )
    WHERE T0."CardCode" IN (
      SELECT "CardCode"
      FROM OPOR WHERE "DocEntry" IN (:list_of_cols_val_tab_del)
    );

    -- Asignar un error general si alguna validación falla en el socio de negocio o en el maestro de artículos
    IF BP_EXISTS > 0 OR CARD_NAME_VALID > 0 
       OR EMAIL_VALID > 0 OR PHONE_VALID > 0 
       OR MAIN_USAGE > 0 OR ADDRESS_VALID > 0 
       OR STREET_VALID > 0 OR COLONIA_VALID > 0 
       OR CITY_VALID > 0 OR ZIP_CODE_VALID > 0 OR COUNTRY_VALID > 0 
       OR PAYMENT_CONDITION_VALID > 0 OR LIC_TRAD_NUM_VALID > 0 
       OR ID_FISCAL_VALID > 0 OR REGIMEN_FISCAL_V4_VALID > 0 
       OR PAYMENT_METHOD_CHECK_VALID > 0 OR ANEXOS_VALID > 0
       OR SAL_UNIT_MSR_STATUS > 0 OR INVNTRY_UOM_STATUS > 0
       /* OR SAL_UNIT_MSR_STATUS LIKE '%Missing%' -- Verifica si falta la unidad de medida
       OR SAL_UNIT_MSR_STATUS LIKE '%Invalid%' -- Verifica si la unidad es inválida
       OR INVNTRY_UOM_STATUS LIKE '%Missing%' -- Verifica si falta la unidad de inventario
       OR INVNTRY_UOM_STATUS LIKE '%Invalid%' -- Verifica si la unidad de inventario es inválida */
    THEN
       
       error := -100;
       error_message := N'Faltan campos por validar en el maestro socio negocio o en el maestro de artículos antes de crear la orden de compra o pedido.';
       RETURN;
    END IF;

END IF;


/* ***************************** */


-- Validaciones del maestro de artículos
    SELECT
        CASE 
            WHEN T0."SalUnitMsr" IS NULL OR T0."SalUnitMsr" = '' THEN 1 
            WHEN T0."SalUnitMsr" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT') THEN 2 
            ELSE 0 
        END AS SalUnitMsrCheck,

        CASE 
            WHEN T0."InvntryUom" IS NULL OR T0."InvntryUom" = '' THEN 1 
            WHEN T0."InvntryUom" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT') THEN 2 
            ELSE 0 
        END AS InvntryUomCheck

    INTO
        SAL_UNIT_MSR_VALID, INVNTRY_UOM_VALID
   
    FROM OITM T0
    WHERE T0."ItemCode" IN (
      SELECT "ItemCode"
      FROM OPOR WHERE "DocEntry" IN (:list_of_cols_val_tab_del)
    );



    /* ESTE POR PROBAR  */


    IF :object_type = '22' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

    -- Validar el socio de negocio y anexos
    SELECT
        MAX(CASE 
                WHEN T0."CardType" IN ('C', 'S', 'L') THEN 0 
                ELSE 1 
            END) AS BPExistsCheck,
        MAX(CASE 
                WHEN T0."CardName" IS NULL OR T0."CardName" = '' THEN 1 
                WHEN T0."CardName" NOT LIKE_REGEXPR '^[a-zA-Z .]+$' THEN 2
                WHEN LENGTH(T0."CardName") > 60 THEN 3
                ELSE 0 
            END) AS CardNameCheck,
        -- (otras validaciones de socio de negocio)
        MAX(CASE 
                WHEN T0."E_Mail" IS NULL OR T0."E_Mail" = '' THEN 1
                ELSE 0 
            END) AS EmailCheck,
        -- Validación de anexos (ATC1)
        MAX(CASE 
                WHEN NOT EXISTS (SELECT 1 FROM ATC1 T4 WHERE T4."AbsEntry" = T0."AtcEntry") THEN 1 
                ELSE 0 
            END) AS AnexosCheck,
        -- Validación de artículos (OITM)
        MAX(CASE 
                WHEN T6."SalUnitMsr" IS NULL OR T6."SalUnitMsr" = '' THEN 1 
                WHEN T6."SalUnitMsr" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT') THEN 2 
                ELSE 0 
            END) AS SalUnitMsrCheck,
        MAX(CASE 
                WHEN T6."InvntryUom" IS NULL OR T6."InvntryUom" = '' THEN 1 
                WHEN T6."InvntryUom" NOT IN ('XUN', 'KGM', 'PLIEGO', 'XBX', 'H87', 'ACT') THEN 2 
                ELSE 0 
            END) AS InvntryUomCheck
        
    INTO 
        BP_EXISTS, CARD_NAME_VALID, EMAIL_VALID, ANEXOS_VALID, 
        SAL_UNIT_MSR_VALID, INVNTRY_UOM_VALID
    FROM OCRD T0
    LEFT JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode"
    LEFT JOIN OCRY T2 ON T1."Country" = T2."Code"
    LEFT JOIN OPYM T3 ON T0."PymCode" = T3."PayMethCod"
    -- Validación de anexos
    --LEFT JOIN ATC1 T4 ON T0."AtcEntry" = T4."AbsEntry"
    -- Validación de artículos
    LEFT JOIN OITM T6 ON T6."ItemCode" IN (
        SELECT A1."ItemCode" 
        FROM OPOR A0
        INNER JOIN POR1 A1 ON A0."DocEntry" = A1."DocEntry"
        WHERE A0."DocEntry" IN (:list_of_cols_val_tab_del)
    )
    WHERE T0."CardCode" IN (
      SELECT "CardCode"
      FROM OPOR WHERE "DocEntry" IN (:list_of_cols_val_tab_del)
    );

    -- Asignar un error general si alguna validación falla
    IF BP_EXISTS > 0 OR CARD_NAME_VALID > 0 
        OR EMAIL_VALID > 0 OR ANEXOS_VALID > 0 
        OR SAL_UNIT_MSR_VALID > 0 OR INVNTRY_UOM_VALID > 0 THEN
        
        error = 40;
        error_message = 'Faltan campos por validar en el socio de negocio, anexos o en los artículos antes de crear la orden de compra.';
        RETURN;
    END IF;
END IF;

