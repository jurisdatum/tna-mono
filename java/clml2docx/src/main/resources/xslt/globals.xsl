<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:local="local"
	exclude-result-prefixes="xs ukm dc local">

<xsl:variable name="document-category" as="xs:string" select="/Legislation/ukm:Metadata/*/ukm:DocumentClassification/ukm:DocumentCategory/@Value" />
<xsl:variable name="document-main-type" as="xs:string" select="/Legislation/ukm:Metadata/*/ukm:DocumentClassification/ukm:DocumentMainType/@Value" />
<xsl:variable name="document-number" as="xs:integer" select="/Legislation/ukm:Metadata/*/ukm:Number/@Value" />
<xsl:variable name="document-number-formatted" as="xs:string">
	<xsl:choose>
		<xsl:when test="$document-main-type = 'UnitedKingdomLocalAct'">
			<xsl:number value="$document-number" format="i" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="string($document-number)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>
<xsl:variable name="document-title" as="xs:string" select="/Legislation/ukm:Metadata/dc:title" />

<!-- dimensions -->

<xsl:variable name="page-width" as="xs:integer" select="xs:integer(round(210 * 56.7))" />	<!-- A4 -->	<!-- 210mm -->
<xsl:variable name="page-height" as="xs:integer" select="xs:integer(round(297 * 56.7))" />	<!-- A4 -->	<!-- 297mm -->
<xsl:variable name="margin-width" as="xs:integer" select="1440" />
<xsl:variable name="content-width" as="xs:integer" select="$page-width - (2 * $margin-width)" />
<xsl:variable name="indent-width" as="xs:integer" select="720" />


<!-- functions -->

<xsl:function name="local:get-all-indexes-of-node" as="xs:integer*">
	<xsl:param name="n" as="node()" />
	<xsl:param name="nodes" as="node()*" />
	<xsl:for-each select="$nodes">
		<xsl:if test=". is $n">
			<xsl:sequence select="position()" />
		</xsl:if>
	</xsl:for-each> 
</xsl:function>

<xsl:function name="local:get-first-index-of-node" as="xs:integer?">
	<xsl:param name="n" as="node()" />
	<xsl:param name="nodes" as="node()*" />
	<xsl:sequence select="local:get-all-indexes-of-node($n, $nodes)[1]" />
</xsl:function>

</xsl:transform>
