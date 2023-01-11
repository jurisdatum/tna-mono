package uk.gov.legislation.cites;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

class UKRegexEnricher extends RegexEnricher {

    final Pattern[] patterns;

    UKRegexEnricher() {
        patterns = RegexEnricher.readPatterns("/uk_patterns.txt");
    }

    @Override
    protected Pattern[] patterns() { return patterns; }

    @Override
    protected Cite parse(Matcher match) {
        String text = match.group();
        String type;
        try {
            type = match.group("type");
        } catch (IllegalArgumentException e) {
            type = null;
        }
        String type2;
        try {
            type2 = match.group("type2");
        } catch (IllegalArgumentException e) {
            type2 = null;
        }
        int year;
        try {
            year = Integer.parseInt(match.group("year"));
        } catch (IllegalArgumentException e) {
            throw new RuntimeException(match.pattern().toString(), e);
        }
        int number = Integer.parseInt(match.group("num"));
        type = normalizeType(type, year, type2);
        return new Cite(text, type, year, number);
    }

    private String normalizeType(String type, int year, String type2) {
        if (type == null) {
            if (year < 1707)
                return "EnglandAct";
            if (year < 1801)
                return "GreatBritainAct";
            return "UnitedKingdomPublicGeneralAct";
        }
        switch (type) {
            case "S.S.I.":
                return "ScottishStatutoryInstrument";
            case "S.I.":
                return "N.I.".equals(type2) ? "NorthernIrelandOrderInCouncil" : "UnitedKingdomStatutoryInstrument";
            case "asp":
                return "ScottishAct";
            case "N.I.":
                return "NorthernIrelandParliamentAct";
            case "S.R. (N.I.)":
                return "NorthernIrelandStatutoryRule";
            default:
                throw new IllegalArgumentException(type);
        }
    }

}
