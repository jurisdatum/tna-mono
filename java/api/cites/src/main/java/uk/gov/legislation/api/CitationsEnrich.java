package uk.gov.legislation.api;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import gate.util.GateException;
import uk.gov.legislation.cites.AllCiteRemover;
import uk.gov.legislation.cites.gate.CiteEnricher;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

public class CitationsEnrich implements RequestHandler<APIGatewayV2HTTPEvent, APIGatewayV2HTTPResponse> {

    private AllCiteRemover remover;
    private CiteEnricher enricher;

    public CitationsEnrich() throws GateException {
        remover = new AllCiteRemover();
        enricher = new CiteEnricher();
    }

    @Override
    public APIGatewayV2HTTPResponse handleRequest(APIGatewayV2HTTPEvent request, Context context) {
        byte[] original;
        try {
            original = getClml(request);
        } catch (URISyntaxException e1) {
            return APIGatewayV2HTTPResponse.builder().withStatusCode(400).build();
        } catch (IOException | InterruptedException e2) {
            return APIGatewayV2HTTPResponse.builder().withStatusCode(500).build();
        }
        byte[] removed = remover.remove(original);
        byte[] enriched;
        try {
            enriched = enricher.enrich(removed);
        } catch (Exception e) {
            return APIGatewayV2HTTPResponse.builder().withStatusCode(500).build();
        }
        return APIGatewayV2HTTPResponse.builder().withBody(new String(enriched, StandardCharsets.UTF_8)).build();
    }

    private byte[] getClml(APIGatewayV2HTTPEvent request) throws URISyntaxException, IOException, InterruptedException {
        if ("POST".equals(request.getRequestContext().getHttp().getMethod()))
            return request.getBody().getBytes();
        String id = request.getQueryStringParameters().get("id");
        URI uri = new URI("https://www.legislation.gov.uk/" + id + "/data.xml");
        HttpRequest http = HttpRequest.newBuilder().uri(uri).build();
        HttpClient client = HttpClient.newHttpClient();
        HttpResponse<byte[]> response = client.send(http, HttpResponse.BodyHandlers.ofByteArray());
        return response.body();
    }

}