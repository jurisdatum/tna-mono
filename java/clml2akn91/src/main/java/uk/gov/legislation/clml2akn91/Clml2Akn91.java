package uk.gov.legislation.clml2akn91;

import java.io.*;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;

import net.sf.saxon.s9api.*;

public class Clml2Akn91 {

	private static final String stylesheet = "/clml2akn/transform/clml2akn.xsl";

	private static class Importer implements URIResolver {
		@Override public Source resolve(String href, String base) throws TransformerException {
			InputStream file = this.getClass().getResourceAsStream("/clml2akn/transform/" + href);
			return new StreamSource(file, href);
		}
	}

	private final XsltExecutable executable;

	public Processor getProcessor() { return executable.getProcessor(); }

	public Clml2Akn91() {
		XsltCompiler compiler = Saxon.processor.newXsltCompiler();
		compiler.setURIResolver(new Importer());
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

	public XdmNode transform(InputStream clml) {
		Source source = new StreamSource(clml);
		XdmDestination destination = new XdmDestination();
		transform(source, destination);
		return destination.getXdmNode();
	}
	public XdmNode transform(String clml) {
		ByteArrayInputStream stream = new ByteArrayInputStream(clml.getBytes());
		return transform(stream);
	}

	public void transform(InputStream clml, OutputStream akn) {
		Source source = new StreamSource(clml);
		Serializer serializer = executable.getProcessor().newSerializer(akn);
		serializer.setOutputProperty(Serializer.Property.INDENT, "yes");
		serializer.setOutputProperty(Serializer.Property.SAXON_SUPPRESS_INDENTATION, "{http://docs.oasis-open.org/legaldocml/ns/akn/3.0}p");
		transform(source, serializer);
	}

	public static void serialize(XdmNode akn, OutputStream out) throws SaxonApiException {
		Serializer serializer = akn.getProcessor().newSerializer(out);
		serializer.setOutputProperty(Serializer.Property.INDENT, "yes");
		serializer.setOutputProperty(Serializer.Property.SAXON_SUPPRESS_INDENTATION, "{http://docs.oasis-open.org/legaldocml/ns/akn/3.0}p");
		serializer.serializeNode(akn);
	}

}
