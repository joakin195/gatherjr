SET ENCRYPTION PASSWORD = '142857';
UPDATE admin.usuarios u
SET u.passwd = encrypt(ltrim(rtrim(upper('NDONOSO')))), CAMBIAR_PSW = 0
WHERE trim(upper(u.usuario)) = 'NDONOSO';
