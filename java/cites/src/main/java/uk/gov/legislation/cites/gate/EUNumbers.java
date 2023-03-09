package uk.gov.legislation.cites.gate;

import java.time.Year;
import java.util.logging.Logger;

public class EUNumbers {

    private static final Logger logger = Logger.getAnonymousLogger();

    static final int earliestYear = 1953;
    static final int currentYear = Year.now().getValue();

    private final int year;
    private final int number;

    public int year() { return year; }
    public int number() { return number; }

    private EUNumbers(int year, int number) {
        this.year = year;
        this.number = number;
    }

    public static EUNumbers interpret(int first, int second) {
        boolean possible1 = isPossibleYear(first);
        boolean possible2 = isPossibleYear(second);
        if (!possible1 && !possible2)
            throw new IllegalArgumentException(first + "/" + second);
        if (!possible2)
            return new EUNumbers(normalizeYear(first), second);
        if (!possible1)
            return new EUNumbers(normalizeYear(second), first);

        int firstAsFourDigitYear = normalizeYear(first);
        int secondAsFourDigitYear = normalizeYear(second);

        // a year after 2014 should not be in the second position
        if (firstAsFourDigitYear >= 2015 && secondAsFourDigitYear > 2014)
            return new EUNumbers(firstAsFourDigitYear, second);
        // a year before 2015 should not be in the first position
        if (firstAsFourDigitYear < 2015 && secondAsFourDigitYear <= 2014)
            return new EUNumbers(secondAsFourDigitYear, first);

        // a year after 1998 should not be expressed in two digits
        boolean firstIsTwoDigitsThatWouldBeAfter1998 = first < 100 && firstAsFourDigitYear > 1998;
        boolean secondIsTwoDigitsThatWouldBeAfter1998 = second < 100 && secondAsFourDigitYear > 1998;
        if (firstIsTwoDigitsThatWouldBeAfter1998 && !secondIsTwoDigitsThatWouldBeAfter1998)
            return new EUNumbers(secondAsFourDigitYear, first);
        if (secondIsTwoDigitsThatWouldBeAfter1998 && !firstIsTwoDigitsThatWouldBeAfter1998)
            return new EUNumbers(firstAsFourDigitYear, second);

        // a year before 1999 was probably expressed in two digits
        boolean firstIsFourDigitsBefore1999 = first > 1000 && first < 1999;
        boolean secondIsFourDigitsBefore1999 = second > 1000 && second < 1999;
        if (firstIsFourDigitsBefore1999 && !secondIsFourDigitsBefore1999)
            return new EUNumbers(secondAsFourDigitYear, first);
        if (secondIsFourDigitsBefore1999 && !firstIsFourDigitsBefore1999)
            return new EUNumbers(firstAsFourDigitYear, second);

        logger.warning("ambiguous numbers: " + first + "/" + second);
        return new EUNumbers(normalizeYear(first), second);
    }

    static boolean isPossibleYear(int num) {
        if (num < 10)
            return false;
        if (num > currentYear)
            return false;
        if (num > 99 && num < earliestYear)
            return false;
        if (num < 100 && num > currentYear % 100 && num < earliestYear % 100)
            return false;
        return true;
    }

    static int normalizeYear(int year) {
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
