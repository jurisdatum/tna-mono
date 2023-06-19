<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:local="local"
	exclude-result-prefixes="xs local">

<xsl:template match="Body">
	<xsl:comment>body</xsl:comment>
	<xsl:apply-templates>
		<xsl:with-param name="outline-level" as="xs:integer" select="-1" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="Body/CommentaryRef">
	<xsl:param name="force" as="xs:boolean" select="false()" />
	<xsl:if test="$force">
		<xsl:next-match />
	</xsl:if>
	<xsl:if test="not($force)">
		<xsl:choose>
			<xsl:when test="exists(following-sibling::*[not(self::CommentaryRef)][1]/self::P/*[1]/self::Text)" />
			<xsl:when test="exists(following-sibling::*[not(self::CommentaryRef)][1]/self::Part)" />
			<xsl:when test="exists(following-sibling::*[not(self::CommentaryRef)][1]/self::Pblock)" />
			<xsl:when test="$debug">
				<xsl:message terminate="yes">CommentaryRef will be missed</xsl:message>
			</xsl:when>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<xsl:template name="big-level">
	<xsl:param name="outline-level" as="xs:integer" select="-1" tunnel="yes" />
	<xsl:apply-templates select="Number | Title" />
	<xsl:apply-templates select="* except (Number, Title)">
		<xsl:with-param name="outline-level" as="xs:integer" select="$outline-level + 1" tunnel="yes" />
	</xsl:apply-templates>
	<xsl:call-template name="insert-alt-versions" />
</xsl:template>

<xsl:template name="big-level-number">
	<xsl:param name="style" as="xs:string" />
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="$style" />
		<xsl:with-param name="para-formatting" as="element()?">
			<xsl:call-template name="add-outline-level" />
		</xsl:with-param>
		<xsl:with-param name="add-beginning-runs" as="element(w:r)*">
			<xsl:if test="exists(parent::*/parent::Body) and empty(parent::*/preceding-sibling::*[not(self::CommentaryRef)])">	<!-- err:Errors -->
				<xsl:apply-templates select="parent::*/preceding-sibling::CommentaryRef">
					<xsl:with-param name="force" select="true()" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:with-param>
		<xsl:with-param name="add-ending-runs" as="element(w:r)*">
			<xsl:call-template name="show-extent">
				<xsl:with-param name="anchor" select=".." />
			</xsl:call-template>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template name="big-level-title">
	<xsl:param name="style" as="xs:string" />
	<xsl:variable name="is-first" as="xs:boolean" select="empty(preceding-sibling::Number) and empty(preceding-sibling::Title)" />
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="$style" />
		<xsl:with-param name="para-formatting" as="element()?">
			<xsl:if test="$is-first">
				<xsl:call-template name="add-outline-level" />
			</xsl:if>
		</xsl:with-param>
		<xsl:with-param name="add-beginning-runs" as="element(w:r)*">
			<xsl:if test="$is-first and exists(parent::*/parent::Body) and empty(parent::*/preceding-sibling::*[not(self::CommentaryRef)])">	<!-- err:Errors -->
				<xsl:apply-templates select="parent::*/preceding-sibling::CommentaryRef">
					<xsl:with-param name="force" select="true()" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:with-param>
		<xsl:with-param name="add-ending-runs" as="element(w:r)*">
			<xsl:if test="$is-first">
				<xsl:call-template name="show-extent">
					<xsl:with-param name="anchor" select=".." />
				</xsl:call-template>
			</xsl:if>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Group">
	<xsl:call-template name="big-level" />
</xsl:template>

<xsl:template match="Group/Number">
	<xsl:call-template name="big-level-number">
		<xsl:with-param name="style">
			<xsl:call-template name="group-number-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Group/Title">
	<xsl:call-template name="big-level-title">
		<xsl:with-param name="style">
			<xsl:call-template name="group-heading-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Group/P">	<!-- ukpga/Vict/63-64/12/enacted -->
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Group/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="section-text-style-id" />	<!-- ToDo create dedicated style, like Chapter -->
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<!-- parts -->

<xsl:template match="Part">
	<xsl:call-template name="big-level" />
</xsl:template>

<xsl:template match="Part/CommentaryRef">	<!-- ukpga/2015/6/2015-09-21 -->
	<xsl:param name="force" as="xs:boolean" select="false()" />
	<xsl:if test="$force">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<xsl:template match="Part/Number">
	<xsl:call-template name="big-level-number">
		<xsl:with-param name="style">
			<xsl:call-template name="part-number-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Part/Title">
	<xsl:call-template name="big-level-title">
		<xsl:with-param name="style">
			<xsl:call-template name="part-heading-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Part/Reference">	<!-- only example I've seen is in ukpga/2009/6/enacted, which seems to be a mistake -->
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Part/P ">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Part/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="section-text-style-id" />	<!-- ToDo create dedicated style, like Chapter -->
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Part/P/BlockText/Text">
	<xsl:call-template name="block-text">
		<xsl:with-param name="style">
			<xsl:call-template name="section-text-style-id" />	<!-- ToDo create dedicated style, like Chapter -->
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<!-- chapters -->

<xsl:template match="Chapter">
	<xsl:call-template name="big-level" />
</xsl:template>

<xsl:template match="Chapter/Number">
	<xsl:call-template name="big-level-number">
		<xsl:with-param name="style">
			<xsl:call-template name="chapter-number-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Chapter/Title">
	<xsl:call-template name="big-level-title">
		<xsl:with-param name="style">
			<xsl:call-template name="chapter-heading-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Chapter/Reference">	<!-- only example I've seen is in ssi/2007/42/made, which seems to be a mistake -->
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Chapter/P">
	<xsl:apply-templates />
</xsl:template>
<xsl:template match="Chapter/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'ChapterText'" />
	</xsl:call-template>
</xsl:template>
<xsl:template match="Chapter/P/BlockText/Text">
	<xsl:call-template name="block-text">
		<xsl:with-param name="style" select="'ChapterText'" />
	</xsl:call-template>
