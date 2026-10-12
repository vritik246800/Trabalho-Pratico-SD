package mz.agrogest.service;

import java.util.Comparator;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import mz.agrogest.model.Categoria;
import mz.agrogest.model.Fornecedor;
import mz.agrogest.model.Produto;
import mz.agrogest.repo.DataStore;

/** B2 — catálogo do cliente. Só leitura (cópias das listas). */
public class CatalogoService {

    /** Todos os produtos (os esgotados também, sem botão de adicionar), nome ↑. categoria null = todas. */
    public List<Produto> listar(Categoria categoria) {
        return DataStore.copia(DataStore.get().produtos).stream()
                .filter(p -> categoria == null || p.getCategoria() == categoria)
                .sorted(Comparator.comparing(Produto::getNome, String.CASE_INSENSITIVE_ORDER))
                .toList();
    }

    /** Nº de produtos por categoria, para os filtros. Todas as categorias presentes (0 se vazia). */
    public Map<Categoria, Long> contagemPorCategoria() {
        Map<Categoria, Long> m = new EnumMap<>(Categoria.class);
        for (Categoria c : Categoria.values()) m.put(c, 0L);
        for (Produto p : DataStore.copia(DataStore.get().produtos))
            if (p.getCategoria() != null) m.merge(p.getCategoria(), 1L, Long::sum); // EnumMap não aceita chave null
        return m;
    }

    /** id → fornecedor, para o cartão mostrar o nome. */
    public Map<Integer, Fornecedor> fornecedoresPorId() {
        return DataStore.copia(DataStore.get().fornecedores).stream()
                .collect(Collectors.toMap(Fornecedor::getId, Function.identity()));
    }
}
