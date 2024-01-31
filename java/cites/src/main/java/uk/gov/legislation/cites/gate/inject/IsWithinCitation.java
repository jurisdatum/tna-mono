package uk.gov.legislation.cites.gate.inject;

import gate.AnnotationSet;
import uk.gov.legislation.cites.gate.CiteEnricher;

import java.util.Map;
import java.util.function.Predicate;

public class IsWithinCitation implements Predicate<AnnotationSet> {

    @Override
    public boolean test(AnnotationSet set) {
        long first = set.firstNode().getOffset();
        long last = set.lastNode().getOffset();
        Map<String, AnnotationSet> sets = set.getDocument().getNamedAnnotationSets();
        AnnotationSet newMarkups = sets.get(CiteEnricher.NewMarkups);
        AnnotationSet origMarkups = sets.get(CiteEnricher.OriginalMarkups);

        if (!newMarkups.get("Citation", first, last).isEmpty())
            return true;
        if (!newMarkups.get("CitationSubRef", first, last).isEmpty())
            return true;

        if (!origMarkups.get("Citation", first, last).isEmpty())
            return true;
        if (!origMarkups.get("CitationSubRef", first, last).isEmpty())
            return true;

        return false;
    }

}
