package mz.agrogest.service;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import mz.agrogest.model.Fornecedor;
import mz.agrogest.model.Produto;
import mz.agrogest.model.TipoFornecedor;
import mz.agrogest.repo.DataStore;

/** A1 — fornecedores. */
public class FornecedorService {

    public List<Fornecedor> listar() {
        List<Fornecedor> l = DataStore.copia(DataStore.get().fornecedores);
        l.sort(Comparator.comparing(Fornecedor::getNome, String.CASE_INSENSITIVE_ORDER));
        return l;
    }

    public Fornecedor criar(String nome, TipoFornecedor tipo, String contacto, String provincia) {
        nome = obrigatorio(nome, "Nome");
        contacto = obrigatorio(contacto, "Contacto");
        provincia = obrigatorio(provincia, "Província");
        if (tipo == null) throw new NegocioException("Tipo de fornecedor obrigatório.");

        DataStore ds = DataStore.get();
        synchronized (ds) {
            Fornecedor f = new Fornecedor(nome, tipo, contacto, provincia);
            f.setId(ds.nextFornecedorId());
            ds.fornecedores.add(f);
            return f;
        }
    }

    public void remover(int id) {
        DataStore ds = DataStore.get();
        synchronized (ds) {
            Fornecedor f = ds.fornecedor(id);
            if (f == null) throw new NegocioException("Fornecedor não existe.");
            long n = DataStore.copia(ds.produtos).stream().filter(p -> p.getFornecedorId() == id).count();
            if (n > 0)
                throw new NegocioException("Não é possível remover \"" + f.getNome() + "\": tem " + n
                        + " produto(s) associado(s). Remova primeiro os produtos.");
            ds.fornecedores.remove(f);
        }
    }

    /** fornecedorId → nº de produtos (coluna da tabela: explica porque não se remove). */
    public Map<Integer, Long> produtosPorFornecedor() {
        return DataStore.copia(DataStore.get().produtos).stream()
                .collect(Collectors.groupingBy(Produto::getFornecedorId, Collectors.counting()));
    }

    static String obrigatorio(String v, String campo) {
        if (v == null || v.isBlank()) throw new NegocioException(campo + " obrigatório.");
        return v.trim();
    }
}
