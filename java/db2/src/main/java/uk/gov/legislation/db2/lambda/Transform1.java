package uk.gov.legislation.db2.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.events.SQSEvent;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;
import org.xml.sax.SAXException;
import uk.gov.legislation.db2.files.EnrichedBucket;

import java.io.IOException;
import java.sql.SQLException;

public class Transform1 extends SWSEventHandler {

    uk.gov.legislation.clml2akn.Transform clml2akn = new uk.gov.legislation.clml2akn.Transform();
    uk.gov.legislation.akn2html.Transform akn2html = new uk.gov.legislation.akn2html.Transform(clml2akn.processor());

    @Override
    void processMessage(SQSEvent.SQSMessage message, Context context) throws SQLException, IOException, SAXException, SaxonApiException {
        LambdaLogger logger = context.getLogger();
        String id = message.getBody();
        logger.log("transforming " + id);
        byte[] clml = EnrichedBucket.getClml(id);
        logger.log("transforming to AkN");
        XdmNode akn = clml2akn.transform(clml);
        EnrichedBucket.saveAkn(id, uk.gov.legislation.clml2akn.Transform.serialize(akn));
        logger.log("transforming to HTML");
        byte[] html = akn2html.transform(akn);
        EnrichedBucket.saveHtml(id, html);
        logger.log("done");
    }

}
