package mz.agrogest.service;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import mz.agrogest.model.Campanha;
import mz.agrogest.model.Colheita;
import mz.agrogest.model.Cultivo;
import mz.agrogest.repo.DataStore;

/** C1 + C2 + C3 — campanhas, cultivos, colheitas. */
public class CampanhaService {

    // ── C1 ──────────────────────────────────────────────────────────────────

    public List<Campanha> listarCampanhas() {
        List<Campanha> l = DataStore.copia(DataStore.get().campanhas);
        l.sort(Comparator.comparing(Campanha::getInicio).reversed());
        return l;
    }

    public Campanha criarCampanha(String nome, String inicioStr, String fimStr) {
        nome = obrigatorio(nome, "Nome");
        LocalDate inicio = parseData(inicioStr, "Início");
        LocalDate fim = parseData(fimStr, "Fim");
        if (fim.isBefore(inicio)) throw new NegocioException("A data de fim não pode ser anterior à de início.");

        DataStore ds = DataStore.get();
        synchronized (ds) {
            Campanha c = new Campanha(nome, inicio, fim);
            c.setId(ds.nextCampanhaId());
            ds.campanhas.add(c);
            return c;
        }
    }

    public void fecharCampanha(int id) {
        DataStore ds = DataStore.get();
        synchronized (ds) {
            Campanha c = campanha(ds, id);
            if (c.isFechada()) throw new NegocioException("Campanha já está fechada.");
            c.setFechada(true);
        }
    }

    public void reabrirCampanha(int id) {
        DataStore ds = DataStore.get();
        synchronized (ds) {
            Campanha c = campanha(ds, id);
            if (!c.isFechada()) throw new NegocioException("Campanha já está aberta.");
            c.setFechada(false);
        }
    }

    public void removerCampanha(int id) {
        DataStore ds = DataStore.get();
        synchronized (ds) {
            Campanha c = campanha(ds, id);
            if (!c.getCultivos().isEmpty())
                throw new NegocioException("Não é possível remover \"" + c.getNome()
                        + "\": tem " + c.getCultivos().size() + " cultivo(s) associado(s). Remova-os primeiro.");
            ds.campanhas.remove(c);
        }
    }

    // ── C2 ──────────────────────────────────────────────────────────────────

    public List<Cultivo> listarCultivos(int campanhaId) {
        DataStore ds = DataStore.get();
        synchronized (ds) {
            Campanha c = ds.campanha(campanhaId);
            if (c == null) return List.of();
            return List.copyOf(c.getCultivos());
        }
    }

    public Cultivo criarCultivo(int campanhaId, String cultura, String variedade,
                                String hectaresStr, String plantioStr) {
        cultura = obrigatorio(cultura, "Cultura");
        variedade = obrigatorio(variedade, "Variedade");
        double hectares = parsePositivo(hectaresStr, "Hectares");
        LocalDate plantio = parseData(plantioStr, "Plantio");

        DataStore ds = DataStore.get();
        synchronized (ds) {
            Campanha c = campanha(ds, campanhaId);
            if (c.isFechada()) throw new NegocioException("Não é possível adicionar cultivos a uma campanha fechada.");
            Cultivo cv = new Cultivo(campanhaId, cultura, variedade, hectares, plantio);
            cv.setId(ds.nextCultivoId());
            c.getCultivos().add(cv);
            return cv;
        }
    }

    public void removerCultivo(int cultivoId) {
        DataStore ds = DataStore.get();
        synchronized (ds) {
            for (Campanha c : DataStore.copia(ds.campanhas)) {
                Optional<Cultivo> opt = c.getCultivos().stream()
                        .filter(cv -> cv.getId() == cultivoId).findFirst();
                if (opt.isPresent()) {
                    Cultivo cv = opt.get();
                    if (!cv.getColheitas().isEmpty())
                        throw new NegocioException("Não é possível remover este cultivo: tem "
                                + cv.getColheitas().size() + " colheita(s). Remova-as primeiro.");
                    c.getCultivos().remove(cv);
                    return;
                }
            }
            throw new NegocioException("Cultivo não encontrado.");
        }
    }

