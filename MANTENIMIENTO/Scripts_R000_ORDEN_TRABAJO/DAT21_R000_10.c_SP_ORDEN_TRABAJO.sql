-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		COMPRAS
-- // MODULE:			ORDENES_TRABAJO
-- // OPERATION:		SP'S
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA
-- // CREATION DATE:	20211101
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- ///////			CONTENIDO DEL SP
--	[PG_LI_ORDEN_TRABAJO]
--	[PG_SK_ORDEN_TRABAJO]
--	[PG_IN_ORDEN_TRABAJO]
--	[PG_UP_ORDEN_TRABAJO]
--	[PG_UP_ESTATUS_ORDEN_TRABAJO]
----	[PG_UP_ESTATUS_ORDEN_TRABAJO_TOOL]
----	[PG_UP_ESTATUS_ORDEN_TRABAJO_TOOL_MANTENIMIENTO]
--	[PG_DL_ORDEN_TRABAJO]
--	[PG_IN_ORDEN_TRABAJO_DESDE_TPO]
--	[PG_IN_ORDEN_TRABAJO_DESDE_TOOL_SET]
--	[PG_PR_ENVIAR_CORREO_ORDEN_TRABAJO]
--	[PG_PR_ENVIAR_CORREO_ORDEN_TRABAJO_HERRAMENTAL]
-- //////////////////////////////////////////////////////////////
--	[PG_IN_ORDEN_TRABAJO_DETALLE]		-- COMENTADO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_ORDEN_TRABAJO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_ORDEN_TRABAJO]
GO
--		 EXECUTE [dbo].[PG_LI_ORDEN_TRABAJO] 0,139,-1,null,null
CREATE PROCEDURE [dbo].[PG_LI_ORDEN_TRABAJO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_STATUS_ORDEN_TRABAJO		INT,
	@PP_F_INIT						DATE,
	@PP_F_FINISH					DATE
AS
	-- ///////////////////////////////////////////
	-- =========================================		
	-- =========================================
	SELECT		TOP (5000)
				(	CASE
						WHEN	CONCAT(USOLICI.NOMBRE,' ',USOLICI.APELLIDO_PATERNO)	= '' THEN	USOLICI.D_USUARIO_PEARL
						ELSE	CONCAT(USOLICI.NOMBRE,' ',USOLICI.APELLIDO_PATERNO)
				END	)	AS REQUERIDO_POR,				
				(	CASE
						WHEN	CONCAT(URECIBE.NOMBRE,' ',URECIBE.APELLIDO_PATERNO)	= '' THEN	URECIBE.D_USUARIO_PEARL
						ELSE	CONCAT(URECIBE.NOMBRE,' ',URECIBE.APELLIDO_PATERNO)
				END	)	AS RECIBIDO_POR,
				-- =============================
				D_STATUS_ORDEN_TRABAJO,	
				-- =============================
				D_ESTACION_TRABAJO,
				D_SUB_ESTACION_TRABAJO,
				-- =============================
				ISNULL(K_TPO_CUSTOMER,0) AS K_TPO_CUSTOMER,
				-- =============================
				ORDEN_TRABAJO.*
				-- =============================
	FROM		ORDEN_TRABAJO			(NOLOCK)
	INNER JOIN 	STATUS_ORDEN_TRABAJO	(NOLOCK) ON STATUS_ORDEN_TRABAJO.K_STATUS_ORDEN_TRABAJO	= ORDEN_TRABAJO.K_STATUS_ORDEN_TRABAJO
	INNER JOIN	BD_GENERAL.DBO.USUARIO_PEARL	AS USOLICI	(NOLOCK) ON USOLICI.K_USUARIO_PEARL	= ORDEN_TRABAJO.K_USUARIO_SOLICITA
	LEFT JOIN	BD_GENERAL.DBO.USUARIO_PEARL	AS URECIBE	(NOLOCK) ON URECIBE.K_USUARIO_PEARL	= ORDEN_TRABAJO.K_USUARIO_RECIBE
	LEFT JOIN	ESTACION_TRABAJO		(NOLOCK) ON ESTACION_TRABAJO.K_ESTACION_TRABAJO			= ORDEN_TRABAJO.K_ESTACION
	LEFT JOIN	SUB_ESTACION_TRABAJO	(NOLOCK) ON SUB_ESTACION_TRABAJO.K_SUB_ESTACION_TRABAJO	= ORDEN_TRABAJO.K_SUB_ESTACION
				-- =============================
	LEFT JOIN	TPO_CUSTOMER_DET_SET_COTIZADO	(NOLOCK) ON TPO_CUSTOMER_DET_SET_COTIZADO.K_ORDEN_TRABAJO	= ORDEN_TRABAJO.K_ORDEN_TRABAJO
				-- =============================
	WHERE		( @PP_K_STATUS_ORDEN_TRABAJO	=-1		OR	ORDEN_TRABAJO.K_STATUS_ORDEN_TRABAJO	= @PP_K_STATUS_ORDEN_TRABAJO )
				-- =============================
	AND			( @PP_F_INIT		IS NULL		OR		@PP_F_INIT		<=	F_ORDEN_TRABAJO	)
	AND			( @PP_F_FINISH		IS NULL		OR		@PP_F_FINISH	>=	F_ORDEN_TRABAJO	)
	AND			ORDEN_TRABAJO.L_BORRADO	<> 1
	ORDER BY	F_ORDEN_TRABAJO		DESC,	O_STATUS_ORDEN_TRABAJO DESC
	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_ORDEN_TRABAJO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_ORDEN_TRABAJO]
