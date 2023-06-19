<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	exclude-result-prefixes="xs">

<xsl:template match="OrderedList | UnorderedList">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:apply-templates>
		<xsl:with-param name="indent" select="$indent + 1" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="ListItem | ListItem/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="OrderedList/ListItem/Para[empty(preceding-sibling::*)]/Text[empty(preceding-sibling::*)] | OrderedList/ListItem/Text[empty(preceding-sibling::*)] | OrderedList/ListItem/Para[empty(preceding-sibling::*)]/BlockText[empty(preceding-sibling::*)]/Text[empty(preceding-sibling::*)]" priority="1">
	<xsl:param name="indent" as="xs:integer" tunnel="yes" />
	<xsl:variable name="item" as="element(ListItem)" select="ancestor::ListItem[1]" />
	<xsl:variable name="list" as="element(OrderedList)" select="$item/.." />
	<xsl:variable name="type" as="xs:string?" select="$list/@Type" />	<!-- empty in ukpga/2015/7/2018-10-01 -->
	<xsl:variable name="decor" as="xs:string?" select="$list/@Decoration" />
	<w:p>
		<w:pPr>
			<w:pStyle>
				<xsl:attribute name="w:val">
					<xsl:call-template name="ordered-list-item-style-id" />
				</xsl:attribute>
			</w:pStyle>
			<w:ind w:left="{ $indent * 720 }" w:hanging="540" />
		</w:pPr>
		<w:r>
			<w:t>
				<xsl:choose>
					<xsl:when test="exists($item/@NumberOverride) and $decor = 'parens' and starts-with($item/@NumberOverride, '(')" />
					<xsl:when test="exists($item/@NumberOverride) and $decor = 'brackets' and starts-with($item/@NumberOverride, '[')" />
					<xsl:when test="$decor = 'parens'">
						<xsl:text>(</xsl:text>
					</xsl:when>
					<xsl:when test="$decor = 'brackets'">
						<xsl:text>[</xsl:text>
					</xsl:when>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="exists($item/@NumberOverride)">
						<xsl:value-of select="$item/@NumberOverride" />
					</xsl:when>
					<xsl:when test="$type = 'arabic'">
						<xsl:number value="count($item/preceding-sibling::ListItem) + 1" format="1" />
					</xsl:when>
					<xsl:when test="$type = 'roman'">
						<xsl:number value="count($item/preceding-sibling::ListItem) + 1" format="i" />
					</xsl:when>
					<xsl:when test="$type = 'romanupper'">
						<xsl:number value="count($item/preceding-sibling::ListItem) + 1" format="I" />
					</xsl:when>
					<xsl:when test="$type = 'alpha'">
						<xsl:number value="count($item/preceding-sibling::ListItem) + 1" format="a" />
					</xsl:when>
					<xsl:when test="$type = 'alphaupper'">
						<xsl:number value="count($item/preceding-sibling::ListItem) + 1" format="A" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:number value="count($item/preceding-sibling::ListItem) + 1" format="1" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="exists($item/@NumberOverride) and $decor = ('parens','parenRight') and ends-with($item/@NumberOverride, ')')" />
					<xsl:when test="exists($item/@NumberOverride) and $decor = ('brackets','bracketRight') and ends-with($item/@NumberOverride, ']')" />
					<xsl:when test="exists($item/@NumberOverride) and $decor = 'period' and ends-with($item/@NumberOverride, '.')" />
					<xsl:when test="exists($item/@NumberOverride) and $decor = 'colon' and ends-with($item/@NumberOverride, ':')" />
					<xsl:when test="$decor = ('parens','parenRight')">
						<xsl:text>)</xsl:text>
					</xsl:when>
					<xsl:when test="$decor = ('brackets','bracketRight')">
						<xsl:text>]</xsl:text>
					</xsl:when>
					<xsl:when test="$decor = 'period'">
						<xsl:text>.</xsl:text>
					</xsl:when>
					<xsl:when test="$decor = 'colon'">
						<xsl:text>:</xsl:text>
					</xsl:when>
				</xsl:choose>
			</w:t>
		</w:r>
       	<w:r>
			<w:tab/>
		</w:r>
		<xsl:apply-templates />
       	<xsl:call-template name="block-amendment-lead-in" />
	</w:p>
</xsl:template>

<!-- ToDo BlockText is list items is not properly indented -->
<xsl:template match="OrderedList/ListItem/Para/Text | OrderedList/ListItem/Text | OrderedList/ListItem/Para/BlockText/Text | OrderedList/ListItem/Para/BlockText/Para/Text">
	<w:p>
		<w:pPr>
			<w:pStyle>
				<xsl:attribute name="w:val">
					<xsl:call-template name="unnumbered-list-item-style-id" />
				</xsl:attribute>
			</w:pStyle>
		</w:pPr>
		<xsl:apply-templates />
       	<xsl:call-template name="block-amendment-lead-in" />
	</w:p>
