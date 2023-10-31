package uk.gov.legislation.cites.gate.inject;

import java.time.Year;
import java.util.function.Function;

public class NormalizeYear implements Function<Integer, Integer> {

    final int currentYear = Year.now().getValue();

    @Override
    public Integer apply(Integer year) {
        if (year > 999)
            return year;
        if (year > 99)
            throw new IllegalArgumentException(Integer.toString(year));
        int currentCentury = currentYear / 100 * 100;
        int currentTwoDigitYear = currentYear % 100;
        if (year <= currentTwoDigitYear)
            return currentCentury + year;
        int lastCentury = currentCentury - 100;
        return lastCentury + year;
    }

}
