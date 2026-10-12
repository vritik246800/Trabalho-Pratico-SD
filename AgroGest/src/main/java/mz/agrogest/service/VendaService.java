package mz.agrogest.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import mz.agrogest.model.Perfil;
import mz.agrogest.model.Produto;
import mz.agrogest.model.Utilizador;
import mz.agrogest.model.Venda;
import mz.agrogest.model.VendaItem;
import mz.agrogest.repo.DataStore;

/**
 * B3 carrinho · B4 compra (RN01 + RN02) · B5 factura (RN03) · B6 histórico.
 * O carrinho vive na sessão (Map produtoId → qtd); escrita nele protegida pelo lock do próprio Map
 * (dois separadores do mesmo cliente).
 */
public class VendaService {
    public static final double IVA = 0.16;

    /** Linha do carrinho com o preço e o stock de agora (o carrinho só guarda id e quantidade). */
    public static class Linha {
        private final int produtoId;
        private final String nome;
        private final String unidade;
        private final int quantidade;
        private final double precoUnit;
        private final double subtotal;
        private final int disponivel;
        private final String problema;

        Linha(int produtoId, Produto p, int quantidade) {
            this.produtoId = produtoId;
            this.nome = p == null ? "Produto #" + produtoId : p.getNome();
            this.unidade = p == null ? "" : p.getUnidade();
            this.quantidade = quantidade;
            this.precoUnit = p == null ? 0 : p.getPreco();
            this.subtotal = cent(precoUnit * quantidade);
            this.disponivel = p == null ? 0 : p.getQuantidade();
            this.problema = problema(p, quantidade);
        }

        public int getProdutoId() { return produtoId; }
        public String getNome() { return nome; }
        public String getUnidade() { return unidade; }
        public int getQuantidade() { return quantidade; }
        public double getPrecoUnit() { return precoUnit; }
        public double getSubtotal() { return subtotal; }
        public int getDisponivel() { return disponivel; }
        /** RN01: porque é que esta linha não se pode comprar agora. null = pode. */
        public String getProblema() { return problema; }
    }

    /** Carrinho pronto a mostrar: linhas + subtotal, IVA 16 %, total. */
    public static class Resumo {
        private final List<Linha> linhas;
        private final double subtotal;
        private final double iva;
        private final double total;

        Resumo(List<Linha> linhas) {
            this.linhas = linhas;
            this.subtotal = cent(linhas.stream().mapToDouble(Linha::getSubtotal).sum());
            this.iva = cent(subtotal * IVA);
            this.total = cent(subtotal + iva);
        }

        public List<Linha> getLinhas() { return linhas; }
        public double getSubtotal() { return subtotal; }
        public double getIva() { return iva; }
        public double getTotal() { return total; }
        public boolean isVazio() { return linhas.isEmpty(); }
        public boolean isComProblemas() { return linhas.stream().anyMatch(l -> l.getProblema() != null); }
    }

    // --- B3 carrinho ------------------------------------------------------------------------

    public Resumo resumo(Map<Integer, Integer> carrinho) {
        List<Linha> linhas = new ArrayList<>();
        if (carrinho != null) {
            DataStore ds = DataStore.get();
            copia(carrinho).forEach((id, qtd) -> linhas.add(new Linha(id, ds.produto(id), qtd)));
        }
        return new Resumo(linhas);
    }

    /** Soma qtd ao que já está no carrinho. RN01: o total não pode passar o stock actual. */
    public Produto adicionar(Utilizador u, Map<Integer, Integer> carrinho, int produtoId, int qtd) {
        exigirCliente(u);
        if (qtd <= 0) throw new NegocioException("A quantidade tem de ser maior que 0.");
        Produto p = DataStore.get().produto(produtoId);
        if (p == null) throw new NegocioException("Produto não existe.");
        synchronized (carrinho) {
            int jaTem = carrinho.getOrDefault(produtoId, 0);
            exigirStock(p, (long) jaTem + qtd, jaTem);
            carrinho.put(produtoId, jaTem + qtd);
        }
        return p;
    }

