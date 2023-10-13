package uk.gov.legislation.cites.gate;

import gate.Factory;
import gate.FeatureMap;
import gate.LanguageAnalyser;
import gate.ProcessingResource;
import gate.creole.ResourceInstantiationException;
import gate.creole.SerialAnalyserController;

class Steps {

    static final String MainGrammar = "/Citations.jape";

    static void addMainGrammar(SerialAnalyserController sac) throws ResourceInstantiationException {
        addTransducer(sac, MainGrammar);
    }

    static void addLoneNumberStep(SerialAnalyserController sac) throws ResourceInstantiationException {
        copyAnnotations(sac, CiteEnricher.NewMarkups, null);
        addTransducer(sac,"/UKCitations3.jape");
    }

    private static void mysteryStep(SerialAnalyserController sac) throws ResourceInstantiationException {
        FeatureMap transferFeatures2 = Factory.newFeatureMap();
        transferFeatures2.put ("inputASName", "Original markups");
        transferFeatures2.put ("outputASName", null); // for default annotation set
        transferFeatures2.put ("copyAnnotations", true);
        ProcessingResource transfer2 = (ProcessingResource) Factory.createResource("gate.creole.annotransfer.AnnotationSetTransfer", transferFeatures2);
        sac.add(transfer2);
        FeatureMap transferFeatures3 = Factory.newFeatureMap();
        transferFeatures3.put ("inputASName", CiteEnricher.NewMarkups);
        transferFeatures3.put ("outputASName", null); // for default annotation set
        transferFeatures3.put ("copyAnnotations", true);
        ProcessingResource transfer3 = (ProcessingResource) Factory.createResource("gate.creole.annotransfer.AnnotationSetTransfer", transferFeatures3);
        sac.add(transfer3);
    }

    static void addRemove(SerialAnalyserController sac) throws ResourceInstantiationException {
        String temp = "TempForRemoval";
        copyAnnotations(sac, CiteEnricher.OriginalMarkups, temp);
        copyAnnotations(sac, CiteEnricher.NewMarkups, temp);
        FeatureMap features = Factory.newFeatureMap();
        features.put("grammarURL", Steps.class.getResource("/Remove.jape"));
        features.put("inputASName", temp);
        LanguageAnalyser transducer = (LanguageAnalyser) Factory.createResource("gate.creole.Transducer", features);
        sac.add(transducer);
    }

    static void addNamespaceCheck(SerialAnalyserController sac) throws ResourceInstantiationException {
        addTransducer(sac, "/Namespace.jape", CiteEnricher.NewMarkups);
    }

    static void addURIs(SerialAnalyserController sac) throws ResourceInstantiationException {
        addTransducer(sac,"/AddURIs.jape", CiteEnricher.NewMarkups);
    }

    /* helpers */

    private static void addTransducer(SerialAnalyserController sac, String grammar) throws ResourceInstantiationException {
        FeatureMap features = Factory.newFeatureMap();
        features.put("grammarURL", Steps.class.getResource(grammar));
        features.put("outputASName", CiteEnricher.NewMarkups);
        addTransducer(sac, features);
    }

    private static void addTransducer(SerialAnalyserController sac, String grammar, String inputASName) throws ResourceInstantiationException {
        FeatureMap features = Factory.newFeatureMap();
        features.put("grammarURL", Steps.class.getResource(grammar));
        features.put("inputASName", inputASName);
        features.put("outputASName", CiteEnricher.NewMarkups);
        addTransducer(sac, features);
    }

    private static void addTransducer(SerialAnalyserController sac, FeatureMap features) throws ResourceInstantiationException {
        LanguageAnalyser transducer = (LanguageAnalyser) Factory.createResource("gate.creole.Transducer", features);
        sac.add(transducer);
    }

    private static void copyAnnotations(SerialAnalyserController sac, String from, String to) throws ResourceInstantiationException {
        FeatureMap features = Factory.newFeatureMap();
        features.put ("inputASName", from);
        features.put ("outputASName", to); // null for default annotation set
        features.put ("copyAnnotations", true);
        ProcessingResource transfer = (ProcessingResource) Factory.createResource("gate.creole.annotransfer.AnnotationSetTransfer", features);
        sac.add(transfer);
    }

}
