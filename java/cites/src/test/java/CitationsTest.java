import gate.util.GateException;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import uk.gov.legislation.cites.AllCiteRemover;
import uk.gov.legislation.cites.gate.CiteEnricher;

import java.io.IOException;

public class CitationsTest {

    private static AllCiteRemover remover;
    private static CiteEnricher enricher;

    @BeforeClass
    public static void init() throws GateException {
        remover = new AllCiteRemover();
        enricher = new CiteEnricher();
    }

    @Test
    public void one() throws IOException, GateException {
        byte[] original = CitationsTest.class.getResourceAsStream("/nisr_2011_224.original.xml").readAllBytes();
        byte[] expected = CitationsTest.class.getResourceAsStream("/nisr_2011_224.enriched.xml").readAllBytes();

        byte[] removed = new AllCiteRemover().remove(original);
        byte[] actual = new CiteEnricher().enrich(removed);

        Assert.assertArrayEquals(expected, actual);
    }

}
