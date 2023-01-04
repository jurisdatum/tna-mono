package uk.gov.legislation.cites;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.time.Year;
import java.util.regex.MatchResult;
import java.util.regex.Pattern;

class EURegexEnricher extends RegexEnricher {

    final Pattern[] patterns;

    EURegexEnricher() {
        InputStream stream = getClass().getResourceAsStream("/eu_patterns.txt");
        String text;
        try {
           text = new String(stream.readAllBytes(), StandardCharsets.UTF_8);
            stream.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        patterns = text.lines()
            .map(line -> { int i = line.indexOf('#'); return i == -1 ? line : line.substring(0, i); })
            .map(line -> line.trim())
            .filter(line -> !line.isEmpty())
            .map(line -> Pattern.compile(line))
            .toArray(Pattern[]::new);
    }

    @Override
    protected Pattern[] patterns() { return patterns; }

    @Override
    protected Cite parse(MatchResult match) {
        String text = match.group();
        String type = normalizeType(match.group(1));
        int num1 = Integer.parseInt(match.group(2));
        int num2 = Integer.parseInt(match.group(3));
        int year;
        int number;
        if (isYear(num1)) {
//            if (isYear(num2)) {
                year = normalizeYear(num1);
                number = num2;
//            } else {
//            }
        } else if (isYear(num2)) {
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
    static final int currentYear = Year.now().getValue();

    private boolean isYear(int num) {
        if (num < 10)
            return false;
        if (num > currentYear)
            return false;
        if (num > 99 && num < earliestYear)
            return false;
        return true;
    }

    private int normalizeYear(int year) {
        if (year > 999)
            return year;
        if (year > 99)
            throw new IllegalArgumentException();
        final int currentCentury = currentYear / 100 * 100;
        final int currentTwoDigitYear = currentYear % 100;
        if (year <= currentTwoDigitYear)
            return currentCentury + year;
        final int lastCentury = currentCentury - 100;
        return  lastCentury + year;
    }

}
