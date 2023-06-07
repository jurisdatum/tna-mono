package uk.gov.legislation.tables;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSOutput;
import org.w3c.dom.ls.LSSerializer;

import javax.xml.transform.*;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.*;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;

public class HtmlTable {

    private final Element table;

    public HtmlTable(Element table) { this.table = table; }

    private ArrayList<Row> header;
    private ArrayList<Row> body;
    private ArrayList<Row> footer;

    private ArrayList<Row> getRows(String xpath) {
        NodeList elements;
        try {
            XPathExpression expr = XPathFactory.newInstance().newXPath().compile(xpath);
            elements = (NodeList) expr.evaluate(table, XPathConstants.NODESET);
        } catch (XPathExpressionException e) {
            throw new RuntimeException(e);
        }
        ArrayList<Row> rows = new ArrayList<>(elements.getLength());
        for (int i = 0; i < elements.getLength(); i++) {
            Element tr = (Element) elements.item(i);
            Row row = new Row(tr);
            rows.add(row);
        }
        return rows;
    }

    public List<Row> header() {
        if (header == null)
            header = getRows("thead/tr");
        return header;
    }

    public List<Row> body() {
        if (body == null)
            body = getRows("tbody/tr");
        return body;
    }

    public List<Row> footer() {
        if (footer == null)
            footer = getRows("tfoot/tr");
        return footer;
    }

    @Override
    public String toString() {
//        Transformer transformer;
//        try {
//            transformer = TransformerFactory.newInstance().newTransformer();
//        } catch (TransformerConfigurationException e) {
//            throw new RuntimeException(e);
//        }
//        transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
//        DOMSource source = new DOMSource(table);
//        StringWriter writer = new StringWriter();
//        StreamResult result = new StreamResult(writer);
//        try {
//            transformer.transform(source, result);
//        } catch (TransformerException e) {
//            throw new RuntimeException(e);
//        }
//        return writer.toString();
        DOMImplementationLS dom = (DOMImplementationLS) table.getOwnerDocument().getImplementation();
        LSSerializer serializer = dom.createLSSerializer();
        serializer.getDomConfig().setParameter("xml-declaration", false);
//        serializer.getDomConfig().setParameter("format-pretty-print", true);
        StringWriter writer = new StringWriter();
        LSOutput output = dom.createLSOutput();
        output.setCharacterStream(writer);
        serializer.write(table, output);
        return writer.toString();
    }

    public static class Row {

        private final Element tr;

        private Row(Element tr) { this.tr = tr; }

        private ArrayList<Cell> cells;

        public List<Cell> cells() {
            if (cells == null) {
                NodeList children = tr.getChildNodes();
                cells = new ArrayList<>(children.getLength());
                for (int i = 0; i < children.getLength(); i++) {
                    Node node = children.item(i);
                    if (node.getNodeType() != Node.ELEMENT_NODE)
                        continue;;
                    Element child = (Element) node;
                    Cell cell = new Cell(child);
                    cells.add(cell);
                }
            }
            return cells;
        }

    }

    public static class Cell {

        private final Element td;

        private Cell(Element td) { this.td = td; }

        public int colspan() {
            if (td.hasAttribute("colspan"))
                return Integer.parseInt(td.getAttribute("colspan"));
            return 1;
        }

        public int rowspan() {
            if (td.hasAttribute("rowspan"))
                return Integer.parseInt(td.getAttribute("rowspan"));
            return 1;
        }

        @Override
        public String toString() {
            return td.getTextContent().replaceAll("\\s+"," ").trim();
        }

    }

}
