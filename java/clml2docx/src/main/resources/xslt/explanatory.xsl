<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	exclude-result-prefixes="xs">

<xsl:template match="ExplanatoryNotes | EarlierOrders">
	<xsl:comment>
		<xsl:value-of select="local-name()" />
	</xsl:comment>
	<xsl:if test="exists(self::ExplanatoryNotes) and empty(Title)">
		<w:p>
			<w:pPr>
				<w:pStyle w:val="ExplanatoryNotesHeading" />
			</w:pPr>
			<w:r>
				<w:t>Explanatory Note</w:t>
			</w:r>
		</w:p>
	</xsl:if>
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="ExplanatoryNotes/Title">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'ExplanatoryNotesHeading'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="EarlierOrders/Title">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'ExplanatoryNotesHeading'" />
		<xsl:with-param name="para-formatting" as="element()">
			<w:pageBreakBefore w:val="false" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="ExplanatoryNotes/Comment | ExplanatoryNotes/Comment/Para | EarlierOrders/Comment | EarlierOrders/Comment/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="ExplanatoryNotes/Comment/Para/Text | EarlierOrders/Comment/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'ExplanatoryNotesComment'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="ExplanatoryNotes/P | EarlierOrders/P">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="ExplanatoryNotes/P/CommentaryRef[following-sibling::*[1][self::Text]]">	<!-- nisr/2019/46/2019-05-07 -->
	<xsl:param name="force" as="xs:boolean" select="false()" />
	<xsl:if test="$force">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<xsl:template match="ExplanatoryNotes/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
		<xsl:with-param name="add-beginning-runs" as="element(w:r)*">
			<xsl:apply-templates select="preceding-sibling::*[1][self::CommentaryRef]">
				<xsl:with-param name="force" select="true()" />
			</xsl:apply-templates>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="ExplanatoryNotes/P/BlockText/Text | ExplanatoryNotes/P/BlockText/Para/Text">
	<xsl:call-template name="block-text">
		<xsl:with-param name="style" select="'Normal'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="EarlierOrders/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>

</xsl:transform>
