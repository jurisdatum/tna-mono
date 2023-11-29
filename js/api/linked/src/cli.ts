
import { get as getTypes } from './types';
import { get as getYears } from './years';
import { get as getDocs } from './documents';
import { search } from './search';

// getTypes().then(console.log);
// getYears('UnitedKingdomPublicGeneralAct').then(console.log);
// getYears('ukpga').then(console.log);
// getDocs('UnitedKingdomPublicGeneralAct', 2023).then(console.log);
// getDocs('ukpga', 2023).then(console.log);
search('banana').then(console.log);
