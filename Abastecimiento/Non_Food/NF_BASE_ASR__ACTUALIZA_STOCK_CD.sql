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
-- Description:	<Carga datos base para informe Non Food ASR>
-- ?? EXEC [RepNonFood].[dbo].[SP_CARGA_NF_BASE_ASR]
-- =============================================
ALTER PROCEDURE [dbo].[SP_CARGA_NF_BASE_ASR]
AS
BEGIN

	BEGIN TRY

		UPDATE [RepNonFood].[dbo].[NF_BASE_ASR]
		SET 
			STOCK_CD = S.UN_INV_DISP_HOY, 
			NO_EMPUJADO = 1-B.[INDICADOR]
			
		FROM [RepNonFood].[dbo].[NF_BASE_ASR] B
			LEFT JOIN (
				SELECT
					[SKU]
					, SUM([COSTO_INV_DISP_HOY]) [COSTO_INV_DISP_HOY]
					, SUM([MONTO_INV_DISP_HOY]) [MONTO_INV_DISP_HOY]
					, SUM([UN_INV_DISP_HOY]) [UN_INV_DISP_HOY]
				FROM [INSTOCK_OPT].[dbo].[STOCK_HOY_CIA]
				WHERE [DIVISION] IN ('J08- VESTUARIO', 'J09 - HOGAR', 'J10 - BAZAR', 'J11 - ELECTRO')
				GROUP BY [SKU]
			) S
				ON B.SKU = S.SKU

	END TRY

	BEGIN CATCH

		EXEC [ACTUALIZABLES].dbo.SP_GetErrorInfo 201, 'Job', 'NF_BASE_ASR__ACTUALIZA_STOCK_CD', '[RepNonFood].[dbo].[NF_BASE_ASR]'

	END CATCH

END