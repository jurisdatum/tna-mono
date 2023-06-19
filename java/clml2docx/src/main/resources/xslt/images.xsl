<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:local="local"
	xmlns:clml2docx="https://www.legislation.gov.uk/namespaces/clml2docx"
	exclude-result-prefixes="xs clml2docx local">

<xsl:template match="Figure">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Figure/Number | Figure/Title">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:sequence select="'FigureHeading'" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Figure/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Figure/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style">
			<xsl:sequence select="'Normal'" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="Figure/Image">
	<w:p>
		<w:pPr>
			<w:pStyle w:val="Figure" />
		</w:pPr>
		<xsl:next-match />
	</w:p>
</xsl:template>

<xsl:variable name="resource-refs" as="element()*" select="//*[exists(@ResourceRef)]" />

<xsl:key name="version-refs" match="*[exists(@AltVersionRefs)]" use="tokenize(normalize-space(@AltVersionRefs), ' ')" />

<xsl:function name="local:make-resource-key" as="xs:string">
	<xsl:param name="resource-ref" as="attribute(ResourceRef)" />
	<xsl:param name="version-ref" as="element()?" />	<!-- having an @AltVersionRefs pointing to the version that contains the ResourceRef -->
	<xsl:choose>
		<xsl:when test="exists($version-ref)">
			<xsl:sequence select="concat(generate-id($version-ref), '/', generate-id($resource-ref))" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="generate-id($resource-ref)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:variable name="resource-keys" as="xs:string*">
	<xsl:for-each select="//*[exists(@ResourceRef)]">
		<xsl:variable name="resource-ref" as="attribute(ResourceRef)" select="@ResourceRef" />
		<xsl:variable name="version" as="element(Version)?" select="ancestor::Version" />
		<xsl:choose>
			<xsl:when test="exists($version)">
				<xsl:for-each select="key('version-refs', $version/@id)">
					<xsl:sequence select="local:make-resource-key($resource-ref, .)" />
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="local:make-resource-key($resource-ref, ())" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:variable>

<xsl:function name="local:get-index-of-drawing-element" as="xs:integer">
	<xsl:param name="resource-ref" as="element()" />	<!-- has @ResourceRef -->
	<xsl:param name="version-ref" as="element()?" />	<!-- has @AltVersionRefs -->
	<xsl:variable name="resource-key" as="xs:string" select="local:make-resource-key($resource-ref/@ResourceRef, $version-ref)" />
	<xsl:sequence select="index-of($resource-keys, $resource-key)" />
</xsl:function>

<xsl:variable name="resources" as="element(Resource)*" select="/Legislation/Resources/Resource" />

<xsl:variable name="external-uris" as="attribute(URI)*" select="$resources/ExternalVersion/@URI" />

<xsl:function name="local:make-image-id" as="xs:string">
	<xsl:param name="index" as="xs:integer" />
	<xsl:sequence select="concat('image', $index)" />
</xsl:function>

<xsl:function name="local:make-image-filename" as="xs:string?">
	<xsl:param name="uri" as="attribute(URI)" />
	<xsl:variable name="content-type" as="xs:string?" select="clml2docx:get-image-type($uri, $cache)" />
	<xsl:choose>
		<xsl:when test="empty($content-type)">
			<xsl:message terminate="no">
				<xsl:text>no content type </xsl:text>
				<xsl:sequence select="$uri" />
			</xsl:message>
		</xsl:when>
		<xsl:when test="$content-type = 'image/gif'">
			<xsl:sequence select="concat(tokenize($uri, '/')[last()], '.gif')" />
		</xsl:when>
		<xsl:when test="$content-type = ('image/jpeg','image/jpg')">
			<xsl:sequence select="concat(tokenize($uri, '/')[last()], '.jpg')" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:message terminate="{ if ($debug) then 'yes' else 'no' }">
				<xsl:text>unrecognized content type </xsl:text>
				<xsl:sequence select="$content-type" />
			</xsl:message>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:key name="resource" match="Resource" use="@id" />

<xsl:function name="local:quantity-to-emu" as="xs:integer?">
	<xsl:param name="quantity" as="xs:string?" />
	<xsl:choose>
		<xsl:when test="$quantity castable as xs:integer">
			<xsl:sequence select="xs:integer($quantity) * 9525" />	<!-- 914400 / 72 * 4 / 3 -->
		</xsl:when>
		<xsl:when test="$quantity castable as xs:decimal">
			<xsl:sequence select="xs:integer(round(number($quantity) * 9525))" />
		</xsl:when>
		<xsl:when test="ends-with($quantity, 'pt')">
			<xsl:sequence select="xs:integer(round(number(substring-before($quantity,'pt')) * 12700))" />	<!-- 914400 / 72 -->
		</xsl:when>
		<xsl:when test="ends-with($quantity, 'em')">
			<xsl:sequence select="xs:integer(round(number(substring-before($quantity,'em')) * 12 * 12700))" />	<!-- assumes 12 points -->
		</xsl:when>
		<xsl:when test="ends-with($quantity, 'px')">	<!-- uksi/2015/620/2015-10-01 -->
			<xsl:sequence select="xs:integer(round(number(substring-before($quantity,'px')) * 9525))" />	<!-- 914400 / 96 -->
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:template match="Version/Image">
	<xsl:param name="version-ref" as="element()?" select="()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$version-ref/self::Formula">
			<w:p>
				<w:pPr>
					<w:pStyle w:val="Formula" />
					<xsl:call-template name="paragraph-formatting-for-indentation">
						<xsl:with-param name="base-style-id" select="'Formula'" />
					</xsl:call-template>
				</w:pPr>
				<xsl:next-match />
			</w:p>
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="Image[empty(key('resource', @ResourceRef))]" priority="1">	<!-- uksi/2001/4022/2013-04-29, uksi/2003/1572/2004-10-18 -->
	<xsl:message terminate="no">
		<xsl:text>no resource for ref </xsl:text>
		<xsl:value-of select="@ResourceRef" />
	</xsl:message>
