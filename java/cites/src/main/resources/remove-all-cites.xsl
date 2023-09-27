<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation">

<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" />

<xsl:strip-space elements="*" />

<xsl:template match="/">
    <xsl:variable name="removed">
        <xsl:apply-templates mode="remove" />
    </xsl:variable>
    <xsl:apply-templates select="$removed" mode="join" />
</xsl:template>

<!-- remove citations -->

<xsl:template match="Citation" mode="remove">
    <xsl:apply-templates mode="remove" />
</xsl:template>

<xsl:template match="Citation//Acronym" mode="remove">
    <xsl:apply-templates mode="remove" />
</xsl:template>

<xsl:template match="@*|node()" mode="remove">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="remove" />
    </xsl:copy>
</xsl:template>

<!-- join adjacent change elements -->

<xsl:template match="*[exists(child::Addition) or exists(child::Substitution) or exists(child::Repeal)]" mode="join">
    <xsl:copy>
        <xsl:apply-templates select="@*" mode="join" />
        <xsl:for-each-group select="node()" group-adjacent="concat(local-name(.), @ChangeId)">
            <xsl:choose>
                <xsl:when test="(exists(self::Addition) or exists(self::Substitution) or exists(self::Repeal)) and exists(@ChangeId)">
                    <xsl:if test="count(current-group()) > 1">
                        <xsl:message>
                            <xsl:text>merging </xsl:text>
                            <xsl:value-of select="count(current-group())" />
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="local-name(.)" />
                            <xsl:text> elements</xsl:text>
                        </xsl:message>
                    </xsl:if>
                    <xsl:copy>
                        <xsl:apply-templates select="@*" mode="join" />
                        <xsl:apply-templates select="current-group()/node()" mode="join" />
                    </xsl:copy>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="current-group()" mode="join" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:copy>
</xsl:template>

<xsl:template match="@*|node()" mode="join">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="join" />
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
