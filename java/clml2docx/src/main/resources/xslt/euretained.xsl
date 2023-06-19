<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	exclude-result-prefixes="xs">


<xsl:template match="EURetained">
	<xsl:apply-templates>
		<xsl:with-param name="compact-format" select="false()" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<!-- prelims -->

<xsl:template match="EUPrelims">
	<xsl:comment>prelims</xsl:comment>
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="MultilineTitle">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="MultilineTitle/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'EUDocumentTitle'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="EUPrelims/Number">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'DocumentNumber'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="EUPrelims/IntroductoryText | EUPrelims/IntroductoryText/P">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="EUPrelims/IntroductoryText/P/Text">
	<w:p>
		<xsl:apply-templates />
	</w:p>
</xsl:template>

<xsl:template match="EUPreamble">
	<xsl:comment>preamble</xsl:comment>
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="EUPreamble//Division" mode="old">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="indent" select="if (exists(parent::EUPreamble)) then $indent else $indent + 1" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="EUPreamble//Division/Number" mode="old" />

<xsl:template match="EUPreamble//Division[empty(Number)]/Title" mode="old">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<w:p>
		<w:pPr>
			<w:pStyle w:val="EUPreamble" />
			<xsl:if test="$indent gt 0">
				<w:ind w:left="{ $indent * $indent-width }" />
			</xsl:if>
		</w:pPr>
		<xsl:apply-templates />
	</w:p>
</xsl:template>

<xsl:template match="EUPreamble//Division[exists(Number)]/Title" mode="old">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<w:p>
		<w:pPr>
			<w:pStyle w:val="EUPreambleNumbered" />
			<xsl:if test="$indent gt 0">
				<w:ind w:left="{ ($indent + 1) * $indent-width }" />
			</xsl:if>
		</w:pPr>
		<xsl:apply-templates select="preceding-sibling::Number/node()" />
		<w:r>
			<w:tab/>
		</w:r>
		<xsl:apply-templates />
	</w:p>
</xsl:template>

<xsl:template match="EUPreamble//Division[exists(Number)]/P[empty(preceding-sibling::*[not(self::Number)])]/Text[empty(preceding-sibling::*)]" priority="1"  mode="old">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<w:p>
		<w:pPr>
			<w:pStyle w:val="EUPreambleNumbered" />
			<xsl:if test="$indent gt 0">
				<w:ind w:left="{ ($indent + 1) * $indent-width }" />
			</xsl:if>
		</w:pPr>
		<xsl:apply-templates select="../../Number/node()" />
		<w:r>
			<w:tab/>
		</w:r>
		<xsl:apply-templates />
	</w:p>
</xsl:template>

<xsl:template match="EUPreamble/P">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="EUPreamble/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'EUPreamble'" />
	</xsl:call-template>
</xsl:template>


<!-- body -->

<xsl:template match="EUBody">
	<xsl:comment>body</xsl:comment>
	<xsl:apply-templates mode="eu">
		<xsl:with-param name="outline-level" as="xs:integer" select="-1" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="EUBody/P" mode="eu">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="EUBody/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>


<!-- big levels -->

<xsl:template match="EUPart | EUTitle | EUChapter | EUSection | EUSubsection">	<!-- e.g., if within Division, eudn/2006/463/adopted -->
	<xsl:apply-templates select="." mode="eu" />
</xsl:template>

<xsl:template match="EUPart | EUTitle | EUChapter | EUSection | EUSubsection" mode="eu">
	<xsl:call-template name="big-level" />
</xsl:template>

<xsl:template match="Number" mode="eu">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="concat(local-name(parent::*), 'Number')" />
		<xsl:with-param name="para-formatting" as="element()?">
			<xsl:call-template name="add-outline-level" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Title | Subtitle" mode="eu">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="concat(local-name(parent::*), 'Heading')" />
	</xsl:call-template>
</xsl:template>


<!-- provisions -->

<xsl:template match="EUPart/P | EUTitle/P | EUChapter/P | EUSection/P | EUSubsection/P" mode="eu">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="EUPart/P/Text | EUTitle/P/Text | EUChapter/P/Text | EUSection/P/Text | EUSubsection/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'Normal'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="P1group" mode="eu">
	<xsl:apply-templates select="* except Title" mode="eu" />
</xsl:template>

<xsl:template match="P1group/Title" mode="eu">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'EUArticleHeading'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="P1" mode="eu">
	<xsl:apply-templates mode="eu" />
</xsl:template>

<xsl:template match="P1/Pnumber" mode="eu">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'EUArticleNumber'" />
	</xsl:call-template>
	<xsl:if test="empty(parent::*/preceding-sibling::*[not(self::Title)]) and exists(parent::*/parent::P1group/child::Title)">
		<xsl:apply-templates select="parent::*/preceding-sibling::Title" mode="eu" />
	</xsl:if>
