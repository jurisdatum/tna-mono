package uk.gov.legislation.db2.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.events.SQSEvent.SQSMessage;
import com.fasterxml.jackson.core.JsonProcessingException;
import uk.gov.legislation.Atom;
import uk.gov.legislation.Legislation;
import uk.gov.legislation.db2.queues.CheckQueue;
import uk.gov.legislation.db2.queues.UpdateQueue;
import uk.gov.legislation.db2.rds.Document;

import java.sql.SQLException;
import java.util.Date;
import java.util.Iterator;
import java.util.Map;
import java.util.stream.Collectors;

public class CheckKnown extends SQSEventHandler {

    @Override
    void processMessage(SQSMessage message, Context context) throws JsonProcessingException, SQLException {
        LambdaLogger logger = context.getLogger();
        logger.log(message.getBody());
        CheckQueue.Message body = CheckQueue.Message.parse(message.getBody());
        Map<String, Date> dates = fetchDates(body.type, body.year);
        if (body.type.equals("uksi")) {
            dates.putAll(fetchDates("wsi", body.year));
            dates.putAll(fetchDates("nisi", body.year));
        }
        Iterator<Atom.Entry> iterator = Atom.getFeed(Legislation.Type.valueOf(body.type), body.year).entries();
        while (iterator.hasNext()) {
            Atom.Entry entry = iterator.next();
            String id = entry.shortId();
            if (!body.force && dates.containsKey(id) && dates.get(id).getTime() == entry.updated().getTime())
                continue;
            UpdateQueue.MessageBody update = UpdateQueue.MessageBody.make(entry);
            update.force = body.force;
            UpdateQueue.enqueue(update);
        }
    }

    private Map<String, Date> fetchDates(String type, int year) throws SQLException {
        return Document.fetch(type, year).stream().collect(Collectors.toMap(d -> d.id(), d -> d.getLastUpdated()));
    }

}
