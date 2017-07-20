/*
CREATE TABLE ADMIN.TOKEN_PSW (
  CLAVE    BIGINT PRIMARY KEY NOT NULL         GENERATED ALWAYS AS IDENTITY ( START WITH 1 INCREMENT BY 1),
  token    VARCHAR(20)        NOT NULL,
  usuario  BIGINT             NOT NULL,
  usada    INT DEFAULT 0      NOT NULL,
  CREACION TIMESTAMP          NOT NULL         WITH DEFAULT CURRENT TIMESTAMP,
  MOD      TIMESTAMP          NOT NULL         GENERATED ALWAYS FOR EACH ROW ON UPDATE AS ROW CHANGE TIMESTAMP,
  FOREIGN KEY (usuario) REFERENCES admin.USUARIOS (clave)
);
*/

DROP TABLE wf_obj.DIAGRAMA_NODOS;
DROP TABLE wf_obj.DIAGRAMA_CONECTOR;
DROP TABLE wf_obj.DIAGRAMA_NODO_ANCLAJE;

CREATE TABLE WF_OBJ.DIAGRAMA_NODOS (
  clave      BIGINT PRIMARY KEY NOT NULL         GENERATED ALWAYS AS IDENTITY ( START WITH 1 INCREMENT BY 1),
  proceso_cl BIGINT             NOT NULL,
  tarea_cl   BIGINT,
  label      VARCHAR(50)        NOT NULL,
  posicion_x DOUBLE             NOT NULL,
  posicion_y DOUBLE             NOT NULL,
  css_class  VARCHAR(50),
  FOREIGN KEY (proceso_cl) REFERENCES WF_OBJ.PROCESOS (clave),
  FOREIGN KEY (tarea_cl) REFERENCES WF_OBJ.TAREAS (clave)
);


CREATE TABLE WF_OBJ.DIAGRAMA_NODO_ANCLAJE (
  clave    BIGINT PRIMARY KEY NOT NULL         GENERATED ALWAYS AS IDENTITY ( START WITH 1 INCREMENT BY 1),
  nodo_cl  BIGINT             NOT NULL,
  posicion INTEGER            NOT NULL,
  FOREIGN KEY (nodo_cl) REFERENCES WF_OBJ.DIAGRAMA_NODOS (clave)
);


CREATE TABLE WF_OBJ.DIAGRAMA_CONECTOR (
  clave              BIGINT PRIMARY KEY NOT NULL         GENERATED ALWAYS AS IDENTITY ( START WITH 1 INCREMENT BY 1),
  label              VARCHAR(50),
  anclaje_origen_cl  INTEGER            NOT NULL,
  anclaje_destino_cl INTEGER            NOT NULL,
  css_class          VARCHAR(50),
  FOREIGN KEY (anclaje_origen_cl) REFERENCES WF_OBJ.DIAGRAMA_NODO_ANCLAJE (clave),
  FOREIGN KEY (anclaje_destino_cl) REFERENCES WF_OBJ.DIAGRAMA_NODO_ANCLAJE (clave)
);


CREATE TABLE WF_OBJ.DIAGRAMA_CONECCION (
  clave                    BIGINT PRIMARY KEY NOT NULL         GENERATED ALWAYS AS IDENTITY ( START WITH 1 INCREMENT BY 1),
  label                    VARCHAR(50),
  nodo_origen_cl           INTEGER            NOT NULL,
  posicion_anclaje_origen  INTEGER            NOT NULL,
  nodo_destino_cl          INTEGER            NOT NULL,
  posicion_anclaje_destino INTEGER            NOT NULL,
  css_class                VARCHAR(50),
  FOREIGN KEY (nodo_origen_cl) REFERENCES WF_OBJ.DIAGRAMA_NODOS (clave),
  FOREIGN KEY (nodo_destino_cl) REFERENCES WF_OBJ.DIAGRAMA_NODOS (clave)
);


