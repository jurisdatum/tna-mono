package uk.gov.legislation.cites.gate;

import gate.Annotation;
import gate.AnnotationSet;
import gate.Document;
import gate.FeatureMap;
import gate.annotation.AnnotationSetImpl;

import java.util.Iterator;

class EUUtils {

    /**
     * Adjusts the @Class, @Year and @Number attributes of EU cites that are not OJ cites,
     * and removes those with bad dates
     */
    static void correctFeatures(Document doc) {
        AnnotationSet newMarkups = doc.getAnnotations(CiteEnricher.NewMarkups);
        AnnotationSet newFullCites = newMarkups.get("Citation");
        AnnotationSetImpl toRemove = new AnnotationSetImpl(doc);
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
            Integer year = getYearFromFollowingDate(cite, doc);
            if (year == null)
                year = getYearFromFollowingOJCite(cite, doc);
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

    static void correctOJCites(Document doc) {
        AnnotationSet newMarkups = doc.getAnnotations(CiteEnricher.NewMarkups);
        AnnotationSet newFullCites = newMarkups.get("Citation");
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
        newMarkups.removeAll(toRemove);
    }

    private static boolean correctOJCite(Annotation cite) {
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

    private static Integer getYearFromFollowingOJCite(Annotation cite, Document doc) {
        Annotation next = Utils.getNextNewCite(cite, doc, 50);
        // should also check that there are no annotations in between?
        if (next != null && "EuropeanUnionOfficialJournal".equals(next.getFeatures().get("Class"))) {
//            logger.info("using year from following OJ cite: " + gate.Utils.stringFor(doc, next) + " " + next.getFeatures().toString());
            return (Integer) next.getFeatures().get("Year");
        }
        return getYearFromOJCiteInFollowingFootnote(cite, doc);
    }

    private static Integer getYearFromOJCiteInFollowingFootnote(Annotation cite, Document doc) {
        Annotation fnRef = Utils.getNextFootnoteRef(cite, doc);
        if (fnRef == null)
            return null;
        AnnotationSet originalMarkups = doc.getAnnotations(CiteEnricher.OriginalMarkups);
        AnnotationSet newAnnotations = doc.getAnnotations(CiteEnricher.NewMarkups);
        // if there is another citation before the footnote ref, don't consider the footnote
        Annotation next = Utils.getNextAnnotationWithinSameText(cite, originalMarkups, "Citation");
        if (next != null && next.getStartNode().getOffset() < fnRef.getStartNode().getOffset())
            return null;
        next = Utils.getNextAnnotationWithinSameText(cite, newAnnotations, "Citation");
        if (next != null && next.getStartNode().getOffset() < fnRef.getStartNode().getOffset())
            return null;
        String footnoteId = (String) fnRef.getFeatures().get("Ref");
        Annotation cite2 = Utils.getNewCitationFromFootnote(doc, footnoteId);
        if (cite2 == null)
            return null;
        if ("EuropeanUnionOfficialJournal".equals(cite2.getFeatures().get("Class"))) {
//            logger.info("using year from OJ cite in footnote " + footnoteId + ": " + gate.Utils.stringFor(doc, cite2) + " " + cite2.getFeatures().toString());
            return (Integer) cite2.getFeatures().get("Year");
        }
        return null;
    }

    private static Integer getYearFromFollowingDate(Annotation cite, Document doc) {
        Annotation date = DateAnnotator.getFollowingDate(cite, doc, 20);
        if (date == null)
            return null;
        return DateAnnotator.getYear(date);
    }

}