</xsl:template>


<!-- Pblocks -->

<xsl:template match="Pblock">
	<xsl:call-template name="big-level" />
</xsl:template>

<xsl:template match="Pblock/Number">
	<xsl:call-template name="big-level-number">
		<xsl:with-param name="style">
			<xsl:call-template name="crossheading-number-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- ToDO check -->
<xsl:template match="Pblock/Reference">	<!-- uksi/2019/764/made -->
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Pblock/Title">
	<xsl:call-template name="big-level-title">
		<xsl:with-param name="style">
			<xsl:call-template name="crossheading-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Pblock/P">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Pblock/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="section-text-style-id" />	<!-- ToDo create dedicated style -->
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Pblock/P/BlockText/Text | Pblock/P/BlockText/Para/Text">
	<xsl:call-template name="block-text">
		<xsl:with-param name="style">
			<xsl:call-template name="section-text-style-id" />	<!-- ToDo create dedicated style -->
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<!-- PsubBlocks -->

<xsl:template match="PsubBlock">
	<xsl:call-template name="big-level" />
</xsl:template>

<xsl:template match="PsubBlock/Number">
	<xsl:call-template name="big-level-number">
		<xsl:with-param name="style">
			<xsl:call-template name="subheading-number-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="PsubBlock/Title">
	<xsl:call-template name="big-level-title">
		<xsl:with-param name="style">
			<xsl:call-template name="subheading-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="PsubBlock/P">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="PsubBlock/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="section-text-style-id" />	<!-- ToDo create dedicated style -->
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="PsubBlock/P/BlockText/Text | PsubBlock/P/BlockText/Para/Text">
	<xsl:call-template name="block-text">
		<xsl:with-param name="style">
			<xsl:call-template name="section-text-style-id" />	<!-- ToDo create dedicated style -->
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<!-- provisions -->

<xsl:template match="Body/P">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Body/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
		<xsl:with-param name="add-beginning-runs" as="element(w:r)*">
			<xsl:if test="empty(preceding-sibling::*) and empty(../preceding-sibling::*[not(self::CommentaryRef)])">
				<xsl:apply-templates select="../preceding-sibling::*">
					<xsl:with-param name="force" select="true()" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Body/Para">	<!-- mistake in apni/1964/21/2006-01-01 -->
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Body/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="P1group">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:apply-templates>
		<!-- <xsl:with-param name="p1group-has-singleton-p1-child" as="xs:boolean" select="exists(*[not(self::Title)][1][self::P1]) and (count(P1) eq 1)" /> -->
		<xsl:with-param name="p1group-title-goes-with-first-p1" as="xs:boolean">
			<xsl:choose>
				<xsl:when test="$inside-schedule">
					<xsl:sequence select="false()" />
				</xsl:when>
				<xsl:when test="$compact-format">
					<xsl:sequence select="false()" />
				</xsl:when>
				<xsl:otherwise>
					<!-- exists(Title/following-sibling::*[1][self::P1]) and (count(P1) eq 1) -->
					<xsl:sequence select="exists(*[not(self::Title)][1][self::P1]) and (count(P1) eq 1)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
	</xsl:apply-templates>
	<xsl:call-template name="insert-alt-versions" />
</xsl:template>

<xsl:template match="P1group/CommentaryRef[exists(following-sibling::Title)]">	<!-- anaw/2016/6/2016-04-26 -->
	<xsl:param name="force" as="xs:boolean" select="false()" />
	<xsl:if test="$force">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<xsl:template match="P1group/Title">
	<!-- <xsl:param name="p1group-has-singleton-p1-child" as="xs:boolean" required="yes" /> -->
	<xsl:param name="p1group-title-goes-with-first-p1" as="xs:boolean" required="yes" />
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:if test="not($p1group-title-goes-with-first-p1)">
		<xsl:call-template name="p">
			<xsl:with-param name="style">
				<xsl:choose>
					<xsl:when test="$inside-schedule">
						<xsl:call-template name="schedule-paragraph-heading-style-id" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="unnumbered-section-heading-style-id" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="add-beginning-runs" as="element(w:r)*">
				<xsl:apply-templates select="preceding-sibling::CommentaryRef">
					<xsl:with-param name="force" select="true()" />
				</xsl:apply-templates>
			</xsl:with-param>
			<xsl:with-param name="add-ending-runs" as="element(w:r)*">
				<xsl:call-template name="show-extent">
					<xsl:with-param name="anchor" select=".." />
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template match="P1group/P">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="P1group/P/CommentaryRef">
	<xsl:param name="force" as="xs:boolean" select="false()" />
	<xsl:choose>
		<xsl:when test="$force">
			<xsl:next-match />
		</xsl:when>
		<xsl:when test="exists(following-sibling::*[not(self::CommentaryRef)][1]/self::Text)" />
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

