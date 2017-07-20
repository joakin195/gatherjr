DROP PROCEDURE ADMIN.VALIDAR_LINK_PSW;
CREATE OR REPLACE PROCEDURE admin.VALIDAR_LINK_PSW(x_token VARCHAR(20))
LANGUAGE SQL
  SPECIFIC admin.VALIDAR_LINK_PSW
DYNAMIC RESULT SETS 1
  ------------------------------------------------------------------------
  --Valida que el token sea valido
  ------------------------------------------------------------------------
  P1: BEGIN
  DECLARE x_usuario_cl BIGINT;
  DECLARE x_usuario VARCHAR(250) DEFAULT '';
  DECLARE x_error INTEGER DEFAULT 0;
  DECLARE x_msg VARCHAR(100) DEFAULT '';

  DECLARE cursor1 CURSOR WITH RETURN FOR
    SELECT
      x_error,
      x_msg,
      x_usuario
    FROM table(values(1)) AS x;

  SET x_usuario_cl = NULL;
  SET x_usuario_cl = (SELECT u.USUARIO
                      FROM admin.TOKEN_PSW u
                      WHERE
                        upper(ltrim(rtrim(u.TOKEN))) = upper(ltrim(rtrim(x_token))) AND u.USADA = 0
                      ORDER BY u.CREACION DESC
                      FETCH FIRST ROW ONLY);

  IF x_usuario_cl IS NULL
  THEN
    SET x_error = 1;
    SET x_msg = 'link invalido';

    OPEN cursor1;
    RETURN;
  END IF;

  SET x_usuario = NULL;
  SET x_usuario = (SELECT u.USUARIO
                   FROM admin.USUARIOS u
                   WHERE u.CLAVE = x_usuario_cl);

  UPDATE admin.TOKEN_PSW tk
  SET tk.USADA = 1
  WHERE tk.USUARIO = x_usuario_cl;

  SET x_error = 0;
  SET x_msg = 'Link valido';

  OPEN cursor1;
END P1;