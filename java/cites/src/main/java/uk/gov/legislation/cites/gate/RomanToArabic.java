package uk.gov.legislation.cites.gate;

import java.util.function.Function;

class RomanToArabic implements Function<String, Integer> {

    @Override
    public Integer apply(String roman) {
        java.util.Map<Character, Integer> romanMap = new java.util.HashMap<>();
        romanMap.put('i', 1);
        romanMap.put('v', 5);
        romanMap.put('x', 10);
        romanMap.put('l', 50);
        romanMap.put('c', 100);
        int result = 0;
        int prevValue = 0;
        for (int i = roman.length() - 1; i >= 0; i--) {
            int currentValue = romanMap.get(roman.charAt(i));
            if (currentValue < prevValue) {
                result -= currentValue;
            } else {
                result += currentValue;
            }
            prevValue = currentValue;
        }
        return result;
    }

}