<xsl:template match="P1group/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="section-text-style-id" />
		</xsl:with-param>
		<xsl:with-param name="add-beginning-runs" as="element(w:r)*">
			<xsl:if test="empty(preceding-sibling::*[not(self::CommentaryRef)])">
				<xsl:apply-templates select="preceding-sibling::*">
					<xsl:with-param name="force" select="true()" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="P1group/P/BlockText/Text | P1group/P/BlockText/Para/Text">
	<xsl:call-template name="block-text">
		<xsl:with-param name="style">
			<xsl:call-template name="section-text-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="P1">
	<xsl:param name="p1group-title-goes-with-first-p1" as="xs:boolean" select="false()" />	<!-- if true then P1 is singleton -->
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:param name="within-extract" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$p1group-title-goes-with-first-p1">	<!-- currently this is true only if this P1 is a singleton -->
			<w:p>
				<xsl:call-template name="style-and-indent-formatting">
					<xsl:with-param name="style-id">
						<xsl:call-template name="numbered-section-heading-style-id" />
					</xsl:with-param>
				</xsl:call-template>
				<xsl:apply-templates select="Pnumber/preceding-sibling::CommentaryRef">
					<xsl:with-param name="force" select="true()" />
				</xsl:apply-templates>
				<xsl:apply-templates select="Pnumber/node()" />
				<w:r>
					<w:tab/>
				</w:r>
				<xsl:apply-templates select="../Title/preceding-sibling::CommentaryRef">
					<xsl:with-param name="force" select="true()" />
				</xsl:apply-templates>
				<xsl:apply-templates select="../Title/node()" />
				<xsl:call-template name="show-extent">
					<xsl:with-param name="anchor" select=".." />
				</xsl:call-template>
			</w:p>
			<xsl:apply-templates select="* except Pnumber">
				<xsl:with-param name="p1-number-already-handled" as="xs:boolean" select="true()" />
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="first" as="element()" select="Pnumber/following-sibling::*[1]" />
			<xsl:variable name="p1-number-must-go-with-p2" as="xs:boolean" select="exists($first/self::P1para/child::*[1]/self::P2)" />
			<xsl:choose>
				<xsl:when test="exists($first/self::P1para/child::*[1]/self::Text)" />
				<xsl:when test="$p1-number-must-go-with-p2" />
				<xsl:otherwise>
					<xsl:call-template name="orphan-pnumber">
						<xsl:with-param name="style">
							<xsl:call-template name="numbered-section-style-id" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="* except Pnumber">
				<xsl:with-param name="p1-number-must-go-with-p2" select="$p1-number-must-go-with-p2" />
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:call-template name="insert-alt-versions" />
</xsl:template>

<xsl:template match="P1/CommentaryRef[exists(following-sibling::Pnumber)]">	<!-- ukpga/2014/14/2018-01-01 -->
	<xsl:param name="force" as="xs:boolean" select="false()" />
	<xsl:if test="$force">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<xsl:template match="P1/Pnumber">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="P1para">
	<xsl:param name="p1-number-already-handled" as="xs:boolean" select="false()" />
	<xsl:param name="p1-number-must-go-with-p2" as="xs:boolean" select="false()" />
	<xsl:apply-templates>
		<xsl:with-param name="p1-number-already-handled" select="$p1-number-already-handled" />
		<xsl:with-param name="p1-number-must-go-with-p2" select="$p1-number-must-go-with-p2" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="P1para[1]/Text[empty(preceding-sibling::*)]" priority="1">
	<xsl:param name="p1-number-already-handled" as="xs:boolean" select="false()" />
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<!-- p1-number-must-go-with-p2 must be false -->
	<!-- <xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" /> -->
	<xsl:choose>
		<xsl:when test="not($p1-number-already-handled)">	<!-- $inside-schedule -->
			<w:p>
				<xsl:call-template name="style-and-indent-formatting">
					<xsl:with-param name="style-id">
						<xsl:call-template name="numbered-section-style-id" />
					</xsl:with-param>
				</xsl:call-template>

				<xsl:apply-templates select="../../Pnumber/preceding-sibling::CommentaryRef">
					<xsl:with-param name="force" select="true()" />
				</xsl:apply-templates>

				<xsl:apply-templates select="../../Pnumber/node()">
					<xsl:with-param name="last-text-node-in-pnumber" select="../../Pnumber/descendant::text()[normalize-space()][last()]" tunnel="yes" />
					<xsl:with-param name="punc-after-last-node-in-pnumber" tunnel="yes">
						<xsl:call-template name="punctuation-after-p1-number" />
					</xsl:with-param>
					<xsl:with-param name="run-formatting" as="element()*" tunnel="yes">
						<xsl:call-template name="run-formatting-for-p1-number" />
					</xsl:with-param>
				</xsl:apply-templates>

				<w:r>
					<xsl:choose>
						<xsl:when test="$compact-format">
							<w:t xml:space="preserve"> </w:t>
						</xsl:when>
						<xsl:otherwise>
							<w:tab/>
						</xsl:otherwise>
					</xsl:choose>
				</w:r>
				<xsl:apply-templates />
			</w:p>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="P1para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="section-text-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>
<xsl:template match="P1para/BlockText/Text | P1para/BlockText/Para/Text">
	<xsl:call-template name="block-text">
		<xsl:with-param name="style">
			<xsl:call-template name="section-text-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="P2group">
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="p2group-title-goes-with-p2" as="xs:boolean">
			<xsl:choose>
				<xsl:when test="$inside-schedule">
					<xsl:sequence select="false()" />	<!-- This is not true of P3s, see uksi/1993/2006/schedule/5/paragraph/12/made -->
				</xsl:when>
				<xsl:when test="$compact-format">
					<xsl:sequence select="false()" />
				</xsl:when>
				<xsl:when test="exists(Pnumber)">
					<xsl:sequence select="false()" />
				</xsl:when>
				<xsl:when test="empty(Title)">
					<xsl:sequence select="false()" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="count(P2) eq 1" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
	</xsl:apply-templates>
	<xsl:call-template name="insert-alt-versions" />
</xsl:template>

<xsl:template match="P2group/Pnumber">
	<xsl:if test="$debug and empty(following-sibling::Title)">
		<xsl:message terminate="yes" />
	</xsl:if>
</xsl:template>

<xsl:template match="P2group/Title">
	<xsl:param name="p2group-title-goes-with-p2" as="xs:boolean" required="yes" />
	<xsl:if test="not($p2group-title-goes-with-p2)">
		<w:p>
			<w:pPr>
				<xsl:variable name="style" as="xs:string">
					<xsl:call-template name="subsection-group-heading-style-id" />
				</xsl:variable>
				<w:pStyle w:val="{ $style }" />
				<xsl:call-template name="paragraph-formatting-for-indentation">
					<xsl:with-param name="base-style-id" select="$style" />
				</xsl:call-template>
			</w:pPr>
			<xsl:if test="exists(preceding-sibling::Pnumber)">
				<xsl:apply-templates select="preceding-sibling::Pnumber/node()" />
				<w:r>
					<w:tab/>
				</w:r>
			</xsl:if>
			<xsl:apply-templates />
		</w:p>
	</xsl:if>
</xsl:template>

