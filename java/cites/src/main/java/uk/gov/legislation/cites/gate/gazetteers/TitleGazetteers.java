package uk.gov.legislation.cites.gate.gazetteers;

import gate.Factory;
import gate.FeatureMap;
import gate.LanguageAnalyser;
import gate.creole.ResourceInstantiationException;
import gate.creole.SerialAnalyserController;
import gate.creole.gazetteer.DefaultGazetteer;
import uk.gov.legislation.cites.gate.CiteEnricher;
import uk.gov.legislation.cites.gate.plugin.DefActGazPopulator;

import java.net.URL;

public class TitleGazetteers {

    public static void add(SerialAnalyserController sac) throws ResourceInstantiationException {
        addMainGazetteer(sac);
        addTransducer(sac, "/grammars/Definitions.jape", null, null);
        DefActGazPopulator.add(sac);
        addTransducer(sac, "/grammars/Titles.jape", null, CiteEnricher.NewMarkups);
    }
    public static void addMainGazetteer(SerialAnalyserController sac) throws ResourceInstantiationException {
        URL url = TitleGazetteers.class.getResource("/gazetteers/titles.def");
        FeatureMap params = Factory.newFeatureMap();
        params.put("listsURL", url);
        params.put("gazetteerFeatureSeparator", "\t");
        params.put("caseSensitive", false);
        DefaultGazetteer gaz = (DefaultGazetteer) Factory.createResource("gate.creole.gazetteer.DefaultGazetteer", params);
        sac.add(gaz);
    }

    private static void addTransducer(SerialAnalyserController sac, String grammar, String inputASName, String outputASName) throws ResourceInstantiationException {
        FeatureMap features = Factory.newFeatureMap();
        features.put("grammarURL", TitleGazetteers.class.getResource(grammar));
        features.put("inputASName", inputASName);
        features.put("outputASName", outputASName);
        LanguageAnalyser transducer = (LanguageAnalyser) Factory.createResource("gate.creole.Transducer", features);
        sac.add(transducer);
    }

}
