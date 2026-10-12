package mz.agrogest.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mz.agrogest.model.Utilizador;
import mz.agrogest.repo.DataStore;
import mz.agrogest.util.PasswordUtil;

@WebServlet({ "/login", "/logout" })
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        if ("/logout".equals(req.getServletPath())) {
            HttpSession s = req.getSession(false);
            if (s != null) s.invalidate();
            req.getSession().setAttribute("flash", "Sessão terminada.");
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        HttpSession s = req.getSession(false);
        Utilizador u = s == null ? null : (Utilizador) s.getAttribute("utilizador");
        if (u != null) {
            res.sendRedirect(inicio(req, u));
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String email = req.getParameter("email");
        String pass = req.getParameter("pass");
        Utilizador u = DataStore.get().utilizadorPorEmail(email);
        // mesma mensagem para email ou pass errados: não revela que contas existem
        if (u == null || !PasswordUtil.verificar(pass, u.getPassHash())) {
            req.setAttribute("erro", "Email ou palavra-passe incorrectos.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, res);
            return;
        }
        if (!u.isAtivo()) {
            req.setAttribute("erro", "Conta desactivada. Contacte o administrador.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, res);
            return;
        }
        req.getSession().invalidate(); // session fixation: sessão nova após login
        req.getSession().setAttribute("utilizador", u);
        res.sendRedirect(inicio(req, u));
    }

    /** Admin → /admin · cliente → /catalogo. */
    private static String inicio(HttpServletRequest req, Utilizador u) {
        return req.getContextPath() + (u.isAdmin() ? "/admin" : "/catalogo");
    }
}
