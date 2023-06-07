package uk.gov.legislation.tables;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.util.List;

public class CSV {

    public static String convert(List<List<Grid.Cell>> table) throws IOException {
        StringWriter writer = new StringWriter();
        write(table, writer);
        return writer.toString();
    }

    public static void write(List<List<Grid.Cell>> table, OutputStream out) throws IOException {
        OutputStreamWriter writer = new OutputStreamWriter(out);
        write(table, writer);
        writer.close();
    }

    public static void write(List<List<Grid.Cell>> table, Appendable writer) throws IOException {
        CSVFormat format = CSVFormat.Builder.create(CSVFormat.DEFAULT).setRecordSeparator('\n').build();
        CSVPrinter printer = format.print(writer);
        write(table, printer);
        printer.close();
    }

    private static void write(List<List<Grid.Cell>> table, CSVPrinter printer) throws IOException {
        for (List<Grid.Cell> row: table)
            printer.printRecord(row.stream().map(c -> c.text()));
    }

}
