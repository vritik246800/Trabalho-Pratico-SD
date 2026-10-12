package mz.agrogest.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mz.agrogest.model.Utilizador;
import mz.agrogest.service.ClienteService;
import mz.agrogest.service.NegocioException;

/** B1 — /registo: auto-registo de cliente com login automático. */
@WebServlet("/registo")
public class RegistoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ClienteService service = new ClienteService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession s = req.getSession(false);
        Utilizador u = s == null ? null : (Utilizador) s.getAttribute("utilizador");
        if (u != null) { // já tem sessão: não faz sentido registar outra conta
            res.sendRedirect(req.getContextPath() + (u.isAdmin() ? "/admin" : "/catalogo"));
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/registo.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try {
            String pass = req.getParameter("pass");
            if (pass == null || !pass.equals(req.getParameter("pass2")))
                throw new NegocioException("As palavras-passe não coincidem.");
            Utilizador u = service.registar(req.getParameter("nome"), req.getParameter("email"), pass,
                    req.getParameter("telefone"), req.getParameter("endereco"));
            HttpSession s = req.getSession(false);
            if (s != null) s.invalidate(); // session fixation: sessão nova após login
            s = req.getSession();
            s.setAttribute("utilizador", u);
            s.setAttribute("flash", "Conta criada. Bem-vindo, " + u.getNome() + "!");
            res.sendRedirect(req.getContextPath() + "/catalogo"); // PRG
        } catch (NegocioException e) {
            req.setAttribute("erro", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/registo.jsp").forward(req, res); // volta com os valores (param.*)
        }
    }
}
