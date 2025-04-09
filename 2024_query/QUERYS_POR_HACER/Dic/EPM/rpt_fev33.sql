SELECT * FROM "B1H_EPM_PROD"."vw_RPT_FEV33" T1 WHERE T1."DocEntry" = 393 AND T1."OBJTYPE" = 14 AND T1."SERIES" = 1456

/* original */

CREATE VIEW "B1H_EPM_PROD"."vw_RPT_FEV33" ( 
    "QRIMG",
    "DocEntry",
    "OBJTYPE",
    "SERIES",
    "tipo",
    "tipo2",
    "TipoComprobante",
    "CodigoCliente",
    "DocDate",
    "FechaVencimieno",
    "U_fe_sello",
    "LUGAREXPEDIDO",
    "U_fe_nocertificado",
    "U_fe_emisorRFC",
    "U_fe_emisornombre",
    "U_fe_emisorcalle",
    "U_fe_emisornoext",
    "U_fe_emisornoint",
    "Expr1",
    "U_fe_emisorcolonia",
    "U_fe_emisortelefono",
    "U_fe_emisortelefono2",
    "U_fe_emisorestado",
    "U_fe_emisormunicipio",
    "U_fe_emisorpais",
    "U_fe_emisorCP",
    "FolioPref",
    "FolioNum",
    "ItemCode",
    "Codigo Cliente",
    "BaseEntry",
    "BaseType",
    "Dscription",
    "U_fe_reccalle",
    "U_fe_reccalleS",
    "U_fe_reccolonia",
    "U_fe_reccoloniaS",
    "U_fe_recCP",
    "U_fe_recCPS",
    "U_fe_serie",
    "U_fe_recestado",
    "U_fe_recestadoS",
    "U_fe_recmunicipio",
    "U_fe_recmunicipioS",
    "U_fe_recnoext",
    "U_fe_recnoextS",
    "U_fe_recnombre",
    "U_fe_recpais",
    "U_fe_recpaisS",
    "DELEGACION",
    "DELEGACIONS",
    "U_fe_recRFC",
    "U_fe_rectelefono",
    "U_fe_reccontacto",
    "Quantity",
    "Price",
    "LineTotal",
    "DescuentoT",
    "DiscPrcnt",
    "TotalDoc",
    "Comentarios",
    "UseBaseUn",
    "IVA",
    "IEPS",
    "Hora",
    "ClaveProdServ",
    "SalUnitMsr",
    "SalPackMsr",
    "Regimen",
    "RegimenFiscalCliente",
    "FECHACREACION",
    "MetodoPago",
    "condicionesDePago",
    "SWeight1",
    "Vendedor",
    "Autor",
    "DocNum",
    "numatcard",
    "metododepago2",
    "SalUnitMsr2",
    "metododepago",
    "ImpLinea",
    "retencion",
    "cdecred",
    "linenum",
    "BaseLine",
    "VOLUMEN",
    "FECHAHORASAT",
    "UUID",
    "NOCERTIFICADO",
    "SELLOSAT",
    "CADENASAT",
    "CERTIFICADOSAT",
    "FECHAHORA",
    "VatGroup",
    "PriceAfVAT",
    "VatPrcnt",
    "GTotal",
    "UsoCFDI",
    "DescripcionUsoCFDI",
    "SelloQR",
    "Moneda",
    "RFCPROVCERTIF",
    "TipoCambio",
    "TIEPS",
    "TIVA",
    "subtotal",
    "total",
    "Iva2",
    "DescuentoDocto",
    "frgnname",
    "U_CEMTraslado",
    "U_CETOperacion",
    "U_CECDPedimento",
    "U_CECOrigen",
    "U_CENCOrigen",
    "U_CENEConfiable",
    "U_CEIncoterm",
    "U_CESubdivision",
    "U_CEObservaciones",
    "MotivoTraslado",
    "TipoOperacion",
    "Incoterm",
    "CertificadoOrigen",
    "Subdivision",
    "UnidadAduana",
    "FraccionArancelaria",
	"QRCodeSrc" ) AS ((
    (
        SELECT
            t3.qrimg,
            t0."DocEntry",
            t3.objtype,
            t3.series,
            'FACTURA' AS "tipo",
            'FACTURADO A' AS "tipo2",
            'I - Ingreso' AS "TipoComprobante",
            t0."CardCode" AS "CodigoCliente",
            t0."DocDate" AS "DocDate",
            t0."DocDueDate" AS "FechaVencimieno",
            t3.sello AS "U_fe_sello",
            t4.lugarexpedido,
            t3.nocertificado AS "U_fe_nocertificado",
            (SELECT "RevOffice" FROM oadm) AS "U_fe_emisorRFC",
            (SELECT "CompnyName" FROM oadm) AS "U_fe_emisornombre",
            (SELECT "Street" FROM ADM1) AS "U_fe_emisorcalle",
            (SELECT "StreetNo" FROM ADM1) AS "U_fe_emisornoext",
            '' AS "U_fe_emisornoint",
            (SELECT "Street" FROM ADM1) AS "Expr1",
            (SELECT "City" FROM ADM1) AS "U_fe_emisorcolonia",
            (Select "Phone1" FROM OADM) AS "U_fe_emisortelefono",
            (Select "Phone2" FROM OADM) AS "U_fe_emisortelefono2",
            (select "State" from OADM) AS "U_fe_emisorestado",
            (select "County" from ADM1) AS "U_fe_emisormunicipio",
            (select "Country" from OADM) AS "U_fe_emisorpais",
            (select "ZipCode" from ADM1) AS "U_fe_emisorCP",
            t0."FolioPref",
            t0."DocNum" AS "FolioNum",
            Case 
                ( select "QryGroup2" from ocrd where "CardCode"=t0."CardCode") when 'Y' then t1."FreeTxt" 
	            else t1."ItemCode" 
	        end as "ItemCode",
            t2."U_SYP_CODE_SKU" AS "Codigo Cliente",
            t1."BaseEntry",
            t1."BaseType",
            IFNULL(t2."FrgnName" || ' ' || t1."FreeTxt",
            t2."ItemName") AS "Dscription",
            ( SELECT "Street" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."PayToCode" and "AdresType"='B' ) AS "U_fe_reccalle",
            ( SELECT "Street" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."ShipToCode" and "AdresType"='S' ) AS "U_fe_reccalleS",
            ( SELECT "Block" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."PayToCode" and "AdresType"='B' ) AS "U_fe_reccolonia",
            ( SELECT "Block" FROM CRD1 WHERE "CardCode" = t0."CardCode"  AND "Address" = T0."ShipToCode"  and "AdresType"='S' ) AS "U_fe_reccoloniaS",
            ( SELECT "ZipCode" FROM CRD1 WHERE "CardCode" = t0."CardCode"  AND "Address" = T0."PayToCode"  and "AdresType"='B' ) AS "U_fe_recCP",
            ( SELECT "ZipCode" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."ShipToCode"  and "AdresType"='S' ) AS "U_fe_recCPS",
	        t3.serie AS "U_fe_serie",
            ( SELECT "State" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."PayToCode" and "AdresType"='B' ) AS "U_fe_recestado",
            ( SELECT "State" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."ShipToCode" and "AdresType"='S' ) AS "U_fe_recestadoS",
            ( SELECT"City" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."PayToCode" and "AdresType"='B' ) AS "U_fe_recmunicipio",
            ( SELECT "City" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."ShipToCode" and "AdresType"='S' ) AS "U_fe_recmunicipioS",
            (SELECT "StreetNo" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."PayToCode" and "AdresType"='B' ) AS "U_fe_recnoext",
            (SELECT "StreetNo" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."ShipToCode" and "AdresType"='S' ) AS "U_fe_recnoextS",
            t0."CardName" AS "U_fe_recnombre",
	        ( SELECT "Country" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."PayToCode" and "AdresType"='B' ) AS "U_fe_recpais",
            ( SELECT "Country" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."ShipToCode" and "AdresType"='S' ) AS "U_fe_recpaisS",
            ( SELECT "County" FROM CRD1 WHERE "CardCode" = T0."CardCode" AND "Address" = T0."PayToCode" and "AdresType"='B' ) AS "DELEGACION",
            ( SELECT "County" FROM CRD1 WHERE "CardCode" = T0."CardCode" AND "Address" = T0."ShipToCode" and "AdresType"='S' ) AS "DELEGACIONS",
            ( SELECT "LicTradNum" FROM ocrd WHERE t0."CardCode" = "CardCode") AS "U_fe_recRFC",
            ( SELECT "Phone1" FrOM OCRD where t0."CardCode" = "CardCode" ) as "U_fe_rectelefono",
            ( SELECT "CntctPrsn" FrOM OCRD where t0."CardCode" = "CardCode" ) as "U_fe_reccontacto",
            (
                CASE 
                    IFNULL(t1."Quantity", 0) WHEN 0 THEN 1 
                    ELSE t1."Quantity" 
                END
            ) AS "Quantity",
            t1."Price",
            t1."Quantity" * t1."Price" AS "LineTotal",
            t1."Price" * (t1."DiscPrcnt" / 100) AS "DescuentoT",
            t1."DiscPrcnt",
            CASE 
                t0."DocCur" WHEN 'MXP' THEN t0."DocTotal" 
                WHEN 'USD' THEN t0."DocTotalFC"
                WHEN 'EUR' THEN t0."DocTotalFC"
                END AS "TotalDoc",
            t0."Comments" as "Comentarios",
            t1."UseBaseUn" as "UseBaseUn",
	        CASE 
                t0."DocCur" WHEN 'MXP' 
			    THEN ifnull(( select sum("TaxSum") from INV4 where "DocEntry"=t0."DocEntry" and "staType" <> '6'), 0) when 'USD' 
			    THEN ifnull(( select sum("TaxSumFrgn") from INV4 where "DocEntry"=t0."DocEntry" and "staType" <> '6'),0) when 'EUR' 
			    THEN ifnull(( select sum("TaxSumFrgn") from INV4 where "DocEntry"=t0."DocEntry" and "staType" <> '6'),0) 
			END AS "IVA" 
            /* 
			THEN t0."VatSum" WHEN 'USD' 
			THEN t0."VatSumFC" WHEN 'EUR' 
			THEN t0."VatSumFC" 
			END AS "IVA" */,
	        Case 
                t0."DocCur" when 'MXP' THEN ifnull(( select sum("TaxSum") from INV4 where "DocEntry"=t0."DocEntry" and "staType"='6'), 0) when 'USD' 
			    THEN ifnull(( select sum("TaxSumFrgn") from INV4 where "DocEntry"=t0."DocEntry" and "staType"='6'), 0) when 'EUR' 
			    THEN ifnull(( select sum("TaxSumFrgn") from INV4 where "DocEntry"=t0."DocEntry" and "staType"='6'), 0) 
			END AS "IEPS",
	        t0."DocTime" AS "Hora",
            IFNULL(( select "NcmCode" from ONCM where "AbsEntry"=t1."NCMCode"),'01010101' ) AS "ClaveProdServ",
	        ( SELECT c_ClaveUnidad FROM fe_SAT_c_ClaveUnidad WHERE c_ClaveUnidad = t1."UomCode" ) AS "SalUnitMsr",
	        ( SELECT nombre FROM fe_SAT_c_ClaveUnidad WHERE c_ClaveUnidad = t1."UomCode" ) AS "SalPackMsr",
	        ( SELECT "TaxRegime" FROM OADM) || ' ' || (
                SELECT descripcion FROM fe_SAT_c_RegimenFiscal WHERE c_RegimenFiscal = (
                    SELECT "TaxRegime" FROM OADM)
            ) AS "Regimen",
            ( select "U_SYP_FPAGO" from ocrd where "CardCode"=t0."CardCode")|| ' ' || (
                select descripcion from fe_sat_c_regimenfiscal where c_regimenfiscal=(
                    select "U_SYP_FPAGO" from ocrd where "CardCode"=t0."CardCode")
            ) as "RegimenFiscalCliente",
	        t3.fechacreacion,
	        cast(
                case(
                    ifnull(t0."PeyMethod",'')) when '99' 
				    then 'PPD - Pago en parcialidades o diferido' 
				    else 'PUE - Pago en una sola exhibición' 
				end as varchar(100)
            ) AS "MetodoPago",
            (SELECT ta."PymntGroup" FROM octg ta WHERE t0."GroupNum" = ta."GroupNum") AS "condicionesDePago",
            t2."SWeight1",
            ( SELECT "SlpName" FROM oslp WHERE "SlpCode" = t0."SlpCode") AS "Vendedor",
            ( SELECT "U_NAME" FROM ousr WHERE T0."UserSign" = INTERNAL_K) AS "Autor",
            t0."DocNum",
            t0."NumAtCard" as "numatcard",
            '99' AS "metododepago2",
            IFNULL(t1."UomCode",'NA') AS "SalUnitMsr2",
	        (select "PayMethCod"||'-'||"Descript" from opym where "PayMethCod"=t0."PeyMethod") AS "metododepago",
	         --	 '99 Por Definir' AS "metododepago",
            t1."VatSum" AS "ImpLinea",
	        T0."WTSum" AS "retencion",
	        (SELECT "PymntGroup" FROM octg WHERE "GroupNum" = t0."GroupNum") AS "cdecred",
            t1."LineNum" AS "linenum",
            t1."BaseLine",
            (t2."SalPackUn" * t1."Quantity" * "SVolume") / 1000000 AS Volumen,
            t3.fechahorasat,
            t3.uuid,
            t3.nocertificado,
            T3.sellosat,
            T3.cadenasat,
            T3.CERTIFICADOSAT,
            t3.fechahora,
            t1."VatGroup",
            t1."PriceAfVAT",
            t1."VatPrcnt",
            CASE 
                t1."Currency" WHEN 'MXP' 
                THEN t1."GTotal" WHEN 'USD' 
                THEN t1."GTotalFC" WHEN 'EUR' 
                THEN t1."GTotalFC" 
            END AS "GTotal",
	        t0."U_B1SYS_MainUsage" AS "UsoCFDI",
            ( SELECT Descripcion FROM fe_SAT_c_UsoCFDI WHERE c_UsoCFDI = t0."U_B1SYS_MainUsage" ) AS "DescripcionUsoCFDI", 
            substring(t3.sello,(LENGTH(t3.sello) - 7),8) AS "SelloQR",
            t0."DocCur" AS "Moneda",
            t3.rfcprovcertif,
            t0."DocRate" AS "TipoCambio",
            (SELECT SUM("TaxSum") FROM inv4 WHERE "DocEntry" = t0."DocEntry" AND (
                            SELECT "U_c_Impuestos" FROM "@SAT_C_IMPUESTOS" WHERE "Code" = "StaCode") = '003'
            ) AS "TIEPS",
            (SELECT SUM("TaxSum") FROM inv4 WHERE "DocEntry" = t0."DocEntry" AND (
                            SELECT "U_c_Impuestos" FROM "@SAT_C_IMPUESTOS" WHERE "Code" = "StaCode") = '002'
            ) AS "TIVA",
            (select subtotal from fe_api_encabezado where docentry=t0."DocEntry" and objtype=t0."ObjType") as "subtotal",
            (select total from fe_api_encabezado where docentry=t0."DocEntry" and objtype=t0."ObjType") as "total",
            (select sum(importe) from fe_api_impuestos where docentry=t0."DocEntry" and objtype=t0."ObjType") as "Iva2",
            IFNULL((SELECT
            CASE t0."DocCur" WHEN 'MXP' 
                            THEN IFNULL(t0."DiscSum",
            0) + IFNULL(t0."DpmAmnt",
            0) 
                            ELSE IFNULL(t0."DiscSumFC",
            0) + IFNULL(t0."DpmAmntFC",
            0) 
                            END 
                            FROM DUMMY),
	 0) AS "DescuentoDocto",
	 t2."FrgnName" as "frgnname",
	 t0."U_DXT_CCE_MotivoTraslado" as "U_CEMTraslado",
	 t0."U_DXT_CCE_TipoOperacion" as "U_CETOperacion",
	 t0."U_ClavePedimento" as "U_CECDPedimento",
	 t0."U_DXT_CCE_CeritifcadoOrigen" as "U_CECOrigen",
	 ifnull(t0."U_DXT_CCE_NumCertificadoOrigen",
	 '') as "U_CENCOrigen",
	 ifnull(t0."U_DXT_CCE_NumExportadorConfiable",
	 '') as "U_CENEConfiable",
	 ifnull(t0."U_DXT_CCE_Incoterm",
	 '') as "U_CEIncoterm",
	 ifnull(t0."U_SubDivision",
	 '') as "U_CESubdivision",
	 t0."U_CEObservaciones" as "U_CEObservaciones",
	 (SELECT
	 descripcion 
				FROM fe_SAT_c_MotivoTraslado 
				WHERE c_MotivoTraslado = t0."U_DXT_CCE_MotivoTraslado") AS "MotivoTraslado",
	 (SELECT
	 descripcion 
				FROM fe_SAT_c_TipoOperacion 
				WHERE c_TipoOperacion = t0."U_DXT_CCE_TipoOperacion") AS "TipoOperacion",
	 (SELECT
	 descripcion 
				FROM fe_SAT_c_INCOTERM 
				WHERE c_INCOTERM = ifnull(t0."U_DXT_CCE_Incoterm",
	 '')) AS "Incoterm",
	 (CASE t0."U_DXT_CCE_CeritifcadoOrigen" WHEN '0' 
				THEN 'No Funje' WHEN '1' 
				THEN 'Funje' 
				END) AS "CertificadoOrigen",
	 (CASE ifnull(t0."U_SubDivision",
	 '') WHEN '0' 
				THEN 'No Tiene División' WHEN '1' 
				THEN 'Si tiene División' 
				END) AS "Subdivision",
	 t1."U_UnidadAduana" AS "UnidadAduana",
	 t1."U_FraccionArancel" AS "FraccionArancelaria",
	 (select
	 "FileContnt" 
				from oqrc 
				where "SrcObjAbs"=t0."DocEntry" 
				and "SrcObjType"=13) as "QRCodeSrc" --t1."U_UVta" AS "UnidadFlex",
 --t1."U_PrecioVenta" AS "PrecioFlex",
 /*UnidadCFDI(T1."U_TipoUnidad",
	 T1."ItemCode") AS "ClaveUnidadFlex",
	 DescripCFDI(T1."U_TipoUnidad",
	 T1."ItemCode") AS "NombreUnidadFlex" */ 
			FROM OINV t0 
			INNER JOIN INV1 t1 ON t0."DocEntry" = t1."DocEntry" 
			INNER JOIN OITM t2 ON t1."ItemCode" = t2."ItemCode" 
			INNER JOIN fe_control T3 ON T0."DocEntry" = t3.docentry 
			INNER JOIN fe_seriescontrol t4 ON t0."Series" = t4.series 
			INNER JOIN fe_certificados t5 ON t5.id = t4.nocertificado 
			AND t3.objtype = 13 
			WHERE t1."UseBaseUn"='N') 
UNION ALL (
        SELECT
            TOP 100 
            t3.qrimg,
            t0."DocEntry",
            t3.objtype,
            t3.series,
            'NOTA DE CREDITO' AS "tipo",
            'FACTURADO A' AS "tipo2",
            'E - Egreso' AS "TipoComprobante",
            t0."CardCode" AS "CodigoCliente",
            t0."DocDate" AS "DocDate",
            t0."DocDueDate" AS "FechaVencimieno",
            t3.sello AS "U_fe_sello",
            t4.lugarexpedido,
            t3.nocertificado AS "U_fe_nocertificado",
            (SELECT "RevOffice" FROM oadm) AS "U_fe_emisorRFC",
            (SELECT "CompnyName" FROM oadm) AS "U_fe_emisornombre",
            (SELECT "Street" FROM ADM1) AS "U_fe_emisorcalle",
            (SELECT "StreetNo" FROM ADM1) AS "U_fe_emisornoext",
            '' AS "U_fe_emisornoint",
            (SELECT "Street" FROM ADM1) AS "Expr1",
            (SELECT "Block" FROM ADM1) AS "U_fe_emisorcolonia",
            (Select "Phone1" FROM OADM) AS "U_fe_emisortelefono",
            (Select "Phone2" FROM OADM) AS "U_fe_emisortelefono2",
            t4.estado AS "U_fe_emisorestado",
            t4.municipio AS "U_fe_emisormunicipio",
            t4.pais AS "U_fe_emisorpais",
            t4.cp AS "U_fe_emisorCP",
            t0."FolioPref",
            t0."DocNum" AS "FolioNum",
            Case 
                (select "QryGroup2" from ocrd where "CardCode"=t0."CardCode") when 'Y' 
                then t1."FreeTxt" 
                else t1."ItemCode" 
                end as "ItemCode",
            T2."U_SYP_CODE_SKU" AS "Codigo Cliente",
            t1."BaseEntry",
            t1."BaseType",
            IFNULL(t2."FrgnName" || ' ' || t1."FreeTxt",t2."ItemName") AS "Dscription",
            (SELECT "Street" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."PayToCode" and "AdresType"='B') AS "U_fe_reccalle",
            (SELECT "Street" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."ShipToCode" and "AdresType"='S') AS "U_fe_reccalleS",
            (SELECT "Block" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."PayToCode" and "AdresType"='B') AS "U_fe_reccolonia",
            (SELECT "Block" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."ShipToCode" and "AdresType"='S') AS "U_fe_reccoloniaS",
            (SELECT "ZipCode" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."PayToCode" and "AdresType"='B') AS "U_fe_recCP",
            (SELECT "ZipCode" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."ShipToCode" and "AdresType"='S') AS "U_fe_recCPS",
            t3.serie AS "U_fe_serie",
            (SELECT "State" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."PayToCode" and "AdresType"='B') AS "U_fe_recestado",
            (SELECT "State" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."ShipToCode" and "AdresType"='S') AS "U_fe_recestadoS",
            (SELECT "City" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."PayToCode" and "AdresType"='B') AS "U_fe_recmunicipio",
            (SELECT "City" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."ShipToCode" and "AdresType"='S') AS "U_fe_recmunicipioS",
            (SELECT "StreetNo" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."PayToCode" and "AdresType"='B') AS "U_fe_recnoext",
            (SELECT "StreetNo" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."ShipToCode" and "AdresType"='S') AS "U_fe_recnoextS",
            t0."CardName" AS "U_fe_recnombre",
            (SELECT "Country" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."PayToCode" and "AdresType"='B') AS "U_fe_recpais",
            (SELECT "Country" FROM CRD1 WHERE "CardCode" = t0."CardCode" AND "Address" = T0."ShipToCode" and "AdresType"='S') AS "U_fe_recpaisS",
            (SELECT "County" FROM CRD1 WHERE "CardCode" = T0."CardCode" AND "Address" = T0."PayToCode" and "AdresType"='B') AS "DELEGACION",
            (SELECT "County" FROM CRD1 WHERE "CardCode" = T0."CardCode" AND "Address" = T0."ShipToCode" and "AdresType"='S') AS "DELEGACIONS",
            (SELECT "LicTradNum" FROM ocrd WHERE t0."CardCode" = "CardCode") AS "U_fe_recRFC",
            (SELECT "Phone1" FrOM OCRD where t0."CardCode" = "CardCode") as "U_fe_rectelefono",
            (SELECT "CntctPrsn" FrOM OCRD where t0."CardCode" = "CardCode") as "U_fe_reccontacto",
            (
                CASE 
                    IFNULL(t1."Quantity", 0) WHEN 0 THEN 1 
                    ELSE t1."Quantity" 
                END
            ) AS "Quantity",
            t1."Price",
            t1."Quantity" * t1."Price" AS "LineTotal",
            t1."Price" * (t1."DiscPrcnt" / 100) AS "DescuentoT",
            t1."DiscPrcnt",
            CASE 
                t0."DocCur" WHEN 'MXP' 
                THEN t0."DocTotal" WHEN 'USD' 
                THEN t0."DocTotalFC" WHEN 'EUR' 
                THEN t0."DocTotalFC" 
            END AS "TotalDoc",
            t0."Comments" as "Comentarios",
            t1."UseBaseUn" as "UseBaseUn",
            CASE t0."DocCur" WHEN 'MXP' 
                THEN ifnull((select sum("TaxSum") from RIN4 where "DocEntry"=t0."DocEntry" and "staType" <> '6'), 0) when 'USD' 
                THEN ifnull((select sum("TaxSumFrgn") from RIN4 where "DocEntry"=t0."DocEntry" and "staType" <> '6'),0) when 'EUR' 
                THEN ifnull((select sum("TaxSumFrgn") from RIN4 where "DocEntry"=t0."DocEntry" and "staType" <> '6'), 0) 
            END AS "IVA" /* 
            THEN t0."VatSum" WHEN 'USD' 
            THEN t0."VatSumFC" WHEN 'EUR' 
            THEN t0."VatSumFC" 
            END AS "IVA"*/,
            Case 
                t0."DocCur" when 'MXP' 
                THEN ifnull((select sum("TaxSum") from RIN4 where "DocEntry"=t0."DocEntry" and "staType"='6'),0) when 'USD' 
                THEN ifnull((select sum("TaxSumFrgn") from RIN4 where "DocEntry"=t0."DocEntry" and "staType"='6'),0) when 'EUR' 
                THEN ifnull((select sum("TaxSumFrgn") from RIN4 where "DocEntry"=t0."DocEntry" and "staType"='6'),0) 
            END AS "IEPS",
            t0."DocTime" AS "Hora",
            IFNULL((select "NcmCode" from ONCM where "AbsEntry"=t1."NCMCode"),'01010101') AS "ClaveProdServ",
            (SELECT c_ClaveUnidad 
                        FROM fe_SAT_c_ClaveUnidad 
                        WHERE c_ClaveUnidad = t1."UomCode") AS "SalUnitMsr",
            (SELECT nombre FROM fe_SAT_c_ClaveUnidad WHERE c_ClaveUnidad = t1."UomCode") AS "SalPackMsr",
            (SELECT "TaxRegime" FROM OADM) || ' ' || (
                SELECT descripcion FROM fe_SAT_c_RegimenFiscal WHERE c_RegimenFiscal = (SELECT "TaxRegime" FROM OADM)
            ) AS "Regimen",
            (select "U_SYP_FPAGO" from ocrd where "CardCode"=t0."CardCode")|| ' ' || (
                select descripcion from fe_sat_c_regimenfiscal where c_regimenfiscal=(
                    select "U_SYP_FPAGO" from ocrd where "CardCode"=t0."CardCode")
            ) as "RegimenFiscalCliente",
            t3.fechacreacion,
	        cast(
                case
                    (ifnull(t0."PeyMethod",'')) when '99' then 'PPD - Pago en parcialidades o diferido' 
				    else 'PUE - Pago en una sola exhibición' 
				end as varchar(100)
            ) AS "MetodoPago",
            (SELECT ta."PymntGroup" FROM octg ta WHERE t0."GroupNum" = ta."GroupNum") AS "condicionesDePago",
            t2."SWeight1",
            (SELECT "SlpName" FROM oslp WHERE "SlpCode" = t0."SlpCode") AS "Vendedor",
	        (SELECT "U_NAME" FROM ousr WHERE T0."UserSign" = INTERNAL_K) AS "Autor",
            t0."DocNum",
            t0."NumAtCard" as "numatcard",
            '99' AS "metododepago2",
            IFNULL(t1."UomCode",'NA') AS "SalUnitMsr2",
            (select "PayMethCod"||'-'||"Descript" from opym where "PayMethCod"=t0."PeyMethod") AS "metododepago",
            t1."VatSum" AS "ImpLinea",
            T0."WTSum" AS "retencion",
            (SELECT "PymntGroup" FROM octg WHERE "GroupNum" = t0."GroupNum") AS "cdecred",
            t1."LineNum" AS "linenum",
            t1."BaseLine",
            (t2."SalPackUn" * t1."Quantity" * "SVolume") / 1000000 AS Volumen,
            t3.fechahorasat,
            t3.uuid,
            t3.nocertificado,
            T3.sellosat,
            T3.cadenasat,
            T3.CERTIFICADOSAT,
            t3.fechahora,
            t1."VatGroup",
            t1."PriceAfVAT",
            t1."VatPrcnt",
            CASE t1."Currency" WHEN 'MXP' 
                    THEN t1."GTotal" WHEN 'USD' 
                    THEN t1."GTotalFC" WHEN 'EUR' 
                    THEN t1."GTotalFC" 
                    END AS "GTotal",
            'G02' AS "UsoCFDI",
            (SELECT
            Descripcion 
                        FROM fe_SAT_c_UsoCFDI 
                        WHERE c_UsoCFDI = 'G02') AS "DescripcionUsoCFDI",
            substring(t3.sello,
            (LENGTH(t3.sello) - 7),
            8) AS "SelloQR",
            t0."DocCur" AS "Moneda",
            t3.rfcprovcertif,
            t0."DocRate" AS "TipoCambio",
            (SELECT
            SUM("TaxSum") 
                        FROM RIN4 
                        WHERE "DocEntry" = t0."DocEntry" 
                        AND (SELECT
            "U_c_Impuestos" 
                            FROM "@SAT_C_IMPUESTOS" 
                            WHERE "Code" = "StaCode") = '003') AS "TIEPS",
            (SELECT
            SUM("TaxSum") 
                        FROM RIN4 
                        WHERE "DocEntry" = t0."DocEntry" 
                        AND (SELECT
            "U_c_Impuestos" 
                            FROM "@SAT_C_IMPUESTOS" 
                            WHERE "Code" = "StaCode") = '002') AS "TIVA",
            (select
            subtotal 
                        from fe_api_encabezado 
                        where docentry=t0."DocEntry" 
                        and objtype=t0."ObjType") as "subtotal",
            (select
            total 
                        from fe_api_encabezado 
                        where docentry=t0."DocEntry" 
                        and objtype=t0."ObjType") as "total",
            (select
            sum(importe) 
                        from fe_api_impuestos 
                        where docentry=t0."DocEntry" 
                        and objtype=t0."ObjType") as "Iva2",
            IFNULL((SELECT
            CASE t0."DocCur" WHEN 'MXP' 
                            THEN IFNULL(t0."DiscSum",
            0) + IFNULL(t0."DpmAmnt",
            0) 
                            ELSE IFNULL(t0."DiscSumFC",
            0) + IFNULL(t0."DpmAmntFC",
            0) 
                            END 
                            FROM DUMMY),0) AS "DescuentoDocto",
            t2."FrgnName" as "frgnname",
            t0."U_DXT_CCE_MotivoTraslado" as "U_CEMTraslado",
            t0."U_DXT_CCE_TipoOperacion" as "U_CETOperacion",
            t0."U_ClavePedimento" as "U_CECDPedimento",
            t0."U_DXT_CCE_CeritifcadoOrigen" as "U_CECOrigen",
            ifnull(t0."U_DXT_CCE_NumCertificadoOrigen",'') as "U_CENCOrigen",
            ifnull(t0."U_DXT_CCE_NumExportadorConfiable",'') as "U_CENEConfiable",
            ifnull(t0."U_DXT_CCE_Incoterm",'') as "U_CEIncoterm",
            ifnull(t0."U_SubDivision",'') as "U_CESubdivision",
            t0."U_CEObservaciones" as "U_CEObservaciones",
            (SELECT descripcion FROM fe_SAT_c_MotivoTraslado WHERE c_MotivoTraslado = t0."U_DXT_CCE_MotivoTraslado") AS "MotivoTraslado",
            (SELECT descripcion FROM fe_SAT_c_TipoOperacion WHERE c_TipoOperacion = t0."U_DXT_CCE_TipoOperacion") AS "TipoOperacion",
            (SELECT descripcion FROM fe_SAT_c_INCOTERM WHERE c_INCOTERM = ifnull(t0."U_DXT_CCE_Incoterm",'')) AS "Incoterm",
            (
                CASE 
                    t0."U_DXT_CCE_CeritifcadoOrigen" WHEN '0' 
                    THEN 'No Funje' WHEN '1' 
                    THEN 'Funje' 
                END) AS "CertificadoOrigen",
            (
                CASE 
                    ifnull(t0."U_SubDivision",'') WHEN '0' 
                    THEN 'No Tiene División' WHEN '1' 
                    THEN 'Si tiene División' 
                END) AS "Subdivision",
            t1."U_UnidadAduana" AS "UnidadAduana",
            t1."U_FraccionArancel" AS "FraccionArancelaria",
            (select "FileContnt" from oqrc where "SrcObjAbs"=t0."DocEntry" and "SrcObjType"=14) as "QRCodeSrc" 
                --t1."U_UVta" AS "UnidadFlex",
 --t1."U_PrecioVenta" AS "PrecioFlex",
 /*UnidadCFDI(T1."U_TipoUnidad",
	 T1."ItemCode") AS "ClaveUnidadFlex",
	 DescripCFDI(T1."U_TipoUnidad",
	 T1."ItemCode") AS "NombreUnidadFlex" */ 
			FROM ORIN t0 
			INNER JOIN RIN1 t1 ON t0."DocEntry" = t1."DocEntry" 
			INNER JOIN OITM t2 ON t1."ItemCode" = t2."ItemCode" 
			INNER JOIN fe_control T3 ON T0."DocEntry" = t3.docentry 
			INNER JOIN fe_seriescontrol t4 ON t0."Series" = t4.series 
			INNER JOIN fe_certificados t5 ON t5.id = t4.nocertificado 
			AND t3.objtype = 14 
			WHERE t1."UseBaseUn"='N')) 



	UNION ALL (SELECT
	 TOP 100 t3.qrimg,
	 t0."DocEntry",
	 t3.objtype,
	 t3.series,
	 'FACTURA' AS "tipo",
	 'FACTURADO A' AS "tipo2",
	 'I - Ingreso' AS "TipoComprobante",
	 t0."CardCode" AS "CodigoCliente",
	 t0."DocDate" AS "DocDate",
	 t0."DocDueDate" AS "FechaVencimieno",
	 t3.sello AS "U_fe_sello",
	 t4.lugarexpedido,
	 t3.nocertificado AS "U_fe_nocertificado",
	 (SELECT
	 "RevOffice" 
			FROM oadm) AS "U_fe_emisorRFC",
	 (SELECT
	 "CompnyName" 
			FROM oadm) AS "U_fe_emisornombre",
	 (SELECT
	 "Street" 
			FROM ADM1) AS "U_fe_emisorcalle",
	 (SELECT
	 "StreetNo" 
			FROM ADM1) AS "U_fe_emisornoext",
	 '' AS "U_fe_emisornoint",
	 (SELECT
	 "Street" 
			FROM ADM1) AS "Expr1",
	 (SELECT
	 "Block" 
			FROM ADM1) AS "U_fe_emisorcolonia",
	 (Select
	 "Phone1" 
			FROM OADM) AS "U_fe_emisortelefono",
	 (Select
	 "Phone2" 
			FROM OADM) AS "U_fe_emisortelefono2",
	 t4.estado AS "U_fe_emisorestado",
	 t4.municipio AS "U_fe_emisormunicipio",
	 t4.pais AS "U_fe_emisorpais",
	 t4.cp AS "U_fe_emisorCP",
	 t0."FolioPref",
	 t0."DocNum" AS "FolioNum",
	 Case (select
	 "QryGroup2" 
			from ocrd 
			where "CardCode"=t0."CardCode") when 'Y' 
		then t1."FreeTxt" 
		else t1."ItemCode" 
		end as "ItemCode",
	 T2."U_SYP_CODE_SKU" AS "Codigo Cliente",
	 t1."BaseEntry",
	 t1."BaseType",
	 IFNULL(t2."FrgnName" || ' ' || t1."FreeTxt",
	 t2."ItemName") AS "Dscription",
	 (SELECT
	 "Street" 
			FROM CRD1 
			WHERE "CardCode" = t0."CardCode" 
			AND "Address" = T0."PayToCode" 
			and "AdresType"='B') AS "U_fe_reccalle",
	 (SELECT
	 "Street" 
			FROM CRD1 
			WHERE "CardCode" = t0."CardCode" 
			AND "Address" = T0."ShipToCode" 
			and "AdresType"='S') AS "U_fe_reccalleS",
	 (SELECT
	 "Block" 
			FROM CRD1 
			WHERE "CardCode" = t0."CardCode" 
			AND "Address" = T0."PayToCode" 
			and "AdresType"='B') AS "U_fe_reccolonia",
	 (SELECT
	 "Block" 
			FROM CRD1 
			WHERE "CardCode" = t0."CardCode" 
			AND "Address" = T0."ShipToCode" 
			and "AdresType"='S') AS "U_fe_reccoloniaS",
	 (SELECT
	 "ZipCode" 
			FROM CRD1 
			WHERE "CardCode" = t0."CardCode" 
			AND "Address" = T0."PayToCode" 
			and "AdresType"='B') AS "U_fe_recCP",
	 (SELECT
	 "ZipCode" 
			FROM CRD1 
			WHERE "CardCode" = t0."CardCode" 
			AND "Address" = T0."ShipToCode" 
			and "AdresType"='S') AS "U_fe_recCPS",
	 t3.serie AS "U_fe_serie",
	 (SELECT
	 "State" 
			FROM CRD1 
			WHERE "CardCode" = t0."CardCode" 
			AND "Address" = T0."PayToCode" 
			and "AdresType"='B') AS "U_fe_recestado",
	 (SELECT
	 "State" 
			FROM CRD1 
			WHERE "CardCode" = t0."CardCode" 
			AND "Address" = T0."ShipToCode" 
			and "AdresType"='S') AS "U_fe_recestadoS",
	 (SELECT
	 "City" 
			FROM CRD1 
			WHERE "CardCode" = t0."CardCode" 
			AND "Address" = T0."PayToCode" 
			and "AdresType"='B') AS "U_fe_recmunicipio",
	 (SELECT
	 "City" 
			FROM CRD1 
			WHERE "CardCode" = t0."CardCode" 
			AND "Address" = T0."ShipToCode" 
			and "AdresType"='S') AS "U_fe_recmunicipioS",
	 (SELECT
	 "StreetNo" 
			FROM CRD1 
			WHERE "CardCode" = t0."CardCode" 
			AND "Address" = T0."PayToCode" 
			and "AdresType"='B') AS "U_fe_recnoext",
	 (SELECT
	 "StreetNo" 
			FROM CRD1 
			WHERE "CardCode" = t0."CardCode" 
			AND "Address" = T0."ShipToCode" 
			and "AdresType"='S') AS "U_fe_recnoextS",
	 t0."CardName" AS "U_fe_recnombre",
	 (SELECT
	 "Country" 
			FROM CRD1 
			WHERE "CardCode" = t0."CardCode" 
			AND "Address" = T0."PayToCode" 
			and "AdresType"='B') AS "U_fe_recpais",
	 (SELECT
	 "Country" 
			FROM CRD1 
			WHERE "CardCode" = t0."CardCode" 
			AND "Address" = T0."ShipToCode" 
			and "AdresType"='S') AS "U_fe_recpaisS",
	 (SELECT
	 "County" 
			FROM CRD1 
			WHERE "CardCode" = T0."CardCode" 
			AND "Address" = T0."PayToCode" 
			and "AdresType"='B') AS "DELEGACION",
	 (SELECT
	 "County" 
			FROM CRD1 
			WHERE "CardCode" = T0."CardCode" 
			AND "Address" = T0."ShipToCode" 
			and "AdresType"='S') AS "DELEGACIONS",
	 (SELECT
	 "LicTradNum" 
			FROM ocrd 
			WHERE t0."CardCode" = "CardCode") AS "U_fe_recRFC",
	 (SELECT
	 "Phone1" 
			FrOM OCRD 
			where t0."CardCode" = "CardCode") as "U_fe_rectelefono",
	 (SELECT
	 "CntctPrsn" 
			FrOM OCRD 
			where t0."CardCode" = "CardCode") as "U_fe_reccontacto",
	 (CASE IFNULL(t1."Quantity",
	 0) WHEN 0 
			THEN 1 
			ELSE t1."Quantity" 
			END) AS "Quantity",
	 t1."Price",
	 t1."Quantity" * t1."Price" AS "LineTotal",
	 t1."Price" * (t1."DiscPrcnt" / 100) AS "DescuentoT",
	 t1."DiscPrcnt",
	 CASE t0."DocCur" WHEN 'MXP' 
		THEN t0."DocTotal" WHEN 'USD' 
		THEN t0."DocTotalFC" WHEN 'EUR' 
		THEN t0."DocTotalFC" 
		END AS "TotalDoc",
	 t0."Comments" as "Comentarios",
	 t1."UseBaseUn" as "UseBaseUn",
	 CASE t0."DocCur" WHEN 'MXP' 
		THEN ifnull((select
	 sum("TaxSum") 
				from INV4 
				where "DocEntry"=t0."DocEntry" 
				and "staType" <> '6'),
	 0) when 'USD' 
		THEN ifnull((select
	 sum("TaxSumFrgn") 
				from DPI4 
				where "DocEntry"=t0."DocEntry" 
				and "staType" <> '6'),
	 0) when 'EUR' 
		THEN ifnull((select
	 sum("TaxSumFrgn") 
				from DPI4 
				where "DocEntry"=t0."DocEntry" 
				and "staType" <> '6'),
	 0) 
		END AS "IVA" /* 
		THEN t0."VatSum" WHEN 'USD' 
		THEN t0."VatSumFC" WHEN 'EUR' 
		THEN t0."VatSumFC" 
		END AS "IVA"*/,
	 Case t0."DocCur" when 'MXP' 
		THEN ifnull((select
	 sum("TaxSum") 
				from DPI4 
				where "DocEntry"=t0."DocEntry" 
				and "staType"='6'),
	 0) when 'USD' 
		THEN ifnull((select
	 sum("TaxSumFrgn") 
				from DPI4 
				where "DocEntry"=t0."DocEntry" 
				and "staType"='6'),
	 0) when 'EUR' 
		THEN ifnull((select
	 sum("TaxSumFrgn") 
				from DPI4 
				where "DocEntry"=t0."DocEntry" 
				and "staType"='6'),
	 0) 
		END AS "IEPS",
	 t0."DocTime" AS "Hora",
	 IFNULL((select
	 "NcmCode" 
				from ONCM 
				where "AbsEntry"=t1."NCMCode"),
	 '01010101') AS "ClaveProdServ",
	 (SELECT
	 c_ClaveUnidad 
			FROM fe_SAT_c_ClaveUnidad 
			WHERE c_ClaveUnidad = t1."UomCode") AS "SalUnitMsr",
	 (SELECT
	 nombre 
			FROM fe_SAT_c_ClaveUnidad 
			WHERE c_ClaveUnidad = t1."UomCode") AS "SalPackMsr",
	 (SELECT
	 "TaxRegime" 
			FROM OADM) || ' ' || (SELECT
	 descripcion 
			FROM fe_SAT_c_RegimenFiscal 
			WHERE c_RegimenFiscal = (SELECT
	 "TaxRegime" 
				FROM OADM)) AS "Regimen",
	 (select
	 "U_SYP_FPAGO" 
			from ocrd 
			where "CardCode"=t0."CardCode")|| ' ' || (select
	 descripcion 
			from fe_sat_c_regimenfiscal 
			where c_regimenfiscal=(select
	 "U_SYP_FPAGO" 
				from ocrd 
				where "CardCode"=t0."CardCode")) as "RegimenFiscalCliente",
	 t3.fechacreacion,
	 cast(case(ifnull(t0."PeyMethod",
	 '')) when '99' 
			then 'PPD - Pago en parcialidades o diferido' 
			else 'PUE - Pago en una sola exhibición' 
			end as varchar(100)) AS "MetodoPago",
	 (SELECT
	 ta."PymntGroup" 
			FROM octg ta 
			WHERE t0."GroupNum" = ta."GroupNum") AS "condicionesDePago",
	 t2."SWeight1",
	 (SELECT
	 "SlpName" 
			FROM oslp 
			WHERE "SlpCode" = t0."SlpCode") AS "Vendedor",
	 (SELECT
	 "U_NAME" 
			FROM ousr 
			WHERE T0."UserSign" = INTERNAL_K) AS "Autor",
	 t0."DocNum",
	 t0."NumAtCard" as "numatcard",
	 '99' AS "metododepago2",
	 IFNULL(t1."UomCode",
	 'NA') AS "SalUnitMsr2",
	 (select
	 "PayMethCod"||'-'||"Descript" 
			from opym 
			where "PayMethCod"=t0."PeyMethod") AS "metododepago",
	 t1."VatSum" AS "ImpLinea",
	 T0."WTSum" AS "retencion",
	 (SELECT
	 "PymntGroup" 
			FROM octg 
			WHERE "GroupNum" = t0."GroupNum") AS "cdecred",
	 t1."LineNum" AS "linenum",
	 t1."BaseLine",
	 (t2."SalPackUn" * t1."Quantity" * "SVolume") / 1000000 AS Volumen,
	 t3.fechahorasat,
	 t3.uuid,
	 t3.nocertificado,
	 T3.sellosat,
	 T3.cadenasat,
	 T3.CERTIFICADOSAT,
	 t3.fechahora,
	 t1."VatGroup",
	 t1."PriceAfVAT",
	 t1."VatPrcnt",
	 CASE t1."Currency" WHEN 'MXP' 
		THEN t1."GTotal" WHEN 'USD' 
		THEN t1."GTotalFC" WHEN 'EUR' 
		THEN t1."GTotalFC" 
		END AS "GTotal",
	 t0."U_B1SYS_MainUsage" AS "UsoCFDI",
	 (SELECT
	 Descripcion 
			FROM fe_SAT_c_UsoCFDI 
			WHERE c_UsoCFDI = t0."U_B1SYS_MainUsage") AS "DescripcionUsoCFDI",
	 substring(t3.sello,
	 (LENGTH(t3.sello) - 7),
	 8) AS "SelloQR",
	 t0."DocCur" AS "Moneda",
	 t3.rfcprovcertif,
	 t0."DocRate" AS "TipoCambio",
	 (SELECT
	 SUM("TaxSum") 
			FROM DPI4 
			WHERE "DocEntry" = t0."DocEntry" 
			AND (SELECT
	 "U_c_Impuestos" 
				FROM "@SAT_C_IMPUESTOS" 
				WHERE "Code" = "StaCode") = '003') AS "TIEPS",
	 (SELECT
	 SUM("TaxSum") 
			FROM DPI4 
			WHERE "DocEntry" = t0."DocEntry" 
			AND (SELECT
	 "U_c_Impuestos" 
				FROM "@SAT_C_IMPUESTOS" 
				WHERE "Code" = "StaCode") = '002') AS "TIVA",
	 (select
	 subtotal 
			from fe_api_encabezado 
			where docentry=t0."DocEntry" 
			and objtype=t0."ObjType") as "subtotal",
	 (select
	 total 
			from fe_api_encabezado 
			where docentry=t0."DocEntry" 
			and objtype=t0."ObjType") as "total",
	 (select
	 sum(importe) 
			from fe_api_impuestos 
			where docentry=t0."DocEntry" 
			and objtype=t0."ObjType") as "Iva2",
	 IFNULL((SELECT
	 CASE t0."DocCur" WHEN 'MXP' 
				THEN IFNULL(t0."DiscSum",
	 0) + IFNULL(t0."DpmAmnt",
	 0) 
				ELSE IFNULL(t0."DiscSumFC",
	 0) + IFNULL(t0."DpmAmntFC",
	 0) 
				END 
				FROM DUMMY),
	 0) AS "DescuentoDocto",
	 t2."FrgnName" as "frgnname",
	 t0."U_DXT_CCE_MotivoTraslado" as "U_CEMTraslado",
	 t0."U_DXT_CCE_TipoOperacion" as "U_CETOperacion",
	 t0."U_ClavePedimento" as "U_CECDPedimento",
	 t0."U_DXT_CCE_CeritifcadoOrigen" as "U_CECOrigen",
	 ifnull(t0."U_DXT_CCE_NumCertificadoOrigen",
	 '') as "U_CENCOrigen",
	 ifnull(t0."U_DXT_CCE_NumExportadorConfiable",
	 '') as "U_CENEConfiable",
	 ifnull(t0."U_DXT_CCE_Incoterm",
	 '') as "U_CEIncoterm",
	 ifnull(t0."U_SubDivision",
	 '') as "U_CESubdivision",
	 t0."U_CEObservaciones" as "U_CEObservaciones",
	 (SELECT
	 descripcion 
			FROM fe_SAT_c_MotivoTraslado 
			WHERE c_MotivoTraslado = t0."U_DXT_CCE_MotivoTraslado") AS "MotivoTraslado",
	 (SELECT
	 descripcion 
			FROM fe_SAT_c_TipoOperacion 
			WHERE c_TipoOperacion = t0."U_DXT_CCE_TipoOperacion") AS "TipoOperacion",
	 (SELECT
	 descripcion 
			FROM fe_SAT_c_INCOTERM 
			WHERE c_INCOTERM = ifnull(t0."U_DXT_CCE_Incoterm",
	 '')) AS "Incoterm",
	 (CASE t0."U_DXT_CCE_CeritifcadoOrigen" WHEN '0' 
			THEN 'No Funje' WHEN '1' 
			THEN 'Funje' 
			END) AS "CertificadoOrigen",
	 (CASE ifnull(t0."U_SubDivision",
	 '') WHEN '0' 
			THEN 'No Tiene División' WHEN '1' 
			THEN 'Si tiene División' 
			END) AS "Subdivision",
	 t1."U_UnidadAduana" AS "UnidadAduana",
	 t1."U_FraccionArancel" AS "FraccionArancelaria",
	 (select
	 "FileContnt" 
			from oqrc 
			where "SrcObjAbs"=t0."DocEntry" 
			and "SrcObjType"=203) as "QRCodeSrc" --t1."U_UVta" AS "UnidadFlex",
 --t1."U_PrecioVenta" AS "PrecioFlex",
 /*UnidadCFDI(T1."U_TipoUnidad",
	 T1."ItemCode") AS "ClaveUnidadFlex",
	 DescripCFDI(T1."U_TipoUnidad",
	 T1."ItemCode") AS "NombreUnidadFlex" */ 
		FROM ODPI t0 
		INNER JOIN DPI1 t1 ON t0."DocEntry" = t1."DocEntry" 
		INNER JOIN OITM t2 ON t1."ItemCode" = t2."ItemCode" 
		INNER JOIN fe_control T3 ON T0."DocEntry" = t3.docentry 
		INNER JOIN fe_seriescontrol t4 ON t0."Series" = t4.series 
		INNER JOIN fe_certificados t5 ON t5.id = t4.nocertificado 
		AND t3.objtype = 203 
		WHERE t1."UseBaseUn"='N')) WITH READ ONLY