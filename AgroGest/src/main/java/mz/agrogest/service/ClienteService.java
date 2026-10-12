package mz.agrogest.service;

import java.util.Locale;

import mz.agrogest.model.Perfil;
import mz.agrogest.model.Utilizador;
import mz.agrogest.repo.DataStore;
import mz.agrogest.util.PasswordUtil;

/** B1 — auto-registo de clientes. */
public class ClienteService {
    private static final String EMAIL = "[^@\\s]+@[^@\\s]+\\.[^@\\s]+";

    /** Perfil CLIENTE, activo, pass guardada só como hash. Email único (sem distinguir maiúsculas). */
    public Utilizador registar(String nome, String email, String pass, String telefone, String endereco) {
        nome = obrigatorio(nome, "Nome", 100);
        email = obrigatorio(email, "Email", 100).toLowerCase(Locale.ROOT);
        telefone = obrigatorio(telefone, "Telefone", 30);
        endereco = obrigatorio(endereco, "Endereço", 200);
        if (!email.matches(EMAIL)) throw new NegocioException("Email inválido.");
        // dígitos, espaços, + - ( ) e pelo menos 9 dígitos (+258 84 123 4567)
        if (!telefone.matches("[0-9 +()-]+") || telefone.replaceAll("\\D", "").length() < 9)
            throw new NegocioException("Telefone inválido: use só dígitos, espaços e +, com pelo menos 9 dígitos.");
        if (pass == null || pass.length() < 4) throw new NegocioException("A palavra-passe tem de ter pelo menos 4 caracteres.");
        if (pass.length() > 100) throw new NegocioException("A palavra-passe não pode ter mais de 100 caracteres.");

        Utilizador u = new Utilizador(nome, email, PasswordUtil.hash(pass), Perfil.CLIENTE, telefone, endereco);
        u.setAtivo(true);
        DataStore ds = DataStore.get();
        // verificar e inserir sob o mesmo lock: dois registos simultâneos com o mesmo email não passam os dois
        synchronized (ds) {
            if (ds.utilizadorPorEmail(email) != null)
                throw new NegocioException("Já existe uma conta com o email " + email + ".");
            u.setId(ds.nextUtilizadorId());
            ds.utilizadores.add(u);
        }
        return u;
    }

    private static String obrigatorio(String v, String campo, int max) {
        if (v == null || v.isBlank()) throw new NegocioException(campo + " obrigatório.");
        v = v.trim();
        if (v.length() > max) throw new NegocioException(campo + ": máximo " + max + " caracteres.");
        return v;
    }
}
