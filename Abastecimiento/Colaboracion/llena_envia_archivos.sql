		USE msdb
		
		GO
            DECLARE @SW INT
			DECLARE @icont2 INT	
			DECLARE @registros INT
			
			SET @SW = @SW+1
			
			SET @registros= (SELECT   COUNT(*)
             FROM [10.195.254.201].[INFORMES3].[dbo].[BASE_MAILS_PROVEEDORES] where ID <90 ) ---intervalo de envio
			
			--(SELECT   COUNT(*)
   --           FROM [10.195.254.201].[INFORMES3].[dbo].[BASE_MAILS_PROVEEDORES] where ID <90 )
			
			--renviar entre 19 y 30			
					
			SET @icont2 = 79
		
			--SET @icont2=79 --comienza en cero
					
			WHILE @icont2<=@registros	
			
			BEGIN
			     --PRINT @icont2
			    -- PRINT @SW
						
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
			    
			    DECLARE @text2 VARCHAR(MAX)
			    
			    DECLARE @text3 VARCHAR(MAX)
			          
			    SET @text1='C:\ARCHIVOS_PROVEEDORES\INSTOCK_'+@RUT+'.xls'
			    SET @text2='C:\ARCHIVOS_PROVEEDORES\FR_'+@RUT+'.xls'
			    SET @text3='C:\ARCHIVOS_PROVEEDORES\EXPORT_'+@RUT+'.xls'
			          
	 

