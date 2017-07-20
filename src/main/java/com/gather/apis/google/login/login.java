/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.gather.apis.google.login;

import com.gather.apis.google.controller.core.GatherContext;
import com.gather.apis.google.dao.AuthDao;
import com.gather.gathercommons.domain.User;
import com.gather.gathercommons.util.Validator;
import com.gather.springcommons.services.IResultSetProvider;
import java.io.Serializable;
import java.util.List;
import javax.faces.application.FacesMessage;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.inject.Inject;
import javax.inject.Named;
import javax.servlet.http.HttpSession;
import org.apache.log4j.Logger;
import org.omnifaces.cdi.ViewScoped;

/**
 *
 * @author MacJoaquin
 */
@ViewScoped
@Named
public class login implements Serializable {

    @Inject
    private transient Logger log;

    @Inject
    private GatherContext context;

    @Inject
    private AuthDao service;

    private User usuario;

    public FacesContext fc() {
        FacesContext contex = FacesContext.getCurrentInstance();
        return contex;
    }

    public ExternalContext ex() {
        ExternalContext contex = FacesContext.getCurrentInstance().getExternalContext();
        return contex;
    }

    public User getUsuario() {
        if (this.usuario == null) {
            this.usuario = new User();
        }

        return this.usuario;
    }

    public void setUsuario(User usuario) {
        this.usuario = usuario;
    }

    private boolean authenticate() throws
            Exception {
        return this.service.authenticate(this.getUsuario().getName(),
                this.getUsuario().getPassword());
    }

    public String login() {
        log.info("INICIO AUTENTIFICACION USUARIO");

        String[] usuarios = this.getUsuario().getName().split("-");
        String usuarioTest = null;
        if (usuarios.length > 1) {
            this.getUsuario().setName(usuarios[0]);
            usuarioTest = usuarios[1];
        }
        try {
            if (authenticate()) {
                if (this.getUsuario().getName().equalsIgnoreCase("db2Admin") && usuarioTest != null) {
                    this.getUsuario().setName(usuarioTest);
                }

                IResultSetProvider rp = this.service.sesionService(this.getUsuario().getName());

                if (rp != null) {
                    this.context.setUserName(this.getUsuario().getName());

                    final List<List<Object>> rsListofList = rp.getResultSetasListofList();
                    if (Validator.validateList(rsListofList) && Validator.validateList(rsListofList.get(0))) {

                        if (this.context.getSession() == null) {

                            if (rsListofList.get(0).get(0).toString().compareTo("0") == 0) {
                                String message = "NO TIENE ACCESO A LA APLICACIÓN.";

                                FacesContext.getCurrentInstance().addMessage(null,
                                        new FacesMessage(FacesMessage.SEVERITY_WARN,
                                                message,
                                                message));
                                return "";
                            }

                            this.context.setSession(rsListofList.get(0).get(0));
                        }
                    }
                }

                log.info("REDIRECCIONANDO A HOME");
                ExternalContext contex = ex();
                contex.redirect(contex.getRequestContextPath() + "/app/apis/index.xhtml");
                /*
                if (menu.getPaginaInicial() != null) {
                    return menu.getPaginaInicial();
                } else {
                    String message = "NO TIENE ACCESO A LA APLICACIÓN.";

                    FacesContext.getCurrentInstance().addMessage(null,
                            new FacesMessage(FacesMessage.SEVERITY_ERROR,
                                    message,
                                    message));
                    return "";
                }*/

            } else {
                String message = "USUARIO Y/O CONTRASEÑA INCORRECTO(S).";

                FacesContext.getCurrentInstance().addMessage(null,
                        new FacesMessage(FacesMessage.SEVERITY_ERROR,
                                message,
                                message));

                log.warn(message);
                return ""; //"login?faces-redirect=true";
            }
        } catch (Exception e) {
            log.info(e.getMessage());
        }

        return "error";
    }

    public String toString() {
        return this.usuario.getName();
    }

    public String logout() {
        log.info("CERRANDO SESION USUARIO");

        try {
            //todo: buscar alternativa
            FacesContext currentInstance = FacesContext.getCurrentInstance();
            ExternalContext externalContext = currentInstance.getExternalContext();
            HttpSession session = (HttpSession) externalContext.getSession(false);

            if (session != null) {
                session.invalidate();
            }

            externalContext.invalidateSession();
        } catch (Exception e) {
            log.error(e.getMessage());
        }

        return "logout";
    }

}
