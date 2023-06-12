package uk.gov.legislation.tables;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSOutput;
import org.w3c.dom.ls.LSSerializer;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

public class Excel {

    static final String NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";

    private final List<List<Grid.Cell>> grid;

    private int cellCount = 0;
    private Map<String, Integer> sharedStringMap = new LinkedHashMap<>();

    final Document worksheet;
    final Document sharedStrings;

    public static byte[] convert(List<List<Grid.Cell>> table) throws IOException {
//        Excel excel = new Excel(table);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        write(table, baos);
        return baos.toByteArray();
    }

    public static void write(List<List<Grid.Cell>> table, OutputStream out) throws IOException {
        Excel excel = new Excel(table);
        excel.write(out);
    }

    private Excel(List<List<Grid.Cell>> grid) {
        this.grid = grid;
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = null;
        try {
            builder = factory.newDocumentBuilder();
        } catch (ParserConfigurationException e) {
            throw new RuntimeException(e);
        }
        worksheet = makeWorksheet(builder);
        sharedStrings = makeSharedStrings(builder);
    }

    private Document makeWorksheet(DocumentBuilder builder) {
        Document document = builder.newDocument();
        Element worksheet = document.createElementNS(NS, "worksheet");
        document.appendChild(worksheet);
        Element sheetData = document.createElementNS(NS, "sheetData");
        worksheet.appendChild(sheetData);
        Element mergeCells = document.createElementNS(NS, "mergeCells");
        int i = 1;
        for (List<Grid.Cell> row: grid) {
            Element e = document.createElementNS(NS, "row");
            e.setAttribute("r", Integer.toString(i));
            sheetData.appendChild(e);
            int j = 1;
            for (Grid.Cell cell: row) {
                cellCount += 1;
                Element c = document.createElementNS(NS, "c");
                c.setAttribute("r", makeCellName(j, i));
                e.appendChild(c);

                String string = cell.text();
                if (string != null) {
                    c.setAttribute("t", "s");
                    Element v = document.createElementNS(NS, "v");
                    c.appendChild(v);

                    int sharedStringNumber;
                    if (sharedStringMap.containsKey(string)) {
                        sharedStringNumber = sharedStringMap.get(string);
                    } else {
                        sharedStringNumber = sharedStringMap.size();
                        sharedStringMap.put(string, sharedStringNumber);
                    }

                    Node text = document.createTextNode(Integer.toString(sharedStringNumber));
                    v.appendChild(text);
                }

                if (cell.first() && (cell.colspan() > 1 || cell.rowspan() > 1)) {
                    String start = makeCellName(j, i);
                    String end = makeCellName(j + cell.colspan() - 1, i + cell.rowspan() - 1);
                    Element mergeCell = worksheet.getOwnerDocument().createElementNS(NS, "mergeCell");
                    mergeCell.setAttribute("ref", start + ":" + end);
                    mergeCells.appendChild(mergeCell);
                }

                j += 1;
            }
            i += 1;
        }
        if (mergeCells.hasChildNodes())
            worksheet.appendChild(mergeCells);
        return document;
    }

    private Document makeSharedStrings(DocumentBuilder builder) {
        Document document = builder.newDocument();
        Element sst = document.createElementNS(NS, "sst");
        document.appendChild(sst);
        sst.setAttribute("count", Integer.toString(cellCount));
        sst.setAttribute("uniqueCount", Integer.toString(sharedStringMap.size()));
        for (String string: sharedStringMap.keySet()) {
            Element si = document.createElementNS(NS, "si");
            sst.appendChild(si);
            Element t = document.createElementNS(NS, "t");
            si.appendChild(t);
            Node text = document.createTextNode(string);
            t.appendChild(text);
        }
        return document;
    }

    public static String makeCellName(int column, int row) {
        if (column > 26)
            throw new IllegalArgumentException();
        char letter = (char) (column + 64);
        return String.valueOf(letter) + row;
    }

    private byte[] serialize(Document doc) {
        DOMImplementationLS dom = (DOMImplementationLS) doc.getImplementation();
        LSSerializer serializer = dom.createLSSerializer();
        serializer.getDomConfig().setParameter("xml-declaration", true);
        LSOutput output = dom.createLSOutput();
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        output.setByteStream(baos);
        serializer.write(doc, output);
        return baos.toByteArray();
    }

    public void write(OutputStream out) throws IOException {
        InputStream in = this.getClass().getResourceAsStream("/template.xlsx");
        ZipInputStream template = new ZipInputStream(in);
        ZipOutputStream zip = new ZipOutputStream(out);
        ZipEntry entry = template.getNextEntry();
        while (entry != null) {
            String name = entry.getName();
            zip.putNextEntry(new ZipEntry(name));
            if (name.equals("xl/worksheets/sheet1.xml")) {
                byte[] data = serialize(worksheet);
                zip.write(data, 0, data.length);
            } else if (name.equals("xl/sharedStrings.xml")) {
                byte[] data = serialize(sharedStrings);
                zip.write(data, 0, data.length);
            } else {
                byte[] buffer = new byte[2048];
                int len;
                while ((len = template.read(buffer)) > 0)
                    zip.write(buffer, 0, len);
            }
            zip.closeEntry();
            entry = template.getNextEntry();
        }
        zip.close();
        template.close();
        in.close();
    }

}