GO
--		 EXECUTE [dbo].[PG_SK_ORDEN_TRABAJO] 0,139,	1
--		 EXECUTE [dbo].[PG_SK_ORDEN_TRABAJO] 0,139,	2
--		 EXECUTE [dbo].[PG_SK_ORDEN_TRABAJO] 0,139,	3
--		 EXECUTE [dbo].[PG_SK_ORDEN_TRABAJO] 0,139,	20
--		 EXECUTE [dbo].[PG_SK_ORDEN_TRABAJO] 0,139,	23
CREATE PROCEDURE [dbo].[PG_SK_ORDEN_TRABAJO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_TRABAJO				INT
AS
	-- ///////////////////////////////////////////
	-- =========================================		
	-- =========================================
	SELECT		TOP (1)
				(	CASE
						WHEN	CONCAT(USOLICI.NOMBRE,' ',USOLICI.APELLIDO_PATERNO)	= '' THEN	USOLICI.D_USUARIO_PEARL
						ELSE	CONCAT(USOLICI.NOMBRE,' ',USOLICI.APELLIDO_PATERNO)
				END	)	AS REQUERIDO_POR,				
				(	CASE
						WHEN	CONCAT(URECIBE.NOMBRE,' ',URECIBE.APELLIDO_PATERNO)	= '' THEN	URECIBE.D_USUARIO_PEARL
						ELSE	CONCAT(URECIBE.NOMBRE,' ',URECIBE.APELLIDO_PATERNO)
				END	)	AS RECIBIDO_POR,
				-- =============================
				D_STATUS_ORDEN_TRABAJO,	
				-- =============================
				D_ESTACION_TRABAJO,
				D_SUB_ESTACION_TRABAJO,
				-- =============================
				(	CASE
						WHEN	(	SELECT COUNT(K_TOOL_SET_ORDEN_TRABAJO)	FROM TOOL_SET_ORDEN_TRABAJO (NOLOCK)	 WHERE	K_ORDEN_TRABAJO = @PP_K_ORDEN_TRABAJO ) > 0 THEN	1
						WHEN	(	SELECT COUNT(K_TOOL_SET_ORDEN_TRABAJO)	FROM TOOL_SET_ORDEN_TRABAJO (NOLOCK)	 WHERE	K_ORDEN_TRABAJO = @PP_K_ORDEN_TRABAJO ) = 0 THEN													
								(	SELECT	COUNT(K_TPO_CUSTOMER_DET_SET_COTIZADO)
									FROM	TPO_CUSTOMER_DET_SET_COTIZADO (NOLOCK) 
									WHERE	TPO_CUSTOMER_DET_SET_COTIZADO.K_ORDEN_TRABAJO	= ORDEN_TRABAJO.K_ORDEN_TRABAJO )
				END	) AS L_DETALLE_DADOS,
				-- =============================
				( CASE
					WHEN	CONCAT(USOLICI.K_USUARIO_DEPARTAMENTO,'-',USOLICI.K_CLASE_DEPARTAMENTO) =	(	SELECT	CONCAT(K_USUARIO_DEPARTAMENTO,'-',K_CLASE_DEPARTAMENTO) 
																											FROM	BD_GENERAL.DBO.USUARIO_PEARL (NOLOCK) 
																											WHERE	K_USUARIO_PEARL	= @PP_K_USUARIO_ACCION	)
																									THEN	1
					ELSE	0
				END ) AS L_MISMO_DEPARTAMENTO,
				-- =============================
				ORDEN_TRABAJO.*
				-- =============================
	FROM		ORDEN_TRABAJO			(NOLOCK)
	INNER JOIN 	STATUS_ORDEN_TRABAJO	(NOLOCK) ON STATUS_ORDEN_TRABAJO.K_STATUS_ORDEN_TRABAJO	= ORDEN_TRABAJO.K_STATUS_ORDEN_TRABAJO
	INNER JOIN	BD_GENERAL.DBO.USUARIO_PEARL	AS USOLICI	(NOLOCK) ON USOLICI.K_USUARIO_PEARL	= ORDEN_TRABAJO.K_USUARIO_SOLICITA
	LEFT JOIN	BD_GENERAL.DBO.USUARIO_PEARL	AS URECIBE	(NOLOCK) ON URECIBE.K_USUARIO_PEARL	= ORDEN_TRABAJO.K_USUARIO_RECIBE
	LEFT JOIN	ESTACION_TRABAJO		(NOLOCK) ON ESTACION_TRABAJO.K_ESTACION_TRABAJO			= ORDEN_TRABAJO.K_ESTACION
	LEFT JOIN	SUB_ESTACION_TRABAJO	(NOLOCK) ON SUB_ESTACION_TRABAJO.K_SUB_ESTACION_TRABAJO	= ORDEN_TRABAJO.K_SUB_ESTACION
				-- =============================
	WHERE		K_ORDEN_TRABAJO		= @PP_K_ORDEN_TRABAJO
				-- =============================
	ORDER BY	F_ORDEN_TRABAJO		DESC
	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //		PARA MOSTRAR EL DETALLE DE LOS DADOS EN LA ORDEN
-- //		DE MANTENIMIENTO.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_HDR_ORDEN_TRABAJO_REPORTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_HDR_ORDEN_TRABAJO_REPORTE]
GO
--		 EXECUTE [dbo].[PG_SK_HDR_ORDEN_TRABAJO_REPORTE] 0,139,1
--		 EXECUTE [dbo].[PG_SK_HDR_ORDEN_TRABAJO_REPORTE] 0,139,2
--		 EXECUTE [dbo].[PG_SK_HDR_ORDEN_TRABAJO_REPORTE] 0,139,3
--		 EXECUTE [dbo].[PG_SK_HDR_ORDEN_TRABAJO_REPORTE] 0,139,4
--		 EXECUTE [dbo].[PG_SK_HDR_ORDEN_TRABAJO_REPORTE] 0,139,5
--		 EXECUTE [dbo].[PG_SK_HDR_ORDEN_TRABAJO_REPORTE] 0,139,6
--		 EXECUTE [dbo].[PG_SK_HDR_ORDEN_TRABAJO_REPORTE] 0,139,7
--		 EXECUTE [dbo].[PG_SK_HDR_ORDEN_TRABAJO_REPORTE] 0,139,20
CREATE PROCEDURE [dbo].[PG_SK_HDR_ORDEN_TRABAJO_REPORTE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_TRABAJO				INT
AS
	DECLARE  @VP_MENSAJE			NVARCHAR(MAX) = ''
			,@VP_NOMBRE				VARCHAR(500)
	-- ///////////////////////////////////////////
	SELECT		TOP (1)
				CONCAT(USOLICI.NOMBRE,' ',USOLICI.APELLIDO_PATERNO)	AS REQUERIDO_POR,
				-- =============================
				D_STATUS_ORDEN_TRABAJO,	
				-- =============================
				CONCAT(	D_ESTACION_TRABAJO ,' (' + D_SUB_ESTACION_TRABAJO + ')') AS D_ESTACION_TRABAJO,
				-- =============================
				FORMAT(K_ORDEN_TRABAJO,'000000')		AS K_ORDEN_TRABAJO,
				--CONVERT(varchar,F_ORDEN_TRABAJO,106)	AS F_ORDEN_TRABAJO,
				CONVERT(VARCHAR(100),F_ORDEN_TRABAJO,106)	AS F_ORDEN_TRABAJO,-- 25/OCT/2021
				-- =============================
				D_ORDEN_TRABAJO,
				ACCION_REALIZADA,
				C_ORDEN_TRABAJO,
				-- =============================
				D_TECNICO_REALIZA,
				DURACION_TOTAL_MINUTOS,
				CONCAT(URECIBE.NOMBRE,' ',URECIBE.APELLIDO_PATERNO)	AS RECIBIDO_POR
				--ORDEN_TRABAJO.*
	FROM		ORDEN_TRABAJO			(NOLOCK)
	INNER JOIN 	STATUS_ORDEN_TRABAJO	(NOLOCK) ON STATUS_ORDEN_TRABAJO.K_STATUS_ORDEN_TRABAJO	= ORDEN_TRABAJO.K_STATUS_ORDEN_TRABAJO
	INNER JOIN	BD_GENERAL.DBO.USUARIO_PEARL	AS USOLICI	(NOLOCK) ON USOLICI.K_USUARIO_PEARL	= ORDEN_TRABAJO.K_USUARIO_SOLICITA
	LEFT JOIN	BD_GENERAL.DBO.USUARIO_PEARL	AS URECIBE	(NOLOCK) ON URECIBE.K_USUARIO_PEARL	= ORDEN_TRABAJO.K_USUARIO_RECIBE
	LEFT JOIN	ESTACION_TRABAJO		(NOLOCK) ON ESTACION_TRABAJO.K_ESTACION_TRABAJO			= ORDEN_TRABAJO.K_ESTACION
	LEFT JOIN	SUB_ESTACION_TRABAJO	(NOLOCK) ON SUB_ESTACION_TRABAJO.K_SUB_ESTACION_TRABAJO	= ORDEN_TRABAJO.K_SUB_ESTACION
				-- =============================
	WHERE		K_ORDEN_TRABAJO			= @PP_K_ORDEN_TRABAJO
	AND			K_TIPO_ORDEN_TRABAJO	= 0
				-- =============================
	ORDER BY	F_ORDEN_TRABAJO		DESC
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / ORDEN_TRABAJO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_ORDEN_TRABAJO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_ORDEN_TRABAJO]
GO		
CREATE PROCEDURE [dbo].[PG_IN_ORDEN_TRABAJO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ============================
	--@PP_K_USUARIO_SOLICITA			INT,
	--@PP_K_USUARIO_RECIBE			INT,	
	-- ============================
	@PP_K_STATUS_ORDEN_TRABAJO		INT,
	-- ============================
	@PP_K_ESTACION					INT,
	@PP_K_SUB_ESTACION				INT,
	-- ============================
	@PP_D_ORDEN_TRABAJO				NVARCHAR(MAX),
	@PP_F_ORDEN_TRABAJO				DATE,
	-- ============================
	@PP_DURACION_TOTAL_MINUTOS		INT,
	-- ============================	
	--@PP_K_TIPO_ORDEN_TRABAJO		INT,	
	--@PP_K_MOTIVO_ORDEN_TRABAJO		INT,
	-- ============================	
	--@PP_RUTA_ORDEN_TRABAJO			NVARCHAR(MAX),
	-- ============================
	@PP_N_TECNICO_REALIZA			INT,
	@PP_D_TECNICO_REALIZA			VARCHAR(500),
	-- ============================
	--@PP_DURACION_MINUTOS			
	@PP_ACCION_REALIZADA			NVARCHAR(MAX),	
	@PP_C_ORDEN_TRABAJO				NVARCHAR(MAX)
	-----=====================================================
	--@PP_K_DET_TOOL_ARRAY			NVARCHAR(MAX),
	--@PP_CANT_FABRI_ARRAY			NVARCHAR(MAX)
AS			
DECLARE  @VP_MENSAJE				NVARCHAR(MAX)	= ''
		,@VP_K_ORDEN_TRABAJO		INT				= 0
BEGIN TRANSACTION 
BEGIN TRY
	-- /////////////////////////////////////////////////////////////////////
	IF ( (	SELECT	CONCAT(K_USUARIO_DEPARTAMENTO,'-',K_CLASE_DEPARTAMENTO) 
			FROM	BD_GENERAL.DBO.USUARIO_PEARL (NOLOCK) 
			WHERE	K_USUARIO_PEARL	= @PP_K_USUARIO_ACCION	) = '5-2' )
	BEGIN
		SET @VP_MENSAJE='Los usuarios de mantenimiento no pueden generar una orden de trabajo.'
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END
	-- /////////////////////////////////////////////////////////////////////
	IF @PP_D_ORDEN_TRABAJO	= ''
	BEGIN
		SET @VP_MENSAJE='Se debe indicar una Descripción para la orden de Trabajo.'
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END
	
	SET	@PP_K_STATUS_ORDEN_TRABAJO	= 10
	SET	@PP_F_ORDEN_TRABAJO			= GETDATE()
	SET	@PP_DURACION_TOTAL_MINUTOS	= 0
	SET	@PP_N_TECNICO_REALIZA		= 0
	SET	@PP_D_TECNICO_REALIZA		= 0
	SET	@PP_ACCION_REALIZADA		= ''
	SET	@PP_C_ORDEN_TRABAJO			= ''
	--============================================================================
	--======================================INSERTAR EL ORDEN_TRABAJO
	--============================================================================
		INSERT INTO ORDEN_TRABAJO
			(	[K_USUARIO_SOLICITA]			,	[K_USUARIO_RECIBE]			,	--	1
				-- ============================
				[K_STATUS_ORDEN_TRABAJO]		,									--	2
				-- ============================
				[K_ESTACION]					,	[K_SUB_ESTACION]			,	--	3
				-- ============================
				[D_ORDEN_TRABAJO]				,	[F_ORDEN_TRABAJO]			,	--	4
				-- ============================
				[DURACION_TOTAL_MINUTOS]		,									--	5
				-- ============================	
				[K_TIPO_ORDEN_TRABAJO]			,	[K_MOTIVO_ORDEN_TRABAJO]	,	--	6
				-- ============================	
				[RUTA_ORDEN_TRABAJO]			,									--	7
				[N_TECNICO_REALIZA]				,	[D_TECNICO_REALIZA]			,	--	8
				-- =========================
				[ACCION_REALIZADA]				,									--	9		[DURACION_MINUTOS]				,	
				[C_ORDEN_TRABAJO]				,									--	10
				-- ===========================
				[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
		VALUES	
			(	@PP_K_USUARIO_ACCION			,	0							,	--	1
				-- ============================
				10								,									--	2					--	#1: ES EL ESTATUS INICIAL DE @PP_K_STATUS_ORDEN_TRABAJO	,
				-- ============================
				@PP_K_ESTACION					,	@PP_K_SUB_ESTACION			,	--	3
				-- ============================
				@PP_D_ORDEN_TRABAJO				,	@PP_F_ORDEN_TRABAJO			,	--	4
				-- ============================
				@PP_DURACION_TOTAL_MINUTOS		,									--	5
				-- ============================
				0								,	0							,	--	6
				-- ============================
				''								,									--	7
				@PP_N_TECNICO_REALIZA			,	@PP_D_TECNICO_REALIZA		,	--	8
				-- =========================
				@PP_ACCION_REALIZADA			,									--	9
				@PP_C_ORDEN_TRABAJO				,									--	10
				-- ============================
				@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),	
				0, NULL, NULL  )

			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='El registro no se ingresó. [OTR#'+CONVERT(VARCHAR(10),@VP_K_ORDEN_TRABAJO)+']'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
			END
			ELSE
			BEGIN
				SELECT @VP_K_ORDEN_TRABAJO	= SCOPE_IDENTITY()

				IF	( @VP_K_ORDEN_TRABAJO	= 0 OR @VP_K_ORDEN_TRABAJO IS NULL )
				BEGIN
					RAISERROR ('Error en la asignación de identidad.', 16, 1 ) 
				END
			END

-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH	
	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [Insertar]: ' + @VP_MENSAJE 
	END
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_ORDEN_TRABAJO AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / ORDEN_TRABAJO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_ORDEN_TRABAJO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_ORDEN_TRABAJO]
GO		
CREATE PROCEDURE [dbo].[PG_UP_ORDEN_TRABAJO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ============================
	--@PP_K_USUARIO_SOLICITA		INT,
	--@PP_K_USUARIO_RECIBE			INT,	
	-- ============================
	@PP_K_ORDEN_TRABAJO				INT,
	-- ============================
	@PP_K_STATUS_ORDEN_TRABAJO		INT,
	-- ============================
	@PP_K_ESTACION					INT,
	@PP_K_SUB_ESTACION				INT,
	-- ============================
	@PP_D_ORDEN_TRABAJO				NVARCHAR(MAX),
	@PP_F_ORDEN_TRABAJO				DATE,
	-- ============================
	@PP_DURACION_TOTAL_MINUTOS		INT,
	-- ============================	
	--@PP_K_TIPO_ORDEN_TRABAJO		INT,	
	--@PP_K_MOTIVO_ORDEN_TRABAJO	INT,
	-- ============================	
	--@PP_RUTA_ORDEN_TRABAJO			NVARCHAR(MAX),
	-- ============================
	@PP_N_TECNICO_REALIZA			INT,
	@PP_D_TECNICO_REALIZA			VARCHAR(500),
	-- ============================
	--@PP_DURACION_MINUTOS			
	@PP_ACCION_REALIZADA			NVARCHAR(MAX),	
	@PP_C_ORDEN_TRABAJO				NVARCHAR(MAX)
	-----=====================================================
	--@PP_K_DET_TOOL_ARRAY			NVARCHAR(MAX),
	--@PP_CANT_FABRI_ARRAY			NVARCHAR(MAX)
AS			
DECLARE  @VP_MENSAJE				NVARCHAR(MAX)	= ''
		,@VP_K_ESTATUS_ORDEN_BD		INT				= 0
BEGIN TRANSACTION 
BEGIN TRY
	-- /////////////////////////////////////////////////////////////////////
	IF ( (	SELECT	CONCAT(K_USUARIO_DEPARTAMENTO,'-',K_CLASE_DEPARTAMENTO) 
			FROM	BD_GENERAL.DBO.USUARIO_PEARL (NOLOCK) 
			WHERE	K_USUARIO_PEARL	= @PP_K_USUARIO_ACCION	) = '5-2' )	---	AND		@PP_K_STATUS_ORDEN_TRABAJO NOT IN ()
	BEGIN
		SET @VP_MENSAJE='Los usuarios de mantenimiento no pueden actulizar una orden de trabajo.'
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END
	-- /////////////////////////////////////////////////////////////////////
	IF @PP_D_ORDEN_TRABAJO	= ''
	BEGIN
		SET @VP_MENSAJE='Se debe indicar una Descripción para la orden de Trabajo. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END

	IF ( SELECT	COUNT([K_ORDEN_TRABAJO])
		 FROM	[TPO_CUSTOMER_DET_SET_COTIZADO]	(NOLOCK)
		 WHERE	[K_ORDEN_TRABAJO]	= @PP_K_ORDEN_TRABAJO	) > 0
	BEGIN
		SET @VP_MENSAJE='Las órdenes recibidas desde el sistema de Herramental, no se pueden modificar en esta pantalla [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']. Informe a Sistemas para su revisión...'
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END

	SET @VP_K_ESTATUS_ORDEN_BD	=	ISNULL( (SELECT	K_STATUS_ORDEN_TRABAJO
											 FROM	ORDEN_TRABAJO (NOLOCK) 
											 WHERE	K_ORDEN_TRABAJO = @PP_K_ORDEN_TRABAJO) , 0 )
	
	IF	@VP_K_ESTATUS_ORDEN_BD	<> @PP_K_STATUS_ORDEN_TRABAJO
	BEGIN
		SET @VP_MENSAJE='Existe un problema con el estatus de la orden [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']. Informe a Sistemas...'
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END
	
	IF	 ( @VP_K_ESTATUS_ORDEN_BD ) NOT IN (10)
	BEGIN
		SET @VP_MENSAJE='El estatus de la orden no permite realizar cambios. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']. Verifique e intente desde la opción correspondiente...'
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END

	--============================================================================
	--======================================ACTUALIZAR LA ORDEN_TRABAJO
	--============================================================================
	UPDATE	ORDEN_TRABAJO
	SET		[K_ESTACION]			 = @PP_K_ESTACION,
			[K_SUB_ESTACION]		 = @PP_K_SUB_ESTACION,
			[D_ORDEN_TRABAJO]		 = @PP_D_ORDEN_TRABAJO,
			[K_USUARIO_CAMBIO]		 = @PP_K_USUARIO_ACCION,
			[F_CAMBIO]				 = GETDATE()
	WHERE	[K_ORDEN_TRABAJO]		 = @PP_K_ORDEN_TRABAJO
	AND		[K_STATUS_ORDEN_TRABAJO] = 10
	IF @@ROWCOUNT = 0
	BEGIN
		SET @VP_MENSAJE='El registro no se actualizó. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END
	
