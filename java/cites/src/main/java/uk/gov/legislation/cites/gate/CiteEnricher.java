package uk.gov.legislation.cites.gate;

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

public class CiteEnricher {

    static final String OriginalMarkups = "Original markups";
    static final String NewMarkups = "New markups";

    private final SerialAnalyserController sac;
    private final GateArtifactRemover artifactRemover = new GateArtifactRemover();
    private final ClmlBeautifier beautifier = new ClmlBeautifier();

    public CiteEnricher() throws GateException {
        if (!Gate.isInitialised())
            Gate.init();
        sac = (SerialAnalyserController) Factory.createResource("gate.creole.SerialAnalyserController");

        sac.getFeatures().put("romanToArabic", new RomanToArabic());
        sac.getFeatures().put("getPrecedingCite", new GetPrecedingCite());
        sac.getFeatures().put("isWithinCitation", new IsWithinCitation());

        Gate.getCreoleRegister().registerPlugin(new Plugin.Directory(getClass().getResource("/annie/")));

        ProcessingResource tokenizer = (ProcessingResource) Factory.createResource("gate.creole.tokeniser.DefaultTokeniser");
        sac.add(tokenizer);

        Steps.addMainGrammar(sac);
        Steps.addLoneNumberStep(sac);
//        Steps.mysteryStep(sac);
        Steps.addNamespaceCheck(sac);
        Steps.addRemove(sac);

        Corpus corpus = Factory.newCorpus("Corpus");
        sac.setCorpus(corpus);
    }

    public byte[] enrich(byte[] clml) throws IOException, ResourceInstantiationException, ExecutionException {
        clml = beautifier.transform(clml);
        Path temp = Files.createTempFile("clml", ".xml");
        Files.write(temp, clml);
        Document doc = Factory.newDocument(temp.toUri().toURL());
        String enriched1 = enrich(doc);
        byte[] withGateArtifactsRemoved = artifactRemover.remove(enriched1);
        byte[] enriched = beautifier.transform(withGateArtifactsRemoved);
        Files.delete(temp);
        return enriched;
    }

    private String enrich(Document doc) throws ExecutionException {
        sac.getCorpus().add(doc);
        sac.execute();
        EUUtils.correctOJCites(doc);
        EUUtils.correctFeatures(doc);
        String enriched = serialize(doc);
        sac.getCorpus().remove(doc);
        return enriched;
    }

    private String serialize(Document doc) {
        AnnotationSet newMarkups = doc.getAnnotations(NewMarkups);
        return doc.toXml(newMarkups, true);
    }

}
