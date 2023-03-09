package uk.gov.legislation;

import java.util.Arrays;
import java.util.EnumSet;

public class Legislation {

	public enum Type {
		ukpga, ukla, asp, asc, anaw, mwa, ukcm, nia, aosp, aep, aip, apgb, mnia, apni, ukppa, gbla, gbppa,
		uksi, wsi, ssi, nisi, nisr, ukci, ukmo, uksro, nisro,
		eur, eudn, eudr;
	}

	public enum Group {

		primary (Type.ukpga, Type.ukla, Type.asp, Type.asc, Type.anaw, Type.mwa, Type.ukcm, Type.nia, Type.aosp, Type.aep, Type.aip, Type.apgb, Type.mnia, Type.apni, Type.ukppa, Type.gbla, Type.gbppa),

		secondary (Type.uksi, Type.wsi, Type.ssi, Type.nisi, Type.nisr, Type.ukci, Type.ukmo, Type.uksro, Type.nisro),

		uk (Type.ukpga, Type.ukla, Type.asp, Type.asc, Type.anaw, Type.mwa, Type.ukcm, Type.nia, Type.aosp, Type.aep, Type.aip, Type.apgb, Type.mnia, Type.apni, Type.ukppa, Type.gbla, Type.gbppa,
			Type.uksi, Type.wsi, Type.ssi, Type.nisi, Type.nisr, Type.ukci, Type.ukmo, Type.uksro, Type.nisro),

		eu (Type.eur, Type.eudn, Type.eudr),

		all (Type.ukpga, Type.ukla, Type.asp, Type.asc, Type.anaw, Type.mwa, Type.ukcm, Type.nia, Type.aosp, Type.aep, Type.aip, Type.apgb, Type.mnia, Type.apni, Type.ukppa, Type.gbla, Type.gbppa,
			Type.uksi, Type.wsi, Type.ssi, Type.nisi, Type.nisr, Type.ukci, Type.ukmo, Type.uksro, Type.nisro,
			Type.eur, Type.eudn, Type.eudr);

		private final EnumSet<Type> types;

		private Group(Type... types) {
			this.types = EnumSet.copyOf(Arrays.asList(types));
		}

		public EnumSet<Type> types() {
			return types.clone();
		};
	}

}
