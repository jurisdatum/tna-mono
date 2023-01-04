package uk.gov.legislation.cites;

public class EmbeddedCite {

    private String section;

    private Cite cite;

    public String section() {
        return section;
    }
    public void setSection(String section) {
        this.section = section;
    }

    public Cite cite() {
        return cite;
    }
    public void setCite(Cite cite) {
        this.cite = cite;
    }

    public EmbeddedCite(String section, Cite cite) {
        this.section = section;
        this.cite = cite;
    }

}