<xsl:template match="P2">
	<xsl:param name="p1-number-must-go-with-p2" as="xs:boolean" select="false()" />
	<xsl:param name="p2group-title-goes-with-p2" as="xs:boolean" select="false()" />
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:if test="$debug and $p1-number-must-go-with-p2 and $p2group-title-goes-with-p2">
		<xsl:message terminate="true" />
	</xsl:if>
	<xsl:choose>
		<xsl:when test="$p2group-title-goes-with-p2">	<!-- if true, then parent is P2group and context P2 is a singleton -->
			<w:p>
				<w:pPr>
					<xsl:variable name="style" as="xs:string">
						<xsl:call-template name="subsection-group-heading-style-id" />
					</xsl:variable>
					<w:pStyle w:val="{ $style }" />
					<xsl:call-template name="paragraph-formatting-for-indentation">
						<xsl:with-param name="base-style-id" select="$style" />
					</xsl:call-template>
				</w:pPr>
				<xsl:call-template name="handle-pnumber">
					<xsl:with-param name="pnumber" select="Pnumber" />
					<xsl:with-param name="punc-before" select="'('" />
					<xsl:with-param name="punc-after" select="')'" />
					<xsl:with-param name="add-tab" select="true()" />
				</xsl:call-template>
				<xsl:apply-templates select="../Title/node()" />
			</w:p>
			<xsl:apply-templates select="* except Pnumber">
				<xsl:with-param name="p2-number-already-handled" as="xs:boolean" select="true()" />
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="first" as="element()?" select="Pnumber/following-sibling::*[1]" />
			<xsl:choose>
				<xsl:when test="exists($first/self::P2para/child::*[1]/self::Text)" />
				<xsl:when test="exists($first/self::P2para/child::*[1][self::P3group])" />
				<xsl:when test="exists($first/self::P2para/child::*[1][self::P3])" />
				<xsl:when test="exists($first/self::P2para/child::*[1][self::P4])" />
				<xsl:otherwise>
					<xsl:call-template name="orphan-pnumber">
						<xsl:with-param name="style">
							<xsl:call-template name="subsection-heading-style-id" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates>
				<xsl:with-param name="p1-number-must-go-with-p2" select="$p1-number-must-go-with-p2" />
				<xsl:with-param name="p2-number-must-go-with-p3group" select="not($p2group-title-goes-with-p2) and exists(P2para[1]/*[1][self::P3group])" />
				<xsl:with-param name="p2-number-must-go-with-p3" select="not($p2group-title-goes-with-p2) and exists(P2para[1]/*[1][self::P3])" />
				<xsl:with-param name="p2-number-must-go-with-p4" select="not($p2group-title-goes-with-p2) and exists(P2para[1]/*[1][self::P4])" /><!--  uksi/2000/2/section/2/2 -->
				<!-- removed indent b/c of amendments, see comment in amendments, need to check tables, etc. -->
				<xsl:with-param name="indent" select="$indent" tunnel="yes" />
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:call-template name="insert-alt-versions" />
</xsl:template>

<xsl:template match="P2/CommentaryRef[exists(following-sibling::Pnumber)]">	<!-- asp/2016/21/2016-04-29 -->
	<xsl:param name="force" as="xs:boolean" select="false()" />
	<xsl:if test="$force">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<xsl:template match="P2/Pnumber" />

<xsl:template match="P2para">
	<xsl:param name="p1-number-must-go-with-p2" as="xs:boolean" select="false()" />
	<xsl:param name="p2-number-already-handled" as="xs:boolean" select="false()" />
	<xsl:param name="p2-number-must-go-with-p3group" as="xs:boolean" select="false()" />
	<xsl:param name="p2-number-must-go-with-p3" as="xs:boolean" select="false()" />
	<xsl:param name="p2-number-must-go-with-p4" as="xs:boolean" select="false()" />
	<xsl:apply-templates>
		<xsl:with-param name="p1-number-must-go-with-p2" select="$p1-number-must-go-with-p2" />
		<xsl:with-param name="p2-number-already-handled" select="$p2-number-already-handled" />
		<xsl:with-param name="p2-number-must-go-with-p3group" select="$p2-number-must-go-with-p3group" />
		<xsl:with-param name="p2-number-must-go-with-p3" select="$p2-number-must-go-with-p3" />
		<xsl:with-param name="p2-number-must-go-with-p4" select="$p2-number-must-go-with-p4" />
	</xsl:apply-templates>
</xsl:template>


<xsl:template match="P2/P2para[1]/Text[empty(preceding-sibling::*)]" priority="1">	<!-- P2/ guards against BlockAmendment/P2para -->
	<xsl:param name="p1-number-must-go-with-p2" as="xs:boolean" select="false()" />
	<xsl:param name="p2-number-already-handled" as="xs:boolean" select="false()" />
	<!-- p2-number-must-go-with-p3 must be false -->
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:if test="$debug and $p1-number-must-go-with-p2 and $p2-number-already-handled">
		<xsl:message terminate="yes">
			<xsl:text>p1-number-must-go-with-p2 and p2-number-already-handled</xsl:text>
		</xsl:message>
	</xsl:if>
	<xsl:choose>
		<xsl:when test="$p2-number-already-handled">
			<xsl:next-match />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="include-p1-number" as="xs:boolean" select="$p1-number-must-go-with-p2 and empty(../../preceding-sibling::*)" />
			<w:p>
				<xsl:call-template name="style-and-indent-formatting">
					<xsl:with-param name="style-id">
						<xsl:choose>
							<xsl:when test="$include-p1-number">
								<xsl:call-template name="p1-with-p2-style-id" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="subsection-heading-style-id" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
		
				<xsl:if test="$include-p1-number">
					<xsl:call-template name="handle-pnumber">
						<xsl:with-param name="pnumber" select="../../../../Pnumber" />
						<xsl:with-param name="punc-before" select="()" />
						<xsl:with-param name="punc-after">
							<xsl:call-template name="punctuation-after-p1-number" />
						</xsl:with-param>
						<xsl:with-param name="add-tab" select="not($compact-format)" />
						<xsl:with-param name="run-formatting" as="element()*" tunnel="yes">
							<xsl:call-template name="run-formatting-for-p1-number" />
						</xsl:with-param>
					</xsl:call-template>
					<xsl:if test="$compact-format">
						<w:r>
							<w:t xml:space="preserve">&#8212;</w:t>	<!-- em dash -->
						</w:r>
					</xsl:if>
				</xsl:if>
				
				<xsl:if test="not($compact-format) and not($is-eu)">
					<w:r>	<!-- tab to right-aligned number -->
						<w:tab/>
					</w:r>
				</xsl:if>
				
				<xsl:call-template name="handle-pnumber">
					<xsl:with-param name="pnumber" select="../../Pnumber" />
					<xsl:with-param name="punc-before" select="if ($is-eu) then '' else '('" />
					<xsl:with-param name="punc-after" select="if ($is-eu) then '.' else ')'" />
					<xsl:with-param name="add-tab" select="not($compact-format)" />
					<xsl:with-param name="add-space" select="$compact-format" />
				</xsl:call-template>
				
				<xsl:apply-templates />
		       	<xsl:call-template name="block-amendment-lead-in" />	<!-- check for lead-in to BlockAmendment -->
			</w:p>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="P2para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="subsection-text-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>
