package uk.gov.legislation.cites.gate;

import gate.Annotation;
import gate.AnnotationSet;

import java.util.function.Function;

class GetPrecedingCite implements Function<AnnotationSet, Annotation> {

    @Override
    public Annotation apply(AnnotationSet set) {
        gate.AnnotationSet originalMarkups = set.getDocument().getNamedAnnotationSets().get(CiteEnricher.OriginalMarkups);
        gate.AnnotationSet newMarkups = set.getDocument().getNamedAnnotationSets().get(CiteEnricher.NewMarkups);
        gate.AnnotationSet text = originalMarkups.get("Text", set.firstNode().getOffset(), set.lastNode().getOffset());
        if (text.isEmpty())
            return null;
        gate.AnnotationSet newCites = newMarkups.get("Citation", text.firstNode().getOffset(), set.firstNode().getOffset());
        if (newCites.isEmpty())
            return null;
        gate.Annotation fullCite = newCites.inDocumentOrder().get(newCites.size() - 1);
        if (fullCite.getEndNode().getOffset() >= set.firstNode().getOffset())
            return null;
        return fullCite;
//        AnnotationSet originalMarkups = doc.getNamedAnnotationSets().get("Original markups");
//        AnnotationSet ancestorCites = originalMarkups.get("Citation", cite.getStartNode().getOffset(), cite.getEndNode().getOffset());
//        return !ancestorCites.isEmpty();
    }

}
