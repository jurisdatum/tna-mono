package uk.gov.legislation.db2.queues;

import java.util.function.Function;

class IdMapper {

    static Function<String, String> Instance = id -> id
        .replace('/', '_')
        .replace('&', '_');

}
