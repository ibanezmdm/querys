USE [INFORMES3]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Mail_Grilla_FFVV_Clase_A]    Script Date: 20-11-2019 17:07:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Carlos Reyes L.
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- EXEC Sp_Mail_Grilla_FFVV_Clase_A 
-- =============================================
ALTER PROCEDURE [dbo].[Sp_Mail_Grilla_FFVV_Clase_A]

AS
BEGIN
	TRUNCATE TABLE [INFORMES3].[dbo].[FFVV_INSTOCK_CLASE_A]

	INSERT INTO [INFORMES3].[dbo].[FFVV_INSTOCK_CLASE_A] (
		[INSTOCK_FFVV_CLASE_A]
		,[INSTOCK]
	)

-- SELECT    'INSTOCK FFVV CLASE A' AS INSTOCK_FFVV_CLASE_A
--           ,''+CONVERT(VARCHAR(10),CONVERT(NUMERIC(12,1),SUM([NUM_OH_VALORIZADO])/nullif(SUM([NUM_VTA_SEM_X_PERFIL]),0)*100))+'%'		AS INSTOCK
-- --INTO [INFORMES3].[dbo].[FFVV_INSTOCK_CLASE_A]
-- FROM         dbo.CE_INSTOCK_FYV
-- WHERE     (SUBDEP LIKE '%J04%') AND (SKU IN
--                           (SELECT     SKU
--                             FROM          [INFORMES3].[dbo].[FFVV_SKUS_CLASE_A])) and COD_LOCAL not in (209,203,205,202,206,105,129,107,207)


	SELECT 
		'INSTOCK FFVV CLASE A' AS INSTOCK_FFVV_CLASE_A
		,''+CONVERT(VARCHAR(10),CONVERT(NUMERIC(12,1),SUM([NUM_OH_VALORIZADO])/nullif(SUM([NUM_VTA_SEM_X_PERFIL]),0)*100))+'%' AS INSTOCK
	FROM dbo.CE_INSTOCK_FYV I
	LEFT JOIN [INFORMES3].[dbo].[TIENDAS_ASENTADAS] T
		ON I.COD_LOCAL = T.COD_LOCAL
	WHERE
		SUBDEP LIKE '%J04%'
		AND	SKU IN (SELECT SKU FROM [INFORMES3].[dbo].[FFVV_SKUS_CLASE_A])
		AND T.COD_LOCAL IS NULL

END

