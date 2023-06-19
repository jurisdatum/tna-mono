<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:array="http://www.w3.org/2005/xpath-functions/array"
	xmlns:local="local"
	exclude-result-prefixes="html xs fo array local">


<xsl:template match="Tabular">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Tabular/Number">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="tabular-number-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Tabular/Title">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="tabular-heading-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Tabular/Subtitle">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:call-template name="tabular-subheading-style-id" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="TableText | TableText/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="TableText/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="TableText" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="html:table">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:apply-templates select="html:caption" />
	<w:tbl>
        <w:tblPr> <!-- required -->
			<xsl:if test="$is-eu">
				<w:tblStyle w:val="EUTableDefault" />
			</xsl:if>
             <xsl:if test="$indent gt 0">
            	<w:tblInd w:w="{ $indent * $indent-width }" />	<!-- w:type="dxa" -->
            </xsl:if>
        </w:tblPr>
		<w:tblGrid>
			<xsl:apply-templates select="html:colgroup | html:col" />
		</w:tblGrid>
		<xsl:apply-templates select="*[not(self::html:caption)][not(self::html:colgroup)][not(self::html:col)][not(self::html:tfoot)]">
			<xsl:with-param name="within-extract" as="xs:boolean" select="false()" tunnel="yes" />	<!-- this prevents indentation within table cells -->
		</xsl:apply-templates>
		<xsl:apply-templates select="html:tfoot">
			<xsl:with-param name="within-extract" as="xs:boolean" select="false()" tunnel="yes" />	<!-- this prevents indentation within table cells -->
		</xsl:apply-templates>
	</w:tbl>
	<xsl:if test="empty(ancestor::html:table)">
		<xsl:call-template name="table-notes" />
	</xsl:if>
</xsl:template>

<!-- nested tables, e.g., for tables within table footnotes (eur/2006/1195/adopted) -->
<xsl:template match="html:table//html:table">
	<xsl:next-match />
	<w:p />
</xsl:template>

<xsl:template match="html:colgroup">	<!-- there can be multiple, e.g., in uksi/2008/409/2015-04-06 -->
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="html:col" priority="1">
</xsl:template>

<xsl:template match="html:col">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:variable name="table-width" as="xs:integer" select="$content-width - ( $indent * $indent-width )" />
	<w:gridCol>
		<xsl:attribute name="w:w">
			<xsl:choose>
				<xsl:when test="ends-with(@width, 'pt')">
					<xsl:variable name="points" as="xs:string" select="substring(@width, 1, string-length(@width) - 2)" />
					<xsl:variable name="points" as="xs:double" select="number($points)" />
					<xsl:value-of select="format-number($points * 20, '0')" />
				</xsl:when>
				<xsl:when test="ends-with(@width, '%')">
					<xsl:variable name="percent" as="xs:string" select="substring(@width, 1, string-length(@width) - 1)" />
					<xsl:variable name="percent" as="xs:double" select="number($percent) - 1.0" />	<!-- sometimes percents add up to > 100%, e.g., 2019/1/2019-02-12 -->
					<xsl:value-of select="format-number($table-width * $percent, '0')" />
				</xsl:when>
			</xsl:choose>
		</xsl:attribute>
	</w:gridCol>
</xsl:template>

<xsl:template match="html:col" priority="-1">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:variable name="table-width" as="xs:integer" select="$content-width - ($indent * $indent-width)" />
	<w:gridCol>
		<xsl:attribute name="w:w">
			<xsl:choose>
				<xsl:when test="ends-with(@width, '%')">
					<xsl:value-of select="round(xs:integer(substring(@width, 1, string-length(@width) - 1)) * .01 * $table-width)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>2880</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</w:gridCol>
</xsl:template>

<xsl:template match="html:caption">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'TableCaption'" />
	</xsl:call-template>
</xsl:template>

<!-- don't really need these -->
<xsl:function name="local:index-of-nth-zero" as="xs:integer">
	<xsl:param name="values" as="array(xs:integer)" />
	<xsl:param name="n" as="xs:integer" />
	<xsl:param name="considered" as="xs:integer" />	<!-- the number of values already counted -->
	<xsl:param name="found" as="xs:integer" />	<!-- the number of zeros already found -->
	<xsl:choose>
		<xsl:when test="$found eq $n">
			<xsl:sequence select="$considered" />
		</xsl:when>
		<xsl:when test="array:size($values) eq 0">
			<xsl:sequence select="$n + $considered - $found" />
		</xsl:when>
		<xsl:when test="array:head($values) eq 0">
			<xsl:sequence select="local:index-of-nth-zero(array:tail($values), $n, $considered + 1, $found + 1)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="local:index-of-nth-zero(array:tail($values), $n, $considered + 1, $found)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
