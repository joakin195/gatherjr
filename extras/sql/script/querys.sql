CALL WF.COMPOSICION_PROCESO(777, NULL);

SELECT t.proceso
FROM wf_obj.tareas t
WHERE t.clave = 20
WITH UR;


SELECT u.CELULAR
FROM wf_obj.procesos p
  INNER JOIN wf_obj.roles_proc rp ON p.clave = 1 AND rp.proceso = p.clave AND rp.estado = 1
  INNER JOIN wf_obj.roles r ON r.clave = rp.rol AND r.estado = 1
  INNER JOIN wf_obj.roles_usu ru ON ru.rol = r.clave AND ru.estado = 1
  INNER JOIN admin.usuarios u ON ru.usuario = u.usuario AND u.estado = 1
UNION
SELECT u.CELULAR
FROM wf_obj.tareas T
  INNER JOIN wf_obj.roles_tareas rt ON t.clave = 20 AND rt.tarea = t.clave AND rt.estado = 1
  INNER JOIN wf_obj.roles r ON r.clave = rt.rol AND r.estado = 1
  INNER JOIN wf_obj.roles_usu ru ON ru.rol = r.clave AND ru.estado = 1
  INNER JOIN admin.usuarios u ON ru.usuario = u.usuario AND u.estado = 1
UNION
SELECT u.CELULAR
FROM wf_obj.tareas T
  INNER JOIN wf_obj.tareas_checks tc ON
                                       t.clave = 20 AND t.clave = tc.tarea
  INNER JOIN wf_obj.roles_check rc ON
                                     rc.check_tarea = tc.clave AND rc.estado = 1
  INNER JOIN wf_obj.roles r ON r.clave = rc.rol AND r.estado = 1
  INNER JOIN wf_obj.roles_usu ru ON ru.rol = r.clave AND ru.estado = 1
  INNER JOIN admin.usuarios u ON ru.usuario = u.usuario AND u.estado = 1
WITH UR;


SELECT *
FROM admin.SESIONES
WHERE CLAVE = 894
WITH UR;

SELECT *
FROM admin.USUARIOS
WHERE CLAVE = 61
WITH UR;


SELECT *
FROM WF_INST.PROCESOS
WHERE USU_CREADOR = 61
WITH UR;


SELECT *
FROM WF_INST.PROCESOS
WHERE USU_CREADOR <> 'DB2ADMIN'
FETCH FIRST 10 ROWS ONLY
WITH UR;


SELECT *
FROM WF_OBJ.ROLES
WITH UR
