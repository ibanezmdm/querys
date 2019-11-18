			
		USE msdb	
			

			DECLARE @icont2 INT	
			DECLARE @registros INT
			
			
			
			SET @registros= (SELECT   COUNT(*) FROM
                             [10.195.254.201].[INFORMES3].[dbo].[BASE_MAILS_PROVEEDORES]  where ID <90)
						
			
			SET @icont2=79
	        print @icont2	 			
			
			WHILE @icont2<=@registros	
			
			BEGIN
			     PRINT @icont2
					
						DECLARE @tmp_prov TABLE ( 
						               ID   INT 
				                      , N               NVARCHAR(MAX)
									  ,NI              NVARCHAR(MAX)
									  ,RUT             NVARCHAR(MAX)
									  ,MD              NVARCHAR(MAX)
									  ,CC              NVARCHAR(MAX) 
									   ) 
									   
						DELETE FROM @tmp_prov

						--Se insertan los datos 
						INSERT INTO @tmp_prov

                       SELECT   ID
                              ,[NOMBRE]
                              ,[NOMBRE INSTOCK]
                              ,[RUT]
                              ,[MAIL DESTINATARIO ]
                              ,[CC]
                        FROM [10.195.254.201].[INFORMES3].[dbo].[BASE_MAILS_PROVEEDORES]
                        WHERE ID>@icont2
                          ORDER BY ID                      

						--Variables con los mimsmos nombres 
						DECLARE        @ID INT
						               ,@N             NVARCHAR(MAX)
						              ,@NI            NVARCHAR(MAX)
						              ,@RUT           NVARCHAR(MAX)
									  ,@MD            NVARCHAR(MAX) 
									  ,@CC            NVARCHAR(MAX) 
									
									
						
														
						--Variables para el ciclo 
						DECLARE @totalregistros INT, 
								@icont     INT 
								
								
								
						SET @icont = 1
						
                      
                                                 
						--Iniciamos el ciclo 
						WHILE @icont <= 20
						
	--==================================INICIO CICLO RECORRIDO DE DIAS DE LA tabla=============================================================================											  
																								  
						  BEGIN	
							  
								 SELECT @ID=ID
								        ,@N = N 
								     	,@NI = NI
								     	,@RUT=RUT
								     	,@MD=MD
								     	,@CC=CC
								 FROM   @tmp_prov
								 WHERE  id = @icont2+@icont 
								 
				
				 IF @icont2+@icont>@registros
			         begin
			           BREAK;
			         end
							  
			
			    DECLARE @text1 NVARCHAR(MAX)
			    
			  --  DECLARE @text2 VARCHAR(MAX)
			          
			     SET @text1='C:\ARCHIVOS_PROVEEDORES\INSTOCK_'+@RUT+'.xls'
			          
			--  SET @text1='C:\ARCHIVOS_PROVEEDORES\PRUEBA1.xls'
			 
			-- set @text2= 'DEL '+@text1
			 			 						  
            DECLARE @LOG NVARCHAR(MAX)
            
		    exec spExecute_ADODB_SQL @DDL='Create table INSTOCK
						  (CLUSTER_DE_PRODUCTOS VARCHAR
						  ,NOM_PRODUCTO VARCHAR
						  ,SKU VARCHAR
						  ,CANTIDAD FLOAT
						  ,SKU_TOP_TICKET VARCHAR
						  ,SKU_PALLET_READY VARCHAR
						  ,COD_CLASIFICACION_SKU VARCHAR
						  ,ABC_2018 VARCHAR
						  ,ABC_CL_2018 VARCHAR
						  ,IND_SURTIDO VARCHAR
						  ,ESTADO VARCHAR
						  ,TOP_2100 VARCHAR
						  ,TOP_500 VARCHAR
						  ,MMPP VARCHAR
						  ,INV_NEGATIVO VARCHAR
						  ,NOM_LOCAL VARCHAR
						  ,COD_LOCAL VARCHAR
						  ,DIVISION VARCHAR
						  ,DEPARTAMENTO VARCHAR
						  ,SUBDEP VARCHAR
						  ,CLASE VARCHAR
						  ,SUBCLASE VARCHAR
						  ,COD_PROV VARCHAR
						  ,NOM_PROV VARCHAR
						  ,RUT VARCHAR
						  ,MARCA VARCHAR
						  ,METOD_ABAST VARCHAR
						  ,ON_HAND FLOAT
						  ,ON_ORDER FLOAT
						  ,NUM_OH_VALORIZADO NUMERIC
						  ,NUM_OH_BINARIO_ FLOAT
						  ,NUM_VTA_SEM_X_PERFIL NUMERIC
						  ,INV_IMPORTADOS VARCHAR
						  ,VTA_PERDIDA_VP VARCHAR
						  ,OH_QUIEBRE VARCHAR
						  ,UN_INV_DISP_HOY FLOAT
						  ,COSTO_INV_DISP_HOY FLOAT
						  ,UN_VTA FLOAT
						  ,MONTO_VTA FLOAT
						  ,CANTIDAD_SKUS FLOAT
						  ,DEMANDA_SEMANAL VARCHAR
						  ,FECHA_ACTUALIZ VARCHAR
						  ,SIS_REPOSICION VARCHAR
						  ,PROCEDENCIA VARCHAR
						  ,RESPONSABLE VARCHAR)',
						  
					
				
						  
					--	@DataSource =@text1
					    @DataSource =@text1;
					    
					SET @LOG = 'INSERT INTO [10.195.254.201].[INFORMES3].[dbo].LOG_MAIL_PROVEEDORES VALUES ('+@RUT+',''INSTOCK'',GETDATE())'	
					EXEC (@LOG)	
					    
		   DECLARE @text2 NVARCHAR(MAX)
			    
	          
		   SET @text2='C:\ARCHIVOS_PROVEEDORES\FR_'+@RUT+'.xls'         
		
					   
			
		   exec spExecute_ADODB_SQL @DDL='Create table FR
						  (SEMANA VARCHAR
						  ,NOM_SEMANA VARCHAR
						  ,CHILD_LOCAL FLOAT
						  ,NOM_LOCAL VARCHAR
						  ,COD_LOCAL FLOAT
						  ,NUM_OC FLOAT
						  ,TIPO_OC VARCHAR
						  ,MOTIVO_CANCELACION VARCHAR
						  ,ESTADO_OC FLOAT
						  ,DESC_ESTADO VARCHAR
						  ,FECHA_LIBERA_OC VARCHAR
						  ,DIA_ANALISIS VARCHAR
						  ,DESC_FECHA_D_ANALISIS VARCHAR
						  ,FECHA_PRIMERA_RECEP_LIN VARCHAR
						  ,FECHA_ULTIM_RECEP_LIN VARCHAR
						  ,FECHA_CANCELACION VARCHAR
						  ,COD_PROV FLOAT
						  ,DESC_PROV VARCHAR
						  ,RUT_PROV FLOAT
						  ,SKU_M VARCHAR
						  ,NSG VARCHAR
						  ,COPIA_OC VARCHAR
						  ,PROV_CENTRALIZADOS VARCHAR
						  ,NOM_DIVISION VARCHAR
						  ,NOM_SUBDEP VARCHAR
						  ,NOM_PRODUCTO VARCHAR
						  ,SKU FLOAT
						  ,EXHIBICION VARCHAR
						  ,TOP_2100 VARCHAR
						  ,TOP_500 VARCHAR
						  ,EAN FLOAT
						  ,NOM_COMPRADOR VARCHAR
						  ,USER_COMPRADOR VARCHAR
						  ,CASE_PACK FLOAT
						  ,MARCA VARCHAR
						  ,NOM_CLASE VARCHAR
						  ,COST_NETO_SOLICI FLOAT
						  ,COST_NETO_RECIB FLOAT
						  ,UN_SOLICI FLOAT
						  ,CAJAS_SOLICITADAS FLOAT
						  ,UN_RECIBI FLOAT
						  ,CAJAS_RECIBIDAS FLOAT
						  ,CAJAS_NO_DESP FLOAT)',
						  
						
						  
					--	@DataSource =@text1
					    @DataSource =@text2;
					    
					SET @LOG = 'INSERT INTO [10.195.254.201].[INFORMES3].[dbo].LOG_MAIL_PROVEEDORES VALUES ('+@RUT+',''FILLRATE'',GETDATE())'	
					EXEC (@LOG)
					    
			     DECLARE @text3 NVARCHAR(MAX)		    
	
			          
			     SET @text3='C:\ARCHIVOS_PROVEEDORES\EXPORT_'+@RUT+'.xls'			          

					    
			     exec spExecute_ADODB_SQL @DDL='Create table EXPORT
						   (SKU_ID FLOAT
                     	  ,SKU_Name VARCHAR
                     	  ,Store_ID VARCHAR
                     	  ,Store_Name VARCHAR
                     	  ,Source_ID VARCHAR
                     	  ,Source_Name VARCHAR
                     	  ,MFG_ID VARCHAR
						  ,On_Hand FLOAT
						  ,On_Order FLOAT
						  ,Current_Balance FLOAT
						  ,Reserved VARCHAR
						  ,Safety_Stock FLOAT
						  ,Min_Presentation_Stock FLOAT
						  ,Units_per_Case FLOAT
						  ,Service_Level_Goal FLOAT
						  ,Buyer_Class VARCHAR
						  ,Demand_Weekly FLOAT
						  ,OUTL_Hard_Max FLOAT	
						  ,Sales_Price FLOAT
						  ,Sold_Week_To_Date VARCHAR
						  ,OUTL_Units FLOAT	  
					      ,In_Lieu_Of_Plans FLOAT
						  ,SOQ_Actual FLOAT
						  ,Super_Source_ID VARCHAR
						  ,SKU_Group_1 VARCHAR
						  ,SKU_Group_2 VARCHAR
						  ,SKU_Group_3 VARCHAR
						  ,SKU_Group_4 VARCHAR
				     	  ,DESC_PROVEEDOR VARCHAR)',
				     	  
				    				
				     	  							  
					--	@DataSource =@text1
					    @DataSource =@text3;
		
					SET @LOG = 'INSERT INTO [10.195.254.201].[INFORMES3].[dbo].LOG_MAIL_PROVEEDORES VALUES ('+@RUT+',''EXPORT'',GETDATE())'	
					EXEC (@LOG)		
					 
					    
					    --WAITFOR DELAY '00:00:20'
--=============================LLENAR ARCHIVO==================================================== 


--================================================================================================					    
					    
			     --	EXEC XP_CMDSHELL @text2
--=================================== ENVIO MAIL ======================================================






--=====================================================================================================		           
		           print @icont 
				 print @icont2	 
												
					 SET @icont=@icont+1
					 
									
									
								
						END
			  
			
			  SET @icont2=@icont2+20
			  
			     print @icont 
				 print @icont2	
						
			END
