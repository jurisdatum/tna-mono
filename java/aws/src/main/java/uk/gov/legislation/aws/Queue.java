package uk.gov.legislation.aws;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.*;

import java.util.Map;

public class Queue {

    public static final Region DefaultRegion =Region.EU_WEST_2;

    public static String getQueueUrl(String queue) {
        SqsClient client = SqsClient.builder().region(DefaultRegion).build();
        GetQueueUrlRequest request = GetQueueUrlRequest.builder().queueName(queue).build();
        GetQueueUrlResponse response = client.getQueueUrl(request);
        return response.queueUrl();
    }

    public static String sendMessage(String url, String message) {
        SqsClient client = SqsClient.builder().region(DefaultRegion).build();
        SendMessageRequest request = SendMessageRequest.builder().queueUrl(url).messageBody(message).build();
        SendMessageResponse response = client.sendMessage(request);
        return response.messageId();
    }
    public static boolean sendMessages(String url, Map<String, String> messages) {
        if (messages.isEmpty())
            return true;
        SqsClient client = SqsClient.builder().region(DefaultRegion).build();
        SendMessageBatchRequestEntry[] entries = messages.entrySet().stream()
            .map(message -> SendMessageBatchRequestEntry.builder().id(message.getKey()).messageBody(message.getValue()).build())
            .toArray(SendMessageBatchRequestEntry[]::new);
        SendMessageBatchRequest request = SendMessageBatchRequest.builder().queueUrl(url).entries(entries).build();
        SendMessageBatchResponse response = client.sendMessageBatch(request);
        return !response.hasFailed();
    }

}
