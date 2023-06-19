<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:local="local"
	exclude-result-prefixes="xs local">

<!-- prelims -->

<xsl:template name="date-of-enactment-style-id">
	<xsl:choose>
		<xsl:when test="$document-main-type = 'ScottishAct'">
			<xsl:sequence select="'ASPDateOfEnactment'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'DateOfEnactment'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- body -->

<xsl:template name="group-number-style-id">
	<xsl:sequence select="'GroupNumber'" />
</xsl:template>

<xsl:template name="group-heading-style-id">
	<xsl:sequence select="'GroupHeading'" />
</xsl:template>

<xsl:template name="part-number-style-id">
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:sequence select="if ($inside-schedule) then 'SchedulePartNumber' else 'PartNumber'" />
</xsl:template>

<xsl:template name="part-heading-style-id">
	<xsl:sequence select="'PartHeading'" />
</xsl:template>

<xsl:template name="chapter-number-style-id">
	<xsl:sequence select="'ChapterNumber'" />
</xsl:template>

<xsl:template name="chapter-heading-style-id">
	<xsl:sequence select="'ChapterHeading'" />
</xsl:template>

<xsl:template name="crossheading-number-style-id">
	<xsl:sequence select="'CrossHeadingNumber'" />
</xsl:template>

<xsl:template name="crossheading-style-id">
	<xsl:sequence select="'CrossHeading'" />
</xsl:template>

<xsl:template name="subheading-number-style-id">
	<xsl:sequence select="'SubHeadingNumber'" />
</xsl:template>

<xsl:template name="subheading-style-id">
	<xsl:sequence select="'SubHeading'" />
</xsl:template>

<xsl:template name="unnumbered-section-heading-style-id">
	<xsl:sequence select="'UnnumberedSectionHeading'" />
</xsl:template>

<!-- typical P1 with number and heading -->
<xsl:template name="numbered-section-heading-style-id">
	<xsl:sequence select="'NumberedSectionHeading'" />
</xsl:template>

<!-- first paragraph of P1 with no heading -->
<xsl:template name="numbered-section-style-id">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$inside-schedule">
			<xsl:sequence select="'ScheduleParagraph'" />
		</xsl:when>
		<xsl:when test="$compact-format">
			<xsl:sequence select="'SectionCompact'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'NumberedSection'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="run-formatting-for-p1-number">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$inside-schedule">
			<xsl:if test="$is-secondary">
				<w:b w:val="true"/>
			</xsl:if>
		</xsl:when>
		<xsl:when test="$compact-format">
			<w:b w:val="true"/>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template name="punctuation-after-p1-number">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$inside-schedule">
			<xsl:if test="$is-secondary">
				<xsl:sequence select="'.'" />
			</xsl:if>
		</xsl:when>
		<xsl:when test="$compact-format">
			<xsl:sequence select="'.'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="section-text-style-id">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$compact-format">
			<xsl:sequence select="'SectionTextCompact'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'SectionText'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- P1 and P2 together -->

<xsl:template name="p1-with-p2-style-id">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$inside-schedule">
			<xsl:call-template name="schedule-paragraph-and-subparagraph-style-id" />
		</xsl:when>
		<xsl:when test="$compact-format">
			<xsl:sequence select="'SectionAndSubsectionCompact'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'SectionAndSubsection'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- P2 -->

<xsl:template name="subsection-group-heading-style-id">	<!-- for P2groups -->
	<xsl:sequence select="'SubsectionGroupHeading'" />
</xsl:template>

<xsl:template name="subsection-heading-style-id">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$inside-schedule">
			<xsl:call-template name="schedule-subparagraph-style-id" />
		</xsl:when>
		<xsl:when test="$is-eu">
			<xsl:sequence select="'EUParagraph'" />
		</xsl:when>
		<xsl:when test="$compact-format">
			<xsl:sequence select="'SubsectionCompact'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'SubsectionHeading'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="subsection-text-style-id">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$is-eu">
			<xsl:sequence select="'EUParagraph'" />
		</xsl:when>
		<xsl:when test="$compact-format">
			<xsl:sequence select="'SubsectionTextCompact'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'SubsectionText'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- P3 and P3 together -->

