<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:local="local"
	exclude-result-prefixes="xs local">

<xsl:template match="BlockAmendment">
	<xsl:call-template name="block-extract">
		<xsl:with-param name="is-amendment" as="xs:boolean" select="true()" />
		<xsl:with-param name="class" as="xs:string" select="if (exists(@TargetClass)) then @TargetClass else 'unknown'" />
		<xsl:with-param name="subclass" as="xs:string" select="if (exists(@TargetSubClass)) then @TargetSubClass else 'unknown'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="BlockExtract">
	<xsl:call-template name="block-extract">
		<xsl:with-param name="is-amendment" as="xs:boolean" select="false()" />
		<xsl:with-param name="class" as="xs:string" select="if (exists(@SourceClass)) then @SourceClass else 'unknown'" />
		<xsl:with-param name="subclass" as="xs:string" select="if (exists(@SourceSubClass)) then @SourceSubClass else 'unknown'" />
	</xsl:call-template>
</xsl:template>

<xsl:function name="local:extract-is-compact-format" as="xs:boolean">
	<xsl:param name="class" as="xs:string" />
	<xsl:param name="subclass" as="xs:string" />
	<xsl:param name="context" as="xs:string" />
	<xsl:param name="main-is-compact" as="xs:boolean" />
	<xsl:choose>
		<xsl:when test="$context = 'schedule'">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:when test="$class = 'secondary'">
			<xsl:sequence select="true()" />
		</xsl:when>
<!-- 		<xsl:when test="$class = 'euretained'">
			<xsl:sequence select="false()" />
		</xsl:when> -->
		<xsl:when test="$is-primary">
			<xsl:sequence select="$main-is-compact" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template name="block-extract">
	<xsl:param name="is-amendment" as="xs:boolean" required="yes" />
	<xsl:param name="class" as="xs:string" required="yes" />
	<xsl:param name="subclass" as="xs:string" required="yes" />
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:param name="compact-format" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:variable name="partial-refs" as="xs:string?" select="@PartialRefs" />
	<xsl:variable name="context" as="xs:string" select="if (exists(@Context)) then @Context else 'unknown'" />
	<xsl:variable name="extract-is-compact-format" as="xs:boolean" select="local:extract-is-compact-format($class, $subclass, $context, $compact-format)" />
	<xsl:variable name="first-text-node" as="text()?">
		<xsl:choose>
			<xsl:when test="$context = 'schedule'">
				<xsl:sequence select="descendant::text()[normalize-space()][1]" />
			</xsl:when>
			<xsl:when test="$extract-is-compact-format">
				<xsl:sequence select="descendant::text()[normalize-space()][1]" />
			</xsl:when>
			<xsl:when test="*[1][self::P1group] and exists(*[1]/P1[1]/Pnumber/descendant::text()[normalize-space()])">
				<xsl:sequence select="*[1]/P1[1]/Pnumber/descendant::text()[normalize-space()][1]" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="descendant::text()[normalize-space()][1]" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="$debug">
		<xsl:comment>
			<xsl:value-of select="local-name(.)" />
			<xsl:text> class=</xsl:text>
			<xsl:value-of select="$class" />
			<xsl:text> subclass=</xsl:text>
			<xsl:value-of select="$subclass" />
			<xsl:text> context=</xsl:text>
			<xsl:value-of select="$context" />
		</xsl:comment>
	</xsl:if>
	<xsl:apply-templates select="if (exists($partial-refs)) then *[not(@id = $partial-refs)] else *">
		<xsl:with-param name="within-extract" as="xs:boolean" select="true()" tunnel="yes" />
		<xsl:with-param name="extract-is-amendment" as="xs:boolean" select="$is-amendment" tunnel="yes" />
		<xsl:with-param name="extract-class" as="xs:string" select="$class" tunnel="yes" />
		<xsl:with-param name="extract-subclass" as="xs:string" select="$subclass" tunnel="yes" />
		<xsl:with-param name="extract-context" as="xs:string" select="$context" tunnel="yes" />
		<xsl:with-param name="inside-schedule" as="xs:boolean" select="@Context = 'schedule'" tunnel="yes" />
		<xsl:with-param name="extract-format" as="xs:string" select="if (exists(@Format)) then @Format else 'default'" tunnel="yes" />
		<xsl:with-param name="first-text-node-in-extract" as="text()?" select="$first-text-node" tunnel="yes" />
		<xsl:with-param name="last-text-node-in-extract" as="text()?" select="descendant::text()[normalize-space()][last()]" tunnel="yes" />
		<xsl:with-param name="append-text" as="element(AppendText)?" select="following-sibling::*[1][self::AppendText]" tunnel="yes" />
		<xsl:with-param name="indent" as="xs:integer" select="$indent + 1" tunnel="yes" />
		<xsl:with-param name="extract-indent" as="xs:integer" select="$indent + 1" tunnel="yes" />
		<xsl:with-param name="compact-format" select="$extract-is-compact-format" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template name="run-for-start-quote">
	<xsl:param name="extract-format" as="xs:string" select="'default'" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$extract-format = 'none'" />
		<xsl:otherwise>
		    <w:r>
		        <w:fldChar w:fldCharType="begin"/>
		    </w:r>
		    <w:r>
			    <xsl:choose>
			    	<xsl:when test="$extract-format = 'single'">
				        <w:instrText xml:space="preserve"> SYMBOL 145 \* MERGEFORMAT </w:instrText>
			    	</xsl:when>
			    	<xsl:otherwise>
				        <w:instrText xml:space="preserve"> SYMBOL 147 \* MERGEFORMAT </w:instrText>
			    	</xsl:otherwise>
			    </xsl:choose>
		    </w:r>
		    <w:r>
		        <w:fldChar w:fldCharType="end"/>
		    </w:r>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="run-for-end-quote">
	<xsl:param name="extract-format" as="xs:string" select="'none'" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$extract-format = 'none'" />
		<xsl:otherwise>
		    <w:r>
		        <w:fldChar w:fldCharType="begin"/>
		    </w:r>
		    <w:r>
			    <xsl:choose>
			    	<xsl:when test="$extract-format = 'single'">
				        <w:instrText xml:space="preserve"> SYMBOL 146 \* MERGEFORMAT </w:instrText>
			    	</xsl:when>
			    	<xsl:otherwise>
				        <w:instrText xml:space="preserve"> SYMBOL 148 \* MERGEFORMAT </w:instrText>
			    	</xsl:otherwise>
			    </xsl:choose>
		    </w:r>
		    <w:r>
		        <w:fldChar w:fldCharType="end"/>
		    </w:r>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="AppendText" />


