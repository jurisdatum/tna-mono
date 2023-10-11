package uk.gov.legislation.clml;

import java.io.InputStream;

import org.w3c.dom.bootstrap.DOMImplementationRegistry;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSInput;
import org.w3c.dom.ls.LSResourceResolver;

class CLMLLocator implements LSResourceResolver {
	
	private static final String[] paths = new String[]{
		"/CLML/schema/", "/CLML/schemaModules/", "/CLML/schemaModules/mathml2/",
		"/CLML/schemaModules/mathml2/common/", "/CLML/schemaModules/mathml2/content/", "/CLML/schemaModules/mathml2/presentation/"
	};
	
	private final DOMImplementationLS impl;
	
	CLMLLocator() {
		DOMImplementationRegistry registry;
		try {
			registry = DOMImplementationRegistry.newInstance();
		} catch (ClassNotFoundException | InstantiationException | IllegalAccessException | ClassCastException e) {
			throw new RuntimeException(e);
		}
		impl = (DOMImplementationLS)registry.getDOMImplementation("LS");
	}
	
	private InputStream findFile(String systemId) {
		for (String path : paths) {
			InputStream file = CLMLLocator.class.getResourceAsStream(path + systemId);
			if (file != null) return file;
		}
		return null;
	}

	@Override
	public LSInput resolveResource(String type, String namespaceURI, String publicId, String systemId, String baseURI) {
		InputStream stream = findFile(systemId);
		if (stream == null)
			throw new RuntimeException(systemId);
		LSInput input = impl.createLSInput();
		input.setSystemId(systemId);
		input.setBaseURI(baseURI);
		input.setByteStream(stream);
		return input;
	}
	
}