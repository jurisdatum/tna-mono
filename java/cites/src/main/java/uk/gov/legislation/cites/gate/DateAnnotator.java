package uk.gov.legislation.cites.gate;

import gate.*;
import gate.creole.ResourceInstantiationException;
import gate.creole.SerialAnalyserController;
import gate.creole.gazetteer.Gazetteer;

import java.net.URL;

class DateAnnotator {

    static final String Grammar = "/Dates.jape";

    static final String AnnotationSet = "Dates";

    static void add(SerialAnalyserController controller) throws ResourceInstantiationException {

        Gazetteer gazetteer = (Gazetteer) Factory.createResource("gate.creole.gazetteer.DefaultGazetteer");
        URL lists = DateAnnotator.class.getResource("/annie/resources/gazetteer/lists.def");
        gazetteer.setListsURL(lists);
        gazetteer.init();
        controller.add(gazetteer);

        FeatureMap features = Factory.newFeatureMap();
        features.put("grammarURL", DateAnnotator.class.getResource(Grammar));
        features.put("outputASName", AnnotationSet);
        LanguageAnalyser analyser = (LanguageAnalyser) Factory.createResource("gate.creole.Transducer", features);
        controller.add(analyser);
    }

    static Annotation getFollowingDate(Annotation offset, Document doc, int limit) {
        AnnotationSet dates = doc.getAnnotations(AnnotationSet);
        return Utils.getNextAnnotationWithinSameText(offset, dates, "Date", limit);
    }

    static Integer getYear(Annotation date) {
        if (date == null)
            return null;
        String year = (String) date.getFeatures().get("Year");
        return Integer.valueOf(year);
    }

}
