package mz.agrogest.service;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import mz.agrogest.model.Fornecedor;
import mz.agrogest.model.Perfil;
import mz.agrogest.model.Produto;
import mz.agrogest.model.Utilizador;
import mz.agrogest.model.Venda;
import mz.agrogest.repo.DataStore;
import mz.agrogest.util.Datas;

/** A3 listagens com ordenação · A4 relatórios de clientes. Só leitura (cópias das listas). */
public class RelatorioService {

    /** tipo de listagem → ordens que aceita (a primeira é a de omissão). */
    public static final Map<String, List<String>> ORDENS = new LinkedHashMap<>();
    static {
        ORDENS.put("produtos", List.of("nome", "preco", "stock", "data"));
        ORDENS.put("fornecedores", List.of("nome"));
        ORDENS.put("clientes", List.of("nome", "valor", "data"));
        ORDENS.put("armazem", List.of("nome", "preco", "stock", "data"));
        ORDENS.put("compras", List.of("data", "valor", "nome"));
    }

    /** Linha de cliente com totais de compras. */
    public static class ClienteStats {
        private final Utilizador cliente;
        private final int compras;
        private final double volume;
        private final LocalDateTime ultimaCompra;

        ClienteStats(Utilizador cliente, List<Venda> vendas) {
            this.cliente = cliente;
            this.compras = vendas.size();
            this.volume = vendas.stream().mapToDouble(Venda::getTotal).sum();
            this.ultimaCompra = vendas.stream().map(Venda::getData).max(Comparator.naturalOrder()).orElse(null);
        }

        public Utilizador getCliente() { return cliente; }
        public int getCompras() { return compras; }
        public double getVolume() { return volume; }
        public LocalDateTime getUltimaCompra() { return ultimaCompra; }
        public String getUltimaCompraFmt() { return Datas.fmt(ultimaCompra); }
    }

    // --- A3 listagens -----------------------------------------------------------------------

    /** armazem = só stock > 0. Ordem: nome · preco · stock · data (validade, sem validade no fim). */
    public List<Produto> produtos(boolean armazem, String ordem, boolean desc) {
        Comparator<Produto> c = switch (ordem) {
            case "preco" -> Comparator.comparingDouble(Produto::getPreco);
            case "stock" -> Comparator.comparingInt(Produto::getQuantidade);
            case "data" -> Comparator.comparing(Produto::getValidade, Comparator.nullsLast(Comparator.naturalOrder()));
            default -> Comparator.comparing(Produto::getNome, String.CASE_INSENSITIVE_ORDER);
        };
        return DataStore.copia(DataStore.get().produtos).stream()
                .filter(p -> !armazem || p.getQuantidade() > 0)
                .sorted(sentido(c, desc))
                .toList();
    }

    public List<Fornecedor> fornecedores(boolean desc) {
        Comparator<Fornecedor> c = Comparator.comparing(Fornecedor::getNome, String.CASE_INSENSITIVE_ORDER);
        return DataStore.copia(DataStore.get().fornecedores).stream().sorted(sentido(c, desc)).toList();
    }

    /** Ordem: nome · valor (total comprado) · data (última compra, sem compras no fim). */
    public List<ClienteStats> clientes(String ordem, boolean desc) {
        Comparator<ClienteStats> c = switch (ordem) {
            case "valor" -> Comparator.comparingDouble(ClienteStats::getVolume);
            case "data" -> Comparator.comparing(ClienteStats::getUltimaCompra, Comparator.nullsFirst(Comparator.naturalOrder()));
            default -> porNomeCliente();
        };
        return stats().stream().sorted(sentido(c, desc)).toList();
    }

    /** Ordem: data · valor (total) · nome (do cliente). */
    public List<Venda> compras(String ordem, boolean desc) {
        Map<Integer, Utilizador> clientes = clientesPorId();
        Comparator<Venda> c = switch (ordem) {
            case "valor" -> Comparator.comparingDouble(Venda::getTotal);
            case "nome" -> Comparator.comparing(v -> nomeDe(clientes.get(v.getClienteId())), String.CASE_INSENSITIVE_ORDER);
            default -> Comparator.comparing(Venda::getData);
        };
        return DataStore.copia(DataStore.get().vendas).stream().sorted(sentido(c, desc)).toList();
    }

    /** id → utilizador, para a JSP mostrar nome/endereço/telefone do cliente de cada venda. */
    public Map<Integer, Utilizador> clientesPorId() {
        return DataStore.copia(DataStore.get().utilizadores).stream()
                .collect(Collectors.toMap(Utilizador::getId, Function.identity()));
    }

    public Map<Integer, Fornecedor> fornecedoresPorId() {
        return DataStore.copia(DataStore.get().fornecedores).stream()
                .collect(Collectors.toMap(Fornecedor::getId, Function.identity()));
    }

    // --- A4 relatórios ----------------------------------------------------------------------

    /** Todos os clientes, nome ↑. */
    public List<ClienteStats> porNome() {
        return stats().stream().sorted(porNomeCliente()).toList();
    }

    /** Clientes que compraram, por volume (soma dos totais) ↓. */
    public List<ClienteStats> porVolume() {
        return stats().stream().filter(s -> s.getCompras() > 0)
                .sorted(Comparator.comparingDouble(ClienteStats::getVolume).reversed().thenComparing(porNomeCliente()))
                .toList();
    }

    /** Ranking por nº de compras ↓ (empate: maior volume primeiro). */
    public List<ClienteStats> maisAssiduos() {
        return stats().stream().filter(s -> s.getCompras() > 0)
                .sorted(Comparator.comparingInt(ClienteStats::getCompras).reversed()
                        .thenComparing(Comparator.comparingDouble(ClienteStats::getVolume).reversed()))
                .toList();
    }

    /** Extra: clientes registados que nunca compraram, nome ↑. */
    public List<ClienteStats> semCompras() {
        return stats().stream().filter(s -> s.getCompras() == 0).sorted(porNomeCliente()).toList();
    }

    // --- A5 dashboard -----------------------------------------------------------------------

    /** Contagens do dashboard, na ordem em que aparecem. */
    public Map<String, Integer> contagens() {
        DataStore ds = DataStore.get();
        Map<String, Integer> m = new LinkedHashMap<>();
        m.put("fornecedores", ds.fornecedores.size());
        m.put("produtos", ds.produtos.size());
        m.put("clientes", (int) DataStore.copia(ds.utilizadores).stream().filter(u -> u.getPerfil() == Perfil.CLIENTE).count());
        m.put("vendas", ds.vendas.size());
        m.put("campanhas", ds.campanhas.size());
        return m;
    }

    // --- auxiliares -------------------------------------------------------------------------

    /** Só perfil CLIENTE, cada um com as suas vendas. */
    private List<ClienteStats> stats() {
        Map<Integer, List<Venda>> porCliente = DataStore.copia(DataStore.get().vendas).stream()
                .collect(Collectors.groupingBy(Venda::getClienteId));
        return DataStore.copia(DataStore.get().utilizadores).stream()
                .filter(u -> u.getPerfil() == Perfil.CLIENTE)
                .map(u -> new ClienteStats(u, porCliente.getOrDefault(u.getId(), List.of())))
                .toList();
    }

    private static Comparator<ClienteStats> porNomeCliente() {
        return Comparator.comparing(s -> s.getCliente().getNome(), String.CASE_INSENSITIVE_ORDER);
    }

    private static String nomeDe(Utilizador u) {
        return u == null ? "" : u.getNome();
    }

    private static <T> Comparator<T> sentido(Comparator<T> c, boolean desc) {
        return desc ? c.reversed() : c;
    }
}