-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH	
	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [Actualizar]: ' + @VP_MENSAJE 
	END
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_ORDEN_TRABAJO AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / ORDEN_TRABAJO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_ESTATUS_ORDEN_TRABAJO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_ESTATUS_ORDEN_TRABAJO]
GO		
CREATE PROCEDURE [dbo].[PG_UP_ESTATUS_ORDEN_TRABAJO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ============================
	@PP_K_ORDEN_TRABAJO							INT,
	-- ============================
	@PP_K_STATUS_ORDEN_TRABAJO					INT,
	-- ============================
	@PP_K_ESTACION								INT,
	@PP_K_SUB_ESTACION							INT,
	-- ============================
	@PP_D_ORDEN_TRABAJO							NVARCHAR(MAX),
	---- @PP_F_ORDEN_TRABAJO			DATE,
	---- ============================
	@PP_DURACION_TOTAL_MINUTOS					INT,
	---- ============================
	---- @PP_K_TIPO_ORDEN_TRABAJO		INT,
	---- @PP_K_MOTIVO_ORDEN_TRABAJO		INT,
	---- ============================
	@PP_N_TECNICO_REALIZA						INT,
	@PP_D_TECNICO_REALIZA						VARCHAR(500),
	---- ============================
	@PP_ACCION_REALIZADA						NVARCHAR(MAX),
	@PP_C_ORDEN_TRABAJO							NVARCHAR(MAX),
	-- ============================
	@PP_K_ACCION_REALIZADA						INT,
	-- ============================
	@PP_ARRAY_K_TPO_CUSTOMER_DET_SET_COTIZADO	NVARCHAR(MAX)= '',
	@PP_ARRAY_TOOL_SET_CANTIDAD_FABRICADA		NVARCHAR(MAX)= ''
	--@PP_ARRAY_TOOL_SET_CANTIDAD_PENDIENTE		NVARCHAR(MAX)= ''
AS
DECLARE  @VP_MENSAJE				NVARCHAR(MAX)	= ''
		,@VP_K_ESTATUS_ORDEN_BD		INT				= 0
BEGIN TRANSACTION
BEGIN TRY
	-- /////////////////////////////////////////////////////////////////////
	SET @VP_K_ESTATUS_ORDEN_BD	=	ISNULL( (SELECT	K_STATUS_ORDEN_TRABAJO
											 FROM	ORDEN_TRABAJO (NOLOCK) 
											 WHERE	K_ORDEN_TRABAJO = @PP_K_ORDEN_TRABAJO) , 0 )
	
	IF	@VP_K_ESTATUS_ORDEN_BD	<> @PP_K_STATUS_ORDEN_TRABAJO
	BEGIN
		SET @VP_MENSAJE='Existe un problema con el estatus de la orden [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']. Informe a Sistemas...'
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END
	
	--============================================================================
	--======================================	ACTUALIZAR LA ORDEN_TRABAJO
	--============================================================================
	DECLARE	@VP_EXISTE_ORDEN_TRABAJO	INT	= 0
	
	SET @VP_EXISTE_ORDEN_TRABAJO	= ISNULL(	(SELECT	COUNT(K_ORDEN_TRABAJO)	FROM [TOOL_SET_ORDEN_TRABAJO]	(NOLOCK)	WHERE	K_ORDEN_TRABAJO	= @PP_K_ORDEN_TRABAJO ),0	)
	
	IF @VP_EXISTE_ORDEN_TRABAJO	>= 1
	BEGIN
			IF	( @PP_DURACION_TOTAL_MINUTOS = 0 ) OR ( @PP_ACCION_REALIZADA = '' )
			BEGIN
				SET @VP_MENSAJE='Se debe indicar la DURACIÓN y/o ACCIÓN REALIZADA para completar la acción. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
			END
						
			EXECUTE [DBO].[PG_UP_ESTATUS_ORDEN_TRABAJO_TOOL_MANTENIMIENTO]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
																			-- ============================
																			@PP_K_ORDEN_TRABAJO,
																			@PP_ARRAY_K_TPO_CUSTOMER_DET_SET_COTIZADO,	@PP_ARRAY_TOOL_SET_CANTIDAD_FABRICADA
			
			IF	(	SELECT	COUNT(K_TOOL_SET_ORDEN_TRABAJO) - SUM(TOOL_SET_CANTIDAD_RECIBIDA) 
					FROM	TOOL_SET_ORDEN_TRABAJO		(NOLOCK)
					WHERE	K_ORDEN_TRABAJO				= @PP_K_ORDEN_TRABAJO	) = 0
			BEGIN	-- SE ACTUALIZA LA ORDEN DE TRABAJO COMO TERMINADA		
				SET	@PP_K_ACCION_REALIZADA = 40
			END
			ELSE IF @PP_K_STATUS_ORDEN_TRABAJO IN ( 30, 35 )
			BEGIN
				SET	@PP_K_ACCION_REALIZADA = 35
			END

			UPDATE	ORDEN_TRABAJO
			SET		[K_STATUS_ORDEN_TRABAJO] = @PP_K_ACCION_REALIZADA,
					
					[ACCION_REALIZADA]		 = ( CASE
													WHEN [ACCION_REALIZADA]=''	THEN @PP_ACCION_REALIZADA
													WHEN [ACCION_REALIZADA]<>'' THEN [ACCION_REALIZADA] + ' /[ADICI]/ ' + @PP_ACCION_REALIZADA
												END ),
					[DURACION_TOTAL_MINUTOS] = ( CASE
													WHEN [DURACION_TOTAL_MINUTOS]=0	THEN @PP_DURACION_TOTAL_MINUTOS
													WHEN [DURACION_TOTAL_MINUTOS]>0 THEN [DURACION_TOTAL_MINUTOS] + @PP_DURACION_TOTAL_MINUTOS
												END ),
					[K_USUARIO_CAMBIO]		 = @PP_K_USUARIO_ACCION,
					[F_CAMBIO]				 = GETDATE()
			WHERE	[K_ORDEN_TRABAJO]		 = @PP_K_ORDEN_TRABAJO
			AND		[K_STATUS_ORDEN_TRABAJO] IN (30,35)
			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='El registro no se actualizó. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
			END

			IF @PP_K_ACCION_REALIZADA = 40
			BEGIN
				UPDATE	TOOL_SET
				SET		K_ORDEN_TRABAJO		= 0,
						K_STATUS_TOOL_SET	= 25
				WHERE	K_ORDEN_TRABAJO		= @PP_K_ORDEN_TRABAJO
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE='El registro no se actualizó. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
					RAISERROR (@VP_MENSAJE, 16, 1 ) 
				END
			END			
	END
	ELSE
	--IF @VP_EXISTE_ORDEN_TRABAJO	= 0
	BEGIN
		SET @VP_EXISTE_ORDEN_TRABAJO	= ISNULL(	(SELECT	COUNT(K_ORDEN_TRABAJO)	FROM TPO_CUSTOMER_DET_SET_COTIZADO (NOLOCK)	WHERE	K_ORDEN_TRABAJO	= @PP_K_ORDEN_TRABAJO ),0	)
	
		IF @VP_EXISTE_ORDEN_TRABAJO	>= 1
		BEGIN
				IF @PP_ARRAY_K_TPO_CUSTOMER_DET_SET_COTIZADO <> ''
				BEGIN

					IF	( @PP_DURACION_TOTAL_MINUTOS = 0 ) OR ( @PP_ACCION_REALIZADA = '' )
					BEGIN
						SET @VP_MENSAJE='Se debe indicar la DURACIÓN y/o ACCIÓN REALIZADA para completar la acción. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END

					EXECUTE [DBO].[PG_UP_ESTATUS_ORDEN_TRABAJO_TOOL]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
																		-- ============================
																		@PP_ARRAY_K_TPO_CUSTOMER_DET_SET_COTIZADO,	@PP_ARRAY_TOOL_SET_CANTIDAD_FABRICADA

						IF (	SELECT	SUM(TOOL_SET_CANTIDAD_COTIZADA) - SUM(TOOL_SET_CANTIDAD_FABRICADA)
								FROM	TPO_CUSTOMER_DET_SET_COTIZADO (NOLOCK)
								WHERE	K_ORDEN_TRABAJO	= @PP_K_ORDEN_TRABAJO	)	= 0
						BEGIN
							SET	@PP_K_ACCION_REALIZADA = 40
						END
						ELSE IF @PP_K_STATUS_ORDEN_TRABAJO IN ( 30, 35 )
						BEGIN
							SET	@PP_K_ACCION_REALIZADA = 35
						END

						UPDATE	ORDEN_TRABAJO
						SET		[K_STATUS_ORDEN_TRABAJO] = @PP_K_ACCION_REALIZADA,
					
								[ACCION_REALIZADA]		 = ( CASE
																WHEN [ACCION_REALIZADA]=''	THEN @PP_ACCION_REALIZADA
																WHEN [ACCION_REALIZADA]<>'' THEN [ACCION_REALIZADA] + ' /[ADICI]/ ' + @PP_ACCION_REALIZADA
															END ),
								[DURACION_TOTAL_MINUTOS] = ( CASE
																WHEN [DURACION_TOTAL_MINUTOS]=0	THEN @PP_DURACION_TOTAL_MINUTOS
																WHEN [DURACION_TOTAL_MINUTOS]>0 THEN [DURACION_TOTAL_MINUTOS] + @PP_DURACION_TOTAL_MINUTOS
															END ),
								[K_USUARIO_CAMBIO]		 = @PP_K_USUARIO_ACCION,
								[F_CAMBIO]				 = GETDATE()
						WHERE	[K_ORDEN_TRABAJO]		 = @PP_K_ORDEN_TRABAJO
						AND		[K_STATUS_ORDEN_TRABAJO] IN (30,35)
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro no se actualizó. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END
				END
		END
	--------------------------------------------------------------------------------------------------------------------
		ELSE
		--IF @VP_EXISTE_ORDEN_TRABAJO	= 0
		BEGIN
			IF	 ( @VP_K_ESTATUS_ORDEN_BD ) IN (10)	AND @PP_K_ACCION_REALIZADA = 20	--	CREADA, PASA A ESTATUS ENVIADA
			BEGIN
				UPDATE	ORDEN_TRABAJO
				SET		[K_STATUS_ORDEN_TRABAJO] = @PP_K_ACCION_REALIZADA,
						[K_ESTACION]			 = @PP_K_ESTACION,
						[K_SUB_ESTACION]		 = @PP_K_SUB_ESTACION,
						[D_ORDEN_TRABAJO]		 = @PP_D_ORDEN_TRABAJO,
						[K_USUARIO_CAMBIO]		 = @PP_K_USUARIO_ACCION,
						[F_CAMBIO]				 = GETDATE()
				WHERE	[K_ORDEN_TRABAJO]		 = @PP_K_ORDEN_TRABAJO
				AND		[K_STATUS_ORDEN_TRABAJO] = 10
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE='El registro no se actualizó. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END

				--SE ENVÍA CORREO CUANDO HA SIDO ENVIADA UNA ORDEN DE TRABAJO.
				EXECUTE	[PG_PR_ENVIAR_CORREO_ORDEN_TRABAJO]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
															-- ===========================
															@PP_K_ORDEN_TRABAJO
			END
			--------------------------------------------------------------------------------------------------------------------
			ELSE	IF	 ( @VP_K_ESTATUS_ORDEN_BD ) IN (20)	AND @PP_K_ACCION_REALIZADA = 30	--	ENVIADA, PASA A ESTATUS ASIGNADA
			BEGIN
				IF	( @PP_N_TECNICO_REALIZA = 0 ) OR ( @PP_D_TECNICO_REALIZA = '' )
					BEGIN
						SET @VP_MENSAJE='Se debe indicar un TÉCNICO para completar la acción. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END

					UPDATE	ORDEN_TRABAJO
					SET		[K_STATUS_ORDEN_TRABAJO] = @PP_K_ACCION_REALIZADA,
							[N_TECNICO_REALIZA]		 = @PP_N_TECNICO_REALIZA,
							[D_TECNICO_REALIZA]		 = @PP_D_TECNICO_REALIZA,
							[K_USUARIO_CAMBIO]		 = @PP_K_USUARIO_ACCION,
							[F_CAMBIO]				 = GETDATE()
					WHERE	[K_ORDEN_TRABAJO]		 = @PP_K_ORDEN_TRABAJO
					AND		[K_STATUS_ORDEN_TRABAJO] = 20
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE='El registro no se actualizó. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END
				END
				--------------------------------------------------------------------------------------------------------------------
				ELSE	IF	 ( @VP_K_ESTATUS_ORDEN_BD ) IN (30)	AND @PP_K_ACCION_REALIZADA = 40	--	ASIGNADA, PASA A ESTATUS TERMINADA
				BEGIN
					IF	( @PP_DURACION_TOTAL_MINUTOS = 0 ) OR ( @PP_ACCION_REALIZADA = '' )
					BEGIN
						SET @VP_MENSAJE='Se debe indicar la DURACIÓN y/o ACCIÓN REALIZADA para completar la acción. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END

					UPDATE	ORDEN_TRABAJO
					SET		[K_STATUS_ORDEN_TRABAJO] = @PP_K_ACCION_REALIZADA,
							[ACCION_REALIZADA]		 = @PP_ACCION_REALIZADA,
							[DURACION_TOTAL_MINUTOS] = @PP_DURACION_TOTAL_MINUTOS,
							[K_USUARIO_CAMBIO]		 = @PP_K_USUARIO_ACCION,
							[F_CAMBIO]				 = GETDATE()
					WHERE	[K_ORDEN_TRABAJO]		 = @PP_K_ORDEN_TRABAJO
					AND		[K_STATUS_ORDEN_TRABAJO] = 30
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE='El registro no se actualizó. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END
				END
				--------------------------------------------------------------------------------------------------------------------
				ELSE	IF	 ( @VP_K_ESTATUS_ORDEN_BD ) IN (40)	AND @PP_K_ACCION_REALIZADA IN ( 50 , 60 )	--	TERMINADA, PUEDE PASAR A RECHAZADA O ACEPTADA.
				BEGIN
					IF	( @PP_C_ORDEN_TRABAJO = '' AND @PP_K_ACCION_REALIZADA	= 50)	--	RECHAZADA. EL COMENTARIO POR PARTE DEL USUARIO ES OBLIGATORIO.
					BEGIN																--	ACEPTADA. EL COMENTARIO POR PARTE DEL USUARIO NO ES OBLIGATORIO.
						SET @VP_MENSAJE='Se debe indicar un COMENTARIO para completar la acción. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END

					--IF @PP_K_ACCION_REALIZADA	= 50			--	RECHAZADA. EL COMENTARIO POR PARTE DEL USUARIO ES OBLIGATORIO.
					--BEGIN
						UPDATE	ORDEN_TRABAJO
						SET		[K_STATUS_ORDEN_TRABAJO] = @PP_K_ACCION_REALIZADA,
								[C_ORDEN_TRABAJO]		 = @PP_C_ORDEN_TRABAJO,
								[K_USUARIO_RECIBE]		 = @PP_K_USUARIO_ACCION,
								[K_USUARIO_CAMBIO]		 = @PP_K_USUARIO_ACCION,
								[F_CAMBIO]				 = GETDATE()
						WHERE	[K_ORDEN_TRABAJO]		 = @PP_K_ORDEN_TRABAJO
						AND		[K_STATUS_ORDEN_TRABAJO] = 40
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro no se actualizó. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END		
					--END
					--ELSE IF @PP_K_ACCION_REALIZADA	= 60		--	ACEPTADA. EL COMENTARIO POR PARTE DEL USUARIO NO ES OBLIGATORIO.
					--BEGIN
					--	UPDATE	ORDEN_TRABAJO
					--	SET		[K_STATUS_ORDEN_TRABAJO] = @PP_K_ACCION_REALIZADA,
					--			[C_ORDEN_TRABAJO]		 = [C_ORDEN_TRABAJO] + @PP_C_ORDEN_TRABAJO,
					--			[K_USUARIO_CAMBIO]		 = @PP_K_USUARIO_ACCION,
					--			[F_CAMBIO]				 = GETDATE()
					--	WHERE	[K_ORDEN_TRABAJO]		 = @PP_K_ORDEN_TRABAJO
					--	AND		[K_STATUS_ORDEN_TRABAJO] = 40
					--	IF @@ROWCOUNT = 0
					--	BEGIN
					--		SET @VP_MENSAJE='El registro no se actualizó. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
					--		RAISERROR (@VP_MENSAJE, 16, 1 ) 
					--	END
					--END
				END
				--------------------------------------------------------------------------------------------------------------------
				ELSE	IF	 ( @VP_K_ESTATUS_ORDEN_BD ) IN (45)	AND @PP_K_ACCION_REALIZADA IN ( 50 , 60 )	--	TERMINADA DESPUES DE RECHAZO, PUEDE PASAR A RECHAZADA O ACEPTADA. COMENTARIO OBLIGATORIO.
				BEGIN
					IF	( @PP_C_ORDEN_TRABAJO = '' )
					BEGIN																
						SET @VP_MENSAJE='Se debe indicar un COMENTARIO para completar la acción. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END

					IF @PP_K_ACCION_REALIZADA	= 50			--	RECHAZADA. EL COMENTARIO POR PARTE DEL USUARIO ES OBLIGATORIO.
					BEGIN
						UPDATE	ORDEN_TRABAJO
						SET		[K_STATUS_ORDEN_TRABAJO] = @PP_K_ACCION_REALIZADA,
								[C_ORDEN_TRABAJO]		 = [C_ORDEN_TRABAJO] + '. /[X]/ ' + @PP_C_ORDEN_TRABAJO,
								[K_USUARIO_RECIBE]		 = @PP_K_USUARIO_ACCION,
								[K_USUARIO_CAMBIO]		 = @PP_K_USUARIO_ACCION,
								[F_CAMBIO]				 = GETDATE()
						WHERE	[K_ORDEN_TRABAJO]		 = @PP_K_ORDEN_TRABAJO
						AND		[K_STATUS_ORDEN_TRABAJO] = 45
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro no se actualizó. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END		
					END
					ELSE IF @PP_K_ACCION_REALIZADA	= 60		--	ACEPTADA. EL COMENTARIO POR PARTE DEL USUARIO NO ES OBLIGATORIO.
					BEGIN
						UPDATE	ORDEN_TRABAJO
						SET		[K_STATUS_ORDEN_TRABAJO] = @PP_K_ACCION_REALIZADA,
								[C_ORDEN_TRABAJO]		 = [C_ORDEN_TRABAJO] + '. /[OK]/ ' + @PP_C_ORDEN_TRABAJO,
								[K_USUARIO_RECIBE]		 = @PP_K_USUARIO_ACCION,
								[K_USUARIO_CAMBIO]		 = @PP_K_USUARIO_ACCION,
								[F_CAMBIO]				 = GETDATE()
						WHERE	[K_ORDEN_TRABAJO]		 = @PP_K_ORDEN_TRABAJO
						AND		[K_STATUS_ORDEN_TRABAJO] = 45
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro no se actualizó. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END
					END
				END
				--------------------------------------------------------------------------------------------------------------------
				ELSE	IF	 ( @VP_K_ESTATUS_ORDEN_BD ) IN (50)	AND @PP_K_ACCION_REALIZADA = 45	--	RECHAZADA, PASA A ESTATUS TERMINADA DESPUES DE RECHAZO
				BEGIN
					IF	( @PP_DURACION_TOTAL_MINUTOS = 0 ) OR ( @PP_ACCION_REALIZADA = '' )
					BEGIN
						SET @VP_MENSAJE='Se debe indicar la DURACIÓN(rechazo) y/o ACCIÓN REALIZADA(rechazo) para completar la acción. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END

					UPDATE	ORDEN_TRABAJO
					SET		[K_STATUS_ORDEN_TRABAJO] = @PP_K_ACCION_REALIZADA,
							[ACCION_REALIZADA]		 = [ACCION_REALIZADA] + ' /[SOLU]/ ' + @PP_ACCION_REALIZADA,
							[DURACION_TOTAL_MINUTOS] = [DURACION_TOTAL_MINUTOS] + @PP_DURACION_TOTAL_MINUTOS,
							[K_USUARIO_CAMBIO]		 = @PP_K_USUARIO_ACCION,
							[F_CAMBIO]				 = GETDATE()
					WHERE	[K_ORDEN_TRABAJO]		 = @PP_K_ORDEN_TRABAJO
					AND		[K_STATUS_ORDEN_TRABAJO] = 50
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE='El registro no se actualizó. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END
				END
				--------------------------------------------------------------------------------------------------------------------
				ELSE
				BEGIN
					SET @VP_MENSAJE='No se realizó ninguna acción. [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+'], verifique...'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END
		END
	END
	--	[K_ESTACION]			 = @PP_K_ESTACION,
	--	[K_SUB_ESTACION]		 = @PP_K_SUB_ESTACION,
