package uk.gov.legislation.db2.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.events.SQSEvent;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;
import org.xml.sax.SAXException;
import uk.gov.legislation.cites.EmbeddedCite;
import uk.gov.legislation.cites.Enricher;
import uk.gov.legislation.cites.Extractor;
import uk.gov.legislation.cites.Util;
import uk.gov.legislation.clml2akn.Transform;
import uk.gov.legislation.db2.files.EnrichedBucket;
import uk.gov.legislation.db2.files.LGUCache;
import uk.gov.legislation.db2.rds.Citations;
import uk.gov.legislation.db2.rds.Document;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class Enrich1 extends SWSEventHandler {

    Enricher enricher = new Enricher();
    uk.gov.legislation.clml2akn.Transform clml2akn = new uk.gov.legislation.clml2akn.Transform();
    uk.gov.legislation.akn2html.Transform akn2html = new uk.gov.legislation.akn2html.Transform(clml2akn.processor());

    @Override
    void processMessage(SQSEvent.SQSMessage message, Context context) throws SQLException, IOException, SAXException, SaxonApiException {
        LambdaLogger logger = context.getLogger();
        String id = message.getBody();
        logger.log("enriching " + id);
        Document leg = Document.get(id);
        if (leg == null) {
            logger.log(id + " does not exists");
            return;
        }
        byte[] clml = LGUCache.getClml(id);
        org.w3c.dom.Document doc = Util.parse(clml);
        enricher.enrich(doc);
        EnrichedBucket.saveClml(id, Util.serialize(doc));
        List<EmbeddedCite> cites = Extractor.extract(doc);
        Citations.save(id, cites);

        logger.log("transforming " + id);
        XdmNode akn = clml2akn.transform(doc);
        EnrichedBucket.saveAkn(id, Transform.serialize(akn));
        byte[] html = akn2html.transform(akn);
        EnrichedBucket.saveHtml(id, html);

        logger.log("done");
    }

}
