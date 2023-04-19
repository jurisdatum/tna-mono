package uk.gov.legislation.cites.gate;

import gate.Annotation;
import gate.AnnotationSet;
import gate.Document;

class Util {

    /**
     * Finds the next newly recognized Citation annotation within the same Text parent.
     *
     * @param offset the annotation (Citation) to search after
     * @param doc the Document
     * @param limit the maximum number of characters allowable between the two Citations
     * @return a Citation annotation or null
     */
    static Annotation getNextNewCite(Annotation offset, Document doc, int limit) {
        AnnotationSet originalMarkups = doc.getNamedAnnotationSets().get("Original markups");
        AnnotationSet newMarkups = doc.getAnnotations(EUCiteEnricher.AnnotationSet);
        AnnotationSet text = originalMarkups.get("Text", offset.getStartNode().getOffset(), offset.getEndNode().getOffset());
        if (text.isEmpty())
            return null;
        AnnotationSet following = newMarkups.get("Citation", offset.getEndNode().getOffset(), text.lastNode().getOffset());
        if (following.isEmpty())
            return null;
        Annotation next = following.inDocumentOrder().get(0);
        long charsBetween = next.getStartNode().getOffset() - offset.getEndNode().getOffset();
        if (charsBetween > limit)
            return null;
        return next;
    }

}
