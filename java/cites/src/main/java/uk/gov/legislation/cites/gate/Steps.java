package uk.gov.legislation.cites.gate;

import gate.Factory;
import gate.FeatureMap;
import gate.LanguageAnalyser;
import gate.ProcessingResource;
import gate.creole.ResourceInstantiationException;
import gate.creole.SerialAnalyserController;

class Steps {

    static void copyAnnotations(SerialAnalyserController sac, String from, String to) throws ResourceInstantiationException {
        FeatureMap features = Factory.newFeatureMap();
        features.put ("inputASName", from);
        features.put ("outputASName", to); // null for default annotation set
        features.put ("copyAnnotations", true);
        ProcessingResource transfer = (ProcessingResource) Factory.createResource("gate.creole.annotransfer.AnnotationSetTransfer", features);
        sac.add(transfer);
    }

    static void addRemove(SerialAnalyserController sac) throws ResourceInstantiationException {
        String temp = "TempForRemoval";
        copyAnnotations(sac, CiteEnricher.OriginalMarkups, temp);
        copyAnnotations(sac, CiteEnricher.NewMarkups, temp);
        FeatureMap features = Factory.newFeatureMap();
        features.put("grammarURL", Steps.class.getResource("/Remove.jape"));
        features.put("inputASName", temp);
//        features.put("outputASName", temp);
        LanguageAnalyser transducer = (LanguageAnalyser) Factory.createResource("gate.creole.Transducer", features);
        sac.add(transducer);
    }

}
