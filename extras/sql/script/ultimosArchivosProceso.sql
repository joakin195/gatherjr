--LISTA LOS ARCHIVOS A LOS QUE TIENE ACCESO UN USUARIO

SELECT
  imp.clave       mega_inst_cl,
  imp.DESCRIPCION mega_inst_desc,
  ar.clave        archivo_inst_cl,
  ar.DESCRIPCION  archivo_inst_desc
FROM
  wf_inst.mega_procesos imp
  INNER JOIN
  wf_inst.ARCHIVOS ar
    ON imp.CLAVE = ar.MEGA_PROCESO
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
             ON ru.rol = r.clave AND ru.estado = 1
           INNER JOIN
           admin.usuarios u
             ON ru.usuario = u.usuario AND
                u.estado = 1 AND
                u.usuario = 'AREVECO'
         UNION
         SELECT
           1
         FROM
           WF_INST.PROCESOS ip
           INNER JOIN
           WF_OBJ.PROCESOS op
             ON ip.PROCESO = op.CLAVE AND ip.MEGA_PROCESO = imp.CLAVE
           INNER JOIN
           wf_obj.tareas ot
             ON ot.PROCESO = op.CLAVE
           INNER JOIN
           wf_obj.roles_tareas rt
             ON ot.proceso = op.CLAVE AND
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
                u.usuario = 'AREVECO'
         UNION
         SELECT
           1
         FROM
           WF_INST.PROCESOS ip
           INNER JOIN
           WF_OBJ.PROCESOS op
             ON ip.PROCESO = op.CLAVE AND ip.MEGA_PROCESO = imp.CLAVE
           INNER JOIN
           wf_obj.tareas ot
             ON ot.PROCESO = op.CLAVE
           INNER JOIN
           wf_obj.tareas_checks tc
             ON ot.proceso = ip.proceso AND
                ot.clave = tc.tarea
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
                u.usuario = 'AREVECO')
ORDER BY imp.CLAVE
WITH UR;