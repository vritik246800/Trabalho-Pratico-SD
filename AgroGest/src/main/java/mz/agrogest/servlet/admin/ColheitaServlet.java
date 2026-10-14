package mz.agrogest.servlet.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mz.agrogest.service.CampanhaService;
import mz.agrogest.service.NegocioException;

/** C3 — registar e remover colheitas por cultivo. */
@WebServlet("/admin/colheitas")
public class ColheitaServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final CampanhaService service = new CampanhaService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setAttribute("campanhas", service.listarCampanhas());
        req.setAttribute("cultivos", service.todosOsCultivos());

        String pidStr = req.getParameter("cultivo");
        if (pidStr != null && !pidStr.isBlank()) {
            try {
                int cultivoId = Integer.parseInt(pidStr.trim());
                req.setAttribute("cultivoId", cultivoId);
                req.setAttribute("colheitas", service.listarColheitas(cultivoId));
                req.setAttribute("cultivoSel", service.encontrarCultivo(cultivoId));
            } catch (NumberFormatException ignored) {}
        }

        req.getRequestDispatcher("/WEB-INF/views/admin/colheitas.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String cultivoIdStr = req.getParameter("cultivoId");
        int cultivoId = 0;
        try { cultivoId = Integer.parseInt(String.valueOf(cultivoIdStr)); }
        catch (NumberFormatException ignored) {}

        try {
            switch (String.valueOf(req.getParameter("acao"))) {
                case "criar" -> {
                    var col = service.criarColheita(
                            cultivoId,
                            req.getParameter("data"),
                            req.getParameter("kg"),
                            req.getParameter("precoKg"));
                    req.getSession().setAttribute("flash",
                            "Colheita de " + col.getKg() + " kg registada (total: " + String.format("%.2f", col.getValorTotal()) + " MT).");
                }
                case "remover" -> {
                    service.removerColheita(id(req.getParameter("id")));
                    req.getSession().setAttribute("flash", "Colheita removida.");
                }
                default -> throw new NegocioException("Acção desconhecida.");
            }
            res.sendRedirect(req.getContextPath() + "/admin/colheitas?cultivo=" + cultivoId);
        } catch (NegocioException e) {
            req.setAttribute("erro", e.getMessage());
            req.setAttribute("cultivoId", cultivoId);
            doGet(req, res);
        }
    }

    private static int id(String v) {
        try { return Integer.parseInt(String.valueOf(v)); }
        catch (NumberFormatException e) { throw new NegocioException("ID inválido."); }
    }
}
