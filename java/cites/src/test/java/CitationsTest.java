import gate.util.GateException;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import uk.gov.legislation.cites.AllCiteRemover;
import uk.gov.legislation.cites.gate.CiteEnricher;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
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
            { "nisr_2003_439" }, { "uksi_2015_1669" }, { "ssi_2009_189" }, { "uksi_1998_768" }
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

        String expected1 = new String(expected, StandardCharsets.UTF_8);
        String actual1 = new String(actual, StandardCharsets.UTF_8);

        Assert.assertEquals(filename, expected1, actual1);
    }

}
