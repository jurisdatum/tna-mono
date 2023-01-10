package uk.gov.legislation.db2.queues;

import uk.gov.legislation.aws.Queue;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

public class TransformQueue {

    public static final String name = "transform";
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
        Map<String, String> messages = ids.stream().collect(Collectors.toMap(IdMapper.Instance, Function.identity()));
        Queue.sendMessages(url, messages);
    }

}
