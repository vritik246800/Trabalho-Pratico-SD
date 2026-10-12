package mz.agrogest.util;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/** Datas em formato português para as JSP. null → "". */
public final class Datas {
    private static final DateTimeFormatter DIA = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter DIA_HORA = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private Datas() {
    }

    public static String fmt(LocalDate d) {
        return d == null ? "" : d.format(DIA);
    }

    public static String fmt(LocalDateTime d) {
        return d == null ? "" : d.format(DIA_HORA);
    }
}
