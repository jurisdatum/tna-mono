package uk.gov.legislation.clml2docx;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.xml.transform.stream.StreamSource;

import net.sf.saxon.s9api.DocumentBuilder;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;
import uk.gov.legislation.clml2docx.Delegate.Resource;

public class Transform {
	
	private final Delegate delegate;
	private final XSLT xslt;
	
	public Transform(Delegate delegate) throws IOException {
		this.delegate = delegate;
		this.xslt = new XSLT(delegate);
	}
	public Transform() throws IOException {
		this.delegate = new LGUDelegate();
		this.xslt = new XSLT(delegate);
	}
	
	private LinkedHashMap<String, byte[]> fetchResources(List<String> resourceURIs, Map<String, Resource> cache) throws IOException {
		LinkedHashMap<String, byte[]> resources = new LinkedHashMap<>();
		for (String uri : resourceURIs) {
			Resource resource;
			try {
				resource = delegate.fetch(uri, cache);
			} catch (IOException e) {
				continue;
			}
			String filename = uri.substring(uri.lastIndexOf('/') + 1);
			if (resource.contentType.equals("image/gif"))
				filename += ".gif";
			else if (resource.contentType.equals("image/jpeg") || resource.contentType.equals("image/jpg"))
				filename += ".jpg";
			else
				throw new RuntimeException(resource.contentType);
			resources.put(filename, resource.content);
		}
		return resources;
	}
	
	private Map<String, byte[]> fetchResources(XdmNode clml, Map<String, Resource> cache) throws IOException {
		List<String> resourceURIs = xslt.getResourceURIs(clml);
		LinkedHashMap<String, byte[]> resources = fetchResources(resourceURIs, cache);
		final String crest;
		switch (xslt.getDocumentMainType(clml)) {
			case "UnitedKingdomPublicGeneralAct":
			case "UnitedKingdomLocalAct":
			case "UnitedKingdomChurchMeasure":
			case "NorthernIrelandAct":
			case "EnglandAct":
			case "IrelandAct":
			case "GreatBritainAct":
			case "NorthernIrelandAssemblyMeasure": // note really clear
			case "NorthernIrelandParliamentAct": // note really clear
				crest = "ukpga.png";
				break;
			case "ScottishAct":
			case "ScottishOldAct":
				crest = "asp.png";
				break;
			case "WelshParliamentAct":
			case "WelshNationalAssemblyAct":
			case "WelshAssemblyMeasure":	// need to check
				crest = "asc.png";
				break;
			default:
				crest = null;
		}
		if (crest != null) {
			InputStream input = getClass().getResourceAsStream("/images/" + crest);
			byte[] image = Util.read(input);
			resources.put("crest.png", image);
		}
		return resources;
	}
	
	public byte[] transform(XdmNode clml, boolean debug) throws IOException {
		Bundle bundle = new Bundle();
		Map<String, Resource> cache = new HashMap<>();
		bundle.coreProperties = xslt.coreProperties(clml, cache, debug);
		bundle.document = xslt.document(clml, cache, debug);
		bundle.styles = xslt.styles(clml, cache, debug);
		bundle.headers = xslt.headers(clml, cache, debug);
		bundle.footers =  xslt.footers(clml, cache, debug);
		bundle.footnotes = xslt.footnotes(clml, cache, debug);
		bundle.relationships = xslt.relationships(clml, cache, debug);
		bundle.footnoteRelationships = xslt.footnoteRelationships(clml, cache, debug);
		bundle.resources = fetchResources(clml, cache);
		return bundle.bundle();		
	}
	
	public XdmNode parse(InputStream clml) throws IOException, SaxonApiException {
		DocumentBuilder builder = xslt.getProcessor().newDocumentBuilder();
		XdmNode document = builder.build(new StreamSource(clml));
		clml.close();
		return document;
	}
	
	public byte[] transform(InputStream clml, boolean debug) throws IOException, SaxonApiException {
		XdmNode doc = parse(clml);
		return transform(doc, debug);
	}
	public byte[] transform(InputStream clml) throws IOException, SaxonApiException {
		return transform(clml, false);
	}

}
