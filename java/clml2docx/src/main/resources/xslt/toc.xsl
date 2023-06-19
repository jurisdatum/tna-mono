<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	exclude-result-prefixes="xs">

<xsl:template match="Contents">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="ContentsGroup | ContentsPart | ContentsChapter | ContentsPblock | ContentsSchedules | ContentsSchedule | ContentsAppendix | ContentsDivision">
	<w:p>
		<xsl:apply-templates select="ContentsNumber | ContentsTitle" />
	</w:p>
	<xsl:apply-templates select="* except (ContentsNumber, ContentsTitle)" />
</xsl:template>

<xsl:template match="ContentsItem">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Contents/ContentsTitle">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="ContentsNumber | ContentsTitle">
	<xsl:apply-templates />
</xsl:template>

</xsl:transform>
