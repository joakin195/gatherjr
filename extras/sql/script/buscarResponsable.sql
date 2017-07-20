SELECT
  u.clave,
  u.NOMBRES
FROM admin.usuarios u, wf_obj.roles_usu ru, wf_obj.roles_tareas rt
WHERE u.usuario = ru.usuario AND ru.default = 1 AND ru.estado = 1 AND
      rt.rol = ru.rol AND rt.tarea = 10
WITH UR;

SELECT u.CLAVE
FROM admin.usuarios u
WHERE u.USUARIO = 'DB2ADMIN'
WITH UR;
