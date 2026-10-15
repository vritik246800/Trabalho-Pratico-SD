package mz.agrogest.repo;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.logging.Logger;

/** C4 — gravar/carregar DataStore em ${catalina.base}/data/agrogest.ser (escrita atómica). */
public final class Persistencia {
    private static final Logger LOG = Logger.getLogger(Persistencia.class.getName());

    private Persistencia() {}

    public static Path caminho() {
        String base = System.getProperty("catalina.base", System.getProperty("user.home"));
        Path dir = Paths.get(base, "data");
        try {
            Files.createDirectories(dir);
        } catch (IOException ignored) {}
        return dir.resolve("agrogest.ser");
    }

    public static void gravar() {
        Path dst = caminho();
        Path tmp = dst.resolveSibling("agrogest.tmp");
        try (ObjectOutputStream oos = new ObjectOutputStream(
                new BufferedOutputStream(Files.newOutputStream(tmp)))) {
            oos.writeObject(DataStore.get());
            oos.flush();
        } catch (IOException e) {
            LOG.warning("Erro ao gravar DataStore: " + e.getMessage());
            return;
        }
        try {
            Files.move(tmp, dst, StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
            LOG.info("DataStore gravado em: " + dst);
        } catch (IOException e) {
            LOG.warning("Erro ao mover .tmp → .ser: " + e.getMessage());
        }
    }

    public static void carregar() {
        Path p = caminho();
        if (!Files.exists(p)) {
            LOG.info("Ficheiro .ser não encontrado, será usado seed().");
            return;
        }
        try (ObjectInputStream ois = new ObjectInputStream(
                new BufferedInputStream(Files.newInputStream(p)))) {
            DataStore ds = (DataStore) ois.readObject();
            DataStore.set(ds);
            LOG.info("DataStore carregado de: " + p);
        } catch (Exception e) {
            LOG.warning("Ficheiro corrompido ou incompatível, a usar seed(): " + e.getMessage());
            // DataStore continua o novo vazio — AppListener chama seed() a seguir
        }
    }

    public static void apagarFicheiro() {
        try {
            boolean apagado = Files.deleteIfExists(caminho());
            if (apagado) LOG.info("Ficheiro .ser apagado.");
        } catch (IOException e) {
            LOG.warning("Erro ao apagar ficheiro .ser: " + e.getMessage());
        }
    }

    /** A7 — revela o .ser no Finder (macOS) ou Explorador (Windows). Só abre na máquina do servidor. */
    public static void abrirPasta() throws IOException {
        Path p = caminho();
        String os = System.getProperty("os.name").toLowerCase();
        boolean existe = Files.exists(p);
        if (os.contains("mac"))
            new ProcessBuilder(existe ? new String[]{"open", "-R", p.toString()}
                                      : new String[]{"open", p.getParent().toString()}).start();
        else if (os.contains("win"))
            new ProcessBuilder(existe ? new String[]{"explorer", "/select," + p}
                                      : new String[]{"explorer", p.getParent().toString()}).start();
        else
            throw new IOException("Só disponível em macOS ou Windows.");
    }
}
