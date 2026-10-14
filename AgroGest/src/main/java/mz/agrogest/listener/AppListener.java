package mz.agrogest.listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import mz.agrogest.repo.DataStore;
import mz.agrogest.repo.Persistencia;

/** C4 — carrega .ser no arranque, grava na paragem. */
@WebListener
public class AppListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        Persistencia.carregar();
        DataStore ds = DataStore.get();
        if (ds.utilizadores.isEmpty()) ds.seed();
        ds.garantirAdmin();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        Persistencia.gravar();
    }
}
