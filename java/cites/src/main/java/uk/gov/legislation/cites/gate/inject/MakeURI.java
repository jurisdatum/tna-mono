package uk.gov.legislation.cites.gate.inject;

import gate.Annotation;
import gate.FeatureMap;

import java.util.function.Function;

public class MakeURI implements Function<Annotation, String> {
    @Override
    public String apply(Annotation annotation) {
        FeatureMap features = annotation.getFeatures();
        String longType = (String) features.get("Class");
        Object year = features.get("Year"); // can be either String or Integer
        Object number = features.get("Number");
        if (number instanceof String)
            number = ((String) number).replaceFirst("^0+(?!$)", "");
        String section = (String) features.get("SectionRef");
        if (number == null)
            return null;
        String shortType = shortTypeFromLong(longType);
        if (shortType == null)
            return null;
        String start = "http://www.legislation.gov.uk/id/" + shortType + "/" + year + "/" + number;
        if (section == null)
            return start;
        return start + "/" + pathComponentFromInternalId(section);
    }

    private static String shortTypeFromLong(String longType) {
        switch (longType) {
            case "UnitedKingdomPublicGeneralAct":
                return "ukpga";
            case "UnitedKingdomLocalAct":
                return "ukla";
            case "ScottishAct":
                return "asp";
            case "WelshParliamentAct":
                return "asc";
            case "WelshNationalAssemblyAct":
                return "anaw";
            case "WelshAssemblyMeasure":
                return "mwa";
            case "UnitedKingdomChurchMeasure":
                return "ukcm";
            case "NorthernIrelandAct":
                return "nia";
            case "ScottishOldAct":
                return "aosp";
            case "EnglandAct":
                return "aep";
            case "IrelandAct":
                return "aip";
            case "GreatBritainAct":
                return "apgb";
            case "GreatBritainLocalAct":
                return "gbla";
            case "NorthernIrelandAssemblyMeasure":
                return "mnia";
            case "NorthernIrelandParliamentAct":
                return "apni";
            case "UnitedKingdomStatutoryInstrument":
                return "uksi";
            case "WelshStatutoryInstrument":
                return "wsi";
            case "ScottishStatutoryInstrument":
                return "ssi";
            case "NorthernIrelandOrderInCouncil":
                return "nisi";
            case "NorthernIrelandStatutoryRule":
                return "nisr";
            case "UnitedKingdomChurchInstrument":
                return "ukci";
            case "UnitedKingdomMinisterialDirection":
                return "ukmd";
            case "UnitedKingdomMinisterialOrder":
                return "ukmo";
            case "UnitedKingdomStatutoryRuleOrOrder":
                return "uksro";
            case "NorthernIrelandStatutoryRuleOrOrder":
                return "nisro";
            case "UnitedKingdomDraftPublicBill":
                return "ukdpb";
            case "UnitedKingdomDraftStatutoryInstrument":
                return "ukdsi";
            case "ScottishDraftStatutoryInstrument":
                return "sdsi";
            case "NorthernIrelandDraftStatutoryRule":
                return "nidsr";
            case "EuropeanUnionRegulation":
                return "eur";
            case "EuropeanUnionDecision":
                return "eudn";
            case "EuropeanUnionDirective":
                return "eudr";
            case "EuropeanUnionTreaty":
                return "eut";
            default:
                return null;
        }
    }

    static String pathComponentFromInternalId(String section) {
        int i = section.indexOf("crossheading");
        if (i == -1)
            return section.replace('-', '/');
        return section.substring(0, i).replace('-', '/') + section.substring(i);
    }

}
