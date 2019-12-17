USE [INFORMES3]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Mail_Grilla_FFVV_Local]    Script Date: 20-11-2019 16:47:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Carlos Reyes L.
-- Create date: 14-02-2018
-- Description:	Crea Grilla Instock FFVV Por Local
-- EXEC Sp_Mail_Grilla_FFVV_Local
-- =============================================
ALTER PROCEDURE [dbo].[Sp_Mail_Grilla_FFVV_Local]

AS
BEGIN
	TRUNCATE TABLE [INFORMES3].[dbo].[FFVV_GRILLA_INSTOCK_LOCAL]
	
INSERT INTO [INFORMES3].[dbo].[FFVV_GRILLA_INSTOCK_LOCAL] (
	[Cuadro Resumen]
	,[FECHA]
	,[COD_LOCAL]
	,[NOM_LOCAL]
	,[INSTOCK]
	,[INSTOCK_NUM]
)
SELECT '2-INSTOCK SUBDEPTO LOCAL'  AS [Cuadro Resumen]
       ,B.FECHA
      -- ,A.SUBDEP
       ,A.COD_LOCAL
       ,A.NOM_LOCAL
      ,''+CONVERT(VARCHAR(10),CONVERT(NUMERIC(12,1),SUM([NUM_OH_VALORIZADO])/nullif(SUM([NUM_VTA_SEM_X_PERFIL]),0)*100))+'%' AS INSTOCK
      ,CONVERT(NUMERIC(12,1),SUM([NUM_OH_VALORIZADO])/nullif(SUM([NUM_VTA_SEM_X_PERFIL]),0)*100) AS INSTOCK_NUM
--INTO [INFORMES3].[dbo].[FFVV_GRILLA_INSTOCK_LOCAL]
FROM dbo.CE_INSTOCK_FYV AS A
JOIN [INFORMES3].dbo.DHW_MES_GC AS B ON B.FECHA=CONVERT(DATE,A.FECHA_ACTUALIZ) 
GROUP BY B.FECHA,A.COD_LOCAL,A.NOM_LOCAL
ORDER BY INSTOCK_NUM


END
