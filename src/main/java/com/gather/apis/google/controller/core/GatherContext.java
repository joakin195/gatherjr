package com.gather.apis.google.controller.core;

import java.io.IOException;
import javax.enterprise.context.SessionScoped;
import javax.inject.Named;
import java.io.Serializable;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;


@Named
@SessionScoped
public class GatherContext implements Serializable {
    private Object session;
    private String userName;

    public Object getSession() {
        return session;
    }

    public void setSession(Object session) {
        this.session = session;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }
    
    public void reportarError(String error){
    
    
    }
    
    public void checkSession(){
        if(session == null){
            ExternalContext context = FacesContext.getCurrentInstance().getExternalContext();
            try {
                context.redirect(context.getRequestContextPath()+"/sesionExpirada.xhtml");
                        
            } catch (IOException ex) {
                Logger.getLogger(GatherContext.class.getName()).log(Level.SEVERE, null, ex);
            }
        }

    }

    @Override
    public String toString() {
        return new StringBuilder().append("GatherContext{").append("session=").append(session).append(", userName='").append(userName).append('\'').append('}').toString();
    }
}
