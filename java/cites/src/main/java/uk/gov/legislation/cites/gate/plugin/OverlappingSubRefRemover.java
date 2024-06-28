package uk.gov.legislation.cites.gate.plugin;

import gate.Annotation;
import gate.AnnotationSet;
import gate.annotation.AnnotationSetImpl;
import gate.creole.metadata.CreoleResource;
import uk.gov.legislation.cites.gate.CiteEnricher;

import java.util.Iterator;
import java.util.logging.Logger;

@CreoleResource(name = "Overlapping SubRef Remover", comment = "remove new SubRef if it overlaps with old one")
public class OverlappingSubRefRemover extends gate.creole.AbstractLanguageAnalyser implements gate.LanguageAnalyser {

    private final Logger logger = Logger.getAnonymousLogger();

    @Override
    public void execute() {
        AnnotationSet oldMarkups = document.getAnnotations(CiteEnricher.OriginalMarkups);
        AnnotationSet newMarkups = document.getAnnotations(CiteEnricher.NewMarkups);
        AnnotationSetImpl toRemove = new AnnotationSetImpl(document);
        Iterator<Annotation> iterator = newMarkups.get("CitationSubRef").iterator();
        while (iterator.hasNext()) {
            Annotation newCite = iterator.next();
            AnnotationSet overlappingOldCites = oldMarkups.get("CitationSubRef", newCite.getStartNode().getOffset(), newCite.getEndNode().getOffset());
            if (overlappingOldCites.isEmpty())
                continue;
            toRemove.add(newCite);
        }
        newMarkups.removeAll(toRemove);
    }

}