--=============================LLENAR ARCHIVO==================================================== 
			   
			  
DECLARE @text4 VARCHAR(MAX)
set @text4= '''Microsoft.ACE.OLEDB.12.0''' + ',' + '''Excel 12.0 Xml;HDR=YES;Database='+@text1+'''' + ',' +'''SELECT * FROM [INSTOCK$]'''
--EXEC INFORMES3.[dbo].[SP_INSERTA_DATOS_EXCEL] @text4,@RUT
declare @sql VARCHAR (MAX)
 SET @sql = 'insert into OPENROWSET('+@text4+') SELECT  * FROM [10.195.254.201].[INFORMES3].[dbo].[INSTOCK_NUEVA_PLANILLA_CAMILA] where RUT ='+@RUT
         
exec(@sql) ---> Llenado INSTOCK


DECLARE @text5 VARCHAR(MAX)
set @text5= '''Microsoft.ACE.OLEDB.12.0''' + ',' + '''Excel 12.0 Xml;HDR=YES;Database='+@text2+'''' + ',' +'''SELECT * FROM [FR$]'''
--EXEC INFORMES3.[dbo].[SP_INSERTA_DATOS_EXCEL] @text4,@RUT
declare @sql_2 VARCHAR (MAX)
 SET @sql_2 = 'insert into OPENROWSET('+@text5+') SELECT * FROM [10.195.254.201].INFORMES3.DBO.FR_PROVEEDOR WHERE RUT_PROV = ' + @RUT 
      
exec(@sql_2) ---> Llenado FILLRATE

DECLARE @text6 VARCHAR(MAX)
set @text6= '''Microsoft.ACE.OLEDB.12.0''' + ',' + '''Excel 12.0 Xml;HDR=YES;Database='+@text3+'''' + ',' +'''SELECT * FROM [EXPORT$]'''
--EXEC INFORMES3.[dbo].[SP_INSERTA_DATOS_EXCEL] @text4,@RUT
declare @sql_3 VARCHAR (MAX)
 SET @sql_3 = 'insert into OPENROWSET('+@text6+') SELECT  I.*
														  ,M.[NOM_PROV] DESC_PROVEEDOR
													  FROM [10.195.254.201].[INSTOCK_OPT].[dbo].[INSTOCK_MIN_PRE] I LEFT JOIN 
														  [10.195.254.201].RepNonFood.dbo.MAESTRA_SKU M ON CONVERT(FLOAT,I.[SKU ID]) = CONVERT(FLOAT,M.SKU)
													 WHERE M.RUT_PROV =  ' + @RUT 
													      
exec(@sql_3)  ---> Llenado EXPORT


--================================================================================================					    
					    
			     --	EXEC XP_CMDSHELL @text2
--=================================== ENVIO MAIL ======================================================

-- INSTOCK--
--===============HTML=================================
DECLARE @Html_I nvarchar(max)
DECLARE @Html_F nvarchar(max)
DECLARE @Html_E nvarchar(max)
DECLARE @NOM NVARCHAR(MAX)
DECLARE @FECHA NVARCHAR(MAX)

SET @FECHA = CONVERT(DATE,GETDATE())


SET @NOM = '<td> Estimados(a) <b>'+@NI+' </b></td>
</tr>'
  SET @Html_I = '
						<table border=0  width="100%" >
                        <tr>
					    '
						+ @NOM +
					    '	
						<tr>
						<td><br></td>
						</tr>
						<tr>
							<td> Se adjunta detalle de instock al día de hoy.
						</td>
                        </tr>
                         <td><br></td>
                        <tr>
							<td>Saludos Cordiales.
						</td>
                        </tr>						
						<br>
						<tr>
						<td>
						<BR>
						<BR>
						<img src="https://www.tottus.cl/static/2210a//img/img-com/icons/sup_logo-tottus.png" />
						</td>
						</tr>
						</table>
						'
						 SET @Html_F = '
						<table border=0  width="100%" >
                        <tr>
						'
						+ @NOM +
					    '						
						<tr>
						<td><br></td>
						</tr>
						<tr>
							<td>Junto con saludar, se adjunta detalle de FILLRATE de las últimas 2 semanas.
						</td>
                        </tr>
                         <td><br></td>
                        <tr>
							<td>Saludos Cordiales.
						</td>
                        </tr>						
						<br>
						<tr>
						<td>
						<BR>
						<BR>
						<img src="https://www.tottus.cl/static/2210a//img/img-com/icons/sup_logo-tottus.png" />
						</td>
						</tr>
						</table>
						'
						 SET @Html_E = '
						<table border=0  width="100%" >
                        <tr>
						'
						+ @NOM +
					    '						
						<tr>
						<td><br></td>
						</tr>
						<tr>
							<td>Junto con saludar, se adjunta detalle de EXPORT ASR al dia de hoy.
						</td>
                        </tr>
                         <td><br></td>
                        <tr>
							<td>Saludos Cordiales.
						</td>
                        </tr>						
						<br>
						<tr>
						<td>
						<BR>
						<BR>
						<img src="https://www.tottus.cl/static/2210a//img/img-com/icons/sup_logo-tottus.png" />
						</td>
						</tr>
						</table>
						'
--==================================================
DECLARE @CAB_I NVARCHAR(MAX)
SET @CAB_I = 'Detalle Instock ' + @FECHA

DECLARE @CAB_F NVARCHAR(MAX)
SET @CAB_F = 'Detalle Fillrate ' + @FECHA

DECLARE @CAB_E NVARCHAR(MAX)
SET @CAB_E = 'Detalle Export ASR ' + @FECHA

EXEC sp_send_dbmail

@profile_name='CORREO',

@recipients=@MD,

--@recipients='cfreyes@tottus.cl',

@copy_recipients = @CC, 

@subject=@CAB_I,

@file_attachments =@text1 ,

@body= @Html_I,
@body_format = 'HTML'
---------------------------> Envio Mail Instock
-- FR--

EXEC sp_send_dbmail
@profile_name='CORREO',

@recipients=@MD,

@copy_recipients = @CC, 

@subject=@CAB_F,

@file_attachments =@text2 ,

@body= @Html_F,
@body_format = 'HTML'
---------------------------> Envio Mail Fillrate

-- EXPORT--

EXEC sp_send_dbmail

@profile_name='CORREO',

@recipients=@MD,

@copy_recipients = @CC, 

@subject=@CAB_E,

@file_attachments =@text3 ,
@body= @Html_E,
@body_format = 'HTML'

---------------------------> Envio Mail Export

--=====================================================================================================		           
		          -- print @icont 
				print @RUT
				print @icont2
												
					 SET @icont=@icont+1
					 
									
									
								
						END
			  
			
			  SET @icont2=@icont2+20
			  
			
						
			END
