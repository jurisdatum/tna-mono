package uk.gov.legislation.clml2docx;

import java.io.IOException;
import java.util.Map;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.EmptySequence;
import net.sf.saxon.value.Int64Value;
import net.sf.saxon.value.ObjectValue;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;
import uk.gov.legislation.clml2docx.Delegate.Resource;

public class Functions {

	public static final String namespacePrefix = "clml2docx";
	public static final String namespaceURI = "https://www.legislation.gov.uk/namespaces/clml2docx";

	public static class GetImageWidth extends ExtensionFunctionDefinition {
		
		private final Delegate delegate;
		
		public GetImageWidth(Delegate delegate) {
			this.delegate = delegate;
		}
	
		@Override
		public StructuredQName getFunctionQName() {
			return new StructuredQName(namespacePrefix, namespaceURI, "get-image-width");
		}
	
		@Override
		public SequenceType[] getArgumentTypes() {
			return new SequenceType[] { SequenceType.SINGLE_STRING, SequenceType.SINGLE_ITEM };
		}
	
		@Override
		public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
			return SequenceType.OPTIONAL_INTEGER;
		}
	
		@Override
		public ExtensionFunctionCall makeCallExpression() {
			return new ExtensionFunctionCall() {
				@SuppressWarnings("rawtypes")
				public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
					String uri = ((StringValue) arguments[0]).getStringValue();
					@SuppressWarnings("unchecked")
					Map<String, Resource> cache = ((ObjectValue<Map<String, Resource>>) arguments[1]).getObject();
					Resource resource;
					try {
						resource = delegate.fetch(uri, cache);
					} catch (IOException e) {
						return EmptySequence.getInstance();
					}
					int width;
					try {
						width = resource.getImageWidth();
					} catch (IOException e) {
						return EmptySequence.getInstance();
					}
					return new Int64Value(width);
				}
			};
		}
	
	}

	public static class GetImageHeight extends ExtensionFunctionDefinition {
		
		private final Delegate delegate;
		
		public GetImageHeight(Delegate delegate) {
			this.delegate = delegate;
		}
	
		@Override
		public StructuredQName getFunctionQName() {
			return new StructuredQName(namespacePrefix, namespaceURI, "get-image-height");
		}
	
		@Override
		public SequenceType[] getArgumentTypes() {
			return new SequenceType[] { SequenceType.SINGLE_STRING, SequenceType.SINGLE_ITEM };
		}
	
		@Override
		public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
			return SequenceType.OPTIONAL_INTEGER;
		}
	
		@Override
		public ExtensionFunctionCall makeCallExpression() {
			return new ExtensionFunctionCall() {
				@SuppressWarnings("rawtypes")
				public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
					String uri = ((StringValue) arguments[0]).getStringValue();
					@SuppressWarnings("unchecked")
					Map<String, Resource> cache = ((ObjectValue<Map<String, Resource>>) arguments[1]).getObject();
					Resource resource;
					try {
						resource = delegate.fetch(uri, cache);
					} catch (IOException e) {
						return EmptySequence.getInstance();
					}
					int height;
					try {
						height = resource.getImageHeight();
					} catch (IOException e) {
						return EmptySequence.getInstance();
					}
					return new Int64Value(height);
				}
			};
		}
	
	}

	public static class GetImageType extends ExtensionFunctionDefinition {
		
		private final Delegate delegate;
		
		public GetImageType(Delegate delegate) {
			this.delegate = delegate;
		}
	
		@Override
		public StructuredQName getFunctionQName() {
			return new StructuredQName(namespacePrefix, namespaceURI, "get-image-type");
		}
	
		@Override
		public SequenceType[] getArgumentTypes() {
			return new SequenceType[] { SequenceType.SINGLE_STRING, SequenceType.SINGLE_ITEM };
		}
	
		@Override
		public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
			return SequenceType.OPTIONAL_STRING;
		}
	
		@Override
		public ExtensionFunctionCall makeCallExpression() {
			return new ExtensionFunctionCall() {
				@SuppressWarnings("rawtypes")
				public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
					String uri = arguments[0].iterate().next().getStringValue();
					@SuppressWarnings("unchecked")
					Map<String, Resource> cache = ((ObjectValue<Map<String, Resource>>) arguments[1]).getObject();
					Resource resource;
					try {
						resource = delegate.fetch(uri, cache);
					} catch (IOException e) {
						return EmptySequence.getInstance();
					}
					String contentType = resource.contentType;
					if (contentType == null)
						return EmptySequence.getInstance();
					return new StringValue(contentType);
				}
			};
		}
	
	}

}