</xsl:template>

<xsl:template match="P1para" mode="eu">
	<xsl:apply-templates mode="eu" />
</xsl:template>

<xsl:template match="P1para/Text" mode="eu">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'EUArticleText'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="P2" mode="eu">
	<xsl:apply-templates select="." />
</xsl:template>

<xsl:template match="*" mode="eu">
	<xsl:apply-templates select="." />
</xsl:template>


<!-- divisions -->

<xsl:template match="Division" mode="eu">
	<xsl:apply-templates select="." />
</xsl:template>

<xsl:template match="Division[@Type=('EUPart','EUTitle','EUChapter','EUSection','EUSubsection')]">
	<xsl:call-template name="big-level" />
</xsl:template>

<xsl:template match="Division">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="indent" select="$indent + 1" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="Division/Number" />

<xsl:template match="Division[@Type=('EUPart','EUTitle','EUChapter','EUSection','EUSubsection')]/Number" priority="1">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="concat(parent::*/@Type, 'Number')" />
		<xsl:with-param name="para-formatting" as="element()?">
			<xsl:call-template name="add-outline-level" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Division/Title">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="empty(preceding-sibling::Title) and exists(preceding-sibling::Number)">	<!-- there can be multiple titles, e.g., eudn/2018/1303/adopted -->
			<w:p>
				<w:pPr>
					<w:pStyle w:val="Division" />
					<w:ind w:left="{ $indent * $indent-width }" />
				</w:pPr>
				<xsl:apply-templates select="preceding-sibling::Number/node()" />
				<w:r>
					<w:tab/>
				</w:r>
				<xsl:apply-templates />
			</w:p>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="p">
				<xsl:with-param name="style" select="'UnnumberedDivision'" />
				<xsl:with-param name="para-formatting" as="element(w:ind)">
					<w:ind w:left="{ $indent * $indent-width }" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="Division[@Type=('EUPart','EUTitle','EUChapter','EUSection','EUSubsection')]/Title" priority="1">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="concat(parent::*/@Type, 'Heading')" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Division/Subtitle">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'UnnumberedDivision'" />
		<xsl:with-param name="para-formatting" as="element(w:ind)">
			<w:ind w:left="{ $indent * $indent-width }" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Division/P | Division/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Division/P/Text | Division/Para/Text">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'Normal'" />
		<xsl:with-param name="para-formatting" as="element(w:ind)">
			<w:ind w:left="{ $indent * $indent-width }" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Division/P/BlockText/Text | Division/P/BlockText/Para/Text">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'Normal'" />
		<xsl:with-param name="para-formatting" as="element(w:ind)">
			<w:ind w:left="{ ($indent + 1) * $indent-width }" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Division[exists(Number)]/P[empty(preceding-sibling::*[not(self::Number)])]/Text[empty(preceding-sibling::*)]" priority="1">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<w:p>
		<w:pPr>
			<w:pStyle w:val="Division" />
			<w:ind w:left="{ $indent * $indent-width }" />
		</w:pPr>
		<xsl:apply-templates select="../../Number/node()" />
		<w:r>
			<w:tab/>
		</w:r>
		<xsl:apply-templates />
	</w:p>
</xsl:template>

<xsl:template match="Division[@Type='ANNEX']" priority="1">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Division[@Type='ANNEX']/Number" priority="1">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'ScheduleNumber'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Division[@Type='ANNEX']/Title" priority="1">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'ScheduleHeading'" />
	</xsl:call-template>
</xsl:template>


<!-- signature blocks -->

<xsl:template match="Signee/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Signee/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'SigneeText'" />
	</xsl:call-template>
</xsl:template>


<!-- annexes -->

<xsl:template match="EURetained/Schedules">
	<xsl:apply-templates mode="eu" />
</xsl:template>

<xsl:template match="Schedule" mode="eu">
	<xsl:param name="outline-level" as="xs:integer" select="-1" tunnel="yes" />
	<xsl:apply-templates mode="eu">
		<xsl:with-param name="outline-level" as="xs:integer" select="$outline-level + 1" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="Schedule/Number" mode="eu">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'EUAnnexNumber'" />
		<xsl:with-param name="para-formatting" as="element()">
			<xsl:call-template name="add-outline-level" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Schedule/Title" mode="eu">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'EUAnnexHeading'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="ScheduleBody" mode="eu">
	<xsl:apply-templates mode="eu" />
</xsl:template>


<!-- attachments -->

<xsl:template match="Attachments">
	<xsl:comment>attachments</xsl:comment>
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Attachments/Title">	<!-- eudn/2004/635/adopted -->
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'EUAnnexHeading'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Attachment">
	<xsl:comment>attachment</xsl:comment>
	<xsl:apply-templates />
</xsl:template>

</xsl:transform>
