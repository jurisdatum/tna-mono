package uk.gov.legislation;

import net.sf.saxon.s9api.*;
import net.sf.saxon.value.Whitespace;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

public class Atom {

    private static final Map<String, String> namespaces = new HashMap<>();
    static {
        namespaces.put("", "http://www.w3.org/2005/Atom");
        namespaces.put("leg", "http://www.legislation.gov.uk/namespaces/legislation");
        namespaces.put("ukm", "http://www.legislation.gov.uk/namespaces/metadata");
    }

    public static final Feed NewLegislation = new Feed("https://www.legislation.gov.uk/new/data.feed");

    public static Feed getFeed(Legislation.Type type) {
        String url = "https://legislation.gov.uk/" + type.name() + "/data.feed";
        return new Feed(url);
    }
    public static Feed getFeed(Legislation.Type type, int year) {
        String url = "https://legislation.gov.uk/" + type.name() + "/" + year + "/data.feed";
        return new Feed(url);
    }

    public static class Feed {

        private final XPathCompiler compiler;

        private final String url;

        public Feed(String url) {
            this.url = url;
            Processor processor = new Processor(false);
            compiler = processor.newXPathCompiler();
            for (Map.Entry<String, String> namespace : namespaces.entrySet())
                compiler.declareNamespace(namespace.getKey(), namespace.getValue());
        }

        private Page fetch(int page) throws IOException {
            String url = this.url + "?page=" + page;
            HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
            connection.addRequestProperty("User-Agent", "Juris Datum");
            connection.connect();
            Page pg;
            try {
                InputStream stream = connection.getInputStream();
                try {
                    pg = new Page(stream, compiler);
                } finally {
                    stream.close();
                }
            } finally {
                connection.disconnect();
            }
            return pg;
        }

        public Iterator<Entry> entries() {
            return new I(this);
        }

    }

    private static class Page {

        private final XPathCompiler compiler;
        private final XdmNode root;
        private Page(InputStream input, XPathCompiler compiler) throws IOException {
            this.compiler = compiler;
            Source source = new StreamSource(input);
            DocumentBuilder builder = compiler.getProcessor().newDocumentBuilder();
            try {
                root = builder.build(source);
            } catch (SaxonApiException e) {
                throw new IOException("error parsing document", e);
            }
        }

        private List<Entry> entries() {
            return Xpath.eval(compiler, root, "/feed/entry").stream()
                .map(item -> new Entry(item, compiler)).collect(Collectors.toList());
        }

        private boolean hasNextPage() {
            String expression = "/feed/link[@rel='next']/@href";
            XdmValue next = Xpath.eval(compiler, root, expression);
            return next != null && next.size() != 0;
        }

    }

    public static class Entry {

        private final XdmItem entry;

        private final XPathCompiler compiler;

        private Entry(XdmItem item, XPathCompiler compiler) {
            this.entry = item;
            this.compiler = compiler;
        }

        public String longId() {
            return Xpath.eval1(compiler, entry, "id").getStringValue();
        }

        public String shortId() {
            return longId().substring(33);
        }

        public String longType() {
            return Xpath.eval1(compiler, entry, "ukm:DocumentMainType/@Value").getStringValue();
        }

        public int year() {
            String year = Xpath.eval1(compiler, entry, "ukm:Year/@Value").getStringValue();
            return Integer.parseInt(year);
        }

        public Optional<Integer> number() {
            XdmNode value = (XdmNode) Xpath.eval1(compiler, entry, "ukm:Number/@Value");
            if (value == null)
                return Optional.empty();
            return Optional.of(Integer.parseInt(value.getStringValue()));
        }

        public String title() {
            String title = Xpath.eval1(compiler, entry, "title").getStringValue();
            return Whitespace.collapseWhitespace(title);
        }

        private static final DateFormat format1 = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
        private static final DateFormat format2 = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'");
        static {
            TimeZone tz = TimeZone.getTimeZone("UTC");
            format1.setTimeZone(tz);
            format2.setTimeZone(tz);
        }

        public Date updated() {
            String expression = "updated";
            String updated = Xpath.eval1(compiler, entry, expression).getStringValue();
            try {
                return format1.parse(updated);
            } catch (ParseException e1) {
                try {
                    return format2.parse(updated);
                } catch (ParseException e2) {
                    throw new RuntimeException("unexpected date format: " + updated, e1);
                }
            }
        }
    }

    private static class I implements Iterator<Entry> {

        private final Atom.Feed feed;
        private int page = 0;

        private Iterator<Entry> entries;

        private boolean hasNextPage;

        private I(Feed feed) {
            this.feed = feed;
            fetchNextPage();
        }

        private void fetchNextPage() {
            page += 1;
            Page pg;
            try {
                pg = feed.fetch(page);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
            entries = pg.entries().iterator();
            hasNextPage = pg.hasNextPage();
        }

        @Override
        public boolean hasNext() {
            if (entries.hasNext())
                return true;
            if (hasNextPage) {
                fetchNextPage();
                return true;
            }
            return false;
        }

        @Override
        public Entry next() {
            return entries.next();
        }

    }

}
