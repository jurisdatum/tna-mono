package uk.gov.legislation.cites;

public class EmbeddedCite {

    public static enum Part { Main, Intro, FN, EN, Comm }

    private Part part;

    private String section;

    private Cite cite;

    public Part part() { return part; }

    /**
     * @return the internal id of the nearest ancestor
     */
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

    public EmbeddedCite(Part part, String section, Cite cite) {
        this.part = part;
        this.section = section;
        this.cite = cite;
    }

}
