USE [ACTUALIZABLES]
GO
/****** Object:  StoredProcedure [dbo].[SP_CARNES_INSERTA_ON_HAND]    Script Date: 25-10-2019 12:51:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:			<Sebastian Cornejo>
-- Create date: <2019/10/15>
-- Update date: <2019/10/25>
-- Description:	<Actualiza Tabla on_hand de carnes blancas>
-- EXEC [ACTUALIZABLES].[dbo].[SP_CARNES_INSERTA_ON_HAND]
-- =============================================

ALTER PROCEDURE [dbo].[SP_CARNES_INSERTA_ON_HAND]
AS
BEGIN
	BEGIN TRY

		-- !! BORRA DATA HISTORICA (30 dias)
		DECLARE @fecha_borrado DATE, @cmd NVARCHAR(MAX)
			SET @fecha_borrado = GETDATE()-30
			-- ** Se genera esta varibale debido a que el bloque catch no captura los errores de servidores vinculados.
			SET @cmd = '
				SELECT *
				FROM OPENQUERY(DW,''
					SELECT 
						A.Custcol_7 sku_producto,
						A.Cod_Localfisico id_local,
						A.Id_Diaanalisis id_dia,
						A.WJXBFS1 on_hand
					FROM dssmkpmmcl.on_hand_carnes A
				'') AS OH;'

		DELETE FROM [ACTUALIZABLES].[dbo].[CARNES_ON_HAND]
		WHERE id_dia <= @fecha_borrado

		-- ** INSERTA DATOS DESCARGADOS DE DWH
		INSERT INTO [ACTUALIZABLES].[dbo].[CARNES_ON_HAND]
		(sku_producto, id_local,id_dia,on_hand)

		EXEC sp_executesql @cmd;

	END TRY

	BEGIN CATCH

			EXEC [ACTUALIZABLES].dbo.SP_GetErrorInfo 201,'Job','CARNES_BLANCAS_ACTUALIZA_TABLAS', '[ACTUALIZABLES].[dbo].[CARNES_ON_HAND]'

	END CATCH
END
