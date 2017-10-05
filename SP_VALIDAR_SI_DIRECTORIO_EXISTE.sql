USE [BioStar]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================================================================
-- Author:		<Raul González>
-- Create date: <25/09/2017>
/* Description:	<
					VALIDAR SI UN DIRECOTRIO EXISTE O NO EN EL EQUIPO.
					EN CASO DE NO EXISTIR, LO CREA. FUNCIONA PARA ALMACENAR FOTOGRAFÍAS DE LOS CHECADORES EN UNA RUTA
					ESPECIFICADA EN EL EQUIPO LOCAL.
				>
-- ACTIVAR BCP UTILITY "XP_CMDSHELL" CON LAS SIGUIENTES INSTRUCCIONES PARA CREAR EL DIRECTORIO EN CASO DE NO EXISTIR
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'xp_cmdshell',1
GO
RECONFIGURE
GO

-- =====================================================================================================================
*/
CREATE PROCEDURE [dbo].[validarRuta]
(
	-- PARÁMETROS:
	-- RUTA DEL DIRECTORIO A EVALUAR
	@pPath varchar(4000)
)
AS
BEGIN
	--DECLARE @RUTA VARCHAR(4000);
	DECLARE @pathExist INT;
	DECLARE @file_results TABLE
    (
	file_exists INT,
    file_is_a_directory INT,
    parent_directory_exists INT
    );
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--EJECUTAMOS LA CONSULTA Y ALMACENAMOS LOS DATOS EN UNA TABLA TEMPORAL
	--SET @RUTA = @pPath;
	INSERT INTO @file_results
    (file_exists, file_is_a_directory, parent_directory_exists)
    EXEC MASTER.dbo.xp_fileexist @pPath;
	--OBTENER EL VALOR 1 Ó 0 DEPENDIENDO SI EL DIRECTORIO EXISTE O NO LA VARIABLE
	SET @pathExist = (SELECT file_is_a_directory FROM @file_results);
	--SI LA RUTA NO EXISTE, CREAR LA CARPETA. EN CASO CONTRARIO NO HACE NADA
	IF @pathExist = 0
		BEGIN
			EXEC MASTER.dbo.xp_create_subdir @pPath;
		END	
END
