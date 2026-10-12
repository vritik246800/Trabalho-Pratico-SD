package mz.agrogest.servlet.admin;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mz.agrogest.service.RelatorioService;

/** A3 — /admin/listagens?tipo=&ordem=&dir=asc|desc. Valores fora da lista caem na omissão. */
@WebServlet("/admin/listagens")
public class ListagemServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final RelatorioService service = new RelatorioService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String tipo = req.getParameter("tipo");
        if (tipo == null || !RelatorioService.ORDENS.containsKey(tipo)) tipo = "produtos";
        List<String> ordens = RelatorioService.ORDENS.get(tipo);
        String ordem = req.getParameter("ordem");
        if (ordem == null || !ordens.contains(ordem)) ordem = ordens.get(0); // List.of().contains(null) lança NPE
        String dir = req.getParameter("dir");
        // sem dir: data e valor do mais recente/maior para o menor, o resto crescente
        boolean desc = dir == null ? ordem.equals("data") || ordem.equals("valor") : dir.equals("desc");

        Object linhas = switch (tipo) {
            case "fornecedores" -> service.fornecedores(desc);
            case "clientes" -> service.clientes(ordem, desc);
            case "compras" -> service.compras(ordem, desc);
            default -> service.produtos(tipo.equals("armazem"), ordem, desc);
        };
        req.setAttribute("tipo", tipo);
        req.setAttribute("ordem", ordem);
        req.setAttribute("desc", desc);
        req.setAttribute("ordens", ordens);
        req.setAttribute("tipos", RelatorioService.ORDENS.keySet());
        req.setAttribute("linhas", linhas);
        if (tipo.equals("compras")) req.setAttribute("clientePorId", service.clientesPorId());
        if (tipo.equals("produtos") || tipo.equals("armazem")) req.setAttribute("fornecedorPorId", service.fornecedoresPorId());
        req.getRequestDispatcher("/WEB-INF/views/admin/listagens.jsp").forward(req, res);
    }
}