<xsl:template match="P2para/BlockText/Text | P2para/BlockText/Para/Text">
	<xsl:call-template name="block-text">
		<xsl:with-param name="style">
			<xsl:call-template name="subsection-text-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>
<xsl:template match="P2para/BlockText/Para/BlockText/Para/Text">
	<xsl:variable name="style" as="xs:string">
		<xsl:call-template name="subsection-text-style-id" />
	</xsl:variable>
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="$style" />
		<xsl:with-param name="para-formatting" as="element(w:ind)">
			<w:ind w:left="{ local:get-style-indent($style) + 2 * $indent-width }" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<!-- P3s -->

<xsl:template match="P3group">	<!-- nisr/2003/31 -->
	<xsl:param name="p2-number-must-go-with-p3group" as="xs:boolean" select="false()" />
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="p2-number-must-go-with-p3group" select="$p2-number-must-go-with-p3group" />
		<xsl:with-param name="p3group-title-goes-with-p3" as="xs:boolean">
			<xsl:choose>
				<xsl:when test="$p2-number-must-go-with-p3group">
					<xsl:sequence select="false()" />
				</xsl:when>
				<xsl:when test="$compact-format">
					<xsl:sequence select="false()" />
				</xsl:when>
				<xsl:when test="exists(Pnumber)">
					<xsl:sequence select="false()" />
				</xsl:when>
				<xsl:when test="empty(Title)">
					<xsl:sequence select="false()" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="count(P3) eq 1" />	<!-- uksi/1993/2006/schedule/5/paragraph/12/made -->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
	</xsl:apply-templates>
	<xsl:call-template name="insert-alt-versions" />
</xsl:template>

<!-- P3groups must have a Title and can't have a Number -->
<xsl:template match="P3group/Title">
	<xsl:param name="p2-number-must-go-with-p3group" as="xs:boolean" select="false()" />
	<xsl:param name="p3group-title-goes-with-p3" as="xs:boolean" required="yes" />
	<xsl:choose>
		<xsl:when test="$p2-number-must-go-with-p3group">
			<w:p>
				<w:pPr>
					<w:pStyle>
						<xsl:attribute name="w:val">
							<xsl:call-template name="subsection-heading-style-id" />
						</xsl:attribute>
					</w:pStyle>
				</w:pPr>
				<xsl:call-template name="handle-pnumber">
					<xsl:with-param name="pnumber" select="../../../Pnumber" />
					<xsl:with-param name="punc-before" select="()" />
					<xsl:with-param name="punc-after" select="()" />
					<xsl:with-param name="add-tab" select="true()" />
				</xsl:call-template>
				<xsl:apply-templates />
			</w:p>
		</xsl:when>
		<xsl:when test="not($p3group-title-goes-with-p3)">
			<xsl:call-template name="p">
				<xsl:with-param name="style">
					<xsl:call-template name="p3-heading-style-id" />	<!-- this may not be right -->
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template name="orphan-pnumber">
	<xsl:param name="style" as="xs:string" />
	<xsl:param name="punc-before" as="xs:string?" select="'('" />
	<xsl:param name="punc-after" as="xs:string?" select="')'" />
	<xsl:if test="exists(Pnumber)">
		<w:p>
			<xsl:call-template name="style-and-indent-formatting">
				<xsl:with-param name="style-id" select="$style" />
			</xsl:call-template>
			<xsl:call-template name="handle-pnumber">
				<xsl:with-param name="pnumber" select="Pnumber" />
				<xsl:with-param name="punc-before" select="$punc-before" />
				<xsl:with-param name="punc-after" select="$punc-after" />
				<xsl:with-param name="add-tab" select="false()" />
			</xsl:call-template>
		</w:p>
	</xsl:if>
</xsl:template>

