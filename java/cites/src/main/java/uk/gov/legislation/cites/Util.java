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
import java.io.*;

public class Util {

    public static Document parse(byte[] bytes) throws IOException, SAXException {
        ByteArrayInputStream input = new ByteArrayInputStream(bytes);
        return parse(input);
    }
    public static Document parse(InputStream input) throws IOException, SAXException {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setNamespaceAware(true);
        DocumentBuilder builder;
        try {
            builder = factory.newDocumentBuilder();
        } catch (ParserConfigurationException e) {
            throw new RuntimeException(e);
        }
        return builder.parse(input);
    }

    public static byte[] serialize(Document xml) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        serialize(xml, baos);
        return baos.toByteArray();
    }

    public static void serialize(Document xml, OutputStream output) {
        DOMSource source = new DOMSource(xml);
        StreamResult result = new StreamResult(output);
        try {
            Transformer transformer = TransformerFactory.newInstance().newTransformer();
            transformer.transform(source, result);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }
    }

}
