package uk.gov.legislation.api;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;

import net.sf.saxon.s9api.XdmNode;

import uk.gov.legislation.clml2akn91.Akn2Html91;
import uk.gov.legislation.clml2akn91.Clml2Akn91;

import java.util.Collections;

public class Clml2Html implements RequestHandler<APIGatewayV2HTTPEvent, APIGatewayV2HTTPResponse> {

    private static final String cssPath = "https://www.tna.jurisdatum.com/css/";

    private Clml2Akn91 clml2akn;
    private Akn2Html91 akn2html;

    public Clml2Html() {
        clml2akn = new Clml2Akn91();
        akn2html = new Akn2Html91(clml2akn.getProcessor());
    }

    @Override
    public APIGatewayV2HTTPResponse handleRequest(APIGatewayV2HTTPEvent request, Context context) {
        String clml = request.getBody();
        String html;
        try {
            XdmNode akn = clml2akn.transform(clml);
            html = akn2html.transform(akn, cssPath);
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
