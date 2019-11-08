USE [ACTUALIZABLES]
GO
/****** Object:  StoredProcedure [dbo].[SP_GetErrorInfo]    Script Date: 15-10-2019 18:33:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Sebastian Cornejo Berrios>
-- Create date: <2019-10-11>
-- Update date: <2019-10-15>
-- Description:	<SP que captura errores y los registra en la tabla log_catch_error>
-- ?? EXEC SP_GetErrorInfo
-- =============================================
ALTER PROCEDURE [dbo].[SP_GetErrorInfo]
	-- Add the parameters for the stored procedure here
	@servidor NUMERIC(12,0),
	@tipoProceso VARCHAR(MAX),
	@proceso VARCHAR(MAX),
	@tabla VARCHAR(MAX)
AS
BEGIN

	-- ?? SELECT * FROM [ACTUALIZABLES].dbo.[log_catch_error]

	INSERT INTO [ACTUALIZABLES].dbo.[log_catch_error] (
		ErrorNumber,
		ErrorSeverity,
		ErrorState,
		ErrorProcedure,
		ErrorLine,
		ErrorMessage,
		servidor,
		tipoProceso,
		NombreProceso,
		NombreTabla,
		fechaError
	)

	SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage,
		@servidor as servidor,
		@tipoProceso as tipoProceso,
		@proceso as NombreProceso,
		@tabla as NombreTabla,
		GETDATE() as fechaError;

END
