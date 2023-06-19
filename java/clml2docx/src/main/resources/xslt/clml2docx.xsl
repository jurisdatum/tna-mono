<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">

<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" />

<xsl:strip-space elements="*" />
<xsl:preserve-space elements="Text Emphasis Strong Underline SmallCaps Superior Inferior Uppercase Underline Expanded Strike Definition Proviso Abbreviation Acronym Term Span Citation CitationSubRef InternalLink ExternalLink InlineAmendment Addition Substitution Repeal" />
<!-- Character FootnoteRef CommentaryRef MarginNoteRef -->

<xsl:param name="cache" as="item()" required="yes" />
<xsl:param name="debug" as="xs:boolean" select="false()" />

<xsl:include href="aux/core.xsl" />
<xsl:include href="document.xsl" />
<xsl:include href="styles2.xsl" />
<xsl:include href="relationships.xsl" />

<xsl:key name="id" match="*" use="@id" />

<xsl:template match="*" priority="-100">
	<xsl:if test="$debug">
		<xsl:message>
			<xsl:text>no template for </xsl:text>
			<xsl:sequence select="." />
		</xsl:message>
		<xsl:message terminate="yes">
			<xsl:if test="exists(parent::*/parent::*/parent::*)">
				<xsl:value-of select="name(parent::*/parent::*/parent::*)" />
				<xsl:text>/</xsl:text>
			</xsl:if>
			<xsl:if test="exists(parent::*/parent::*)">
				<xsl:value-of select="name(parent::*/parent::*)" />
				<xsl:text>/</xsl:text>
			</xsl:if>
			<xsl:if test="exists(parent::*)">
				<xsl:value-of select="name(parent::*)" />
				<xsl:text>/</xsl:text>
			</xsl:if>
			<xsl:value-of select="name()" />
		</xsl:message>
	</xsl:if>
	<xsl:next-match />
</xsl:template>

</xsl:transform>
