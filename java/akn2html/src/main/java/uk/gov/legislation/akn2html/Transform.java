package uk.gov.legislation.akn2html;

import net.sf.saxon.lib.ResourceRequest;
import net.sf.saxon.lib.ResourceResolver;
import net.sf.saxon.s9api.*;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

@Deprecated
public class Transform {

    private static final String stylesheet = "/transform/akn2html.xsl";

    private static class Resolver implements ResourceResolver {
        @Override
        public Source resolve(ResourceRequest request) {
            String filename = request.uri.substring(request.uri.lastIndexOf('/') + 1);
            InputStream file = this.getClass().getResourceAsStream("/transform/" + filename);
            return new StreamSource(file, filename);
        }
    }

    private final XsltExecutable executable;

    public Transform() {
        this(new Processor(false));
    }
    public Transform(Processor processor) {
        XsltCompiler compiler = processor.newXsltCompiler();
        compiler.setResourceResolver(new Resolver());
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

    private void transform(Source clml, Destination destination, String cssPath) {
        XsltTransformer transform = executable.load();
        if (cssPath != null)
            transform.setParameter(new QName("css-path"), XdmValue.makeValue(cssPath));
        try {
            transform.setSource(clml);
            transform.setDestination(destination);
            transform.transform();
        } catch (SaxonApiException e) {
            throw new RuntimeException(e);
        }
    }
    private void transform(Source clml, Destination destination) {
        XsltTransformer transform = executable.load();
        try {
            transform.setSource(clml);
            transform.setDestination(destination);
            transform.transform();
        } catch (SaxonApiException e) {
            throw new RuntimeException(e);
        }
    }

    public void transform(InputStream akn, OutputStream html) {
        Source source = new StreamSource(akn);
        Serializer serializer = executable.getProcessor().newSerializer(html);
        transform(source, serializer);
    }

    public byte[] transform(XdmNode akn) {
        ByteArrayOutputStream html = new ByteArrayOutputStream();
        Serializer serializer = executable.getProcessor().newSerializer(html);
        transform(akn.asSource(), serializer);
        return html.toByteArray();
    }
    public byte[] transform(XdmNode akn, String cssPath) {
        ByteArrayOutputStream html = new ByteArrayOutputStream();
        Serializer serializer = executable.getProcessor().newSerializer(html);
        transform(akn.asSource(), serializer, cssPath);
        return html.toByteArray();
    }

}
