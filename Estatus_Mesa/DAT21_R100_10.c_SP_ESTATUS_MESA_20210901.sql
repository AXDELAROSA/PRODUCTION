-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			ESTATUS_MESA
-- // OPERATION:		SP'S
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210901
-- ////////////////////////////////////////////////////////////// 

USE	[DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////		CONTENIDO DEL SP
--	[PG_LI_CARGAR_ORDENES_ESTATUS_MESA]
-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_CARGAR_ORDENES_ESTATUS_MESA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_CARGAR_ORDENES_ESTATUS_MESA]
GO
--		 EXECUTE [dbo].[PG_LI_CARGAR_ORDENES_ESTATUS_MESA] 0,87,''
--		 EXECUTE [dbo].[PG_LI_CARGAR_ORDENES_ESTATUS_MESA] 0,165,''
CREATE PROCEDURE [dbo].[PG_LI_CARGAR_ORDENES_ESTATUS_MESA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_BUSCAR						VARCHAR(25)
AS
	DECLARE	 @VP_MENSAJE			NVARCHAR(MAX)	= ''
--================================================================================================================================================================================
--================================================================================================================================================================================
--================================================================================================================================================================================
BEGIN TRANSACTION 
BEGIN TRY
	DECLARE	@TABLE_FINAL	TABLE
	(	
		TAF_NO_MESA			VARCHAR(50),
		TAF_ORDEN_ABIERTA	VARCHAR(50),
		TAF_COLOUR			VARCHAR(50),
		TAF_PROGRAMA		VARCHAR(50),
		TAF_LOTE			VARCHAR(50),
		TAF_PIELES			VARCHAR(50),--INT,
		TAF_SQFT_TRANS		VARCHAR(50),--DECIMAL(19,4),
		TAF_DADOS_CO		VARCHAR(50),--INT,
		TAF_DADOS_PN		VARCHAR(50),--INT,
		TAF_PORCENTAJE		VARCHAR(50),--DECIMAL(19,4),
		TAF_SQF				VARCHAR(50),
		TAF_TABLERO			VARCHAR(50) ,--NOT NULL DEFAULT '',
		TAF_COLOR2			VARCHAR(50) ,--NOT NULL DEFAULT '',
		TAF_COL				VARCHAR(50) ,--NOT NULL DEFAULT '',
		TAF_DATECREATED		VARCHAR(50)
	)
--================================================================================================================================================================================
--================================================================================================================================================================================
--================================================================================================================================================================================
	DECLARE	@TABLE_SELECT	TABLE
	(	TA_JOBNO			VARCHAR(50),
		TA_STATUS			VARCHAR(50),
		TA_COLOUR			VARCHAR(50),
		TA_COLOURDESC		VARCHAR(500),
		TA_MACHINE			VARCHAR(50),
		TA_DATECREATED		VARCHAR(50),
		TA_DATEPLANNED		VARCHAR(50),
		TA_NETSQM			DECIMAL(19,2),
		TA_STANDARDSQM		DECIMAL(19,2),
		TA_CUSTOMER			VARCHAR(50),
		TA_PATTERNS			INT,
		TA_LOTNO			VARCHAR(50),
		TA_FOLIO			VARCHAR(50),
		TA_PROD_CAT			VARCHAR(50),
		TA_PROD_CAT_DESC	VARCHAR(500)
	)
	
	INSERT INTO @TABLE_SELECT
	SELECT DISTINCT 
			JOBNO,				[STATUS],				COLOUR,						COLOURDESC,		
			MACHINE,			DATECREATED,			DATEPLANNED,				NETSQM,		
			STANDARDSQM,		CUSTOMER,				PATTERNS,					LOTNO,		
			FOLIO,				IMITMIDX_SQL.PROD_CAT,	IMCATFIL_SQL.PROD_CAT_DESC
	FROM CCJOBHDR_SQL		(NOLOCK)
	INNER JOIN IMITMIDX_SQL (NOLOCK) ON MACHINE	IN  (	---'TABLE 79'
													SELECT	LTRIM(RTRIM(loc_desc))
													FROM	DATA_02.DBO.imlocfil_sql	(NOLOCK)
													WHERE	SUBSTRING(LTRIM(RTRIM(loc_desc)),1,1) = 'T'
												)	
	AND		[STATUS]		='P' 
	AND		STARTEDFLAG		='Y' 
	AND		ITEM_NO			= CONCAT('F',CCJOBHDR_SQL.COLOUR) 
	INNER JOIN IMCATFIL_SQL (NOLOCK) ON IMITMIDX_SQL.PROD_CAT=IMCATFIL_SQL.PROD_CAT 
	ORDER	BY MACHINE,	DATECREATED DESC
--================================================================================================================================================================================
--================================================================================================================================================================================
--================================================================================================================================================================================

		-----==========================================================		
		DECLARE	@VP_CU_JOBNO			VARCHAR(50),
				@VP_CU_STATUS			VARCHAR(50),
				@VP_CU_COLOUR			VARCHAR(50),
				@VP_CU_COLOURDESC		VARCHAR(500),
				@VP_CU_MACHINE			VARCHAR(50),
				@VP_CU_DATECREATED		VARCHAR(50),
				@VP_CU_DATEPLANNED		VARCHAR(50),
				@VP_CU_NETSQM			DECIMAL(19,2),
				@VP_CU_STANDARDSQM		DECIMAL(19,2),
				@VP_CU_CUSTOMER			VARCHAR(50),
				@VP_CU_PATTERNS			INT,
				@VP_CU_LOTNO			VARCHAR(50),
				@VP_CU_FOLIO			VARCHAR(50),
				@VP_CU_PROD_CAT			VARCHAR(50),
				@VP_CU_PROD_CAT_DESC	VARCHAR(500),
				@VP_MESA_ANTERIOR		VARCHAR(50),
				@VP_L_SET_MESA			INT	= 0

--===================================================================================================================================================================================================================================================
--===================================================================================================================================================================================================================================================
		
		--IF (	SELECT COUNT(@VP_CU_JOBNO)	FROM @TABLE_SELECT	)	>= 0
		--	RAISERROR ('SIN REGISTROS', 16, 1 )


		DECLARE CU_CURSOR				CURSOR LOCAL STATIC FOR
			SELECT * FROM @TABLE_SELECT
			ORDER BY TA_MACHINE,	TA_DATECREATED
		OPEN CU_CURSOR
			FETCH NEXT FROM CU_CURSOR INTO	@VP_CU_JOBNO			,@VP_CU_STATUS			,@VP_CU_COLOUR			,@VP_CU_COLOURDESC		,
											@VP_CU_MACHINE			,@VP_CU_DATECREATED		,@VP_CU_DATEPLANNED		,@VP_CU_NETSQM			,
											@VP_CU_STANDARDSQM		,@VP_CU_CUSTOMER		,@VP_CU_PATTERNS		,@VP_CU_LOTNO			,
											@VP_CU_FOLIO			,@VP_CU_PROD_CAT		,@VP_CU_PROD_CAT_DESC	
			WHILE @@FETCH_STATUS = 0
			BEGIN
			-----==========================================================
			--	VARIABLES DEL CURSOR
			DECLARE	 @VP_SQFT			DECIMAL(19,2)
					----------------------------------------
					,@VP_HIDES			INT
					,@VP_CUTPATRONES	INT
					,@VP_NET			DECIMAL(19,2)
					,@VP_SQF			DECIMAL(19,2)
					----------------------------------------
					,@VP_LOTNO			VARCHAR(50)	= ''
					----------------------------------------
					,@VP_PORCENTAJE		DECIMAL(19,2)
					----------------------------------------
					,@VP_SINO			VARCHAR(50)	= ''


			-----==========================================================
			--	PARA OBTENER EL SQFT DEL GetAllocatedHidesSupMat
			SELECT	@VP_SQFT	=	ISNULL(	SUM(	(CASE
												WHEN	doc_type	= 'I' THEN	(trx_qty * -1)
												WHEN	doc_type	= 'R' THEN	(trx_qty *  1)
												WHEN	doc_type	= 'T' THEN	
															(CASE
																WHEN	IMLSTRX_SQL.LEV_NO	= 1 THEN	(trx_qty *   1)
																ELSE	(trx_qty *  -1)
															END)
											END)
										)
									,0)
			FROM	IMLSTRX_SQL				(NOLOCK)
			INNER JOIN IMINVTRX_SQL			(NOLOCK)	ON	IMLSTRX_SQL.[source] = IMINVTRX_SQL.[source]
			AND		IMLSTRX_SQL.ord_no		= IMINVTRX_SQL.ord_no
			AND		IMLSTRX_SQL.ctl_no		= IMINVTRX_SQL.ctl_no
			AND		IMLSTRX_SQL.line_no		= IMINVTRX_SQL.line_no
			AND		IMLSTRX_SQL.lev_no		= IMINVTRX_SQL.lev_no
			AND		IMLSTRX_SQL.seq_no		= IMINVTRX_SQL.seq_no
			WHERE	IMINVTRX_SQL.item_no	= 'F' + LTRIM(RTRIM(@VP_CU_COLOUR))		--'" + Trim(item) +' --'" + loc +' 
			AND		IMINVTRX_SQL.loc 	IN  (	SELECT	LTRIM(RTRIM(loc))
												FROM	DATA_02.DBO.imlocfil_sql	(NOLOCK)
												WHERE	SUBSTRING(LTRIM(RTRIM(loc_desc)),1,1) = 'T'		)
			AND (	IMINVTRX_SQL.doc_ord_no =		LTRIM(RTRIM(@VP_CU_JOBNO))
				OR	IMINVTRX_SQL.doc_ord_no = 'J' + LTRIM(RTRIM(@VP_CU_JOBNO))	--or	IMINVTRX_SQL.doc_ord_no = LTRIM(RTRIM((@VP_CU_JOBNO))
				)

			-----==========================================================
			-----==========================================================
			--SE OBTIENEN VALORES DEL rs2	A UTILIZAR MÁS ADELANTE.
			SELECT	 @VP_HIDES			= COUNT(HIDES)			--AS HIDES,
					,@VP_CUTPATRONES	= SUM(RAWPATTERNS)		--AS CUTPATRONES,
					,@VP_NET			= SUM(RAWPATTERNSQM)	--AS NET, 
					,@VP_SQF			= SUM(HIDESQM)			--AS SQF 
			FROM	CCCUTHST_SQL		(NOLOCK)
			WHERE	JOBNO				IN	(	@VP_CU_JOBNO	)--'" & TRIM(RS("JOBNO").VALUE) & "'

			-----==========================================================
			-----==========================================================
			--	SE VALIDA EL VALOR DEL rs3	PARA CONOCER EL VALOR DEL PORCENTAJE.			
			IF (	SELECT	TOP (1)	COUNT(JOBNO)
					FROM	CCCUTHST_SQL	(NOLOCK)
					WHERE	JOBNO			=	LTRIM(RTRIM(@VP_CU_JOBNO))		)	> 0
			BEGIN
					SELECT	TOP (1)	
							@VP_LOTNO	= LOTNO	--SUM(HIDESQM) AS QTY
					FROM	CCCUTHST_SQL	(NOLOCK)
					WHERE	JOBNO			=	LTRIM(RTRIM(@VP_CU_JOBNO))
					GROUP	BY LOTNO 
					ORDER	BY LOTNO  DESC

				--	porcentaje		= Format(100 * Val(rs2("net").Value) / Val(rs("netsqm").Value), "##0.0")
				SET	@VP_PORCENTAJE	= ( 100 * @VP_NET ) / @VP_CU_NETSQM

					IF	@VP_PORCENTAJE	<= 95
					BEGIN
						SET @VP_SINO	= 'SI'
					END
					ELSE
					BEGIN
						SET @VP_SINO	= 'NO'
					END					

					INSERT INTO	@TABLE_FINAL
					VALUES	(	@VP_CU_MACHINE,		@VP_CU_JOBNO,	('F' + LTRIM(RTRIM(@VP_CU_COLOUR))),		@VP_CU_PROD_CAT_DESC,
								@VP_LOTNO,			@VP_HIDES,		@VP_SQFT,									@VP_CUTPATRONES,
								(@VP_CU_PATTERNS- @VP_CUTPATRONES),
								CONCAT(	CONVERT( VARCHAR(10),	FORMAT( ( 100 * @VP_NET ) / @VP_CU_NETSQM ,'00.0') ) ,' %'),
								--CONVERT( VARCHAR(10),	FORMAT( ( 100 * @VP_NET ) / @VP_CU_NETSQM ,'00.0') ),
								@VP_SQF,
								' ',
								' ',
								--0,
								@VP_SINO,
								@VP_CU_DATECREATED	)
								--,50	)
					--IF @@ROWCOUNT = 0
					--BEGIN
					--	SET @VP_MENSAJE='Error en INSERT'
					--	RAISERROR (@VP_MENSAJE, 16, 1 )
					--END
			END
			ELSE
			BEGIN
					INSERT INTO	@TABLE_FINAL
					VALUES	(	@VP_CU_MACHINE,		@VP_CU_JOBNO,	('F' + LTRIM(RTRIM(@VP_CU_COLOUR))),		@VP_CU_PROD_CAT_DESC,
								' ',				'',				0,											0,
								@VP_CU_PATTERNS,
								'0 %',
								' ',
								' ',
								--' ',
								0,
								'SI',
								@VP_CU_DATECREATED	)
					--IF @@ROWCOUNT = 0
					--BEGIN
					--	SET @VP_MENSAJE='Error en INSERT'
					--	RAISERROR (@VP_MENSAJE, 16, 1 )
					--END
			END

				-----==========================================================
				IF @VP_L_SET_MESA	= 0
				BEGIN
					SET	@VP_MESA_ANTERIOR	= @VP_CU_MACHINE
					SET	@VP_L_SET_MESA	= 1
				END
				-----==========================================================
			FETCH NEXT FROM CU_CURSOR INTO	@VP_CU_JOBNO			,@VP_CU_STATUS			,@VP_CU_COLOUR			,@VP_CU_COLOURDESC		,
											@VP_CU_MACHINE			,@VP_CU_DATECREATED		,@VP_CU_DATEPLANNED		,@VP_CU_NETSQM			,
											@VP_CU_STANDARDSQM		,@VP_CU_CUSTOMER		,@VP_CU_PATTERNS		,@VP_CU_LOTNO			,
											@VP_CU_FOLIO			,@VP_CU_PROD_CAT		,@VP_CU_PROD_CAT_DESC	
			
				--IF @VP_MESA_ANTERIOR	<>	@VP_CU_MACHINE
				--BEGIN
				--	SET	@VP_L_SET_MESA	= 0

				--	IF	(	SELECT	COUNT(JOBNO)
				--			FROM	CCJOBHDR_SQL	(NOLOCK)
				--			WHERE	MACHINE			=  @VP_MESA_ANTERIOR
				--			AND		[STATUS]		=  'P'
				--			AND		STARTEDFLAG		<> 'Y'
				--			AND		STARTEDFLAG		<> 'C'	)	> 0
				--	BEGIN

				--		INSERT INTO	@TABLE_FINAL
				--		--VALUES	(	@VP_CU_MACHINE,		'Ordenes en Tablero',	' ',		' ',
				--		VALUES	(	@VP_MESA_ANTERIOR,		'Ordenes en Tablero',	' ',		' ',
				--					' ',				' ',					' ',			' ',
				--					' ',				' ',					' ',		
				--					' ',				' ',					' ',
				--					' '	)
				--		IF @@ROWCOUNT = 0
				--		BEGIN
				--			SET @VP_MENSAJE='Error en INSERT'
				--			RAISERROR (@VP_MENSAJE, 16, 1 )
				--		END

				--		INSERT INTO	@TABLE_FINAL
				--		--SELECT	@VP_CU_MACHINE,		JOBNO,		('F' + LTRIM(RTRIM(COLOUR))),		' ',
				--		SELECT	@VP_MESA_ANTERIOR,		JOBNO,		('F' + LTRIM(RTRIM(COLOUR))),		' ',
				--				' ',				' ',		' ',									' ',
				--				' ',
				--				' ',
				--				' ',
				--				' ',				' ',		' ',
				--				' '	
				--		FROM	CCJOBHDR_SQL	(NOLOCK)
				--		--WHERE	MACHINE			=  @VP_CU_MACHINE
				--		WHERE	MACHINE			=  @VP_MESA_ANTERIOR
				--		AND		[STATUS]		=  'P'
				--		AND		STARTEDFLAG		<> 'Y'
				--		AND		STARTEDFLAG		<> 'C'
				--	END

				--	INSERT INTO	@TABLE_FINAL
				--	VALUES	(	@VP_MESA_ANTERIOR,		' - ',	' - ',		' - ',
				--				' - ',				' - ',					' - ',		' - ',
				--				' - ',				' - ',					' - ',		
				--				' - ',				' - ',					' - ',
				--				' -1 '	)
				--	IF @@ROWCOUNT = 0
				--	BEGIN
				--		SET @VP_MENSAJE='Error en INSERT'
				--		RAISERROR (@VP_MENSAJE, 16, 1 )
				--	END
				--END

			END
		CLOSE		CU_CURSOR
		DEALLOCATE	CU_CURSOR
		
COMMIT TRANSACTION
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH

IF	@VP_MENSAJE	<> ''
BEGIN
	SELECT	@VP_MENSAJE AS MENSAJE
END
ELSE
BEGIN
	SELECT	
		LTRIM(RTRIM(TAF_NO_MESA))		AS NO_MESA,
		LTRIM(RTRIM(TAF_ORDEN_ABIERTA))	AS WIP,
		TAF_COLOUR						AS COLOUR,
		LTRIM(RTRIM(TAF_PROGRAMA))		AS PROGRAMA,
		LTRIM(RTRIM(TAF_LOTE))			AS LOTE,
		TAF_PIELES						AS PIELES,
		--FORMAT(TAF_SQFT_TRANS,'0.00')	AS SQFT,
		TAF_SQFT_TRANS					AS SQFT,
		TAF_DADOS_CO					AS DADOS,
		TAF_DADOS_PN					AS DATOSP,
		TAF_PORCENTAJE					AS PORCENTAJE,
		TAF_SQF							AS SQF,
		TAF_TABLERO						AS TABLERO		,
		TAF_COLOR2						AS COLOR2		,
		TAF_COL							AS COL			,
		TAF_DATECREATED					AS ACTUAL
	FROM	@TABLE_FINAL
	--ORDER	BY TAF_NO_MESA, TAF_DATECREATED	DESC
END

-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////