package uk.gov.legislation.db2.queues;

import uk.gov.legislation.aws.Queue;

import java.util.function.Consumer;

public class EnrichDeadLetter {

    public static final String name = "enrich-dead-letter";
    private String url;

    public EnrichDeadLetter() {
        url = Queue.getQueueUrl(name);
    }

    public boolean lease1(Integer seconds, Consumer<String> consumer) {
        return Queue.leaseMessage(url, seconds, consumer);
    }

}
