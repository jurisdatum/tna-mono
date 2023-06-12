package uk.gov.legislation.api;

import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;

import java.io.IOException;


public class LGUCache {

    static final Region region = Region.US_EAST_1;

    static final String bucket = "lgu-cache";

    public static S3Client client() {
        return S3Client.builder()
            .region(region)
            .build();
    }

    public static byte[] getClml(S3Client client, String id) throws IOException {
        String key = id + "/data.xml";
        GetObjectRequest request = GetObjectRequest.builder()
            .bucket(bucket)
            .key(key)
            .build();
        ResponseInputStream response = client.getObject(request);
        byte[] content = response.readAllBytes();
        response.close();
        return content;
    }

}
