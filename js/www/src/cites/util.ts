import { Cite } from './cites';

export function longToShortType(type: string): string | null {
    switch (type) {
        case "EnglandAct":
            return "aep"
        case "GreatBritainAct":
            return "apgb"
        case "IrelandAct":
            return "aip"
        case "NorthernIrelandAct":
            return "nia"
        case "NorthernIrelandAssemblyMeasure":
            return "mnia"
        case "NorthernIrelandParliamentAct":
            return "apni"
        case "NorthernIrelandOrderInCouncil":
            return "nisi"
        case "NorthernIrelandDraftOrderInCouncil":
            return null;
        case "NorthernIrelandStatutoryRule":
            return "nisr"
        case "NorthernIrelandStatutoryRuleOrOrder":
            return "nisro"
        case "NorthernIrelandDraftStatutoryRule":
            return "nidsr"
        case "ScottishAct":
            return "asp"
        case "ScottishOldAct":
            return "aosp"
        case "ScottishStatutoryInstrument":
            return "ssi"
        case "ScottishDraftStatutoryInstrument":
            return "sdsi"
        case "UnitedKingdomChurchInstrument":
            return "ukci"
        case "UnitedKingdomChurchMeasure":
            return "ukcm"
        case "UnitedKingdomPrivateAct":
            return null;
        case "UnitedKingdomPublicGeneralAct":
            return "ukpga"
        case "UnitedKingdomLocalAct":
            return "ukla"
        case "UnitedKingdomMinisterialDirection":
            return "ukmd"
        case "UnitedKingdomMinisterialOrder":
            return "ukmo"
        case "UnitedKingdomStatutoryInstrument":
            return "uksi"
        case "UnitedKingdomDraftStatutoryInstrument":
            return "ukdsi"
        case "UnitedKingdomStatutoryRuleOrOrder":
            return "uksro"
        case "WelshParliamentAct":
            return "asc"
        case "WelshAssemblyMeasure":
            return "mwa"
        case "WelshNationalAssemblyAct":
            return "anaw"
        case "WelshStatutoryInstrument":
            return "wsi"
        case "WelshDraftStatutoryInstrument":
            return null;
        case "UnitedKingdomImpactAssessment":
            return null;
        case "EuropeanUnionRegulation":
            return "eur"
        case "EuropeanEconomicCommunityRegulation":
            return null;
        case "EuropeanUnionDirective":
            return "eudr"
        case "EuropeanUnionTreaty":
            return "eut"
        case "EuropeanEconomicCommunityDirective":
            return null;
        case "EuropeanUnionDecision":
            return "eudn"
        case "EuropeanEconomicCommunityDecision":
            return null;
        case "EuropeanUnionCorrigendum":
            return null;
        case "EuropeanUnionOfficialJournal":
            return null;
        case "EuropeanUnionOther":
            return null;

        /* not in DocumentMainType */
        case "UnitedKingdomPrivateOrPersonalAct":
            return "ukppa"
        case "GreatBritainLocalAct":
            return "gbla"
        case "GreatBritainPrivateOrPersonalAct":
            return "gbppa"

        default:
            return null;
      }
}

export function makeSectionLabelFromSectionId(id: string) {
    if (!id)
        return 'Unknown';
    if (id === 'introduction')
        return 'Introduction';
    if (id === 'note')
        return 'Explanatory Note';
    if (/^f\d{5}$/.test(id))
        return 'Footnote ' + id.substring(1).replace(/^0+/, '');
    let match = /^schedule-(\d+)-paragraph-/.exec(id);
    if (match)
        return 'Schedule ' + match[1] + ' Paragraph ' + id.substring(match[0].length).replaceAll('-', '.');
    const i = id.search(/\d/);
    if (i === -1)
        return id;
    return id.substring(0, i).replaceAll('-', ' ').split(' ').map(w => w.substring(0, 1).toUpperCase() + w.substring(1)).join(' ') +
        id.substring(i).replaceAll('-', '.');
}

export function makeLinkToDoc(docId: string, sectId: string | null): string {
    if (sectId)
        return 'https://www.legislation.gov.uk/' + docId + '#' + sectId;
    else
        return 'https://www.legislation.gov.uk/' + docId;
}

export function makeLinkToCite(cite: Cite): string | null {
    const t = longToShortType(cite.type);
    if (!t)
        return null;
    return 'https://www.legislation.gov.uk/' + t + '/' + cite.year + '/' + cite.number;
}
