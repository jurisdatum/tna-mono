package uk.gov.legislation.cites.gate.plugin;

import gate.Annotation;
import gate.AnnotationSet;
import gate.annotation.AnnotationSetImpl;
import gate.creole.metadata.CreoleResource;
import uk.gov.legislation.cites.gate.CiteEnricher;

import java.util.Iterator;
import java.util.logging.Logger;

@CreoleResource(name = "Overlapping Cite Remover", comment = "remove new Cite if it overlaps with old one")
public class OverlappingCiteRemover extends gate.creole.AbstractLanguageAnalyser implements gate.LanguageAnalyser {

    private final Logger logger = Logger.getAnonymousLogger();

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
        String oldNumber = (String) oldCite.getFeatures().get("Number").toString().replaceFirst("^0+(?!$)", "");
        if (!newNumber.equals(oldNumber))
            logger.warning("new number: " + newNumber + " -- old number: " + oldNumber);
    }

}
