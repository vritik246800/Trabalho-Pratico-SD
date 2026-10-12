package mz.agrogest.repo;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.Predicate;

import mz.agrogest.model.Campanha;
import mz.agrogest.model.Categoria;
import mz.agrogest.model.Colheita;
import mz.agrogest.model.Cultivo;
import mz.agrogest.model.Fornecedor;
import mz.agrogest.model.Perfil;
import mz.agrogest.model.Produto;
import mz.agrogest.model.TipoFornecedor;
import mz.agrogest.model.Utilizador;
import mz.agrogest.model.Venda;
import mz.agrogest.model.VendaItem;
import mz.agrogest.util.PasswordUtil;

/**
 * Dados da aplicação em memória. Serializa inteiro (listas + contadores) para o .ser.
 * Escrita que lê e altera (ex. stock) :: synchronized (DataStore.get()) { ... } em todos os services,
 * para usarem o mesmo lock.
 */
public final class DataStore implements Serializable {
    private static final long serialVersionUID = 1L;
    private static final double IVA = 0.16;

    private static volatile DataStore instancia = new DataStore();

    public static DataStore get() {
        return instancia;
    }

    /** Só a Persistencia (C4) usa, depois de desserializar. */
    public static void set(DataStore novo) {
        instancia = novo;
    }

    public final List<Utilizador> utilizadores = Collections.synchronizedList(new ArrayList<>());
    public final List<Fornecedor> fornecedores = Collections.synchronizedList(new ArrayList<>());
    public final List<Produto> produtos = Collections.synchronizedList(new ArrayList<>());
    public final List<Campanha> campanhas = Collections.synchronizedList(new ArrayList<>());
    public final List<Venda> vendas = Collections.synchronizedList(new ArrayList<>());

    // RN06 — um contador por entidade; serializam com o DataStore, logo ficam restaurados
    private final AtomicInteger seqUtilizador = new AtomicInteger();
    private final AtomicInteger seqFornecedor = new AtomicInteger();
    private final AtomicInteger seqProduto = new AtomicInteger();
    private final AtomicInteger seqCampanha = new AtomicInteger();
    private final AtomicInteger seqCultivo = new AtomicInteger();
    private final AtomicInteger seqColheita = new AtomicInteger();
    private final AtomicInteger seqVenda = new AtomicInteger();
    private final AtomicInteger seqFactura = new AtomicInteger();

    public int nextUtilizadorId() { return seqUtilizador.incrementAndGet(); }
    public int nextFornecedorId() { return seqFornecedor.incrementAndGet(); }
    public int nextProdutoId() { return seqProduto.incrementAndGet(); }
    public int nextCampanhaId() { return seqCampanha.incrementAndGet(); }
    public int nextCultivoId() { return seqCultivo.incrementAndGet(); }
    public int nextColheitaId() { return seqColheita.incrementAndGet(); }
    public int nextVendaId() { return seqVenda.incrementAndGet(); }

    /** "FT-<ano actual>-<n>", n sequencial. */
    public String nextNumeroFactura() {
        return "FT-" + LocalDate.now().getYear() + "-" + seqFactura.incrementAndGet();
    }

    public Utilizador utilizador(int id) { return primeiro(utilizadores, u -> u.getId() == id); }
    public Produto produto(int id) { return primeiro(produtos, p -> p.getId() == id); }
    public Fornecedor fornecedor(int id) { return primeiro(fornecedores, f -> f.getId() == id); }
    public Campanha campanha(int id) { return primeiro(campanhas, c -> c.getId() == id); }
    public Venda venda(int id) { return primeiro(vendas, v -> v.getId() == id); }

    /** Sem distinguir maiúsculas. null se não existe. */
    public Utilizador utilizadorPorEmail(String email) {
        if (email == null) return null;
        String e = email.trim();
        return primeiro(utilizadores, u -> u.getEmail().equalsIgnoreCase(e));
    }

    /** Cópia para iterar sem segurar o lock da lista (iterar a synchronizedList directamente não é seguro). */
    public static <T> List<T> copia(List<T> lista) {
        synchronized (lista) {
            return new ArrayList<>(lista);
        }
    }

    private static <T> T primeiro(List<T> lista, Predicate<T> filtro) {
        synchronized (lista) {
            for (T t : lista) if (filtro.test(t)) return t;
        }
        return null;
    }

