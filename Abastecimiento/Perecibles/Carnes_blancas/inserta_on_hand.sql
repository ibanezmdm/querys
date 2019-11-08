BEGIN TRY

	-- !! BORRA DATA HISTORICA (30 dias)
	DECLARE @fecha_borrado DATE
		SET @fecha_borrado = GETDATE()-30

	DELETE FROM [ACTUALIZABLES].[dbo].[CARNES_ON_HAND]
	WHERE id_dia <= @fecha_borrado

	-- ** INSERTA DATOS DESCARGADOS DE DWH
	INSERT INTO [ACTUALIZABLES].[dbo].[CARNES_ON_HAND]
		(sku_producto, id_local,id_dia,on_hand)

		SELECT *
			FROM OPENQUERY(DW,'
				SELECT
					A.Custcol_7 sku_producto,
					A.Cod_Localfisico id_local,
					A.Id_Diaanalisis id_dia,
					A.Unidinvdispohoy on_hand
				FROM dssmkpmmcl.on_hand_carnes A
			') AS OH

END TRY

BEGIN CATCH

		EXEC [ACTUALIZABLES].dbo.SP_GetErrorInfo 201,'Job','CARNES_BLANCAS_ACTUALIZA_TABLAS', '[ACTUALIZABLES].[dbo].[CARNES_ON_HAND]'

END CATCH