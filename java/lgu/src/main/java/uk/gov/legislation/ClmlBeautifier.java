package uk.gov.legislation;

import net.sf.saxon.Configuration;
import net.sf.saxon.s9api.*;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

public class ClmlBeautifier {

    private static final String stylesheet = "/beautify.xsl";

    private final XsltExecutable executable;


    public ClmlBeautifier() {
        Processor processor = new Processor(new Z());
        XsltCompiler compiler = processor.newXsltCompiler();
        InputStream stream = this.getClass().getResourceAsStream(stylesheet);
        Source source = new StreamSource(stream, "beautify.xsl");
        try {
            executable = compiler.compile(source);
        } catch (SaxonApiException e) {
            throw new RuntimeException(e);
        } finally {
            try { stream.close(); } catch (IOException e) { }
        }
    }

    private void transform(Source source, Destination destination) {
        XsltTransformer transform = executable.load();
        try {
            transform.setSource(source);
            transform.setDestination(destination);
            transform.transform();
        } catch (SaxonApiException e) {
            throw new RuntimeException(e);
        }
    }

    public void transform(InputStream input, OutputStream output) {
        Source source = new StreamSource(input);
        Serializer serializer = executable.getProcessor().newSerializer(output);
        transform(source, serializer);
    }

    public String transform(String input) {
        ByteArrayInputStream bais = new ByteArrayInputStream(input.getBytes());
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        transform(bais, baos);
        return baos.toString(StandardCharsets.UTF_8);
    }

    private static class X extends net.sf.saxon.serialize.XMLEmitter {
        @Override
        protected void writeAttributeIndentString() throws IOException {
            writer.write(" ");
        }
    }

    private static class Y extends net.sf.saxon.lib.SerializerFactory {
        public Y(Configuration config) {
            super(config);
        }
        @Override
        protected net.sf.saxon.serialize.Emitter newXMLEmitter(Properties properties) {
            return new X();
        }
    }

    private static class Z extends Configuration {
        @Override
        public net.sf.saxon.lib.SerializerFactory getSerializerFactory() {
            return new Y(this);
        }

    }

}
