<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
	exclude-result-prefixes="xs math m">

<xsl:include href="mathml2omml.xsl" />

<xsl:template match="Formula">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="equationNumber">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Formula/math:math">
	<w:p>
		<m:oMathPara>
			<xsl:next-match />
		</m:oMathPara>
	</w:p>
</xsl:template>

<xsl:template match="math:math">
	<m:oMath>
		<xsl:apply-templates select="*" mode="mml2omml" />
	</m:oMath>
<!-- 	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'Formula'" />
	</xsl:call-template> -->
</xsl:template>

<xsl:template match="math:*">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Where">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="indent" select="$indent + 1" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="Where/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Where/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'Normal'" />
	</xsl:call-template>
</xsl:template>
<xsl:template match="Where/Para/BlockText/Text | Where/Para/BlockText/Para/Text">
	<xsl:call-template name="block-text">
		<xsl:with-param name="style" select="'Normal'" />
	</xsl:call-template>
</xsl:template>

</xsl:transform>
