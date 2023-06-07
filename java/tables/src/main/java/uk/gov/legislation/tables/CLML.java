package uk.gov.legislation.tables;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.*;
import java.io.IOException;
import java.io.InputStream;

public class CLML {

    public static Document parse(InputStream clml) throws IOException, SAXException {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder;
        try {
            builder = factory.newDocumentBuilder();
        } catch (ParserConfigurationException e) {
            throw new RuntimeException(e);
        }
        return builder.parse(clml);
    }
    public static HtmlTable getTable(Document doc, int i) {
        XPath xpath = XPathFactory.newInstance().newXPath();
        NodeList elements;
        try {
            XPathExpression expr = xpath.compile("descendant::table");
            elements = (NodeList) expr.evaluate(doc, XPathConstants.NODESET);
        } catch (XPathExpressionException e) {
            throw new RuntimeException(e);
        }
        Element table = (Element) elements.item(i);
        if (table == null)
            return null;
        return new HtmlTable(table);
    }

}
