package uk.gov.legislation.db2.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.SQSBatchResponse;
import com.amazonaws.services.lambda.runtime.events.SQSEvent;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import uk.gov.legislation.CLML;
import uk.gov.legislation.db2.files.LGUCache;
import uk.gov.legislation.db2.queues.UpdateQueue;
import uk.gov.legislation.db2.rds.Document;

import java.sql.SQLException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class Update1 implements RequestHandler<SQSEvent, SQSBatchResponse> {

    @Override
    public SQSBatchResponse handleRequest(SQSEvent event, Context context) {
        LambdaLogger logger = context.getLogger();
        List<SQSBatchResponse.BatchItemFailure> failures = new ArrayList<>();
        String messageId = "";
        for (SQSEvent.SQSMessage message : event.getRecords()) {
            try {
                messageId = message.getMessageId();
                processMessage(message, logger);
            } catch (Exception e) {
                logger.log(e.getLocalizedMessage());
                e.printStackTrace();
                failures.add(new SQSBatchResponse.BatchItemFailure(messageId));
            }
        }
        return new SQSBatchResponse(failures);
    }

    private void processMessage(SQSEvent.SQSMessage message, LambdaLogger logger) throws JsonProcessingException, ParseException, SQLException {
        UpdateQueue.MessageBody body = new ObjectMapper().readValue(message.getBody(), UpdateQueue.MessageBody.class);
        logger.log(body.id);
        Date updated = UpdateQueue.MessageBody.format.parse(body.updated);
        Document doc = Document.get(body.id);
        if (doc != null && !doc.getLastUpdated().before(updated)) {
            logger.log("skipping " + body.id);
            return;
        }
        doc = new Document(body.id, body.year);
        doc.setTitle(body.title);
        doc.setLastUpdated(updated);
        try {
            byte[] clml = CLML.getBytes(body.id);
            LGUCache.saveClml(body.id, clml);
            doc.put();
        } catch (Exception e) {
            logger.log(e.getLocalizedMessage());
            e.printStackTrace();
        }
    }

}