<xsl:template match="BlockAmendment/P | BlockAmendment/Para | BlockExtract/P | BlockExtract/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="BlockAmendment/P/Text | BlockAmendment/Para/Text | BlockAmendment/Text | BlockExtract/P/Text | BlockExtract/Para/Text | BlockExtract/Text">
	<!-- <xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" /> -->
	<xsl:call-template name="p">
<!-- 		<xsl:with-param name="para-formatting" as="element()">
			<w:ind w:left="{ $indent * 720 }" />
		</xsl:with-param> -->
	</xsl:call-template>
</xsl:template>

<xsl:template match="FragmentNumber">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="FragmentNumber/Number">
	<xsl:variable name="context" as="xs:string" select="../@Context" />
	<xsl:variable name="style" as="xs:string?">
		<xsl:choose>
			<xsl:when test="$context = 'Group'">
				<xsl:call-template name="group-number-style-id" />
			</xsl:when>
			<xsl:when test="$context = 'Part'">
				<xsl:call-template name="part-number-style-id" />
			</xsl:when>
			<xsl:when test="$context = 'Chapter'">
				<xsl:call-template name="chapter-number-style-id" />
			</xsl:when>
			<xsl:when test="$context = 'Pblock'">
				<xsl:call-template name="crossheading-number-style-id" />
			</xsl:when>
			<xsl:when test="$context = 'PsubBlock'">
				<xsl:call-template name="subheading-number-style-id" />
			</xsl:when>
			<xsl:when test="$context = 'Schedule'">
				<xsl:call-template name="schedule-number-style-id" />
			</xsl:when>
			<xsl:when test="$debug and ($context = 'Footnote')">
				<xsl:message terminate="yes">not implemented</xsl:message>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="$style" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="FragmentTitle">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="FragmentTitle/Title">
	<xsl:variable name="context" as="xs:string" select="../@Context" />
	<xsl:variable name="style" as="xs:string?">
		<xsl:choose>
			<xsl:when test="$context = 'Group'">
				<xsl:call-template name="group-heading-style-id" />
			</xsl:when>
			<xsl:when test="$context = 'Part'">
				<xsl:call-template name="part-heading-style-id" />
			</xsl:when>
			<xsl:when test="$context = 'Chapter'">
				<xsl:call-template name="chapter-heading-style-id" />
			</xsl:when>
			<xsl:when test="$context = 'Pblock'">
				<xsl:call-template name="crossheading-style-id" />
			</xsl:when>
			<xsl:when test="$context = 'PsubBlock'">
				<xsl:call-template name="subheading-style-id" />
			</xsl:when>
			<xsl:when test="$context = 'P1group'">
				<xsl:call-template name="unnumbered-section-heading-style-id" />
			</xsl:when>
			<xsl:when test="$context = 'P2group'">
				<xsl:call-template name="subsection-heading-style-id" />
			</xsl:when>
			<xsl:when test="$context = 'P3group'">
				<xsl:call-template name="p3-heading-style-id" />
			</xsl:when>
			<xsl:when test="$context = 'Schedule'">
				<xsl:call-template name="schedule-heading-style-id" />
			</xsl:when>
			<xsl:when test="$context = 'Figure'">
				<xsl:call-template name="figure-heading-style-id" />
			</xsl:when>
			<xsl:when test="$context = 'Tabular'">
				<xsl:call-template name="tabular-heading-style-id" />
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="$style" />
	</xsl:call-template>
