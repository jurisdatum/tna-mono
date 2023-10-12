package uk.gov.legislation.cites.gate;

import gate.*;
import gate.annotation.AnnotationSetImpl;
import gate.creole.*;
import gate.util.GateException;

import uk.gov.legislation.ClmlBeautifier;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CiteEnricher {

    static final String OriginalMarkups = "Original markups";
    static final String NewMarkups = "New markups";
    static final String Grammar = "/Citations.jape";
    private static final Logger logger = Logger.getAnonymousLogger();

    private final SerialAnalyserController sac;
    private final GateArtifactRemover artifactRemover = new GateArtifactRemover();
    private final ClmlBeautifier beautifier = new ClmlBeautifier();

    public CiteEnricher() throws GateException {
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

        AnnotationSet newAnnotations = doc.getAnnotations(NewMarkups);
        correctOJCites(newAnnotations.get("Citation"));
        correctFeatures(newAnnotations.get("Citation"));

        String enriched = serialize(doc);
        sac.getCorpus().remove(doc);
        return enriched;
    }

    /**
     * Adjusts the @Class, @Year and @Number attributes of EU cites that are not OJ cites,
     * and removes those with bad dates
     */
    private void correctFeatures(AnnotationSet newFullCites) {
        Document doc = newFullCites.getDocument();
        AnnotationSetImpl toRemove = new AnnotationSetImpl(doc);
        Iterator<Annotation> iterator = newFullCites.iterator();
        while (iterator.hasNext()) {
            Annotation cite = iterator.next();
            String text = gate.Utils.stringFor(doc, cite);
            FeatureMap features = cite.getFeatures();

            String c = (String) features.get("Class");
            if (!c.startsWith("EuropeanUnion"))
                continue;
            if (c.equals("EuropeanUnionOfficialJournal"))
                continue;

            int num1 = Integer.parseInt((String) features.get("Number"));
            int num2 = Integer.parseInt((String) features.get("Year"));
            Integer year = getYearFromFollowingDate(cite, doc);
            if (year == null)
                year = getYearFromFollowingOJCite(cite, doc);
            EUNumbers numbers;
            try {
                numbers = EUNumbers.interpret(num1, num2, year);
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
        doc.getAnnotations(NewMarkups).removeAll(toRemove);
    }

    private void correctOJCites(AnnotationSet newFullCites) {
        Document doc = newFullCites.getDocument();
        AnnotationSetImpl toRemove = new AnnotationSetImpl(doc);
        Iterator<Annotation> iterator = newFullCites.iterator();
        while (iterator.hasNext()) {
            Annotation cite = iterator.next();
            String c = (String) cite.getFeatures().get("Class");
            if (!c.equals("OfficialJournal"))
                continue;
            boolean ok = correctOJCite(cite);
            if (!ok)
                toRemove.add(cite);
        }
        doc.getAnnotations(NewMarkups).removeAll(toRemove);
    }

    private boolean correctOJCite(Annotation cite) {
        FeatureMap features = cite.getFeatures();
        String c = (String) features.get("Class");
        if (!c.startsWith("EuropeanUnion")) {
            c = "EuropeanUnion" + c;
            features.put("Class", c);
        }
        String series = (String) features.get("Series");
        String issue = (String) features.get("Issue");
        int year = Integer.parseInt((String) features.get("Year"));
        int month = Integer.parseInt((String) features.get("Month"));
        int day = Integer.parseInt((String) features.get("Day"));
        String page = (String) features.get("Page");
        try {
            year = EUNumbers.normalizeYear(year);
        } catch (IllegalArgumentException e) {
            return false;
        }
        if (month < 1 || month > 12)
            return false;
        if (day < 1 || day > 31)
            return false;
        features.remove("Series");
        features.remove("Issue");
        features.put("Year", year);
        features.remove("Month");
        features.remove("Day");
        features.remove("Page");
        String date = year + "-" + String.format("%02d", month) + "-" + String.format("%02d", day);
        features.put("Date", date);
        return true;
    }

    private Integer getYearFromFollowingOJCite(Annotation cite, Document doc) {
        Annotation next = Util.getNextNewCite(cite, doc, 50);
        // should also check that there are no annotations in between?
        if (next != null && "EuropeanUnionOfficialJournal".equals(next.getFeatures().get("Class"))) {
            logger.info("using year from following OJ cite: " + gate.Utils.stringFor(doc, next) + " " + next.getFeatures().toString());
            return (Integer) next.getFeatures().get("Year");
        }
        return getYearFromOJCiteInFollowingFootnote(cite, doc);
    }

    private Integer getYearFromOJCiteInFollowingFootnote(Annotation cite, Document doc) {
        Annotation fnRef = Util.getNextFootnoteRef(cite, doc);
        if (fnRef == null)
            return null;
        AnnotationSet originalMarkups = doc.getAnnotations(Util.OriginalMarkupsAnnotationSetName);
        AnnotationSet newAnnotations = doc.getAnnotations(NewMarkups);
        // if there is another citation before the footnote ref, don't consider the footnote
        Annotation next = Util.getNextAnnotationWithinSameText(cite, originalMarkups, "Citation");
        if (next != null && next.getStartNode().getOffset() < fnRef.getStartNode().getOffset())
            return null;
        next = Util.getNextAnnotationWithinSameText(cite, newAnnotations, "Citation");
        if (next != null && next.getStartNode().getOffset() < fnRef.getStartNode().getOffset())
            return null;
        String footnoteId = (String) fnRef.getFeatures().get("Ref");
        Annotation cite2 = Util.getNewCitationFromFootnote(doc, footnoteId);
        if (cite2 == null)
            return null;
        if ("EuropeanUnionOfficialJournal".equals(cite2.getFeatures().get("Class"))) {
            logger.info("using year from OJ cite in footnote " + footnoteId + ": " + gate.Utils.stringFor(doc, cite2) + " " + cite2.getFeatures().toString());
            return (Integer) cite2.getFeatures().get("Year");
        }
        return null;
    }

    private Integer getYearFromFollowingDate(Annotation cite, Document doc) {
        Annotation date = DateAnnotator.getFollowingDate(cite, doc, 20);
        if (date == null)
            return null;
        return DateAnnotator.getYear(date);
    }

    private String serialize(Document doc) {
        return doc.toXml(doc.getAnnotations(NewMarkups), true);
    }

}
