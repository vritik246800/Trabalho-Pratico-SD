package mz.agrogest.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mz.agrogest.model.Utilizador;
import mz.agrogest.model.Venda;
import mz.agrogest.service.NegocioException;
import mz.agrogest.service.VendaService;

/**
 * B5 — /factura?id=: factura imprimível. RN03: o cliente só vê as suas (outra → 403), o admin vê todas.
 * Sem id: admin vê a lista de todas as facturas; cliente vai para o histórico.
 */
@WebServlet("/factura")
public class FacturaServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final VendaService service = new VendaService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Utilizador u = (Utilizador) req.getSession().getAttribute("utilizador");
        String id = req.getParameter("id");
        if (id == null || id.isBlank()) {
            if (!u.isAdmin()) {
                res.sendRedirect(req.getContextPath() + "/minhas-compras");
                return;
            }
            req.setAttribute("todas", true);
            req.setAttribute("vendas", service.todas());
            req.setAttribute("clientePorId", service.clientesPorId());
            req.getRequestDispatcher("/WEB-INF/views/minhas-compras.jsp").forward(req, res);
            return;
        }

        Venda v = venda(id);
        if (v == null) {
            res.setStatus(HttpServletResponse.SC_NOT_FOUND);
        } else if (!service.podeVer(u, v)) { // RN03
            res.setStatus(HttpServletResponse.SC_FORBIDDEN);
            req.setAttribute("negado", true);
        } else {
            req.setAttribute("venda", v);
            req.setAttribute("cliente", service.cliente(v));
            req.setAttribute("unidades", service.unidades(v));
        }
        req.getRequestDispatcher("/WEB-INF/views/factura.jsp").forward(req, res);
    }

    /** id que não é número = factura que não existe. */
    private Venda venda(String id) {
        try {
            return service.venda(CarrinhoServlet.inteiro(id, "Factura"));
        } catch (NegocioException e) {
            return null;
        }
    }
}
