package mz.agrogest.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import mz.agrogest.util.Datas;

public class Venda implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int clienteId;
    private LocalDateTime data;
    private List<VendaItem> itens = new ArrayList<>();
    private double subtotal;
    private double iva;
    private double total;
    private String numeroFactura;

    public Venda() {
    }

    public Venda(int clienteId, LocalDateTime data) {
        this.clienteId = clienteId;
        this.data = data;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getClienteId() {
        return clienteId;
    }

    public void setClienteId(int clienteId) {
        this.clienteId = clienteId;
    }

    public LocalDateTime getData() {
        return data;
    }

    public void setData(LocalDateTime data) {
        this.data = data;
    }

    public List<VendaItem> getItens() {
        return itens;
    }

    public void setItens(List<VendaItem> itens) {
        this.itens = itens;
    }

    public double getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(double subtotal) {
        this.subtotal = subtotal;
    }

    public double getIva() {
        return iva;
    }

    public void setIva(double iva) {
        this.iva = iva;
    }

    public double getTotal() {
        return total;
    }

    public void setTotal(double total) {
        this.total = total;
    }

    public String getNumeroFactura() {
        return numeroFactura;
    }

    public void setNumeroFactura(String numeroFactura) {
        this.numeroFactura = numeroFactura;
    }

    /** dd/MM/yyyy HH:mm para a JSP. */
    public String getDataFmt() {
        return Datas.fmt(data);
    }
}
