<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
	xmlns:local="local"
	exclude-result-prefixes="xs r local">

<xsl:variable name="all-internal-ids" as="xs:string*">
	<xsl:sequence select="//*/@id" />
</xsl:variable>

<xsl:function name="local:get-bookmark-id-1" as="xs:integer?">
	<xsl:param name="id" as="xs:string" />
	<xsl:sequence select="index-of($all-internal-ids, $id)[1]" />
</xsl:function>

<xsl:function name="local:get-bookmark-id-2" as="xs:integer?">
	<xsl:param name="e" as="element()" />
	<xsl:variable name="id" as="xs:string?" select="$e/@id" />
	<xsl:if test="exists($id)">
		<xsl:variable name="is-first" as="xs:boolean" select="key('id', $id, root($e))[1] is $e" />
		<xsl:if test="$is-first">
			<xsl:sequence select="index-of($all-internal-ids, $id)[1]" />
		</xsl:if>
	</xsl:if>
</xsl:function>

<xsl:template match="InternalLink">
	<xsl:choose>
		<xsl:when test="exists(@Ref)">
			<w:hyperlink w:anchor="{ @Ref }">
				<xsl:apply-templates />
			</w:hyperlink>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="Citation | ExternalLink">
	<xsl:choose>
		<xsl:when test="exists(@URI)">
			<w:hyperlink r:id="{ generate-id(.) }">
				<xsl:apply-templates>
					<xsl:with-param name="run-formatting" as="element()" tunnel="yes">
						<w:rStyle w:val="Hyperlink" />
					</xsl:with-param>
				</xsl:apply-templates>
			</w:hyperlink>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="CitationSubRef">
	<xsl:choose>
		<xsl:when test="exists(@URI)">
			<w:hyperlink r:id="{ generate-id(.) }">
				<xsl:apply-templates>
					<xsl:with-param name="run-formatting" as="element()+" tunnel="yes">
						<w:rStyle w:val="Hyperlink" />
						<xsl:if test="@Operative = ('true','1')">
							<w:b w:val="1" />
						</xsl:if>
					</xsl:with-param>
				</xsl:apply-templates>
			</w:hyperlink>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:transform>
