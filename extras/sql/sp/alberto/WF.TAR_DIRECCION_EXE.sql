CREATE OR REPLACE PROCEDURE WF.TAR_DIRECCION_EXE(x_sesion bigint,
                                                 x_proc_inst bigint, 
                                                 x_objetivo integer, 
                                                 x_tar_sgte bigint, 
                                                 x_resp bigint)
specific WF.TAR_DIRECCION_EXE
DYNAMIC RESULT SETS 1
-- COMENTARIOS ||
-- Dado que se valide previamente si por datos (Checklist y formulario) se pueda avanzar a la siguiente tarea.
-- Este SP genera la proxima tarea al proceso y avanza hacia ella.
-- x_objetivo: 1=Avanzar, -1=Retroceder, 0=Reasignar, 10=Autoasignar
-- Avanzar: x_tar_sgte se usa, pero si es nulo avanza a la que pueda
--          x_resp, si existe se usa, pero si es nulo, se queda con el mismo usuario (si puede) o 
--                  default de la siguiente
-- Retroceder: x_tar_sgte no se usa, vuelve a la que sea anterior con el mismo usuario anterior
-- Reasignar: x_tar_sgte no se usa, se queda en la misma
--            x_resp, se usa obligatorio, si no está no funciona
-- Autoasignar: x_tar_sgte no se usa, se queda en la misma
--              x_resp, es el mismo usuario conectado
-- Los unicos errores que controla son respecto a los parametros enviados y las direcciones(objetos) validos.
-- Retorna error si hay infactibilidad o error de parametros.
P1: BEGIN
declare x_usu, x_usu_prox, x_usu_admin varchar(30);
declare x_mail_admin varchar(200);
declare x_celulares varchar(2000);
declare x_sms varchar(140);
declare x_email_sender, x_email_destino, x_link varchar(100) default null;
declare x_email_asunto, x_megaproceso_desc varchar(250) default null;
declare x_email_cuerpo, x_email_cc varchar(500);
declare x_titulo varchar(60);
declare x_tarea_prox, x_tar, x_tar_inst, x_resp_prox, x_usuario,
        x_tar_inst_ant, x_tar_ant, x_tar_inst_prox, x_mega_proc, x_mega_proc_inst, x_nuevo_proc bigint;
