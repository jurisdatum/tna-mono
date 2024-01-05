package uk.gov.legislation.cites.gate;

import gate.*;
import gate.util.SimpleFeatureMapImpl;

import java.util.logging.Logger;

class Utils {

    private static final Logger logger = Logger.getAnonymousLogger();

    static Annotation getNextAnnotationWithinSameText(Annotation offset, AnnotationSet domain, String name) {
        AnnotationSet originalMarkups = domain.getDocument().getNamedAnnotationSets().get(CiteEnricher.OriginalMarkups);
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
        AnnotationSet newMarkups = doc.getAnnotations(CiteEnricher.NewMarkups);
        return getNextAnnotationWithinSameText(offset, newMarkups, "Citation", limit);
    }

    /**
     *
     * @param doc the Document
     * @param cite the Citation
     * @return true if the citation is within a footnote
     */
    static boolean isWithinFootnote(Document doc, Annotation cite) {
        AnnotationSet originalMarkups = doc.getNamedAnnotationSets().get(CiteEnricher.OriginalMarkups);
        AnnotationSet footnotes = originalMarkups.get("Footnote", cite.getStartNode().getOffset(), cite.getEndNode().getOffset());
        return !footnotes.isEmpty();
    }

    /**
     *
     * @param doc the Document
     * @param cite the Citation
     * @return the containing footnote or null
     */
    static Annotation getContainingFootnote(Document doc, Annotation cite) {
        AnnotationSet originalMarkups = doc.getNamedAnnotationSets().get(CiteEnricher.OriginalMarkups);
        AnnotationSet footnotes = originalMarkups.get("Footnote", cite.getStartNode().getOffset(), cite.getEndNode().getOffset());
        if (footnotes.isEmpty())
            return null;
        return footnotes.iterator().next();
    }

    /**
     * Gets a FootnoteRef by Ref attribute
     * @param doc the Document
     * @param ref the footnote id
     * @return a FootnoteRef annotation or null
     */
    static Annotation getFootnoteRef(Document doc, String ref) {
        AnnotationSet originalMarkups = doc.getNamedAnnotationSets().get(CiteEnricher.OriginalMarkups);
        FeatureMap map = new SimpleFeatureMapImpl();
        map.put("Ref", ref);
        AnnotationSet footnoteRefs = originalMarkups.get("FootnoteRef", map);
        if (footnoteRefs.isEmpty())
            return null;
        return footnoteRefs.iterator().next();
    }

    /**
     *
     * @param doc
     * @param fnRef
     * @return
     */
    static String getTextBeforeFootnoteRef(Document doc, Annotation fnRef) {
        AnnotationSet originalMarkups = doc.getNamedAnnotationSets().get(CiteEnricher.OriginalMarkups);
        AnnotationSet texts = originalMarkups.get("Text", fnRef.getStartNode().getOffset(), fnRef.getEndNode().getOffset());
        if (texts.isEmpty())
            return "";
        Annotation text = texts.iterator().next();
        return gate.Utils.stringFor(doc, text.getStartNode().getOffset(), fnRef.getStartNode().getOffset());
    }

    /**
     * Finds the next FootnoteRef within the same Text parent
     * @param offset the annotation to search after
     * @param doc the Document
     * @return a FootnoteRef annotation or null
     */
    static Annotation getNextFootnoteRef(Annotation offset, Document doc) {
        AnnotationSet originalMarkups = doc.getNamedAnnotationSets().get(CiteEnricher.OriginalMarkups);
        return getNextAnnotationWithinSameText(offset, originalMarkups, "FootnoteRef");
    }

    /**
     * Gets a Footnote by id
     * @param doc
     * @param id
     * @return a Footnote annotation or null
     */
    static Annotation getFootnote(Document doc, String id) {
        AnnotationSet originalMarkups = doc.getNamedAnnotationSets().get(CiteEnricher.OriginalMarkups);
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
        AnnotationSet newAnnotations = doc.getAnnotations(CiteEnricher.NewMarkups);
        Annotation fn = Utils.getFootnote(doc, id);
        if (fn == null) {
            logger.warning("couldn't find footnote with id " + id);
            return null;
        }
        Annotation cite = Utils.getFirstIncludedAnnotation(fn, newAnnotations, "Citation");
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
