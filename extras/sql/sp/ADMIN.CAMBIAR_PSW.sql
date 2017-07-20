DROP PROCEDURE ADMIN.CAMBIAR_PSW;
CREATE OR REPLACE PROCEDURE ADMIN.CAMBIAR_PSW(x_sesion  BIGINT,
                                              x_usuario VARCHAR(30), x_passwd VARCHAR(32))
  SPECIFIC admin.CAMBIAR_PSW
  -- Cambia el password del usuario. La sesión debe ser del mismo usuario
DYNAMIC RESULT SETS 1
  P1: BEGIN
  DECLARE x_pregunta_password INTEGER;
  DECLARE x_sesion_out, x_usu_cl BIGINT;
  DECLARE x_error INTEGER DEFAULT 0;
  DECLARE x_msg VARCHAR(100) DEFAULT 'Clave Cambiada';
  DECLARE cursor1 CURSOR WITH RETURN FOR
    SELECT
      x_error,
      x_msg
    FROM table(values(1)) AS x;
  SET ENCRYPTION PASSWORD = '142857';
  SET x_usuario = trim(upper(x_usuario));
  IF NOT exists(SELECT 1
                FROM admin.usuarios u
                WHERE trim(upper(u.usuario)) = x_usuario)
  THEN
    SET x_error = 1;
    SET x_msg = 'Usuario Inválidos';
  ELSEIF NOT exists(SELECT 1
                    FROM admin.usuarios u
                    WHERE trim(upper(u.usuario)) = x_usuario AND u.estado = 1)
    THEN
      SET x_error = 1;
      SET x_msg = 'Usuario Eliminado';
  ELSEIF NOT exists(SELECT 1
                    FROM admin.usuarios u, admin.sesiones s
                    WHERE trim(upper(u.usuario)) = x_usuario AND u.clave = s.usuario AND s.clave = x_sesion)
    THEN
      SET x_error = 1;
      SET x_msg = 'Usuario No Corresponde a la Conexión';
  ELSEIF exists(SELECT 1
                FROM admin.usuarios u, admin.sesiones s
                WHERE trim(upper(u.usuario)) = x_usuario AND u.clave = s.usuario AND s.clave > x_sesion)
    THEN
      SET x_error = 1;
      SET x_msg = 'Usuario Conectado en otro Computador';
  ELSE
    UPDATE admin.usuarios u
    SET u.passwd = encrypt(ltrim(rtrim(upper(x_passwd)))), CAMBIAR_PSW = 0
    WHERE trim(upper(u.usuario)) = x_usuario;
  END IF;
  OPEN cursor1;
END P1;