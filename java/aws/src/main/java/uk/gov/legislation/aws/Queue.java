package uk.gov.legislation.aws;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.*;

import java.util.List;
import java.util.Map;
import java.util.function.Consumer;

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

    public static boolean leaseMessage(String url, Integer seconds, Consumer<String> consumer) {
        SqsClient client = SqsClient.builder().region(DefaultRegion).build();
        ReceiveMessageRequest request = ReceiveMessageRequest.builder().queueUrl(url).visibilityTimeout(seconds).maxNumberOfMessages(1).build();
        ReceiveMessageResponse response = client.receiveMessage(request);
        List<Message> messages = response.messages();
        if (messages.isEmpty())
            return false;
        Message message = messages.get(0);
        String content = message.body();
        String receiptHandle = message.receiptHandle();
        try {
            consumer.accept(content);
        } catch (Exception e) {
            client.close();
            throw new RuntimeException(e);
        }
        DeleteMessageRequest request2 = DeleteMessageRequest.builder().queueUrl(url).receiptHandle(receiptHandle).build();
        client.deleteMessage(request2);
        client.close();
        return true;
    }

}