<xsl:function name="local:index-of-nth-zero" as="xs:integer">
	<xsl:param name="values" as="array(xs:integer)" />
	<xsl:param name="n" as="xs:integer" />
	<xsl:sequence select="local:index-of-nth-zero($values, $n, 0, 0)" />
</xsl:function>

<xsl:function name="local:minus-one" as="xs:integer">
	<xsl:param name="n" as="xs:integer" />
	<xsl:sequence select="$n - 1" />
</xsl:function>

<xsl:mode use-accumulators="table-layout"/>
<xsl:accumulator name="table-layout" as="array(array(xs:integer?))" initial-value="[[],[],[]]">
	<xsl:accumulator-rule match="html:thead | html:tbody | html:tfoot" select="[[],[],[]]" />
	<xsl:accumulator-rule match="html:tr" select="[$value(2),[],[]]" />
	<xsl:accumulator-rule match="html:td" phase="start">
		<xsl:variable name="state-after-previous-rows" as="array(xs:integer?)" select="$value(1)" />
		<xsl:variable name="state-of-this-row" as="array(xs:integer?)" select="$value(2)" />
		<xsl:variable name="carryover" as="array(xs:integer?)">
			<!-- find first zero in state-after-previous-rows beginning at index = size of $state-of-this-row -->
			<xsl:variable name="a" as="xs:integer" select="array:size($state-of-this-row)" />
			<xsl:variable name="b" as="array(xs:integer?)" select="if (array:size($state-after-previous-rows) le $a) then [] else array:subarray($state-after-previous-rows, $a + 1)" />
			<xsl:variable name="c" as="xs:integer*" select="array:flatten($b)" />
			<xsl:variable name="offset" as="xs:integer?" select="index-of($c, 0)[1]" />
			<xsl:variable name="carryover-values" as="xs:integer*">
				<xsl:choose>
					<xsl:when test="empty($offset)">
						<xsl:for-each select="$c">
							<xsl:sequence select=". - 1" />
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="$offset eq 1">	<!-- unnecessary -->
						<xsl:sequence select="()" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="$c[position() lt $offset]">
							<xsl:sequence select=". - 1" />
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:sequence select="array { $carryover-values }" />
		</xsl:variable>
		<xsl:sequence select="array:put($value, 3, $carryover)" />	<!-- set carryover -->
	</xsl:accumulator-rule>
	<xsl:accumulator-rule match="html:td" phase="end">
		<xsl:variable name="state-after-previous-rows" as="array(xs:integer?)" select="$value(1)" />
		<xsl:variable name="state-of-this-row" as="array(xs:integer?)" select="$value(2)" />
		<xsl:variable name="carryover" as="array(xs:integer?)" select="$value(3)" />
		<xsl:variable name="new-values" as="array(xs:integer)">
			<xsl:variable name="colspan" as="xs:integer" select="if (exists(@colspan)) then xs:integer(@colspan) else 1" />
			<xsl:variable name="rowspan" as="xs:integer" select="if (exists(@rowspan)) then xs:integer(@rowspan) else 1" />
			<xsl:variable name="new-value-sequence" as="xs:integer+">
				<xsl:for-each select="1 to $colspan">
					<xsl:sequence select="$rowspan - 1" />
				</xsl:for-each>
			</xsl:variable>
			<xsl:sequence select="array { $new-value-sequence }" />
		</xsl:variable>
		<xsl:variable name="new-state-of-this-row" as="array(xs:integer)">
			<xsl:sequence select="array:join(( $state-of-this-row, $carryover, $new-values ))" />
		</xsl:variable>
		<xsl:sequence select="[$state-after-previous-rows, $new-state-of-this-row, []]" />
	</xsl:accumulator-rule>
</xsl:accumulator>
<xsl:template name="add-vertically-merged-cells">
	<xsl:variable name="table-layout" as="array(array(xs:integer?))" select="accumulator-before('table-layout')" />
	<xsl:variable name="carryover" as="array(xs:integer?)" select="$table-layout(3)" />
	<xsl:for-each select="1 to array:size($carryover)">
		<w:tc>
			<w:tcPr>
				<w:vMerge />
			</w:tcPr>
			<w:p />
		</w:tc>
	</xsl:for-each>