<xsl:template match="P3">
	<xsl:param name="p2-number-must-go-with-p3" as="xs:boolean" select="false()" />
	<xsl:param name="p3group-title-goes-with-p3" as="xs:boolean" select="false()" />
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:variable name="first" as="element()?" select="Pnumber/following-sibling::*[1]" />	<!-- empty in asp/2003/13/section/289/3/a -->
	<xsl:choose>
		<xsl:when test="$p3group-title-goes-with-p3">
			<w:p>
				<w:pPr>
					<xsl:variable name="style" as="xs:string">
						<xsl:call-template name="p3-heading-style-id" />
					</xsl:variable>
					<w:pStyle w:val="{ $style }" />
					<xsl:call-template name="paragraph-formatting-for-indentation">
						<xsl:with-param name="base-style-id" select="$style" />
					</xsl:call-template>
				</w:pPr>
				<w:r>	<!-- tab to right-aligned number -->
					<w:tab/>
				</w:r>
				<xsl:call-template name="handle-pnumber">
					<xsl:with-param name="pnumber" select="Pnumber" />
					<xsl:with-param name="punc-before" select="'('" />
					<xsl:with-param name="punc-after" select="')'" />
					<xsl:with-param name="add-tab" select="true()" />
				</xsl:call-template>
				<xsl:apply-templates select="../Title/node()" />
			</w:p>
		</xsl:when>
		<xsl:when test="exists($first/self::P3para/child::*[1][self::Text])" />
		<xsl:when test="exists($first/self::P3para/*[1][self::P4])" />
		<xsl:otherwise>
			<xsl:call-template name="orphan-pnumber">
				<xsl:with-param name="style">
					<xsl:call-template name="p3-heading-style-id" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:apply-templates>
		<xsl:with-param name="p2-number-must-go-with-p3" select="$p2-number-must-go-with-p3" />
		<xsl:with-param name="p3-number-already-handled" as="xs:boolean" select="$p3group-title-goes-with-p3" />
		<xsl:with-param name="p3-number-must-go-with-p4" select="not($p3group-title-goes-with-p3) and exists(P3para[1]/*[1][self::P4])" />
		<xsl:with-param name="indent" select="$indent + 1" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="P3/CommentaryRef[exists(following-sibling::Pnumber)]">	<!-- ukpga/2016/4/2016-07-31 -->
	<xsl:param name="force" as="xs:boolean" select="false()" />
	<xsl:if test="$force">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<xsl:template match="P3/Pnumber" />

<xsl:template match="P3para">
	<xsl:param name="p2-number-must-go-with-p3" as="xs:boolean" select="false()" />
	<xsl:param name="p3-number-must-go-with-p4" as="xs:boolean" select="false()" />
	<xsl:param name="p3-number-already-handled" as="xs:boolean" select="false()" />
	<xsl:apply-templates>
		<xsl:with-param name="p2-number-must-go-with-p3" select="$p2-number-must-go-with-p3" />
		<xsl:with-param name="p3-number-must-go-with-p4" select="$p3-number-must-go-with-p4" />
		<xsl:with-param name="p3-number-already-handled" select="$p3-number-already-handled" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="P3/P3para[1]/Text[empty(preceding-sibling::*)]" priority="1">	<!-- P3/... exclude BlockAmendment/P3para (asp/2006/1/enacted) -->
	<xsl:param name="p2-number-must-go-with-p3" as="xs:boolean" select="false()" />
	<xsl:param name="p3-number-already-handled" as="xs:boolean" select="false()" />
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<!-- p3-number-must-go-with-p4 can't be true here -->
	<xsl:variable name="include-p2-number" as="xs:boolean" select="$p2-number-must-go-with-p3 and empty(../../preceding-sibling::*)" />
	<xsl:if test="$debug and $p3-number-already-handled and $include-p2-number">
		<xsl:message terminate="true">
		</xsl:message>
	</xsl:if>
	<xsl:choose>
		<xsl:when test="$p3-number-already-handled">
			<xsl:next-match />
		</xsl:when>
		<xsl:otherwise>
			<w:p>
				<xsl:call-template name="style-and-indent-formatting">
					<xsl:with-param name="style-id">
						<xsl:choose>
							<xsl:when test="$include-p2-number">
								<xsl:call-template name="subsection-p3-style-id" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="p3-heading-style-id" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>

				<xsl:if test="$include-p2-number">
					<xsl:apply-templates select="../../../../Pnumber/preceding-sibling::CommentaryRef">
						<xsl:with-param name="force" select="true()" />
					</xsl:apply-templates>
					<xsl:call-template name="handle-pnumber">
						<xsl:with-param name="pnumber" select="../../../../Pnumber" />
						<xsl:with-param name="punc-before" select="'('" />
						<xsl:with-param name="punc-after" select="')'" />
						<xsl:with-param name="add-tab" select="false()" />
						<xsl:with-param name="add-space" select="$compact-format" />
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="not($compact-format)">
					<w:r>	<!-- tab to right-aligned number -->
						<w:tab/>
					</w:r>
				</xsl:if>

				<xsl:apply-templates select="../../Pnumber/preceding-sibling::CommentaryRef">
					<xsl:with-param name="force" select="true()" />
				</xsl:apply-templates>

				<xsl:call-template name="handle-pnumber">
					<xsl:with-param name="pnumber" select="../../Pnumber" />
					<xsl:with-param name="punc-before" select="'('" />
					<xsl:with-param name="punc-after" select="')'" />
					<xsl:with-param name="add-tab" select="not($include-p2-number) or not($compact-format)" />
					<xsl:with-param name="add-space" select="$include-p2-number and $compact-format" />
				</xsl:call-template>

				<xsl:apply-templates />
				<xsl:call-template name="block-amendment-lead-in" />
			</w:p>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="P3para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="p3-text-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>
<xsl:template match="P3para/BlockText/Text | P3para/BlockText/Para/Text">
	<xsl:call-template name="block-text">
		<xsl:with-param name="style">
			<xsl:call-template name="p3-text-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<xsl:template match="P4">
	<xsl:param name="p2-number-must-go-with-p4" as="xs:boolean" select="false()" />
	<xsl:param name="p3-number-must-go-with-p4" as="xs:boolean" select="false()" />
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:variable name="first" as="element()" select="Pnumber/following-sibling::*[1]" />
	<xsl:choose>
		<xsl:when test="exists($first/self::P4para/child::*[1][self::Text])" />	<!-- typical case -->
		<xsl:when test="$first/self::P4para/child::*[1][self::P5]" />	<!-- p4-number-must-go-with-p5 -->
		<xsl:otherwise>
			<xsl:call-template name="orphan-pnumber">
				<xsl:with-param name="style">
					<xsl:call-template name="p4-heading-style-id" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:apply-templates>
		<xsl:with-param name="p2-number-must-go-with-p4" select="$p2-number-must-go-with-p4" />
		<xsl:with-param name="p3-number-must-go-with-p4" select="$p3-number-must-go-with-p4" />
		<xsl:with-param name="p4-number-must-go-with-p5" select="exists(Pnumber/following-sibling::*[1]/child::*[1][self::P5])" />		
		<xsl:with-param name="indent" select="$indent + 1" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="P4/CommentaryRef[exists(following-sibling::Pnumber)]">	<!-- nia/2011/24/2012-06-06 -->
	<xsl:param name="force" as="xs:boolean" select="false()" />
	<xsl:if test="$force">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<xsl:template match="P4/Pnumber" />

