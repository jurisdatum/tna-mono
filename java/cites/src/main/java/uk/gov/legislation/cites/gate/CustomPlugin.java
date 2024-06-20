package uk.gov.legislation.cites.gate;

import org.jdom.Document;
import org.jdom.Element;
import uk.gov.legislation.cites.gate.plugin.DefActGazPopulator;
import uk.gov.legislation.cites.gate.plugin.OverlappingCiteRemover;

import java.net.MalformedURLException;
import java.net.URL;

public class CustomPlugin extends gate.creole.Plugin {

    private Class[] resourceClasses = new Class[] {
        EUNumberCorrector.class,
        UKTypeCorrector.class,
        OverlappingCiteRemover.class,
        DefActGazPopulator.class
    };

    /* This is all borrowed from the gate.creole.Plugin.Component class */

    public CustomPlugin() {
        try {
            this.baseURL = new URL(resourceClasses[0].getResource("/gate/creole/CreoleRegisterImpl.class"), ".");
        } catch (MalformedURLException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public String getName() {
        return this.resourceClasses[0].getName();
    }

    @Override
    public Document getCreoleXML() throws Exception {
        Document doc = new Document();
        Element element;
        doc.addContent(element = new Element("CREOLE-DIRECTORY"));
        element.addContent(element = new Element("CREOLE"));
        for (Class clazz: this.resourceClasses) {
            Element resourceElement = new Element("RESOURCE");
            element.addContent(resourceElement);
            Element classElement = new Element("CLASS");
            classElement.setText(clazz.getName());
            resourceElement.addContent(classElement);
        }
        return doc;
    }

}
