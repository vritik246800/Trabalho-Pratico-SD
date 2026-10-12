package mz.agrogest.model;

import java.io.Serializable;

public class VendaItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private int produtoId;
    private String nomeProduto;
    private int quantidade;
    private double precoUnit;
    private double subtotal;

    public VendaItem() {
    }

    public VendaItem(int produtoId, String nomeProduto, int quantidade, double precoUnit, double subtotal) {
        this.produtoId = produtoId;
        this.nomeProduto = nomeProduto;
        this.quantidade = quantidade;
        this.precoUnit = precoUnit;
        this.subtotal = subtotal;
    }

    public int getProdutoId() {
        return produtoId;
    }

    public void setProdutoId(int produtoId) {
        this.produtoId = produtoId;
    }

    public String getNomeProduto() {
        return nomeProduto;
    }

    public void setNomeProduto(String nomeProduto) {
        this.nomeProduto = nomeProduto;
    }

    public int getQuantidade() {
        return quantidade;
    }

    public void setQuantidade(int quantidade) {
        this.quantidade = quantidade;
    }

    public double getPrecoUnit() {
        return precoUnit;
    }

    public void setPrecoUnit(double precoUnit) {
        this.precoUnit = precoUnit;
    }

    public double getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(double subtotal) {
        this.subtotal = subtotal;
    }
}
