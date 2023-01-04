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
import java.io.*;
import java.util.logging.Logger;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

abstract class RegexEnricher {

    protected Logger logger = Logger.getAnonymousLogger();

    protected abstract Pattern[] patterns();
    protected abstract Cite parse(MatchResult match);

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

    private void enrichText(Text node) {
        if (!shouldEnrich(node))
            return;
        for (Pattern pattern : patterns()) {
            boolean changed = enrich(node, pattern);
            if (changed)
                break;
        }
    }

    private boolean shouldEnrich(Text node) {
        final Element parent = (Element) node.getParentNode();
        if ("Text".equals(parent.getTagName()))
            return true;
        final Element grandparent = (Element) parent.getParentNode();
        if ("Title".equals(parent.getTagName()))
            return !grandparent.getTagName().endsWith("Prelims");
        return false;
    }

    private boolean enrich(Text node, Pattern pattern) {

        String text = node.getTextContent();
        Matcher matcher = pattern.matcher(text);
        if (!matcher.find())
            return false;
        final Cite cite = parse(matcher.toMatchResult());
        if (cite == null)
            return false;
        logger.info("found cite: " + cite.text());

        Document doc = node.getOwnerDocument();
        Node parent = node.getParentNode();

        String beforeText = text.substring(0, matcher.start());
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

        String afterText = text.substring(matcher.end());
        Text afterNode = afterText.isEmpty() ? null : doc.createTextNode(afterText);
        if (afterNode != null)
            parent.insertBefore(afterNode, node);

        parent.removeChild(node);

        if (beforeNode != null)
            enrichText(beforeNode); // could add optimization to skip patterns already tried
        if (afterNode != null)
            enrichText(afterNode);
        return true;
    }

}
