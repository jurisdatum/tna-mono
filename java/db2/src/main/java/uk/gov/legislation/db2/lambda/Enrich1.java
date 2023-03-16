package uk.gov.legislation.db2.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.events.SQSEvent;
import gate.util.GateException;
import org.xml.sax.SAXException;

import uk.gov.legislation.cites.EUCiteRemover;
import uk.gov.legislation.cites.EmbeddedCite;
import uk.gov.legislation.cites.Extractor;
import uk.gov.legislation.cites.gate.EUCiteEnricher;
import uk.gov.legislation.db2.files.EnrichedBucket;
import uk.gov.legislation.db2.files.LGUCache;
import uk.gov.legislation.db2.queues.TransformQueue;
import uk.gov.legislation.db2.rds.Citations;
import uk.gov.legislation.db2.rds.Document;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class Enrich1 extends SQSEventHandler {

    private EUCiteRemover _remover;
    private EUCiteEnricher _enricher;
    private EUCiteRemover getRemover() {
        if (_remover == null)
            _remover = new EUCiteRemover();
        return _remover;
    }
    private EUCiteEnricher getEnricher() throws GateException {
        if (_enricher == null)
            _enricher = new EUCiteEnricher();
        return _enricher;
    }

    @Override
    void processMessage(SQSEvent.SQSMessage message, Context context) throws SQLException, IOException, GateException, SAXException {
        LambdaLogger logger = context.getLogger();
        String id = message.getBody();
        logger.log("received " + id);
        Document leg = Document.get(id);
        if (leg == null) {
            logger.log(id + " does not exists");
            return;
        }
        byte[] clml = LGUCache.getClml(id);
        logger.log("removing original EU citations");
        clml = getRemover().remove(clml);
        logger.log("enriching");
        byte[] enriched = getEnricher().enrich(clml);
        logger.log("saving");
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
