CREATE OR REPLACE PROCEDURE ADMIN.LOGIN_ADM(x_usuario VARCHAR(30), x_passwd VARCHAR(32))
  SPECIFIC admin.LOGIN_ADM
  -- PARA QUE DB2ADMIN PUEDA INGRESAR COMO OTRO USUARIO
DYNAMIC RESULT SETS 1
  P1: BEGIN
  DECLARE x_pregunta_password INTEGER;
  DECLARE x_sesion_out, x_usu_cl BIGINT;
  DECLARE x_error INTEGER DEFAULT 0;
  DECLARE x_msg VARCHAR(100) DEFAULT 'Usuario Conectado';
  DECLARE cursor1 CURSOR WITH RETURN FOR
    SELECT
      x_error,
      x_msg,
      x_sesion_out,
      x_pregunta_password pregunta_password
    FROM table(values(1)) AS x;
  SET ENCRYPTION PASSWORD = '142857';
  SET x_usuario = trim(upper(x_usuario));

  IF NOT exists(SELECT 1
                FROM admin.usuarios u
                WHERE trim(upper(u.usuario)) = 'DB2ADMIN' AND u.passwd = encrypt(ltrim(rtrim(upper(x_passwd)))))
  THEN
    SET x_error = 1;
    SET x_msg = 'Usuario/Clave Inválidos';
  ELSEIF NOT exists(SELECT 1
                    FROM admin.usuarios u
                    WHERE trim(upper(u.usuario)) = x_usuario)
    THEN
      SET x_error = 1;
      SET x_msg = 'Usuario/Clave Inválidos';
  ELSEIF NOT exists(SELECT 1
                    FROM admin.usuarios u
                    WHERE trim(upper(u.usuario)) = x_usuario AND u.estado = 1)
    THEN
      SET x_error = 1;
      SET x_msg = 'Usuario Eliminado';
  ELSE
    SELECT
      u.clave,
      u.cambiar_psw
    INTO x_usu_cl, x_pregunta_password
    FROM admin.usuarios u
    WHERE upper(ltrim(rtrim(u.usuario))) = upper(ltrim(rtrim(x_usuario)));

    CALL admin.generar_sesion(x_usuario);
    SET x_sesion_out = (SELECT max(s.clave)
                        FROM admin.sesiones s
                        WHERE s.usuario = x_usu_cl);
  END IF;
  OPEN cursor1;
END P1;