package uk.gov.legislation.cites.gate;

import net.sf.saxon.s9api.*;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

public class GateArtifactRemover {

    static final String stylesheet = "/remove-gate.xsl";

    private final XsltExecutable executable;

    public GateArtifactRemover() {
        Processor processor = new Processor(false);
        XsltCompiler compiler = processor.newXsltCompiler();
        InputStream stream = this.getClass().getResourceAsStream(stylesheet);
        Source source = new StreamSource(stream, "remove-gate.xsl");
        try {
            executable = compiler.compile(source);
        } catch (SaxonApiException e) {
            throw new RuntimeException(e);
        }
    }

    private void trnasform(Source source, Destination destination) {
        XsltTransformer transform = executable.load();
        try {
            transform.setSource(source);
            transform.setDestination(destination);
            transform.transform();
        } catch (SaxonApiException e) {
            throw new RuntimeException(e);
        }
    }

    private void remove(InputStream input, OutputStream output) {
        Source source = new StreamSource(input);
        Serializer serializer = executable.getProcessor().newSerializer(output);
        trnasform(source, serializer);
    }

    byte[] remove(String clml) {
        ByteArrayInputStream input = new ByteArrayInputStream(clml.getBytes(StandardCharsets.UTF_8));
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        remove(input, output);
        return output.toByteArray();
    }

}
