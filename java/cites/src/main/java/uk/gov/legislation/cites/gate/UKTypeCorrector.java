package uk.gov.legislation.cites.gate;

import gate.Annotation;
import gate.AnnotationSet;
import gate.creole.metadata.CreoleResource;

import java.util.Iterator;
import java.util.regex.Pattern;

@CreoleResource(name = "UK Type Corrector", comment = "adjust type of UK cites in footnotes")
public class UKTypeCorrector extends gate.creole.AbstractLanguageAnalyser implements gate.LanguageAnalyser {

    @Override
    public void execute() {
        AnnotationSet newMarkups = document.getAnnotations(CiteEnricher.NewMarkups);
        AnnotationSet newFullCites = newMarkups.get("Citation");
        Iterator<Annotation> iterator = newFullCites.iterator();
        while (iterator.hasNext()) {
            Annotation cite = iterator.next();
            String type = (String) cite.getFeatures().get("Class");
            if (!type.equals("UnitedKingdomPublicGeneralAct")) {
                continue;
            }
            Annotation footnote = Utils.getContainingFootnote(document, cite);
            if (footnote == null) {
                continue;
            }
            String fnTextBeforeCite;
            try {
                fnTextBeforeCite = gate.Utils.stringFor(document, footnote.getStartNode().getOffset(), cite.getStartNode().getOffset());
            } catch (gate.util.GateRuntimeException e) {
                e.printStackTrace();
                continue;
            }
            if (!fnTextBeforeCite.trim().isEmpty()) {
                continue;
            }
            String id = (String) footnote.getFeatures().get("id");
            Annotation fnRef = Utils.getFootnoteRef(document, id);
            if (fnRef == null) {
                continue;
            }
            String textBeforeRef = Utils.getTextBeforeFootnoteRef(document, fnRef);
            boolean nia = Pattern.compile("\\(Northern Ireland\\) \\d{4}$").matcher(textBeforeRef.trim()).find();
            if (!nia) {
                continue;
            }
            cite.getFeatures().put("Class", "NorthernIrelandAct");
        }
    }

}
