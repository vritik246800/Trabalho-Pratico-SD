package mz.agrogest.servlet;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mz.agrogest.model.Categoria;
import mz.agrogest.model.Produto;
import mz.agrogest.model.Utilizador;
import mz.agrogest.service.NegocioException;
import mz.agrogest.service.VendaService;

/** B3 — GET /carrinho · POST /carrinho/{add,update,remove,limpar}. PRG após cada POST. */
@WebServlet({ "/carrinho", "/carrinho/*" })
public class CarrinhoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final VendaService service = new VendaService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        if (req.getPathInfo() != null) { // GET /carrinho/add etc. não existe
            res.sendRedirect(req.getContextPath() + "/carrinho");
            return;
        }
        mostrar(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String acao = String.valueOf(req.getPathInfo());
        HttpSession s = req.getSession();
        Utilizador u = (Utilizador) s.getAttribute("utilizador");
        Map<Integer, Integer> carrinho = carrinho(s, true);
        try {
            switch (acao) {
                case "/add" -> {
                    int qtd = inteiro(req.getParameter("qtd"), "Quantidade");
                    Produto p = service.adicionar(u, carrinho, inteiro(req.getParameter("produtoId"), "Produto"), qtd);
                    s.setAttribute("flash", "Adicionado ao carrinho: " + qtd + " " + p.getUnidade() + " de " + p.getNome() + ".");
                    // volta ao catálogo, com o mesmo filtro e no cartão do produto
                    Categoria cat = CatalogoServlet.categoria(req.getParameter("categoria"));
                    res.sendRedirect(req.getContextPath() + "/catalogo" + (cat == null ? "" : "?categoria=" + cat) + "#p" + p.getId());
                    return;
                }
                case "/update" -> {
                    Produto p = service.actualizar(u, carrinho, inteiro(req.getParameter("produtoId"), "Produto"),
                            inteiro(req.getParameter("qtd"), "Quantidade"));
                    s.setAttribute("flash", "Quantidade de " + p.getNome() + " actualizada.");
                }
                case "/remove" -> {
                    service.remover(carrinho, inteiro(req.getParameter("produtoId"), "Produto"));
                    s.setAttribute("flash", "Produto retirado do carrinho.");
                }
                case "/limpar" -> {
                    service.limpar(carrinho);
                    s.setAttribute("flash", "Carrinho esvaziado.");
                }
                default -> {
                    res.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
            }
            res.sendRedirect(req.getContextPath() + "/carrinho"); // PRG
        } catch (NegocioException e) {
            req.setAttribute("erro", e.getMessage());
            if (acao.equals("/add")) CatalogoServlet.mostrar(req, res); // o formulário de adicionar está no catálogo
            else mostrar(req, res);
        }
    }

    private void mostrar(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setAttribute("resumo", service.resumo(carrinho(req.getSession(), false)));
        req.getRequestDispatcher("/WEB-INF/views/carrinho.jsp").forward(req, res);
    }

    /** Carrinho da sessão: LinkedHashMap produtoId → qtd (ordem em que se adicionou). criar=false pode dar null. */
    @SuppressWarnings("unchecked")
    static Map<Integer, Integer> carrinho(HttpSession s, boolean criar) {
        synchronized (s) { // Tomcat dá sempre o mesmo objecto por sessão: dois pedidos não criam dois carrinhos
            Map<Integer, Integer> c = (Map<Integer, Integer>) s.getAttribute("carrinho");
            if (c == null && criar) {
                c = new LinkedHashMap<>();
                s.setAttribute("carrinho", c);
            }
            return c;
        }
    }

    static int inteiro(String v, String campo) {
        try {
            return Integer.parseInt(String.valueOf(v).trim());
        } catch (NumberFormatException e) {
            throw new NegocioException(campo + ": número inteiro inválido.");
        }
    }
}
