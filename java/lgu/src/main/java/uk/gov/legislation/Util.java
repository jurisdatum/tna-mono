package uk.gov.legislation;

import java.util.Optional;

public class Util {

    public static String longToShortId(String id) {
        if (id.startsWith("http://www.legislation.gov.uk/id/"))
            return id.substring(33);
        return id;
    }

    public static Optional<String> longToShortType(String type) {
        switch (type) {
            case "EnglandAct":
                return Optional.of("aep");
            case "GreatBritainAct":
                return Optional.of("apgb");
            case "IrelandAct":
                return Optional.of("aip");
            case "NorthernIrelandAct":
                return Optional.of("nia");
            case "NorthernIrelandAssemblyMeasure":
                return Optional.of("mnia");
            case "NorthernIrelandParliamentAct":
                return Optional.of("apni");
            case "NorthernIrelandOrderInCouncil":
                return Optional.of("nisi");
            case "NorthernIrelandDraftOrderInCouncil":
                return Optional.empty();
            case "NorthernIrelandStatutoryRule":
                return Optional.of("nisr");
            case "NorthernIrelandStatutoryRuleOrOrder":
                return Optional.of("nisro");
            case "NorthernIrelandDraftStatutoryRule":
                return Optional.of("nidsr");
            case "ScottishAct":
                return Optional.of("asp");
            case "ScottishOldAct":
                return Optional.of("aosp");
            case "ScottishStatutoryInstrument":
                return Optional.of("ssi");
            case "ScottishDraftStatutoryInstrument":
                return Optional.of("sdsi");
            case "UnitedKingdomChurchInstrument":
                return Optional.of("ukci");
            case "UnitedKingdomChurchMeasure":
                return Optional.of("ukcm");
            case "UnitedKingdomPrivateAct":
                return Optional.empty();
            case "UnitedKingdomPublicGeneralAct":
                return Optional.of("ukpga");
            case "UnitedKingdomLocalAct":
                return Optional.of("ukla");
            case "UnitedKingdomMinisterialDirection":
                return Optional.of("ukmd");
            case "UnitedKingdomMinisterialOrder":
                return Optional.of("ukmo");
            case "UnitedKingdomStatutoryInstrument":
                return Optional.of("uksi");
            case "UnitedKingdomDraftStatutoryInstrument":
                return Optional.of("ukdsi");
            case "UnitedKingdomStatutoryRuleOrOrder":
                return Optional.of("uksro");
            case "WelshParliamentAct":
                return Optional.of("asc");
            case "WelshAssemblyMeasure":
                return Optional.of("mwa");
            case "WelshNationalAssemblyAct":
                return Optional.of("anaw");
            case "WelshStatutoryInstrument":
                return Optional.of("wsi");
            case "WelshDraftStatutoryInstrument":
                return Optional.empty();
            case "UnitedKingdomImpactAssessment":
                return Optional.empty();
            case "EuropeanUnionRegulation":
                return Optional.of("eur");
            case "EuropeanEconomicCommunityRegulation":
                return Optional.empty();
            case "EuropeanUnionDirective":
                return Optional.of("eudr");
            case "EuropeanUnionTreaty":
                return Optional.of("eut");
            case "EuropeanEconomicCommunityDirective":
                return Optional.empty();
            case "EuropeanUnionDecision":
                return Optional.of("eudn");
            case "EuropeanEconomicCommunityDecision":
                return Optional.empty();
            case "EuropeanUnionCorrigendum":
                return Optional.empty();
            case "EuropeanUnionOfficialJournal":
                return Optional.empty();
            case "EuropeanUnionOther":
                return Optional.empty();

            /* not in DocumentMainType */
            case "UnitedKingdomPrivateOrPersonalAct":
                return Optional.of("ukppa");
            case "GreatBritainLocalAct":
                return Optional.of("gbla");
            case "GreatBritainPrivateOrPersonalAct":
                return Optional.of("gbppa");

            default:
                return Optional.empty();
        }
    }

    public static Optional<String> shortToLongType(String type) {
        switch (type) {
            case "aep":
                return Optional.of("EnglandAct");
            case "apgb":
                return Optional.of("GreatBritainAct");
            case "aip":
                return Optional.of("IrelandAct");
            case "nia":
                return Optional.of("NorthernIrelandAct");
            case "mnia":
                return Optional.of("NorthernIrelandAssemblyMeasure");
            case "apni":
                return Optional.of("NorthernIrelandParliamentAct");
            case "nisi":
                return Optional.of("NorthernIrelandOrderInCouncil");
            case "NorthernIrelandDraftOrderInCouncil":
                return Optional.empty();
            case "nisr":
                return Optional.of("NorthernIrelandStatutoryRule");
            case "nisro":
                return Optional.of("NorthernIrelandStatutoryRuleOrOrder");
            case "nidsr":
                return Optional.of("NorthernIrelandDraftStatutoryRule");
            case "asp":
                return Optional.of("ScottishAct");
            case "aosp":
                return Optional.of("ScottishOldAct");
            case "ssi":
                return Optional.of("ScottishStatutoryInstrument");
            case "sdsi":
                return Optional.of("ScottishDraftStatutoryInstrument");
            case "ukci":
                return Optional.of("UnitedKingdomChurchInstrument");
            case "ukcm":
                return Optional.of("UnitedKingdomChurchMeasure");
            case "UnitedKingdomPrivateAct":
                return Optional.empty();
            case "ukpga":
                return Optional.of("UnitedKingdomPublicGeneralAct");
            case "ukla":
                return Optional.of("UnitedKingdomLocalAct");
            case "ukmd":
                return Optional.of("UnitedKingdomMinisterialDirection");
            case "ukmo":
                return Optional.of("UnitedKingdomMinisterialOrder");
            case "uksi":
                return Optional.of("UnitedKingdomStatutoryInstrument");
            case "ukdsi":
                return Optional.of("UnitedKingdomDraftStatutoryInstrument");
            case "uksro":
                return Optional.of("UnitedKingdomStatutoryRuleOrOrder");
            case "asc":
                return Optional.of("WelshParliamentAct");
            case "mwa":
                return Optional.of("WelshAssemblyMeasure");
            case "anaw":
                return Optional.of("WelshNationalAssemblyAct");
            case "wsi":
                return Optional.of("WelshStatutoryInstrument");
            case "WelshDraftStatutoryInstrument":
                return Optional.empty();
            case "UnitedKingdomImpactAssessment":
                return Optional.empty();
            case "eur":
                return Optional.of("EuropeanUnionRegulation");
            case "EuropeanEconomicCommunityRegulation":
                return Optional.empty();
            case "eudr":
                return Optional.of("EuropeanUnionDirective");
            case "eut":
                return Optional.of("EuropeanUnionTreaty");
            case "EuropeanEconomicCommunityDirective":
                return Optional.empty();
            case "eudn":
                return Optional.of("EuropeanUnionDecision");
            case "EuropeanEconomicCommunityDecision":
                return Optional.empty();
            case "EuropeanUnionCorrigendum":
                return Optional.empty();
            case "EuropeanUnionOfficialJournal":
                return Optional.empty();
            case "EuropeanUnionOther":
                return Optional.empty();

            /* not in DocumentMainType */
            case "ukppa":
                return Optional.of("UnitedKingdomPrivateOrPersonalAct");
            case "gbla":
                return Optional.of("GreatBritainLocalAct");
            case "gbppa":
                return Optional.of("GreatBritainPrivateOrPersonalAct");

            default:
                return Optional.empty();
        }
    }

}
