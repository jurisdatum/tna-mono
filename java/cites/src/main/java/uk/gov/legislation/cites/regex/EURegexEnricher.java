package uk.gov.legislation.cites.regex;

import uk.gov.legislation.cites.Cite;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Deprecated
public class EURegexEnricher extends RegexEnricher {

    final Pattern[] patterns;

    public EURegexEnricher() {
        patterns = RegexEnricher.readPatterns("/old/eu_patterns.txt");
    }

    @Override
    protected Pattern[] patterns() { return patterns; }

    @Override
    protected Cite parse(Matcher match) {
        String text = match.group();
        String type = normalizeType(match.group(1));
        int num1 = Integer.parseInt(match.group(2));
        int num2 = Integer.parseInt(match.group(3));
        int year;
        int number;
        if (isYear(num1, earliestYear)) {
//            if (isYear(num2)) {
                year = normalizeYear(num1);
                number = num2;
//            } else {
//            }
        } else if (isYear(num2, earliestYear)) {
            year = normalizeYear(num2);
            number = num1;
        } else {
            return null;
        }
        return new Cite(text, type, year, number);
    }

    private String normalizeType(String type) {
        switch (type) {
            case "Regulation":
                return "EuropeanUnionRegulation";
            case "Decision":
                return "EuropeanUnionDecision";
            case "Directive":
                return "EuropeanUnionDirective";
            default:
                throw new IllegalArgumentException(type);
        }
    }

    static final int earliestYear = 1953;

}
