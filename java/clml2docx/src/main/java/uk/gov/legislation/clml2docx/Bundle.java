package uk.gov.legislation.clml2docx;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.logging.Logger;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.stream.StreamResult;

import net.sf.saxon.s9api.XdmNode;

public class Bundle {
	
	XdmNode document;
	XdmNode coreProperties;
	XdmNode styles;
	XdmNode[] headers;
	XdmNode[] footers;
	XdmNode footnotes;
	XdmNode relationships;
	XdmNode footnoteRelationships;
	Map<String, byte[]> resources = new LinkedHashMap<>();
	
	private final String[] components = new String[] {
		"_rels/.rels",
//		"word/settings.xml",
//		"word/webSettings.xml",
		"[Content_Types].xml"
	};
	
	private ByteArrayOutputStream baos;
	private ZipOutputStream zip;
		
	byte[] bundle() throws IOException {
		baos = new ByteArrayOutputStream();
		zip = new ZipOutputStream(baos);
		addComponents();
		addCoreProperties();
		addDocument();
		addStyles();
		addHeadersAndFooters();
		addFootnotes();
		addRelationships();
		addFootnoteRelationships();
		addResources();
		zip.close();
		return baos.toByteArray();
	}
	
	private static byte[] read(InputStream input) throws IOException {
		ByteArrayOutputStream buffer = new ByteArrayOutputStream();
	    int nRead;
	    byte[] data = new byte[1024];
	    while ((nRead = input.read(data, 0, data.length)) != -1) {
	        buffer.write(data, 0, nRead);
	    }
	    input.close();
	    buffer.flush();
	    return buffer.toByteArray();		
	}
	
	private void addComponents() throws IOException {
		Logger.getGlobal().info("bundling static components");
		for (String component : components) {
			Logger.getGlobal().info("bundling " + component);
			InputStream input = this.getClass().getResourceAsStream("/components/" + component);
			byte[] data = read(input);
			zip.putNextEntry(new ZipEntry(component));
	        zip.write(data, 0, data.length);
	        zip.closeEntry();
		}
	}
	
	private void addCoreProperties() throws IOException {
		Logger.getGlobal().info("bundling core properties");
		zip.putNextEntry(new ZipEntry("docProps/core.xml"));
		serialize(coreProperties, zip);
		zip.closeEntry();
	}
	
	private void addDocument() throws IOException {
		Logger.getGlobal().info("bundling document");
		zip.putNextEntry(new ZipEntry("word/document.xml"));
		serialize(document, zip);
		zip.closeEntry();
	}
	
	private void addStyles() throws IOException {
		Logger.getGlobal().info("bundling styles");
		zip.putNextEntry(new ZipEntry("word/styles.xml"));
		serialize(styles, zip);
		zip.closeEntry();
	}

	private void addHeadersAndFooters() throws IOException {
		for (int i = 0; i < headers.length; i++) {
			int n = i + 1;
			Logger.getGlobal().info("bundling header " + n);
			zip.putNextEntry(new ZipEntry("word/header" + n + ".xml"));
			serialize(headers[i], zip);
			zip.closeEntry();
		}
		for (int i = 0; i < footers.length; i++) {
			int n = i + 1;
			Logger.getGlobal().info("bundling footer " + n);
			zip.putNextEntry(new ZipEntry("word/footer" + n + ".xml"));
			serialize(footers[i], zip);
			zip.closeEntry();
		}
	}

	private void addFootnotes() throws IOException {
		Logger.getGlobal().info("bundling footnotes");
		zip.putNextEntry(new ZipEntry("word/footnotes.xml"));
		serialize(footnotes, zip);
		zip.closeEntry();
	}

	private void addRelationships() throws IOException {
		Logger.getGlobal().info("bundling relationships");
		zip.putNextEntry(new ZipEntry("word/_rels/document.xml.rels"));
		serialize(relationships, zip);
		zip.closeEntry();
	}

	private void addFootnoteRelationships() throws IOException {
		Logger.getGlobal().info("bundling footnote relationships");
		zip.putNextEntry(new ZipEntry("word/_rels/footnotes.xml.rels"));
		serialize(footnoteRelationships, zip);
		zip.closeEntry();
	}

	private void addResources() throws IOException {
		Logger.getGlobal().info("bundling resources");
		for (Entry<String, byte[]> image : resources.entrySet()) {
			String filename = image.getKey();
			Logger.getGlobal().info("bundling " + filename);
			zip.putNextEntry(new ZipEntry("word/media/" + filename));
			byte[] data = image.getValue();
			zip.write(data, 0, data.length);
			zip.closeEntry();
		}
	}
	
	public static void serialize(XdmNode document, OutputStream output) {
		Transformer transformer;
		try {
			transformer = TransformerFactory.newInstance().newTransformer();
		} catch (TransformerConfigurationException | TransformerFactoryConfigurationError e) {
			throw new RuntimeException(e);
		}
		transformer.setOutputProperty(OutputKeys.INDENT, "yes");
		try {
			transformer.transform(document.asSource(), new StreamResult(output));
		} catch (TransformerException e) {
			throw new RuntimeException(e);
		}
	}

}
