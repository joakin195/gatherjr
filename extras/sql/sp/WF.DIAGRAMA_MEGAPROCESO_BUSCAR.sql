CREATE OR REPLACE PROCEDURE WF.DIAGRAMA_MEGAPROCESO_BUSCAR(x_sesion BIGINT, x_mega_proceso_inst_cl BIGINT)
  SPECIFIC WF.DIAGRAMA_MEGAPROCESO_BUSCAR
DYNAMIC RESULT SETS 2
  P1: BEGIN
  DECLARE x_usuario BIGINT;
  DECLARE x_megaproceso_obj_cl BIGINT;

  DECLARE cursor1 CURSOR WITH RETURN FOR
    with activos(proceso,fecha_termino) AS
   (SELECT p.PROCESO,
           p.F_TERMINO
      FROM wf_inst.PROCESOS p
      WHERE p.MEGA_PROCESO = x_mega_proceso_inst_cl
    WITH UR)

  SELECT
    dn.CLAVE,
    dn.PROCESO_CL,
    dn.TAREA_CL,
    dn.LABEL,
    dn.POSICION_X,
    dn.POSICION_Y,
    CASE WHEN a.proceso is not null
         THEN CASE WHEN a.fecha_termino is not null
                   THEN 'ui-diagram-ended'
                   ELSE 'ui-diagram-selected' END
         ELSE dn.CSS_CLASS END
  FROM WF_OBJ.PROCESOS p,
       WF_OBJ.DIAGRAMA_NODOS dn LEFT JOIN activos a ON dn.PROCESO_CL = a.proceso
  WHERE p.MEGA_PROCESO = x_megaproceso_obj_cl AND
        dn.PROCESO_CL = p.CLAVE AND
        dn.TAREA_CL IS NULL
  ORDER BY dn.PROCESO_CL, dn.TAREA_CL
  WITH UR;

  DECLARE cursor2 CURSOR WITH RETURN FOR
    SELECT
      dc.clave,
      dc.label,
      dc.NODO_ORIGEN_CL,
      dc.POSICION_ANCLAJE_ORIGEN,
      dc.NODO_DESTINO_CL,
      dc.POSICION_ANCLAJE_DESTINO,
      dc.CSS_CLASS
    FROM
      WF_OBJ.DIAGRAMA_CONECCION dc,
      WF_OBJ.DIAGRAMA_NODOS dn,
      WF_OBJ.PROCESOS p
    WHERE
      p.MEGA_PROCESO = x_megaproceso_obj_cl AND
      dn.PROCESO_CL = p.CLAVE AND
      dn.TAREA_CL IS NULL AND
      dn.CLAVE = dc.NODO_ORIGEN_CL
    ORDER BY dc.NODO_ORIGEN_CL
    WITH UR;

  SET x_megaproceso_obj_cl = (SELECT
                                mp.MEGA_PROCESO
                              FROM
                                wf_inst.MEGA_PROCESOS mp
                              WHERE
                                mp.clave = x_mega_proceso_inst_cl
                              FETCH FIRST ROW ONLY
                              WITH UR);

  CALL admin.LEER_PARAM_int(x_sesion, 1, x_usuario);

  OPEN cursor1;
  OPEN cursor2;
END P1