    // ── C3 ──────────────────────────────────────────────────────────────────

    public List<Colheita> listarColheitas(int cultivoId) {
        DataStore ds = DataStore.get();
        synchronized (ds) {
            Cultivo cv = encontrarCultivo(cultivoId);
            if (cv == null) return List.of();
            return List.copyOf(cv.getColheitas());
        }
    }

    public Colheita criarColheita(int cultivoId, String dataStr, String kgStr, String precoKgStr) {
        LocalDate data = parseData(dataStr, "Data");
        double kg = parsePositivo(kgStr, "Kg");
        double precoKg = parsePositivo(precoKgStr, "Preço/kg");

        DataStore ds = DataStore.get();
        synchronized (ds) {
            Cultivo cv = encontrarCultivo(cultivoId);
            if (cv == null) throw new NegocioException("Cultivo não encontrado.");
            Colheita col = new Colheita(cultivoId, data, kg, precoKg);
            col.setId(ds.nextColheitaId());
            col.setValorTotal(kg * precoKg);
            cv.getColheitas().add(col);
            return col;
        }
    }

    public void removerColheita(int colheitaId) {
        DataStore ds = DataStore.get();
        synchronized (ds) {
            for (Campanha c : DataStore.copia(ds.campanhas)) {
                for (Cultivo cv : c.getCultivos()) {
                    Optional<Colheita> opt = cv.getColheitas().stream()
                            .filter(col -> col.getId() == colheitaId).findFirst();
                    if (opt.isPresent()) {
                        cv.getColheitas().remove(opt.get());
                        return;
                    }
                }
            }
            throw new NegocioException("Colheita não encontrada.");
        }
    }

    // ── utilitários ─────────────────────────────────────────────────────────

    /** Todos os cultivos de todas as campanhas (para o selector de C3). */
    public List<Cultivo> todosOsCultivos() {
        return DataStore.copia(DataStore.get().campanhas).stream()
                .flatMap(c -> c.getCultivos().stream())
                .sorted(Comparator.comparingInt(Cultivo::getId))
                .collect(Collectors.toList());
    }

    public Cultivo encontrarCultivo(int cultivoId) {
        return DataStore.copia(DataStore.get().campanhas).stream()
                .flatMap(c -> c.getCultivos().stream())
                .filter(cv -> cv.getId() == cultivoId)
                .findFirst().orElse(null);
    }

    /** Devolve o nome da campanha a que pertence o cultivo (para exibir no selector). */
    public String nomeCampanhaDoCultivo(int cultivoId) {
        return DataStore.copia(DataStore.get().campanhas).stream()
                .filter(c -> c.getCultivos().stream().anyMatch(cv -> cv.getId() == cultivoId))
                .map(Campanha::getNome)
                .findFirst().orElse("?");
    }

    private static Campanha campanha(DataStore ds, int id) {
        Campanha c = ds.campanha(id);
        if (c == null) throw new NegocioException("Campanha não encontrada.");
        return c;
    }

    private static String obrigatorio(String v, String campo) {
        if (v == null || v.isBlank()) throw new NegocioException(campo + " obrigatório.");
        return v.trim();
    }

    private static LocalDate parseData(String v, String campo) {
        if (v == null || v.isBlank()) throw new NegocioException(campo + " obrigatório.");
        try {
            return LocalDate.parse(v.trim());
        } catch (Exception e) {
            throw new NegocioException(campo + " inválido (formato esperado: AAAA-MM-DD).");
        }
    }

    private static double parsePositivo(String v, String campo) {
        if (v == null || v.isBlank()) throw new NegocioException(campo + " obrigatório.");
        try {
            double d = Double.parseDouble(v.trim().replace(',', '.'));
            if (d <= 0) throw new NegocioException(campo + " deve ser maior que zero.");
            return d;
        } catch (NumberFormatException e) {
            throw new NegocioException(campo + " inválido.");
        }
    }
}
