package uk.gov.legislation.clml;

import java.util.LinkedList;
import java.util.List;

import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

class ErrorHandler implements org.xml.sax.ErrorHandler {

	List<SAXException> errors = new LinkedList<SAXException>();
	
	@Override
	public void warning(SAXParseException exception) throws SAXException {
		errors.add(exception);
	}

	@Override
	public void error(SAXParseException exception) throws SAXException {
		errors.add(exception);
	}

	@Override
	public void fatalError(SAXParseException exception) throws SAXException {
		errors.add(exception);
	}

}