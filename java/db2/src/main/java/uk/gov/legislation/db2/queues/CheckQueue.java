package uk.gov.legislation.db2.queues;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import uk.gov.legislation.aws.Queue;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

public class CheckQueue {

    public static final String name = "check";
    private static String url;

    public static void enqueue(Message message) {
        if (url == null)
            url = Queue.getQueueUrl(name);
        Queue.sendMessage(url, message.toString());
    }
    public static void enqueue(List<Message> messages) {
        if (url == null)
            url = Queue.getQueueUrl(name);
        ObjectMapper objectMapper = new ObjectMapper();
        Function<Message, String> keyMapper = (message) -> message.type + message.year;
        Function<Message, String> valueMapper = Message::toString;
        Map<String, String> bodies = messages.stream().collect(Collectors.toMap(keyMapper, valueMapper));
        Queue.sendMessages(url, bodies);
    }

    public static class Message {

        public String type;

        public int year;

        @JsonProperty(value="force")
        public boolean force;

        public Message() { }

        public Message(String type, int year, boolean force) {
            this.type = type;
            this.year = year;
            this.force = force;
        }

        @Override
        public String toString() {
            ObjectMapper mapper = new ObjectMapper();
            try {
                return mapper.writeValueAsString(this);
            } catch (JsonProcessingException e) {
                throw new RuntimeException(e);
            }
        }

        public static Message parse(String json) throws JsonProcessingException {
            return new ObjectMapper().readValue(json, Message.class);
        }

    }
}
