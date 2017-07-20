/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.gather.apis.google.apis;

import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
import com.google.api.client.googleapis.auth.oauth2.GoogleTokenResponse;
import com.google.api.client.http.HttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.jackson2.JacksonFactory;
import com.google.api.services.drive.Drive;
import com.google.api.services.gmail.Gmail;
import com.google.api.services.oauth2.Oauth2;
import com.google.api.services.oauth2.model.Userinfoplus;
import java.io.IOException;
import java.io.Serializable;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Level;
import javax.faces.application.FacesMessage;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.inject.Inject;
import javax.inject.Named;
import org.apache.log4j.Logger;
import org.omnifaces.cdi.ViewScoped;

/**
 *
 * @author MacJoaquin
 */
@Named
@ViewScoped
public class authGoogle implements Serializable {

    private Oauth2 oauth2;
    private String app = "Apis_Google_Gather";
    private ExternalContext context = FacesContext.getCurrentInstance().getExternalContext();

    private String redireccion = "http://" + context.getRequestServerName() + ":8090/APIS_GOOGLE_AMAZON/autorizacionCodeGoogle.xhtml";
    @Inject
    private transient Logger LOG;
    private static HttpTransport httpTransport;
    private static JsonFactory jsonFactory;
    private static GoogleAuthorizationCodeFlow flow;
    private static Drive drive;
    private static Gmail gmail;

    private static final List<String> SCOPES = Arrays.asList(
            "https://www.googleapis.com/auth/drive",
            "https://www.googleapis.com/auth/userinfo.profile",
            "https://www.googleapis.com/auth/userinfo.email",
            "https://mail.google.com/",
            "https://www.googleapis.com/auth/drive.appdata");

    public authGoogle() {
    }

    public ExternalContext ex() {
        ExternalContext contex = FacesContext.getCurrentInstance().getExternalContext();
        return contex;
    }

    public FacesContext fc() {
        FacesContext contex = FacesContext.getCurrentInstance();
        return contex;
    }

    public void generar() throws IOException {
        getAcceso();
    }

    //Generacion de url para autentificacion Cliente
    public String getAcceso() {
        try {
            LOG.info("GENERANDO ACCESO");
            ExternalContext context = FacesContext.getCurrentInstance().getExternalContext();
            httpTransport = new NetHttpTransport();
            jsonFactory = new JacksonFactory();

            flow = new GoogleAuthorizationCodeFlow.Builder(
                    httpTransport,
                    jsonFactory,
                    "12087956130-lmur6j9ie3gmnjtph5slmk6ou3iefi9p.apps.googleusercontent.com",
                    "YlEO9blHq5PcBO3Vi2XpLKI2",
                    SCOPES)
                    .setAccessType("online")
                    .build();

            LOG.warn("GENERANDO URL");
            String url = flow.newAuthorizationUrl().setRedirectUri(redireccion).build();
            System.out.println(url);
            LOG.info(url);
            context.redirect(url);
            return "OK";
        } catch (Exception e) {
            System.out.println("Error: " + e);
            return "ERROR";
        }

    }

    //Generar Credencial de google para acceder a los Servicios de google
    public void autorizacion(String code) {
        try {
            FacesContext contex = fc();
            GoogleTokenResponse tokenResponse = flow.newTokenRequest(code).setRedirectUri(redireccion).execute();
            String accessToken = tokenResponse.getAccessToken();
            //Token de Acceso
            contex.getExternalContext().getSessionMap().put("tokenAccesoGoogle", accessToken);
            contex.getExternalContext().getSessionMap().put("credencialGoogle", new GoogleCredential().setAccessToken(getStoken()));
            System.out.println("credencial cargada " + credencial());
        } catch (Exception e) {
            System.out.println("Error al cargar Credencial Google: " + e);
        }
    }

    //Guardando credencial
    public GoogleCredential credencial() {
        try {
            GoogleCredential cred = (GoogleCredential) FacesContext.getCurrentInstance().getExternalContext().getSessionMap().get("credencialGoogle");
            return cred;
        } catch (Exception e) {
            System.out.println("Error al guardar la credencial de google metodo credencial()==> " + e);
            return null;
        }

    }

    //Generando autorizacion para servicio API Drive
    public Drive servicioDrive() {
        //LOG.info("GENERANDO SERVICIO DRIVE");
        try {
            drive = new Drive.Builder(
                    httpTransport,
                    jsonFactory,
                    credencial())
                    .setApplicationName(app)
                    .build();
            return drive;
        } catch (Exception e) {
            java.util.logging.Logger.getLogger(authGoogle.class.getName()).log(Level.SEVERE, null, e);
            return null;
        }

    }

