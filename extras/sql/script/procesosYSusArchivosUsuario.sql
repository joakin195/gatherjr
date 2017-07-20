--LISTA LOS PROCESOS A LOS QUE TIENE ACCESO UN USUARIO

SELECT
  imp.MEGA_PROCESO mega_obj_cl,
  imp.clave        mega_inst_cl,
  imp.descripcion  mega_inst_desc,
  ip.proceso       proceso_obj_clave,
  ip.clave         proceso_inst_cl,
  ip.nombre        proceso_inst_nombre,
  it.clave         tarea_inst_cl,
  it.PROCESO       tarea_inst_proceso,
  to.DESCRIPCION   tarea_obj_desc,
  ar.clave         archivo_inst_cl,
  ar.DESCRIPCION   archivo_inst_desc,
  ar.NOMBRE_ARCHIVO
FROM
  WF_INST.tareas it
  INNER JOIN
  WF_INST.procesos ip
    ON it.proceso = ip.clave AND
       it.tarea_siguiente IS NULL
  INNER JOIN
  wf_inst.mega_procesos imp
    ON imp.clave = ip.mega_proceso
  INNER JOIN
  wf_inst.ARCHIVOS ar
    ON imp.CLAVE = ar.MEGA_PROCESO
  INNER JOIN
  wf_obj.tareas to
    ON to.clave = it.tarea AND
       to.tipo IN (0, 1)
WHERE
  exists(SELECT
           1
         FROM
           wf_obj.roles_mega_proc rp
           INNER JOIN
           wf_obj.roles r
             ON rp.mega_proceso = imp.mega_proceso AND
                rp.estado = 1 AND
                r.clave = rp.rol AND
                r.estado = 1
           INNER JOIN
           wf_obj.roles_usu ru
             ON ru.rol = r.clave AND
                ru.estado = 1
           INNER JOIN
           admin.usuarios u
             ON ru.usuario = u.usuario AND
                u.estado = 1 AND u.usuario = 'DB2ADMIN'
         UNION
         SELECT
           1
         FROM
           wf_obj.tareas ot
           INNER JOIN
           wf_obj.roles_tareas rt
             ON ot.proceso = ip.proceso AND
                rt.tarea = ot.clave AND
                rt.estado = 1
           INNER JOIN
           wf_obj.roles r
             ON r.clave = rt.rol AND
                r.estado = 1
           INNER JOIN
           wf_obj.roles_usu ru
             ON ru.rol = r.clave AND
                ru.estado = 1
           INNER JOIN
           admin.usuarios u
             ON ru.usuario = u.usuario AND
                u.estado = 1 AND
                u.usuario = 'DB2ADMIN'
         UNION
         SELECT
           1
         FROM
           wf_obj.tareas t
           INNER JOIN
           wf_obj.tareas_checks tc
             ON t.proceso = ip.proceso AND
                t.clave = tc.tarea
           INNER JOIN
           wf_obj.roles_check rc
             ON rc.check_tarea = tc.clave AND
                rc.estado = 1
           INNER JOIN
           wf_obj.roles r
             ON r.clave = rc.rol AND
                r.estado = 1
           INNER JOIN
           wf_obj.roles_usu ru
             ON ru.rol = r.clave AND
                ru.estado = 1
           INNER JOIN
           admin.usuarios u
             ON ru.usuario = u.usuario AND
                u.estado = 1 AND
                u.usuario = 'DB2ADMIN')
ORDER BY ar.CLAVE, IP.CLAVE
WITH UR;




