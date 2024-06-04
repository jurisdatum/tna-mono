package uk.gov.legislation.cites.gate.plugin;

import gate.Annotation;
import gate.AnnotationSet;
import gate.FeatureMap;
import gate.annotation.AnnotationSetImpl;
import gate.creole.metadata.CreoleResource;
import uk.gov.legislation.cites.gate.CiteEnricher;

import java.util.Iterator;
import java.util.function.Predicate;
import java.util.logging.Logger;
import java.util.regex.Pattern;

@CreoleResource(name = "Overlapping Cite Remover", comment = "remove new Cite if it overlaps with old one")
public class OverlappingCiteRemover extends gate.creole.AbstractLanguageAnalyser implements gate.LanguageAnalyser {

    private final Logger logger = Logger.getAnonymousLogger();

    private final Predicate<String> IsYear = Pattern.compile("^\\d{4}$").asMatchPredicate();

    @Override
    public void execute() {
        AnnotationSet oldMarkups = document.getAnnotations(CiteEnricher.OriginalMarkups);
        AnnotationSet newMarkups = document.getAnnotations(CiteEnricher.NewMarkups);
        AnnotationSetImpl toRemove = new AnnotationSetImpl(document);
        Iterator<Annotation> iterator = newMarkups.iterator();
        while (iterator.hasNext()) {
            Annotation newCite = iterator.next();
            AnnotationSet overlappingOldCites = oldMarkups.get("Citation", newCite.getStartNode().getOffset(), newCite.getEndNode().getOffset());
            if (overlappingOldCites.isEmpty()) {
                logger.info("found new cite: " + gate.Utils.stringFor(document, newCite));
                continue;
            }
            if (overlappingOldCites.size() == 1) {
                Annotation oldCite = overlappingOldCites.inDocumentOrder().get(0);
                FeatureMap oldFeatures = oldCite.getFeatures();
                FeatureMap newFeatures = newCite.getFeatures();
                String oldYear = (String) oldFeatures.get("Year");
                if (oldYear == null || !IsYear.test(oldYear)) { // uksi/2020/1528
                    logger.warning("old year is invalid: " + oldYear);
                    String oldType = (String) oldFeatures.get("Class");
                    Object oldNumber = oldFeatures.get("Number");
                    String newType = (String) newFeatures.get("Class");
                    Object newYear = newFeatures.get("Year");
                    Object newNumber = newFeatures.get("Number");
                    if (oldType.equals(newType) || (oldType.startsWith("European") && newType.startsWith("European"))) { // ssi/2005/311
                        oldFeatures.put("Year", newYear);
                        oldFeatures.put("Number", newNumber);
                        oldFeatures.remove("URI");
                        if (!oldType.equalsIgnoreCase(newType))
                            logger.info("changing type from " + oldType + " to " + newType);
                        logger.info("changing year from " + oldYear + " to " + newYear);
                        if (oldNumber == null)
                            oldNumber = "<empty>";
                        logger.info("changing number from " + oldNumber + " to " + newNumber);
                    }
                }
            }
            toRemove.add(newCite);
            logRemoval(newCite, overlappingOldCites);
        }
        newMarkups.removeAll(toRemove);
    }

    private void logRemoval(Annotation newCite, AnnotationSet overlappingOldCites) {
        Annotation oldCite = overlappingOldCites.iterator().next();
        logger.info("removing overlapping new cite: " + gate.Utils.stringFor(document, newCite) + " -- old cite: " + gate.Utils.stringFor(document, oldCite));

        String newClass = (String) newCite.getFeatures().get("Class");
        String oldClass = (String) oldCite.getFeatures().get("Class");
        if (!newClass.equals(oldClass))
            logger.warning("new class: " + newClass + " -- old class: " + oldClass);

        String newYear = (String) newCite.getFeatures().get("Year").toString();
        String oldYear = (String) oldCite.getFeatures().get("Year").toString();
        if (!newYear.equals(oldYear))
            logger.warning("new year: " + newYear + " -- old year: " + oldYear);

        String newNumber = (String) newCite.getFeatures().get("Number").toString().replaceFirst("^0+(?!$)", "");
        Object oldNumberObject = oldCite.getFeatures().get("Number");
        if (oldNumberObject == null) {
            logger.warning("new number: " + newNumber + " -- old number: null");
            return;
        }
        String oldNumber = (String) oldNumberObject.toString().replaceFirst("^0+(?!$)", "");
        if (!newNumber.equals(oldNumber))
            logger.warning("new number: " + newNumber + " -- old number: " + oldNumber);
    }

}