    /** Admin + dados de exemplo do enunciado: 3 fornecedores · 3 produtos · 5 clientes · 4 vendas · 1 campanha. */
    public synchronized void seed() {
        garantirAdmin();

        Fornecedor f1 = fornecedor("AgroSementes Nampula", TipoFornecedor.SEMENTES, "+258 84 123 4567", "Nampula");
        Fornecedor f2 = fornecedor("FertiMoz, Lda", TipoFornecedor.FERTILIZANTES, "+258 82 765 4321", "Zambézia");
        Fornecedor f3 = fornecedor("MaquiAgro Moçambique", TipoFornecedor.MAQUINARIA, "+258 87 555 0101", "Maputo");

        LocalDate hoje = LocalDate.now();
        Produto milho = produto(new Produto("Semente de Milho", Categoria.SEMENTE, f1.getId(), 85, 500, "kg",
                "Milho branco de ciclo curto, adaptado ao norte de Moçambique.", "", hoje.plusMonths(6)));
        Produto adubo = produto(new Produto("Adubo NPK 12-24-12", Categoria.FERTILIZANTE, f2.getId(), 1850, 120, "saco",
                "Saco de 50 kg para adubação de fundo.", "", hoje.plusMonths(18)));
        Produto enxada = produto(new Produto("Enxada", Categoria.FERRAMENTA, f3.getId(), 450, 60, "unidade",
                "Enxada de aço com cabo de madeira.", "", null));

        Utilizador joao = cliente("João Silva", "joao@teste.mz", "+258 84 111 2222", "Av. Eduardo Mondlane, Nampula");
        Utilizador maria = cliente("Maria Mussa", "maria@teste.mz", "+258 82 333 4444", "Bairro Muahivire, Nampula");
        Utilizador carlos = cliente("Carlos Muianga", "carlos@teste.mz", "+258 86 555 6666", "Rua dos Continuadores, Nacala");
        cliente("Ana Nhantumbo", "ana@teste.mz", "+258 84 777 8888", "Av. Julius Nyerere, Maputo");
        cliente("Pedro Cossa", "pedro@teste.mz", "+258 87 999 0000", "Bairro Natiquiri, Nampula");

        LocalDateTime agora = LocalDateTime.now().withSecond(0).withNano(0);
        venda(joao, agora.minusDays(20), milho, 10, adubo, 2);
        venda(maria, agora.minusDays(12), adubo, 5);
        venda(joao, agora.minusDays(5), enxada, 3, milho, 4);
        venda(carlos, agora.minusDays(2), enxada, 1);

        Campanha camp = new Campanha("Campanha 2025/2026", LocalDate.of(2025, 10, 1), LocalDate.of(2026, 6, 30));
        camp.setId(nextCampanhaId());
        camp.setFechada(true);
        Cultivo cult = new Cultivo(camp.getId(), "Milho", "Matuba", 5, LocalDate.of(2025, 11, 20));
        cult.setId(nextCultivoId());
        Colheita col = new Colheita(cult.getId(), LocalDate.of(2026, 4, 15), 12000, 15);
        col.setId(nextColheitaId());
        col.setValorTotal(col.getKg() * col.getPrecoKg());
        cult.getColheitas().add(col);
        camp.getCultivos().add(cult);
        campanhas.add(camp);
    }

    /** Cria admin@agro.mz / admin234 se não existir (também para o C4 depois de carregar o .ser). */
    public synchronized void garantirAdmin() {
        if (utilizadorPorEmail("admin@agro.mz") != null) return;
        Utilizador admin = new Utilizador("Administrador", "admin@agro.mz", PasswordUtil.hash("admin234"),
                Perfil.ADMIN, "", "");
        admin.setId(nextUtilizadorId());
        admin.setAtivo(true);
        utilizadores.add(admin);
    }

    private Fornecedor fornecedor(String nome, TipoFornecedor tipo, String contacto, String provincia) {
        Fornecedor f = new Fornecedor(nome, tipo, contacto, provincia);
        f.setId(nextFornecedorId());
        fornecedores.add(f);
        return f;
    }

    private Produto produto(Produto p) {
        p.setId(nextProdutoId());
        produtos.add(p);
        return p;
    }

    private Utilizador cliente(String nome, String email, String telefone, String endereco) {
        Utilizador u = new Utilizador(nome, email, PasswordUtil.hash("1234"), Perfil.CLIENTE, telefone, endereco);
        u.setId(nextUtilizadorId());
        u.setAtivo(true);
        utilizadores.add(u);
        return u;
    }

    /** pares (produto, quantidade). Seed: stock já reflecte as vendas, não desconta. */
    private void venda(Utilizador cliente, LocalDateTime data, Object... pares) {
        Venda v = new Venda(cliente.getId(), data);
        double subtotal = 0;
        for (int i = 0; i < pares.length; i += 2) {
            Produto p = (Produto) pares[i];
            int q = (Integer) pares[i + 1];
            v.getItens().add(new VendaItem(p.getId(), p.getNome(), q, p.getPreco(), q * p.getPreco()));
            subtotal += q * p.getPreco();
        }
        v.setId(nextVendaId());
        v.setNumeroFactura(nextNumeroFactura());
        v.setSubtotal(subtotal);
        v.setIva(subtotal * IVA);
        v.setTotal(subtotal + v.getIva());
        vendas.add(v);
    }
}