</xsl:template>

<!-- for EU documents, probably should have been wrapped in FragmentTitle -->
<xsl:template match="BlockAmendment/Number | BlockAmendment/Title | BlockAmendment/Subtitle | BlockAmendment/Pnumber">	<!-- eur/2014/592/adopted, eur/2019/318/adopted, eur/2019/2175/adopted -->
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'Normal'" />
		<xsl:with-param name="para-formatting" as="element(w:ind)">
			<w:ind w:left="{ $indent * $indent-width }" />	<!-- should this really be necessary? -->
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>
<xsl:template match="BlockExtract/Number | BlockExtract/Title | BlockExtract/Subtitle | BlockExtract/Pnumber">	<!-- eur/2013/519/adopted -->
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'Normal'" />
		<xsl:with-param name="para-formatting" as="element(w:ind)">
			<w:ind w:left="{ $indent * $indent-width }" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template name="block-amendment-lead-in">
	<xsl:variable name="amendment" as="element()?" select="following-sibling::*[1]/self::BlockAmendment" />
	<xsl:variable name="partial-refs" as="attribute(PartialRefs)?" select="$amendment/@PartialRefs" />
	<xsl:if test="exists($partial-refs)">
		<w:r>
			<w:t xml:space="preserve"> </w:t>
		</w:r>
		<xsl:variable name="lead-in" as="element()" select="$amendment/*[@id = $partial-refs]" />
		<xsl:apply-templates select="$lead-in" mode="lead-in">
			<xsl:with-param name="within-extract" as="xs:boolean" select="true()" tunnel="yes" />
			<xsl:with-param name="extract-is-amendment" as="xs:boolean" select="true()" tunnel="yes" />
			<xsl:with-param name="extract-format" as="xs:string" select="$amendment/@Format" tunnel="yes" />
			<xsl:with-param name="first-text-node-in-extract" as="text()?" tunnel="yes">
				<xsl:sequence select="$lead-in/descendant::text()[normalize-space()][1]" />
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:if>
</xsl:template>

<xsl:template match="*" mode="lead-in">
	<xsl:apply-templates mode="lead-in" />
</xsl:template>

<xsl:template match="text()" mode="lead-in">
	<xsl:apply-templates select="." />
</xsl:template>

<xsl:template match="InlineAmendment">
	<xsl:apply-templates />
</xsl:template>

</xsl:transform>
