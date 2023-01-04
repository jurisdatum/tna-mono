package uk.gov.legislation.aws;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueResponse;

public class Secrets {

    private static final Region DefaultRegion = Region.EU_WEST_2;

    public static String getSecret(String name) {
        return getSecret(DefaultRegion, name);
    }

    public static String getSecret(Region region, String name) {
        SecretsManagerClient client = SecretsManagerClient.builder()
            .region(region)
//                .credentialsProvider()
            .build();
        GetSecretValueRequest request = GetSecretValueRequest.builder()
            .secretId(name)
            .build();
        GetSecretValueResponse response = client.getSecretValue(request);
        return response.secretString();
    }

}