    //Generando autorizacion para servicio API Gmail
    public Gmail servicioGmail() {
        try {
            gmail = new Gmail.Builder(
                    httpTransport,
                    jsonFactory,
                    credencial())
                    .setApplicationName(app)
                    .build();
            return gmail;
        } catch (Exception e) {
            java.util.logging.Logger.getLogger(authGoogle.class.getName()).log(Level.SEVERE, null, e);
            return null;
        }
    }

    //Informacion Perfil Usurio Logeado
    public Oauth2 servicioPerfil() {
        //LOG.info("GENERANDO SERVICIOS DE PERFIL");
        try {
            FacesContext contex = fc();
            oauth2 = new Oauth2.Builder(httpTransport,
                    jsonFactory,
                    credencial())
                    .setApplicationName(app)
                    .build();
            Userinfoplus perfil = oauth2.userinfo().get().execute();
            contex.getExternalContext().getSessionMap().put("idUsuarioGoogle", perfil.getId());
            contex.getExternalContext().getSessionMap().put("usuarioGoogle", perfil.getName());
            contex.getExternalContext().getSessionMap().put("mailGoogle", perfil.getEmail());
            contex.getExternalContext().getSessionMap().put("imgGoogle", perfil.getPicture());
            return oauth2;
        } catch (Exception e) {
            java.util.logging.Logger.getLogger(authGoogle.class.getName()).log(Level.SEVERE, null, e);
            return null;
        }
        
    }

    //Metodo para cargar los servicios de google
    public String serviciosGoogle() {
        try {
            if (servicioPerfil() == null || servicioDrive() == null || servicioGmail() == null) {
                ExternalContext contex = ex();
                contex.redirect(contex.getRequestContextPath() + "/sesionExpirada.xhtml");
                return null;
            } else {
                servicioPerfil();
                servicioDrive();
                servicioGmail();
                return "OK";
            }

        } catch (Exception e) {
            System.out.println("Error al cargar los servicios.. " + e);
            return null;
        }
    }

    //Inicio aplicacion
    public void inicio() throws IOException {
        //LOG.info("INICIO CON GOOGLE");
        ExternalContext econ = ex();
        econ.redirect(econ.getRequestContextPath() + "/app/apis/index.xhtml");
    }

    //metodo error por acceder con cuenta no valida
    public void error() throws IOException {
        String message = "NO PUEDES ACCEDER A LA APLICACION CON ESTA CUENTA DE CORREO.(@BCI.CL)";

        FacesContext.getCurrentInstance().addMessage(null,
                new FacesMessage(FacesMessage.SEVERITY_ERROR,
                        message,
                        message));

        LOG.warn(message);

        ExternalContext econ = ex();
        econ.redirect(econ.getRequestContextPath());
    }
    
    public String revokeToken(){
        String salida = "https://accounts.google.com/o/oauth2/revoke?token=" + getStoken();
        return salida;
    }

    //destruir sesiones de google
    public void salir() throws IOException {
        //LOG.info("DESTRUIR TOKEN DE ACCESO");
        ExternalContext econ = ex();
        econ.redirect(econ.getRequestContextPath());
        FacesContext.getCurrentInstance().getExternalContext().invalidateSession();
        System.out.println("haz salido");

    }

    //obtener id cliente google
    public String getSid() {
        String ids = (String) FacesContext.getCurrentInstance().getExternalContext().getSessionMap().get("idGoogle");

        return ids;
    }

    //obtener cliente google
    public String getSuser() {
        String usuarios = (String) FacesContext.getCurrentInstance().getExternalContext().getSessionMap().get("usuarioGoogle");
        return usuarios;
    }

    //obtener mail cliente google
    public String getSmail() {
        String mails = (String) FacesContext.getCurrentInstance().getExternalContext().getSessionMap().get("mailGoogle");
        return mails;
    }

    //obtener url imagen cliente google
    public String getSimg() {
        String ims = (String) FacesContext.getCurrentInstance().getExternalContext().getSessionMap().get("imgGoogle");
        return ims;
    }

    //obtener token de acceso google
    public String getStoken() {
        String tokens = (String) FacesContext.getCurrentInstance().getExternalContext().getSessionMap().get("tokenAccesoGoogle");
        return tokens;
    }

}
