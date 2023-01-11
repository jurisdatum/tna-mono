package uk.gov.legislation.cites;

import org.w3c.dom.*;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.time.Year;
import java.util.logging.Logger;

abstract class AbstractEnricher {

    protected Logger logger = Logger.getAnonymousLogger();

    public byte[] enrich(InputStream stream) throws IOException, SAXException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        enrich(stream, baos);
        return baos.toByteArray();
    }

    public void enrich(InputStream input, OutputStream output) throws IOException, SAXException {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setNamespaceAware(true);
        DocumentBuilder builder;
        try {
            builder = factory.newDocumentBuilder();
        } catch (ParserConfigurationException e) {
            throw new RuntimeException(e);
        }
        Document doc = builder.parse(input);
        enrich(doc);
        DOMSource source = new DOMSource(doc);
        StreamResult result = new StreamResult(output);
        try {
            Transformer transformer = TransformerFactory.newInstance().newTransformer();
            transformer.transform(source, result);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }
    }

    public void enrich(Document doc) {
        enrichNode(doc.getDocumentElement());
    }

    private void enrichNode(Node node) {
        if (node instanceof Element) {
            NodeList children = node.getChildNodes();
            for (int i = 0; i < children.getLength(); i++)
                enrichNode(children.item(i));
            return;
        }
        if (node instanceof Text) {
            Text text = (Text) node;
            enrichText(text);
        }
    }

    abstract protected void enrichText(Text node);

    static final int currentYear = Year.now().getValue();

    static boolean isYear(int num, int earliest) {
        return isYear(num, earliest, currentYear);
    }
    static boolean isYear(int num, int earliest, int latest) {
        if (num < 10)
            return false;
        if (num > latest)
            return false;
        if (num > 99 && num < earliest)
            return false;
        return true;
    }

    static int normalizeYear(int year) {
        if (year > 999)
            return year;
        if (year > 99)
            throw new IllegalArgumentException();
        final int currentCentury = currentYear / 100 * 100;
        final int currentTwoDigitYear = currentYear % 100;
        if (year <= currentTwoDigitYear)
            return currentCentury + year;
        final int lastCentury = currentCentury - 100;
        return  lastCentury + year;
    }

    protected void replaceNode(Node node, String beforeText, Cite cite, String afterText, boolean enrichBefore) {
        Document doc = node.getOwnerDocument();
        Node parent = node.getParentNode();

        Text beforeNode = beforeText.isEmpty() ? null : doc.createTextNode(beforeText);
        if (beforeNode != null)
            parent.insertBefore(beforeNode, node);

        Element citation = doc.createElementNS("http://www.legislation.gov.uk/namespaces/legislation", "Citation");
        citation.setAttribute("Class", cite.type());
        citation.setAttribute("Year", Integer.toString(cite.year()));
        citation.setAttribute("Number", Integer.toString(cite.number()));
        citation.appendChild(doc.createTextNode(cite.text()));
        String url = cite.url();
        if (url != null)
            citation.setAttribute("URI", url);
        parent.insertBefore(citation, node);

        Text afterNode = afterText.isEmpty() ? null : doc.createTextNode(afterText);
        if (afterNode != null)
            parent.insertBefore(afterNode, node);

        parent.removeChild(node);

        if (enrichBefore && beforeNode != null)
            enrichText(beforeNode);
        if (afterNode != null)
            enrichText(afterNode);
    }

}
