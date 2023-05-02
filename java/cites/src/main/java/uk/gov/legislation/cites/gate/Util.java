package uk.gov.legislation.cites.gate;

import gate.*;
import gate.util.SimpleFeatureMapImpl;

import java.util.logging.Logger;

class Util {

    static final String OriginalMarkupsAnnotationSetName = "Original markups";

    private static final Logger logger = Logger.getAnonymousLogger();

    static Annotation getNextAnnotationWithinSameText(Annotation offset, AnnotationSet domain, String name) {
        AnnotationSet originalMarkups = domain.getDocument().getNamedAnnotationSets().get(OriginalMarkupsAnnotationSetName);
        AnnotationSet text = originalMarkups.get("Text", offset.getStartNode().getOffset(), offset.getEndNode().getOffset());
        if (text.isEmpty())
            return null;
        AnnotationSet following = domain.get(name, offset.getEndNode().getOffset(), text.lastNode().getOffset());
        if (following.isEmpty())
            return null;
        return following.inDocumentOrder().get(0);
    }

    static Annotation getNextAnnotationWithinSameText(Annotation offset, AnnotationSet domain, String name, int limit) {
        Annotation next = getNextAnnotationWithinSameText(offset, domain, name);
        if (next == null)
            return null;
        long charsBetween = next.getStartNode().getOffset() - offset.getEndNode().getOffset();
        if (charsBetween > limit)
            return null;
        return next;
    }

    /**
     * Finds the next newly recognized Citation annotation within the same Text parent.
     *
     * @param offset the annotation (Citation) to search after
     * @param doc the Document
     * @param limit the maximum number of characters allowable between the two Citations
     * @return a Citation annotation or null
     */
    static Annotation getNextNewCite(Annotation offset, Document doc, int limit) {
        AnnotationSet newMarkups = doc.getAnnotations(EUCiteEnricher.AnnotationSet);
        return getNextAnnotationWithinSameText(offset, newMarkups, "Citation", limit);
    }

    /**
     * Finds the next FootnoteRef within the same Text parent
     * @param offset the annotation to search after
     * @param doc the Document
     * @return a FootnoteRef annotation or null
     */
    static Annotation getNextFootnoteRef(Annotation offset, Document doc) {
        AnnotationSet originalMarkups = doc.getNamedAnnotationSets().get(OriginalMarkupsAnnotationSetName);
        return getNextAnnotationWithinSameText(offset, originalMarkups, "FootnoteRef");
    }

    /**
     * Gets a Footnote by id
     * @param doc
     * @param id
     * @return a Footnote annotation or null
     */
    static Annotation getFootnote(Document doc, String id) {
        AnnotationSet originalMarkups = doc.getNamedAnnotationSets().get(OriginalMarkupsAnnotationSetName);
        FeatureMap map = new SimpleFeatureMapImpl();
        map.put("id", id);
        AnnotationSet footnotes = originalMarkups.get("Footnote", map);
        if (footnotes.isEmpty())
            return null;
        return footnotes.iterator().next();
    }

    static AnnotationSet getIncludedAnnotations(Annotation ancestor, AnnotationSet domain, String name) {
        return domain.get(name, ancestor.getStartNode().getOffset(), ancestor.getEndNode().getOffset());
    }
    static Annotation getFirstIncludedAnnotation(Annotation ancestor, AnnotationSet domain, String name) {
        AnnotationSet all = getIncludedAnnotations(ancestor, domain, name);
        if (all.isEmpty())
            return null;
        return all.inDocumentOrder().get(0);
    }

    static Annotation getNewCitationFromFootnote(Document doc, String id) {
        AnnotationSet newAnnotations = doc.getAnnotations(EUCiteEnricher.AnnotationSet);
        Annotation fn = Util.getFootnote(doc, id);
        if (fn == null) {
            logger.warning("couldn't find footnote with id " + id);
            return null;
        }
        Annotation cite = Util.getFirstIncludedAnnotation(fn, newAnnotations, "Citation");
        if (cite == null) {
            logger.warning("footnote " + id + " contains no citations");
            return null;
        }
        String fnTextBeforeCite = gate.Utils.stringFor(doc, fn.getStartNode().getOffset(), cite.getStartNode().getOffset());
        fnTextBeforeCite = fnTextBeforeCite.replaceAll("\\s+", "").trim();
        String fnTextAfterCite = gate.Utils.stringFor(doc, cite.getEndNode().getOffset(), fn.getEndNode().getOffset());
        fnTextAfterCite = fnTextAfterCite.replaceAll("\\s+", "").trim();
        if (!fnTextBeforeCite.isEmpty()) {
            logger.warning("rejecting citation in footnote " + id + " because too much text before: " + fnTextBeforeCite);
            return null;
        }
        if (!fnTextAfterCite.isEmpty() && !".".equals(fnTextAfterCite)) {
            logger.warning("rejecting citation in footnote " + id + " because too much text after: " + fnTextAfterCite);
            return null;
        }
        return cite;
    }

}
