package uk.gov.legislation.clml2docx;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;

import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XPathCompiler;
import net.sf.saxon.s9api.XPathExecutable;
import net.sf.saxon.s9api.XPathSelector;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XdmDestination;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XdmValue;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;
import net.sf.saxon.value.ObjectValue;
import uk.gov.legislation.clml2docx.Delegate.Resource;

public class XSLT {
	
	static final String path = "/xslt/";
	
	private static final String stylesheet = "clml2docx.xsl";
	
	static class Importer implements URIResolver {

		public Source resolve(String href, String base) throws TransformerException {
			InputStream file = this.getClass().getResourceAsStream(path + href);
			return new StreamSource(file, href);
		}

	}
	
	private static XsltExecutable executable;
	private static XPathExecutable docType;
	private static XPathExecutable resourceURIs;
	
	
	XSLT(Delegate delegate) throws IOException {
		
		Processor processor = new Processor(false);
		
		processor.getUnderlyingConfiguration().registerExtensionFunction(new Functions.GetImageWidth(delegate));
		processor.getUnderlyingConfiguration().registerExtensionFunction(new Functions.GetImageHeight(delegate));
		processor.getUnderlyingConfiguration().registerExtensionFunction(new Functions.GetImageType(delegate));
		
		if (executable == null) {
			XsltCompiler xsltCompiler = processor.newXsltCompiler();
			xsltCompiler.setURIResolver(new Importer());
			InputStream stream = this.getClass().getResourceAsStream(path + stylesheet);
			Source source = new StreamSource(stream, stylesheet);
			try {
				executable = xsltCompiler.compile(source);
			} catch (SaxonApiException e) {
				throw new RuntimeException(e);
			} finally {
				stream.close();
			}
			XPathCompiler xPathCompiler = processor.newXPathCompiler();
			xPathCompiler.declareNamespace("", "http://www.legislation.gov.uk/namespaces/legislation");
			xPathCompiler.declareNamespace("ukm", "http://www.legislation.gov.uk/namespaces/metadata");
			try {
				docType = xPathCompiler.compile("/Legislation/ukm:Metadata/*/ukm:DocumentClassification/ukm:DocumentMainType/@Value");
				resourceURIs = xPathCompiler.compile("/Legislation/Resources/Resource/ExternalVersion/@URI");
			} catch (SaxonApiException e) {
				throw new RuntimeException(e);
			}
		}
	}

	public XdmNode coreProperties(XdmNode clml, Map<String, Resource> cache, boolean debug) {
		return callTemplate(clml, "core-properties", cache, debug);
	}

	private XsltTransformer loadAndSetParameters(Map<String, Resource> cache, boolean debug) {
		XsltTransformer transform = executable.load();
		transform.setParameter(new QName("cache"), XdmValue.makeValue( new ObjectValue<>(cache)));
		transform.setParameter(new QName("debug"), new XdmAtomicValue(debug));
		return transform;
	}

	private XdmNode transformToNode(XsltTransformer transform) {
		XdmDestination destination = new XdmDestination();
		transform.setDestination(destination);
		try {
			transform.transform();
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		}
		return destination.getXdmNode();
	}

	public XdmNode document(XdmNode clml, Map<String, Resource> cache, boolean debug) {
		XsltTransformer transform = loadAndSetParameters(cache, debug);
		transform.setInitialContextNode(clml);
		return transformToNode(transform);
	}

	private XdmNode callTemplate(XdmNode clml, String template, Map<String, Resource> cache, boolean debug) {
		XsltTransformer transform = loadAndSetParameters(cache, debug);
		transform.setInitialContextNode(clml);
		transform.setInitialTemplate(new QName(template));
		return transformToNode(transform);
	}
	
	public XdmNode styles(XdmNode clml, Map<String, Resource> cache, boolean debug) {
		return callTemplate(clml, "styles", cache, debug);
	}

	public XdmNode[] headers(XdmNode clml, Map<String, Resource> cache, boolean debug) {
		XdmNode[] headers = new XdmNode[3];
		headers[0] = callTemplate(clml, "header1", cache, debug);
		headers[1] = callTemplate(clml, "header2", cache, debug);
		headers[2] = callTemplate(clml, "header3", cache, debug);
		return headers;
	}
	public XdmNode[] footers(XdmNode clml, Map<String, Resource> cache, boolean debug) {
		XdmNode[] footers = new XdmNode[2];
		footers[0] = callTemplate(clml, "footer1", cache, debug);
		footers[1] = callTemplate(clml, "footer2", cache, debug);
		return footers;
	}

	public XdmNode footnotes(XdmNode clml, Map<String, Resource> cache, boolean debug) {
		return callTemplate(clml, "footnotes", cache, debug);
	}

	public XdmNode relationships(XdmNode clml, Map<String, Resource> cache, boolean debug) {
		return callTemplate(clml, "relationships", cache, debug);
	}

	public XdmNode footnoteRelationships(XdmNode clml, Map<String, Resource> cache, boolean debug) {
		return callTemplate(clml, "footnote-relationships", cache, debug);
	}


	String getDocumentMainType(XdmNode clml) {
		XPathSelector selector = docType.load();
		try {
			selector.setContextItem(clml);
		} catch (SaxonApiException e) {
			throw new IllegalArgumentException(e);
		}
		try {
			return selector.evaluateSingle().getStringValue();
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		}
	}

	List<String> getResourceURIs(XdmNode clml) {
		XPathSelector selector = resourceURIs.load();
		try {
			selector.setContextItem(clml);
		} catch (SaxonApiException e) {
			throw new IllegalArgumentException(e);
		}
		XdmValue uris;
		try {
			uris = selector.evaluate();
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		}
		return StreamSupport.stream(uris.spliterator(), false)
			.map(item -> item.getStringValue())
			.collect(Collectors.toList());	
	}
	
	Processor getProcessor() {
		return executable.getProcessor();
	}

}