<xsl:template name="subsection-p3-style-id">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$inside-schedule">
			<xsl:sequence select="'ScheduleSubparagraphP3'" />
		</xsl:when>
		<xsl:when test="$compact-format">
			<xsl:sequence select="'SubsectionP3Compact'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'SubsectionP3Heading'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- P3 -->

<xsl:template name="p3-heading-style-id">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$inside-schedule">
			<xsl:sequence select="'ScheduleP3Heading'" />
		</xsl:when>
		<xsl:when test="$compact-format">
			<xsl:sequence select="'P3Compact'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'P3Heading'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="p3-text-style-id">
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:sequence select="if ($inside-schedule) then 'ScheduleP3Text' else 'P3Text'" />
</xsl:template>


<xsl:template name="p2-p4-style-id">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$inside-schedule">
			<xsl:sequence select="'ScheduleParagraphP4Heading'" />
		</xsl:when>
		<xsl:when test="$compact-format">
			<xsl:sequence select="'SubsectionP4Compact'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'SubsectionP4Heading'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<xsl:template name="p3-p4-style-id">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$inside-schedule">
			<xsl:sequence select="'ScheduleP3P4Heading'" />
		</xsl:when>
		<xsl:when test="$compact-format">
			<xsl:sequence select="'P3P4Compact'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'P3P4Heading'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="p4-heading-style-id">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$compact-format">
			<xsl:sequence select="'P4Compact'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'P4Heading'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="p4-text-style-id">
	<xsl:sequence select="'P4Text'" />
</xsl:template>

<xsl:template name="p5-heading-style-id">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$compact-format">
			<xsl:sequence select="'P5Compact'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'P5Heading'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="p4-p5-style-id">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$inside-schedule">
			<xsl:sequence select="'ScheduleP4P5Heading'" />
		</xsl:when>
		<xsl:when test="$compact-format">
			<xsl:sequence select="'P4P5Compact'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'P4P5Heading'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="p5-text-style-id">
	<xsl:sequence select="'P5Text'" />
</xsl:template>

<xsl:template name="p6-heading-style-id">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$compact-format">
			<xsl:sequence select="'P6Compact'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'P6Heading'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="p6-text-style-id">
	<xsl:sequence select="'P6Text'" />
</xsl:template>

<xsl:template name="p7-heading-style-id">
	<xsl:sequence select="'P7Heading'" />
</xsl:template>
<xsl:template name="p7-text-style-id">
	<xsl:sequence select="'P7Text'" />
</xsl:template>


<!-- lists -->

<xsl:template name="ordered-list-item-style-id">
	<xsl:sequence select="'ListItem'" />
</xsl:template>

<xsl:template name="unordered-list-item-style-id">
	<xsl:sequence select="'ListItem'" />
</xsl:template>

<xsl:template name="unnumbered-list-item-style-id">
	<xsl:sequence select="'UnnumberedListItem'" />
</xsl:template>

<!-- figures -->

<xsl:template name="figure-number-style-id">
	<xsl:sequence select="'FigureNumber'" />
</xsl:template>

<xsl:template name="figure-heading-style-id">
	<xsl:sequence select="'FigureHeading'" />
</xsl:template>


<!-- tables -->

<xsl:template name="tabular-number-style-id">
	<xsl:sequence select="'TabularNumber'" />
</xsl:template>

<xsl:template name="tabular-heading-style-id">
	<xsl:sequence select="'TabularHeading'" />
</xsl:template>

<xsl:template name="tabular-subheading-style-id">
	<xsl:sequence select="'TabularSubheading'" />
</xsl:template>


<!-- schedules -->

<xsl:template name="schedules-block-style-id">
	<xsl:sequence select="'Schedules'" />
</xsl:template>