    /** Troca a quantidade de uma linha. RN01 como no adicionar. */
    public Produto actualizar(Utilizador u, Map<Integer, Integer> carrinho, int produtoId, int qtd) {
        exigirCliente(u);
        if (qtd <= 0) throw new NegocioException("A quantidade tem de ser maior que 0. Para tirar o produto use Remover.");
        synchronized (carrinho) {
            if (!carrinho.containsKey(produtoId)) throw new NegocioException("Esse produto não está no carrinho.");
            Produto p = DataStore.get().produto(produtoId);
            if (p == null) throw new NegocioException("Esse produto já não está à venda. Remova-o do carrinho.");
            exigirStock(p, qtd, 0);
            carrinho.put(produtoId, qtd);
            return p;
        }
    }

    /** Sem erro se já não estava (duplo clique). */
    public void remover(Map<Integer, Integer> carrinho, int produtoId) {
        synchronized (carrinho) {
            carrinho.remove(produtoId);
        }
    }

    public void limpar(Map<Integer, Integer> carrinho) {
        synchronized (carrinho) {
            carrinho.clear();
        }
    }

    // --- B4 compra --------------------------------------------------------------------------

    /**
     * RN01 + RN02 — valida todos os itens e só depois desconta o stock: ou tudo ou nada.
     * Lock do DataStore, o mesmo do repor stock (A2). Não chega "synchronized" no método: cada servlet
     * tem a sua instância deste service. O lock do carrinho por fora faz o duplo clique esperar e
     * encontrar o carrinho já vazio, em vez de comprar duas vezes.
     */
    public Venda finalizar(Utilizador cliente, Map<Integer, Integer> carrinho) {
        exigirCliente(cliente);
        if (carrinho == null) throw new NegocioException("O carrinho está vazio.");
        DataStore ds = DataStore.get();
        synchronized (carrinho) {
            if (carrinho.isEmpty()) throw new NegocioException("O carrinho está vazio.");
            Venda v = new Venda(cliente.getId(), LocalDateTime.now().withNano(0));
            synchronized (ds) {
                // sessão de antes de um restauro do .ser: o id pode já ser de outra pessoa
                Utilizador registado = ds.utilizador(cliente.getId());
                if (registado == null || !registado.getEmail().equalsIgnoreCase(cliente.getEmail()))
                    throw new NegocioException("A sua sessão já não é válida. Saia e entre de novo.");

                // 1. validar tudo (RN01)
                List<String> falhas = new ArrayList<>();
                Map<Produto, Integer> itens = new LinkedHashMap<>();
                carrinho.forEach((id, qtd) -> {
                    Produto p = ds.produto(id);
                    String problema = problema(p, qtd);
                    if (problema != null) falhas.add((p == null ? "produto #" + id : p.getNome()) + ": " + problema);
                    else itens.put(p, qtd);
                });
                if (!falhas.isEmpty())
                    throw new NegocioException("Compra não concluída, nada foi descontado do stock. Indisponível — "
                            + String.join("; ", falhas) + ".");

                // 2. tudo válido: criar a venda e descontar (RN02). Daqui para baixo nada lança excepção.
                itens.forEach((p, qtd) -> {
                    v.getItens().add(new VendaItem(p.getId(), p.getNome(), qtd, p.getPreco(), cent(p.getPreco() * qtd)));
                    p.setQuantidade(p.getQuantidade() - qtd);
                });
                v.setSubtotal(cent(v.getItens().stream().mapToDouble(VendaItem::getSubtotal).sum()));
                v.setIva(cent(v.getSubtotal() * IVA));
                v.setTotal(cent(v.getSubtotal() + v.getIva()));
                v.setId(ds.nextVendaId()); // RN06
                v.setNumeroFactura(ds.nextNumeroFactura());
                ds.vendas.add(v);
            }
            carrinho.clear();
            return v;
        }
    }

