/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.gather.apis.google.testapis;

import com.gather.apis.google.apis.authGoogle;
import com.gather.apis.google.apis.gmail;
import com.google.api.services.gmail.model.Message;
import java.io.File;
import java.io.IOException;
import java.io.Serializable;
import java.util.logging.Level;
import javax.faces.application.FacesMessage;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.inject.Named;
import javax.mail.internet.MimeMessage;
import org.omnifaces.cdi.ViewScoped;

/**
 *
 * @author MacJoaquin
 */
@Named
@ViewScoped
public class gmailTest implements Serializable{
    
    private String to, subject, body;
    private File archivo;
    private authGoogle gd = new authGoogle();
    private gmail clGmail = new gmail();
    
    public ExternalContext ex() {
        ExternalContext contex = FacesContext.getCurrentInstance().getExternalContext();
        return contex;
    }
    
    public String getTo() {
        return to;
    }

    public void setTo(String to) {
        this.to = to;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getBody() {
        return body;
    }

    public void setBody(String body) {
        this.body = body;
    }

    public File getArchivo() {
        return archivo;
    }

    public void setArchivo(File archivo) {
        this.archivo = archivo;
    }
    
    
    
    public void gmail() throws IOException {
        ExternalContext contex = ex();
        contex.redirect(contex.getRequestContextPath() + "/app/gmail/index.xhtml");
        //System.out.println("Error metodo ListadoDrive() clase testDrive.java: " + e);
    }
    
     public Message enviar() {
        try {
            //System.out.println(archivo.getPath());
            //System.out.println(archivo.getName());
            MimeMessage mimemsj = clGmail.createEmail(to, body, subject);
            Message message = clGmail.createMessageWithEmail(mimemsj);
            message = gd.servicioGmail().users().messages().send(gd.getSmail(), message).execute();
            FacesContext context = FacesContext.getCurrentInstance();
            context.addMessage(null, new FacesMessage("Excelente Tu Correo ha sido enviado" + message.getId()));
            return message;
        } catch (Exception e) {
            java.util.logging.Logger.getLogger(authGoogle.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;

    }
    
}
