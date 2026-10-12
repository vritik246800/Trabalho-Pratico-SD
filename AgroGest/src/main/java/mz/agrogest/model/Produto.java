package mz.agrogest.model;

import java.io.Serializable;
import java.time.LocalDate;
import mz.agrogest.util.Datas;

public class Produto implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String nome;
    private Categoria categoria;
    private int fornecedorId;
    private double preco;
    private int quantidade;
    private String unidade;
    private String descricao;
    private String foto;
    private LocalDate validade;

    public Produto() {
    }

    public Produto(String nome, Categoria categoria, int fornecedorId, double preco, int quantidade, String unidade, String descricao, String foto, LocalDate validade) {
        this.nome = nome;
        this.categoria = categoria;
        this.fornecedorId = fornecedorId;
        this.preco = preco;
        this.quantidade = quantidade;
        this.unidade = unidade;
        this.descricao = descricao;
        this.foto = foto;
        this.validade = validade;
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

    public Categoria getCategoria() {
        return categoria;
    }

    public void setCategoria(Categoria categoria) {
        this.categoria = categoria;
    }

    public int getFornecedorId() {
        return fornecedorId;
    }

    public void setFornecedorId(int fornecedorId) {
        this.fornecedorId = fornecedorId;
    }

    public double getPreco() {
        return preco;
    }

    public void setPreco(double preco) {
        this.preco = preco;
    }

    public int getQuantidade() {
        return quantidade;
    }

    public void setQuantidade(int quantidade) {
        this.quantidade = quantidade;
    }

    public String getUnidade() {
        return unidade;
    }

    public void setUnidade(String unidade) {
        this.unidade = unidade;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public String getFoto() {
        return foto;
    }

    public void setFoto(String foto) {
        this.foto = foto;
    }

    public LocalDate getValidade() {
        return validade;
    }

    public void setValidade(LocalDate validade) {
        this.validade = validade;
    }

    /** dd/MM/yyyy para a JSP (fmt:formatDate não aceita LocalDate). */
    public String getValidadeFmt() {
        return Datas.fmt(validade);
    }
}
