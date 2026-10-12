package mz.agrogest.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

/** SHA-256 + salt de 16 bytes. Formato guardado: "saltBase64:hashBase64". */
public final class PasswordUtil {
    private static final SecureRandom RANDOM = new SecureRandom();

    private PasswordUtil() {
    }

    public static String hash(String pass) {
        byte[] salt = new byte[16];
        RANDOM.nextBytes(salt);
        Base64.Encoder b64 = Base64.getEncoder();
        return b64.encodeToString(salt) + ":" + b64.encodeToString(sha256(salt, pass));
    }

    public static boolean verificar(String pass, String guardado) {
        if (pass == null || guardado == null) return false;
        String[] partes = guardado.split(":");
        if (partes.length != 2) return false;
        try {
            Base64.Decoder b64 = Base64.getDecoder();
            // comparação em tempo constante
            return MessageDigest.isEqual(b64.decode(partes[1]), sha256(b64.decode(partes[0]), pass));
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    private static byte[] sha256(byte[] salt, String pass) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt);
            return md.digest(pass.getBytes(StandardCharsets.UTF_8));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e); // SHA-256 existe em qualquer JVM
        }
    }
}
