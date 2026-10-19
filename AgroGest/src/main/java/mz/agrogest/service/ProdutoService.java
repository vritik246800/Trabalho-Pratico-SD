package mz.agrogest.service;

import java.util.Comparator;
import java.util.List;

import mz.agrogest.model.Categoria;
import mz.agrogest.model.Produto;
import mz.agrogest.repo.DataStore;

/** A2 — produtos e reposição de stock. Escrita sob o lock do DataStore (o mesmo da venda). */
public class ProdutoService {

    /** null se não existe. */
    public Produto produto(int id) {
        return DataStore.get().produto(id);
    }

    public List<Produto> listar() {
        List<Produto> l = DataStore.copia(DataStore.get().produtos);
        l.sort(Comparator.comparing(Produto::getNome, String.CASE_INSENSITIVE_ORDER));
        return l;
    }

    /** dados = produto ainda sem id, com o que veio do formulário. */
    public Produto criar(Produto dados) {
        Produto p = validar(dados);
        DataStore ds = DataStore.get();
        synchronized (ds) {
            if (ds.fornecedor(p.getFornecedorId()) == null) throw new NegocioException("Fornecedor não existe.");
            p.setId(ds.nextProdutoId());
            ds.produtos.add(p);
            return p;
        }
    }

    /** A10 — troca todos os campos do produto id pelos de dados. Mesmas validações do criar. */
    public Produto editar(int id, Produto dados) {
        Produto v = validar(dados);
        DataStore ds = DataStore.get();
        synchronized (ds) {
            Produto p = ds.produto(id);
            if (p == null) throw new NegocioException("Produto não existe.");
            if (ds.fornecedor(v.getFornecedorId()) == null) throw new NegocioException("Fornecedor não existe.");
            p.setNome(v.getNome());
            p.setCategoria(v.getCategoria());
            p.setFornecedorId(v.getFornecedorId());
            p.setPreco(v.getPreco());
            p.setQuantidade(v.getQuantidade());
            p.setUnidade(v.getUnidade());
            p.setDescricao(v.getDescricao());
            p.setFoto(v.getFoto());
            p.setValidade(v.getValidade());
            return p;
        }
    }

    /** Produto novo (sem id) com os campos limpos e validados. */
    private static Produto validar(Produto d) {
        String nome = FornecedorService.obrigatorio(d.getNome(), "Nome");
        String unidade = FornecedorService.obrigatorio(d.getUnidade(), "Unidade");
        if (d.getCategoria() == null) throw new NegocioException("Categoria obrigatória.");
        if (!(d.getPreco() > 0)) throw new NegocioException("O preço tem de ser maior que 0.");
        if (d.getQuantidade() < 0) throw new NegocioException("A quantidade não pode ser negativa.");
        String foto = d.getFoto() == null ? "" : d.getFoto().trim();
        // só http(s): impede "javascript:" no <img src>
        if (!foto.isEmpty() && !foto.matches("(?i)https?://\\S+"))
            throw new NegocioException("A foto tem de ser um URL http:// ou https://.");
        return new Produto(nome, d.getCategoria(), d.getFornecedorId(), d.getPreco(), d.getQuantidade(), unidade,
                d.getDescricao() == null ? "" : d.getDescricao().trim(), foto, d.getValidade());
    }

    /** A8 — produtos com validade passada, para o alerta do admin. Mais antigo primeiro. */
    public List<Produto> expirados() {
        return DataStore.copia(DataStore.get().produtos).stream()
                .filter(Produto::isExpirado)
                .sorted(Comparator.comparing(Produto::getValidade))
                .toList();
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
