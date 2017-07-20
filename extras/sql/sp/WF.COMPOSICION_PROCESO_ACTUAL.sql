CREATE OR REPLACE PROCEDURE WF.COMPOSICION_PROCESO_ACTUAL(x_sesion BIGINT, x_proceso_obj_cl BIGINT)
  SPECIFIC WF.COMPOSICION_PROCESO_ACTUAL
  --MUESTRA LAS ACTIVIDADES DEL PROCESO INDICADO
  --USADO EN LA PANTALLA DE EDICION DE PROCESO
DYNAMIC RESULT SETS 3
  P1: BEGIN
  DECLARE x_usuario BIGINT;

  DECLARE cursor1 CURSOR WITH RETURN FOR
    SELECT p.descripcion proceso_desc
      FROM WF_OBJ.PROCESOS p
      WHERE p.CLAVE = x_proceso_obj_cl
      WITH UR;

  DECLARE cursor2 CURSOR WITH RETURN FOR
    SELECT t.CLAVE         tarea_cl,
           t.descripcion   tarea_desc,
           t.IMAGEN        tarea_imagen,
           t.BENCH_ROJO    tarea_tiempo,
      coalesce((SELECT LISTAGG(r.descripcion, ',')
                  FROM wf_obj.roles_tareas rt,
                       wf_obj.roles r
                WHERE rt.tarea = t.clave AND
                      rt.estado = 1 AND
                      r.clave = rt.rol AND
                      upper(trim(r.descripcion)) NOT IN ('DEFAULT', 'DEFAULT2')), '') rol
      FROM WF_OBJ.PROCESOS p LEFT JOIN WF_OBJ.tareas t ON t.PROCESO = p.CLAVE
      WHERE t.CLAVE IS NOT NULL AND
            p.CLAVE = x_proceso_obj_cl AND
            upper(trim(t.DESCRIPCION)) NOT IN ('FIN', 'CANCELAR')
      ORDER BY t.CLAVE
      WITH UR;

  DECLARE cursor3 CURSOR WITH RETURN FOR
    SELECT t.CLAVE       tarea_cl,
           c.DESCRIPCION check_desc
      FROM WF_OBJ.PROCESOS p LEFT JOIN WF_OBJ.tareas t ON t.PROCESO = p.CLAVE
                             LEFT JOIN WF_OBJ.TAREAS_CHECKS tc ON t.CLAVE = tc.TAREA
                             LEFT JOIN WF_OBJ.CHECKS c ON c.CLAVE = tc.CHECK
      WHERE p.CLAVE = x_proceso_obj_cl AND
            t.CLAVE IS NOT NULL AND
            c.DESCRIPCION IS NOT NULL AND
            tc.DESPLIEGUE = 1 AND
            upper(trim(t.DESCRIPCION)) NOT IN ('FIN', 'CANCELAR')
      ORDER BY t.CLAVE, tc.CLAVE
      WITH UR;

  CALL admin.LEER_PARAM_int(x_sesion, 1, x_usuario);

  OPEN cursor1;
  OPEN cursor2;
  OPEN cursor3;
END P1