</xsl:template>

<xsl:template match="html:thead | html:tbody | html:tfoot">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="html:thead/html:tr">
	<w:tr>
		<w:trPr>
			<w:tblHeader />
		</w:trPr>
		<xsl:apply-templates />
	</w:tr>
</xsl:template>

<xsl:template match="html:tr">
	<w:tr>
		<xsl:apply-templates />
	</w:tr>
</xsl:template>

<xsl:template match="html:th">
	<!-- merge cells? -->
	<w:tc>
		<w:tcPr>
			<xsl:if test="exists(@colspan) and number(@colspan) gt 1">
				<w:gridSpan w:val="{ @colspan }" />
			</xsl:if>
			<xsl:call-template name="cell-borders" />
		</w:tcPr>
		<xsl:choose>
			<xsl:when test="every $child in * satisfies local:is-inline($child)">
				<xsl:call-template name="p">
					<xsl:with-param name="style">
						<xsl:choose>
							<xsl:when test="parent::html:tr/parent::html:tbody">
								<xsl:sequence select="'TableHeader2'" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="'TableHeader'" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</w:tc>
</xsl:template>

<xsl:template name="cell-border">
	<xsl:param name="name" as="xs:string" />
	<xsl:param name="style" as="attribute()?" />
	<xsl:param name="width" as="attribute()?" />
	<xsl:param name="color" as="attribute()?" />
	<xsl:if test="exists($style) or (exists($width) and not(string($width) = 'inherit')) or exists($color)">
		<xsl:element name="w:{ $name }">
			<xsl:attribute name="w:val">
				<xsl:choose>
					<xsl:when test="empty($style)">
						<xsl:text>single</xsl:text>
					</xsl:when>
					<xsl:when test="$style = 'solid'">
						<xsl:text>single</xsl:text>
					</xsl:when>
					<xsl:when test="$style = 'inherit'">	<!-- uksi/1954/898/made -->
						<xsl:text>single</xsl:text>
					</xsl:when>
					<xsl:when test="$style = ('dashed', 'dotted', 'double', 'outset')">
						<xsl:value-of select="$style" />
					</xsl:when>
					<xsl:when test="$debug">
						<xsl:message terminate="yes">
							<xsl:text>style: </xsl:text>
							<xsl:value-of select="$style/name()" />
							<xsl:text> = </xsl:text>
							<xsl:value-of select="$style" />
						</xsl:message>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>single</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="w:sz">
				<xsl:variable name="default" as="xs:integer" select="20" />
				<xsl:choose>
					<xsl:when test="empty($width)">
						<xsl:value-of select="$default" />
					</xsl:when>
					<xsl:when test="$width = 'inherit'">	<!-- eur/2009/1287/adopted -->
						<xsl:value-of select="$default" />
					</xsl:when>
					<xsl:when test="ends-with($width, 'pt')">
						<xsl:variable name="points" as="xs:string" select="substring($width, 1, string-length($width) - 2)" />
						<xsl:variable name="points" as="xs:double" select="number($points)" />
						<xsl:value-of select="format-number($points * $default, '0')" />
					</xsl:when>
					<xsl:when test="ends-with($width, 'px')">
						<xsl:variable name="pixels" as="xs:string" select="substring($width, 1, string-length($width) - 2)" />
						<xsl:variable name="pixels" as="xs:double" select="number($pixels)" />
						<xsl:value-of select="format-number($pixels * $default * 4 div 3, '0')" />
					</xsl:when>
					<xsl:when test="$debug">
						<xsl:message terminate="yes">
							<xsl:text>width: </xsl:text>
							<xsl:value-of select="$width/name()" />
							<xsl:text> = </xsl:text>
							<xsl:value-of select="$width" />
						</xsl:message>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$default" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="w:space">
				<xsl:text>0</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="w:color">
				<xsl:choose>
					<xsl:when test="$color = 'black'">
						<xsl:text>000000</xsl:text>
					</xsl:when>
					<xsl:when test="empty($color)">
						<xsl:text>000000</xsl:text>
					</xsl:when>
					<xsl:when test="matches($color, '#[0-9a-f]{6}')">	<!-- nisr/2016/4 -->
						<xsl:value-of select="substring($color, 2)" />
					</xsl:when>
					<xsl:when test="$debug">
						<xsl:message terminate="yes">
							<xsl:text>color: </xsl:text>
							<xsl:value-of select="$color/name()" />
							<xsl:text> = </xsl:text>
							<xsl:value-of select="$color" />
						</xsl:message>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>000000</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="cell-borders">
	<w:tcBorders>
		<xsl:call-template name="cell-border">
			<xsl:with-param name="name" select="'top'" />
			<xsl:with-param name="style" select="@fo:border-top-style" />
			<xsl:with-param name="width" select="@fo:border-top-width" />
			<xsl:with-param name="color" select="@fo:border-top-color" />
		</xsl:call-template>
		<xsl:call-template name="cell-border">
			<xsl:with-param name="name" select="'left'" />
			<xsl:with-param name="style" select="@fo:border-left-style" />
			<xsl:with-param name="width" select="@fo:border-left-width" />
			<xsl:with-param name="color" select="@fo:border-left-color" />
		</xsl:call-template>
		<xsl:call-template name="cell-border">
			<xsl:with-param name="name" select="'bottom'" />
			<xsl:with-param name="style" select="@fo:border-bottom-style" />
			<xsl:with-param name="width" select="@fo:border-bottom-width" />
			<xsl:with-param name="color" select="@fo:border-bottom-color" />
		</xsl:call-template>
		<xsl:call-template name="cell-border">
			<xsl:with-param name="name" select="'right'" />
			<xsl:with-param name="style" select="@fo:border-right-style" />
			<xsl:with-param name="width" select="@fo:border-right-width" />
			<xsl:with-param name="color" select="@fo:border-right-color" />
		</xsl:call-template>
	</w:tcBorders>
