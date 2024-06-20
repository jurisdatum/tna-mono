package uk.gov.legislation.cites.gate.plugin;

import gate.Annotation;
import gate.AnnotationSet;
import gate.Factory;
import gate.FeatureMap;
import gate.creole.ResourceInstantiationException;
import gate.creole.SerialAnalyserController;
import gate.creole.gazetteer.DefaultGazetteer;
import gate.creole.gazetteer.Lookup;
import gate.creole.metadata.CreoleResource;

import java.net.URL;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

@CreoleResource(name = "Defined Act Gazetteer Populator", comment = "adds defined acts to a gazetteer")
public class DefActGazPopulator extends gate.creole.AbstractLanguageAnalyser implements gate.LanguageAnalyser {

    private static final String Key = "gaz";

    private DefaultGazetteer gaz;
    private Set<String> phrases = new HashSet<>();

    public DefaultGazetteer getGaz() { return gaz; }
    public void setGaz(DefaultGazetteer gaz) { this.gaz = gaz; }

    @Override
    public void execute() {

        for (String text: phrases)
            gaz.remove(text);

        AnnotationSet lookups2 = this.document.getAnnotations().get("Lookup2");
        for (Annotation lookup2: lookups2) {
            String text = gate.Utils.stringFor(this.document, lookup2);
            String majorType = (String) lookup2.getFeatures().get("majorType");
            String minorType = (String) lookup2.getFeatures().get("minorType");
            Lookup l = new Lookup("empty.lst", majorType, minorType, "en", "Lookup");
            l.features = new HashMap<>();
            l.features.put("year", lookup2.getFeatures().get("year"));
            l.features.put("number", lookup2.getFeatures().get("number"));
            l.features.put("id", lookup2.getFeatures().get("id"));
            gaz.add(text, l);
            phrases.add(text);
        }
    }

    public static void add(SerialAnalyserController sac) throws ResourceInstantiationException {
        DefaultGazetteer gaz = makeGazetteer();
        DefActGazPopulator pop = makePopulator(gaz);
        sac.add(pop);
        sac.add(gaz);
    }

    private static DefaultGazetteer makeGazetteer() throws ResourceInstantiationException {
        URL url = DefActGazPopulator.class.getResource("/gazetteers/empty.def");
        FeatureMap params = Factory.newFeatureMap();
        params.put("listsURL", url);
        DefaultGazetteer gaz = (DefaultGazetteer) Factory.createResource("gate.creole.gazetteer.DefaultGazetteer", params);
        return gaz;
    }

    private static DefActGazPopulator makePopulator(DefaultGazetteer gaz) throws ResourceInstantiationException {
        FeatureMap features = Factory.newFeatureMap();
        features.put(Key, gaz);
        return (DefActGazPopulator) Factory.createResource(DefActGazPopulator.class.getName(), features);
    }

}
