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
import java.util.Collections;

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
            original = getClml(request, context);
        } catch (URISyntaxException e1) {
            context.getLogger().log(e1.getClass().getSimpleName() + " " + e1.getLocalizedMessage());
            context.getLogger().log("returning status code 400");
            return APIGatewayV2HTTPResponse.builder().withStatusCode(400).build();
        } catch (NotFoundException e2) {
            context.getLogger().log("returning status code 404");
            return APIGatewayV2HTTPResponse.builder().withStatusCode(404).build();
        } catch (IOException | InterruptedException e3) {
            context.getLogger().log(e3.getClass().getSimpleName() + " " + e3.getLocalizedMessage());
            context.getLogger().log("returning status code 500");
            return APIGatewayV2HTTPResponse.builder().withStatusCode(500).build();
        }
        byte[] removed = remover.remove(original);
        byte[] enriched;
        try {
            enriched = enricher.enrich(removed);
        } catch (Exception e) {
            context.getLogger().log(e.getClass().getSimpleName() + " " + e.getLocalizedMessage());
            context.getLogger().log("returning status code 500");
            return APIGatewayV2HTTPResponse.builder().withStatusCode(500).build();
        }
        context.getLogger().log("success: returning status code 200");
        return APIGatewayV2HTTPResponse.builder()
            .withStatusCode(200)
            .withHeaders(Collections.singletonMap("Content-Type", "application/xml; charset=utf-8"))
            .withBody(new String(enriched, StandardCharsets.UTF_8))
            .build();
    }

    static class NotFoundException extends Exception { }

    private byte[] getClml(APIGatewayV2HTTPEvent request, Context context) throws URISyntaxException, IOException, InterruptedException, NotFoundException {
        context.getLogger().log("getting CLML");
        context.getLogger().log("http method is " + request.getRequestContext().getHttp().getMethod());
        if ("POST".equals(request.getRequestContext().getHttp().getMethod()))
            return request.getBody().getBytes();
        context.getLogger().log("query string parameters are " + request.getRawQueryString());
        String id = request.getQueryStringParameters().get("id");
        context.getLogger().log("id is " + id);
        URI uri = new URI("https://www.legislation.gov.uk/" + id + "/data.xml");
        HttpRequest http = HttpRequest.newBuilder().uri(uri).build();
        HttpClient client = HttpClient.newBuilder().followRedirects(HttpClient.Redirect.NORMAL).build();
        HttpResponse<byte[]> response = client.send(http, HttpResponse.BodyHandlers.ofByteArray());
        context.getLogger().log("LGU returned status code " + response.statusCode());
        if (response.statusCode() == 404)
            throw new NotFoundException();
        if (response.statusCode() != 200)
            throw new IOException("LGU returned status code " + response.statusCode());
        return response.body();
    }

}