USE [ACTUALIZABLES]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Sebastian Cornejo Berrios>
-- Create date: <2019-10-11>
-- Update date: <2019-10-15>
-- Description:	<SP que captura errores y los registra en la tabla log_catch_error>
-- ?? [dbo].[SP_fixErrorLog] '2,3'
-- =============================================
ALTER PROCEDURE [dbo].[SP_fixErrorLog]
	-- Add the parameters for the stored procedure here
	@ids VARCHAR(MAX)
AS
BEGIN

	-- ?? SELECT * FROM [ACTUALIZABLES].dbo.[log_catch_error] WHERE estadoError <> 1

	-- SELECT *
	UPDATE [ACTUALIZABLES].[dbo].[log_catch_error]
	SET estadoError = 1
	FROM [ACTUALIZABLES].[dbo].[log_catch_error]
		WHERE id IN (SELECT * FROM dbo.splitString(@ids))

END
