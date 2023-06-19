<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:local="local"
	exclude-result-prefixes="xs ukm local">

<xsl:template name="core-properties">
	<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
		xmlns:dc="http://purl.org/dc/elements/1.1/"
		xmlns:dct="http://purl.org/dc/terms/"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
		<dc:title>
			<xsl:value-of select="/Legislation/ukm:Metadata/dc:title" />
		</dc:title>
<!-- 		<dc:subject/> -->
		<dc:creator>
			<xsl:text>CLML to DOCX transform</xsl:text>
		</dc:creator>
<!-- 		<cp:keywords/>
		<dc:description/> -->
		<cp:lastModifiedBy>
			<xsl:text>CLML to DOCX transform</xsl:text>
		</cp:lastModifiedBy>
		<cp:revision>1</cp:revision>
		<dct:created xsi:type="dct:W3CDTF">
			<xsl:value-of select="current-dateTime()" />
		</dct:created>
		<dct:modified xsi:type="dct:W3CDTF">
			<xsl:value-of select="current-dateTime()" />
		</dct:modified>
	</cp:coreProperties>
</xsl:template>

</xsl:transform>
