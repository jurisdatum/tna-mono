<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:local="local"
	exclude-result-prefixes="xs local">

<xsl:template match="Form">
	<xsl:apply-templates select="Reference" />
	<xsl:apply-templates select="* except Reference" />
</xsl:template>

<xsl:template match="Form/Number">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'FormNumber'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Form/TitleBlock">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Form/TitleBlock/Title">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'FormHeading'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Form/TitleBlock/Subtitle">	<!-- nisr/2003/37 -->
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'FormHeading'" />	<!-- probably should be different -->
	</xsl:call-template>
</xsl:template>

<xsl:template match="Form/Reference">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'FormReference'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Form/P">	<!-- ukpga/Geo5/1-2/34/enacted -->
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Form/P/Text">	<!-- ukpga/Geo5/1-2/34/enacted -->
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'Normal'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Form/IncludedDocument">	<!-- this doesn't work, see ssi/2020/27, probably related to LSseal issue -->
<!-- regular images work, see ssi/2020/21 -->
<!-- could it be related to the unknown width and height??? -->
	<xsl:param name="version-ref" as="element()?" select="()" tunnel="yes" />
	<xsl:variable name="index-of-drawing-element" as="xs:integer" select="local:get-index-of-drawing-element(., $version-ref)" />
	<xsl:variable name="ref" as="xs:string" select="@ResourceRef" />
	<xsl:variable name="resource" as="element(Resource)" select="key('resource', $ref)" />
	<xsl:variable name="uri" as="attribute(URI)" select="$resource/ExternalVersion/@URI" />
	<xsl:variable name="index-of-media-component" as="xs:integer" select="local:get-first-index-of-node($uri, $external-uris)" />
	<xsl:variable name="filename" as="xs:string" select="local:make-image-filename($uri)" />
	<xsl:variable name="width" as="xs:integer?" select="500" />
	<xsl:variable name="height" as="xs:integer?" select="500" />
	<w:p>
		<w:pPr>
		</w:pPr>
		<xsl:call-template name="image">
			<xsl:with-param name="index-of-drawing-element" select="$index-of-drawing-element" />
			<xsl:with-param name="index-of-media-component" select="$index-of-media-component" />
			<xsl:with-param name="filename" select="$filename" />
			<xsl:with-param name="width" select="$width" />
			<xsl:with-param name="height" select="$height" />
			<xsl:with-param name="alt-text" as="xs:string" select="concat('form ', $filename)" />
		</xsl:call-template>
	</w:p>
</xsl:template>

</xsl:transform>
