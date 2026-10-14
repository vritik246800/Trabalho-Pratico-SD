package mz.agrogest.servlet.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mz.agrogest.service.CampanhaService;
import mz.agrogest.service.NegocioException;

/** C2 — registar e remover cultivos por campanha. */
@WebServlet("/admin/cultivos")
public class CultivoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final CampanhaService service = new CampanhaService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setAttribute("campanhas", service.listarCampanhas());

        String pidStr = req.getParameter("campanha");
        if (pidStr != null && !pidStr.isBlank()) {
            try {
                int campanhaId = Integer.parseInt(pidStr.trim());
                req.setAttribute("campanhaId", campanhaId);
                req.setAttribute("cultivos", service.listarCultivos(campanhaId));
                // campanha para mostrar estado (aberta/fechada) no formulário
                var campanhas = service.listarCampanhas();
                campanhas.stream().filter(c -> c.getId() == campanhaId)
                        .findFirst().ifPresent(c -> req.setAttribute("campanhaSel", c));
            } catch (NumberFormatException ignored) {}
        }

        req.getRequestDispatcher("/WEB-INF/views/admin/cultivos.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String campanhaIdStr = req.getParameter("campanhaId");
        int campanhaId = 0;
        try { campanhaId = Integer.parseInt(String.valueOf(campanhaIdStr)); }
        catch (NumberFormatException ignored) {}

        try {
            switch (String.valueOf(req.getParameter("acao"))) {
                case "criar" -> {
                    var cv = service.criarCultivo(
                            campanhaId,
                            req.getParameter("cultura"),
                            req.getParameter("variedade"),
                            req.getParameter("hectares"),
                            req.getParameter("plantio"));
                    req.getSession().setAttribute("flash",
                            "Cultivo \"" + cv.getCultura() + "\" registado.");
                }
                case "remover" -> {
                    service.removerCultivo(id(req.getParameter("id")));
                    req.getSession().setAttribute("flash", "Cultivo removido.");
                }
                default -> throw new NegocioException("Acção desconhecida.");
            }
            res.sendRedirect(req.getContextPath() + "/admin/cultivos?campanha=" + campanhaId);
        } catch (NegocioException e) {
            req.setAttribute("erro", e.getMessage());
            req.setAttribute("campanhaId", campanhaId);
            doGet(req, res);
        }
    }

    private static int id(String v) {
        try { return Integer.parseInt(String.valueOf(v)); }
        catch (NumberFormatException e) { throw new NegocioException("ID inválido."); }
    }
}
