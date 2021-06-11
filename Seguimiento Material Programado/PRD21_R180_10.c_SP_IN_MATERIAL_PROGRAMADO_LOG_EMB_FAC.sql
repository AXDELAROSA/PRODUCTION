
-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			ESTATUS POR ORDEN/SERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	11/JUN/2021
-- //////////////////////////////////////////////////////////////  

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_EVENTO_EMBARCADO_FACTURADO_KIT_PROGRAMADO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_EVENTO_EMBARCADO_FACTURADO_KIT_PROGRAMADO]
GO

/*
	 EXEC [PG_IN_EVENTO_EMBARCADO_FACTURADO_KIT_PROGRAMADO] 0 ,144, 440, '557800' , 'FACTURACION' , 13367, ''
*/

CREATE PROCEDURE [dbo].[PG_IN_EVENTO_EMBARCADO_FACTURADO_KIT_PROGRAMADO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TIPO_EVENTO_KIT			INT,
	@PP_USUARIO_EVENTO			VARCHAR(100),
	@PP_ESTACION				VARCHAR(100),
	@PP_K_RESPONSABLE			INT,
	@PP_CODIGO_ETIQUETA			VARCHAR(255)
AS
	-- ///////////////////////////////////////////
	DECLARE @VP_ITEM_NO VARCHAR(50) = ''
	DECLARE @VP_SERIAL VARCHAR(50) = ''
	
	IF @PP_TIPO_EVENTO_KIT = 430 
		BEGIN
			DECLARE CU_EVENTO_EMB_FACT CURSOR 
			FOR SELECT  ITEM_NO, SERIAL_1
				FROM INVENTARIO_EMBARQUE 
				WHERE PACKING_NO = @PP_USUARIO_EVENTO
		END
	ELSE
		BEGIN
			DECLARE CU_EVENTO_EMB_FACT CURSOR 
			FOR SELECT  ITEM_NO, SERIAL_1
				FROM INVENTARIO_EMBARQUE 
				WHERE INVOICE_NO = @PP_USUARIO_EVENTO
		END

	OPEN CU_EVENTO_EMB_FACT
	FETCH NEXT FROM CU_EVENTO_EMB_FACT INTO  @VP_ITEM_NO, @VP_SERIAL
	
	WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE @VP_N_SERIAL_EXISTE INT = 0

			SELECT  @VP_N_SERIAL_EXISTE = COUNT([K_MATERIAL_PROGRAMADO]) 
			FROM [MATERIAL_PROGRAMADO] 
			WHERE SERIAL = @VP_SERIAL

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
							(	@PP_TIPO_EVENTO_KIT,				
								@VP_SERIAL,				
								@VP_ITEM_NO,				
								@PP_USUARIO_EVENTO,			
								@PP_ESTACION,						
								@PP_K_RESPONSABLE,		
								@PP_CODIGO_ETIQUETA,								
								GETDATE(),
								-- ===========================				
								@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
								0, NULL, NULL )	
				
					IF @@ROWCOUNT = 0
						RAISERROR ('ERROR SP: PG_IN_EVENTO_EMBARCADO_FACTURADO_KIT_PROGRAMADO_LOG', 16, 1 ) --MENSAJE - Severity -State.
				END
			ELSE
				BEGIN
					UPDATE [MATERIAL_PROGRAMADO]	
						SET [K_TIPO_EVENTO_KIT]	= @PP_TIPO_EVENTO_KIT,			
							-- =====================			
							[ITEM_NO]			= @VP_ITEM_NO,				
							[USUARIO_EVENTO]	= @PP_USUARIO_EVENTO,			
							[ESTACION]			= @PP_ESTACION,				
							[K_RESPONSABLE]		= @PP_K_RESPONSABLE,			
							[CODIGO_ETIQUETA]	= @PP_CODIGO_ETIQUETA,		
							[F_EVENTO]			= GETDATE(),			
							-- ===========================
							[K_USUARIO_CAMBIO]	= @PP_K_USUARIO_ACCION, 
							[F_CAMBIO]			= GETDATE()
					WHERE SERIAL = @VP_SERIAL

					IF @@ROWCOUNT = 0
						RAISERROR ('ERROR SP: PG_IN_EVENTO_EMBARCADO_FACTURADO_KIT_PROGRAMADO_LOG', 16, 1 ) --MENSAJE - Severity -State.
				END

			FETCH NEXT FROM CU_EVENTO_EMB_FACT INTO  @VP_ITEM_NO, @VP_SERIAL
		END
	CLOSE CU_EVENTO_EMB_FACT
	DEALLOCATE CU_EVENTO_EMB_FACT

	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO
	