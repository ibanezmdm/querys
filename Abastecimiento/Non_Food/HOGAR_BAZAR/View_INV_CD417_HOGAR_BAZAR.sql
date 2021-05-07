USE [RepNonFood]
GO

/****** Object:  View [dbo].[View_INV_CD417_HOGAR_BAZAR]    Script Date: 15/04/2021 22:33:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[View_INV_CD417_HOGAR_BAZAR]
AS

	/*	Author:				Sebastian Esteban Cornejo Berrios
	 *	Description:	Consulta inventario CD 417 que muestra 
	 *	Created_at: 	2020/08/11
	 *	Updated_at:		2020/12/23
	 *	Cambios:
	 *		>> 2020/12/23: Se agrega J10 y J12 a los filtros
	 *	-- ?? SELECT * FROM RepNonFood.[dbo].[View_INV_CD417_HOGAR_BAZAR] where sku =  20445558
	 */

	WITH stock_no_disponible as (
		SELECT 
			t.sku,
			t.INVENTARIO_LOCAL
		FROM OPENQUERY(PMM,'
			SELECT 
				TO_NUMBER (trim(DEP.PRD_UPC)) AS UPC,
				PRD.PRD_LVL_NUMBER AS SKU,
				PRD_LVL_NUMBER6 AS JERARQUIA,
				PRD.PRD_NAME_FULL AS DESCRIPCION,
				DEP.CMARCA AS MARCA,
				ES.PRD_STATUS_DESC AS ESTADO,
				PRD.PRD_SLL_UOM UMP,
				ORG.ORG_LVL_NUMBER AS COD_LOCAL, 
				ORG.ORG_NAME_FULL AS NOM_LOCAL, 
				TYP.INV_TYPE_DESC AS TIPO_INVENTARIO,
				BAL.ON_HAND_QTY AS INVENTARIO_LOCAL, 
				BAL.ON_HAND_COST AS INVENTARIO_COSTO

			FROM 
			PRDTREEP DEP
			INNER JOIN PRDMSTEE PRD 
				ON PRD.PRD_LVL_NUMBER = DEP.PRD_LVL_NUMBER
			INNER JOIN PRDSTSEE ES 
				ON ES.PRD_STATUS = DEP.PRD_STATUS
			INNER JOIN INVBALEE BAL 
				ON BAL.PRD_LVL_CHILD = PRD.PRD_LVL_CHILD
			INNER JOIN ORGMSTEE ORG 
				ON ORG.ORG_LVL_CHILD = BAL.ORG_LVL_CHILD
			INNER JOIN INVTYPEE TYP 
				ON TYP.INV_TYPE_CODE = BAL.INV_TYPE_CODE

			WHERE 
				TYP.INV_TYPE_DESC = ''No Disponible''
				AND ORG.ORG_LVL_NUMBER  in (417)
				AND PRD_LVL_NUMBER6 IN (
					''J09            '', 
					''J08            '', 
					''J10            '', 
					''J11            ''
				)
				AND (BAL.ON_HAND_QTY > 0
					--OR BAL.ON_HAND_COST > 0
				)
				--AND PRD.PRD_LVL_NUMBER = ''20445558''
		') T
	)

	SELECT  
		A.[SKU] 
		,A.[NOM_SKU] 
		,[UN_INV_DISP_HOY] 
		,B.DEPARTAMENTO 
		,B.SUBDEPARTAMENTO 
		,B.CASEPACK
		,isnull(convert(int, s.INVENTARIO_LOCAL), 0) inv_no_diponible
	FROM [INFORMES3].[dbo].[CE_INV_CD417_DIA]  AS A 
	left join [RepNonFood].dbo.Maestra_sku AS b 
		on b.SKU=A.SKU 
	left join stock_no_disponible s
		on s.sku = A.SKU
	where (b.DIVISION like 'J09%' 
			or b.DIVISION like 'J10%'
		)
		and (UN_INV_DISP_HOY > 0
			or s.INVENTARIO_LOCAL > 0
		)

GO


