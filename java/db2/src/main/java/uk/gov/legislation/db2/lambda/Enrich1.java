package uk.gov.legislation.db2.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.events.SQSEvent;
import gate.util.GateException;
import org.xml.sax.SAXException;

import uk.gov.legislation.cites.AllCiteRemover;
import uk.gov.legislation.cites.EmbeddedCite;
import uk.gov.legislation.cites.Extractor;
import uk.gov.legislation.cites.gate.CiteEnricher;
import uk.gov.legislation.db2.files.EnrichedBucket;
import uk.gov.legislation.db2.files.LGUCache;
import uk.gov.legislation.db2.queues.TransformQueue;
import uk.gov.legislation.db2.rds.Citations;
import uk.gov.legislation.db2.rds.Document;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class Enrich1 extends SQSEventHandler {

    private AllCiteRemover _remover;
    private CiteEnricher _enricher;
    private AllCiteRemover getRemover() {
        if (_remover == null)
            _remover = new AllCiteRemover();
        return _remover;
    }
    private CiteEnricher getEnricher() throws GateException {
        if (_enricher == null)
            _enricher = new CiteEnricher();
        return _enricher;
    }

    @Override
    void processMessage(SQSEvent.SQSMessage message, Context context) throws SQLException, IOException, GateException, SAXException {
        LambdaLogger logger = context.getLogger();
        String id = message.getBody();
        logger.log("received " + id);
        Document leg = Document.get(id);
        if (leg == null)
            throw new RuntimeException(id + " does not exist");
        byte[] clml = LGUCache.getClml(id);
        logger.log("removing original EU citations");
        clml = getRemover().remove(clml);
        logger.log("enriching XML");
        byte[] enriched = getEnricher().enrich(clml);
        logger.log("saving enriched XML");
        EnrichedBucket.saveClml(id, enriched);
        logger.log("extracting citations");
        List<EmbeddedCite> cites = Extractor.extract(enriched);
        logger.log("saving citations to MySQL");
        Citations.save(id, cites);

        logger.log("enqueuing for transform");
        TransformQueue.enqueue(id);

        logger.log("done");
    }

}