-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH	
	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [Actualizar]: ' + @VP_MENSAJE 
	END
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_ORDEN_TRABAJO AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / ORDEN_TRABAJO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_ESTATUS_ORDEN_TRABAJO_TOOL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_ESTATUS_ORDEN_TRABAJO_TOOL]
GO		
CREATE PROCEDURE [dbo].[PG_UP_ESTATUS_ORDEN_TRABAJO_TOOL]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ============================
	@PP_ARRAY_K_TPO_CUSTOMER_DET_SET_COTIZADO	NVARCHAR(MAX)= '',
	@PP_ARRAY_TOOL_SET_CANTIDAD_FABRICADA		NVARCHAR(MAX)= ''
	-- ============================
AS
DECLARE  @VP_MENSAJE				NVARCHAR(MAX)	= ''
		,@VP_K_ESTATUS_ORDEN_BD		INT				= 0
	-----=====================================================
	DECLARE	@PP_K_TPO_ARRAY	NVARCHAR(MAX) = @PP_ARRAY_K_TPO_CUSTOMER_DET_SET_COTIZADO
	DECLARE	@PP_FABRI_ARRAY	NVARCHAR(MAX) = @PP_ARRAY_TOOL_SET_CANTIDAD_FABRICADA
		-----=====================================================
	DECLARE  @VP_POSICION_K_TPO		INT
			,@VP_POSICION_FABRI		INT
			,@VP_VALOR_K_TPO		VARCHAR(500)
			,@VP_VALOR_FABRI		VARCHAR(500)
	-------------------------------------------------------------
			,@VP_CONTADOR			INT	= 0
			,@VP_CONTADOR_CEROS		INT	= 0
	-------------------------------------------------------------
	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_K_TPO_ARRAY	= @PP_K_TPO_ARRAY	+ '/'
	SET	@PP_FABRI_ARRAY	= @PP_FABRI_ARRAY	+ '/'
	
	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_K_TPO_ARRAY) <> 0
		BEGIN
			SELECT @VP_POSICION_K_TPO	=	patindex('%/%' , @PP_K_TPO_ARRAY	)
			SELECT @VP_POSICION_FABRI	=	patindex('%/%' , @PP_FABRI_ARRAY	)

			--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
			SELECT @VP_VALOR_K_TPO		= LEFT(@PP_K_TPO_ARRAY	, @VP_POSICION_K_TPO	- 1)
			SELECT @VP_VALOR_FABRI		= LEFT(@PP_FABRI_ARRAY	, @VP_POSICION_FABRI	- 1)
				-- =========================================================================================================
				DECLARE	@VP_TOOL_SET_CANTIDAD_PENDIENTE		INT	= 0
	
				SELECT	@VP_TOOL_SET_CANTIDAD_PENDIENTE		= ( TOOL_SET_CANTIDAD_COTIZADA - TOOL_SET_CANTIDAD_FABRICADA )
				FROM	TPO_CUSTOMER_DET_SET_COTIZADO		(NOLOCK)
				WHERE	K_TPO_CUSTOMER_DET_SET_COTIZADO		= @VP_VALOR_K_TPO
	
				IF	@VP_TOOL_SET_CANTIDAD_PENDIENTE	 <	@VP_VALOR_FABRI
				BEGIN
					SET @VP_MENSAJE='La cantidad fabricada no puede ser mayor a la cantidad cotizada.'
					RAISERROR (@VP_MENSAJE, 16, 1 ) 
				END

				SET	@VP_CONTADOR += 1

				IF	@VP_VALOR_FABRI <= 0
				BEGIN
					SET	@VP_CONTADOR_CEROS += 1
					--SET @VP_MENSAJE='Se debe indicar un valor para la cantidad fabricada.'
					--RAISERROR (@VP_MENSAJE, 16, 1 ) 
				END

					UPDATE	TPO_CUSTOMER_DET_SET_COTIZADO
					SET		
							TOOL_SET_CANTIDAD_FABRICADA		= TOOL_SET_CANTIDAD_FABRICADA + @VP_VALOR_FABRI
					WHERE	K_TPO_CUSTOMER_DET_SET_COTIZADO	= @VP_VALOR_K_TPO
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE='El detalle no fue actualizado. [DET#'+@VP_VALOR_K_TPO+'] '
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END
				-- =========================================================================================================
			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_K_TPO_ARRAY		= STUFF(@PP_K_TPO_ARRAY		, 1, @VP_POSICION_K_TPO, '')
			SELECT @PP_FABRI_ARRAY		= STUFF(@PP_FABRI_ARRAY		, 1, @VP_POSICION_FABRI, '')
		END

		IF @VP_CONTADOR = @VP_CONTADOR_CEROS
		BEGIN
			SET @VP_MENSAJE='Se debe indicar al menos un valor para un registro en la cantidad fabricada. No pueden ir todos los registros en 0 (cero).'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END
