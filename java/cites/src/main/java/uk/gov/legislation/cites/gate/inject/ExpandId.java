package uk.gov.legislation.cites.gate.inject;

import java.util.function.BiFunction;

public class ExpandId implements BiFunction<String, String, String> {

    @Override
    public String apply(String id, String section) {
        String start = "http://www.legislation.gov.uk/id/" + id;
        if (section == null)
            return start;
        return start + "/" + MakeURI.pathComponentFromInternalId(section);
    }

}
