CREATE OR REPLACE PROCEDURE WF.COMPOSICION_PROCESO(x_sesion BIGINT, x_megaproceso_cl BIGINT)
  SPECIFIC WF.COMPOSICION_PROCESO
  --MUESTRA LAS ACTIVIDADES DEL PRIMER PROCESO DE UN MEGRAPROCESO
  --USADO SOLO EN LA PANTALLA DE CREACION DE PROCESO
DYNAMIC RESULT SETS 3
  P1: BEGIN
  DECLARE x_usuario BIGINT;
  DECLARE x_proceso_inicio_cl BIGINT;

  DECLARE cursor1 CURSOR WITH RETURN FOR
    SELECT mp.CLAVE,
           mp.descripcion mega_desc
    FROM WF_OBJ.MEGA_PROCESOS mp
    WHERE mp.CLAVE = x_megaproceso_cl
    WITH UR;

  DECLARE cursor2 CURSOR WITH RETURN FOR
    SELECT
      t.CLAVE         clave_tarea,
      t.descripcion   desc_tarea,
      t.IMAGEN        imagen_tarea,
      t.BENCH_ROJO    tiempo,
      coalesce((SELECT
                  LISTAGG(r.descripcion, ',')
                FROM
                  wf_obj.roles_tareas rt,
                  wf_obj.roles r
                WHERE
                  rt.tarea = t.clave AND rt.estado = 1 AND
                  r.clave = rt.rol AND
                  upper(trim(r.descripcion)) NOT IN ('DEFAULT', 'DEFAULT2')), '') rol
    FROM WF_OBJ.PROCESOS p
      LEFT JOIN WF_OBJ.tareas t ON t.PROCESO = p.CLAVE
    WHERE p.CLAVE = x_proceso_inicio_cl AND
          t.CLAVE IS NOT NULL AND
          upper(trim(t.DESCRIPCION)) NOT IN ('FIN', 'CANCELAR')
    ORDER BY t.CLAVE
    WITH UR;

  DECLARE cursor3 CURSOR WITH RETURN FOR
    SELECT
      t.CLAVE       clave_tarea,
      c.DESCRIPCION check
    FROM WF_OBJ.PROCESOS p
      LEFT JOIN WF_OBJ.tareas t ON t.PROCESO = p.CLAVE
      LEFT JOIN WF_OBJ.TAREAS_CHECKS tc ON t.CLAVE = tc.TAREA
      LEFT JOIN WF_OBJ.CHECKS c ON c.CLAVE = tc.CHECK
    WHERE
      p.CLAVE = x_proceso_inicio_cl AND
      t.CLAVE IS NOT NULL AND
      c.DESCRIPCION IS NOT NULL AND
      tc.DESPLIEGUE = 1 AND
      upper(trim(t.DESCRIPCION)) NOT IN ('FIN', 'CANCELAR')
    ORDER BY tc.CLAVE
    WITH UR;

  SET x_proceso_inicio_cl = (SELECT p.clave
                               FROM wf_obj.procesos p
                               WHERE p.MEGA_PROCESO = x_megaproceso_cl AND
                                     p.INICIO = 1
                               FETCH FIRST ROW ONLY
                               WITH UR);

  CALL admin.LEER_PARAM_int(x_sesion, 1, x_usuario);

  OPEN cursor1;
  OPEN cursor2;
  OPEN cursor3;
END P1

