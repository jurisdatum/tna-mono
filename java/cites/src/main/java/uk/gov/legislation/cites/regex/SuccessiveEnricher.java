package uk.gov.legislation.cites.regex;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.Text;
import uk.gov.legislation.cites.Cite;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

class SuccessiveEnricher extends AbstractEnricher {

    static final Pattern pattern = Pattern.compile("^,? and (\\d+)/(\\d+)[;,\\.]");

    static final Set<String> types = new HashSet<>();
    static {
        types.add("UnitedKingdomStatutoryInstrument");
        types.add("EuropeanUnionRegulation");
        types.add("EuropeanUnionDecision");
        types.add("EuropeanUnionDirective");
    }
    static final Map<String, Integer> earliestYears = new HashMap<>();
    static {
        earliestYears.put("UnitedKingdomStatutoryInstrument", 1948);
        earliestYears.put("EuropeanUnionRegulation", 1958);
        earliestYears.put("EuropeanUnionDecision", 1953);
        earliestYears.put("EuropeanUnionDirective", 1959);
    }

    @Override
    protected void enrichText(Text node) {
        Node prev = node.getPreviousSibling();
        if (prev == null)
            return;
        if (!"Citation".equals(prev.getNodeName()))
            return;
        String type = ((Element) prev).getAttribute("Class");
        if (!types.contains(type))
            return;

        String text = node.getTextContent();
        Matcher matcher = pattern.matcher(text);
        if (!matcher.find())
            return;

        int num1 = Integer.parseInt(matcher.group(1));
        int num2 = Integer.parseInt(matcher.group(2));
        int year;
        int number;
        int earliestYear = earliestYears.get(type);
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
            return;
        }

        int start = matcher.start(1);
        int end = matcher.end(2);
        String beforeText = text.substring(0, start);
        String afterText = text.substring(end);
        Cite cite = new Cite(text.substring(start, end), type, year, number);
        logger.info("found cite: \"" + cite.text() + "\" within line: " + node.getParentNode().getTextContent().replaceAll("\\s+", " ").trim());

        replaceNode(node, beforeText, cite, afterText, false);
    }

}
