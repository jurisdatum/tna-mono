package uk.gov.legislation.db2.queues;

import uk.gov.legislation.aws.Queue;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

public class EnrichmentQueue {

    public static final String name = "enrich";
    private static String url;

    public static void enqueue(String id) {
        if (url == null)
            url = Queue.getQueueUrl(name);
        String body = id;
        Queue.sendMessage(url, body);
    }
    public static void enqueue(List<String> ids) {
        if (url == null)
            url = Queue.getQueueUrl(name);
        Function<String, String> keyMapper = (id) -> id.replace('/', '_');
        Map<String, String> messages = ids.stream().collect(Collectors.toMap(keyMapper, Function.identity()));
        Queue.sendMessages(url, messages);
    }

}
