TRUNCATE TABLE [INFORMES3].[dbo].[INSTOCK_TABLEAU_LOCAL]

INSERT INTO [INFORMES3].[dbo].[INSTOCK_TABLEAU_LOCAL]
           ([COD_LOCAL]
           ,[NOM_LOCAL]
		   ,[CANTIDAD_SKUS]
           ,[INSTOCK-CIA]
           ,[INSTOCK-TOP500]
           ,[INSTOCK-TOP2100]
           ,[INSTOCK-J01]
           ,[INSTOCK-J02]
           ,[INSTOCK-J05]
           ,[INSTOCK-J06]
           ,[INSTOCK-J07])

SELECT AA.COD_LOCAL
	   ,AA.NOM_LOCAL
	   ,SUM(AA.CANTIDAD_SKUS)    AS CANTIDAD_SKUS
	   ,SUM(AA.[INSTOCK-CIA])	 AS [INSTOCK-CIA]
	   ,SUM(AA.[INSTOCK-TOP500])    AS [INSTOCK-TOP500]
	   ,SUM(AA.[INSTOCK-TOP2100])    AS [INSTOCK-TOP2100]
	   ,SUM(AA.[INSTOCK-J01])    AS [INSTOCK-J01]
	   ,SUM(AA.[INSTOCK-J02])    AS [INSTOCK-J02]
	   ,SUM(AA.[INSTOCK-J05])    AS [INSTOCK-J05]
	   ,SUM(AA.[INSTOCK-J06])    AS [INSTOCK-J06]
	   ,SUM(AA.[INSTOCK-J07])    AS [INSTOCK-J07]
	 


