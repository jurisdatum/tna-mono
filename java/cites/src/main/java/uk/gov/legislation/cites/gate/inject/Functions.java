package uk.gov.legislation.cites.gate.inject;

import gate.creole.SerialAnalyserController;

public class Functions {

    public static void addAll(SerialAnalyserController sac) {
        sac.getFeatures().put("romanToArabic", new RomanToArabic());
        sac.getFeatures().put("getPrecedingCite", new GetPrecedingCite());
        sac.getFeatures().put("isWithinCitation", new IsWithinCitation());
        sac.getFeatures().put("normalizeYear", new NormalizeYear());
        sac.getFeatures().put("makeURI", new MakeURI());
    }

}
