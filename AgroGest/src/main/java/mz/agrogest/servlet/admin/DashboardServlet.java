package mz.agrogest.servlet.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mz.agrogest.service.RelatorioService;

/** A5 — /admin: contagens + atalhos para os módulos. */
@WebServlet("/admin")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final RelatorioService service = new RelatorioService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setAttribute("contagens", service.contagens());
        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, res);
    }
}
