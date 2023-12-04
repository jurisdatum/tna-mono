package uk.gov.legislation.cites.gate;

import net.sf.saxon.s9api.*;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

public class GateXMLPreparer {

    static final String stylesheet = "/prepare-gate.xsl";

    private final XsltExecutable executable;

    public GateXMLPreparer(Processor processor) {
        XsltCompiler compiler = processor.newXsltCompiler();
        InputStream stream = this.getClass().getResourceAsStream(stylesheet);
        Source source = new StreamSource(stream, "prepare-gate.xsl");
        try {
            executable = compiler.compile(source);
        } catch (SaxonApiException e) {
            throw new RuntimeException(e);
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

    private void prepare(InputStream input, OutputStream output) {
        Source source = new StreamSource(input);
        Serializer serializer = executable.getProcessor().newSerializer(output);
        transform(source, serializer);
    }

    public byte[] prepare(byte[] clml) {
        ByteArrayInputStream input = new ByteArrayInputStream(clml);
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        prepare(input, output);
        return output.toByteArray();
    }

}
