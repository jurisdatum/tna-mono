package uk.gov.legislation.clml2akn91;

import net.sf.saxon.Configuration;
import net.sf.saxon.event.Emitter;
import net.sf.saxon.event.PipelineConfiguration;
import net.sf.saxon.event.Receiver;
import net.sf.saxon.s9api.Destination;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.trans.XPathException;

import javax.xml.transform.Result;
import java.util.Properties;

public class Helper {

    public static final Processor processor = new Processor(false);
    public static class SerializerFactory extends net.sf.saxon.event.SerializerFactory {

        @Override
        protected Emitter newXMLEmitter() {
            return new XMLEmitter();
        }

    }

    static {
        processor.getUnderlyingConfiguration().setSerializerFactory(new SerializerFactory());
    }

    public static Destination makeDestination(Result result, Properties props) {
        return new Destination() {
            public Receiver getReceiver(Configuration config) throws SaxonApiException {
                PipelineConfiguration pipe = new PipelineConfiguration();
                pipe.setConfiguration(config);
                try {
                    return config.getSerializerFactory().getReceiver(result, pipe, props);
                } catch (XPathException e) {
                    throw new RuntimeException(e);
                }
            }
        };
    }

    public static final Properties aknProperties = new Properties();
    static {
        aknProperties.setProperty(Serializer.Property.INDENT.toString(), "yes");
    }

    public static final Properties html5properties = new Properties();
    static {
        html5properties.setProperty(Serializer.Property.METHOD.toString(), "html");
//		properties.setProperty(Property.VERSION.toString(), "5");
        html5properties.setProperty(Serializer.Property.INCLUDE_CONTENT_TYPE.toString(), "no");
        html5properties.setProperty(Serializer.Property.INDENT.toString(), "yes");
    }

}
