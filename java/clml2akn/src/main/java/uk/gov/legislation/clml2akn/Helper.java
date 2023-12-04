package uk.gov.legislation.clml2akn;

import net.sf.saxon.Configuration;
import net.sf.saxon.lib.SerializerFactory;
import net.sf.saxon.serialize.Emitter;

import java.io.IOException;
import java.util.Properties;

class Helper {

    static final Configuration DontIndentAttributes = new Z();

    private static class X extends net.sf.saxon.serialize.XMLEmitter {
        @Override
        protected void writeAttributeIndentString() throws IOException {
            writer.write(" ");
        }
    }

    private static class Y extends net.sf.saxon.lib.SerializerFactory {
        public Y(Configuration config) {
            super(config);
        }
        @Override
        protected Emitter newXMLEmitter(Properties properties) {
            return new X();
        }
    }

    private static class Z extends Configuration {
        @Override
        public SerializerFactory getSerializerFactory() {
            return new Y(this);
        }

    }

}
