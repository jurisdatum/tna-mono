<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:gate="http://www.gate.ac.uk" exclude-result-prefixes="gate">

<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" />

<xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
        <xsl:copy-of select="namespace::*[. != 'http://www.gate.ac.uk']" />
        <xsl:apply-templates select="@* except @gate:*" />
        <xsl:apply-templates />
    </xsl:copy>
</xsl:template>

</xsl:transform>
