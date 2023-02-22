package uk.gov.legislation.gate;

import gate.*;
import gate.creole.ExecutionException;
import gate.creole.Plugin;
import gate.creole.ResourceInstantiationException;
import gate.creole.SerialAnalyserController;
import gate.util.GateException;
import uk.gov.legislation.ClmlBeautifier;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.logging.Logger;

public class EUCiteEnricher extends GateEnricher {

    private final Logger logger = Logger.getAnonymousLogger();

    private final SerialAnalyserController sac;

    private static final String AnnotationSet = "New markups";
    private static final String Grammar = "/EUCitations.jape";

    public EUCiteEnricher() throws GateException {
        Gate.init();
        sac = (SerialAnalyserController) Factory.createResource("gate.creole.SerialAnalyserController");

        Gate.getCreoleRegister().registerPlugin(new Plugin.Maven("uk.ac.gate.plugins", "annie", "9.1"));

        ProcessingResource tokenizer = (ProcessingResource) Factory.createResource("gate.creole.tokeniser.DefaultTokeniser");
        sac.add(tokenizer);

        FeatureMap japeFeature = Factory.newFeatureMap();
        japeFeature.put("grammarURL", EUCiteEnricher.class.getResource(Grammar));
        japeFeature.put("outputASName", AnnotationSet);
        LanguageAnalyser jape = (LanguageAnalyser) Factory.createResource("gate.creole.Transducer", japeFeature);
        sac.add(jape);

        Corpus corpus = Factory.newCorpus("Corpus");
        sac.setCorpus(corpus);
    }

    @Override
    public String enrich(String clml) throws IOException, ResourceInstantiationException, ExecutionException {
        ClmlBeautifier beautifier = new ClmlBeautifier();
        clml = beautifier.transform(clml);
        Path temp = Files.createTempFile("clml", ".xml");
        Files.writeString(temp, clml);
        Document doc = Factory.newDocument(temp.toUri().toURL());
        String enriched = enrich(doc);
        enriched = beautifier.transform(enriched);
        Files.delete(temp);
        return enriched;
    }

    private String enrich(Document doc) throws ExecutionException {
        sac.getCorpus().add(doc);
        sac.execute();
        doc.getAnnotations(AnnotationSet).forEach(ann -> {
            String text = gate.Utils.stringFor(doc, ann);
            logger.info("found cite: \"" + text + "\"");
        });
        String enriched = serialize(doc);
        sac.getCorpus().remove(doc);
        return enriched;
    }

    private String serialize(Document doc) {
        return doc.toXml(doc.getAnnotations(AnnotationSet), true);
    }

}
