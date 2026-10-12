package mz.agrogest.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mz.agrogest.model.Utilizador;
import mz.agrogest.model.Venda;
import mz.agrogest.service.NegocioException;
import mz.agrogest.service.VendaService;

/** B4 — GET /compra (rever e confirmar) · POST /compra (finalizar → factura). */
@WebServlet("/compra")
public class CompraServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final VendaService service = new VendaService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        mostrar(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession s = req.getSession();
        try {
            Venda v = service.finalizar((Utilizador) s.getAttribute("utilizador"), CarrinhoServlet.carrinho(s, false));
            s.setAttribute("flash", "Compra concluída. Factura " + v.getNumeroFactura() + " emitida.");
            res.sendRedirect(req.getContextPath() + "/factura?id=" + v.getId()); // PRG
        } catch (NegocioException e) { // RN01: mensagem na página, carrinho e stock ficam como estavam (RN02)
            req.setAttribute("erro", e.getMessage());
            mostrar(req, res);
        }
    }

    private void mostrar(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setAttribute("resumo", service.resumo(CarrinhoServlet.carrinho(req.getSession(), false)));
        req.getRequestDispatcher("/WEB-INF/views/compra.jsp").forward(req, res);
    }
}
