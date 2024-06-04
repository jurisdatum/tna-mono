package uk.gov.legislation.cites.gate;

import gate.*;
import gate.creole.ExecutionException;
import gate.creole.Plugin;
import gate.creole.ResourceInstantiationException;
import gate.creole.SerialAnalyserController;
import gate.util.GateException;
import uk.gov.legislation.ClmlBeautifier;
import uk.gov.legislation.cites.gate.inject.Functions;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

public class CiteEnricher {

    public static final String OriginalMarkups = GateConstants.ORIGINAL_MARKUPS_ANNOT_SET_NAME;
    public static final String NewMarkups = "New markups";

    private final SerialAnalyserController sac;
    private final ClmlBeautifier beautifier = new ClmlBeautifier();
    private final GateXMLPreparer preparer = new GateXMLPreparer(beautifier.getProcessor());
    private final GateArtifactRemover artifactRemover = new GateArtifactRemover(beautifier.getProcessor());

    static void init() throws GateException {
        if (Gate.isInitialised())
            return;
        Gate.init();
        // this prevents the adding of spaces in the XML
        Gate.getUserConfig().put(GateConstants.DOCUMENT_ADD_SPACE_ON_UNPACK_FEATURE_NAME, Boolean.FALSE);
        // add ANNIE
        Gate.getCreoleRegister().registerPlugin(new Plugin.Directory(CiteEnricher.class.getResource("/annie/")));
        // add custom plugin
        // can't use Gate.getCreoleRegister().registerComponent() -- or Plugin.Component() -- they allow only one resource class
        Gate.getCreoleRegister().registerPlugin( new CustomPlugin());
    }

    public CiteEnricher() throws GateException {
        init();

        sac = (SerialAnalyserController) Factory.createResource("gate.creole.SerialAnalyserController");

        // add custom functions to feature map
        Functions.addAll(sac);

        // add tokenizer
        sac.add((ProcessingResource) Factory.createResource("gate.creole.tokeniser.DefaultTokeniser"));

        // add custom JAPE grammars
        Steps.addAll(sac);

        sac.setCorpus(Factory.newCorpus("Corpus"));
    }

    public byte[] enrich(byte[] clml) throws ResourceInstantiationException, ExecutionException {
        Document doc = loadXml(clml);
        enrich(doc);
        String enriched1 = serialize(doc);
        byte[] withGateArtifactsRemoved = artifactRemover.remove(enriched1);
        return withGateArtifactsRemoved;
    }

    public Document loadXml(byte[] xml) throws ResourceInstantiationException {
        xml = beautifier.transform(xml);
        xml = preparer.prepare(xml);
        String string = new String(xml, StandardCharsets.UTF_8);
        return loadXml(string);
    }
    private static Document loadXml(String xml) throws ResourceInstantiationException {
        FeatureMap params = Factory.newFeatureMap();
        params.put(Document.DOCUMENT_MIME_TYPE_PARAMETER_NAME, "application/xml");
        params.put(Document.DOCUMENT_STRING_CONTENT_PARAMETER_NAME, xml);
        params.put(Document.DOCUMENT_ENCODING_PARAMETER_NAME, StandardCharsets.UTF_8.name());
//        params.put(Document.DOCUMENT_PRESERVE_CONTENT_PARAMETER_NAME, Boolean.TRUE);
//        params.put(Document.DOCUMENT_REPOSITIONING_PARAMETER_NAME, Boolean.TRUE);
        return (Document) Factory.createResource("gate.corpora.DocumentImpl", params);
    }

    public static void removeOriginal(Document doc) {
        AnnotationSet markup = doc.getAnnotations(OriginalMarkups);
        AnnotationSet full = markup.get("Citation");
        markup.removeAll(full);
        AnnotationSet sub = markup.get("CitationSubRef");
        markup.removeAll(sub);
    }

    public void enrich(Document doc) throws ExecutionException {
        sac.getCorpus().add(doc);
        sac.execute();
        sac.getCorpus().remove(doc);
    }

    public static String serialize(Document doc) {
        AnnotationSet newMarkups = doc.getAnnotations(NewMarkups);
        return doc.toXml(newMarkups, true);
    }

}