-- /////////////////////////////////////////////////////////////////////
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_ESTATUS_ORDEN_TRABAJO_TOOL_MANTENIMIENTO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_ESTATUS_ORDEN_TRABAJO_TOOL_MANTENIMIENTO]
GO		
CREATE PROCEDURE [dbo].[PG_UP_ESTATUS_ORDEN_TRABAJO_TOOL_MANTENIMIENTO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ============================
	@PP_K_ORDEN_TRABAJO				INT,
	@PP_ARRAY_K_TPO_CUSTOMER_DET_SET_COTIZADO	NVARCHAR(MAX)= '',	-- SE RECIBE EL K_TOOL_SET
	@PP_ARRAY_TOOL_SET_CANTIDAD_MANTENIMIENTO	NVARCHAR(MAX)= ''
	-- ============================
AS
DECLARE  @VP_MENSAJE				NVARCHAR(MAX)	= ''
		,@VP_K_ESTATUS_ORDEN_BD		INT				= 0
	-----=====================================================
	DECLARE	@PP_K_TPO_ARRAY	NVARCHAR(MAX) = @PP_ARRAY_K_TPO_CUSTOMER_DET_SET_COTIZADO
	DECLARE	@PP_MANTO_ARRAY	NVARCHAR(MAX) = @PP_ARRAY_TOOL_SET_CANTIDAD_MANTENIMIENTO
		-----=====================================================
	DECLARE  @VP_POSICION_K_TPO		INT
			,@VP_POSICION_FABRI		INT
			,@VP_VALOR_K_TPO		VARCHAR(500)
			,@VP_VALOR_FABRI		VARCHAR(500)
	-------------------------------------------------------------
			,@VP_CONTADOR			INT	= 0
			,@VP_CONTADOR_CEROS		INT	= 0
	-------------------------------------------------------------
	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_K_TPO_ARRAY	= @PP_K_TPO_ARRAY	+ '/'
	SET	@PP_MANTO_ARRAY	= @PP_MANTO_ARRAY	+ '/'
	
	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_K_TPO_ARRAY) <> 0
		BEGIN
			SELECT @VP_POSICION_K_TPO	=	patindex('%/%' , @PP_K_TPO_ARRAY	)
			SELECT @VP_POSICION_FABRI	=	patindex('%/%' , @PP_MANTO_ARRAY	)

			--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
			SELECT @VP_VALOR_K_TPO		= LEFT(@PP_K_TPO_ARRAY	, @VP_POSICION_K_TPO	- 1)
			SELECT @VP_VALOR_FABRI		= LEFT(@PP_MANTO_ARRAY	, @VP_POSICION_FABRI	- 1)
				-- =========================================================================================================
				SET	@VP_CONTADOR += 1

				IF @VP_VALOR_FABRI	<> 0
				BEGIN
						DECLARE	@VP_TOOL_SET_CANTIDAD_PENDIENTE		INT	= 0

						SELECT	@VP_TOOL_SET_CANTIDAD_PENDIENTE	= TOOL_SET_CANTIDAD_RECIBIDA 
						FROM	TOOL_SET_ORDEN_TRABAJO			(NOLOCK) 
						WHERE	K_TOOL_SET						= @VP_VALOR_K_TPO
						AND		K_ORDEN_TRABAJO					= @PP_K_ORDEN_TRABAJO
	
						IF	@VP_TOOL_SET_CANTIDAD_PENDIENTE	 >	@VP_VALOR_FABRI
						BEGIN
							SET @VP_MENSAJE='La cantidad pendiente no puede ser mayor a la cantidad a dar mantenimiento.'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END

						UPDATE	TOOL_SET_ORDEN_TRABAJO
						SET		TOOL_SET_CANTIDAD_RECIBIDA		= TOOL_SET_CANTIDAD_RECIBIDA + @VP_VALOR_FABRI
						WHERE	K_TOOL_SET						= @VP_VALOR_K_TPO
						AND		K_ORDEN_TRABAJO					= @PP_K_ORDEN_TRABAJO
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El detalle no fue actualizado. [DET#'+@VP_VALOR_K_TPO+'] '
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END
				END
				ELSE
				--IF	@VP_VALOR_FABRI <= 0
				BEGIN
					SET	@VP_CONTADOR_CEROS += 1
				END
				-- =========================================================================================================
			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_K_TPO_ARRAY		= STUFF(@PP_K_TPO_ARRAY		, 1, @VP_POSICION_K_TPO, '')
			SELECT @PP_MANTO_ARRAY		= STUFF(@PP_MANTO_ARRAY		, 1, @VP_POSICION_FABRI, '')
		END

		IF @VP_CONTADOR = @VP_CONTADOR_CEROS
		BEGIN
			SET @VP_MENSAJE='Se debe indicar al menos un valor para un registro en la cantidad fabricada/mantenimiento. No pueden ir todos los registros en 0 (cero).'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END
-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////
--  EXECUTE [dbo].[PG_SK_TOOL_SET] 0,139,9
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_ORDEN_TRABAJO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_ORDEN_TRABAJO]
GO
--		 EXECUTE [dbo].[PG_DL_ORDEN_TRABAJO] 0,139,1
CREATE PROCEDURE [dbo].[PG_DL_ORDEN_TRABAJO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_TRABAJO				INT
AS
DECLARE  @VP_MENSAJE					VARCHAR(300) = ''
		,@VP_K_STATUS_ORDEN_TRABAJO		INT
BEGIN TRANSACTION 
BEGIN TRY
	--/////////////////////////////////////////////////////////////
	SELECT	@VP_K_STATUS_ORDEN_TRABAJO	= K_STATUS_ORDEN_TRABAJO
	FROM	ORDEN_TRABAJO				(NOLOCK)
	WHERE	K_ORDEN_TRABAJO				=	@PP_K_ORDEN_TRABAJO
	
	--////////////////////////////////////////////////////////////
	IF	@VP_K_STATUS_ORDEN_TRABAJO	= 10
	BEGIN
		--DELETE	ORDEN_TRABAJO
		UPDATE	ORDEN_TRABAJO
		SET		L_BORRADO		= 1
		WHERE	K_ORDEN_TRABAJO	= @PP_K_ORDEN_TRABAJO
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='El registro no se pudo eliminar.'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END	
	END
	ELSE
	BEGIN
		SET @VP_MENSAJE='El registro no se puede eliminar. El estatus de la ORDEN DE TRBAJO [ ' + CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO) + ' ] no lo permite. Verifique...'
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END
	-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH
	
	IF @VP_MENSAJE<>''
		BEGIN
			SET	@VP_MENSAJE = '!!!! ' + @VP_MENSAJE 
		END

	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_ORDEN_TRABAJO AS CLAVE
	-- //////////////////////////////////////////////////////////////	
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_ORDEN_TRABAJO_DESDE_TPO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_ORDEN_TRABAJO_DESDE_TPO]
GO
CREATE PROCEDURE [dbo].[PG_IN_ORDEN_TRABAJO_DESDE_TPO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	 -- ===========================
	@PP_K_TPO_CUSTOMER 				INT,
	 -- ===========================
	@PP_ARRAY_K_TPO_CUSTOMER_DET_SET_COTIZADO	NVARCHAR(MAX)= ''
AS			
DECLARE  @VP_MENSAJE				NVARCHAR(MAX)	= ''
		,@VP_K_ORDEN_TRABAJO		INT				= 0
		--,@VP_D_USUARIO_SOLICITA		VARCHAR(500)
BEGIN TRANSACTION 
BEGIN TRY
	-- /////////////////////////////////////////////////////////////////////
	--SELECT	@VP_D_USUARIO_SOLICITA	= NOMBRE + ' ' +	APELLIDO_PATERNO
	--		----CONVERT(VARCHAR(100),GETDATE(),103)	AS FECHA,	-- 25/10/2021
	--		--CONVERT(VARCHAR(100),GETDATE(),106)	AS FECHA,	-- 25/OCT/2021
	--		--'FABRICACIÓN HERRAMENTAL'			AS SOLICITA,
	--		--'Se hace la solicitud de la fabricación de los siguientes herramentales:' AS LEYENDA_HEADER
	--FROM	BD_GENERAL.DBO.USUARIO_PEARL
	--WHERE	K_USUARIO_PEARL		= @PP_K_USUARIO_ACCION
	--============================================================================
	--======================================INSERTAR EL ENCABEZADO DE LA ORDEN TRABAJO
	--============================================================================
		INSERT INTO ORDEN_TRABAJO
			(	[K_USUARIO_SOLICITA]			,	[K_USUARIO_RECIBE]			,	--	1
				-- ============================
				[K_STATUS_ORDEN_TRABAJO]		,									--	2
				-- ============================
				[K_ESTACION]					,	[K_SUB_ESTACION]			,	--	3
				-- ============================
				[D_ORDEN_TRABAJO]				,	
				[F_ORDEN_TRABAJO]				,	--	4
				-- ============================
				[DURACION_TOTAL_MINUTOS]		,									--	5
				-- ============================	
				[K_TIPO_ORDEN_TRABAJO]			,	[K_MOTIVO_ORDEN_TRABAJO]	,	--	6
				-- ============================	
				[RUTA_ORDEN_TRABAJO]			,									--	7
				[N_TECNICO_REALIZA]				,	[D_TECNICO_REALIZA]			,	--	8
				-- =========================
				[ACCION_REALIZADA]				,									--	9		[DURACION_MINUTOS]				,	
				[C_ORDEN_TRABAJO]				,									--	10
				-- ===========================
				[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
		VALUES	
			(	@PP_K_USUARIO_ACCION			,	0							,	--	1
				-- ============================
				20								,									--	2					--	#1: ES EL ESTATUS INICIAL DE @PP_K_STATUS_ORDEN_TRABAJO	,
				-- ============================
				24								,	0							,	--	3
				-- ============================
				'Se hace la solicitud de la fabricación de los siguientes herramentales:',	
				GETDATE()					,	--	4
				-- ============================
				0								,									--	5
				-- ============================
				1								,	0							,	--	6
				-- ============================
				''								,									--	7
				0								,	''							,	--	8
				-- =========================
				''								,									--	9
				''								,									--	10
				-- ============================
				@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),	
				0, NULL, NULL  )

			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='El registro no se ingresó. [OTR#'+CONVERT(VARCHAR(10),@PP_K_TPO_CUSTOMER)+']'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
			END
			ELSE
			BEGIN
				SELECT @VP_K_ORDEN_TRABAJO	= SCOPE_IDENTITY()

				IF	( @VP_K_ORDEN_TRABAJO	= 0 OR @VP_K_ORDEN_TRABAJO IS NULL )
				BEGIN
					RAISERROR ('Error en la asignación de identidad.', 16, 1 ) 
				END
			END

		-- /////////////////////////////////////////////////////////////////////-- /////////////////////////////////////////////////////////////////////

		--EXECUTE	[dbo].[PG_IN_ORDEN_TRABAJO_DETALLE]	@PP_K_SISTEMA_EXE	,		@PP_K_USUARIO_ACCION,
		--											-- ===========================
		--											@VP_K_ORDEN_TRABAJO			--@PP_DESCRIPCION_ORDEN_TRABAJO	,
		--											--@PP_ACCIONES_ORDEN_TRABAJO,
		--											--@PP_C_ORDEN_TRABAJO

	-----=====================================================
	DECLARE	@PP_K_TPO_ARRAY	NVARCHAR(MAX) = @PP_ARRAY_K_TPO_CUSTOMER_DET_SET_COTIZADO
		-----=====================================================
	DECLARE  @VP_POSICION_K_TPO		INT
			,@VP_VALOR_K_TPO		VARCHAR(500)
	-------------------------------------------------------------
	-------------------------------------------------------------
	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_K_TPO_ARRAY	= @PP_K_TPO_ARRAY	+ '/'	
	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_K_TPO_ARRAY) <> 0
		BEGIN
			SELECT @VP_POSICION_K_TPO	=	patindex('%/%' , @PP_K_TPO_ARRAY	)
			--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
			SELECT @VP_VALOR_K_TPO		= LEFT(@PP_K_TPO_ARRAY	, @VP_POSICION_K_TPO	- 1)
				-- =========================================================================================================

					UPDATE	[TPO_CUSTOMER_DET_SET_COTIZADO]
					SET		[K_STATUS_SET_COTIZADO]	= 2,
							[K_ORDEN_TRABAJO]		= @VP_K_ORDEN_TRABAJO
					--WHERE	[K_TPO_CUSTOMER]		= @PP_K_TPO_CUSTOMER
					WHERE	[K_TPO_CUSTOMER_DET_SET_COTIZADO]	= @VP_VALOR_K_TPO
					AND		[L_HECHO_EN_PEARL]					= 1
					AND		[K_STATUS_SET_COTIZADO]				= 1
					IF @@ROWCOUNT = 0
					BEGIN
						RAISERROR ('ERROR: No fue posible actualizar el registro de la [ORDEN_TRABAJO]', 16, 1 ) 
					END
				-- =========================================================================================================
			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_K_TPO_ARRAY		= STUFF(@PP_K_TPO_ARRAY		, 1, @VP_POSICION_K_TPO, '')
		END
-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH	
	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [Insertar]: ' + @VP_MENSAJE 
	END
	SELECT	@VP_MENSAJE AS MENSAJE, FORMAT(@VP_K_ORDEN_TRABAJO,'000000') AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_ORDEN_TRABAJO_DESDE_TOOL_SET]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_ORDEN_TRABAJO_DESDE_TOOL_SET]
