package uk.gov.legislation.db2.files;

import software.amazon.awssdk.regions.Region;
import uk.gov.legislation.aws.S3;

import java.io.IOException;

public class LGUCache {

    static final Region region = Region.US_EAST_1;

    static final String bucket = "lgu-cache";

    public static byte[] getClml(String id) throws IOException {
        if (id.startsWith("http://www.legislation.gov.uk/id/"))
            id = id.substring(33);
        String key = id + "/data.xml";
        return S3.getBytes(region, bucket, key);
    }
    public static void saveClml(String id, byte[] clml) {
        if (id.startsWith("http://www.legislation.gov.uk/id/"))
            id = id.substring(33);
        String key = id + "/data.xml";
        S3.put(region, bucket, key, clml, "application/xml");
    }

}
