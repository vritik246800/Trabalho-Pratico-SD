package mz.agrogest.service;

/** Regra de negócio violada. A mensagem vai tal e qual para a JSP. */
public class NegocioException extends RuntimeException {
    private static final long serialVersionUID = 1L;

    public NegocioException(String mensagem) {
        super(mensagem);
    }
}
