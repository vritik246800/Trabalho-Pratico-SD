package mz.agrogest.model;

import java.io.Serializable;

public class Utilizador implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String nome;
    private String email;
    private String passHash;
    private Perfil perfil;
    private boolean ativo;
    private String telefone;
    private String endereco;

    public Utilizador() {
    }

    public Utilizador(String nome, String email, String passHash, Perfil perfil, String telefone, String endereco) {
        this.nome = nome;
        this.email = email;
        this.passHash = passHash;
        this.perfil = perfil;
        this.telefone = telefone;
        this.endereco = endereco;
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

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassHash() {
        return passHash;
    }

    public void setPassHash(String passHash) {
        this.passHash = passHash;
    }

    public Perfil getPerfil() {
        return perfil;
    }

    public void setPerfil(Perfil perfil) {
        this.perfil = perfil;
    }

    public boolean isAtivo() {
        return ativo;
    }

    public void setAtivo(boolean ativo) {
        this.ativo = ativo;
    }

    public String getTelefone() {
        return telefone;
    }

    public void setTelefone(String telefone) {
        this.telefone = telefone;
    }

    public String getEndereco() {
        return endereco;
    }

    public void setEndereco(String endereco) {
        this.endereco = endereco;
    }

    public boolean isAdmin() {
        return perfil == Perfil.ADMIN;
    }
}