GO
--		 EXECUTE [dbo].[PG_IN_ORDEN_TRABAJO_DESDE_TOOL_SET] 0,139,'10/6'
CREATE PROCEDURE [dbo].[PG_IN_ORDEN_TRABAJO_DESDE_TOOL_SET]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	 -- ===========================
	 -- ===========================
	@PP_ARRAY_K_TOOL_SET			NVARCHAR(MAX)= ''
AS			
DECLARE  @VP_MENSAJE				NVARCHAR(MAX)	= ''
		,@VP_K_ORDEN_TRABAJO		INT				= 0
		--,@VP_D_USUARIO_SOLICITA		VARCHAR(500)
BEGIN TRANSACTION 
BEGIN TRY
	-- /////////////////////////////////////////////////////////////////////
	--============================================================================
	--======================================INSERTAR EL ENCABEZADO DE LA ORDEN TRABAJO
	--============================================================================
		INSERT INTO ORDEN_TRABAJO
			(	[K_USUARIO_SOLICITA]			,	[K_USUARIO_RECIBE]			,	--	1
				-- ============================
				[K_STATUS_ORDEN_TRABAJO]		,									--	2
				-- ============================
				[K_ESTACION]					,	[K_SUB_ESTACION]			,	--	3
				-- ============================
				[D_ORDEN_TRABAJO]				,	
				[F_ORDEN_TRABAJO]				,	--	4
				-- ============================
				[DURACION_TOTAL_MINUTOS]		,									--	5
				-- ============================	
				[K_TIPO_ORDEN_TRABAJO]			,	[K_MOTIVO_ORDEN_TRABAJO]	,	--	6
				-- ============================	
				[RUTA_ORDEN_TRABAJO]			,									--	7
				[N_TECNICO_REALIZA]				,	[D_TECNICO_REALIZA]			,	--	8
				-- =========================
				[ACCION_REALIZADA]				,									--	9		[DURACION_MINUTOS]				,	
				[C_ORDEN_TRABAJO]				,									--	10
				-- ===========================
				[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
		VALUES	
			(	@PP_K_USUARIO_ACCION			,	0							,	--	1
				-- ============================
				20								,									--	2					--	#1: ES EL ESTATUS INICIAL DE @PP_K_STATUS_ORDEN_TRABAJO	,
				-- ============================
				24								,	0							,	--	3
				-- ============================
				'Se hace la solicitud del mantenimiento de los siguientes herramentales:',	
				GETDATE()					,	--	4
				-- ============================
				0								,									--	5
				-- ============================
				1								,	0							,	--	6
				-- ============================
				''								,									--	7
				0								,	''							,	--	8
				-- =========================
				''								,									--	9
				''								,									--	10
				-- ============================
				@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),	
				0, NULL, NULL  )

			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='El registro no se ingresó.'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
			END
			ELSE
			BEGIN
				SELECT @VP_K_ORDEN_TRABAJO	= SCOPE_IDENTITY()

				IF	( @VP_K_ORDEN_TRABAJO	= 0 OR @VP_K_ORDEN_TRABAJO IS NULL )
				BEGIN
					RAISERROR ('Error en la asignación de identidad.', 16, 1 ) 
				END
			END
		-- /////////////////////////////////////////////////////////////////////-- /////////////////////////////////////////////////////////////////////
	-----=====================================================
	-----=====================================================
	DECLARE  @VP_K_TOOL_POSICION	INT
			,@VP_K_TOOL_VALOR		VARCHAR(500)
			,@VP_CONTADOR			INT	= 0
	-------------------------------------------------------------
	-------------------------------------------------------------
	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_ARRAY_K_TOOL_SET	= @PP_ARRAY_K_TOOL_SET	+ '/'	
	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_ARRAY_K_TOOL_SET) <> 0
		BEGIN
			SELECT @VP_K_TOOL_POSICION	=	patindex('%/%' , @PP_ARRAY_K_TOOL_SET	)
			--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
			SELECT @VP_K_TOOL_VALOR		= LEFT(@PP_ARRAY_K_TOOL_SET	, @VP_K_TOOL_POSICION	- 1)
				-- =========================================================================================================
					DECLARE	 @VP_STATUS_TOOL_SET			INTEGER = 0
							,@VP_NO_PARTE_PEARL_PATTERN		VARCHAR(250)=''
							,@VP_TOOL_SET_ID_TAG			VARCHAR(250)=''					
					SELECT	@VP_STATUS_TOOL_SET			= K_STATUS_TOOL_SET,
							@VP_NO_PARTE_PEARL_PATTERN	= NO_PARTE_PEARL_PATTERN,
							@VP_TOOL_SET_ID_TAG			= TOOL_SET_ID_TAG
					FROM	TOOL_SET		(NOLOCK)
					WHERE	K_TOOL_SET		= @VP_K_TOOL_VALOR


					IF ISNULL(	( 	@VP_STATUS_TOOL_SET	), 0) IN (0,10,40,60,70)
					BEGIN
						SET	@VP_MENSAJE	= 'Estatus no válido para realizar la acción. [PEARL: '  + @VP_NO_PARTE_PEARL_PATTERN + ' // ID_TAG: ' + @VP_TOOL_SET_ID_TAG + ']'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END

					UPDATE	TOOL_SET
					SET		K_STATUS_TOOL_SET	= 40,
							K_ORDEN_TRABAJO		= @VP_K_ORDEN_TRABAJO
					WHERE	K_TOOL_SET			= @VP_K_TOOL_VALOR
					AND		L_BORRADO			= 0
					AND		K_ORDEN_TRABAJO		= 0
					IF @@ROWCOUNT = 0
					BEGIN
						RAISERROR ('ERROR: No fue posible actualizar el registro de la [ORDEN_TRABAJO]', 16, 1 ) 
					END

					INSERT INTO TOOL_SET_ORDEN_TRABAJO
					SELECT	@VP_K_ORDEN_TRABAJO,
							[K_TOOL_SET],
							[K_TPO_CUSTOMER_DET_SET_COTIZADO],
							[K_TPO_CUSTOMER]			,
							[K_CUSTOMER]				,	
							[K_TOOL_SET_COLOR]			,
							[CUS_NO]					,	[MODELNO]					,
							[NO_PARTE_PEARL_PATTERN]	,
							-- =========================
							-- TOOL IDENTIFICATION NUMBE
							[TOOL_SET_ID]				,
							-- =========================
							[D_TOOL_SET]				,	[K_TOOL_SET_ROW]			,
							-- =========================
							--	TOOL TAG
							[TOOL_SET_ID_TAG]			,	[K_TOOL_SET_CODE]			,
							[TOOL_SET_CODE_01]			,	[TOOL_SET_CODE_02]			,
							-- =========================
							[K_TOOL_SET_SUPPLIER]		,	0,--[TOOL_SET_CANTIDAD_RECIBIDA],	
							[F_STATUS_TOOL_SET]			
					FROM	TOOL_SET
					WHERE	K_TOOL_SET	= @VP_K_TOOL_VALOR	--2
					IF @@ROWCOUNT = 0
					BEGIN
						RAISERROR ('ERROR: No fue posible insertar el registro de la [SET_ORDEN_TRABAJO]', 16, 1 ) 
					END

					SET @VP_CONTADOR += 1

					IF @VP_CONTADOR > 12
					BEGIN
						RAISERROR ('Sólo es posible incluir 12 dados por orden de Mantenimiento.', 16, 1 ) 
					END
				-- =========================================================================================================
			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_ARRAY_K_TOOL_SET		= STUFF(@PP_ARRAY_K_TOOL_SET		, 1, @VP_K_TOOL_POSICION, '')
		END
