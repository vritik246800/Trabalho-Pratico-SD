package mz.agrogest.model;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import mz.agrogest.util.Datas;

public class Campanha implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String nome;
    private LocalDate inicio;
    private LocalDate fim;
    private boolean fechada;
    private List<Cultivo> cultivos = new ArrayList<>();

    public Campanha() {
    }

    public Campanha(String nome, LocalDate inicio, LocalDate fim) {
        this.nome = nome;
        this.inicio = inicio;
        this.fim = fim;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public LocalDate getInicio() {
        return inicio;
    }

    public void setInicio(LocalDate inicio) {
        this.inicio = inicio;
    }

    public LocalDate getFim() {
        return fim;
    }

    public void setFim(LocalDate fim) {
        this.fim = fim;
    }

    public boolean isFechada() {
        return fechada;
    }

    public void setFechada(boolean fechada) {
        this.fechada = fechada;
    }

    public List<Cultivo> getCultivos() {
        return cultivos;
    }

    public void setCultivos(List<Cultivo> cultivos) {
        this.cultivos = cultivos;
    }

    /** dd/MM/yyyy para a JSP (fmt:formatDate não aceita LocalDate). */
    public String getInicioFmt() {
        return Datas.fmt(inicio);
    }

    /** dd/MM/yyyy para a JSP (fmt:formatDate não aceita LocalDate). */
    public String getFimFmt() {
        return Datas.fmt(fim);
    }
}
