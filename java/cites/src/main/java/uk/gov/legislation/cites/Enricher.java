package uk.gov.legislation.cites;

import org.w3c.dom.Document;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.List;

public class Enricher {

    private final EURegexEnricher eu = new EURegexEnricher();

    public void enrich(InputStream input, OutputStream output) throws IOException, SAXException {
        Document doc = Util.parse(input);
        enrich(doc);
        Util.serialize(doc, output);
    }

    public void enrich(Document doc) {
        eu.enrich(doc);
    }

}
