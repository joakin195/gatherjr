/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.gather.apis.google.apis;

import com.google.api.client.repackaged.org.apache.commons.codec.binary.Base64;
import com.google.api.services.gmail.model.Message;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.Serializable;
import java.util.Properties;
import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.activation.FileDataSource;
import javax.inject.Named;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.Session;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import org.omnifaces.cdi.ViewScoped;
import org.primefaces.model.UploadedFile;

/**
 *
 * @author MacJoaquin
 */
@Named
@ViewScoped
public class gmail implements Serializable {

    private authGoogle authGoogle = new authGoogle();
    private MimeMessage mimemsj;

    public gmail() {
    }

    public MimeMessage getTexto() {
        return mimemsj;
    }

    public void setTexto(MimeMessage mimemsj) {
        this.mimemsj = mimemsj;
    }

    //Generando Mail API GMAIL
    public MimeMessage createEmail(String para, String cuerpo, String asunto)
            throws MessagingException {
        Properties props = new Properties();
        Session session = Session.getDefaultInstance(props, null);
        mimemsj = new MimeMessage(session);
        mimemsj.setFrom(new InternetAddress(authGoogle.getSmail()));
        mimemsj.addRecipient(javax.mail.Message.RecipientType.TO,
                new InternetAddress(para));
        mimemsj.setSubject(asunto);
        mimemsj.setText(cuerpo);
        return mimemsj;
    }

    //crear mail con la api de gmail con archivo adjunto
    public MimeMessage createEmailWithAttachment(String para,
            String asunto,
            String cuerpo,
            File file)
            throws MessagingException, IOException {
        System.out.println("files: "+file);
        Properties props = new Properties();
        Session session = Session.getDefaultInstance(props, null);
        mimemsj = new MimeMessage(session);
        mimemsj.setFrom(new InternetAddress(authGoogle.getSmail()));
        mimemsj.addRecipient(javax.mail.Message.RecipientType.TO,
                new InternetAddress(para));
        mimemsj.setSubject(asunto);

        MimeBodyPart adjunto = new MimeBodyPart();
        adjunto.setContent(cuerpo, "text/plain");
        adjunto = new MimeBodyPart();
        adjunto.setDataHandler(new DataHandler(new FileDataSource(file)));
        System.out.println("Adjutno: "+adjunto);
        System.out.println("nombre archivo: " + file.getName());
        adjunto.setFileName(file.getName());
        Multipart multipart = new MimeMultipart();
        multipart.addBodyPart(adjunto);
        mimemsj.setContent(multipart);

        return mimemsj;
    }

    //creando mensaje con el mail
    public Message createMessageWithEmail(MimeMessage mime)
            throws MessagingException, IOException {

        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        mime.writeTo(buffer);
        byte[] bytes = buffer.toByteArray();
        String encodedEmail = Base64.encodeBase64URLSafeString(bytes);
        Message message = new Message();
        message.setRaw(encodedEmail);
        return message;
    }

}
