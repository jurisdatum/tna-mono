package uk.gov.legislation.api;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.S3Exception;
import uk.gov.legislation.tables.CSV;
import uk.gov.legislation.tables.Excel;
import uk.gov.legislation.tables.Grid;
import uk.gov.legislation.tables.HtmlTable;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Base64;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class Tables implements RequestHandler<APIGatewayV2HTTPEvent, APIGatewayV2HTTPResponse> {

    private final S3Client client;

    public Tables() {
        client = LGUCache.client();
    }

    @Override
    public APIGatewayV2HTTPResponse handleRequest(APIGatewayV2HTTPEvent request, Context context) {
        String id = request.getQueryStringParameters().get("document");
        int n = Integer.parseInt(request.getQueryStringParameters().get("table"));
        String format = request.getQueryStringParameters().get("format");
        LambdaLogger logger = context.getLogger();
        logger.log("document id = " + id);
        logger.log("table number = " + n);
        logger.log("format = " + format);
        try {
            HtmlTable table = getTable(id, n);
            if (table == null)
                return APIGatewayV2HTTPResponse.builder().withStatusCode(404).build();
            if ("csv".equalsIgnoreCase(format))
                return csv(id, n, table);
            if ("xlsx".equalsIgnoreCase(format) || "excel".equalsIgnoreCase(format))
                return xlsx(id, n, table);
            return html(table);
        } catch (S3Exception e) {
            logger.log("S3Exception: " + e.getLocalizedMessage());
            return APIGatewayV2HTTPResponse.builder().withStatusCode(404).build();
        } catch (Exception e) {
            logger.log("ERROR: " + e.getLocalizedMessage());
            return APIGatewayV2HTTPResponse.builder().withStatusCode(500).build();
        }
    }

    private HtmlTable getTable(String id, int n) throws IOException, SAXException {
        byte[] clml = LGUCache.getClml(client, id);
        ByteArrayInputStream bais = new ByteArrayInputStream(clml);
        Document doc = uk.gov.legislation.tables.CLML.parse(bais);
        return uk.gov.legislation.tables.CLML.getTable(doc, n - 1);
    }

    private static APIGatewayV2HTTPResponse html(HtmlTable table) throws IOException {
        return APIGatewayV2HTTPResponse.builder()
            .withStatusCode(200)
            .withHeaders(Collections.singletonMap("Content-Type", "text/html; charset=utf-8"))
            .withBody(table.toString())
            .build();
    }

    private static String makeFilename(String id, int n, String ext) {
        return id.replace('/', '_') + "_table_" + n + "." + ext;
    }

    private APIGatewayV2HTTPResponse csv(String id, int n, HtmlTable table) throws IOException {
        List<List<Grid.Cell>> grid = Grid.convert(table, false);
        return csv(id, n, grid);
    }
    private APIGatewayV2HTTPResponse csv(String id, int n, List<List<Grid.Cell>> grid) throws IOException {
        String csv = CSV.convert(grid);
        String filename = makeFilename(id, n, "csv");
        Map<String, String> headers = Map.of(
            "Content-Type", "text/csv",
            "Content-Disposition", "attachment; filename=\"" + filename + "\""
        );
        return APIGatewayV2HTTPResponse.builder()
            .withStatusCode(200)
            .withHeaders(headers)
            .withBody(csv)
            .build();
    }

    private APIGatewayV2HTTPResponse xlsx(String id, int n, HtmlTable table) throws IOException {
        List<List<Grid.Cell>> grid = Grid.convert(table, true);
        return xlsx(id, n, grid);
    }
    private APIGatewayV2HTTPResponse xlsx(String id, int n, List<List<Grid.Cell>> grid) throws IOException {
        byte[] xlsx = Excel.convert(grid);
        String body = Base64.getEncoder().encodeToString(xlsx);
        String filename = makeFilename(id, n, "xlsx");
        Map<String, String> headers = Map.of(
            "Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "Content-Disposition", "attachment; filename=\"" + filename + "\""
        );
        return APIGatewayV2HTTPResponse.builder()
            .withStatusCode(200)
            .withHeaders(headers)
            .withBody(body)
            .withIsBase64Encoded(true)
            .build();
    }

}
