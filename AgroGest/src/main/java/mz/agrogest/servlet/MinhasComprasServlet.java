package mz.agrogest.servlet;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mz.agrogest.model.Utilizador;
import mz.agrogest.model.Venda;
import mz.agrogest.service.VendaService;

/** B6 — /minhas-compras: histórico do cliente da sessão, com link para cada factura. */
@WebServlet("/minhas-compras")
public class MinhasComprasServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final VendaService service = new VendaService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Utilizador u = (Utilizador) req.getSession().getAttribute("utilizador");
        if (u.isAdmin()) { // o admin não compra: a lista dele é a de todas as facturas
            res.sendRedirect(req.getContextPath() + "/factura");
            return;
        }
        List<Venda> vendas = service.historico(u.getId());
        req.setAttribute("vendas", vendas);
        req.setAttribute("totalGasto", vendas.stream().mapToDouble(Venda::getTotal).sum());
        req.getRequestDispatcher("/WEB-INF/views/minhas-compras.jsp").forward(req, res);
    }
}
