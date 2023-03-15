package uk.gov.legislation.cites.gate;

import gate.*;
import gate.annotation.AnnotationSetImpl;
import gate.creole.ExecutionException;
import gate.creole.Plugin;
import gate.creole.ResourceInstantiationException;
import gate.creole.SerialAnalyserController;
import gate.util.GateException;

import uk.gov.legislation.ClmlBeautifier;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EUCiteEnricher {

    private static final String AnnotationSet = "New markups";
    private static final String Grammar = "/EUCitations.jape";
    private static final Logger logger = Logger.getAnonymousLogger();

    private final SerialAnalyserController sac;
    private final ClmlBeautifier beautifier = new ClmlBeautifier();

    public EUCiteEnricher() throws GateException {
        Gate.init();
        sac = (SerialAnalyserController) Factory.createResource("gate.creole.SerialAnalyserController");

        /*
        * Plugin.Maven is a plugin that is a single JAR ﬁle speciﬁed via its group:artifact:version “coordinates”,
        * and which is downloaded from a Maven repository at runtime by GATE the ﬁrst time the plugin is loaded.
        */
//        Gate.getCreoleRegister().registerPlugin(new Plugin.Maven("uk.ac.gate.plugins", "annie", "9.1"));
        Gate.getCreoleRegister().registerPlugin(new Plugin.Directory(getClass().getResource("/annie/")));

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

    public String enrich(String clml) throws IOException, ResourceInstantiationException, ExecutionException {
        clml = beautifier.transform(clml);
        Path temp = Files.createTempFile("clml", ".xml");
        Files.writeString(temp, clml);
        Document doc = Factory.newDocument(temp.toUri().toURL());
        String enriched = enrich(doc);
        enriched = beautifier.transform(enriched);
        Files.delete(temp);
        return enriched;
    }

    public byte[] enrich(byte[] clml) throws IOException, ResourceInstantiationException, ExecutionException {
        clml = beautifier.transform(clml);
        Path temp = Files.createTempFile("clml", ".xml");
        Files.write(temp, clml);
        Document doc = Factory.newDocument(temp.toUri().toURL());
        String enriched1 = enrich(doc);
        byte[] enriched = beautifier.transformToBytes(enriched1);
        Files.delete(temp);
        return enriched;
    }

    private String enrich(Document doc) throws ExecutionException {
        sac.getCorpus().add(doc);
        sac.execute();
        AnnotationSet newAnnotations = doc.getAnnotations(AnnotationSet);
        removeCertainCites(newAnnotations.get("Citation"));
        correctFeatures(newAnnotations.get("Citation"));    // only those that remain after removeCertainCites()
        replaceSuccessive(newAnnotations.get("SuccessiveCitation"));
        String enriched = serialize(doc);
        sac.getCorpus().remove(doc);
        return enriched;
    }

    private void removeCertainCites(AnnotationSet newFullCites) {
        Document doc = newFullCites.getDocument();
        AnnotationSetImpl toRemove = new AnnotationSetImpl(doc);
        Iterator<Annotation> iterator = newFullCites.iterator();
        while (iterator.hasNext()) {
            Annotation cite = iterator.next();
            if (isWithinMetadata(doc, cite)) {
                logger.info("removing cite: \"" + gate.Utils.stringFor(doc, cite) + "\" because it's in the metadata");
                toRemove.add(cite);
                continue;
            }
            if (isWithinOriginalCitation(doc, cite)) {
                logger.info("removing cite: \"" + gate.Utils.stringFor(doc, cite) + "\" because it's within another cite");
                toRemove.add(cite);
                continue;
            }
            if (isWithinTitleElement(doc, cite)) {
                logger.info("removing cite: \"" + gate.Utils.stringFor(doc, cite) + "\" because it's in a title");
                toRemove.add(cite);
                continue;
            }
//            if (isWithinQuotation(doc, cite)) {
//                logger.info("removing cite: \"" + gate.Utils.stringFor(doc, cite) + "\" because it's in a quote");
//                iterator.remove();
//                continue;
//            }
        }
        doc.getAnnotations(AnnotationSet).removeAll(toRemove);
    }

    // correct @Class, @Year and @Number attributes
    private void correctFeatures(AnnotationSet newFullCites) {
        Document doc = newFullCites.getDocument();
        AnnotationSetImpl toRemove = new AnnotationSetImpl(doc);
        Iterator<Annotation> iterator = newFullCites.iterator();
        while (iterator.hasNext()) {
            Annotation cite = iterator.next();
            String text = gate.Utils.stringFor(doc, cite);
            FeatureMap features = cite.getFeatures();

            String c = (String) features.get("Class");
            if (c.endsWith("s"))
                c = c.substring(0, c.length() - 1);
            c = "EuropeanUnion" + c;
            features.put("Class", c);

            int num1 = Integer.parseInt((String) features.get("Number"));
            int num2 = Integer.parseInt((String) features.get("Year"));
            EUNumbers numbers;
            try {
                numbers = EUNumbers.interpret(num1, num2);
            } catch (IllegalArgumentException e) {
                logger.log(Level.WARNING, "removing cite: \"" + text + "\"", e);
                toRemove.add(cite);
                continue;
            }
            features.put("Year", numbers.year());
            features.put("Number", numbers.number());
            logger.info("found cite: " + text + " " + features.toString());
            cite.setFeatures(features);
        }
        doc.getAnnotations(AnnotationSet).removeAll(toRemove);
    }

    private boolean isWithinMetadata(Document doc, Annotation cite) {
        AnnotationSet originalMarkups = doc.getNamedAnnotationSets().get("Original markups");
        AnnotationSet ancestorCites = originalMarkups.get("ukm:Metadata", cite.getStartNode().getOffset(), cite.getEndNode().getOffset());
        return !ancestorCites.isEmpty();
    }

    private boolean isWithinOriginalCitation(Document doc, Annotation cite) {
        AnnotationSet originalMarkups = doc.getNamedAnnotationSets().get("Original markups");
        AnnotationSet ancestorCites = originalMarkups.get("Citation", cite.getStartNode().getOffset(), cite.getEndNode().getOffset());
        return !ancestorCites.isEmpty();
    }

    private boolean isWithinTitleElement(Document doc, Annotation cite) {
        AnnotationSet originalMarkups = doc.getNamedAnnotationSets().get("Original markups");
        AnnotationSet titleElements = originalMarkups.get("Title", cite.getStartNode().getOffset(), cite.getEndNode().getOffset());
        return !titleElements.isEmpty();
    }

    private boolean isWithinQuotation(Document doc, Annotation cite) {
        AnnotationSet originalMarkups = doc.getNamedAnnotationSets().get("Original markups");
        AnnotationSet text = originalMarkups.get("Text", cite.getStartNode().getOffset(), cite.getEndNode().getOffset());
        if (text.isEmpty())
            return false;
        String before = gate.Utils.stringFor(doc, text.firstNode().getOffset(), cite.getStartNode().getOffset());
        long open = before.chars().filter(ch -> ch == '“').count();
        long close = before.chars().filter(ch -> ch == '”').count();
        return open > close;
    }

    private void replaceSuccessive(AnnotationSet newSuccessiveCites) {
        Document doc = newSuccessiveCites.getDocument();
        AnnotationSet originalMarkups = doc.getNamedAnnotationSets().get("Original markups");
        AnnotationSet newMarkups = doc.getAnnotations(AnnotationSet);
        Iterator<Annotation> iterator = newSuccessiveCites.iterator();
        while (iterator.hasNext()) {
            Annotation successive = iterator.next();
            if (isWithinMetadata(doc, successive))
                continue;
            if (isWithinOriginalCitation(doc, successive))
                continue;
            // the following finds the last <Citation> element preceding this successive cite within the same <Text>
            AnnotationSet text = originalMarkups.get("Text", successive.getStartNode().getOffset(), successive.getEndNode().getOffset());
            if (text.isEmpty())
                continue;
            AnnotationSet origCites = originalMarkups.get("Citation", text.firstNode().getOffset(), successive.getStartNode().getOffset());
            AnnotationSet newCites = newMarkups.get("Citation", text.firstNode().getOffset(), successive.getStartNode().getOffset());
            AnnotationSetImpl combined = new AnnotationSetImpl(origCites);
            combined.addAll(newCites);
            if (combined.isEmpty())
                continue;
            Annotation fullCite = combined.inDocumentOrder().get(combined.size() - 1);
            String citeClass = (String) fullCite.getFeatures().get("Class");
            if (!citeClass.startsWith("EuropeanUnion"))
                continue;
            int num1 = Integer.parseInt((String) successive.getFeatures().get("Number"));
            int num2 = Integer.parseInt((String) successive.getFeatures().get("Year"));
            EUNumbers numbers;
            try {
                numbers = EUNumbers.interpret(num1, num2);
            } catch (IllegalArgumentException e) {
                continue;
            }
            FeatureMap newFeatures = Factory.newFeatureMap();
            newFeatures.put("Class", citeClass);
            newFeatures.put("Year", numbers.year());
            newFeatures.put("Number", numbers.number());
            newMarkups.add(successive.getStartNode(), successive.getEndNode(), "Citation", newFeatures);
            logger.info("found successive cite: " + gate.Utils.stringFor(doc, successive) + " " + newFeatures.toString());
        }
        newMarkups.removeAll(newSuccessiveCites);
    }

    private String serialize(Document doc) {
        return doc.toXml(doc.getAnnotations(AnnotationSet), true);
    }

}