-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH	
	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [Insertar]: ' + @VP_MENSAJE 
	END
	SELECT	@VP_MENSAJE AS MENSAJE, FORMAT(@VP_K_ORDEN_TRABAJO,'000000') AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> ENVIAR CORREO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_ENVIAR_CORREO_ORDEN_TRABAJO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_ENVIAR_CORREO_ORDEN_TRABAJO]
GO
--		 EXECUTE [dbo].[PG_PR_ENVIAR_CORREO_ORDEN_TRABAJO]	1,139,  1,''
CREATE PROCEDURE [dbo].[PG_PR_ENVIAR_CORREO_ORDEN_TRABAJO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_VALOR_ORDEN_TRABAJO			INT
AS
	DECLARE	 @VP_MENSAJE					NVARCHAR(MAX)
			,@VP_RECIPIENTS					NVARCHAR(MAX)	= ''
			,@VP_SUBJECT					NVARCHAR(MAX) 
			,@VP_BODY_HTML					NVARCHAR(MAX) 
			,@VP_ID_MAIL					INT
			,@VP_SENT_STATUS				VARCHAR(500)
			,@VP_CLIENTE					VARCHAR(250)
			,@VP_K_CUSTOMER					INT
			,@VP_K_TIPO_GRUPO_APROBADOR		VARCHAR(15)	=	110
	----================================================================
	----================================================================
	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
	FROM	BD_GENERAL.dbo.USUARIO_PEARL AS USERS  (NOLOCK) 
	INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR (NOLOCK) ON GRUPO_APROBADOR.K_USUARIO	= USERS.K_USUARIO_PEARL
	WHERE	GRUPO_APROBADOR.K_TIPO_GRUPO_APROBADOR			= @VP_K_TIPO_GRUPO_APROBADOR
	AND		K_ESTATUS_GRUPO_APROBADOR						= 1

	SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))
	----================================================================
	----================================================================
	----================================================================
		SET @VP_SUBJECT = 'PEARL LEATHER [ORDEN_TRABAJO#' + CONVERT(VARCHAR(10),FORMAT(@PP_VALOR_ORDEN_TRABAJO,'000000')) +']'--CONVERT(VARCHAR(10),FORMAT(@VP_VALOR_PO,'000000'))+']'
	
	SET @VP_BODY_HTML =  
	N'<p style="color:black; font-size:12.0pt;font-family:"Calisto MT",serif">'+
	N'Buen día, se ha realizado una solicitud de orden de trabajo.<br>'+
	N'El registro ya se encuentra generado con el estatus de [ENVIADA] para le sea asignado un técnico. Favor de realizar el seguimiento correspondiente.<br><br>'+
	N'Este correo fue generado automáticamente por el sistema PEARL.<br><br>'+
	N'Saludos.<br> == = == = == = == = == = == = == = == = == = == = == = == = == = == = ==<br></p> <p>'
	
	EXEC msdb.dbo.sp_send_dbmail @recipients=@VP_RECIPIENTS,
