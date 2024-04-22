package uk.gov.legislation.cites.gate.inject;

import gate.Annotation;
import gate.AnnotationSet;
import gate.annotation.AnnotationSetImpl;
import uk.gov.legislation.cites.gate.CiteEnricher;

import java.util.function.Function;

public class GetPrecedingCiteEU implements Function<AnnotationSet, Annotation> {

    @Override
    public Annotation apply(AnnotationSet set) {
        AnnotationSet originalMarkups = set.getDocument().getNamedAnnotationSets().get(CiteEnricher.OriginalMarkups);
        AnnotationSet newMarkups = set.getDocument().getNamedAnnotationSets().get(CiteEnricher.NewMarkups);
        AnnotationSet line = originalMarkups.get("Text", set.firstNode().getOffset(), set.lastNode().getOffset());
        if (line.isEmpty())
            line = originalMarkups.get("td", set.firstNode().getOffset(), set.lastNode().getOffset());
        if (line.isEmpty())
            line = originalMarkups.get("html:td", set.firstNode().getOffset(), set.lastNode().getOffset());
        if (line.isEmpty())
            return null;
        AnnotationSet origCites = originalMarkups.get("Citation", line.firstNode().getOffset(), set.firstNode().getOffset());
        AnnotationSet newCites = newMarkups.get("Citation", line.firstNode().getOffset(), set.firstNode().getOffset());
        AnnotationSet combinedCites = new AnnotationSetImpl(set.getDocument());
        combinedCites.addAll(origCites);
        combinedCites.addAll(newCites);

        if (combinedCites.isEmpty())
            return null;
        Annotation fullCite = combinedCites.inDocumentOrder().get(combinedCites.size() - 1);
        String fullCiteClass = (String) fullCite.getFeatures().get("Class");
        if (fullCiteClass == null)
            return null;
        if (!fullCiteClass.startsWith("European"))
            return null;

        if (!fullCiteClass.equals("EuropeanUnionOfficialJournal"))
            return fullCite;

        combinedCites.remove(fullCite);
        if (combinedCites.isEmpty())
            return null;
        fullCite = combinedCites.inDocumentOrder().get(combinedCites.size() - 1);
        fullCiteClass = (String) fullCite.getFeatures().get("Class");
        if (fullCiteClass == null)
            return null;
        if (!fullCiteClass.startsWith("European"))
            return null;
        if (fullCiteClass.equals("EuropeanUnionOfficialJournal"))
            return null;
        return fullCite;
    }

}
