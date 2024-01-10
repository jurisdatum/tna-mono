import gate.util.GateException;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import uk.gov.legislation.cites.AllCiteRemover;
import uk.gov.legislation.cites.gate.CiteEnricher;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collection;

@RunWith(Parameterized.class)
public class CitationsTest {

    private static AllCiteRemover remover;
    private static CiteEnricher enricher;

    @BeforeClass
    public static void init() throws GateException {
        remover = new AllCiteRemover();
        enricher = new CiteEnricher();
    }

    @Parameterized.Parameters()
    public static Collection<Object[]> filenames() {
        return Arrays.asList(new Object[][] {
            { "nisr_2011_224" }, { "uksi_1994_935" }, { "uksi_2010_2493" }, { "wsi_2013_664" }, { "uksi_2005_1958" },
            { "nisr_2003_439" }
        });
    }

    @Parameterized.Parameter(value = 0)
    public String filename;

    @Test
    @Parameterized.Parameters
    public void one() throws IOException, GateException {
        byte[] original = CitationsTest.class.getResourceAsStream("/" + filename + ".original.xml").readAllBytes();
        byte[] expected = CitationsTest.class.getResourceAsStream("/" + filename + ".enriched.xml").readAllBytes();

        byte[] removed = new AllCiteRemover().remove(original);
        byte[] actual = new CiteEnricher().enrich(removed);

        Assert.assertArrayEquals(expected, actual);
    }

}
