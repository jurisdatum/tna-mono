<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" /> <!-- suppress-indentation="Number Title Text" -->

<xsl:strip-space elements="*" />
<!--<xsl:preserve-space elements="Text Emphasis Strong Underline SmallCaps Superior Inferior Uppercase Underline Expanded Strike Definition Proviso Abbreviation Acronym Term Span Citation CitationSubRef InternalLink ExternalLink InlineAmendment Addition Substitution Repeal" />-->

<xsl:template match="@IdURI" />
<xsl:template match="@DocumentURI" />

<xsl:template match="*:UnappliedEffects" />

<xsl:template match="text()" priority="1">
    <xsl:variable name="normalized" select="normalize-space(.)" />
    <xsl:if test="matches(., '^\s')">
        <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="$normalized" />
    <xsl:if test="matches(., '\s$') and $normalized">
        <xsl:text> </xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="@*|node()">
    <xsl:copy>
        <xsl:apply-templates select="@*">
            <xsl:sort select="local-name()" />
        </xsl:apply-templates>
        <xsl:apply-templates />
    </xsl:copy>
</xsl:template>

</xsl:transform>
