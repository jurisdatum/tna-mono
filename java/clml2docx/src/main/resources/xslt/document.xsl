<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	exclude-result-prefixes="xs">

<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" />

<xsl:include href="globals.xsl" />
<xsl:include href="metadata.xsl" />
<xsl:include href="sections.xsl" />
<xsl:include href="prelims1.xsl" />
<xsl:include href="prelims2.xsl" />
<xsl:include href="styles.xsl" />
<xsl:include href="body.xsl" />
<xsl:include href="amendments.xsl" />
<xsl:include href="lists.xsl" />
<xsl:include href="tables.xsl" />
<xsl:include href="images.xsl" />
<xsl:include href="forms.xsl" />
<xsl:include href="math.xsl" />
<xsl:include href="p.xsl" />
<xsl:include href="inline.xsl" />
<xsl:include href="links.xsl" />
<xsl:include href="misc.xsl" />
<xsl:include href="footnotes.xsl" />
<xsl:include href="schedules.xsl" />
<xsl:include href="signatures.xsl" />
<xsl:include href="explanatory.xsl" />
<xsl:include href="commentaries.xsl" />
<xsl:include href="toc.xsl" />
<xsl:include href="euretained.xsl" />

<xsl:template match="/">
	<w:document>
		<xsl:apply-templates />
	</w:document>
</xsl:template>

<xsl:template match="Legislation">
    <w:body>
    	<xsl:apply-templates />
   		<xsl:call-template name="body-section-properties" />
   		<!-- For all sections except the last section, the sectPr element is stored as a child element of the last paragraph in the section.
   		For the last section, the sectPr is stored as a child element of the body element. -->
    </w:body>
</xsl:template>

<xsl:template match="Primary">
	<xsl:apply-templates>
		<xsl:with-param name="compact-format" select="$document-main-type = 'NorthernIrelandAct'" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>
<xsl:template match="Secondary">
	<xsl:apply-templates>
		<xsl:with-param name="compact-format" select="true()" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="Versions" />

<xsl:template match="Resources" />

<xsl:template name="apply-templates-and-increment-outline-level">
	<xsl:param name="outline-level" as="xs:integer" select="-1" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="outline-level" as="xs:integer" select="$outline-level + 1" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template name="add-outline-level">
	<xsl:param name="within-extract" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:param name="outline-level" as="xs:integer" select="-1" tunnel="yes" />
	<xsl:if test="not($within-extract)">
		<w:outlineLvl w:val="{ $outline-level + 1 }" />
	</xsl:if>
</xsl:template>

<xsl:template match="IncludedDocument">
	<xsl:if test="$debug and exists(child::node())">
		<xsl:message terminate="yes">
			<xsl:text>incomplete handling of inline content within IncludedDocument</xsl:text>
		</xsl:message>
	</xsl:if>
	<xsl:apply-templates select="key('id', @ResourceRef)" mode="included-document" />
</xsl:template>

<xsl:template match="Resource" mode="included-document">
	<xsl:if test="$debug and not(every $child in * satisfies $child/self::InternalVersion)">
		<xsl:message terminate="yes">
			<xsl:text>incomplete handling of IncludedDocument</xsl:text>
		</xsl:message>
	</xsl:if>
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="InternalVersion">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="XMLcontent">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="XMLcontent//*" priority="-1">
	<xsl:choose>
		<xsl:when test="self::Text">
			<xsl:call-template name="p">
				<xsl:with-param name="style" select="'Normal'" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- versions -->

<xsl:key name="main-version" match="*[exists(@AltVersionRefs)]" use="tokenize(@AltVersionRefs)" />

<xsl:template name="insert-alt-versions">
	<xsl:param name="alt-version-refs" as="attribute()?" select="./@AltVersionRefs" />
	<xsl:if test="empty(ancestor::Version) and exists($alt-version-refs)">
		<xsl:variable name="alt-ids" as="xs:string*" select="tokenize($alt-version-refs)" />
		<xsl:for-each select="$alt-ids">
			<xsl:variable name="alt-version" as="element(Version)?" select="key('id', ., root($alt-version-refs))" />
			<xsl:apply-templates select="$alt-version/node()" />
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<!-- extent -->

<xsl:template name="show-extent">
	<xsl:param name="anchor" as="element()" select="." />
	<xsl:variable name="extent" as="xs:string?" select="$anchor/@RestrictExtent" />
	<xsl:variable name="other-extents" as="xs:string*">
		<xsl:choose>
			<xsl:when test="exists($anchor/parent::Version)">
				<xsl:variable name="version-id" as="xs:string?" select="$anchor/parent::*/@id" />
				<xsl:variable name="others" as="element()*" select="key('main-version', $version-id)" />
				<xsl:sequence select="$others/@RestrictExtent" />
			</xsl:when>
			<xsl:when test="exists($anchor/ancestor::Version)" />
			<xsl:otherwise>
				<xsl:variable name="version-refs" as="xs:string*" select="tokenize($anchor/@AltVersionRefs)" />
				<xsl:variable name="versions" as="element(Version)*">
					<xsl:for-each select="$version-refs">
						<xsl:sequence select="key('id', ., root($anchor))" />
					</xsl:for-each>
				</xsl:variable>
				<xsl:sequence select="$versions/child::*[1]/@RestrictExtent" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="exists($extent) and exists($other-extents) and not($extent = $other-extents)">
		<!-- tabs are not always the same length; also, tabs won't work in schedule numbers -->
		<w:r>
			<w:t xml:space="preserve">     </w:t>
		</w:r>
		<w:r>
			<w:rPr>
				<w:rStyle w:val="Extent" />
			</w:rPr>
			<w:t>
				<xsl:choose>
					<xsl:when test="$extent = 'E+W+S+N.I.'">
						<xsl:text>U.K.</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$extent" />
					</xsl:otherwise>
				</xsl:choose>
			</w:t>
		</w:r>
	</xsl:if>
</xsl:template>

</xsl:transform>
