package uk.gov.legislation.db2.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.ScheduledEvent;
import uk.gov.legislation.Atom;
import uk.gov.legislation.CLML;
import uk.gov.legislation.db2.files.LGUCache;
import uk.gov.legislation.db2.queues.EnrichmentQueue;
import uk.gov.legislation.db2.rds.Document;
import uk.gov.legislation.db2.rds.Version;

import java.sql.SQLException;
import java.util.Iterator;

import static uk.gov.legislation.Atom.NewLegislation;

public class ScrapeNew implements RequestHandler<ScheduledEvent, Void> {

    @Override
    public Void handleRequest(ScheduledEvent scheduledEvent, Context context) {
        LambdaLogger logger = context.getLogger();
        Iterator<Atom.Entry> entries = NewLegislation.entries();
        while (entries.hasNext()) {
            Atom.Entry entry = entries.next();
            String id = entry.shortId();
            logger.log(id);
            if (id.endsWith(".pdf")) // correction slips
                continue;

            Document doc;
            try {
                doc = Document.get(id);
            } catch (SQLException e) {
                logger.log(e.getLocalizedMessage());
                e.printStackTrace();
                break;
            }
            if (doc != null && !doc.getLastUpdated().before(entry.updated())) {
//                doc.setLastChecked(new Date());
//                try {
//                    doc.put();
//                } catch (SQLException e) {
//                    logger.log(e.getLocalizedMessage());
//                    e.printStackTrace();
//                }
                break;
            }

            doc = new Document(id, entry.year());
            doc.setTitle(entry.title());
            doc.setLastUpdated(entry.updated());
            try {
                byte[] clml = CLML.getBytes(id);
                LGUCache.saveClml(id, clml);
                doc.put();
                Version.save(id, new CLML(clml).getVersions());
                EnrichmentQueue.enqueue(id);
            } catch (Exception e) {
                logger.log(e.getLocalizedMessage());
                e.printStackTrace();
                break;
            }
        }
        logger.log("done");
        return null;
    }

}