    // --- B5 factura · B6 histórico ----------------------------------------------------------

    /** null se não existe. */
    public Venda venda(int id) {
        return DataStore.get().venda(id);
    }

    /** RN03 — o cliente só vê as suas facturas; o admin vê todas. */
    public boolean podeVer(Utilizador u, Venda v) {
        return u != null && v != null && (u.isAdmin() || v.getClienteId() == u.getId());
    }

    /** Cliente da venda (dados da factura). null se já não existe. */
    public Utilizador cliente(Venda v) {
        return DataStore.get().utilizador(v.getClienteId());
    }

    /** produtoId → unidade, para a factura dizer "3 kg". O VendaItem não a guarda; produto removido fica sem. */
    public Map<Integer, String> unidades(Venda v) {
        Map<Integer, String> m = new HashMap<>();
        for (VendaItem i : v.getItens()) {
            Produto p = DataStore.get().produto(i.getProdutoId());
            if (p != null) m.put(i.getProdutoId(), p.getUnidade());
        }
        return m;
    }

    /** B6 — compras do cliente, mais recente primeiro. */
    public List<Venda> historico(int clienteId) {
        return DataStore.copia(DataStore.get().vendas).stream()
                .filter(v -> v.getClienteId() == clienteId)
                .sorted(MAIS_RECENTE)
                .toList();
    }

    /** Admin (RN03): todas as facturas, mais recente primeiro. */
    public List<Venda> todas() {
        return DataStore.copia(DataStore.get().vendas).stream().sorted(MAIS_RECENTE).toList();
    }

    /** id → utilizador: coluna Cliente na lista de facturas do admin. */
    public Map<Integer, Utilizador> clientesPorId() {
        return DataStore.copia(DataStore.get().utilizadores).stream()
                .collect(Collectors.toMap(Utilizador::getId, Function.identity()));
    }

    // --- auxiliares -------------------------------------------------------------------------

    private static final Comparator<Venda> MAIS_RECENTE = Comparator
            .comparing(Venda::getData, Comparator.nullsFirst(Comparator.<LocalDateTime>naturalOrder()))
            .thenComparingInt(Venda::getId)
            .reversed();

    /** RN01, texto curto sem o nome do produto. null = pode comprar qtd. */
    static String problema(Produto p, int qtd) {
        if (p == null) return "já não está à venda";
        if (qtd <= 0) return "quantidade inválida";
        if (p.getQuantidade() == 0) return "esgotado";
        if (qtd > p.getQuantidade())
            return "pediu " + qtd + " " + p.getUnidade() + ", só há " + p.getQuantidade() + " " + p.getUnidade() + " em stock";
        return null;
    }

    private static void exigirStock(Produto p, long qtd, int jaTem) {
        if (p.getQuantidade() == 0) throw new NegocioException("\"" + p.getNome() + "\" está esgotado.");
        if (qtd > p.getQuantidade())
            throw new NegocioException("Stock insuficiente para \"" + p.getNome() + "\": só há " + p.getQuantidade() + " "
                    + p.getUnidade() + " em stock" + (jaTem > 0 ? " e já tem " + jaTem + " " + p.getUnidade() + " no carrinho." : "."));
    }

    private static void exigirCliente(Utilizador u) {
        if (u == null || u.getPerfil() != Perfil.CLIENTE)
            throw new NegocioException("Só clientes podem comprar. Entre com uma conta de cliente.");
    }

    private static Map<Integer, Integer> copia(Map<Integer, Integer> carrinho) {
        synchronized (carrinho) {
            return new LinkedHashMap<>(carrinho);
        }
    }

    /** Dinheiro arredondado ao cêntimo: subtotal + IVA batem certo com o total impresso. */
    static double cent(double v) {
        return Math.round(v * 100) / 100.0;
    }
}
