package uk.gov.legislation.db2.files;

import software.amazon.awssdk.regions.Region;
import uk.gov.legislation.Util;
import uk.gov.legislation.aws.S3;

import java.io.IOException;

public class EnrichedBucket {

    static final Region region = Region.EU_WEST_2;

    static final String bucket = "lgu-enriched";

    private static String makeClmlKey(String id) {
        return Util.longToShortId(id) + "/data.xml";
    }
    public static byte[] getClml(String id) throws IOException {
        String key = makeClmlKey(id);
        return S3.getBytes(region, bucket, key);
    }
    public static void saveClml(String id, byte[] clml) {
        String key = makeClmlKey(id);
        S3.put(region, bucket, key, clml, "application/xml");
    }

    public static void saveAkn(String id, byte[] clml) {
        String key = Util.longToShortId(id) + "/data.akn";
        S3.put(region, bucket, key, clml, "application/xml");
    }

    public static void saveHtml(String id, byte[] clml) {
        String key = Util.longToShortId(id) + "/data.html";
        S3.put(region, bucket, key, clml, "text/html");
    }

}
