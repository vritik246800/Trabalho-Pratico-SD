package mz.agrogest.servlet;

import java.io.IOException;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mz.agrogest.model.Categoria;
import mz.agrogest.service.CatalogoService;

/** B2 — /catalogo?categoria=: cartões de produtos com filtro por categoria. */
@WebServlet("/catalogo")
public class CatalogoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final CatalogoService SERVICE = new CatalogoService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        mostrar(req, res);
    }

    /** Também usado pelo CarrinhoServlet: erro ao adicionar volta ao catálogo com o mesmo filtro. */
    static void mostrar(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Categoria categoria = categoria(req.getParameter("categoria"));
        Map<Categoria, Long> contagem = SERVICE.contagemPorCategoria();
        req.setAttribute("categoria", categoria);
        req.setAttribute("categorias", Categoria.values());
        req.setAttribute("contagem", contagem);
        req.setAttribute("totalProdutos", contagem.values().stream().mapToLong(Long::longValue).sum());
        req.setAttribute("produtos", SERVICE.listar(categoria));
        req.setAttribute("fornecedorPorId", SERVICE.fornecedoresPorId());
        req.getRequestDispatcher("/WEB-INF/views/catalogo.jsp").forward(req, res);
    }

    /** Valor fora do enum (ou vazio) = sem filtro. */
    static Categoria categoria(String v) {
        if (v == null || v.isBlank()) return null;
        try {
            return Categoria.valueOf(v.trim());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
