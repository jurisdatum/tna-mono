package uk.gov.legislation.cites;

import net.sf.saxon.s9api.*;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import java.io.*;
import java.nio.charset.StandardCharsets;

public class EUCiteRemover {

    static final String xslt = "<?xml version='1.0'?>\n" +
            "<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='1.0'>\n" +
            "  <xsl:template match=\"*:Citation[starts-with(@Class,'European')]\">\n" +
            "      <xsl:apply-templates />\n" +
            "  </xsl:template>\n" +
            "  <xsl:template match='@*|node()'>\n" +
            "    <xsl:copy>\n" +
            "      <xsl:apply-templates select='@*|node()'/>\n" +
            "    </xsl:copy>\n" +
            "  </xsl:template>\n" +
            "</xsl:stylesheet>\n";

    private final XsltExecutable executable;

    public EUCiteRemover() {
        Processor processor = new Processor(false);
        XsltCompiler compiler = processor.newXsltCompiler();
        InputStream stream = new ByteArrayInputStream(xslt.getBytes(StandardCharsets.UTF_8));
        Source source = new StreamSource(stream, "remove-eu-cites");
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