--		@copy_recipients = 'ALEJANDROD@PEARLLEATHER.COM.MX',
	@blind_copy_recipients='ALEJANDROD@PEARLLEATHER.COM.MX',
	@subject = @VP_SUBJECT,
	@body = @VP_BODY_HTML,  
	@body_format = 'HTML';
	--@mailitem_id = @VP_ID_MAIL OUTPUT;

-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> ENVIAR CORREO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_ENVIAR_CORREO_ORDEN_TRABAJO_HERRAMENTAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_ENVIAR_CORREO_ORDEN_TRABAJO_HERRAMENTAL]
GO
--		 EXECUTE [dbo].[PG_PR_ENVIAR_CORREO_ORDEN_TRABAJO_HERRAMENTAL]	1,139,  1,''
CREATE PROCEDURE [dbo].[PG_PR_ENVIAR_CORREO_ORDEN_TRABAJO_HERRAMENTAL]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_VALOR_ORDEN_TRABAJO			INT,
	@PP_FILE_PATH					NVARCHAR(MAX)
AS
	DECLARE	@VP_MENSAJE		NVARCHAR(MAX)
BEGIN TRANSACTION 
BEGIN TRY
	DECLARE  @VP_RECIPIENTS		NVARCHAR(MAX)	= ''
			,@VP_FILE_PATH		NVARCHAR(MAX)	= ''	
--			,@VP_PO_INT			INT
			,@VP_SUBJECT		NVARCHAR(MAX) 
			,@VP_BODY_HTML		NVARCHAR(MAX) 
			,@VP_ID_MAIL		INT
			,@VP_SENT_STATUS	VARCHAR(500)
			,@VP_CLIENTE		VARCHAR(250)
			,@VP_K_CUSTOMER		INT
			,@VP_K_TIPO_GRUPO_APROBADOR		VARCHAR(15)	=	110
	----================================================================
	----================================================================
	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
	FROM	BD_GENERAL.dbo.USUARIO_PEARL AS USERS  (NOLOCK) 
	INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR (NOLOCK) ON GRUPO_APROBADOR.K_USUARIO	= USERS.K_USUARIO_PEARL
	WHERE	GRUPO_APROBADOR.K_TIPO_GRUPO_APROBADOR			= @VP_K_TIPO_GRUPO_APROBADOR
	AND		K_ESTATUS_GRUPO_APROBADOR						= 1

	SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))
	----================================================================

	IF @PP_FILE_PATH	= ''
	BEGIN
		SELECT	@PP_FILE_PATH		= RUTA_ORDEN_TRABAJO
		FROM	ORDEN_TRABAJO		(NOLOCK)
		WHERE	K_ORDEN_TRABAJO		= @PP_VALOR_ORDEN_TRABAJO

		IF	@PP_FILE_PATH IS NULL OR @PP_FILE_PATH = ''
		BEGIN
			RAISERROR ('ERROR: No fue posible encontrar el archivo de la [ORDEN_TRABAJO], informe a sistemas.', 16, 1 ) 
		END
	END

	--SELECT @VP_RECIPIENTS
	
	--SELECT	@VP_K_CUSTOMER	= K_TPO_CUSTOMER
	--FROM	TPO_CUSTOMER
	--WHERE	INV_NO			= @PP_VALOR_PO

	----================================================================
	UPDATE	[ORDEN_TRABAJO]
	SET		K_STATUS_ORDEN_TRABAJO	= 2,
			RUTA_ORDEN_TRABAJO		= @PP_FILE_PATH
	WHERE	K_ORDEN_TRABAJO			= @PP_VALOR_ORDEN_TRABAJO
	AND		K_STATUS_ORDEN_TRABAJO	< 2
	--IF @@ROWCOUNT = 0
	--BEGIN
	--	RAISERROR ('ERROR: No fue posible actualizar el registro de la [ORDEN_TRABAJO]', 16, 1 ) 
	--END
	----================================================================
	--IF @PP_K_SISTEMA_EXE=1
	--BEGIN
		-- USUARIO DEFAULT DE COMPRAS A DONDE SE ENVIARÁ EL CORREO.
		--SET @VP_RECIPIENTS = 'ALEJANDROD@PEARLLEATHER.COM.MX'
	--END
		--SET @VP_FILE_PATH = '\\10.1.1.5\DOCUMENTS\COMMON\APQP\TPO_CUSTOMER\INVOICE\'+ @VP_CLIENTE +'\INV_TPO_'  + CONVERT(VARCHAR(10),FORMAT(@PP_VALOR_PO,'000000')) +'.PDF'
		--SET @VP_FILE_PATH = '\\10.1.1.5\DOCUMENTS\COMMON\APQP\TPO_CUSTOMER\INVOICE\INV_TPO_'  + CONVERT(VARCHAR(10),FORMAT(@PP_VALOR_PO,'000000')) +'.PDF'
		SET @VP_SUBJECT = 'PEARL LEATHER [ORDEN_TRABAJO#' + CONVERT(VARCHAR(10),FORMAT(@PP_VALOR_ORDEN_TRABAJO,'000000')) +']'--CONVERT(VARCHAR(10),FORMAT(@VP_VALOR_PO,'000000'))+']'
	

	SET @VP_BODY_HTML =  
	N'<p style="color:black; font-size:12.0pt;font-family:"Calisto MT",serif">'+
	N'Buen día, se ha realizado una solicitud de orden de trabajo, adjunto al correo viene el archivo. Favor de realizar el seguimiento correspondiente.<br><br>'+
	--N'<br>'+
	--N'Por lo cual, si llegasen a detectar algo extraño o algún punto de mejora pueden comunicarse con:<br>'+
	--N'* Viviana Chávez  (Proyectos) Ext. 134<br>'+
	--N'* Alex de la Rosa (Sistemas)  Ext. 112<br><br>'+
	--N'Para atender las observaciones necesarias. Esto con el fin de optimizar el formato recibido.<br>'+
	N'Este correo fue generado automáticamente por el sistema PEARL.<br><br>'+
	N'Saludos.<br> == = == = == = == = == = == = == = == = == = == = == = == = == = == = ==<br></p> <p>'
	--N'Good day, <br><br>'+
	--N'Tooling invoice (TPO) is sent, please do the corresponding follow-up...<br>'+
	----N'Please confirm receipt and estimated delivery date.<br><br>'+
	--N'Regards.<br> </p> <p>'

	--N'<p><span style="color:maroon; font-size:12.0pt"><b>Fabiola Gerardo Arévalo | Compras</b></span><br>'+
	--N'<span style="color:lightpink; font-size:11pt"><b>Dirección:</b></span>'+
	--N'<span style="color:lightpink; font-size:11pt">Av. Rosa Maria Y. Fuentes 7050-A <b>|C.P.</b> 32320</span></br>'+
	--N'<span style="color:lightpink; font-size:11pt"><b>Tel.</b>656-892-5800<b>|Ext:</b>121'+
	--N'<b>|Cel.</b> 656-103-4020<o:p></o:p></span><br><br></p>'+
	--N'<p><span style="color:maroon; font-size:11pt"><b><u>RECEPCION DE MATERIAL <b>|</b> RECEIPT OF MATERIAL</u></b></span></p>'+
	--N'<p><span style="color:maroon; font-size: 8pt"><b>Lunes a Viernes | Monday to Friday: 7am -9am, 10am -2pm y 4pm -5:30pm</b></span></p>'
	
	EXEC msdb.dbo.sp_send_dbmail @recipients=@VP_RECIPIENTS,
--		@copy_recipients = 'ALEJANDROD@PEARLLEATHER.COM.MX',
	@blind_copy_recipients='ALEJANDROD@PEARLLEATHER.COM.MX',
	@subject = @VP_SUBJECT,
	@body = @VP_BODY_HTML,  
	@body_format = 'HTML', 
	@file_attachments = @PP_FILE_PATH, --EL ARCHIVO A ENVIAR DEBE ESTAR EN EL MISMO (SERVIDOR, EQUIPO) QUE SE TIENE INSTALADO EL SQLSERVER
	@mailitem_id = @VP_ID_MAIL OUTPUT;

-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH	
	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [Actualizar]: ' + @VP_MENSAJE 
	END

	SELECT	@VP_MENSAJE AS MENSAJE, @PP_VALOR_ORDEN_TRABAJO AS CLAVE
	-- //////////////////////////////////////////////////////////////	
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////


---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> INSERT
---- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_ORDEN_TRABAJO_DETALLE]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_IN_ORDEN_TRABAJO_DETALLE]
--GO
--CREATE PROCEDURE [dbo].[PG_IN_ORDEN_TRABAJO_DETALLE]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	 -- ===========================
--	@PP_K_ORDEN_TRABAJO 			INT
--	 -- ============================
--	--@PP_DESCRIPCION_ORDEN_TRABAJO	NVARCHAR(MAX),
--	--@PP_ACCIONES_ORDEN_TRABAJO		NVARCHAR(MAX),
--	--@PP_C_ORDEN_TRABAJO				NVARCHAR(MAX)
--AS			
--DECLARE  @VP_MENSAJE					NVARCHAR(MAX)	= ''
--		,@VP_K_ORDEN_TRABAJO_DETALLE	INT				= 0
--	-- /////////////////////////////////////////////////////////////////////
--	--============================================================================
--	--======================================INSERTAR EL DETALLE
--	--============================================================================
--		INSERT INTO ORDEN_TRABAJO_DETALLE
--			(	[K_ORDEN_TRABAJO]			,
--				-- =========================
--				[N_TECNICO_REALIZA]			,	[D_TECNICO_REALIZA]		,
--				-- =========================
--				[DURACION_MINUTOS]			,	[ACCION_REALIZADA]		,
--				[C_ORDEN_TRABAJO]			
--			)
--		VALUES	
--			(	@PP_K_ORDEN_TRABAJO			,
--				-- =========================
--				0							,	''						,
--				-- =========================
--				0							,	''						,
--				''							
--			)

--		IF @@ROWCOUNT = 0
--		BEGIN
--			SET @VP_MENSAJE='El registro no se ingresó (DETALLE). [OTR#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_TRABAJO)+']'
--			RAISERROR (@VP_MENSAJE, 16, 1 ) 
--		END
--		ELSE
--		BEGIN
--			SELECT @VP_K_ORDEN_TRABAJO_DETALLE	= SCOPE_IDENTITY()

--			IF	( @VP_K_ORDEN_TRABAJO_DETALLE	= 0 OR @VP_K_ORDEN_TRABAJO_DETALLE IS NULL )
--			BEGIN
--				RAISERROR ('Error en la asignación de identidad.(DETALLE)', 16, 1 ) 
--			END
--		END
--	-- //////////////////////////////////////////////////////////////
--GO