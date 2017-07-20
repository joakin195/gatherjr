DROP PROCEDURE ADMIN.CAMBIAR_DATOS;
CREATE OR REPLACE PROCEDURE ADMIN.CAMBIAR_DATOS(x_sesion    BIGINT,
                                                x_nombres   VARCHAR(250),
                                                x_apell_pat VARCHAR(250),
                                                x_apell_mat VARCHAR(250),
                                                x_sexo      INTEGER,
                                                x_celular   VARCHAR(50),
                                                x_gmail     VARCHAR(200))
  SPECIFIC admin.CAMBIAR_DATOS
  -- Cambia los datos del usuario
DYNAMIC RESULT SETS 1
  P1: BEGIN
  DECLARE x_error INTEGER DEFAULT 0;
  DECLARE x_msg VARCHAR(100) DEFAULT 'Clave Cambiada';
  DECLARE cursor1 CURSOR WITH RETURN FOR
    SELECT
      x_error,
      x_msg
    FROM table(values(1)) AS x;
  SET x_nombres = trim(x_nombres);
  SET x_apell_pat = trim(x_apell_pat);
  SET x_apell_mat = trim(x_apell_mat);
  SET x_celular = trim(x_celular);
  SET x_gmail = trim(x_gmail);
  IF NOT exists(SELECT 1
                FROM admin.sesiones s
                WHERE s.clave = x_sesion)
  THEN
    SET x_error = 1;
    SET x_msg = 'Sesión Inválida';
  ELSEIF length(x_nombres) = 0
    THEN
      SET x_error = 1;
      SET x_msg = 'Debe Ingresar su Nombre';
  ELSEIF length(x_apell_pat) = 0
    THEN
      SET x_error = 1;
      SET x_msg = 'Debe Ingresar su Apellido Paterno';
  ELSEIF length(x_celular) < 8
    THEN
      SET x_error = 1;
      SET x_msg = 'Debe Ingresar su Celular';
  ELSE
    UPDATE ADMIN.USUARIOS U
    SET U.NOMBRES = x_nombres, U.APELLIDO_PAT = x_apell_pat, U.APELLIDO_MAT = x_apell_mat,
      U.SEXO      = x_sexo, U.CELULAR = x_celular, U.GMAIL = x_gmail
    WHERE u.clave = (SELECT s.usuario
                     FROM admin.sesiones s
                     WHERE s.clave = x_sesion);
  END IF;
  OPEN cursor1;
END P1;