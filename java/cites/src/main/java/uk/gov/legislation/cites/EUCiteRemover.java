package uk.gov.legislation.cites;

import net.sf.saxon.s9api.*;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import java.io.*;
import java.nio.charset.StandardCharsets;

public class EUCiteRemover {

    static final String stylesheet = "/remove-cites.xsl";

    private final XsltExecutable executable;

    public EUCiteRemover() {
        Processor processor = new Processor(false);
        XsltCompiler compiler = processor.newXsltCompiler();
        InputStream stream = this.getClass().getResourceAsStream(stylesheet);
        Source source = new StreamSource(stream, "remove-cites.xsl");
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

    public void remove(InputStream input, OutputStream output) {
        Source source = new StreamSource(input);
        Serializer serializer = executable.getProcessor().newSerializer(output);
        trnasform(source, serializer);
    }

    public byte[] remove(byte[] clml) {
        ByteArrayInputStream input = new ByteArrayInputStream(clml);
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        remove(input, output);
        return output.toByteArray();
    }

}
