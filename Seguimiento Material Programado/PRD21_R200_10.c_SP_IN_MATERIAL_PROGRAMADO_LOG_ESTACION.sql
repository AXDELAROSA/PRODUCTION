-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			ESTATUS POR ORDEN/SERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	31/MAY/2021
-- //////////////////////////////////////////////////////////////  

USE [DATA_02] 
GO

-- //////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_GUARDAR_MATERIAL_PROGRAMADO_LOG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_GUARDAR_MATERIAL_PROGRAMADO_LOG]
GO

/*
	 EXEC [PG_PR_GUARDAR_MATERIAL_PROGRAMADO_LOG] 0 ,144, 'PERFORACION' , 'PERFORACION-001' , 13367 , 'RUWLDLFWLROTX7,Q15-S32629001~32630*200766DTX7%MAGN02#WDL@1!2' 
*/

CREATE PROCEDURE [dbo].[PG_PR_GUARDAR_MATERIAL_PROGRAMADO_LOG]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_USUARIO_EVENTO			VARCHAR(100),
	@PP_ESTACION				VARCHAR(100),
	@PP_K_RESPONSABLE			INT,
	@PP_CODIGO_ETIQUETA			VARCHAR(150)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE	VARCHAR(255) = ''
	DECLARE @VP_PART_NO				VARCHAR(50) = '' 
	DECLARE @VP_QTY					VARCHAR(50) = '' 
	DECLARE @VP_SERIAL_1			VARCHAR(50) = '' 
	DECLARE @VP_SERIAL_2			VARCHAR(50) = '' 
	DECLARE @VP_CUSTNO				VARCHAR(50) = '' 
	DECLARE @VP_CLIENTE				VARCHAR(50) = ''
	DECLARE @VP_PRODUCT_CAT			VARCHAR(50) = '' 
	DECLARE @VP_LOTE_1				VARCHAR(50) = '' 
	DECLARE @VP_LOTE_2				VARCHAR(50) = '' 
	DECLARE @VP_TIPO_EVENTO			INT = 0

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	IF @PP_CODIGO_ETIQUETA = ''
		SET @VP_MENSAJE = 'No se obtuvieron datos de la etiqueta'

	IF @VP_MENSAJE = ''
		IF LEN(@PP_CODIGO_ETIQUETA) < 30
			SET @VP_MENSAJE = 'Etiqueta no valida.'

	IF @VP_MENSAJE = ''
		BEGIN
			DECLARE @VP_N_RELOJ_EXISTE INT = 0
			SELECT @VP_N_RELOJ_EXISTE = COUNT(EN_NUM_EMP) 
			FROM HOWE.dbo.VISTA_GAFETES 
			WHERE EN_NUM_EMP = @PP_K_RESPONSABLE

			IF @VP_N_RELOJ_EXISTE IS NULL OR @VP_N_RELOJ_EXISTE = 0
				SET @VP_MENSAJE = 'Numero de Reloj no valido'

		END

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY

				SET @PP_CODIGO_ETIQUETA = UPPER(@PP_CODIGO_ETIQUETA)
				-- ///////SE OBTIENEN LOS DATOS DEL CODIGO DE LA ETIQUETA//////////////////////////////////////////////
				EXECUTE [dbo].[PG_GET_DATO_ETIQUETA_KIT]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_CODIGO_ETIQUETA,
															@OU_PART_NO		 =	@VP_PART_NO			OUTPUT,
															@OU_QTY			 =	@VP_QTY				OUTPUT,
															@OU_SERIAL_1	 =	@VP_SERIAL_1		OUTPUT,
															@OU_SERIAL_2	 =	@VP_SERIAL_2		OUTPUT,
															@OU_CUSTNO		 =  @VP_CUSTNO			OUTPUT,
															@OU_CLIENTE		 =  @VP_CLIENTE			OUTPUT,
															@OU_PRODUCT_CAT	 =  @VP_PRODUCT_CAT 	OUTPUT,
															@OU_LOTE_1		 =  @VP_LOTE_1			OUTPUT,
															@OU_LOTE_2		 =  @VP_LOTE_2			OUTPUT				
			
				-- ///////SE GUARDA EL REGISTRO DEL MATERIAL ESCANEADO//////////////////////////////////////////////	
				--	CLASE MEDIO_PROCESO		
				------------------------------------------------------------------------------------------------
				--EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 300	,'INSP. PERFO.'					, 'INSP-PERFO'		
				--EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 400	,'CERTIFICACION'				, 'CERTIF'				
				--EXECUTE [dbo].[PG_CI_KIT_RUTA_EVENTO] 410	,'LIBERACION QC'				, 'QC-LIBER'				

				DECLARE @VP_TIPO_EVENTO_KIT INT = 0
				IF @PP_USUARIO_EVENTO = 'SKIVING'
					SET @VP_TIPO_EVENTO_KIT = 200

				IF @PP_USUARIO_EVENTO = 'RECUT'
					SET @VP_TIPO_EVENTO_KIT = 210

				IF @PP_USUARIO_EVENTO = 'LAMINACION'
					SET @VP_TIPO_EVENTO_KIT = 220

				IF @PP_USUARIO_EVENTO = 'PERFORACION'
					SET @VP_TIPO_EVENTO_KIT = 230

				IF @PP_USUARIO_EVENTO = 'QUILTING'
					SET @VP_TIPO_EVENTO_KIT = 240

				IF @PP_USUARIO_EVENTO = 'EMBOSSING'
					SET @VP_TIPO_EVENTO_KIT = 250
									
				IF @PP_USUARIO_EVENTO = 'INSP_PERFO'
					SET @VP_TIPO_EVENTO_KIT = 300

				IF @PP_USUARIO_EVENTO = 'CERTIFICACION'
					SET @VP_TIPO_EVENTO_KIT = 400

				IF @PP_USUARIO_EVENTO = 'LIBERACION_QC'
					SET @VP_TIPO_EVENTO_KIT = 410

				IF @PP_USUARIO_EVENTO = 'MFP'
					SET @VP_TIPO_EVENTO_KIT = 420

				IF @PP_USUARIO_EVENTO = 'EMBARCADO'
					SET @VP_TIPO_EVENTO_KIT = 430
				
				IF @PP_USUARIO_EVENTO = 'FACTURADO'
					SET @VP_TIPO_EVENTO_KIT = 440

				SET @VP_SERIAL_1 = SUBSTRING(@VP_SERIAL_1, 2, LEN(@VP_SERIAL_1))
				EXECUTE [dbo].[PG_IN_MATERIAL_PROGRAMADO_LOG]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@VP_TIPO_EVENTO_KIT, @VP_SERIAL_1, @VP_PART_NO, @PP_USUARIO_EVENTO, 
																@PP_ESTACION, @PP_K_RESPONSABLE, @PP_CODIGO_ETIQUETA
			-- ///////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PR_GUARDAR_MATERIAL_PROGRAMADO_LOG] // ' + @VP_ERROR_TRANS
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
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'PROCESO',
													'',
													-- ===========================================
													'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_USUARIO_EVENTO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO


