<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:local="local"
	xmlns:clml2docx="https://www.legislation.gov.uk/namespaces/clml2docx"
	exclude-result-prefixes="xs local clml2docx">

<xsl:template match="SignedSection">
	<xsl:comment>
		<xsl:value-of select="local-name()" />
	</xsl:comment>
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="SignedSection/P | SignedSection/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="SignedSection/P/CommentaryRef[following-sibling::*[1][self::Text]]">	<!-- nisr/2019/46/2019-05-07 -->
	<xsl:param name="force" as="xs:boolean" select="false()" />
	<xsl:if test="$force">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<xsl:template match="SignedSection/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'SignatoryText'" />
		<xsl:with-param name="add-beginning-runs" as="element(w:r)*">
			<xsl:apply-templates select="preceding-sibling::*[1][self::CommentaryRef]">
				<xsl:with-param name="force" select="true()" />
			</xsl:apply-templates>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="SignedSection/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'SignatoryText'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Signatory">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Signatory/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Signatory/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'SignatoryText'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Signee">
	<xsl:apply-templates />
</xsl:template>

<!-- Signee/Para and Signee/Para/Text handled in euretained.xsl -->

<xsl:template match="PersonName">
	<xsl:call-template name="p" />
</xsl:template>

<xsl:template match="JobTitle">
	<xsl:call-template name="p" />
</xsl:template>

<xsl:template match="Department">
	<xsl:call-template name="p" />
</xsl:template>

<xsl:template match="Address">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="AddressLine">
	<xsl:call-template name="p" />
</xsl:template>

<xsl:template match="DateSigned">
	<xsl:call-template name="p" />
</xsl:template>

<xsl:template match="DateSigned/DateText">
	<xsl:apply-templates />	
</xsl:template>

<xsl:template match="LSseal">
	<xsl:comment>seal</xsl:comment>
	<xsl:choose>
		<xsl:when test="exists(@ResourceRef)">	<!-- not working: uksi/2020/42/made -->
			<w:p>
				<xsl:try>
					<xsl:variable name="index-of-drawing-element" as="xs:integer" select="local:get-index-of-drawing-element(., ())" />
					<xsl:variable name="ref" as="xs:string" select="@ResourceRef" />
					<xsl:variable name="resource" as="element(Resource)" select="key('resource', $ref)" />
					<xsl:variable name="uri" as="attribute(URI)" select="$resource/ExternalVersion/@URI" />
					<xsl:variable name="index-of-media-component" as="xs:integer" select="local:get-first-index-of-node($uri, $external-uris)" />
					<xsl:variable name="filename" as="xs:string" select="local:make-image-filename($uri)" />
					<xsl:variable name="width" as="xs:integer" select="clml2docx:get-image-width(string($uri), $cache) * 9525" />
					<xsl:variable name="height" as="xs:integer" select="clml2docx:get-image-height(string($uri), $cache) * 9525" />
					<xsl:call-template name="image">
						<xsl:with-param name="index-of-drawing-element" select="$index-of-drawing-element" />
						<xsl:with-param name="index-of-media-component" select="$index-of-media-component" />
						<xsl:with-param name="filename" select="$filename" />
						<xsl:with-param name="width" select="$width" />
						<xsl:with-param name="height" select="$height" />
						<xsl:with-param name="alt-text" as="xs:string" select="'seal'" />
					</xsl:call-template>
					<xsl:catch xmlns:err="http://www.w3.org/2005/xqt-errors">
						<xsl:call-template name="text-seal" />
				        <xsl:message terminate="{ if ($debug) then 'yes' else 'no' }">
				        	<xsl:text>Error: </xsl:text>
				        	<xsl:value-of select="$err:code"/>
			            	<xsl:text> Reason: </xsl:text>
			            	<xsl:value-of select="$err:description"/>
				        </xsl:message>
				    </xsl:catch>
				</xsl:try>
			</w:p>
		</xsl:when>
		<xsl:when test="exists(child::node())">	<!-- e.g., nisr/2020/6 -->
			<w:p>
				<xsl:apply-templates />
			</w:p>
		</xsl:when>
		<xsl:otherwise>	<!-- nisr/2006/41 -->
			<w:p>
				<xsl:call-template name="text-seal" />
			</w:p>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="text-seal">
	<w:r>
		<w:t>(</w:t>
	</w:r>
	<w:r>
        <w:rPr>
               <w:sz w:val="{ $font-size - 4 }"/>
        </w:rPr>
		<w:t>L.S.</w:t>
	</w:r>
	<w:r>
		<w:t>)</w:t>
	</w:r>
</xsl:template>

</xsl:transform>
