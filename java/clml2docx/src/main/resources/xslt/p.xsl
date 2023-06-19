<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	exclude-result-prefixes="xs">

<xsl:template name="p">
	<xsl:param name="style" as="xs:string?" select="local-name(.)" />
	<xsl:param name="para-formatting" as="element()*" select="()" />
	<xsl:param name="add-beginning-runs" as="element(w:r)*" select="()" />
	<xsl:param name="add-ending-runs" as="element(w:r)*" select="()" />
	<xsl:variable name="para-formatting" as="element()*">
		<xsl:sequence select="$para-formatting" />
		<!-- this check means that whenever a template sets indentation, it must do so correctly for amendments too -->
		<xsl:if test="empty($para-formatting/self::w:ind)">
			<xsl:call-template name="paragraph-formatting-for-indentation">
				<xsl:with-param name="base-style-id" select="$style" />
			</xsl:call-template>
		</xsl:if>
	</xsl:variable>
	<w:p>
		<xsl:if test="exists($style) or exists($para-formatting)">
			<w:pPr>
				<xsl:if test="exists($style)">
					<w:pStyle w:val="{ $style }" />
				</xsl:if>
				<!-- <xsl:copy-of select="$para-formatting/self::w:keepNext" /> -->
				<xsl:copy-of select="$para-formatting/self::w:pageBreakBefore" />
				<xsl:copy-of select="$para-formatting/self::w:tabs" />
				<!-- <xsl:copy-of select="$para-formatting/self::w:spacing" /> -->
				<xsl:copy-of select="$para-formatting/self::w:ind" />
				<!-- <xsl:copy-of select="$para-formatting/self::w:jc" /> -->
				<xsl:copy-of select="$para-formatting/self::w:outlineLvl" />
				
				<xsl:if test="$debug">
					<xsl:for-each select="$para-formatting">
						<xsl:choose>
							<!-- <xsl:when test="self::w:keepNext" /> -->
							<xsl:when test="self::w:pageBreakBefore" />
							<xsl:when test="self::w:tabs" />
							<!-- <xsl:when test="self::w:spacing" /> -->
							<xsl:when test="self::w:ind" />
							<!-- <xsl:when test="self::w:jc" /> -->
							<xsl:when test="self::w:outlineLvl" />
							<xsl:otherwise>
								<xsl:message terminate="yes">
									<xsl:sequence select="." />
								</xsl:message>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
			</w:pPr>
		</xsl:if>
		<xsl:copy-of select="$add-beginning-runs" />
       	<xsl:apply-templates />
       	<xsl:call-template name="block-amendment-lead-in" />
		<xsl:copy-of select="$add-ending-runs" />	<!-- this should never contain anything when there is a block amendment lead-in -->
	</w:p>
</xsl:template>

<xsl:template match="text()">
	<xsl:param name="first-text-node-in-pnumber" as="text()?" select="()" tunnel="yes" />
	<xsl:param name="last-text-node-in-pnumber" as="text()?" select="()" tunnel="yes" />
	<xsl:param name="punc-before-first-node-in-pnumber" as="xs:string?" select="()" tunnel="yes" />
	<xsl:param name="punc-after-last-node-in-pnumber" as="xs:string?" select="()" tunnel="yes" />
	<xsl:param name="run-formatting" as="element()*" select="()" tunnel="yes" />
	<xsl:param name="first-text-node-in-extract" as="text()?" select="()" tunnel="yes" />
	<xsl:param name="last-text-node-in-extract" as="text()?" select="()" tunnel="yes" />
	<xsl:param name="append-text" as="element(AppendText)?" select="()" tunnel="yes" />
	<xsl:if test=". is $first-text-node-in-extract">
		<xsl:call-template name="run-for-start-quote" />
	</xsl:if>
	<w:r>
		<xsl:if test="exists($run-formatting)">
			<w:rPr>
				<!-- https://c-rex.net/projects/samples/ooxml/e1/Part4/OOXML_P4_DOCX_rPr_topic_ID0EIB4KB.html#topic_ID0EIB4KB -->
				<xsl:copy-of select="$run-formatting/self::w:rStyle" />
				<xsl:copy-of select="($run-formatting/self::w:b)[last()]" />	<!-- ukpga/2018/3/2018-03-15 has nested <Strong> elements -->
				<xsl:copy-of select="($run-formatting/self::w:i)[last()]" />	<!-- uksi/2020/43/2021-02-22 -->
				<xsl:copy-of select="$run-formatting/self::w:strike" />
				<xsl:copy-of select="$run-formatting/self::w:u" />
				<xsl:copy-of select="$run-formatting/self::w:smallCaps" />
				<xsl:copy-of select="$run-formatting/self::w:spacing" />
				<xsl:copy-of select="($run-formatting/self::w:vertAlign)[last()]" />	<!-- last() needed for eur/2009/641/adopted -->
				<xsl:copy-of select="$run-formatting/self::w:caps" />	<!-- not sure the order is right here -->
			</w:rPr>
			<xsl:if test="$debug">
				<xsl:for-each select="$run-formatting">
					<xsl:choose>
						<xsl:when test="self::w:rStyle" />
						<xsl:when test="self::w:b" />
						<xsl:when test="self::w:i" />
						<xsl:when test="self::w:strike" />
						<xsl:when test="self::w:u" />
						<xsl:when test="self::w:smallCaps" />
						<xsl:when test="self::w:spacing" />
						<xsl:when test="self::w:vertAlign" />
						<xsl:when test="self::w:caps" />
						<xsl:otherwise>
							<xsl:message terminate="yes">
								<xsl:sequence select="." />
							</xsl:message>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
		<xsl:if test="(. is $first-text-node-in-pnumber) and exists($punc-before-first-node-in-pnumber)">
			<w:t>
				<xsl:value-of select="$punc-before-first-node-in-pnumber" />
			</w:t>
		</xsl:if>
		<w:t>
			<xsl:attribute name="xml:space">preserve</xsl:attribute>
			<xsl:if test="matches(., '^\s')">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:value-of select="normalize-space(.)" />
			<xsl:if test="matches(., '\s$')">
				<xsl:text> </xsl:text>
			</xsl:if>
		</w:t>
		<xsl:if test="(. is $last-text-node-in-pnumber) and exists($punc-after-last-node-in-pnumber)">
			<w:t>
				<xsl:value-of select="$punc-after-last-node-in-pnumber" />
			</w:t>
		</xsl:if>
	</w:r>
	<xsl:if test=". is $last-text-node-in-extract">
		<xsl:call-template name="run-for-end-quote" />
		<xsl:apply-templates select="$append-text/node()" />
	</xsl:if>
</xsl:template>

</xsl:transform>
