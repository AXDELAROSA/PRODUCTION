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
	 EXEC [PG_PR_GUARDAR_MATERIAL_PROGRAMADO_LOG] 0 ,144, 'laminacion' , 'IT-010' , 13367 , 'RUWLDLFWLROTX7,Q15-S32629001~32630*200766DTX7%MAGN02#WDL@1!2' , 0 
*/

CREATE PROCEDURE [dbo].[PG_PR_GUARDAR_MATERIAL_PROGRAMADO_LOG]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_USUARIO_EVENTO			VARCHAR(100),
	@PP_ESTACION				VARCHAR(100),
	@PP_K_RESPONSABLE			INT,
	@PP_CODIGO_ETIQUETA			VARCHAR(150),
	@AUTORIZAR_EVENTO_DIFERENTE INT = 0
AS

	SET @PP_USUARIO_EVENTO = UPPER(@PP_USUARIO_EVENTO)
	-- ///////SE DECLARAN VARIABLES A USARSE////////////////////////////////////
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

	-- ///////SE OBTIENE EL ID DEL EVENTO EN BASE AL USUARIO EVENTO////////////////////////////////////
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
	
	 --AGREGADO PARA PRUEBAS FEG
	IF @PP_USUARIO_EVENTO = 'CERTIFICACION'
		SET @VP_TIPO_EVENTO_KIT = 400

	IF @PP_USUARIO_EVENTO = 'LIBERACION_QC'
		SET @VP_TIPO_EVENTO_KIT = 410

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	IF @VP_TIPO_EVENTO_KIT = 0
		SET @VP_MENSAJE = 'Estación no valida.'
	
	IF @VP_MENSAJE = ''
		IF @PP_CODIGO_ETIQUETA = ''
			SET @VP_MENSAJE = 'No se obtuvieron datos de la etiqueta.'

	IF @VP_MENSAJE = ''
		IF LEN(@PP_CODIGO_ETIQUETA) < 30
			SET @VP_MENSAJE = 'Etiqueta no valida.'

	IF @VP_MENSAJE = ''
		BEGIN
			DECLARE @VP_N_RELOJ_EXISTE INT = 0
			SELECT @VP_N_RELOJ_EXISTE = COUNT(EN_NUM_EMP) 
			FROM HOWE.dbo.VISTA_GAFETES (NOLOCK)
			WHERE EN_NUM_EMP = @PP_K_RESPONSABLE

			IF @VP_N_RELOJ_EXISTE IS NULL OR @VP_N_RELOJ_EXISTE = 0
				SET @VP_MENSAJE = 'Numero de Reloj no valido.'
		END

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- ///////SE OBTIENEN LOS DATOS DEL CODIGO DE LA ETIQUETA//////////////////////////////////////////////
				DECLARE @VP_MENSAJE_TRANSACCION VARCHAR(255)= ''
				SET @PP_CODIGO_ETIQUETA = UPPER(@PP_CODIGO_ETIQUETA)
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
																		
				IF (@VP_PART_NO = '' OR @VP_QTY = '' OR  @VP_SERIAL_1 = '' OR @VP_CUSTNO = '' OR @VP_CLIENTE = '' OR @VP_PRODUCT_CAT = '' OR @VP_LOTE_1 = '')
					RAISERROR ('Los datos obtenidos de la etiqueta son incorrectos.', 16, 1 ) --MENSAJE - Severity -State.

				-- ///////SE OBTIENEN LOS DATOS DEL KIT PROGRAMADO//////////////////////////////////////////////
				DECLARE @VP_ITEM_NO_PROGRAMADO VARCHAR(100) = ''
				DECLARE @VP_VERSION VARCHAR(100) = ''
				SELECT	@VP_ITEM_NO_PROGRAMADO = LTRIM(RTRIM(ccjoblin_sql.item_no)),
						@VP_VERSION = LTRIM(RTRIM(cccusitm_sql.versionno))
						-- ===========================
				FROM ccjoblin_sql  (NOLOCK)
				INNER JOIN	cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
				AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
				AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
																FROM	cccusitm_sql (NOLOCK)
																WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
																AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
				-- ===========================
				WHERE	 LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) = @VP_SERIAL_1

				IF @VP_ITEM_NO_PROGRAMADO IS NULL OR @VP_ITEM_NO_PROGRAMADO = ''
					RAISERROR ('No fue posible obtener el Kit del serial en [ccjoblin_sql].', 16, 1 ) --MENSAJE - Severity -State.

				IF @VP_ITEM_NO_PROGRAMADO <> @VP_PART_NO
					BEGIN
						IF SUBSTRING(@VP_PART_NO, 1, 1) <> 'U'
							BEGIN
								SET @VP_MENSAJE_TRANSACCION = 'El kit programado: ' + @VP_ITEM_NO_PROGRAMADO + ' es diferente al kit de la etiqueta: ' + @VP_PART_NO +'.'
								RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
						END
					END

				DECLARE @VP_RUTA_EXISTE INT = 0
				SELECT @VP_RUTA_EXISTE = COUNT(K_KIT_RUTA)
				FROM KIT_RUTA (NOLOCK) 
				WHERE ITEM_NO = @VP_ITEM_NO_PROGRAMADO

				IF @VP_RUTA_EXISTE IS NULL
					SET @VP_RUTA_EXISTE = 0

				IF @VP_RUTA_EXISTE > 0
					BEGIN
						-- ///////SE VERIFICA QUE EL EVENTO QUE SE ESTA REALIZANDO ESTE DENTRO DE LA RUTA DEL KIT//////////////////////////////////////////////
						DECLARE @VP_N_KIT_RUTA_EVENTO INT = 0
						SELECT @VP_N_KIT_RUTA_EVENTO =  COUNT(K_KIT_RUTA)
						FROM KIT_RUTA (NOLOCK)
						WHERE ITEM_NO = @VP_ITEM_NO_PROGRAMADO
						AND MODELNO = @VP_PRODUCT_CAT
						AND VERSIONNO = @VP_VERSION
						AND K_KIT_RUTA_EVENTO =  @VP_TIPO_EVENTO_KIT

						IF ( @VP_N_KIT_RUTA_EVENTO IS NULL OR @VP_N_KIT_RUTA_EVENTO = 0 )
							RAISERROR ('El evento no se encuentra dentro de la ruta del Kit.', 16, 1 ) --MENSAJE - Severity -State.
						
						-- ///////SE OBTIENE EL ORDEN Y DESCRIPCION DEL EVENTO DEL KIT ESCANEADO//////////////////////////////////////////////
						DECLARE @VP_O_KIT_RUTA_EVENTO_ESCANEADO INT = 0
						DECLARE @VP_D_KIT_EVENTO_ESCANEADO VARCHAR(100) = ''
						SELECT @VP_O_KIT_RUTA_EVENTO_ESCANEADO = KIT_RUTA.O_KIT_RUTA_EVENTO,
								@VP_D_KIT_EVENTO_ESCANEADO = D_KIT_RUTA_EVENTO
						FROM KIT_RUTA (NOLOCK)
						INNER JOIN KIT_RUTA_EVENTO (NOLOCK) ON KIT_RUTA_EVENTO.K_KIT_RUTA_EVENTO = KIT_RUTA.K_KIT_RUTA_EVENTO
						WHERE ITEM_NO = @VP_ITEM_NO_PROGRAMADO
						AND MODELNO = @VP_PRODUCT_CAT
						AND VERSIONNO = @VP_VERSION
						AND KIT_RUTA.K_KIT_RUTA_EVENTO =  @VP_TIPO_EVENTO_KIT

						IF ( @VP_O_KIT_RUTA_EVENTO_ESCANEADO IS NULL OR @VP_O_KIT_RUTA_EVENTO_ESCANEADO = 0 )
							RAISERROR ('El fue posible obtener el orden del Evento para el kit Escaneado.', 16, 1 ) --MENSAJE - Severity -State.

						-- ///////SE OBTIENE EL EVENTO ACTUAL DEL KIT//////////////////////////////////////////////
						DECLARE @VP_KIT_EVENTO_ACTUAL INT = 0
						DECLARE @VP_D_KIT_EVENTO_ACTUAL VARCHAR(100) = ''
						SELECT TOP 1 @VP_KIT_EVENTO_ACTUAL = K_TIPO_EVENTO_KIT,
									 @VP_D_KIT_EVENTO_ACTUAL = D_KIT_RUTA_EVENTO
						FROM [MATERIAL_PROGRAMADO_LOG]  (NOLOCK)
						INNER JOIN KIT_RUTA_EVENTO (NOLOCK) ON KIT_RUTA_EVENTO.K_KIT_RUTA_EVENTO = [MATERIAL_PROGRAMADO_LOG].K_TIPO_EVENTO_KIT
						WHERE SERIAL = @VP_SERIAL_1
						ORDER BY K_MATERIAL_PROGRAMADO_LOG DESC

						IF ( @VP_KIT_EVENTO_ACTUAL IS NULL OR @VP_KIT_EVENTO_ACTUAL = 0 )
							RAISERROR ('No fue posible obtener el evento Actual del kit.', 16, 1 ) --MENSAJE - Severity -State.

						-- ///////SE OBTIENE EL ORDEN DEL EVENTO ACTUAL DEL KIT//////////////////////////////////////////////
						DECLARE @VP_O_KIT_RUTA_EVENTO_ACTUAL INT = 0
						SELECT @VP_O_KIT_RUTA_EVENTO_ACTUAL = O_KIT_RUTA_EVENTO
						FROM KIT_RUTA (NOLOCK)
						WHERE ITEM_NO = @VP_ITEM_NO_PROGRAMADO
						AND MODELNO = @VP_PRODUCT_CAT
						AND VERSIONNO = @VP_VERSION
						AND K_KIT_RUTA_EVENTO =  @VP_KIT_EVENTO_ACTUAL

						IF ( @VP_O_KIT_RUTA_EVENTO_ACTUAL IS NULL OR @VP_O_KIT_RUTA_EVENTO_ACTUAL = 0 )
							RAISERROR ('El fue posible obtener el orden del Evento Actual.', 16, 1 ) --MENSAJE - Severity -State.

						-- ///////SE OBTIENE EL EVENTO SIGUIENTE DEL KIT//////////////////////////////////////////////
						DECLARE @VP_O_KIT_RUTA_EVENTO_SIGUIENTE INT = 0
						DECLARE @VP_KIT_EVENTO_SIGUIENTE INT = 0
						DECLARE @VP_D_KIT_EVENTO_SIGUIENTE VARCHAR(100) = ''

						SELECT TOP 1 @VP_KIT_EVENTO_SIGUIENTE =  KIT_RUTA.K_KIT_RUTA_EVENTO,
									 @VP_D_KIT_EVENTO_SIGUIENTE = D_KIT_RUTA_EVENTO,
									 @VP_O_KIT_RUTA_EVENTO_SIGUIENTE = KIT_RUTA.O_KIT_RUTA_EVENTO
						FROM KIT_RUTA (NOLOCK)
						INNER JOIN KIT_RUTA_EVENTO (NOLOCK) ON KIT_RUTA_EVENTO.K_KIT_RUTA_EVENTO = KIT_RUTA.K_KIT_RUTA_EVENTO
						WHERE ITEM_NO = @VP_ITEM_NO_PROGRAMADO
						AND MODELNO = @VP_PRODUCT_CAT
						AND VERSIONNO = @VP_VERSION
						AND KIT_RUTA.O_KIT_RUTA_EVENTO >  @VP_O_KIT_RUTA_EVENTO_ACTUAL

						IF ( @VP_KIT_EVENTO_SIGUIENTE IS NULL OR @VP_KIT_EVENTO_SIGUIENTE = 0 )
							RAISERROR ('No fue posible obtener el evento siguiente del kit.', 16, 1 ) --MENSAJE - Severity -State.

						IF @VP_O_KIT_RUTA_EVENTO_ESCANEADO > @VP_O_KIT_RUTA_EVENTO_SIGUIENTE 
							IF @AUTORIZAR_EVENTO_DIFERENTE = 0
								BEGIN
									SET @VP_MENSAJE_TRANSACCION = 'El kit se encuentra en: ' + @VP_D_KIT_EVENTO_ACTUAL + ' y tiene eventos pendientes, autoriza que los eventos anteriores se realizarón?'
									RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
								END

						IF @VP_O_KIT_RUTA_EVENTO_ESCANEADO < @VP_O_KIT_RUTA_EVENTO_ACTUAL 
							BEGIN
								--DECLARE @VP_D_KIT_EVENTO_ANTERIOR VARCHAR(100) = ''
								--SELECT @VP_D_KIT_EVENTO_ANTERIOR =  D_KIT_RUTA_EVENTO
								--FROM KIT_RUTA_EVENTO (NOLOCK)
								--WHERE K_KIT_RUTA_EVENTO = @VP_TIPO_EVENTO_KIT

								IF @AUTORIZAR_EVENTO_DIFERENTE = 0
									BEGIN
										SET @VP_MENSAJE_TRANSACCION = 'El kit se encuentra en: ' + @VP_D_KIT_EVENTO_ACTUAL + ', desea regresarlo al evento: ' + @VP_D_KIT_EVENTO_ESCANEADO + '?'
										RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
									END
							END
					END

				-- ///////SE GUARDA EL REGISTRO DEL MATERIAL ESCANEADO//////////////////////////////////////////////		
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
				SET @VP_MENSAJE = @VP_ERROR_TRANS
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
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_SERIAL_1 AS CLAVE
	
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


