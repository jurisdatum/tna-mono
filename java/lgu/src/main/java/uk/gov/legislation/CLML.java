package uk.gov.legislation;

import net.sf.saxon.s9api.*;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class CLML {

	private static final Map<String, String> namespaces = new HashMap<>();
	static {
		namespaces.put("", "http://www.legislation.gov.uk/namespaces/legislation");
		namespaces.put("leg", "http://www.legislation.gov.uk/namespaces/legislation");
		namespaces.put("ukm", "http://www.legislation.gov.uk/namespaces/metadata");
		namespaces.put("dc", "http://purl.org/dc/elements/1.1/");
		namespaces.put("dct", "http://purl.org/dc/terms/");
		namespaces.put("atom", "http://www.w3.org/2005/Atom");
		namespaces.put("html", "http://www.w3.org/1999/xhtml");
		namespaces.put("math", "http://www.w3.org/1998/Math/MathML");
	}

	public static class NoDocumentException extends RuntimeException {
		public final int responseCode;
		public NoDocumentException(int responseCode) { this.responseCode = responseCode; }
	}

	public static class NoClmlException extends RuntimeException { }

	public static byte[] getBytes(String id) throws IOException {
		if (id.startsWith("http://www.legislation.gov.uk/id/"))
			id = id.substring(33);
		StringBuilder url = new StringBuilder("https://www.legislation.gov.uk/");
		url.append(id);
		url.append("/data.xml");
		return getBytes(new URL(url.toString()));
	}

	private static byte[] getBytes(URL url) throws IOException, NoDocumentException, NoClmlException {
		HttpURLConnection connection = (HttpURLConnection) url.openConnection();
		connection.addRequestProperty("User-Agent", "Juris Datum");
		connection.connect();
		try {
			int responseCode = connection.getResponseCode();
			if (responseCode != 200)
				throw new NoDocumentException(responseCode);
			if (!connection.getHeaderField("Content-Type").startsWith("application/xml"))
				throw new NoClmlException();
			byte[] clml;
			InputStream stream = connection.getInputStream();
			try {
				clml = stream.readAllBytes();
			} finally {
				stream.close();
			}
			return clml;
		} finally {
			connection.disconnect();
		}
	}

	private final XPathCompiler compiler;

	private final XdmNode root;

	public CLML(byte[] xml) throws SaxonApiException {
		Processor processor = new Processor(false);
		compiler = processor.newXPathCompiler();
		for (Map.Entry<String, String> namespace : namespaces.entrySet())
			compiler.declareNamespace(namespace.getKey(), namespace.getValue());
		Source source = new StreamSource(new ByteArrayInputStream(xml));
		root = processor.newDocumentBuilder().build(source);
	}

	public Set<String> getVersions() {
		XdmValue titles = Xpath.eval(compiler, root, "/Legislation/ukm:Metadata/atom:link[@rel='http://purl.org/dc/terms/hasVersion']/@title");
		if (!titles.isEmpty())
			return titles.stream().map(item -> item.getStringValue()).collect(Collectors.toSet());
		String href = Xpath.eval1(compiler, root, "/Legislation/ukm:Metadata/atom:link[@rel='self']/@href").getStringValue();
		String[] parts = href.split("/");
		return Collections.singleton( parts[parts.length-2] );
	}

}
