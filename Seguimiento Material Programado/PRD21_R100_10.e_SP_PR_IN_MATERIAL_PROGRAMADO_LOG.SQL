-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			
-- // OPERACION:		MATERIAL PROGRAMADO LOG 
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	08/JUN/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO


-- EXECUTE [dbo].[PG_IN_RP_FOLIOS] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_MATERIAL_PROGRAMADO_LOG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_MATERIAL_PROGRAMADO_LOG]
GO


CREATE PROCEDURE [dbo].[PG_IN_MATERIAL_PROGRAMADO_LOG]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_TIPO_EVENTO_KIT		INT,
	@PP_SERIAL					VARCHAR(100),
	@PP_ITEM_NO					VARCHAR(100),
	@PP_USUARIO_EVENTO			VARCHAR(100),
	@PP_ESTACION				VARCHAR(100),
	@PP_K_RESPONSABLE			INT,
	@PP_CODIGO_ETIQUETA			VARCHAR(150)

AS

	DECLARE @VP_N_SERIAL_EXISTE INT = 0

	SELECT  @VP_N_SERIAL_EXISTE = COUNT([K_MATERIAL_PROGRAMADO]) 
	FROM [MATERIAL_PROGRAMADO] 
	WHERE SERIAL = @PP_SERIAL

	IF ( @VP_N_SERIAL_EXISTE IS NULL OR @VP_N_SERIAL_EXISTE = 0 )
		BEGIN
			INSERT INTO [MATERIAL_PROGRAMADO]	
					(					
						[K_TIPO_EVENTO_KIT],			
						-- =====================				
						[SERIAL],					
						[ITEM_NO],				
						[USUARIO_EVENTO],			
						[ESTACION],				
						[K_RESPONSABLE],			
						[CODIGO_ETIQUETA],		
						[F_EVENTO],			
						-- ===========================
						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
				VALUES	
					(	@PP_K_TIPO_EVENTO_KIT,				
						@PP_SERIAL,				
						@PP_ITEM_NO,				
						@PP_USUARIO_EVENTO,			
						@PP_ESTACION,						
						@PP_K_RESPONSABLE,		
						@PP_CODIGO_ETIQUETA,								
						GETDATE(),
						-- ===========================				
						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, NULL, NULL )	
		
			IF @@ROWCOUNT = 0
				RAISERROR ('ERROR SP: PG_IN_MATERIAL_PROGRAMADO_LOG', 16, 1 ) --MENSAJE - Severity -State.
		END
	ELSE
		BEGIN
			UPDATE [MATERIAL_PROGRAMADO]	
				SET [K_TIPO_EVENTO_KIT]	= @PP_K_TIPO_EVENTO_KIT,			
					-- =====================			
					[ITEM_NO]			= @PP_ITEM_NO,				
					[USUARIO_EVENTO]	= @PP_USUARIO_EVENTO,			
					[ESTACION]			= @PP_ESTACION,				
					[K_RESPONSABLE]		= @PP_K_RESPONSABLE,			
					[CODIGO_ETIQUETA]	= @PP_CODIGO_ETIQUETA,		
					[F_EVENTO]			= GETDATE(),			
					-- ===========================
					[K_USUARIO_CAMBIO]	= @PP_K_USUARIO_ACCION, 
					[F_CAMBIO]			= GETDATE()
			WHERE SERIAL = @PP_SERIAL

			IF @@ROWCOUNT = 0
				RAISERROR ('ERROR SP: PG_IN_MATERIAL_PROGRAMADO_LOG', 16, 1 ) --MENSAJE - Severity -State.
		END

	INSERT INTO [MATERIAL_PROGRAMADO_LOG]	
					(					
						[K_TIPO_EVENTO_KIT],			
						-- =====================				
						[SERIAL],					
						[ITEM_NO],				
						[USUARIO_EVENTO],			
						[ESTACION],				
						[K_RESPONSABLE],			
						[CODIGO_ETIQUETA],		
						[F_LOG],			
						-- ===========================
						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
				VALUES	
					(	@PP_K_TIPO_EVENTO_KIT,				
						@PP_SERIAL,				
						@PP_ITEM_NO,				
						@PP_USUARIO_EVENTO,			
						@PP_ESTACION,						
						@PP_K_RESPONSABLE,		
						@PP_CODIGO_ETIQUETA,								
						GETDATE(),
						-- ===========================				
						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, NULL, NULL )	
		
		IF @@ROWCOUNT = 0
			RAISERROR ('ERROR SP: PG_IN_MATERIAL_PROGRAMADO_LOG', 16, 1 ) --MENSAJE - Severity -State.
	-- ///////////////////////////////////////////
		

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
