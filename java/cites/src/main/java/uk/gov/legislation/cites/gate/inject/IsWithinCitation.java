package uk.gov.legislation.cites.gate.inject;

import gate.AnnotationSet;
import uk.gov.legislation.cites.gate.CiteEnricher;

import java.util.function.Predicate;

public class IsWithinCitation implements Predicate<AnnotationSet> {

    @Override
    public boolean test(AnnotationSet set) {
        AnnotationSet newMarkups = set.getDocument().getNamedAnnotationSets().get(CiteEnricher.NewMarkups);
        AnnotationSet ancestors = newMarkups.get("Citation", set.firstNode().getOffset(), set.lastNode().getOffset());
        return !ancestors.isEmpty();
    }

}