declare x_error, x_tar_fin integer default 0;
declare x_msg varchar(100) default 'Tarea Generada con Éxito';
DECLARE cursor1 CURSOR WITH RETURN FOR
  SELECT x_error, x_msg, x_proc_inst,
         x_email_sender, x_email_destino, x_email_asunto, x_email_cuerpo,
         x_celulares, x_sms, x_tar_ant, x_tar_sgte--   (si están nulos o blancos no se manda
    FROM table(values(1)) as x;
call admin.leer_param_int(x_sesion, 1, x_usuario);
call admin.leer_param_str(x_sesion, 1, x_usu);
set x_msg=case x_objetivo when 1 then 'Avance de Tarea Exitoso'
                          when -1 then 'Retroceso de Tarea Exitoso'
                          when 0 then 'Reasignación Existosa'
                          when 10 then 'Autoasignación Exitosa'
                          end;
set x_tar_fin=coalesce((select 1
                          from wf_obj.tareas t
                          where t.clave=x_tar_sgte and t.tipo=2), 0);
if not exists(select 1
                from WF_INST.procesos p
                where p.clave=x_proc_inst) then
  set x_error=1;
  set x_msg='No existe el Proceso, tarea no se puede generar';
elseif x_tar_sgte is not null and
       not exists(select 1
                    from WF_OBJ.tareas t
                    where t.clave=x_tar_sgte) then
  set x_error=1;
  set x_msg='No existe la nueva Tarea, no se puede generar';
elseif exists(select 1
                from WF_OBJ.tareas t
                where t.clave=x_tar_sgte and t.estado=0) then
  set x_error=1;
  set x_msg='Tarea Seleccionada está Inactiva, no se puede generar';
elseif x_objetivo not in (-1, 0, 1, 10) then
  set x_error=1;
  set x_msg='No existe la dirección de movimiento de tareas, no se puede generar';
elseif x_objetivo in (0) and x_resp is null then
  set x_error=1;
  set x_msg='Al reasignar una Tarea, el Usuario es Obligatorio';
elseif x_objetivo in (0) and 
       not exists(select 1
                    from admin.usuarios u
                    where u.clave=x_resp) then
  set x_error=1;
  set x_msg='Usuario Informado para una Reasignación no Existe';
elseif x_objetivo in (1) and x_resp is not null and
       not exists(select 1
                    from admin.usuarios u
                    where u.clave=x_resp) then
  set x_error=1;
  set x_msg='Usuario Informado para Avanzar a la Siguiente Tarea no Existe';
else
  select p.mega_proceso, m.mega_proceso
    into x_mega_proc_inst, x_mega_proc
    from wf_inst.procesos p, wf_inst.mega_procesos m
    where p.clave=x_proc_inst and p.mega_proceso=m.clave;
  set x_tar_inst=WF.Tarea_Activa(x_sesion, x_proc_inst);
  set x_tar=(select t.tarea
               from wf_inst.tareas t
               where t.clave=x_tar_inst);
  set x_tar_inst_ant=wf.tarea_anterior_retroseso(x_sesion, x_tar_inst);-- tarea anterior para retroceder
  set x_tar_ant=(select t.tarea from wf_inst.tareas t where t.clave=x_tar_inst_ant);
  -- tarea siguiente
  if x_objetivo=1 then
    set x_tarea_prox=coalesce(x_tar_sgte,-- la indicada
                              (select d.tarea_destino
                                 from wf_obj.direcciones d
                                 where d.tarea_origen=x_tar
                                 order by d.orden
                                 fetch first 1 rows only)); -- alguna de las indicadas en direcciones
  elseif x_objetivo=-1 then -- siempre retrocede a la anterior
    set x_tarea_prox=x_tar_ant;
  elseif x_objetivo=0 then
    set x_tarea_prox=x_tar; -- se queda en la misma
  elseif x_objetivo=10 then
    set x_tarea_prox=x_tar; -- se queda en la misma
  end if;
  -- Responsable
  if x_objetivo=1 then --si existe se usa, pero si es nulo, se queda con el mismo usuario (si puede) o 
                          -- default de la siguiente
    set x_resp_prox=coalesce(x_resp,-- la indicada
                      coalesce((select u.clave -- el propio actual
                                 from wf_obj.tareas to
                                      inner join wf_obj.roles_tareas rt on rt.tarea=to.clave
                                      inner join wf_obj.roles r on r.clave=rt.rol
                                      inner join wf_obj.roles_usu ru on ru.rol=r.clave and ru.responsable=1
                                      inner join admin.usuarios u on u.usuario=ru.usuario and u.clave=x_usuario
                                 where to.clave=x_tarea_prox
                                 fetch first 1 rows only),
                               (select u.clave -- el default de los roles con acceso a la tarea
                                  from wf_obj.tareas to
                                       inner join wf_obj.roles_tareas rt on rt.tarea=to.clave
                                       inner join wf_obj.roles r on r.clave=rt.rol
                                       inner join wf_obj.roles_usu ru on ru.rol=r.clave and ru.responsable=1 and 
                                                                         ru.default=1
                                       inner join admin.usuarios u on u.usuario=ru.usuario
                                  where to.clave=x_tarea_prox
                                  fetch first 1 rows only)));
    if x_resp_prox is null and
      exists(select 1 from wf_obj.tareas t where t.clave=x_tar_sgte and t.tipo=2) then
      set x_resp_prox=x_usuario; -- caso de tarea de finalización sin responsable por rol
    end if;
  elseif x_objetivo=-1 then -- usuario responsable anterior
    set x_resp_prox=(select u.clave
                        from wf_inst.tareas t, admin.usuarios u
                        where t.clave=x_tar_inst_ant and t.usu_responsable=u.usuario);
  elseif x_objetivo=0 then --x_resp, se usa obligatorio, si no está no funciona
    set x_resp_prox=x_resp; 
  elseif x_objetivo=10 then --es el mismo usuario conectado
    set x_resp_prox=x_usuario; 
  end if;
  set x_usu_prox=(select u.usuario from admin.usuarios u where u.clave=x_resp_prox);
  if x_tarea_prox is null then
    set x_error=1;
    set x_msg='No se puede determinar la tarea siguiente';
  elseif x_resp_prox is null then
    set x_error=1;
    set x_msg='No se puede determinar el responsable siguiente';
  else
    INSERT INTO WF_INST.TAREAS(TAREA, PROCESO, TAREA_ANTERIOR, F_CREACION, 
                               USU_CREADOR, USU_RESPONSABLE, T_DELAY_HER, 
                               F_REFERENCIA, MOTIVO_DESTINO, DESC_MOTIVO)
      VALUES (x_tarea_prox, x_proc_inst, x_tar_inst, current timestamp, 
             x_usu, x_usu_prox, 0, 
             null, null, '');
    values identity_val_local
      into x_tar_inst_prox;
    insert into wf_inst.procesos_modif(mega_proceso, proceso, usuario, fecha, descripcion) 
      values(x_mega_proc_inst, x_proc_inst, x_usu, current timestamp, 'Nueva TAREA');       
    if exists(select 1
                from WF_OBJ.tareas t
                where t.clave=x_tarea_prox and t.tipo=2) then -- si la tarea siguiente es de finalizacion
      update WF_INST.tareas t
        set t.f_termino=current timestamp, t_final_tarea=0
        where t.clave=x_tar_inst_prox;
      update WF_INST.procesos p
        set p.f_termino=current timestamp,
            p.t_final_proc=integer(days(current date)-days(p.f_creacion))-
                                     coalesce((select sum(integer(case when t.f_termino is null then days(current date) else days(t.f_termino) end-days(t.f_creacion)))
                                                 from WF_INST.tareas t, WF_OBJ.tareas ot
                                                 where t.proceso=p.clave and t.tarea=ot.clave and ot.congelacion=1), 0)
        where p.clave=x_proc_inst;
    end if;
    update WF_INST.tareas t
      set t.tarea_siguiente=x_tar_inst_prox,
          t.f_termino=current timestamp,
          t.t_final_tarea=integer(days(current date) - days(t.f_creacion))+coalesce(t.t_delay_her, 0)
      where t.clave=x_tar_inst;
    update wf_inst.procesos p
      set (p.usu_mod, p.f_mod)=(x_usu, current timestamp)
      where p.clave=x_proc_inst;
    set x_titulo=(select mp.nombre 
                    from wf_inst.mega_procesos mp
                    where mp.clave=x_mega_proc_inst);
    -- ckecks clavados,
    call wf.check_clavados_upd(x_sesion, x_tar_inst, x_tar_inst_prox);
    -- Fin Checks Clavados
    for loop_pr as ciclo_pr cursor with hold
      for select dp.proceso proceso, dp.caso_especial
            from wf_obj.direcciones d, wf_obj.direcciones_procesos dp
            where d.tarea_origen=x_tar and d.tarea_destino=x_tarea_prox and
                  dp.direccion=d.clave and dp.estado=1 and dp.delta_dias=0 do
      if loop_pr.caso_especial is null then
        call WF.Crear_Proceso(x_sesion, 
                              x_mega_proc_inst, 
                              loop_pr.proceso, 
                              null, 
                              x_titulo,
                              x_nuevo_proc);
      elseif loop_pr.caso_especial=1 and
             exists(select 1 -- combo 6 debe estar marcado y decir SI
                      from wf_inst.checklist ch
                      where ch.mega_proceso=x_mega_proc_inst and
                            ch.check=6 and ch.marcado=1 and ch.combo_ref=1) then 
        call WF.Crear_Proceso(x_sesion, 
                              x_mega_proc_inst, 
                              loop_pr.proceso, 
                              null, 
                              x_titulo,
                              x_nuevo_proc);
      end if; 
    end for;
    if x_objetivo in (-1, 1)  then -- cuando no es una reasignación
      set x_link='http://app.gather.cl/wf?id=' || trim(char(x_proc_inst));
      set x_megaproceso_desc = (SELECT mp.DESCRIPCION
                                  FROM wf_obj.MEGA_PROCESOS mp
                                  WHERE mp.clave = x_mega_proc);
      set x_sms='El proceso con folio '||x_proc_inst||' ha cambiado de tarea.'|| x_link;
      set x_celulares='+56962475700; +56998242199';
                      --coalesce((select listagg(pro.usuario, ';') within group(order by pro.usuario)
                      --            from table(select u.celular
                      --                         from wf_obj.mega_procesos mp  
                      --                              inner join wf_obj.roles_mega_proc rp on mp.clave=x_mega_proc and 
                      --                                                                      rp.mega_proceso=mp.clave and rp.estado=1
                      --                              inner join wf_obj.roles r on r.clave=rp.rol and r.estado=1
                      --                              inner join wf_obj.roles_usu ru on ru.rol=r.clave and ru.estado=1
                      --                              inner join admin.usuarios u on ru.usuario=u.usuario and u.estado=1
                      --                       union
                      --                       select u.celular
                      --                         from wf_obj.tareas t 
                      --                              inner join wf_obj.roles_tareas rt on t.clave=x_tar_sgte and 
                      --                                                                   rt.tarea=t.clave and rt.estado=1
                      --                              inner join wf_obj.roles r on r.clave=rt.rol and r.estado=1
                      --                              inner join wf_obj.roles_usu ru on ru.rol=r.clave and ru.estado=1
                      --                              inner join admin.usuarios u on ru.usuario=u.usuario and u.estado=1
                      --                       union
                      --                       select u.celular
                      --                         from wf_obj.tareas t 
                      --                              inner join wf_obj.tareas_checks tc on t.clave=x_tar_sgte and 
                      --                                                                    t.clave=tc.tarea
                      --                              inner join wf_obj.checks och on och.clave=tc.check and och.estado=1
                      --                              inner join wf_obj.roles_check rc on rc.check_tarea=tc.clave and 
                      --                                                                  rc.estado=1
                      --                              inner join wf_obj.roles r on r.clave=rc.rol and r.estado=1
                      --                              inner join wf_obj.roles_usu ru on ru.rol=r.clave and ru.estado=1
                      --                              inner join admin.usuarios u on ru.usuario=u.usuario and u.estado=1) 
                      --                               as pro(usuario)
                      --                            --group by pro.usuario
                      --                            ), '');
      
      set x_mail_admin=''; --'paola.carrasco.b@gmail.com';--'paola.carrasco@GATHER.cl'  
      set x_usu_admin=''; --'SOPORTE';
      set x_email_sender=''; --case x_proc when 1 then 'MesaAyudaFFMM@BCI.CL'
                                         --                   else '' end;
      set x_email_destino='rtroyh@gather.cl;natalia.urrutia@gather.cl';--case x_tar_sgte when 30 then
                                         --                                         case when x_resp1=9 -- SOPORTE
                                         --                                                    then x_mail_admin 
                                         --                                         else (select case u.usuario when 'JUAN' then 'jquinonc@gather.cl'
                                         --                                                                                    when 'RODRIGO' then 'rtroyh@gather.cl'
                                         --                                                                                    when 'DB2ADMIN' then 'acastro@gather.cl'
                                         --                                                                                    when 'SOPORTE' then x_mail_admin
                                         --                                                                                    else trim(u.usuario)||'@BCI.CL' end
                                         --                                                     from admin.usuarios u
                                         --                                                     where u.clave=x_resp1) end
                                         --                         when 40 then
                                         --                                         case when x_resp1=9 -- SOPORTE
                                         --                                                    then x_mail_admin 
                                         --                                         else (select case u.usuario when 'JUAN' then 'jquinonc@gather.cl'
                                         --                                                                                    when 'RODRIGO' then 'rtroyh@gather.cl'
                                         --                                                                                    when 'DB2ADMIN' then 'acastro@gather.cl'
                                         --                                                                                    when 'SOPORTE' then x_mail_admin
                                         --                                                                                    else trim(u.usuario)||'@BCI.CL' end
                                         --                                                     from admin.usuarios u
                                         --                                                     where u.clave=x_resp1) end
                                         --                         when 50 then x_mail_admin
                                         --                        else ''
                                         --       end;
      set x_email_cc=''; --coalesce((select listagg(case u.supervisor when 'JUAN' then 'jquinonc@gather.cl'
                                  --                                                                  when 'RODRIGO' then 'rtroyh@gather.cl'
                                  --                                                                  when 'DB2ADMIN' then 'acastro@gather.cl'
                                  --                                                                  when 'SOPORTE' then x_mail_admin
                                  --                                                                  else u.supervisor||'@bci.cl'  end, ';' )
                                  --                           within group (order by u.supervisor) 
                                  --                  from wf_obj.procesos_usuarios u
                                  --                  where usuario=x_usu and u.proceso=1 and email=1 and
                                  --                             estado=1 and tipo=1 and x_tar_sgte in (30, 50)), '');
      set x_email_cc='';--x_email_cc||
                                 --coalesce((select ';'||case u.usuario when 'JUAN' then 'jquinonc@gather.cl'
                                 --                                                      when 'RODRIGO' then 'rtroyh@gather.cl'
                                 --                                                      when 'DB2ADMIN' then 'acastro@gather.cl'
                                 --                                                      when 'SOPORTE' then x_mail_admin
                                 --                                                      else u.usuario||'@bci.cl'  end 
                                 --                   from wf_obj.procesos_usuarios u
                                 --                   where usuario=x_usu and u.proceso=1 and email=1 and
                                 --                              estado=1 and tipo=1 and x_tar_sgte in (30, 50)
                                 --                   fetch first 1 rows only), '');
      set x_email_asunto='Worflow Productos: Proceso avanzó de tarea';
      set x_email_cuerpo='<p>Estimado usuario<p></br></br>Se informa que el proceso '||
                         x_megaproceso_desc||' con nombre "'||x_titulo||
                         '" ha avanzado de tarea. <p>Puedes acceder desde el siguiente <a href="'||x_link||
                         '">link</a>.</p>';
    end if;                  
  end if;
end if;
OPEN cursor1;
END P1