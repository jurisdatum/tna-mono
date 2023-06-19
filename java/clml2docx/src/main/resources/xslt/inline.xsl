<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:local="local"
	exclude-result-prefixes="xs math local">

<!-- also add to xsl:preserve-space -->
<xsl:function name="local:is-inline" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<!-- EmphasisBasic -->
		<xsl:when test="$e/self::Strong">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Emphasis">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Inferior">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Superior">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::SmallCaps">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Uppercase">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Underline">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Expanded">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Strike">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Definition">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Proviso">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Abbreviation">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="local-name($e) = 'Abbreviation'">	<!-- error in anaw/2014/4/enacted -->
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Acronym">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Term">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Span">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Character">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Citation or $e/self::CitationSubRef">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::InternalLink">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::ExternalLink">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::FootnoteRef">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::MarginNoteRef">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Image">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::InlineAmendment">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::CommentaryRef">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Addition or $e/self::Substitution or $e/self::Repeal">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::math:math">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- EmphasisBasic -->

<xsl:template match="Strong">
	<xsl:param name="run-formatting" as="element()*" select="()" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="run-formatting" as="element()+" tunnel="yes">
			<xsl:sequence select="$run-formatting" />
			<w:b w:val="1" />
		</xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="Emphasis">
	<xsl:param name="run-formatting" as="element()*" select="()" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="run-formatting" as="element()+" tunnel="yes">
			<xsl:sequence select="$run-formatting" />
			<w:i w:val="1" />
		</xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="Inferior">
	<xsl:param name="run-formatting" as="element()*" select="()" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="run-formatting" as="element()+" tunnel="yes">
			<xsl:sequence select="$run-formatting" />
			<w:vertAlign w:val="subscript" />
		</xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="Superior">
	<xsl:param name="run-formatting" as="element()*" select="()" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="run-formatting" as="element()+" tunnel="yes">
			<xsl:sequence select="$run-formatting" />
			<w:vertAlign w:val="superscript" />
		</xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="SmallCaps">
	<xsl:param name="run-formatting" as="element()*" select="()" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="run-formatting" as="element()+" tunnel="yes">
			<xsl:sequence select="$run-formatting" />
			<w:smallCaps w:val="true" />
		</xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="Uppercase">
	<xsl:param name="run-formatting" as="element()*" select="()" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="run-formatting" as="element()+" tunnel="yes">
			<xsl:sequence select="$run-formatting" />
			<w:caps w:val="true" />
		</xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="Underline">
	<xsl:param name="run-formatting" as="element()*" select="()" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="run-formatting" as="element()+" tunnel="yes">
			<xsl:sequence select="$run-formatting" />
			<w:u w:val="single"/>
		</xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="Expanded">	<!-- eudn/2007/268/adopted -->
	<xsl:param name="run-formatting" as="element()*" select="()" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="run-formatting" as="element()+" tunnel="yes">
			<xsl:sequence select="$run-formatting" />
			<w:spacing w:val="60" />
		</xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="Strike">
	<xsl:param name="run-formatting" as="element()*" select="()" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="run-formatting" as="element()+" tunnel="yes">
			<xsl:sequence select="$run-formatting" />
			<w:strike w:val="true" />
		</xsl:with-param>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="Definition">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Proviso">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Abbreviation">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Acronym">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Term">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Span">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Character[@Name='EmSpace']">
	<w:r>
		<w:t xml:space="preserve">&#8195;</w:t>
	</w:r>
</xsl:template>
<xsl:template match="Character[@Name='EnSpace']">
	<w:r>
		<w:t xml:space="preserve">&#8194;</w:t>
	</w:r>
</xsl:template>
<xsl:template match="Character[@Name='NonBreakingSpace']">
	<w:r>
		<w:t xml:space="preserve">&#160;</w:t>
	</w:r>
</xsl:template>
<xsl:template match="Character[string(.)='NonBreakingSpace']">	<!-- error in uksi/2006/1471/2011-05-25 -->
	<w:r>
		<w:t xml:space="preserve">&#160;</w:t>
	</w:r>
</xsl:template>
<xsl:template match="Character[@Name='Minus']">
	<w:r>
		<w:t xml:space="preserve">&#8722;</w:t>
	</w:r>
</xsl:template>
<xsl:template match="Character[@Name='ThinSpace']">
	<w:r>
		<w:t xml:space="preserve">&#8201;</w:t>
	</w:r>
</xsl:template>
<xsl:template match="Character[@Name='DotPadding']">
	<xsl:comment>
		<xsl:text>dot padding</xsl:text>
	</xsl:comment>
</xsl:template>
<xsl:template match="Character[@Name='LinePadding']">
	<xsl:comment>
		<xsl:text>line padding</xsl:text>
	</xsl:comment>
</xsl:template>
<xsl:template match="Character[@Name='BoxPadding']">
	<xsl:comment>
		<xsl:text>box padding</xsl:text>
	</xsl:comment>
</xsl:template>

</xsl:transform>
