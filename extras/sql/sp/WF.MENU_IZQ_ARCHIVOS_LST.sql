CREATE OR REPLACE PROCEDURE WF.MENU_IZQ_ARCHIVOS_LST(x_sesion BIGINT)
  SPECIFIC WF.MENU_IZQ_ARCHIVOS_LST
  -- MUESTRA LOS ULTIMO 15 ARCHIVOS SUBIDOS AL SISTEMA QUE SON VISIBLES POR EL USUARIO
  -- USADO EN UNO DE LOS PANELES DEL MENU IZQUIERDO.
DYNAMIC RESULT SETS 1
  P1: BEGIN
  DECLARE x_usuario VARCHAR(30);

  DECLARE cursor1 CURSOR WITH RETURN FOR
    WITH archivos(proceso_inst_cl, clave_archivo, nombre_archivo, desc_archivo,
                  tipo_archivo, fecha_creacion, proceso_inst_nombre, mega_inst_desc) AS (
                  SELECT ip.clave          proceso_inst_cl,
                         ar.clave          clave_archivo,
                         ar.nombre_archivo nombre_archivo,
                         ar.descripcion    desc_archivo,
                         ta.descripcion    tipo_archivo,
                         ar.f_creacion     fecha_creacion,
                         ip.nombre         proceso_inst_nombre,
                         imp.descripcion   mega_inst_desc
                    FROM WF_INST.tareas it
                    INNER JOIN WF_INST.procesos ip ON
                      it.proceso = ip.clave AND
                      it.tarea_siguiente IS NULL
                    INNER JOIN wf_inst.mega_procesos imp ON
                      imp.clave = ip.mega_proceso
                    INNER JOIN wf_inst.archivos ar ON
                      imp.CLAVE = ar.mega_proceso
                    INNER JOIN wf_obj.tipos_archivos ta ON
                      ta.CLAVE = ar.tipo_archivo
                    INNER JOIN wf_obj.tareas to ON
                      to.clave = it.tarea AND to.tipo IN (0, 1)
                    WHERE exists(SELECT 1
                                  FROM wf_obj.roles_mega_proc rp
                                  INNER JOIN wf_obj.roles r ON
                                    rp.mega_proceso = imp.mega_proceso AND
                                    rp.estado = 1 AND
                                    r.clave = rp.rol AND
                                    r.estado = 1
                                  INNER JOIN wf_obj.roles_usu ru ON
                                    ru.rol = r.clave AND ru.estado = 1
                                  INNER JOIN admin.usuarios u ON
                                    ru.usuario = u.usuario AND
                                    u.estado = 1 AND
                                    u.usuario = x_usuario
                                 UNION
                                  SELECT 1
                                    FROM wf_obj.tareas ot
                                    INNER JOIN wf_obj.roles_tareas rt ON
                                      ot.proceso = ip.proceso AND
                                      rt.tarea = ot.clave AND
                                      rt.estado = 1
                                    INNER JOIN wf_obj.roles r ON
                                      r.clave = rt.rol AND
                                      r.estado = 1
                                    INNER JOIN wf_obj.roles_usu ru ON
                                      ru.rol = r.clave AND
                                      ru.estado = 1
                                    INNER JOIN admin.usuarios u ON
                                      ru.usuario = u.usuario AND
                                      u.estado = 1 AND
                                      u.usuario = x_usuario
                                UNION
                                SELECT 1
                                  FROM wf_obj.tareas t
                                  INNER JOIN wf_obj.tareas_checks tc ON
                                    t.proceso = ip.proceso AND
                                    t.clave = tc.tarea
                                  INNER JOIN wf_obj.roles_check rc ON
                                    rc.check_tarea = tc.clave AND
                                    rc.estado = 1
                                  INNER JOIN wf_obj.roles r ON
                                    r.clave = rc.rol AND
                                    r.estado = 1
                                  INNER JOIN wf_obj.roles_usu ru ON
                                    ru.rol = r.clave AND
                                    ru.estado = 1
                    INNER JOIN admin.usuarios u ON
                      ru.usuario = u.usuario AND
                      u.estado = 1 AND
                      u.usuario = x_usuario)
                  ORDER BY ar.f_creacion DESC WITH UR )

  SELECT a1.proceso_inst_cl,
         a1.nombre_archivo,
         a1.desc_archivo,
         a1.tipo_archivo,
         a1.fecha_creacion,
         a1.proceso_inst_nombre,
         a1.mega_inst_desc
    FROM archivos a1 LEFT JOIN
         archivos a2 ON
          a1.clave_archivo = a2.clave_archivo AND
          a1.proceso_inst_cl < a2.proceso_inst_cl
    WHERE a2.clave_archivo IS NULL
    FETCH FIRST 15 ROWS ONLY
    WITH UR;

  CALL admin.LEER_PARAM_str(x_sesion, 1, x_usuario);

  OPEN cursor1;
END P1

