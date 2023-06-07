package uk.gov.legislation.api;

import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;

import java.io.IOException;

public class EnrichedBucket {

    static final Region region = Region.EU_WEST_2;

    static final String bucket = "lgu-enriched";

    public static byte[] getClml(String id) throws IOException {
        String key = id + "/data.xml";
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

}
