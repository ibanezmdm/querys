USE [ACTUALIZABLES]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:			<Sebastian Cornejo>
-- Create date: <2019/10/15>
-- Update date: <---/--/-->
-- Description:	<Actualiza Tabla con promociones cargadas en SAP para Sistema de Recargas PGC>
-- EXEC [ACTUALIZABLES].[dbo].[SP_CT_ACTUALIZA_DATOS_SAP]
-- =============================================
CREATE PROCEDURE [dbo].[SP_CT_ACTUALIZA_DATOS_SAP]
AS
BEGIN
	DECLARE @fecha_inicio DATE, @fecha_termino DATE
		SET @fecha_inicio = CONVERT(DATE,GETDATE()+7)
		SET @fecha_termino = CONVERT (DATE,GETDATE()+7)

	BEGIN TRY

		TRUNCATE TABLE [ACTUALIZABLES].[dbo].[CT_SAP]

		INSERT INTO [ACTUALIZABLES].[dbo].[CT_SAP]

		SELECT 
			ID_CATALOGO,
			NOM_CATALOGO,
			MIN(DETALLE_PROMOCION),
			SKU_J,
			DESCRIPCION,
			NOM_CLASE,
			MIN(F_I),
			MIN(SEMANA_I),
			MAX(F_F),
			MAX(SEMANA_F)
		FROM [192.168.148.177].[PronosticosVentas].[dbo].[Promociones]
		WHERE F_F >= @fecha_termino
			AND F_I <= @fecha_inicio
			AND (NOM_CLASE LIKE 'J01%'
				OR NOM_CLASE LIKE 'J02%')
		GROUP BY
			ID_CATALOGO,
			NOM_CATALOGO,
			SKU_J,
			DESCRIPCION,
			NOM_CLASE

	END TRY

	BEGIN CATCH

		EXEC [ACTUALIZABLES].dbo.SP_GetErrorInfo 201, 'Job', 'CT_SUGERIDO_CATALOGOS', '[ACTUALIZABLES].[dbo].[CT_SAP]'

	END CATCH
END
