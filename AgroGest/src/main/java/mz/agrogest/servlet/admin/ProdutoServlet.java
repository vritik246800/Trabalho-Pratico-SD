package mz.agrogest.servlet.admin;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mz.agrogest.model.Categoria;
import mz.agrogest.model.Produto;
import mz.agrogest.service.FornecedorService;
import mz.agrogest.service.NegocioException;
import mz.agrogest.service.ProdutoService;
import mz.agrogest.service.RelatorioService;

/** A2 — criar, listar, repor stock, remover · A10 editar. ?novo=1 / ?editar=id abrem o painel do formulário. */
@WebServlet("/admin/produtos")
public class ProdutoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ProdutoService service = new ProdutoService();
    private final FornecedorService fornecedores = new FornecedorService();
    private final RelatorioService relatorios = new RelatorioService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setAttribute("produtos", service.listar());
        req.setAttribute("expirados", service.expirados());
        req.setAttribute("fornecedores", fornecedores.listar());
        req.setAttribute("fornecedorPorId", relatorios.fornecedoresPorId());
        req.setAttribute("categorias", Categoria.values());
        // painel de edição: ?editar=id, ou o POST editar que falhou (volta com os valores escritos)
        String editar = "editar".equals(req.getParameter("acao")) ? req.getParameter("id") : req.getParameter("editar");
        if (editar != null) {
            try {
                req.setAttribute("emEdicao", service.produto(Integer.parseInt(editar.trim())));
            } catch (NumberFormatException e) {
                // id mal escrito: lista sem painel
            }
        }
        req.getRequestDispatcher("/WEB-INF/views/admin/produtos.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try {
            String acao = String.valueOf(req.getParameter("acao"));
            switch (acao) {
                case "criar" -> {
                    Produto p = service.criar(formulario(req));
                    req.getSession().setAttribute("flash", "Produto \"" + p.getNome() + "\" criado.");
                }
                case "editar" -> {
                    Produto p = service.editar(inteiro(req.getParameter("id"), "Produto"), formulario(req));
                    req.getSession().setAttribute("flash", "Produto \"" + p.getNome() + "\" guardado.");
                }
                case "repor" -> {
                    Produto p = service.reporStock(inteiro(req.getParameter("id"), "Produto"),
                            inteiro(req.getParameter("qtd"), "Quantidade a repor"));
                    req.getSession().setAttribute("flash",
                            "Stock de \"" + p.getNome() + "\" actualizado para " + p.getQuantidade() + " " + p.getUnidade() + ".");
                }
                case "remover" -> {
                    service.remover(inteiro(req.getParameter("id"), "Produto"));
                    req.getSession().setAttribute("flash", "Produto removido.");
                }
                default -> throw new NegocioException("Acção desconhecida.");
            }
            res.sendRedirect(req.getContextPath() + "/admin/produtos"); // PRG
        } catch (NegocioException e) {
            req.setAttribute("erro", e.getMessage());
            doGet(req, res);
        }
    }

    /** Campos do formulário criar/editar, ainda por validar no service. */
    private static Produto formulario(HttpServletRequest req) {
        return new Produto(req.getParameter("nome"), categoria(req.getParameter("categoria")),
                inteiro(req.getParameter("fornecedorId"), "Fornecedor"),
                decimal(req.getParameter("preco"), "Preço"),
                inteiro(req.getParameter("quantidade"), "Quantidade"),
                req.getParameter("unidade"), req.getParameter("descricao"), req.getParameter("foto"),
                data(req.getParameter("validade")));
    }

    private static Categoria categoria(String v) {
        try {
            return Categoria.valueOf(String.valueOf(v));
        } catch (IllegalArgumentException e) {
            throw new NegocioException("Categoria inválida.");
        }
    }

    private static int inteiro(String v, String campo) {
        try {
            return Integer.parseInt(String.valueOf(v).trim());
        } catch (NumberFormatException e) {
            throw new NegocioException(campo + ": número inteiro inválido.");
        }
    }

    /** Aceita vírgula decimal (320,50). */
    private static double decimal(String v, String campo) {
        try {
            double d = Double.parseDouble(String.valueOf(v).trim().replace(',', '.'));
            if (!Double.isFinite(d)) throw new NumberFormatException();
            return d;
        } catch (NumberFormatException e) {
            throw new NegocioException(campo + ": número inválido.");
        }
    }

    /** yyyy-MM-dd do <input type="date">. Vazio = sem validade (ferramentas, maquinaria). */
    private static LocalDate data(String v) {
        if (v == null || v.isBlank()) return null;
        try {
            return LocalDate.parse(v.trim());
        } catch (DateTimeParseException e) {
            throw new NegocioException("Validade: data inválida.");
        }
    }
}
