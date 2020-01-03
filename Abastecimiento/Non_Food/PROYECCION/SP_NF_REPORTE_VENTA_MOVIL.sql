USE RepNonFood

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Sebastian Cornejo Berrios>
-- Create date: <2020-01-02>
-- Description:	<Informe proyecciones NonFood>
-- EXEC [RepNonFood].[dbo].[SP_NF_REPORTE_VENTA_MOVIL]
-- =============================================
CREATE PROCEDURE SP_NF_REPORTE_VENTA_MOVIL
AS

BEGIN

SELECT *
FROM RepNonFood.dbo.NF_REPORTE_VENTA_MOVIL

END
GO
