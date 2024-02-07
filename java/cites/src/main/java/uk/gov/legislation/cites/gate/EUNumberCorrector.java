package uk.gov.legislation.cites.gate;

import gate.Annotation;
import gate.AnnotationSet;
import gate.FeatureMap;
import gate.annotation.AnnotationSetImpl;
import gate.creole.metadata.CreoleResource;

import java.util.Iterator;

// https://gate.ac.uk/sale/talks/gate-course-jun19/module-8-developers/2-creole-writing/2-creole-writing.pdf

@CreoleResource(name = "EU Number Corrector", comment = "adjust year and number of EU cites")
public class EUNumberCorrector extends gate.creole.AbstractLanguageAnalyser implements gate.LanguageAnalyser {

    @Override
    public void execute() {  // throws ExecutionException
        AnnotationSet newMarkups = document.getAnnotations(CiteEnricher.NewMarkups);
        AnnotationSet newFullCites = newMarkups.get("Citation");
        AnnotationSetImpl toRemove = new AnnotationSetImpl(document);
        Iterator<Annotation> iterator = newFullCites.iterator();
        while (iterator.hasNext()) {
            Annotation cite = iterator.next();
//            String text = gate.Utils.stringFor(doc, cite);
            FeatureMap features = cite.getFeatures();

            String c = (String) features.get("Class");
            if (!c.startsWith("EuropeanUnion"))
                continue;
            if (c.equals("EuropeanUnionOfficialJournal"))
                continue;

            int num1 = Integer.parseInt((String) features.get("Number"));
            int num2 = Integer.parseInt((String) features.get("Year"));
            Integer year = getYearFromFollowingDate(cite);
            if (year == null)
                year = getYearFromFollowingOJCite(cite);
            EUNumbers numbers;
            try {
                numbers = EUNumbers.interpret(num1, num2, year);
            } catch (IllegalArgumentException e) {
//                logger.log(Level.WARNING, "removing cite: \"" + text + "\"", e);
                toRemove.add(cite);
                continue;
            }
            features.put("Year", numbers.year());
            features.put("Number", numbers.number());
//            logger.info("found cite: " + text + " " + features.toString());
            cite.setFeatures(features);
        }
        newMarkups.removeAll(toRemove);
    }

    private Integer getYearFromFollowingOJCite(Annotation cite) {
        Annotation next = Utils.getNextNewCite(cite, document, 50);
        // should also check that there are no annotations in between?
        if (next != null && "EuropeanUnionOfficialJournal".equals(next.getFeatures().get("Class"))) {
//            logger.info("using year from following OJ cite: " + gate.Utils.stringFor(doc, next) + " " + next.getFeatures().toString());
            Object year = next.getFeatures().get("Year");
            if (year instanceof Integer)
                return (Integer) year;
            if (year instanceof String)
                return Integer.parseInt((String) year);
            throw new IllegalStateException(year.getClass().getCanonicalName());
        }
        return getYearFromOJCiteInFollowingFootnote(cite);
    }

    private Integer getYearFromOJCiteInFollowingFootnote(Annotation cite) {
        Annotation fnRef = Utils.getNextFootnoteRef(cite, document);
        if (fnRef == null)
            return null;
        AnnotationSet originalMarkups = document.getAnnotations(CiteEnricher.OriginalMarkups);
        AnnotationSet newAnnotations = document.getAnnotations(CiteEnricher.NewMarkups);
        // if there is another citation before the footnote ref, don't consider the footnote
        Annotation next = Utils.getNextAnnotationWithinSameText(cite, originalMarkups, "Citation");
        if (next != null && next.getStartNode().getOffset() < fnRef.getStartNode().getOffset())
            return null;
        next = Utils.getNextAnnotationWithinSameText(cite, newAnnotations, "Citation");
        if (next != null && next.getStartNode().getOffset() < fnRef.getStartNode().getOffset())
            return null;
        String footnoteId = (String) fnRef.getFeatures().get("Ref");
        Annotation cite2 = Utils.getNewCitationFromFootnote(document, footnoteId);
        if (cite2 == null)
            return null;
        if ("EuropeanUnionOfficialJournal".equals(cite2.getFeatures().get("Class"))) {
//            logger.info("using year from OJ cite in footnote " + footnoteId + ": " + gate.Utils.stringFor(doc, cite2) + " " + cite2.getFeatures().toString());
            return (Integer) cite2.getFeatures().get("Year");
        }
        return null;
    }

    private Integer getYearFromFollowingDate(Annotation cite) {
        Annotation date = DateAnnotator.getFollowingDate(cite, document, 20);
        if (date == null)
            return null;
        return DateAnnotator.getYear(date);
    }

}
