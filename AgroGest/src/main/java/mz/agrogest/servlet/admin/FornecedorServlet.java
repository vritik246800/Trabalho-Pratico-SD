package mz.agrogest.servlet.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mz.agrogest.model.TipoFornecedor;
import mz.agrogest.service.FornecedorService;
import mz.agrogest.service.NegocioException;

/** A1 — criar, listar, remover fornecedores. */
@WebServlet("/admin/fornecedores")
public class FornecedorServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final FornecedorService service = new FornecedorService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setAttribute("fornecedores", service.listar());
        req.setAttribute("nProdutos", service.produtosPorFornecedor());
        req.setAttribute("tipos", TipoFornecedor.values());
        req.getRequestDispatcher("/WEB-INF/views/admin/fornecedores.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try {
            String acao = String.valueOf(req.getParameter("acao"));
            switch (acao) {
                case "criar" -> {
                    var f = service.criar(req.getParameter("nome"), tipo(req.getParameter("tipo")),
                            req.getParameter("contacto"), req.getParameter("provincia"));
                    req.getSession().setAttribute("flash", "Fornecedor \"" + f.getNome() + "\" criado.");
                }
                case "remover" -> {
                    service.remover(id(req.getParameter("id")));
                    req.getSession().setAttribute("flash", "Fornecedor removido.");
                }
                default -> throw new NegocioException("Acção desconhecida.");
            }
            res.sendRedirect(req.getContextPath() + "/admin/fornecedores"); // PRG
        } catch (NegocioException e) {
            req.setAttribute("erro", e.getMessage());
            doGet(req, res); // volta ao formulário com os valores escritos (param.*)
        }
    }

    private static TipoFornecedor tipo(String v) {
        try {
            return TipoFornecedor.valueOf(String.valueOf(v));
        } catch (IllegalArgumentException e) {
            throw new NegocioException("Tipo de fornecedor inválido.");
        }
    }

    private static int id(String v) {
        try {
            return Integer.parseInt(String.valueOf(v));
        } catch (NumberFormatException e) {
            throw new NegocioException("Fornecedor inválido.");
        }
    }
}
