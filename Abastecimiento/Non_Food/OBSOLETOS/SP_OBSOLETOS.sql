USE [INFORMES3]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Obsoleto]    Script Date: 09-01-2020 10:35:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		BRYAN ESCALONA
-- Create date: 29-04-2013
-- Description:	CREACION DE INFORME DE FILLRATE
-- ?? (104) EXEC [dbo].[Sp_Obsoleto]
-- =============================================
ALTER PROCEDURE [dbo].[Sp_Obsoleto]
	
AS
BEGIN

SELECT [COD_LOCAL]
      ,[NOM_LOCAL]
      ,[SUBGERENTE_ZONAL]
      ,O.[DIVISION]
      ,O.[DEPARTAMENTO]
      ,[SUBDEP]
      ,O.[CLASE]
      ,[SUB_CLASE]
      ,O.[EAN]
      ,O.[SKU]
      ,O.[NOM_SKU]
      ,O.[MARCA]
      ,[NOM_PROVEEDOR]
      ,[DESC_ESTADO]
      ,[INV_DISP_HOY]
      ,O.[PRECIO_COSTO]
      ,[OBSOLESCENCIA_DISPONIBLE]
      ,[PRECIO_ORIGINAL]
      ,O.[PRECIO_VIGENTE]
      ,[RANGO_OBSOLETOS_2]
      ,[SIGNO]
      ,[FECHA_ULT_RECEP]
      ,[FECHA_VENCIMIENTO]
      ,[MES]
      ,[GERENTE_LINEA]
      ,[PM]
      ,[TEMPORADA]
      ,M.PRECIO_REGULAR 
FROM INFORMES3.dbo.ROBSOLETOS_PRINCIPAL O LEFT JOIN 
[192.168.148.177].[RepNonFood].dbo.MAESTRA_SKU_2 M ON O.SKU = M.SKU
WHERE O.DIVISION NOT LIKE 'J12%'
END
