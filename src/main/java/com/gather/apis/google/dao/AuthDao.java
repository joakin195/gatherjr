package com.gather.apis.google.dao;

import com.gather.gathercommons.auth.JDBCLoginService;
import com.gather.springcommons.services.AdvancedSSPService;
import com.gather.springcommons.services.IResultSetProvider;
import java.io.Serializable;
import java.sql.Connection;
import javax.annotation.Resource;
import javax.inject.Inject;
import javax.inject.Named;
import javax.sql.DataSource;
import org.apache.log4j.Logger;
import org.springframework.dao.DataAccessException;

/**
 *
 * @author JOAQUINMARTINEZ
 */
@Named
public class AuthDao implements Serializable {

    @Inject
    private transient Logger LOG;

    @Resource(name = "jdbc/GCB")
    private DataSource ds;

    private AdvancedSSPService sesionService;

    private AdvancedSSPService getSesionService() {
        if (this.sesionService == null) {
            this.sesionService = new AdvancedSSPService(ds,
                    "ADMIN.GENERAR_SESION",
                    1);
        }

        return this.sesionService;
    }

    public IResultSetProvider sesionService(Object userName) throws
            DataAccessException {
        final AdvancedSSPService ssp = this.getSesionService();
        ssp.resetParameter();
        ssp.addParameter(userName);
        ssp.executeQuery();

        return ssp;
    }

    public boolean authenticate(String name,
            String password) throws
            Exception {
        final Connection connection = this.ds.getConnection();
        final String url = connection.getMetaData().getURL();
        JDBCLoginService loginService = new JDBCLoginService(connection.getMetaData().getDriverName(),
                url);
        connection.close();

        return name != null && password != null && loginService.authenticate(name,
                password.toCharArray(),
                url);
    }

    
}
