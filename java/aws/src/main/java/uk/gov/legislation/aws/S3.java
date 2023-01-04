package uk.gov.legislation.aws;

import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.IOException;

public class S3 {

    private static final Region DefaultRegion = Region.EU_WEST_2;

    public static byte[] getBytes(String bucket, String key) throws IOException {
        return getBytes(DefaultRegion, bucket, key);
    }

    public static byte[] getBytes(Region region, String bucket, String key) throws IOException {
        S3Client client = S3Client.builder()
            .region(region)
            .build();
        GetObjectRequest request = GetObjectRequest.builder()
            .bucket(bucket)
            .key(key)
            .build();
        ResponseInputStream response = client.getObject(request);
        byte[] content = response.readAllBytes();
        response.close();
        client.close();
        return content;
    }

    public static void put(String bucket, String key, byte[] content, String type) {
        put(DefaultRegion, bucket, key, content, type);
    }

    public static void put(Region region, String bucket, String key, byte[] content, String type) {
        S3Client client = S3Client.builder()
            .region(region)
            .build();
        PutObjectRequest request = PutObjectRequest.builder()
            .bucket(bucket)
            .key(key)
            .contentType(type)
            .build();
        RequestBody body = RequestBody.fromBytes(content);
        client.putObject(request, body);
        client.close();
    }

}
