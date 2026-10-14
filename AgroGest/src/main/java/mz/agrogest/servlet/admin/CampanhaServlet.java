package mz.agrogest.servlet.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mz.agrogest.service.CampanhaService;
import mz.agrogest.service.NegocioException;

/** C1 — criar, listar, fechar, reabrir, remover campanhas. */
@WebServlet("/admin/campanhas")
public class CampanhaServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final CampanhaService service = new CampanhaService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setAttribute("campanhas", service.listarCampanhas());
        req.getRequestDispatcher("/WEB-INF/views/admin/campanhas.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            switch (String.valueOf(req.getParameter("acao"))) {
                case "criar" -> {
                    var c = service.criarCampanha(
                            req.getParameter("nome"),
                            req.getParameter("inicio"),
                            req.getParameter("fim"));
                    req.getSession().setAttribute("flash", "Campanha \"" + c.getNome() + "\" criada.");
                }
                case "fechar" -> {
                    service.fecharCampanha(id(req.getParameter("id")));
                    req.getSession().setAttribute("flash", "Campanha fechada.");
                }
                case "reabrir" -> {
                    service.reabrirCampanha(id(req.getParameter("id")));
                    req.getSession().setAttribute("flash", "Campanha reaberta.");
                }
                case "remover" -> {
                    service.removerCampanha(id(req.getParameter("id")));
                    req.getSession().setAttribute("flash", "Campanha removida.");
                }
                default -> throw new NegocioException("Acção desconhecida.");
            }
            res.sendRedirect(req.getContextPath() + "/admin/campanhas");
        } catch (NegocioException e) {
            req.setAttribute("erro", e.getMessage());
            doGet(req, res);
        }
    }

    private static int id(String v) {
        try { return Integer.parseInt(String.valueOf(v)); }
        catch (NumberFormatException e) { throw new NegocioException("ID inválido."); }
    }
}
