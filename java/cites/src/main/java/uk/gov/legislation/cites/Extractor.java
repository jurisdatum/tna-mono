package uk.gov.legislation.cites;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import java.io.IOException;
import java.io.InputStream;
import java.util.LinkedList;
import java.util.List;

public class Extractor {

    private final List<EmbeddedCite> cites = new LinkedList<>();

    private Extractor() { }

    public static List<EmbeddedCite> extract(InputStream input) throws IOException, SAXException {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setNamespaceAware(true);
        DocumentBuilder builder;
        try {
            builder = factory.newDocumentBuilder();
        } catch (ParserConfigurationException e) {
            throw new RuntimeException(e);
        }
        Document doc = builder.parse(input);
        return extract(doc);
    }

    public static List<EmbeddedCite> extract(Document doc) {
        Extractor extractor = new Extractor();
        extractor.extractFromDocument(doc);
        return extractor.cites;
    }

    private void extractFromDocument(Document doc) {
        extractFromElement(doc.getDocumentElement());
    }

    private void extractFromNode(Node node) {
        if (node instanceof Element) {
            Element element = (Element) node;
            extractFromElement(element);
        }
    }

    private void extractFromElement(Element element) {
        if (!element.getTagName().equals("Citation")) {
            NodeList children = element.getChildNodes();
            for (int i = 0; i < children.getLength(); i++)
                extractFromNode(children.item(i));
            return;
        }
        String text = element.getTextContent();
        String type = element.getAttribute("Class");
        int year = Integer.parseInt(element.getAttribute("Year"));
        String number = element.getAttribute("Number");
        if (number == null)
            return;
        if (number.isEmpty())
            return;
        Cite cite;
        try {
            cite = new Cite(text, type, year, Integer.parseInt(number));
        } catch (NumberFormatException e) {
            e.printStackTrace();
            return;
        }
        String section = getSection(element.getParentNode());
        EmbeddedCite embedded = new EmbeddedCite(section, cite);
        cites.add(embedded);
    }

    private String getSection(Node node) {
        if (node instanceof Document)
            return null;
        if (!(node instanceof Element))
            return getSection(node.getParentNode());
        Element element = (Element) node;
        // skip some elements?
        String id = element.getAttribute("id");
        if (id != null && !id.isEmpty())
            return id;
        String tag = element.getTagName();
        if (tag.equals("SecondaryPrelims"))
            return "introduction";
        if (tag.equals("SignedSection"))
            return "signature";
        if (tag.equals("ExplanatoryNotes"))
            return "note";
        Node parent = element.getParentNode();
        return getSection(parent);
    }

}
