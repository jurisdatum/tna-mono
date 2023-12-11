package uk.gov.legislation.clml2akn91;

import net.sf.saxon.s9api.*;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;
import java.io.*;
import java.util.Map;

public class Akn2Html91 {

    private static final String stylesheet = "/akn2html/transform/akn2html.xsl";

    private static class Importer implements URIResolver {
        @Override public Source resolve(String href, String base) throws TransformerException {
            InputStream file = this.getClass().getResourceAsStream("/akn2html/transform/" + href);
            return new StreamSource(file, href);
        }
    }

    private final XsltExecutable executable;

    public Akn2Html91(Processor processor) {
        XsltCompiler compiler = processor.newXsltCompiler();
        compiler.setURIResolver(new Importer());
        InputStream stream = this.getClass().getResourceAsStream(stylesheet);
        Source source = new StreamSource(stream, "akn2html.xsl");
        try {
            executable = compiler.compile(source);
        } catch (SaxonApiException e) {
            throw new RuntimeException(e);
        } finally {
            try { stream.close(); } catch (IOException e) { }
        }
    }
    public Akn2Html91() {
        this(Saxon.processor);
    }

//    public Destination load(Destination html) {
//        XsltTransformer transform = executable.load();
//        transform.setDestination(html);
//        return transform;
//    }

    private void transform(Source akn, Destination html, String cssPath) {
        XsltTransformer transform = executable.load();
        if (cssPath != null)
            transform.setParameter(new QName("css-path"), XdmValue.makeValue(cssPath));
        try {
            transform.setSource(akn);
            transform.setDestination(html);
            transform.transform();
        } catch (SaxonApiException e) {
            throw new RuntimeException(e);
        }
    }

    public String transform(XdmNode akn, String cssPath) throws IOException {
        StringWriter html = new StringWriter();
        Serializer serializer = executable.getProcessor().newSerializer(html);
        serializer.setOutputProperty(Serializer.Property.METHOD, "html");
        serializer.setOutputProperty(Serializer.Property.HTML_VERSION, "5");
        transform(akn.asSource(), serializer, cssPath);
        html.close();
        return html.toString();
    }

//    Serializer makeSerializer(Processor processor) {
//        Serializer serializer = executable.getProcessor().newSerializer(html);
//        serializer.setOutputProperty(Serializer.Property.METHOD, "html");
//        serializer.setOutputProperty(Serializer.Property.HTML_VERSION, "5");
//        return serializer;
//    }

    public void transform(InputStream akn, OutputStream html, String cssPath) {
        Source source = new StreamSource(akn);
        Serializer serializer = executable.getProcessor().newSerializer(html);
        serializer.setOutputProperty(Serializer.Property.METHOD, "html");
        serializer.setOutputProperty(Serializer.Property.HTML_VERSION, "5");
        transform(source, serializer, cssPath);
    }

}
