<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs">

<xsl:template match="PrimaryPrelims">
	<xsl:call-template name="crest" />
	<xsl:choose>
		<xsl:when test="$document-main-type = 'ScottishAct'">
			<xsl:apply-templates select="Title | Number" />
			<xsl:apply-templates select="DateOfEnactment" />
			<xsl:apply-templates select="LongTitle" />
			<xsl:apply-templates select="PrimaryPreamble" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="crest">
	<xsl:variable name="dimensions" as="xs:integer+">
		<xsl:choose>
			<xsl:when test="$document-main-type = ('ScottishAct', 'ScottishOldAct')">
				<xsl:sequence select="(651,579,2627)" />	<!-- third is scaling factor so heights are the same -->
			</xsl:when>
			<xsl:when test="$document-main-type = ('WelshParliamentAct','WelshNationalAssemblyAct','WelshAssemblyMeasure')">
				<xsl:sequence select="(147,188,8090)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="(578,499,3048)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<w:p>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
		<xsl:call-template name="image">
			<xsl:with-param name="index-of-drawing-element" select="0" />
			<xsl:with-param name="index-of-media-component" select="0" />
			<xsl:with-param name="filename" select="'crest.png'" />
			<xsl:with-param name="width" select="$dimensions[1] * $dimensions[3]" />	<!-- 1764792 -->
			<xsl:with-param name="height" select="$dimensions[2] * $dimensions[3]" />	<!-- 1520952 -->
			<xsl:with-param name="alt-text" as="xs:string" select="'crest'" />
		</xsl:call-template>
	</w:p>
</xsl:template>

<xsl:template match="PrimaryPrelims/Title">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'DocumentTitle'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="PrimaryPrelims/Number">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'DocumentNumber'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="LongTitle">
	<w:p>
		<w:pPr>
			<w:pStyle w:val="LongTitle" />
		</w:pPr>
       	<xsl:apply-templates />
       	<xsl:if test="exists(following-sibling::DateOfEnactment)">
   			<w:r>
				<w:tab/>
			</w:r>
      		<xsl:apply-templates select="following-sibling::DateOfEnactment/*" />
       	</xsl:if>
	</w:p>
</xsl:template>

<xsl:template match="DateOfEnactment">
<!-- 	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="date-of-enactment-style-id" />
		</xsl:with-param>
	</xsl:call-template> -->
</xsl:template>

<xsl:template match="DateOfEnactment/DateText">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="DateOfEnactment/DateText/text()">
	<w:r>
		<w:t>
			<xsl:attribute name="xml:space">preserve</xsl:attribute>
			<xsl:value-of select="translate(., ' ', '&#160;')" />
		</w:t>
	</w:r>
</xsl:template>

<xsl:template match="PrimaryPreamble">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="PrimaryPreamble/IntroductoryText">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="PrimaryPreamble/IntroductoryText/P">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="PrimaryPreamble/IntroductoryText/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'PreambleIntro'" />
	</xsl:call-template>
</xsl:template>
<xsl:template match="PrimaryPreamble/IntroductoryText/P/BlockText/Text">
	<xsl:call-template name="block-text">
		<xsl:with-param name="style" select="'PreambleIntro'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="PrimaryPreamble/EnactingText">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="PrimaryPreamble/EnactingTextOmitted">	<!-- test with SPGA 1973 0025 -->
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="PrimaryPreamble/EnactingText/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="PrimaryPreamble/EnactingText/Para[1]/Text[1]" priority="1">
	<xsl:choose>
		<xsl:when test="child::node()[1][self::text()][string-length(.)=1] and child::node()[2][self::SmallCaps]">
			<w:p>
				<w:pPr>
					<w:pStyle w:val="EnactingText" />
	                <w:keepNext/>
	                <w:framePr w:dropCap="drop" w:lines="2" w:wrap="around" w:vAnchor="text" w:hAnchor="text" />
	                <w:spacing w:line="505" w:lineRule="exact" />	<!-- magic number -->
	                <!-- <w:textAlignment w:val="baseline"/> -->
				</w:pPr>
	            <w:r>
	                <w:rPr>
	                    <w:position w:val="-5"/>
	                    <w:sz w:val="64"/>
	                </w:rPr>
	                <w:t>
	                	<xsl:value-of select="child::node()[1]" />
	                </w:t>
	            </w:r>
			</w:p>
			<w:p>
				<w:pPr>
					<w:pStyle w:val="EnactingText" />
				</w:pPr>
		       	<xsl:apply-templates select="child::node()[position() gt 1]"/>
			</w:p>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="PrimaryPreamble/EnactingText/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'EnactingText'" />
	</xsl:call-template>
</xsl:template>


</xsl:transform>
