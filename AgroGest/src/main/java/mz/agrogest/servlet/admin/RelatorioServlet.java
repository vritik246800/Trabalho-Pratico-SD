package mz.agrogest.servlet.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mz.agrogest.service.RelatorioService;

/** A4 — relatórios de clientes. */
@WebServlet("/admin/relatorios")
public class RelatorioServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final RelatorioService service = new RelatorioService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setAttribute("porNome", service.porNome());
        req.setAttribute("porVolume", service.porVolume());
        req.setAttribute("assiduos", service.maisAssiduos());
        req.setAttribute("semCompras", service.semCompras());
        req.getRequestDispatcher("/WEB-INF/views/admin/relatorios.jsp").forward(req, res);
    }
}
