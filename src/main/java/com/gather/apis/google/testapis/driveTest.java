/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.gather.apis.google.testapis;

import com.gather.apis.google.apis.authGoogle;
import com.gather.apis.google.apis.drive;
import com.google.api.client.http.FileContent;
import com.google.api.client.http.GenericUrl;
import com.google.api.client.http.HttpResponse;
import com.google.api.services.drive.model.File;
import com.google.api.services.drive.model.FileList;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.inject.Named;
import org.omnifaces.cdi.ViewScoped;
import org.primefaces.model.UploadedFile;

/**
 *
 * @author MacJoaquin
 */
@Named
@ViewScoped
public class driveTest implements Serializable {

    private authGoogle authGoogle = new authGoogle();
    private drive clDrive = new drive();
    private String auth;
    private List<File> folder;
    private Boolean papelera;
    private String nombreCarpetaDrive;
    private UploadedFile newArchivo;

    public ExternalContext ex() {
        ExternalContext contex = FacesContext.getCurrentInstance().getExternalContext();
        return contex;
    }

    public List<File> getFolder() {
        return folder;
    }

    public void setFolder(List<File> folder) {
        this.folder = folder;
    }

    public Boolean getPapelera() {
        return papelera;
    }

    public void setPapelera(Boolean papelera) {
        this.papelera = papelera;
    }

    public UploadedFile getNewArchivo() {
        return newArchivo;
    }

    public void setNewArchivo(UploadedFile newArchivo) {
        this.newArchivo = newArchivo;
    }

    public String getNombreCarpetaDrive() {
        return nombreCarpetaDrive;
    }

    public void setNombreCarpetaDrive(String nombreCarpetaDrive) {
        this.nombreCarpetaDrive = nombreCarpetaDrive;
    }

    public String getAuth() {
        return auth;
    }

    public void setAuth(String auth) {
        this.auth = auth;
    }

    public void drive() throws IOException {
        ExternalContext contex = ex();
        contex.redirect(contex.getRequestContextPath() + "/app/drive/drive.xhtml");
        //System.out.println("Error metodo ListadoDrive() clase testDrive.java: " + e);
    }

    public void datos() {
        try {
            if (!auth.equals("")) {
                authGoogle.autorizacion(auth.substring(6) + "#");
                authGoogle.servicioPerfil();
                authGoogle.servicioDrive();
                authGoogle.servicioGmail();
                ExternalContext contex = ex();
                contex.redirect(contex.getRequestContextPath() + "/app/autenticar/index.xhtml");

            } else {
                System.out.println("ERROR NULOS");
                ExternalContext contex = ex();
                contex.redirect(contex.getRequestContextPath() + "");
            }

            // Sube un fichero de texto a google drive
            // El archivo document.txt se encuentra en la misma carpeta del proyecto
            // En el primer argumento se pone la ruta al fichero, en la segunda el
            // nombre del fichero en google drive
            //String fileID=gd.uploadTextFile("document.txt","documento.txt");
            //System.out.println("Fichero subido. ID del fichero:"+fileID);
            // Descarga el contenido del fichero de texto anteriormente subido
            //String contenido=gd.downloadTextFile(fileID);
            //System.out.println("Contenido:"+contenido);
            /*System.out.println("Pulse intro para listar los archivos de Google Drive");
		new InputStreamReader(System.in);
             */
        } catch (Exception e) {
            System.out.println("Error: " + e);

        }

    }

    public void carpeta() {
        try {
            clDrive.carpeta(nombreCarpetaDrive);
        } catch (Exception e) {
            System.out.println("Error al crear la carpeta Drive: " + e);
        }
    }

    public void nuevoArchivo() {
        String nombre = newArchivo.getFileName();
            System.out.println(nombre);
        try {
            
            File fileMetadata = new File();
            fileMetadata.setTitle(newArchivo.getFileName());
            java.io.File filePath = new java.io.File("files/"+nombre);
            FileContent mediaContent = new FileContent(newArchivo.getContentType(), filePath);
            File file = authGoogle.servicioDrive().files().insert(fileMetadata, mediaContent)
                    .setFields("id")
                    .execute();
            System.out.println("File ID: " + file.getId());
        } catch (Exception e) {
            System.out.println("Error al crear.." +e);
        }
    }

    public List<File> listadoOtrosArchivos() throws IOException {
        try {
            List<File> result = clDrive.verOtros();
            return result;
        } catch (Exception e) {
            System.out.println("Error metodo archivosDrive() " + e);
            return null;
        }

    }

    public List<File> listadoFilesFolder(String folders) throws IOException {
        try {
            List<File> result = clDrive.verDocsFolder(folders);
            folder = result;
            return result;
        } catch (Exception e) {
            System.out.println("Error metodo listadoFilesFolder() " + e);
            return null;
        }

    }

    public List<File> listadoCarpetas() throws IOException {
        try {
            List<File> result = clDrive.verCarpetas();
            return result;
        } catch (Exception e) {
            System.out.println("Error metodo listadoCarpetas() " + e);
            return null;
        }

    }

    public void ver(String fileId) {
        printFile(fileId);
        try {
            OutputStream outputStream = new ByteArrayOutputStream();
            authGoogle.servicioDrive().files().get(fileId)
                    .executeMediaAndDownloadTo(outputStream);
        } catch (Exception e) {
            System.out.println("Error " + e);
        }

    }

    private void printFile(String fileId) {

        try {
            File file = authGoogle.servicioDrive().files().get(fileId).execute();

            System.out.println("Title: " + file.getTitle());
            System.out.println("Web content Link: " + file.getWebContentLink());
            System.out.println("Web View Link: " + file.getWebViewLink());
            System.out.println("Export link: " + file.getExportLinks());
            System.out.println("MIME type: " + file.getMimeType());
            System.out.println("Icon: " + file.getIconLink());
        } catch (IOException e) {
            System.out.println("An error occurred: " + e);
        }
    }
}