<xsl:template name="schedule-number-style-id">
	<xsl:sequence select="'ScheduleNumber'" />
</xsl:template>

<xsl:template name="schedule-heading-style-id">
	<xsl:sequence select="'ScheduleHeading'" />
</xsl:template>

<xsl:template name="schedule-subheading-style-id">
	<xsl:sequence select="'ScheduleSubheading'" />
</xsl:template>

<xsl:template name="schedule-reference-style-id">
	<xsl:sequence select="'ScheduleReference'" />
</xsl:template>

<xsl:template name="schedule-paragraph-heading-style-id">
	<xsl:sequence select="'ScheduleParagraphHeading'" />
</xsl:template>

<xsl:template name="schedule-paragraph-style-id">
	<xsl:sequence select="'ScheduleParagraph'" />
</xsl:template>

<xsl:template name="schedule-paragraph-and-subparagraph-style-id">
	<xsl:sequence select="'ScheduleParagraphAndSubparagraph'" />
</xsl:template>

<xsl:template name="schedule-subparagraph-style-id">
	<xsl:sequence select="'ScheduleSubparagraph'" />
</xsl:template>

<xsl:template name="appendix-number-style-id">
	<xsl:sequence select="'AppendixNumber'" />
</xsl:template>


<!-- indentation -->

<xsl:function name="local:indent-style-definition" as="element(w:style)">
	<xsl:param name="style" as="element(w:style)" />
	<xsl:param name="indent-twips" as="xs:integer" />
	<xsl:apply-templates select="$style" mode="indent-style">
		<xsl:with-param name="indent-twips" as="xs:integer" select="$indent-twips" tunnel="yes" />
	</xsl:apply-templates>
</xsl:function>

<xsl:template match="w:*" mode="indent-style">
	<xsl:copy>
		<xsl:copy-of select="@*" />
		<xsl:apply-templates mode="indent-style" />
	</xsl:copy>
</xsl:template>

<xsl:function name="local:get-style-indent" as="xs:integer">
	<xsl:param name="style-id" as="xs:string" />
	<xsl:variable name="style" as="element(w:style)" select="local:get-style($style-id)" />
	<xsl:choose>
		<xsl:when test="exists($style/w:pPr/w:ind/@w:left)">
			<xsl:sequence select="xs:integer($style/w:pPr/w:ind/@w:left)" />
		</xsl:when>
		<xsl:when test="exists($style/w:basedOn)">
			<xsl:sequence select="local:get-style-indent($style/w:basedOn/@w:val)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="0" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template match="w:style" mode="indent-style">
	<xsl:param name="indent-twips" as="xs:integer" tunnel="yes" />
	<xsl:copy>
		<xsl:copy-of select="@*" />
		<xsl:apply-templates select="* except w:rPr" mode="indent-style" />
		<xsl:if test="empty(w:pPr)">
			<w:pPr>
				<xsl:variable name="tabs" as="element(w:tab)*">
					<xsl:call-template name="indent-tabs" />
				</xsl:variable>
				<xsl:if test="exists($tabs)">
					<w:tabs>
						<xsl:copy-of select="$tabs" />
					</w:tabs>
				</xsl:if>
				<w:ind w:left="{ local:get-style-indent(@w:styleId) + $indent-twips }" />
			</w:pPr>
		</xsl:if>
		<xsl:apply-templates select="w:rPr" mode="indent-style" />
	</xsl:copy>
</xsl:template>

<xsl:template match="w:pPr" mode="indent-style">
	<xsl:param name="indent-twips" as="xs:integer" tunnel="yes" />
	<xsl:copy>
		<xsl:copy-of select="@*" />
		<xsl:if test="empty(w:tabs)">
			<xsl:variable name="tabs" as="element(w:tab)*">
				<xsl:call-template name="indent-tabs" />
			</xsl:variable>
			<xsl:if test="exists($tabs)">
				<w:tabs>
					<xsl:copy-of select="$tabs" />
				</w:tabs>
			</xsl:if>
		</xsl:if>
		<xsl:apply-templates mode="indent-style" />
		<xsl:if test="empty(w:ind)">
			<w:ind w:left="{ local:get-style-indent(../@w:styleId) + $indent-twips }" />
		</xsl:if>
	</xsl:copy>
