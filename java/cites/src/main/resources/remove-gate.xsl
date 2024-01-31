<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
   xmlns:gate="http://www.gate.ac.uk" exclude-result-prefixes="gate">

<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" />

<xsl:template match="FootnoteRef">
    <xsl:copy copy-namespaces="no">
        <xsl:copy-of select="namespace::*[. != 'http://www.gate.ac.uk']" />
        <xsl:apply-templates select="@* except @gate:*" />
    </xsl:copy>
</xsl:template>

<xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
        <xsl:copy-of select="namespace::*[. != 'http://www.gate.ac.uk']" />
        <xsl:apply-templates select="@* except @gate:*">
            <xsl:sort select="local-name()" />
        </xsl:apply-templates>
        <xsl:apply-templates />
    </xsl:copy>
</xsl:template>

</xsl:transform>