<xsl:template name="handle-pnumber">
	<xsl:param name="pnumber" as="element(Pnumber)" required="yes" />
	<xsl:param name="punc-before" as="xs:string?" select="()" />
	<xsl:param name="punc-after" as="xs:string?" select="()" />
	<xsl:param name="add-tab" as="xs:boolean" select="true()" />
	<xsl:param name="add-space" as="xs:boolean" select="false()" />
	<xsl:param name="add-bookmark" as="xs:boolean" select="false()" />
	<xsl:variable name="bookmark-id" as="xs:integer?">
		<xsl:if test="exists(//InternalLink[@Ref=$pnumber/parent::*/@id])">
			<xsl:sequence select="local:get-bookmark-id-2($pnumber/parent::*)" />
		</xsl:if>
	</xsl:variable>
	<xsl:if test="exists($bookmark-id)">
		<w:bookmarkStart w:id="{ $bookmark-id }" w:name="{ $pnumber/parent::*/@id }" />	<!-- generate-id($pnumber/..) -->
	</xsl:if>
	<xsl:apply-templates select="$pnumber/node()">
		<xsl:with-param name="first-text-node-in-pnumber" select="$pnumber/descendant::text()[normalize-space()][1]" tunnel="yes" />
		<xsl:with-param name="last-text-node-in-pnumber" select="$pnumber/descendant::text()[normalize-space()][last()]" tunnel="yes" />
		<xsl:with-param name="punc-before-first-node-in-pnumber" tunnel="yes">
			<xsl:sequence select="if ($pnumber/@PuncBefore or $pnumber/@PuncAfter) then string($pnumber/@PuncBefore) else $punc-before" />
		</xsl:with-param>
		<xsl:with-param name="punc-after-last-node-in-pnumber" tunnel="yes">
			<xsl:sequence select="if ($pnumber/@PuncBefore or $pnumber/@PuncAfter) then string($pnumber/@PuncAfter) else $punc-after" />
		</xsl:with-param>
	</xsl:apply-templates>
	<xsl:if test="exists($bookmark-id)">
       	<w:bookmarkEnd w:id="{ $bookmark-id }"/>
	</xsl:if>
	<xsl:choose>
		<xsl:when test="$add-tab">
			<w:r>
				<w:tab/>
			</w:r>
		</xsl:when>
		<xsl:when test="$add-space">
			<w:r>
				<w:t xml:space="preserve"> </w:t>
			</w:r>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="P4para">
	<xsl:param name="p2-number-must-go-with-p4" as="xs:boolean" select="false()" />
	<xsl:param name="p3-number-must-go-with-p4" as="xs:boolean" select="false()" />
	<xsl:param name="p4-number-must-go-with-p5" as="xs:boolean" select="false()" />
	<xsl:apply-templates>
		<xsl:with-param name="p2-number-must-go-with-p4" select="$p2-number-must-go-with-p4" />
		<xsl:with-param name="p3-number-must-go-with-p4" select="$p3-number-must-go-with-p4" />
		<xsl:with-param name="p4-number-must-go-with-p5" select="$p4-number-must-go-with-p5" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="P4/P4para[1]/Text[empty(preceding-sibling::*)]" priority="1">	<!-- maybe P4para should be [empty(preceding-sibling::*[not(self::Pnumber)])] -->
	<xsl:param name="p2-number-must-go-with-p4" as="xs:boolean" select="false()" />
	<xsl:param name="p3-number-must-go-with-p4" as="xs:boolean" select="false()" />
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:if test="$debug and $p2-number-must-go-with-p4 and $p3-number-must-go-with-p4">
		<xsl:message terminate="yes">p2-number-must-go-with-p4 and p3-number-must-go-with-p4</xsl:message>
	</xsl:if>
	<xsl:variable name="include-p2-number" as="xs:boolean" select="$p2-number-must-go-with-p4 and empty(../../preceding-sibling::*)" />
	<xsl:variable name="include-p3-number" as="xs:boolean" select="$p3-number-must-go-with-p4 and empty(../../preceding-sibling::*)" />
	<!-- p4-number-must-go-with-p5 can't be true here -->
	<w:p>
		<xsl:call-template name="style-and-indent-formatting">
			<xsl:with-param name="style-id">
				<xsl:choose>
					<xsl:when test="$include-p2-number">
						<xsl:call-template name="p2-p4-style-id" />
					</xsl:when>
					<xsl:when test="$include-p3-number">
						<xsl:call-template name="p3-p4-style-id" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="p4-heading-style-id" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:if test="$compact-format and not($include-p2-number or $include-p3-number)">
			<w:r>
				<w:tab/>
			</w:r>
		</xsl:if>
		
		<xsl:if test="$include-p2-number or $include-p3-number">
			<xsl:apply-templates select="../../../../Pnumber/preceding-sibling::CommentaryRef">	<!-- check to see if this is done in other cases -->
				<xsl:with-param name="force" select="true()" />
			</xsl:apply-templates>
			<xsl:call-template name="handle-pnumber">
				<xsl:with-param name="pnumber" select="../../../../Pnumber" />
				<xsl:with-param name="punc-before" select="'('" />
				<xsl:with-param name="punc-after" select="')'" />
				<xsl:with-param name="add-tab" select="true()" />
			</xsl:call-template>
		</xsl:if>
		
		<xsl:if test="not($compact-format)">
			<w:r>	<!-- tab to right-aligned number -->
				<w:tab/>
			</w:r>
		</xsl:if>
		
		<xsl:apply-templates select="../../Pnumber/preceding-sibling::CommentaryRef">
			<xsl:with-param name="force" select="true()" />
		</xsl:apply-templates>
		<xsl:call-template name="handle-pnumber">
			<xsl:with-param name="pnumber" select="../../Pnumber" />
			<xsl:with-param name="punc-before" select="'('" />
			<xsl:with-param name="punc-after" select="')'" />
			<xsl:with-param name="add-tab" select="true()" />
		</xsl:call-template>
		<xsl:apply-templates />
		<!-- check for lead-in to BlockAmendment -->
       	<xsl:call-template name="block-amendment-lead-in" />
	</w:p>
