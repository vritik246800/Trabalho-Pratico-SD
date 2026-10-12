package mz.agrogest.service;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;

import mz.agrogest.model.Categoria;
import mz.agrogest.model.Produto;
import mz.agrogest.repo.DataStore;

/** A2 — produtos e reposição de stock. Escrita sob o lock do DataStore (o mesmo da venda). */
public class ProdutoService {

    public List<Produto> listar() {
        List<Produto> l = DataStore.copia(DataStore.get().produtos);
        l.sort(Comparator.comparing(Produto::getNome, String.CASE_INSENSITIVE_ORDER));
        return l;
    }

    public Produto criar(String nome, Categoria categoria, int fornecedorId, double preco, int quantidade,
            String unidade, String descricao, String foto, LocalDate validade) {
        nome = FornecedorService.obrigatorio(nome, "Nome");
        unidade = FornecedorService.obrigatorio(unidade, "Unidade");
        if (categoria == null) throw new NegocioException("Categoria obrigatória.");
        if (!(preco > 0)) throw new NegocioException("O preço tem de ser maior que 0.");
        if (quantidade < 0) throw new NegocioException("A quantidade não pode ser negativa.");
        foto = foto == null ? "" : foto.trim();
        // só http(s): impede "javascript:" no <img src>
        if (!foto.isEmpty() && !foto.matches("(?i)https?://\\S+"))
            throw new NegocioException("A foto tem de ser um URL http:// ou https://.");

        DataStore ds = DataStore.get();
        synchronized (ds) {
            if (ds.fornecedor(fornecedorId) == null) throw new NegocioException("Fornecedor não existe.");
            Produto p = new Produto(nome, categoria, fornecedorId, preco, quantidade, unidade,
                    descricao == null ? "" : descricao.trim(), foto, validade);
            p.setId(ds.nextProdutoId());
            ds.produtos.add(p);
            return p;
        }
    }

    /** Soma qtd ao stock actual. */
    public Produto reporStock(int id, int qtd) {
        if (qtd <= 0) throw new NegocioException("A quantidade a repor tem de ser maior que 0.");
        DataStore ds = DataStore.get();
        synchronized (ds) {
            Produto p = ds.produto(id);
            if (p == null) throw new NegocioException("Produto não existe.");
            if ((long) p.getQuantidade() + qtd > Integer.MAX_VALUE) throw new NegocioException("Quantidade demasiado grande.");
            p.setQuantidade(p.getQuantidade() + qtd);
            return p;
        }
    }

    /** Vendas antigas guardam o nome do produto no VendaItem: facturas continuam correctas. */
    public void remover(int id) {
        DataStore ds = DataStore.get();
        synchronized (ds) {
            Produto p = ds.produto(id);
            if (p == null) throw new NegocioException("Produto não existe.");
            ds.produtos.remove(p);
        }
    }
}