</xsl:template>

<xsl:template match="Image">
	<xsl:param name="version-ref" as="element()?" select="()" tunnel="yes" />
	<xsl:try>
		<xsl:variable name="index-of-drawing-element" as="xs:integer" select="local:get-index-of-drawing-element(., $version-ref)" />
		<xsl:variable name="ref" as="xs:string" select="@ResourceRef" />
		<xsl:variable name="resource" as="element(Resource)" select="key('resource', $ref)" />
		<xsl:variable name="uri" as="attribute(URI)" select="$resource/ExternalVersion/@URI" />
		<xsl:variable name="index-of-media-component" as="xs:integer" select="local:get-first-index-of-node($uri, $external-uris)" />
		<xsl:variable name="filename" as="xs:string?" select="local:make-image-filename($uri)" />
		<!-- $filename is empty if image file can't be read -->
		<xsl:if test="exists($filename)">
			<xsl:variable name="width" as="xs:integer">
				<xsl:choose>
					<xsl:when test="empty(@Width) or @Width = ('auto','')">
						<xsl:sequence select="clml2docx:get-image-width(string($uri), $cache) * 9525" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="local:quantity-to-emu(@Width)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="height" as="xs:integer">
				<xsl:choose>
					<xsl:when test="empty(@Height) or @Height = ('auto','')">
						<xsl:sequence select="clml2docx:get-image-height(string($uri), $cache) * 9525" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="local:quantity-to-emu(@Height)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:call-template name="image">
				<xsl:with-param name="index-of-drawing-element" select="$index-of-drawing-element" />
				<xsl:with-param name="index-of-media-component" select="$index-of-media-component" />
				<xsl:with-param name="filename" select="$filename" />
				<xsl:with-param name="width" select="$width" />
				<xsl:with-param name="height" select="$height" />
				<xsl:with-param name="alt-text" as="xs:string?" select="@Description" />
			</xsl:call-template>
		</xsl:if>
		<xsl:catch xmlns:err="http://www.w3.org/2005/xqt-errors">
			<xsl:message>
				<xsl:sequence select="path(.)" />
			</xsl:message>
	        <xsl:message terminate="{ if ($debug) then 'yes' else 'no' }">
	        	<xsl:text>Error: </xsl:text>
	        	<xsl:value-of select="$err:code"/>
            	<xsl:text> Reason: </xsl:text>
            	<xsl:value-of select="$err:description"/>
	        </xsl:message>
	    </xsl:catch>
	</xsl:try>
</xsl:template>

<xsl:template name="image">
	<xsl:param name="index-of-drawing-element" as="xs:integer" />
	<xsl:param name="index-of-media-component" as="xs:integer" />
	<xsl:param name="filename" as="xs:string" />
	<xsl:param name="width" as="xs:integer" />
	<xsl:param name="height" as="xs:integer" />
	<xsl:param name="alt-text" as="xs:string?" select="()" />
	<xsl:variable name="image-id" select="local:make-image-id($index-of-media-component)" />
	<w:r>
        <w:drawing>
            <wp:inline xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" distT="0" distB="0" distL="0" distR="0">
                <wp:extent cx="{ $width }" cy="{ $height }"/> <!-- 1828673, 1578734 -->
                <wp:effectExtent l="0" t="0" r="0" b="0"/>
                <wp:docPr id="{ 10000 + $index-of-drawing-element }" name="{ $filename }" descr="{ if (exists($alt-text)) then $alt-text else $filename }" />
                <wp:cNvGraphicFramePr/>
                <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
                    <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                        <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
                            <pic:nvPicPr>
                                <pic:cNvPr id="{ 20000 + $index-of-drawing-element }" name="{ $filename }" descr="{ $filename }"/>
                                <pic:cNvPicPr>
                                    <a:picLocks noChangeAspect="1"/>
                                </pic:cNvPicPr>
                            </pic:nvPicPr>
                            <pic:blipFill>
                                <a:blip r:embed="{ $image-id }" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
                                    <a:extLst/>
                                </a:blip>
                                <a:srcRect l="0" t="0" r="0" b="0"/>
                                <a:stretch>
                                    <a:fillRect/>
                                </a:stretch>
                            </pic:blipFill>
                            <pic:spPr>
                                <a:xfrm>
                                    <a:off x="0" y="0"/>
                                    <a:ext cx="{ $width }" cy="{ $height }"/> <!-- 1828673, 1578734 -->
                                </a:xfrm>
                                <a:prstGeom prst="rect">
                                    <a:avLst/>
                                </a:prstGeom>
                                <a:ln w="12700" cap="flat">
                                    <a:noFill/>
                                    <a:miter lim="400000"/>
                                </a:ln>
                                <a:effectLst/>
                            </pic:spPr>
                        </pic:pic>
                    </a:graphicData>
                </a:graphic>
            </wp:inline>
        </w:drawing>
	</w:r>
</xsl:template>

</xsl:transform>
