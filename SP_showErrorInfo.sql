USE [ACTUALIZABLES]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:			<Sebastian Cornejo Berrios>
-- Create date: <2019/11/08>
-- Update date: <----/--/-->
-- Description:	<SP que captura errores registrados en estado 0>
-- ?? EXEC [ACTUALIZABLES].[dbo].[SP_ShowErrorInfo]
-- ?? EXEC [ACTUALIZABLES].[dbo].[SP_fixErrorLog] '13'
-- =============================================
CREATE PROCEDURE [dbo].[SP_ShowErrorInfo]
	-- Add the parameters for the stored procedure here
AS
BEGIN

	SELECT * 
	FROM [ACTUALIZABLES].dbo.[log_catch_error]
	WHERE estadoError = 0

END
