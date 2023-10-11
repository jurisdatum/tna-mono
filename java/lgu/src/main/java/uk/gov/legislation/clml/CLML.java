package uk.gov.legislation.clml;

import java.util.LinkedHashMap;
import java.util.Map;

public class CLML {
	
	public static final String ukmURI = "http://www.legislation.gov.uk/namespaces/metadata";
	
	static final Map<String, String> namespaces = new LinkedHashMap<>();
	static {
		namespaces.put("", "http://www.legislation.gov.uk/namespaces/legislation");
		namespaces.put("ukl", "http://www.legislation.gov.uk/namespaces/legislation");
		namespaces.put("ukm", "http://www.legislation.gov.uk/namespaces/metadata");
		namespaces.put("dc", "http://purl.org/dc/elements/1.1/");
		namespaces.put("dct", "http://purl.org/dc/terms/");
		namespaces.put("atom", "http://www.w3.org/2005/Atom");
		namespaces.put("math", "http://www.w3.org/1998/Math/MathML");
		namespaces.put("html", "http://www.w3.org/1999/xhtml");
	}
	
	public static Map<String, String> getNamespaces() {
		return new LinkedHashMap<>(namespaces);
	}

}
