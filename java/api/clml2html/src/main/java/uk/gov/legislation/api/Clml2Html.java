package uk.gov.legislation.api;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import net.sf.saxon.s9api.XdmNode;

import java.nio.charset.StandardCharsets;
import java.util.Collections;

public class Clml2Html implements RequestHandler<APIGatewayV2HTTPEvent, APIGatewayV2HTTPResponse> {

    private uk.gov.legislation.clml2akn.Transform clml2akn;
    private uk.gov.legislation.akn2html.Transform akn2html;

    public Clml2Html() {
        clml2akn = new uk.gov.legislation.clml2akn.Transform();
        akn2html = new uk.gov.legislation.akn2html.Transform(clml2akn.processor());
    }

    @Override
    public APIGatewayV2HTTPResponse handleRequest(APIGatewayV2HTTPEvent request, Context context) {
        String clml = request.getBody();
        String html;
        try {
            XdmNode akn = clml2akn.transform(clml.getBytes());
            html = new String(akn2html.transform(akn), StandardCharsets.UTF_8);
        } catch (Exception e) {
            context.getLogger().log(e.getClass().getSimpleName() + " " + e.getLocalizedMessage());
            context.getLogger().log("returning status code 500");
            return APIGatewayV2HTTPResponse.builder().withStatusCode(500).build();
        }
        context.getLogger().log("success: returning status code 200");
        return APIGatewayV2HTTPResponse.builder()
            .withStatusCode(200)
            .withHeaders(Collections.singletonMap("Content-Type", "text/html; charset=utf-8"))
            .withBody(html)
            .build();
    }

}
