package uk.gov.legislation.cites;

import uk.gov.legislation.Util;

import java.util.Optional;

public class Cite {

    private String text;
    private String type;
    private int year;
    private int number;
    private String altNumber;

    public String text() {
        return text;
    }
//    public void setText(String text) {
//        this.text = text;
//    }

    public String type() {
        return type;
    }
//    public void setType(String type) {
//        this.type = type;
//    }

    public int year() {
        return year;
    }
//    public void setYear(int year) {
//        this.year = year;
//    }

    public int number() {
        return number;
    }
//    public void setNumber(int number) {
//        this.number = number;
//    }

    public String altNumber() {
        return altNumber;
    }
    public void setAltNumber(String altNum) {
        this.altNumber = altNum;
    }

    public Cite(String text, String type, int year, int number) {
        this.text = text;
        this.type = type;
        this.year = year;
        this.number = number;
    }
    public String url() {
        Optional<String> shortType = Util.longToShortType(type());
        if (shortType.isEmpty())
            return null;
        return "https://www.legislation.gov.uk/" + shortType.get() + "/" + year + "/" + number;
    }

}
