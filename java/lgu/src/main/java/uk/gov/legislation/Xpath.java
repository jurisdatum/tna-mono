package uk.gov.legislation;

import net.sf.saxon.s9api.*;

class Xpath {

    static XdmValue eval(XPathCompiler compiler, XdmItem context, String expression) {
        XPathExecutable exec;
        try {
            exec = compiler.compile(expression);
        } catch (SaxonApiException e) {
            throw new RuntimeException("error compiling xpath expression", e);
        }
        XPathSelector selector = exec.load();
        try {
            selector.setContextItem(context);
        } catch (SaxonApiException e) {
            throw new RuntimeException("error setting context item", e);
        }
        XdmValue result;
        try {
            result = selector.evaluate();
        } catch (SaxonApiException e) {
            throw new RuntimeException("error evaluating xpath expression", e);
        }
        return result;
    }

    static XdmItem eval1(XPathCompiler compiler, XdmItem context, String expression) {
        XPathExecutable exec;
        try {
            exec = compiler.compile(expression);
        } catch (SaxonApiException e) {
            throw new RuntimeException("error compiling xpath expression", e);
        }
        XPathSelector selector = exec.load();
        try {
            selector.setContextItem(context);
        } catch (SaxonApiException e) {
            throw new RuntimeException("error setting context item", e);
        }
        XdmItem result;
        try {
            result = selector.evaluateSingle();
        } catch (SaxonApiException e) {
            throw new RuntimeException("error evaluating xpath expression", e);
        }
        return result;
    }

}
