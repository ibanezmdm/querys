
 --==== INSTOCK TOP 500 POR SUBDEPTO =======================
 --=========================================================
 --== CORRER EN 104
 
	TRUNCATE TABLE [INFORMES3].[dbo].[NUEVO_INSTOCK_MAIL_SUBDEPTO_TOP500]
	
	INSERT INTO [INFORMES3].[dbo].[NUEVO_INSTOCK_MAIL_SUBDEPTO_TOP500]
           ([SUBDEP]
           ,[SEM4]
           ,[SEM3]
           ,[SEM2]
           ,[SEM1]
           ,[SEM_ACTUAL])
    SELECT A.SUBDEP		
		, ISNULL(SEM5.INSTOCK,0) AS SEM4
		, ISNULL(SEM4.INSTOCK,0) AS SEM3
		, ISNULL(SEM3.INSTOCK,0) AS SEM2
		, ISNULL(SEM2.INSTOCK,0) AS SEM1
		, ISNULL(SEM1.INSTOCK,0) AS SEM_ACTUAL
--INTO [INFORMES3].[dbo].[NUEVO_INSTOCK_MAIL_SUBDEPTO_TOP500]
 FROM  [INFORMES3].[dbo].[INSTOCK_NUEVA_PLANILLA] AS A LEFT JOIN
  (
 SELECT     SUBDEP, (SUM(NUM_OH_VALORIZADO) / NULLIF (SUM(NUM_VTA_SEM_X_PERFIL), 0) * 100) AS INSTOCK
FROM         INSTOCK_NUEVA_PLANILLA_HISTORIA
WHERE     ((SEMANA = (CASE WHEN DATEPART(ww, GETDATE()) < 10 THEN
                          (SELECT     '' + CAST(DATEPART(YYYY, GETDATE()) AS NVARCHAR(MAX)) + '0' + CAST(DATEPART(ww, GETDATE()) AS NVARCHAR(MAX)) + '') ELSE
                          (SELECT     '' + CAST(DATEPART(YYYY, GETDATE()) AS NVARCHAR(MAX)) + '' + CAST(DATEPART(ww, GETDATE()) AS NVARCHAR(MAX)) + '') END)) AND 
                      (TOP_500 = 'TOP500')) AND COD_LOCAL not in (SELECT * FROM [INFORMES3].[dbo].[TIENDAS_ASENTADAS])
GROUP BY SUBDEP) AS SEM1 ON SEM1.SUBDEP=A.SUBDEP LEFT JOIN
 
   (
  SELECT SUBDEP
        , (SUM(NUM_OH_VALORIZADO) / NULLIF (SUM(NUM_VTA_SEM_X_PERFIL), 0) * 100) AS INSTOCK
   
         FROM  [INFORMES3].[dbo].[INSTOCK_NUEVA_PLANILLA_RESUMEN_SEMANA] 
         WHERE (SEMANA= (CASE WHEN DATEPART(ww,GETDATE()-7)<10 THEN (select ''+CAST(DATEPART(YYYY,GETDATE()-7) AS NVARCHAR(MAX))+'0'+CAST(DATEPART(ww,GETDATE()-7) AS NVARCHAR(MAX))+'')
                      ELSE (select ''+CAST(DATEPART(YYYY,GETDATE()-7) AS NVARCHAR(MAX))+''+CAST(DATEPART(ww,GETDATE()-7) AS NVARCHAR(MAX))+'') END )) AND  (TOP_500 = 'TOP500')
        
         
 GROUP BY SUBDEP) AS SEM2 ON SEM2.SUBDEP=A.SUBDEP LEFT JOIN
 
    (
  SELECT SUBDEP
        ,(SUM(NUM_OH_VALORIZADO) / NULLIF (SUM(NUM_VTA_SEM_X_PERFIL), 0) * 100) AS INSTOCK
   
         FROM  [INFORMES3].[dbo].[INSTOCK_NUEVA_PLANILLA_RESUMEN_SEMANA] 
         WHERE (SEMANA= (CASE WHEN DATEPART(ww,GETDATE()-14)<10 THEN (select ''+CAST(DATEPART(YYYY,GETDATE()-14) AS NVARCHAR(MAX))+'0'+CAST(DATEPART(ww,GETDATE()-14) AS NVARCHAR(MAX))+'')
                      ELSE (select ''+CAST(DATEPART(YYYY,GETDATE()-14) AS NVARCHAR(MAX))+''+CAST(DATEPART(ww,GETDATE()-14) AS NVARCHAR(MAX))+'') END )) AND  (TOP_500 = 'TOP500')
              
 GROUP BY SUBDEP) AS SEM3 ON SEM3.SUBDEP=A.SUBDEP LEFT JOIN
 
 (
  SELECT SUBDEP
        --,SEMANA
        , (SUM(NUM_OH_VALORIZADO) / NULLIF (SUM(NUM_VTA_SEM_X_PERFIL), 0) * 100) AS INSTOCK
        FROM  [INFORMES3].[dbo].[INSTOCK_NUEVA_PLANILLA_RESUMEN_SEMANA] 
         WHERE (SEMANA= (CASE WHEN DATEPART(ww,GETDATE()-21)<10 THEN (select ''+CAST(DATEPART(YYYY,GETDATE()-21) AS NVARCHAR(MAX))+'0'+CAST(DATEPART(ww,GETDATE()-21) AS NVARCHAR(MAX))+'')
                      ELSE (select ''+CAST(DATEPART(YYYY,GETDATE()-21) AS NVARCHAR(MAX))+''+CAST(DATEPART(ww,GETDATE()-21) AS NVARCHAR(MAX))+'') END )) AND  (TOP_500 = 'TOP500')
                           
 GROUP BY SUBDEP) AS SEM4 ON SEM4.SUBDEP=A.SUBDEP LEFT JOIN
 
 (
  SELECT SUBDEP
        --,SEMANA
        , (SUM(NUM_OH_VALORIZADO) / NULLIF (SUM(NUM_VTA_SEM_X_PERFIL), 0) * 100) AS INSTOCK
         FROM  [INFORMES3].[dbo].[INSTOCK_NUEVA_PLANILLA_RESUMEN_SEMANA] 
         WHERE (SEMANA= (CASE WHEN DATEPART(ww,GETDATE()-28)<10 THEN (select ''+CAST(DATEPART(YYYY,GETDATE()-28) AS NVARCHAR(MAX))+'0'+CAST(DATEPART(ww,GETDATE()-28) AS NVARCHAR(MAX))+'')
                      ELSE (select ''+CAST(DATEPART(YYYY,GETDATE()-28) AS NVARCHAR(MAX))+''+CAST(DATEPART(ww,GETDATE()-28) AS NVARCHAR(MAX))+'') END )) AND  (TOP_500 = 'TOP500')
                           
 GROUP BY SUBDEP) AS SEM5 ON SEM5.SUBDEP=A.SUBDEP
 
 
 WHERE A.SUBDEP NOT IN ('J010203 - ENVASES') 
 GROUP BY A.SUBDEP, SEM1.INSTOCK, SEM2.INSTOCK, SEM3.INSTOCK, SEM4.INSTOCK, SEM5.INSTOCK


  --==== INSTOCK TOP 2100 POR SUBDEPTO =======================
 --=========================================================
 --== CORRER EN 104
 
