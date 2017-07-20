DROP PROCEDURE ADMIN.GENERAR_LINK_PSW;
CREATE OR REPLACE PROCEDURE admin.GENERAR_LINK_PSW(x_usuario VARCHAR(250), x_mail VARCHAR(200))
LANGUAGE SQL
  SPECIFIC admin.GENERAR_LINK_PSW
DYNAMIC RESULT SETS 1
  ------------------------------------------------------------------------
  --Genera un nuevo link y su token de validación
  --Anula los tokens generados anteriormente para el x_usuario (admin.TOKEN_PSW.usada = 1)
  ------------------------------------------------------------------------
  P1: BEGIN
  DECLARE x_sesion BIGINT;
  DECLARE x_usuario_cl INTEGER;
  DECLARE x_error INTEGER DEFAULT 0;
  DECLARE x_msg VARCHAR(100) DEFAULT '';
  DECLARE x_token VARCHAR(20) DEFAULT '';
  DECLARE x_celular VARCHAR(50) DEFAULT '';
  DECLARE x_link VARCHAR(100) DEFAULT '';
  DECLARE x_nombre VARCHAR(100) DEFAULT '';

  DECLARE cursor1 CURSOR WITH RETURN FOR
    SELECT
      x_error,
      x_msg,
      x_link,
      x_mail,
      x_celular,
      x_token,
      x_nombre
    FROM table(values(1)) AS x;

  SET x_usuario = upper(ltrim(rtrim(x_usuario)));
  SET x_mail = upper(ltrim(rtrim(x_mail)));

  IF (SELECT count(*)
      FROM admin.usuarios u
      WHERE
        upper(ltrim(rtrim(u.usuario))) = x_usuario OR
        upper(ltrim(rtrim(u.gmail))) = x_mail) > 1
  THEN
    SET x_error = 1;
    SET x_msg = 'Existe mas de un usuario con el mismo mail';
    OPEN cursor1;
    RETURN;
  END IF;

  SET x_usuario_cl = NULL;
  SET (x_usuario_cl, x_mail, x_celular, x_nombre) = (SELECT
                                                       u.clave,
                                                       u.gmail,
                                                       u.celular,
                                                       u.NOMBRES
                                                     FROM admin.usuarios u
                                                     WHERE
                                                       upper(ltrim(rtrim(u.usuario))) = x_usuario OR
                                                       upper(ltrim(rtrim(u.gmail))) = x_mail);

  IF x_usuario_cl IS NULL
  THEN
    SET x_error = 1;
    SET x_msg = 'Usuario invalido';
    OPEN cursor1;
    RETURN;
  END IF;

  IF x_mail IS NULL AND x_celular IS NULL
  THEN
    SET x_error = 1;
    SET x_msg = 'Usuario no cuenta con un mail o celular para el envio del link';
    OPEN cursor1;
    RETURN;
  END IF;


  SET x_token = (SELECT CHR(INT(RAND() * 26) + 65) || CHR(INT(RAND() * 26) + 65) || CHR(INT(RAND() * 26) + 65) ||
                        CHR(INT(RAND() * 26) + 65) || CAST(INT(RAND() * 1000000000) AS CHAR(4)) ||
                        CHR(INT(RAND() * 26) + 65) || CHR(INT(RAND() * 26) + 65) || CHR(INT(RAND() * 26) + 65) ||
                        CHR(INT(RAND() * 26) + 65) || CAST(INT(RAND() * 1000000000) AS CHAR(4)) ||
                        CHR(INT(RAND() * 26) + 65) || CHR(INT(RAND() * 26) + 65) || CHR(INT(RAND() * 26) + 65)
                 FROM table(values(1)) AS x);

  UPDATE admin.TOKEN_PSW tk
  SET tk.USADA = 1
  WHERE tk.USUARIO = x_usuario_cl;

  INSERT INTO admin.TOKEN_PSW (TOKEN, USUARIO) VALUES (x_token, x_usuario_cl);

  UPDATE admin.usuarios u
  SET CAMBIAR_PSW = 1
  WHERE u.CLAVE = x_usuario_cl;

  SET x_error = 0;
  SET x_msg = 'Link generado existosamente';
  SET x_link = 'http://184.73.193.49:8080/wf/cambioPassword.jsf?tk=' || x_token;

  OPEN cursor1;
END P1;