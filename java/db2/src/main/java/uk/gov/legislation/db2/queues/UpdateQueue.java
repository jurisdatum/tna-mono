package uk.gov.legislation.db2.queues;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import uk.gov.legislation.Atom;
import uk.gov.legislation.aws.Queue;

import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

public class UpdateQueue {

    public static final String name = "update";
    private static String url;

    public static void enqueue(MessageBody message) {
        if (url == null)
            url = Queue.getQueueUrl(name);
        String body;
        try {
            body = new ObjectMapper().writeValueAsString(message);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
        Queue.sendMessage(url, body);
    }
    public static void enqueue(List<MessageBody> messages) {
        if (url == null)
            url = Queue.getQueueUrl(name);
        ObjectMapper objectMapper = new ObjectMapper();
        Function<MessageBody, String> keyMapper = (message) -> message.id.replace('/', '_');
        Function<MessageBody, String> valueMapper = (message) -> { try { return objectMapper.writeValueAsString(message); } catch (JsonProcessingException e) { throw new RuntimeException(e); } };
        Map<String, String> bodies = messages.stream()
            .collect(Collectors.toMap(keyMapper, valueMapper));
        Queue.sendMessages(url, bodies);
    }

    public static class MessageBody {

        public static final SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

        public String id;

        public int year;

        public String title;

        public String updated;

        public static MessageBody make(Atom.Entry entry) {
            UpdateQueue.MessageBody message = new UpdateQueue.MessageBody();
            message.id = entry.shortId();
            message.year = entry.year();
            message.title = entry.title();
            message.updated = UpdateQueue.MessageBody.format.format(entry.updated());
            return message;
        }
    }

}