</xsl:template>

<xsl:template match="UnorderedList/ListItem/Para/Text | UnorderedList/ListItem/Text | UnorderedList/ListItem/Para/BlockText/Text | UnorderedList/ListItem/Para/BlockText/Para/Text">
	<xsl:param name="indent" as="xs:integer" tunnel="yes" />
	<xsl:variable name="item" as="element(ListItem)" select="ancestor::ListItem[1]" />
	<xsl:variable name="list" as="element(UnorderedList)" select="$item/.." />
	<xsl:variable name="decor" as="xs:string" select="$list/@Decoration" />
	<w:p>
		<w:pPr>
			<w:pStyle>
				<xsl:attribute name="w:val">
					<xsl:choose>
						<xsl:when test="$decor = 'none'">
							<xsl:call-template name="unnumbered-list-item-style-id" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="unordered-list-item-style-id" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</w:pStyle>
			<xsl:choose>
				<xsl:when test="$decor = 'none'">
					<w:ind w:left="{ $indent * 720 }" />
				</xsl:when>
				<xsl:otherwise>
					<w:ind w:left="{ 720 + $indent * 720 }" w:hanging="540" />
				</xsl:otherwise>
			</xsl:choose>
		</w:pPr>
		<xsl:if test="exists($item/@NumberOverride) or $decor = ('bullet','dash','arrow')">
			<w:r>
				<w:t>
					<xsl:choose>
						<xsl:when test="exists($item/@NumberOverride)">
							<xsl:value-of select="$item/@NumberOverride" />
						</xsl:when>
						<xsl:when test="$decor = 'bullet'">
							<xsl:text>•</xsl:text>
						</xsl:when>
						<xsl:when test="$decor = 'dash'">
							<xsl:text>—</xsl:text>
						</xsl:when>
						<xsl:when test="$decor = 'arrow'">
							<xsl:text>→</xsl:text>
						</xsl:when>
					</xsl:choose>
				</w:t>
			</w:r>
	       	<w:r>
				<w:tab/>	<!-- putting this inside xsl:if means @Decoration="none" will be hanging -->
			</w:r>
		</xsl:if>
		<xsl:apply-templates />
		<!-- check for lead-in to BlockAmendment -->
       	<xsl:call-template name="block-amendment-lead-in" />
	</w:p>
</xsl:template>


<!-- key lists -->

<xsl:template match="KeyList">
	<xsl:apply-templates>
		<xsl:with-param name="separator" as="xs:string?" select="@Separator" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="KeyListItem">
	<xsl:param name="separator" as="xs:string?" required="yes" />
	<w:p>
		<w:pPr>
			<xsl:call-template name="paragraph-formatting-for-indentation">
				<xsl:with-param name="base-style-id" select="()" />
			</xsl:call-template>
		</w:pPr>
		<xsl:apply-templates select="Key" />
		<w:r>
			<w:t>
				<xsl:attribute name="xml:space">preserve</xsl:attribute>
				<xsl:text> </xsl:text>
			</w:t>
			<xsl:if test="$separator">
				<w:t>
					<xsl:attribute name="xml:space">preserve</xsl:attribute>
					<xsl:value-of select="$separator" />
				</w:t>
				<w:t>
					<xsl:attribute name="xml:space">preserve</xsl:attribute>
					<xsl:text> </xsl:text>
				</w:t>
			</xsl:if>
		</w:r>
		<xsl:apply-templates select="ListItem" mode="key-list-item-1" />
	</w:p>
	<xsl:apply-templates select="ListItem" mode="key-list-item-2" />
</xsl:template>

<xsl:template match="Key">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="ListItem" mode="key-list-item-1">
	<xsl:choose>
		<xsl:when test="*[1][self::Text]">
			<xsl:apply-templates select="*[1]/node()" />
		</xsl:when>
		<xsl:when test="*[1][self::Para]/*[1][self::Text]">
			<xsl:apply-templates select="*[1]/*[1]/node()" />
		</xsl:when>
		<xsl:otherwise>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="ListItem" mode="key-list-item-2">
	<xsl:choose>
		<xsl:when test="*[1][self::Text]">
			<xsl:apply-templates select="*[position() gt 1]" />
		</xsl:when>
		<xsl:when test="*[1][self::Para]/*[1][self::Text]">
			<xsl:apply-templates select="*[1]/*[position() gt 1]" />
			<xsl:apply-templates select="*[position() gt 1]" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="KeyListItem/ListItem/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>

</xsl:transform>
