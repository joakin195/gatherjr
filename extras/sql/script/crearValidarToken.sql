CALL ADMIN.GENERAR_LINK_PSW('db2admin', NULL);
CALL ADMIN.VALIDAR_LINK_PSW('AKUBFKQIOVZR');


SELECT
  u.usuario,
  u.TOKEN,
  CASE WHEN upper(ltrim(rtrim(u.TOKEN))) = upper(ltrim(rtrim('QEHABCJVIEBD')))
    THEN 'si'
  ELSE 'no' END
FROM admin.TOKEN_PSW u
WHERE
  upper(ltrim(rtrim(u.TOKEN))) = upper(ltrim(rtrim('QEHABCJVIEBD'))) AND u.USADA = 0
WITH UR;

SELECT *
FROM admin.TOKEN_PSW
WHERE USUARIO = 1
WITH UR;