</xsl:template>

<xsl:template match="P4para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="p4-text-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>
<xsl:template match="P4para/BlockText/Text | P4para/BlockText/Para/Text">
	<xsl:call-template name="block-text">
		<xsl:with-param name="style">
			<xsl:call-template name="p4-text-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<xsl:template match="P5">
	<xsl:param name="p4-number-must-go-with-p5" as="xs:boolean" select="false()" />
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="p4-number-must-go-with-p5" select="$p4-number-must-go-with-p5" />
		<xsl:with-param name="indent" select="$indent + 1" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="P5/Pnumber" />

<xsl:template match="P5para">
	<xsl:param name="p4-number-must-go-with-p5" as="xs:boolean" select="false()" />
	<xsl:apply-templates>
		<xsl:with-param name="p4-number-must-go-with-p5" select="$p4-number-must-go-with-p5" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="P5para[1][exists(parent::P5)]/Text[empty(preceding-sibling::*)]" priority="1"><!-- exists(parent::P5) excludes children of BlockAmendment -->
	<xsl:param name="p4-number-must-go-with-p5" as="xs:boolean" select="false()" />
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<xsl:variable name="include-p4-number" as="xs:boolean" select="$p4-number-must-go-with-p5 and empty(../../preceding-sibling::*)" />
	<w:p>
		<xsl:call-template name="style-and-indent-formatting">
			<xsl:with-param name="style-id">
				<xsl:choose>
					<xsl:when test="$include-p4-number">
						<xsl:call-template name="p4-p5-style-id" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="p5-heading-style-id" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:if test="$include-p4-number">
			<xsl:call-template name="handle-pnumber">
				<xsl:with-param name="pnumber" select="../../../../Pnumber" />
				<xsl:with-param name="punc-before" select="'('" />
				<xsl:with-param name="punc-after" select="')'" />
				<xsl:with-param name="add-tab" select="true()" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="not($compact-format)">
			<w:r>	<!-- tab to right-aligned number -->
				<w:tab/>
			</w:r>
		</xsl:if>
		
		<xsl:call-template name="handle-pnumber">
			<xsl:with-param name="pnumber" select="../../Pnumber" />
			<xsl:with-param name="punc-before" select="'('" />
			<xsl:with-param name="punc-after" select="')'" />
			<xsl:with-param name="add-tab" select="true()" />
		</xsl:call-template>

		<xsl:apply-templates />

       	<xsl:call-template name="block-amendment-lead-in" />
	</w:p>
</xsl:template>

<xsl:template match="P5para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="p5-text-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<!-- P6 -->

<xsl:template match="P6">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="indent" select="$indent + 1" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="P6/Pnumber" />

<xsl:template match="P6para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="P6para[1]/Text[1]" priority="1">
	<xsl:param name="compact-format" as="xs:boolean" tunnel="yes" />
	<w:p>
		<xsl:call-template name="style-and-indent-formatting">
			<xsl:with-param name="style-id">
				<xsl:call-template name="p6-heading-style-id" />
			</xsl:with-param>
		</xsl:call-template>

		<xsl:if test="not($compact-format)">
			<w:r>	<!-- tab to right-aligned number -->
				<w:tab/>
			</w:r>
		</xsl:if>
		
		<xsl:call-template name="handle-pnumber">
			<xsl:with-param name="pnumber" select="../../Pnumber" />
			<xsl:with-param name="punc-before" select="'('" />
			<xsl:with-param name="punc-after" select="')'" />
			<xsl:with-param name="add-tab" select="true()" />
		</xsl:call-template>

		<xsl:apply-templates />

       	<xsl:call-template name="block-amendment-lead-in" />
	</w:p>
</xsl:template>

<xsl:template match="P6para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="p6-text-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<!-- P7 -->

<xsl:template match="P7">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="indent" select="$indent + 1" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="P7/Pnumber" />

<xsl:template match="P7para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="P7para[empty(preceding-sibling::*[empty(self::Pnumber)])]/Text[empty(preceding-sibling::*)]" priority="1">
	<w:p>
		<xsl:call-template name="style-and-indent-formatting">
			<xsl:with-param name="style-id">
				<xsl:call-template name="p7-heading-style-id" />
			</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="handle-pnumber">
			<xsl:with-param name="pnumber" select="../../Pnumber" />
			<xsl:with-param name="punc-before" select="'('" />
			<xsl:with-param name="punc-after" select="')'" />
			<xsl:with-param name="add-tab" select="true()" />
		</xsl:call-template>

		<xsl:apply-templates />

		<xsl:call-template name="block-amendment-lead-in" />
	</w:p>
</xsl:template>

<xsl:template match="P7para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="p7-text-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<!-- block text -->

<xsl:template match="BlockText">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="indent" select="$indent + 1" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="BlockText/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template name="block-text">
	<xsl:param name="style" as="xs:string" />
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="$style" />
		<xsl:with-param name="para-formatting" as="element(w:ind)">
			<w:ind w:left="{ local:get-style-indent($style) + $indent-width }" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="BlockText/Text | BlockText/Para/Text" priority="-1">
	<xsl:param name="indent" as="xs:integer" select="1" tunnel="yes" />
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
		<xsl:with-param name="para-formatting" as="element(w:ind)">
			<w:ind w:left="{ $indent * $indent-width }" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

</xsl:transform>
