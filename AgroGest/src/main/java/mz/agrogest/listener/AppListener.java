package mz.agrogest.listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import mz.agrogest.repo.DataStore;

/** T0: seed se vazio. C4 completa com carregar/gravar .ser. */
@WebListener
public class AppListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        DataStore ds = DataStore.get();
        if (ds.utilizadores.isEmpty()) ds.seed();
        ds.garantirAdmin();
    }
}
