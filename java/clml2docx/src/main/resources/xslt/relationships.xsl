<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="local"
	exclude-result-prefixes="xs local">

<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" />

<xsl:function name="local:resource-ref-is-in-footnote" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:variable name="version" as="element(Version)?" select="$e/ancestor::Version" />
	<xsl:choose>
		<xsl:when test="exists($version)">
		   	<xsl:variable name="version-id" as="xs:string" select="string($version/@id)" />
		   	<xsl:variable name="refs" as="element()*" select="root($e)/descendant::*[tokenize(@AltVersionRefs)=$version-id]" />
		   	<xsl:sequence select="exists($refs[local:resource-ref-is-in-footnote(.)])" />
		</xsl:when>
		<xsl:otherwise>
		   	<xsl:sequence select="exists($e/ancestor::Footnotes)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:resource-is-referenced-in-footnote" as="xs:boolean">
	<xsl:param name="resource" as="element(Resource)" />
   	<xsl:variable name="resource-id" as="xs:string" select="string($resource/@id)" />
   	<xsl:variable name="refs" as="element()*" select="root($resource)/descendant::*[@ResourceRef=$resource-id]" />
   	<xsl:sequence select="exists($refs[local:resource-ref-is-in-footnote(.)])" />
</xsl:function>

<xsl:template name="relationships">
	<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
	    <Relationship Id="rId3"
	        Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/webSettings"
	        Target="webSettings.xml"/>
	    <Relationship Id="rId2"
	        Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings"
	        Target="settings.xml"/>
	    <Relationship Id="rId1"
	        Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles"
	        Target="styles.xml"/>
	    <Relationship Id="rId6" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footnotes" Target="footnotes.xml" />
	        
	    <!-- headers -->
	    <xsl:call-template name="header-relationships" />	<!-- in sections.xsl -->
	        
	    <!-- crests -->
	    <xsl:choose>
	    	<xsl:when test="$is-primary">
			    <Relationship Id="image0" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/crest.png"/>
	    	</xsl:when>
	    </xsl:choose>
	    <!-- resources -->
	    <xsl:for-each select="/Legislation/Resources/Resource/ExternalVersion">
	    	<xsl:if test="not(local:resource-is-referenced-in-footnote(..))">
				<xsl:variable name="index" as="xs:integer" select="position()" />
				<xsl:variable name="filename" as="xs:string?" select="local:make-image-filename(@URI)" />	<!-- empty if URI does not resolve -->
				<xsl:if test="exists($filename)">
				    <Relationship Id="{ local:make-image-id($index) }" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/{ $filename }"/>
				</xsl:if>
	    	</xsl:if>
	    </xsl:for-each>
		<!-- hyperlinks -->
		<xsl:for-each select="//Citation[empty(ancestor::Footnotes) and empty(ancestor::MarginNotes) and empty(ancestor::Commentary) and exists(@URI)]">
			<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="{ generate-id(.) }" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="{ @URI }" TargetMode="External" />
		</xsl:for-each>
		<xsl:for-each select="//ExternalLink[empty(ancestor::Footnotes) and empty(ancestor::MarginNotes) and empty(ancestor::Commentary) and exists(@URI)]">
			<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="{ generate-id(.) }" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="{ @URI }" TargetMode="External" />
		</xsl:for-each>
		<xsl:for-each select="//CitationSubRef[empty(ancestor::Footnotes) and empty(ancestor::MarginNotes) and empty(ancestor::Commentary) and exists(@URI)]">
			<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="{ generate-id(.) }" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="{ @URI }" TargetMode="External" />
		</xsl:for-each>
	</Relationships>
</xsl:template>

<xsl:template name="footnote-relationships">
	<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
	    <xsl:for-each select="/Legislation/Resources/Resource/ExternalVersion">
	    	<xsl:if test="local:resource-is-referenced-in-footnote(..)">
				<xsl:variable name="index" as="xs:integer" select="position()" />
				<xsl:variable name="filename" as="xs:string?" select="local:make-image-filename(@URI)" />	<!-- empty if URI does not resolve -->
				<xsl:if test="exists($filename)">
				    <Relationship Id="{ local:make-image-id($index) }" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/{ $filename }"/>
				</xsl:if>
	    	</xsl:if>
	    </xsl:for-each>
		<xsl:for-each select="/Legislation/Footnotes//Citation[exists(@URI)]">
			<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="{ generate-id(.) }" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="{ @URI }" TargetMode="External" />
		</xsl:for-each>
		<xsl:for-each select="/Legislation/Footnotes//ExternalLink[exists(@URI)]">
			<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="{ generate-id(.) }" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="{ @URI }" TargetMode="External" />
		</xsl:for-each>
		<xsl:for-each select="/Legislation/Footnotes//CitationSubRef[exists(@URI)]">
			<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="{ generate-id(.) }" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="{ @URI }" TargetMode="External" />
		</xsl:for-each>
		<xsl:for-each select="/Legislation/MarginNotes//Citation[exists(@URI)]">
			<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="{ generate-id(.) }" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="{ @URI }" TargetMode="External" />
		</xsl:for-each>
		<xsl:for-each select="/Legislation/MarginNotes//ExternalLink[exists(@URI)]">
			<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="{ generate-id(.) }" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="{ @URI }" TargetMode="External" />
		</xsl:for-each>
		<xsl:for-each select="/Legislation/MarginNotes//CitationSubRef[exists(@URI)]">
			<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="{ generate-id(.) }" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="{ @URI }" TargetMode="External" />
		</xsl:for-each>
		<xsl:for-each select="/Legislation/Commentaries//Citation[exists(@URI)]">
			<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="{ generate-id(.) }" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="{ @URI }" TargetMode="External" />
		</xsl:for-each>
		<xsl:for-each select="/Legislation/Commentaries//ExternalLink[exists(@URI)]">
			<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="{ generate-id(.) }" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="{ @URI }" TargetMode="External" />
		</xsl:for-each>
		<xsl:for-each select="/Legislation/Commentaries//CitationSubRef[exists(@URI)]">
			<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="{ generate-id(.) }" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="{ @URI }" TargetMode="External" />
		</xsl:for-each>
	</Relationships>
</xsl:template>

</xsl:transform>
