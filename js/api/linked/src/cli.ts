
import { get as getTypes } from './types';
import { get as getYears } from './years';
import { get as getDocs } from './documents';

// getTypes().then(console.log);
getYears('ukpga').then(console.log);
