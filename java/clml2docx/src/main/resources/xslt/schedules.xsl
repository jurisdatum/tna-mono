<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:local="local"
	exclude-result-prefixes="xs local">


<xsl:template match="Schedules">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Schedules/Title">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="schedules-block-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<!-- abstracts -->

<xsl:template match="Abstract | Abstract/TitleBlock | AbstractBody | AbstractBody/P">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Abstract/TitleBlock/Title">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="schedule-heading-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="AbstractBody/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>


<!-- shedules -->

<xsl:template match="Schedule">
	<xsl:param name="outline-level" as="xs:integer" select="-1" tunnel="yes" />
	<xsl:apply-templates select="Number | TitleBlock" />
<!-- 	<xsl:variable name="commentaries" as="element(CommentaryRef)*" select="(CommentaryRef | Number//CommentaryRef | TitleBlock//CommentaryRef)" />
	<xsl:call-template name="annotations">
		<xsl:with-param name="commentaries" select="$commentaries" />
	</xsl:call-template> -->
	<xsl:apply-templates select="* except (Number, TitleBlock)">
		<xsl:with-param name="inside-schedule" as="xs:boolean" select="true()" tunnel="yes" />
		<xsl:with-param name="outline-level" as="xs:integer" select="$outline-level + 1" tunnel="yes" />
		<xsl:with-param name="compact-format" as="xs:boolean" select="false()" tunnel="yes" />
	</xsl:apply-templates>
	<xsl:if test="$debug and exists(Reference) and empty(Number)">
		<xsl:message terminate="yes">no number for reference</xsl:message>
	</xsl:if>
	<xsl:call-template name="insert-alt-versions" />
</xsl:template>

<xsl:template match="Schedule/Number">
	<xsl:param name="within-extract" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:variable name="reference-at-right" as="xs:boolean" select="not($document-main-type = 'ScottishAct')" />
	<w:p>
		<w:pPr>
			<w:pStyle>
				<xsl:attribute name="w:val">
					<xsl:call-template name="schedule-number-style-id" />
				</xsl:attribute>
			</w:pStyle>
			<xsl:if test="$is-secondary and not($within-extract)">
				<w:pageBreakBefore />
			</xsl:if>
			<xsl:call-template name="paragraph-formatting-for-indentation">
				<xsl:with-param name="base-style-id">
					<xsl:call-template name="schedule-number-style-id" />
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="add-outline-level" />
		</w:pPr>
       	<w:r>
			<w:tab/>
		</w:r>
		<xsl:apply-templates />
		<xsl:call-template name="show-extent">
			<xsl:with-param name="anchor" select=".." />
		</xsl:call-template>
       	<w:r>
			<w:tab/>	<!-- put this inside following xsl:if ? -->
		</w:r>
		<xsl:if test="$reference-at-right and exists(following-sibling::Reference)">
			<xsl:apply-templates select="following-sibling::Reference/node()">
				<xsl:with-param name="run-formatting" as="element()" tunnel="yes">
					<w:rStyle>
						<xsl:attribute name="w:val">
							<xsl:call-template name="schedule-reference-style-id" />
						</xsl:attribute>
					</w:rStyle>
				</xsl:with-param>
			</xsl:apply-templates>
		</xsl:if>
	</w:p>
	<xsl:if test="not($reference-at-right) and exists(following-sibling::Reference)">
		<w:p>
			<w:pPr>
				<w:pStyle w:val='ScheduleReferenceP' />
			</w:pPr>
			<xsl:apply-templates select="following-sibling::Reference/node()" />
		</w:p>
	</xsl:if>
</xsl:template>

<xsl:template match="Schedule/TitleBlock">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Schedule/TitleBlock/Title">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="schedule-heading-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Schedule/TitleBlock/Subtitle">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="schedule-subheading-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Schedule/Reference" />

<xsl:template match="Schedule/Contents" />	<!-- ukpga/2020/1/enacted -->

<xsl:template match="ScheduleBody">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="ScheduleBody/P">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="ScheduleBody/P/CommentaryRef">
	<xsl:param name="force" as="xs:boolean" select="false()" />
	<xsl:choose>
		<xsl:when test="$force">
			<xsl:next-match />
		</xsl:when>
		<xsl:when test="exists(following-sibling::*[not(self::CommentaryRef)][1]/self::Text)" />
		<xsl:when test="exists(following-sibling::*[not(self::CommentaryRef)][1][self::BlockExtract or self::OrderedList])">	<!-- uksi/1953/884/2014-01-01, ukpga/1977/15/2018-12-21 -->
			<w:p>
				<xsl:next-match />
			</w:p>
		</xsl:when>
		<xsl:when test="$debug">
			<xsl:message>
				<xsl:sequence select="following-sibling::*[not(self::CommentaryRef)][1]" />
			</xsl:message>
			<xsl:message terminate="yes">CommentaryRef will be missed</xsl:message>
		</xsl:when>
		<xsl:otherwise>
			<w:p>
				<xsl:next-match />
			</w:p>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="ScheduleBody/P/Text">
	<xsl:call-template name="p">
		<!-- style? -->
		<xsl:with-param name="add-beginning-runs" as="element(w:r)*">
			<xsl:if test="empty(preceding-sibling::*[not(self::CommentaryRef)])">
				<xsl:apply-templates select="preceding-sibling::*">
					<xsl:with-param name="force" select="true()" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="ScheduleBody/P/BlockText/Para/Text">
	<xsl:call-template name="block-text">
		<xsl:with-param name="style" select="'Normal'" />
	</xsl:call-template>
</xsl:template>


<!-- appendices -->

<xsl:template match="Appendix">
	<xsl:apply-templates />
	<xsl:call-template name="insert-alt-versions" />
</xsl:template>

<xsl:template match="Appendix/Number">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="appendix-number-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Appendix/TitleBlock">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Appendix/TitleBlock/Title">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="schedule-heading-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Appendix/TitleBlock/Subtitle">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="schedule-subheading-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Appendix/Reference">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="AppendixBody">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="AppendixBody/P">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="AppendixBody/P/Text">
	<xsl:call-template name="p" />
</xsl:template>

</xsl:transform>
