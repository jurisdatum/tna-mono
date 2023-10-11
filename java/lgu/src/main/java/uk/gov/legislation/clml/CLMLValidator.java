package uk.gov.legislation.clml;

import java.io.IOException;
import java.io.PrintStream;
import java.util.List;

import javax.xml.XMLConstants;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

public class CLMLValidator {
	
	private static final String schema = "/CLML/schema/legislation.xsd";
	private javax.xml.validation.Validator validator;
	
	public CLMLValidator() {
        SchemaFactory factory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
        factory.setResourceResolver(new CLMLLocator());
		Source source = new StreamSource(CLMLValidator.class.getResourceAsStream(schema));
        Schema schema;
		try {
			schema = factory.newSchema(source);
		} catch (SAXException e) {
			throw new RuntimeException(e);
		}
		validator = schema.newValidator();
	}

	public List<SAXException> validate(Source clml) {
		ErrorHandler errorHandler = new ErrorHandler();
		validator.setErrorHandler(errorHandler);
		try {
			validator.validate(clml);
		} catch (SAXException | IOException e) {
			throw new RuntimeException(e);
		}
		return errorHandler.errors;
	}
	
	public static void printErrors(List<SAXException> errors, PrintStream out) {
		for (SAXException error : errors) {
			if (error instanceof SAXParseException) {
				out.print("line ");
				out.print(((SAXParseException) error).getLineNumber());
				out.print(", column ");
				out.print(((SAXParseException) error).getColumnNumber());
				out.print(", ");
			}
			out.println(error.getLocalizedMessage());
		}
	}

}
