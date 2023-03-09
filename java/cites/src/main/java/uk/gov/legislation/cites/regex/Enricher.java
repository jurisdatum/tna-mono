package uk.gov.legislation.cites.regex;

import org.w3c.dom.Document;
import org.xml.sax.SAXException;
import uk.gov.legislation.cites.Util;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class Enricher {

    private final EURegexEnricher eu = new EURegexEnricher();
    private final UKRegexEnricher uk = new UKRegexEnricher();
    private final SuccessiveEnricher successive = new SuccessiveEnricher();

    public void enrich(InputStream input, OutputStream output) throws IOException, SAXException {
        Document doc = Util.parse(input);
        enrich(doc);
        Util.serialize(doc, output);
    }

    public void enrich(Document doc) {
        uk.enrich(doc);
        eu.enrich(doc);
        successive.enrich(doc);
    }

}