</xsl:template>

<xsl:template match="html:td">
	<xsl:call-template name="add-vertically-merged-cells" />
	<!-- <xsl:variable name="colspan" as="xs:integer" select="if (exists(@colspan)) then number(@colspan) else 1" /> -->
	<w:tc>
		<w:tcPr>
			<xsl:if test="exists(@colspan) and number(@colspan) gt 1">
				<w:gridSpan w:val="{ @colspan }" />
			</xsl:if>
			<xsl:if test="exists(@rowspan) and number(@rowspan) gt 1">
				<w:vMerge w:val="restart"/>
			</xsl:if>
			<xsl:call-template name="cell-borders" />
		</w:tcPr>
		<xsl:choose>
			<xsl:when test="every $child in * satisfies local:is-inline($child)">
				<xsl:call-template name="p">
					<xsl:with-param name="style" select="'TableCell'" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</w:tc>
</xsl:template>

<xsl:template match="html:th/Para | html:td/Para | html:td/P">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="html:th/Para/Text | html:td/Para/Text | html:td/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="html:td/Para/BlockText/Text | html:td/Para/BlockText/Para/Text | html:td/P/BlockText/Text | html:td/P/BlockText/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
		<xsl:with-param name="para-formatting" as="element(w:ind)">
			<w:ind w:left="{ $indent-width }" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="html:td/P/BlockText/Para/BlockText/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
		<xsl:with-param name="para-formatting" as="element(w:ind)">
			<w:ind w:left="{ 2 * $indent-width }" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="html:td/text()[exists(../*[not(local:is-inline(.))])]">	<!-- bad markup in nisr/2001/41/made -->
	<w:p>
		<xsl:next-match />
	</w:p>
</xsl:template>

<xsl:template match="html:td[exists(*[not(local:is-inline(.))])]/*[local:is-inline(.)]" priority="1">	<!-- eudn/2015/241/adopted -->
	<w:p>
		<xsl:next-match />
	</w:p>
</xsl:template>


<!-- table (foot)notes -->

<xsl:template match="html:tr[every $n in html:td/node() satisfies $n/self::Footnote]" />

<xsl:template match="html:td[every $n in node() satisfies $n/self::Footnote]" />

<xsl:template match="html:td/Footnote" />

<xsl:template name="table-notes">
	<xsl:variable name="table-notes" as="element(Footnote)*" select="descendant::Footnote" />
	<xsl:if test="exists($table-notes)">
		<xsl:apply-templates select="$table-notes" mode="force" />
	</xsl:if>
</xsl:template>

<xsl:template match="html:td/Footnote" mode="force">
	<xsl:apply-templates />
</xsl:template>


<!-- for errors in CLML -->

<xsl:template match="html:Abbreviation">	<!-- anaw/2014/4/enacted -->
	<xsl:apply-templates />
</xsl:template>

</xsl:transform>
