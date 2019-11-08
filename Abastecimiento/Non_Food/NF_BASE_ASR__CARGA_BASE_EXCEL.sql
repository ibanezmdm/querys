USE [RepNonFood]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:			<Sebastian Cornejo>
-- Create date: <2019/10/17>
-- Update date: <---/--/-->
-- Description:	<Carga datos base para informe Non Food ASR desde archivo excel>
-- ?? EXEC [RepNonFood].[dbo].[SP_NF_BASE_ASR__CARGA_BASE_EXCEL]
-- =============================================
ALTER PROCEDURE [dbo].[SP_NF_BASE_ASR__CARGA_BASE_EXCEL]
AS
BEGIN

	BEGIN TRY

		TRUNCATE TABLE [RepNonFood].[dbo].[NF_BASE_ASR_EXCEL]

		INSERT INTO [RepNonFood].[dbo].[NF_BASE_ASR_EXCEL]

		SELECT 
			CONVERT(NUMERIC, E.SKU) SKU,
			CONVERT(NUMERIC, E.Local) COD_LOCAL,
			CONVERT(NUMERIC, E.Min_Base) MINIMO_BASE
		FROM OPENROWSET (
			'Microsoft.ACE.OLEDB.12.0',
			'Excel 12.0 Xml;HDR=YES;Database=C:\Instock_Quiebre\NON_FOOD\Campos_base_reporte.xlsx',
			'SELECT * FROM [Hoja1$]'
		) E

	END TRY

	BEGIN CATCH

		EXEC [ACTUALIZABLES].dbo.SP_GetErrorInfo 201, 'Job', 'NF_BASE_ASR__CARGA_BASE_EXCEL', '[RepNonFood].[dbo].[NF_BASE_ASR_EXCEL]'

	END CATCH

END
