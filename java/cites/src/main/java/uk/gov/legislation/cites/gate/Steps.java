package uk.gov.legislation.cites.gate;

import gate.Factory;
import gate.FeatureMap;
import gate.LanguageAnalyser;
import gate.ProcessingResource;
import gate.creole.ResourceInstantiationException;
import gate.creole.SerialAnalyserController;

import uk.gov.legislation.cites.gate.plugin.OverlappingCiteRemover;
import uk.gov.legislation.cites.gate.plugin.OverlappingSubRefRemover;

class Steps {

    static void addAll(SerialAnalyserController sac) throws ResourceInstantiationException {
        addMainGrammar(sac);
        addRemove(sac);
        sac.add((LanguageAnalyser) Factory.createResource(EUNumberCorrector.class.getName()));
        sac.add((LanguageAnalyser) Factory.createResource(UKTypeCorrector.class.getName()));
        sac.add((LanguageAnalyser) Factory.createResource(OverlappingCiteRemover.class.getName()));
        addCiteIds(sac);
        subRefs(sac);
        addLoneNumberStep(sac); // this step won't add overlapping Citations
        sac.add((LanguageAnalyser) Factory.createResource(OverlappingSubRefRemover.class.getName()));
        addNamespaceCheck(sac);
        addURIs(sac);
    }

    private static void addMainGrammar(SerialAnalyserController sac) throws ResourceInstantiationException {
        addTransducer(sac, "/Citations.jape");
    }

    private static void addLoneNumberStep(SerialAnalyserController sac) throws ResourceInstantiationException {
        copyAnnotations(sac, CiteEnricher.NewMarkups, null); // null for default annotation set
        addTransducer(sac,"/UKCitations3.jape");
    }

    private static void addRemove(SerialAnalyserController sac) throws ResourceInstantiationException {
        String temp = "TempForRemoval";
        copyAnnotations(sac, CiteEnricher.OriginalMarkups, temp);
        copyAnnotations(sac, CiteEnricher.NewMarkups, temp);
        FeatureMap features = Factory.newFeatureMap();
        features.put("grammarURL", Steps.class.getResource("/Remove.jape"));
        features.put("inputASName", temp);
        LanguageAnalyser transducer = (LanguageAnalyser) Factory.createResource("gate.creole.Transducer", features);
        sac.add(transducer);
    }

    private static void addCiteIds(SerialAnalyserController sac) throws ResourceInstantiationException {
        addTransducer(sac,"/AddCiteIDs.jape", CiteEnricher.NewMarkups);
    }

    private static void subRefs(SerialAnalyserController sac) throws ResourceInstantiationException {
        String combined = "CombinedForSubRefs";
        copyAnnotations(sac, null, combined);
        copyAnnotations(sac, CiteEnricher.OriginalMarkups, combined);
        copyAnnotations(sac, CiteEnricher.NewMarkups, combined);
        FeatureMap features = Factory.newFeatureMap();
        features.put("grammarURL", Steps.class.getResource("/SubRefs.jape"));
        features.put("inputASName", combined);
        features.put("outputASName", CiteEnricher.NewMarkups);
        LanguageAnalyser transducer = (LanguageAnalyser) Factory.createResource("gate.creole.Transducer", features);
        sac.add(transducer);
    }

    private static void addNamespaceCheck(SerialAnalyserController sac) throws ResourceInstantiationException {
        addTransducer(sac, "/Namespace.jape", CiteEnricher.NewMarkups);
    }

    private static void addURIs(SerialAnalyserController sac) throws ResourceInstantiationException {
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