</xsl:template>

<xsl:template match="w:tabs" mode="indent-style">
	<xsl:copy>
		<xsl:copy-of select="@*" />
		<xsl:call-template name="indent-tabs" />
	</xsl:copy>
</xsl:template>

<xsl:template name="indent-tabs">
	<xsl:param name="style" as="element(w:style)" select="ancestor-or-self::w:style" />
	<xsl:if test="exists($style/w:basedOn)">
		<xsl:variable name="parent" as="element(w:style)" select="local:get-style($style/w:basedOn/@w:val)" />
		<xsl:call-template name="indent-tabs">
			<xsl:with-param name="style" select="$parent" />
		</xsl:call-template>
	</xsl:if>
	<xsl:apply-templates select="$style/w:pPr/w:tabs/*" mode="indent-style" />
</xsl:template>

<xsl:template match="w:tab" mode="indent-style">
	<xsl:param name="indent-twips" as="xs:integer" tunnel="yes" />
	<xsl:copy>
		<xsl:attribute name="w:val">
			<xsl:text>clear</xsl:text>
		</xsl:attribute>
		<xsl:copy-of select="@* except @w:val" />
	</xsl:copy>
	<xsl:copy>
		<xsl:copy-of select="@* except @w:pos" />
		<xsl:attribute name="w:pos">
			<xsl:choose>
				<xsl:when test="@w:val = 'center'">
					<xsl:value-of select="xs:integer(@w:pos) + ($indent-twips idiv 2)" />
				</xsl:when>
				<xsl:when test="xs:integer(@w:pos) = $content-width">
					<xsl:value-of select="@w:pos" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="xs:integer(@w:pos) + $indent-twips" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:apply-templates mode="indent-style" />
	</xsl:copy>
</xsl:template>

<xsl:template match="w:ind" mode="indent-style">
	<xsl:param name="indent-twips" as="xs:integer" tunnel="yes" />
	<xsl:copy>
		<xsl:attribute name="w:left">
			<xsl:choose>
				<xsl:when test="exists(@w:left)">
					<xsl:value-of select="xs:integer(@w:left) + $indent-twips" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="local:get-style-indent(../../@w:styleId) + $indent-twips" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:copy-of select="@* except @w:left" />
		<xsl:apply-templates mode="indent-style" />
	</xsl:copy>
</xsl:template>


<xsl:template name="paragraph-formatting-for-indentation">
	<xsl:param name="base-style-id" as="xs:string?" required="yes" />
	<xsl:param name="within-extract" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:param name="extract-indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:if test="$within-extract">
		<xsl:choose>
			<xsl:when test="exists($base-style-id)">
				<xsl:variable name="style" as="element(w:style)" select="local:get-style($base-style-id)" />
				<xsl:variable name="indent-twips" as="xs:integer" select="$extract-indent * 720" />
				<xsl:variable name="indented" as="element(w:style)" select="local:indent-style-definition($style, $indent-twips)" />
				<xsl:copy-of select="$indented/w:pPr/w:tabs" />
				<xsl:copy-of select="$indented/w:pPr/w:ind" />
			</xsl:when>
			<xsl:otherwise>
				<w:ind w:left="{ $extract-indent * 720 }" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<xsl:template name="style-and-indent-formatting">
	<xsl:param name="style-id" as="xs:string" required="yes" />
	<w:pPr>
		<w:pStyle w:val="{ $style-id }" />
		<xsl:call-template name="paragraph-formatting-for-indentation">
			<xsl:with-param name="base-style-id" select="$style-id" />
		</xsl:call-template>
	</w:pPr>
</xsl:template>

</xsl:transform>
