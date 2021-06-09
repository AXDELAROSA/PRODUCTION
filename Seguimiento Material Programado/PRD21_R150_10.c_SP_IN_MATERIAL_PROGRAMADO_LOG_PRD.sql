
-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			ESTATUS POR ORDEN/SERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	8/JUN/2021
-- //////////////////////////////////////////////////////////////  

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_EVENTO_MAT_PRD_KIT_PROGRAMADO_LOG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_EVENTO_MAT_PRD_KIT_PROGRAMADO_LOG]
GO

/*
	 EXEC [PG_IN_EVENTO_MAT_PRD_KIT_PROGRAMADO_LOG] 0 ,144, '32629' , '20' , 'CORTE_PRD', 'PRD-001', 144 
*/

CREATE PROCEDURE [dbo].[PG_IN_EVENTO_MAT_PRD_KIT_PROGRAMADO_LOG]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ORDEN					VARCHAR(100),
	@PP_TIPO_EVENTO_KIT			INT,
	@PP_USUARIO_EVENTO			VARCHAR(100),
	@PP_ESTACION				VARCHAR(100),
	@PP_K_RESPONSABLE			INT
AS
	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE	VARCHAR(255) = ''
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				DECLARE @VP_ITEM_NO VARCHAR(50) = ''
				DECLARE @VP_SER_NO INT = 0
				
				DECLARE CU_EVENTO_CORTE CURSOR 
				FOR SELECT  LTRIM(RTRIM(ITEM_NO)), SER_NO
					FROM ccjoblin_sql 
					WHERE jobno = @PP_ORDEN
					ORDER BY Ser_No
				
				OPEN CU_EVENTO_CORTE
				FETCH NEXT FROM CU_EVENTO_CORTE INTO  @VP_ITEM_NO, @VP_SER_NO
				
				WHILE @@FETCH_STATUS = 0
					BEGIN
						-- ///////SE GUARDA EL REGISTRO DEL MATERIAL ESCANEADO//////////////////////////////////////////////
						DECLARE @VP_SERIAL VARCHAR(50)  = @PP_ORDEN + RIGHT('000'+ CONVERT(VARCHAR(10), @VP_SER_NO), 3) 
						
						EXECUTE [dbo].[PG_IN_MATERIAL_PROGRAMADO_LOG]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_TIPO_EVENTO_KIT, @VP_SERIAL, @VP_ITEM_NO,
																		@PP_USUARIO_EVENTO, @PP_ESTACION, @PP_K_USUARIO_ACCION, ''

						FETCH NEXT FROM CU_EVENTO_CORTE INTO  @VP_ITEM_NO, @VP_SER_NO
					END
				CLOSE CU_EVENTO_CORTE
				DEALLOCATE CU_EVENTO_CORTE
		-- ///////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_IN_EVENTO_MAT_PRD_KIT_PROGRAMADO_LOG] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible guardar el evento: ' + '[' + @PP_USUARIO_EVENTO +'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_USUARIO_EVENTO AS CLAVE
	-- ////////////////////////////////////////////////////////////////////
GO
	