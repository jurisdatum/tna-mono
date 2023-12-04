package uk.gov.legislation.cites.gate;

import com.drew.lang.Charsets;
import gate.*;
import gate.creole.ExecutionException;
import gate.creole.Plugin;
import gate.creole.ResourceInstantiationException;
import gate.creole.SerialAnalyserController;
import gate.util.GateException;
import uk.gov.legislation.ClmlBeautifier;
import uk.gov.legislation.cites.gate.inject.*;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

public class CiteEnricher {

    public static final String OriginalMarkups = "Original markups";
    public static final String NewMarkups = "New markups";

    private final SerialAnalyserController sac;
    private final ClmlBeautifier beautifier = new ClmlBeautifier();
    private final GateXMLPreparer preparer = new GateXMLPreparer(beautifier.getProcessor());
    private final GateArtifactRemover artifactRemover = new GateArtifactRemover(beautifier.getProcessor());

    public CiteEnricher() throws GateException {
        if (!Gate.isInitialised()) {
            Gate.init();
            // add ANNIE
            Gate.getCreoleRegister().registerPlugin(new Plugin.Directory(getClass().getResource("/annie/")));
            // add custom component
            Gate.getCreoleRegister().registerComponent(EUNumberCorrector.class);
        }
        sac = (SerialAnalyserController) Factory.createResource("gate.creole.SerialAnalyserController");

        // add custom functions to feature map
        Functions.addAll(sac);

        // add tokenizer
        sac.add((ProcessingResource) Factory.createResource("gate.creole.tokeniser.DefaultTokeniser"));

        // add custom JAPE grammars
        Steps.addAll(sac);

        sac.setCorpus(Factory.newCorpus("Corpus"));
    }

    public byte[] enrich(byte[] clml) throws IOException, ResourceInstantiationException, ExecutionException {
        clml = beautifier.transform(clml);
        clml = preparer.prepare(clml);
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
        String enriched = serialize(doc);
        sac.getCorpus().remove(doc);
        return enriched;
    }

    private String serialize(Document doc) {
        AnnotationSet newMarkups = doc.getAnnotations(NewMarkups);
        return doc.toXml(newMarkups, true);
    }

}
