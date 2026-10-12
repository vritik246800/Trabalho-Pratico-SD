package mz.agrogest.filter;

import java.io.IOException;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mz.agrogest.model.Utilizador;

/** UTF-8 em todos os pedidos · RN04 /admin/* só admin (403) · RN05 rotas de cliente exigem sessão. */
@WebFilter("/*")
public class AuthFilter extends HttpFilter {
    private static final long serialVersionUID = 1L;

    private static final String[] COM_SESSAO = { "/catalogo", "/carrinho", "/compra", "/factura", "/minhas-compras" };

    @Override
    protected void doFilter(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        req.setCharacterEncoding("UTF-8");
        res.setCharacterEncoding("UTF-8");

        String rota = req.getRequestURI().substring(req.getContextPath().length());
        HttpSession s = req.getSession(false);
        Utilizador u = s == null ? null : (Utilizador) s.getAttribute("utilizador");

        if (debaixo(rota, "/admin") && (u == null || !u.isAdmin())) {
            res.setStatus(HttpServletResponse.SC_FORBIDDEN); // RN04
            req.getRequestDispatcher("/WEB-INF/views/403.jsp").forward(req, res);
            return;
        }
        if (u == null) {
            for (String r : COM_SESSAO) {
                if (debaixo(rota, r)) { // RN05
                    res.sendRedirect(req.getContextPath() + "/login");
                    return;
                }
            }
        }
        chain.doFilter(req, res);
    }

    /** "/admin" apanha /admin e /admin/... mas não /administracao. */
    private static boolean debaixo(String rota, String base) {
        return rota.equals(base) || rota.startsWith(base + "/");
    }
}
