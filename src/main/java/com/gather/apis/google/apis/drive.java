/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.gather.apis.google.apis;

import com.google.api.client.http.FileContent;
import com.google.api.client.http.GenericUrl;
import com.google.api.client.http.HttpResponse;
import com.google.api.services.drive.Drive;
import com.google.api.services.drive.model.File;
import com.google.api.services.drive.model.FileList;
import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import javax.inject.Named;
import org.omnifaces.cdi.ViewScoped;

/**
 *
 * @author MacJoaquin
 */
@Named
@ViewScoped
public class drive implements Serializable{

    private authGoogle authGoogle = new authGoogle();

    public drive() {
    }

    
    

    //crear carpeta google Drive
    public void carpeta(String nombreCarpetaDrive) {
        try {
            File fileMetadata = new File();
            fileMetadata.setTitle(nombreCarpetaDrive);
            fileMetadata.setMimeType("application/vnd.google-apps.folder");

            File file = authGoogle.servicioDrive().files().insert(fileMetadata)
                    .setFields("id")
                    .execute();
            System.out.println("Id Carpeta Creada: " + file.getId());
        } catch (Exception e) {
            System.out.println("Error: " + e);
        }

    }
    
    public List<File> verDocsFolder(String folder) throws IOException{
         FileList result = authGoogle.servicioDrive().files().list()
             .setQ("'"+folder+"'"+ " in parents")
             .execute();
        List<File> files = result.getItems();
        
        return files;
    }
    
    //listado de todas las carpetas de drive que no estan en la basura de drive.
    public List<File> verCarpetas() throws IOException{
         FileList result = authGoogle.servicioDrive().files().list()
             .setQ("mimeType='application/vnd.google-apps.folder'and trashed = false")
             .execute();
        List<File> files = result.getItems();
        
        return files;
    }
    
    //listado de archivos de drive general que no estan en la basura.
    public List<File> verOtros() throws IOException{
         FileList result = authGoogle.servicioDrive().files().list()
                 .setQ("trashed = false")
             .execute();
        List<File> files = result.getItems();
        
        return files;
    }
  

   

    public String uploadTextFile(String filePath, String title) throws IOException {
        File body = new File();
        body.setTitle(title);
        body.setDescription("A test document");
        body.setMimeType("text/plain");
        java.io.File fileContent = new java.io.File(filePath);
        FileContent mediaContent = new FileContent("text/plain", fileContent);
        File file = authGoogle.servicioDrive().files().insert(body, mediaContent).execute();
        return file.getId();
    }

    public String downloadTextFile(File file) throws IOException {
        GenericUrl url = new GenericUrl(file.getWebViewLink());
        HttpResponse response = authGoogle.servicioDrive().getRequestFactory().buildGetRequest(url).execute();
        System.out.println(url);
        try {
            return new Scanner(response.getContent()).useDelimiter("\\A").next();

        } catch (java.util.NoSuchElementException e) {
            System.out.println("Error " + e);
        }
        return null;
    }

    public String downloadTextFile(String fileID) throws IOException {
        File file = authGoogle.servicioDrive().files().get(fileID).execute();
        return downloadTextFile(file);
    }

}