FROM (
SELECT  [COD_LOCAL]
       ,[NOM_LOCAL]
           																									
     ,CONVERT(NUMERIC(12,1),SUM([NUM_OH_VALORIZADO])/nullif(SUM([NUM_VTA_SEM_X_PERFIL]),0)*100) 		AS [INSTOCK-CIA]
	 ,0																									AS [INSTOCK-J01]
	 ,0																									AS [INSTOCK-J02]
	  ,0 																								AS [INSTOCK-J05]
	   ,0																								AS [INSTOCK-J06] 
	    ,0 																								AS [INSTOCK-J07]
		,0																									AS [INSTOCK-TOP500]
		 ,0																								AS [INSTOCK-TOP2100]
     ,SUM([CANTIDAD_SKUS]) AS [CANTIDAD_SKUS]
    
  FROM [INFORMES3].[dbo].CE_INSTOCK

WHERE     (DIVISION IN ('J05 - FLC','J01 - PGC COMESTIBLE'))  AND (SIS_REPOSICION IN ('Reposicion x ASR', 'Informar a ASR'))
		  OR  (DIVISION IN ('J02 - PGC NO COMESTIBLE')) 
		 AND (SIS_REPOSICION IN ('Reposicion x ASR', 'Informar a ASR'))  
		 OR  (DIVISION IN ('J06 - PANADERIA Y PASTELERIA', 'J07 - PLATOS PREPARADOS')) AND (SIS_REPOSICION IN ('Reposicion x ASR')) 
		
GROUP BY  [NOM_LOCAL]
		 ,[COD_LOCAL]


		  UNION ALL 

SELECT  [COD_LOCAL]
       ,[NOM_LOCAL]
      ,0																								AS [INSTOCK-CIA]     																									
     ,CONVERT(NUMERIC(12,1),SUM([NUM_OH_VALORIZADO])/nullif(SUM([NUM_VTA_SEM_X_PERFIL]),0)*100) 		AS [INSTOCK-J01]
	 ,0																									AS [INSTOCK-J02]
	  ,0 																								AS [INSTOCK-J05] 
	   ,0																								AS [INSTOCK-J06]
	    ,0 																								AS [INSTOCK-J07]
		,0																									AS [INSTOCK-TOP500]
		 ,0																								AS [INSTOCK-TOP2100]
      ,0 AS [CANTIDAD_SKUS]
    
  FROM [INFORMES3].[dbo].CE_INSTOCK

WHERE     (DIVISION IN ('J01 - PGC COMESTIBLE')) AND (SIS_REPOSICION IN ('Reposicion x ASR', 'Informar a ASR')) 
	
GROUP BY  [NOM_LOCAL]
		 ,[COD_LOCAL]

UNION ALL 

 SELECT  [COD_LOCAL]
       ,[NOM_LOCAL]
       ,0																								AS [INSTOCK-CIA]  
	   ,0																								AS [INSTOCK-J01]      																									
     ,CONVERT(NUMERIC(12,1),SUM([NUM_OH_VALORIZADO])/nullif(SUM([NUM_VTA_SEM_X_PERFIL]),0)*100) 		AS [INSTOCK-J02]
	 ,0 																								AS [INSTOCK-J05]
	  ,0																								AS [INSTOCK-J06]
	   ,0 																								AS [INSTOCK-J07]
	   ,0																									AS [INSTOCK-TOP500]
	    ,0																								AS [INSTOCK-TOP2100]
      ,0 AS [CANTIDAD_SKUS]
    
  FROM [INFORMES3].[dbo].CE_INSTOCK

WHERE     (DIVISION IN ('J02 - PGC NO COMESTIBLE')) AND (SIS_REPOSICION IN ('Reposicion x ASR', 'Informar a ASR')) 
GROUP BY  [NOM_LOCAL]
		 ,[COD_LOCAL] 

		  UNION ALL 


 SELECT  [COD_LOCAL]
       ,[NOM_LOCAL]
      ,0																								AS [INSTOCK-CIA]
	 ,0																									AS [INSTOCK-J01]
	 ,0																									AS [INSTOCK-J02]      																									
     ,CONVERT(NUMERIC(12,1),SUM([NUM_OH_VALORIZADO])/nullif(SUM([NUM_VTA_SEM_X_PERFIL]),0)*100) 		AS [INSTOCK-J05]
	  ,0																								AS [INSTOCK-J06]
	   ,0 																								AS [INSTOCK-J07]
	   ,0																									AS [INSTOCK-TOP500]
	    ,0																								AS [INSTOCK-TOP2100]
      ,0 AS [CANTIDAD_SKUS]
    
  FROM [INFORMES3].[dbo].CE_INSTOCK 

WHERE     ((DIVISION IN ('J05 - FLC')) AND (SIS_REPOSICION IN ('Reposicion x ASR', 'Informar a ASR'))) 
                     
  
GROUP BY  [NOM_LOCAL]
		 ,[COD_LOCAL] 

	 UNION ALL

 SELECT  [COD_LOCAL]
       ,[NOM_LOCAL]
      ,0																								AS [INSTOCK-CIA]
	 ,0																									AS [INSTOCK-J01]
	 ,0																									AS [INSTOCK-J02]   
	 ,0																									AS [INSTOCK-J05]     																									
     ,CONVERT(NUMERIC(12,1),SUM([NUM_OH_VALORIZADO])/nullif(SUM([NUM_VTA_SEM_X_PERFIL]),0)*100) 		AS [INSTOCK-J06]
	  ,0 																								AS [INSTOCK-J07]
	  ,0																									AS [INSTOCK-TOP500]
	   ,0																								AS [INSTOCK-TOP2100]
       ,0 AS [CANTIDAD_SKUS]
    
  FROM [INFORMES3].[dbo].CE_INSTOCK

WHERE     (DIVISION IN ('J06 - PANADERIA Y PASTELERIA')) AND (SIS_REPOSICION IN ('Reposicion x ASR')) 
  
GROUP BY  [NOM_LOCAL]
		 ,[COD_LOCAL] 

		 UNION ALL 

SELECT  [COD_LOCAL]
       ,[NOM_LOCAL]
      ,0																								AS [INSTOCK-CIA]
	 ,0																									AS [INSTOCK-J01]
	 ,0																									AS [INSTOCK-J02]   
	 ,0																									AS [INSTOCK-J05]  
	  ,0																								AS [INSTOCK-J06]         																									
     ,CONVERT(NUMERIC(12,1),SUM([NUM_OH_VALORIZADO])/nullif(SUM([NUM_VTA_SEM_X_PERFIL]),0)*100) 		AS [INSTOCK-J07]
	 ,0																									AS [INSTOCK-TOP500]
	  ,0																								AS [INSTOCK-TOP2100]
      ,0 AS [CANTIDAD_SKUS]
    
  FROM [INFORMES3].[dbo].CE_INSTOCK 

WHERE   (DIVISION IN ('J07 - PLATOS PREPARADOS')) AND (SIS_REPOSICION IN ('Reposicion x ASR')) 
                       
  
GROUP BY  [NOM_LOCAL]
		 ,[COD_LOCAL]

		 UNION ALL

SELECT     COD_LOCAL
		  ,NOM_LOCAL
	  ,0																								AS [INSTOCK-CIA]
	 ,0																									AS [INSTOCK-J01]
	 ,0																									AS [INSTOCK-J02]   
	 ,0																									AS [INSTOCK-J05]  
	  ,0																								AS [INSTOCK-J06]  
	  ,0																								AS [INSTOCK-J07] 
      , CONVERT(NUMERIC(12, 1), SUM(NUM_OH_VALORIZADO) / NULLIF (SUM(NUM_VTA_SEM_X_PERFIL), 0) * 100)   AS [INSTOCK-TOP500]
	  ,0																								AS [INSTOCK-TOP2100]
	   ,0 AS [CANTIDAD_SKUS]
                     FROM   [INFORMES3].[dbo].[CE_INSTOCK]
WHERE     ((DIVISION IN ('J05 - FLC','J01 - PGC COMESTIBLE')) AND (SIS_REPOSICION IN ('Reposicion x ASR', 'Informar a ASR')) AND (TOP_500 = 'TOP500'))
		  OR ((DIVISION IN ('J02 - PGC NO COMESTIBLE')) 
		 AND (SIS_REPOSICION IN ('Reposicion x ASR', 'Informar a ASR')) AND (TOP_500 = 'TOP500'))
		 OR  ((DIVISION IN ('J06 - PANADERIA Y PASTELERIA', 'J07 - PLATOS PREPARADOS')) 
		 AND (SIS_REPOSICION IN ('Reposicion x ASR')) AND (TOP_500 = 'TOP500'))
GROUP BY NOM_LOCAL
		,COD_LOCAL


			 UNION ALL

SELECT     COD_LOCAL
		  ,NOM_LOCAL
	  ,0																								AS [INSTOCK-CIA]
	 ,0																									AS [INSTOCK-J01]
	 ,0																									AS [INSTOCK-J02]   
	 ,0																									AS [INSTOCK-J05]  
	  ,0																								AS [INSTOCK-J06]  
	  ,0																								AS [INSTOCK-J07] 
	  ,0																								AS [INSTOCK-TOP500]
      , CONVERT(NUMERIC(12, 1), SUM(NUM_OH_VALORIZADO) / NULLIF (SUM(NUM_VTA_SEM_X_PERFIL), 0) * 100)   AS [INSTOCK-TOP2100]
	   ,0 AS [CANTIDAD_SKUS]
                     FROM   [INFORMES3].[dbo].[CE_INSTOCK]
WHERE     ((DIVISION IN ('J05 - FLC','J01 - PGC COMESTIBLE')) AND (SIS_REPOSICION IN ('Reposicion x ASR', 'Informar a ASR')) AND (TOP_2100 = 'TOP2100'))
		  OR ((DIVISION IN ('J02 - PGC NO COMESTIBLE')) 
		 AND (SIS_REPOSICION IN ('Reposicion x ASR','Informar a ASR')) AND (TOP_2100 = 'TOP2100') )
		 OR  ((DIVISION IN ( 'J06 - PANADERIA Y PASTELERIA', 'J07 - PLATOS PREPARADOS')) 
		 AND (SIS_REPOSICION IN ('Reposicion x ASR')) AND (TOP_2100 = 'TOP2100') )
GROUP BY NOM_LOCAL
		,COD_LOCAL



		 ) AS AA
		 GROUP BY AA.COD_LOCAL
					,AA.NOM_LOCAL

