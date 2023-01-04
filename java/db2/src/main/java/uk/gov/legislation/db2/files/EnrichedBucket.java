package uk.gov.legislation.db2.files;

import software.amazon.awssdk.regions.Region;
import uk.gov.legislation.aws.S3;

public class EnrichedBucket {

    static final Region region = Region.EU_WEST_2;

    static final String bucket = "lgu-enriched";

    public static void saveClml(String id, byte[] clml) {
        if (id.startsWith("http://www.legislation.gov.uk/id/"))
            id = id.substring(33);
        String key = id + "/data.xml";
        S3.put(region, bucket, key, clml, "application/xml");
    }

    public static void saveAkn(String id, byte[] clml) {
        if (id.startsWith("http://www.legislation.gov.uk/id/"))
            id = id.substring(33);
        String key = id + "/data.akn";
        S3.put(region, bucket, key, clml, "application/xml");
    }

    public static void saveHtml(String id, byte[] clml) {
        if (id.startsWith("http://www.legislation.gov.uk/id/"))
            id = id.substring(33);
        String key = id + "/data.html";
        S3.put(region, bucket, key, clml, "text/html");
    }

}
