USE [ACTUALIZABLES]
GO
/****** Object:  StoredProcedure [dbo].[SP_ACTUALIZABLE_OCS_PMM]    Script Date: 24-10-2019 9:33:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Sebastian Cornejo>
-- Create date: <2019/10/23>
-- Update date: <2019/10/24>
-- Description:	<Trae todas las OCs generadas desde PMM desde 9 dias hasta hoy>
-- EXEC [ACTUALIZABLES].[dbo].[SP_ACTUALIZABLE_OCS_PMM]
-- =============================================
ALTER PROCEDURE [dbo].[SP_ACTUALIZABLE_OCS_PMM]

AS
BEGIN
	SET NOCOUNT ON;

SELECT
	OC.id_proveedor,
	PROV.RUT_PROV,
	OC.razon_social,
	CONVERT(NUMERIC,OC.sku_producto) sku_producto,
	OC.descripcion_sku,
	OC.id_local,
	OC.nombre_local,
	OC.numero_OC,
	OC.unidades,
	OC.cajas,
	OC.f_emision,
	OC.f_recepcion_OC,
	OC.id_estado_OC,
	E.estado as estado_OC,
	OC.comprador,
	PROV.DIVISION,
	PROV.DEPARTAMENTO,
	PROV.SUBDEPARTAMENTO,
	PROV.CLASE,
	PROV.SUBCLASE
FROM (
	SELECT OC_A.* 
	FROM [ACTUALIZABLES].[dbo].[CT_OCS_PMM] AS OC_A
	LEFT JOIN (
		SELECT *
		FROM OPENQUERY(PMM,'
			SELECT E.PMG_PO_NUMBER
			FROM PMGHDREE E --tabla oc
			WHERE TO_CHAR(E.PMG_LAST_CHG_DT,''yyyymmdd'') = TO_CHAR(sysdate,''yyyymmdd'')
		') AS OC_H
	) AS OC_H 
		ON OC_A.NUMERO_OC = OC_H.PMG_PO_NUMBER
	WHERE OC_H.PMG_PO_NUMBER IS NULL
	UNION ALL
	SELECT *
	FROM OPENQUERY(PMM,'
		SELECT 
			TO_NUMBER(PV.VENDOR_NUMBER) AS id_proveedor,
			-- AS rut_proveedor,
			PV.VENDOR_NAME AS razon_social,
			P.PRD_LVL_NUMBER AS sku_producto,
			P.PRD_NAME_FULL AS descripcion_sku,
			O.ORG_LVL_NUMBER AS id_local,
			O.ORG_NAME_FULL AS nombre_local,
			DT.PMG_PO_NUMBER AS numero_OC,
			DT.PMG_SELL_QTY AS unidades,
			DT.PMG_PACK_QTY AS cajas,
			TO_CHAR(E.PMG_RELEASE_DATE,''DD/MM/YYYY'') AS f_emision,
			TO_CHAR(DT.PMG_EXP_RCT_DATE,''DD/MM/YYYY'') AS f_recepcion_OC,
			E.PMG_STAT_CODE AS id_estado_OC,
			E.PMG_USER AS comprador
		FROM 
			PMGDTLEE DT, --tabla detalle oc
			PMGHDREE E, --tabla oc
			PRDMSTEE P, --tabla producto
			ORGMSTEE O, --tabla organizacion
			VPCMSTEE PV --tabla proveedor
		WHERE 
			DT.PMG_PO_NUMBER = E.PMG_PO_NUMBER
			AND DT.PRD_LVL_CHILD = P.PRD_LVL_CHILD
			AND O.ORG_LVL_CHILD = DT.ORG_LVL_CHILD
			AND PV.VPC_TECH_KEY = E.VPC_TECH_KEY
			AND TO_CHAR(E.PMG_LAST_CHG_DT,''yyyymmdd'') = TO_CHAR(sysdate,''yyyymmdd'')
		ORDER BY 
			DT.PMG_PO_NUMBER
	') AS D_OC_H
) AS OC
LEFT JOIN (
	SELECT *
	FROM [RepNonFood].[dbo].[MAESTRA_SKU] AS A
) AS PROV
ON PROV.sku = OC.sku_producto
LEFT JOIN ACTUALIZABLES.dbo.CT_TEMP_ESTADO_OC AS E
ON OC.id_estado_OC = E.id_estado

END