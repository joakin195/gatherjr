CREATE OR REPLACE PROCEDURE WF.ENVIAR_MAIL_ARCH_LISTA(x_sesion BIGINT, x_proc_inst BIGINT)
  SPECIFIC WF.ENVIAR_MAIL_ARCH_LISTA
DYNAMIC RESULT SETS 1
  P1: BEGIN
  DECLARE x_mega_proceso BIGINT;
  DECLARE cursor1 CURSOR WITH RETURN FOR

    WITH
  archivos(clave, nombre, descripcion, tipo, tipo_descripcion) AS
  ( SELECT
  a.clave, a.nombre_archivo, a.descripcion, ta.CLAVE, ta.descripcion
  FROM WF_INST.archivos a, WF_OBJ.tipos_archivos ta
  WHERE a.mega_proceso = x_mega_proceso AND
  a.tipo_archivo = ta.clave
  ORDER BY a.f_creacion DESC )

  SELECT
    a1.*
  FROM
    archivos a1 LEFT JOIN
    archivos a2
      ON (a1.tipo = a2.tipo AND a1.clave < a2.clave)
  WHERE
    a2.clave IS NULL
  WITH UR;


  SELECT
    ar.MEGA_PROCESO
  INTO x_mega_proceso
  FROM
    WF_INST.PROCESOS ar
  WHERE
    ar.CLAVE = x_proc_inst
  WITH UR;


  OPEN cursor1;
END P1