package uk.gov.legislation.clml2akn;

import net.sf.saxon.lib.ResourceRequest;
import net.sf.saxon.lib.ResourceResolver;
import net.sf.saxon.s9api.*;

import javax.xml.transform.Source;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;
import java.io.*;

public class Transform {

    private static final String stylesheet = "/transform/clml2akn.xsl";

    private static class Resolver implements ResourceResolver {
        @Override
        public Source resolve(ResourceRequest request) {
            String filename = request.uri.substring(request.uri.lastIndexOf('/') + 1);
            InputStream file = this.getClass().getResourceAsStream("/transform/" + filename);
            return new StreamSource(file, filename);
        }
    }

    private final XsltExecutable executable;

    public Processor processor() { return executable.getProcessor(); }

    public Transform() {
        Processor processor = new Processor(false);
        XsltCompiler compiler = processor.newXsltCompiler();
        compiler.setResourceResolver(new Resolver());
        InputStream stream = this.getClass().getResourceAsStream(stylesheet);
        Source source = new StreamSource(stream, "clml2akn.xsl");
        try {
            executable = compiler.compile(source);
        } catch (SaxonApiException e) {
            throw new RuntimeException(e);
        } finally {
            try { stream.close(); } catch (IOException e) { }
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
    private XdmNode transform(Source source) {
        XdmDestination akn = new XdmDestination();
        transform(source, akn);
        return akn.getXdmNode();
    }

    public XdmNode transform(byte[] clml) {
        ByteArrayInputStream bais = new ByteArrayInputStream(clml);
        Source source = new StreamSource(bais);
        return transform(source);
    }

    public XdmNode transform(org.w3c.dom.Document doc) {
        Source source = new DOMSource(doc);
        return transform(source);
    }

    public void transform(InputStream clml, OutputStream akn) {
        Source source = new StreamSource(clml);
        Serializer serializer = executable.getProcessor().newSerializer(akn);
        transform(source, serializer);
    }

    public static byte[] serialize(XdmNode akn) throws SaxonApiException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        Serializer serializer = akn.getProcessor().newSerializer(baos);
        serializer.serializeNode(akn);
        return baos.toByteArray();
    }

}
