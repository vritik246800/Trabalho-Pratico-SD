package mz.agrogest.servlet.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mz.agrogest.repo.Persistencia;
import mz.agrogest.service.NegocioException;

/** C4 — gravar dados agora / apagar ficheiro .ser. */
@WebServlet("/admin/persistencia")
public class PersistenciaServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setAttribute("caminho", Persistencia.caminho());
        req.getRequestDispatcher("/WEB-INF/views/admin/persistencia.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            switch (String.valueOf(req.getParameter("acao"))) {
                case "gravar" -> {
                    Persistencia.gravar();
                    req.getSession().setAttribute("flash", "Dados gravados com sucesso.");
                }
                case "apagar" -> {
                    Persistencia.apagarFicheiro();
                    req.getSession().setAttribute("flash",
                            "Ficheiro apagado. Os dados actuais permanecem em memória até à próxima paragem do Tomcat.");
                }
                case "abrir" -> {
                    try {
                        Persistencia.abrirPasta();
                    } catch (IOException e) {
                        throw new NegocioException("Não foi possível abrir a pasta: " + e.getMessage());
                    }
                }
                default -> throw new NegocioException("Acção desconhecida.");
            }
            res.sendRedirect(req.getContextPath() + "/admin/persistencia");
        } catch (NegocioException e) {
            req.setAttribute("erro", e.getMessage());
            doGet(req, res);
        }
    }
}
