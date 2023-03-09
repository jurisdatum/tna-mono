
import { getDatabaseConnection } from './db.mjs';

export const handler = async(event) => {
    if (event.queryStringParameters.to)
        return getCitesTo(event.queryStringParameters.to);
    if (event.queryStringParameters.from)
        return getCitesWithin(event.queryStringParameters.from);
    return Promise.resolve({ statusCode: 400, body: 'missing to/from parameter' });
};

function getCitesWithin(id) {
    const re = new RegExp('^[a-z]{3,5}/\\d{4}/\\d+$');
    if (!re.test(id))
        return Promise.resolve({ statusCode: 400, body: 'bad id' });
    return new Promise(function(resolve, reject) {
        getDatabaseConnection(function(err, connection) {
            if (err) {
                reject(err);
                return;
            }
            const sql = 'SELECT * FROM citations WHERE id = ?;';
            const params = [ id ];
            connection.query(sql, params, function(err, result) {
                if (err) {
                    reject(err);
                    return;
                }
                resolve(result);
            });
        });
    });
}

function getCitesTo(id) {
    const re = new RegExp('^[a-z]{3,5}/\\d{4}/\\d+$');
    if (!re.test(id))
        return Promise.resolve({ statusCode: 400, body: 'bad id' });
    const parts = id.split('/');
    const longType = shortToLongType(parts[0]);
    if (!longType)
        return Promise.resolve({ statusCode: 400, body: 'bad id' });
    return new Promise(function(resolve, reject) {
        getDatabaseConnection(function(err, connection) {
            if (err) {
                reject(err);
                return;
            }
            const sql = 'SELECT * FROM citations WHERE type = ? AND year = ? AND number = ?;';
            const params = [ longType, parseInt(parts[1]), parseInt(parts[2]) ];
            connection.query(sql, params, function(err, result) {
                if (err) {
                    reject(err);
                    return;
                }
                resolve(result);
            });
        });
    });
}

function shortToLongType(t) {
    switch (t) {
        case "aep":
            return "EnglandAct"
        case "apgb":
            return "GreatBritainAct"
        case "gbla":
            return "GreatBritainLocalAct"
        case "aip":
            return "IrelandAct"
        case "nia":
            return "NorthernIrelandAct"
        case "mnia":
            return "NorthernIrelandAssemblyMeasure"
        case "apni":
            return "NorthernIrelandParliamentAct"
        case "nisi":
            return "NorthernIrelandOrderInCouncil"
        case "NorthernIrelandDraftOrderInCouncil":
            return null;
        case "nisr":
            return "NorthernIrelandStatutoryRule"
        case "nisro":
            return "NorthernIrelandStatutoryRuleOrOrder"
        case "nidsr":
            return "NorthernIrelandDraftStatutoryRule"
        case "asp":
            return "ScottishAct"
        case "aosp":
            return "ScottishOldAct"
        case "ssi":
            return "ScottishStatutoryInstrument"
        case "sdsi":
            return "ScottishDraftStatutoryInstrument"
        case "ukci":
            return "UnitedKingdomChurchInstrument"
        case "ukcm":
            return "UnitedKingdomChurchMeasure"
        case "UnitedKingdomPrivateAct":
            return null;
        case "ukpga":
            return "UnitedKingdomPublicGeneralAct"
        case "ukla":
            return "UnitedKingdomLocalAct"
        case "ukmd":
            return "UnitedKingdomMinisterialDirection"
        case "ukmo":
            return "UnitedKingdomMinisterialOrder"
        case "uksi":
            return "UnitedKingdomStatutoryInstrument"
        case "ukdsi":
            return "UnitedKingdomDraftStatutoryInstrument"
        case "uksro":
            return "UnitedKingdomStatutoryRuleOrOrder"
        case "asc":
            return "WelshParliamentAct"
        case "mwa":
            return "WelshAssemblyMeasure"
        case "anaw":
            return "WelshNationalAssemblyAct"
        case "wsi":
            return "WelshStatutoryInstrument"
        case "WelshDraftStatutoryInstrument":
            return null;
        case "UnitedKingdomImpactAssessment":
            return null;
        case "eur":
            return "EuropeanUnionRegulation"
        case "EuropeanEconomicCommunityRegulation":
            return null;
        case "eudr":
            return "EuropeanUnionDirective"
        case "eut":
            return "EuropeanUnionTreaty"
        case "EuropeanEconomicCommunityDirective":
            return null;
        case "eudn":
            return "EuropeanUnionDecision"
        case "EuropeanEconomicCommunityDecision":
            return null;
        case "EuropeanUnionCorrigendum":
            return null;
        case "EuropeanUnionOfficialJournal":
            return null;
        case "EuropeanUnionOther":
            return null;

        /* not in DocumentMainType */
        case "ukppa":
            return "UnitedKingdomPrivateOrPersonalAct"
        case "gbla":
            return "GreatBritainLocalAct"
        case "gbppa":
            return "GreatBritainPrivateOrPersonalAct"

        default:
            return null;
    }
}