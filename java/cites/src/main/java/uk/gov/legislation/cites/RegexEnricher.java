package uk.gov.legislation.cites;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.Text;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

abstract class RegexEnricher extends AbstractEnricher {

    protected Logger logger = Logger.getAnonymousLogger();

    protected static Pattern[] readPatterns(String resource) {
        InputStream stream = RegexEnricher.class.getResourceAsStream(resource);
        String text;
        try {
            text = new String(stream.readAllBytes(), StandardCharsets.UTF_8);
            stream.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return text.lines()
            .map(line -> { int i = line.indexOf('#'); return i == -1 ? line : line.substring(0, i); })
            .map(line -> line.trim())
            .filter(line -> !line.isEmpty())
            .map(line -> Pattern.compile(line))
            .toArray(Pattern[]::new);
    }

    protected abstract Pattern[] patterns();
    protected abstract Cite parse(Matcher match);

    @Override
    protected final void enrichText(Text node) {
        if (!shouldEnrich(node))
            return;
        for (Pattern pattern : patterns()) {
            boolean changed = enrich(node, pattern);
            if (changed)
                break;
        }
    }

    private boolean shouldEnrich(Text node) {
        if (node.getParentNode().getNodeType() != Node.ELEMENT_NODE)
            return false;
        Element parent = (Element) node.getParentNode();
        if ("Text".equals(parent.getTagName()))
            return true;
        if (parent.getParentNode().getNodeType() != Node.ELEMENT_NODE)
            return false;
        Element grandparent = (Element) parent.getParentNode();
        if ("Title".equals(parent.getTagName()))
            return !grandparent.getTagName().endsWith("Prelims");
        return false;
    }

    private boolean enrich(Text node, Pattern pattern) {
        String text = node.getTextContent();
        Matcher matcher = pattern.matcher(text);
        if (!matcher.find())
            return false;
        Cite cite = parse(matcher);
        if (cite == null)
            return false;
        logger.info("found cite: \"" + cite.text() + "\" within line: " + node.getParentNode().getTextContent().replaceAll("\\s+", " ").trim());
        String beforeText = text.substring(0, matcher.start());
        String afterText = text.substring(matcher.end());
        replaceNode(node, beforeText, cite, afterText, true);
        return true;
    }

}
