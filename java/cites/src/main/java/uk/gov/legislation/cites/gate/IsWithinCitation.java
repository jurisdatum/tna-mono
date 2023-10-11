package uk.gov.legislation.cites.gate;

import gate.AnnotationSet;

import java.util.function.Predicate;

public class IsWithinCitation implements Predicate<AnnotationSet> {

    @Override
    public boolean test(AnnotationSet set) {
        gate.AnnotationSet newMarkups = set.getDocument().getNamedAnnotationSets().get(CiteEnricher.NewMarkups);
        AnnotationSet ancestors = newMarkups.get("Citation", set.firstNode().getOffset(), set.lastNode().getOffset());
        return !ancestors.isEmpty();
    }

}