TRUNCATE TABLE [INFORMES3].[dbo].[NUEVO_INSTOCK_MAIL_SUBDEPTO_TOP2100]

INSERT INTO [INFORMES3].[dbo].[NUEVO_INSTOCK_MAIL_SUBDEPTO_TOP2100]
           ([SUBDEP]
           ,[SEM4]
           ,[SEM3]
           ,[SEM2]
           ,[SEM1]
           ,[SEM_ACTUAL])
    SELECT A.SUBDEP		
		, ISNULL(SEM5.INSTOCK,0) AS SEM4
		, ISNULL(SEM4.INSTOCK,0) AS SEM3
		, ISNULL(SEM3.INSTOCK,0) AS SEM2
		, ISNULL(SEM2.INSTOCK,0) AS SEM1
		, ISNULL(SEM1.INSTOCK,0) AS SEM_ACTUAL
-- INTO [INFORMES3].[dbo].[NUEVO_INSTOCK_MAIL_SUBDEPTO_TOP2100]
 FROM  [INFORMES3].[dbo].[INSTOCK_NUEVA_PLANILLA] AS A LEFT JOIN
  (
 SELECT     SUBDEP, (SUM(NUM_OH_VALORIZADO) / NULLIF (SUM(NUM_VTA_SEM_X_PERFIL), 0) * 100) AS INSTOCK
FROM         INSTOCK_NUEVA_PLANILLA_HISTORIA
WHERE     (SEMANA = (CASE WHEN DATEPART(ww, GETDATE()) < 10 THEN
                          (SELECT     '' + CAST(DATEPART(YYYY, GETDATE()) AS NVARCHAR(MAX)) + '0' + CAST(DATEPART(ww, GETDATE()) AS NVARCHAR(MAX)) + '') ELSE
                          (SELECT     '' + CAST(DATEPART(YYYY, GETDATE()) AS NVARCHAR(MAX)) + '' + CAST(DATEPART(ww, GETDATE()) AS NVARCHAR(MAX)) + '') END)) AND 
                      (TOP_2100 = 'TOP2100')  AND COD_LOCAL not in (SELECT * FROM [INFORMES3].[dbo].[TIENDAS_ASENTADAS])
GROUP BY SUBDEP) AS SEM1 ON SEM1.SUBDEP=A.SUBDEP LEFT JOIN
 
   (
  SELECT SUBDEP
        , (SUM(NUM_OH_VALORIZADO) / NULLIF (SUM(NUM_VTA_SEM_X_PERFIL), 0) * 100) AS INSTOCK
   
         FROM  [INFORMES3].[dbo].[INSTOCK_NUEVA_PLANILLA_RESUMEN_SEMANA] 
         WHERE (SEMANA= (CASE WHEN DATEPART(ww,GETDATE()-7)<10 THEN (select ''+CAST(DATEPART(YYYY,GETDATE()-7) AS NVARCHAR(MAX))+'0'+CAST(DATEPART(ww,GETDATE()-7) AS NVARCHAR(MAX))+'')
                      ELSE (select ''+CAST(DATEPART(YYYY,GETDATE()-7) AS NVARCHAR(MAX))+''+CAST(DATEPART(ww,GETDATE()-7) AS NVARCHAR(MAX))+'') END )) AND  (TOP_2100 = 'TOP2100')
        
         
 GROUP BY SUBDEP) AS SEM2 ON SEM2.SUBDEP=A.SUBDEP LEFT JOIN
 
    (
  SELECT SUBDEP
        , (SUM(NUM_OH_VALORIZADO) / NULLIF (SUM(NUM_VTA_SEM_X_PERFIL), 0) * 100) AS INSTOCK
   
         FROM  [INFORMES3].[dbo].[INSTOCK_NUEVA_PLANILLA_RESUMEN_SEMANA] 
         WHERE (SEMANA= (CASE WHEN DATEPART(ww,GETDATE()-14)<10 THEN (select ''+CAST(DATEPART(YYYY,GETDATE()-14) AS NVARCHAR(MAX))+'0'+CAST(DATEPART(ww,GETDATE()-14) AS NVARCHAR(MAX))+'')
                      ELSE (select ''+CAST(DATEPART(YYYY,GETDATE()-14) AS NVARCHAR(MAX))+''+CAST(DATEPART(ww,GETDATE()-14) AS NVARCHAR(MAX))+'') END )) AND  (TOP_2100 = 'TOP2100')
              
 GROUP BY SUBDEP) AS SEM3 ON SEM3.SUBDEP=A.SUBDEP LEFT JOIN
 
 (
  SELECT SUBDEP
        --,SEMANA
        , (SUM(NUM_OH_VALORIZADO) / NULLIF (SUM(NUM_VTA_SEM_X_PERFIL), 0) * 100) AS INSTOCK
         FROM  [INFORMES3].[dbo].[INSTOCK_NUEVA_PLANILLA_RESUMEN_SEMANA] 
         WHERE (SEMANA= (CASE WHEN DATEPART(ww,GETDATE()-21)<10 THEN (select ''+CAST(DATEPART(YYYY,GETDATE()-21) AS NVARCHAR(MAX))+'0'+CAST(DATEPART(ww,GETDATE()-21) AS NVARCHAR(MAX))+'')
                      ELSE (select ''+CAST(DATEPART(YYYY,GETDATE()-21) AS NVARCHAR(MAX))+''+CAST(DATEPART(ww,GETDATE()-21) AS NVARCHAR(MAX))+'') END )) AND  (TOP_2100 = 'TOP2100')
                           
 GROUP BY SUBDEP) AS SEM4 ON SEM4.SUBDEP=A.SUBDEP LEFT JOIN
 
 (
  SELECT SUBDEP
        --,SEMANA
        , (SUM(NUM_OH_VALORIZADO) / NULLIF (SUM(NUM_VTA_SEM_X_PERFIL), 0) * 100) AS INSTOCK
         FROM  [INFORMES3].[dbo].[INSTOCK_NUEVA_PLANILLA_RESUMEN_SEMANA] 
         WHERE (SEMANA= (CASE WHEN DATEPART(ww,GETDATE()-28)<10 THEN (select ''+CAST(DATEPART(YYYY,GETDATE()-28) AS NVARCHAR(MAX))+'0'+CAST(DATEPART(ww,GETDATE()-28) AS NVARCHAR(MAX))+'')
                      ELSE (select ''+CAST(DATEPART(YYYY,GETDATE()-28) AS NVARCHAR(MAX))+''+CAST(DATEPART(ww,GETDATE()-28) AS NVARCHAR(MAX))+'') END )) AND  (TOP_2100 = 'TOP2100')
                           
 GROUP BY SUBDEP) AS SEM5 ON SEM5.SUBDEP=A.SUBDEP
 
 
 WHERE A.SUBDEP NOT IN ('J010203 - ENVASES')  AND A.COD_LOCAL not in (209,203,205,202,206,105,129,107,207)
 GROUP BY A.SUBDEP, SEM1.INSTOCK, SEM2.INSTOCK, SEM3.INSTOCK, SEM4.INSTOCK, SEM5.INSTOCK


