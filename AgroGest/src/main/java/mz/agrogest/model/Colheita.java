package mz.agrogest.model;

import java.io.Serializable;
import java.time.LocalDate;
import mz.agrogest.util.Datas;

public class Colheita implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int cultivoId;
    private LocalDate data;
    private double kg;
    private double precoKg;
    private double valorTotal;

    public Colheita() {
    }

    public Colheita(int cultivoId, LocalDate data, double kg, double precoKg) {
        this.cultivoId = cultivoId;
        this.data = data;
        this.kg = kg;
        this.precoKg = precoKg;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCultivoId() {
        return cultivoId;
    }

    public void setCultivoId(int cultivoId) {
        this.cultivoId = cultivoId;
    }

    public LocalDate getData() {
        return data;
    }

    public void setData(LocalDate data) {
        this.data = data;
    }

    public double getKg() {
        return kg;
    }

    public void setKg(double kg) {
        this.kg = kg;
    }

    public double getPrecoKg() {
        return precoKg;
    }

    public void setPrecoKg(double precoKg) {
        this.precoKg = precoKg;
    }

    public double getValorTotal() {
        return valorTotal;
    }

    public void setValorTotal(double valorTotal) {
        this.valorTotal = valorTotal;
    }

    /** dd/MM/yyyy para a JSP (fmt:formatDate não aceita LocalDate). */
    public String getDataFmt() {
        return Datas.fmt(data);
    }
}
