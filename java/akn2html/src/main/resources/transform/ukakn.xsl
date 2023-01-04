<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	exclude-result-prefixes="xs uk ukl ukm">

<xsl:variable name="doc-short-type" as="xs:string" select="/akomaNtoso/*/@name" />

<xsl:function name="uk:doc-category-from-short-type" as="xs:string?">
	<xsl:param name="short-type" as="xs:string" />
	<xsl:variable name="primary-short-types" as="xs:string+" select="( 'ukpga', 'ukla', 'asp', 'anaw', 'asc', 'mwa', 'ukcm', 'nia', 'aosp', 'aep', 'aip', 'apgb', 'mnia', 'apni' )" />
	<xsl:variable name="secondary-short-types" as="xs:string+" select="( 'uksi', 'wsi', 'ssi', 'nisi', 'nisr', 'ukci', 'ukmd', 'ukmo', 'uksro', 'nisro', 'ukdpb', 'ukdsi', 'sdsi', 'nidsr' )" />
	<xsl:variable name="eu-short-types" as="xs:string+" select="( 'eur', 'eudn', 'eudr', 'eut' )" />
	<xsl:choose>
		<xsl:when test="$short-type = $primary-short-types">
			<xsl:sequence>primary</xsl:sequence>
		</xsl:when>
		<xsl:when test="$short-type = $secondary-short-types">
			<xsl:sequence>secondary</xsl:sequence>
		</xsl:when>
		<xsl:when test="$short-type = $eu-short-types">
			<xsl:sequence>euretained</xsl:sequence>
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:variable name="doc-category" as="xs:string?" select="uk:doc-category-from-short-type" />

<xsl:function name="uk:is-big-level" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:param name="category" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$category = 'primary'">
			<xsl:sequence select="$e/self::hcontainer[@name='groupOfParts'] or $e/self::part or $e/self::chapter or $e/self::hcontainer[@name='crossheading'] or
				$e/self::hcontainer[@name='subheading'] or $e/self::hcontainer[@name='P1group'] or $e/self::hcontainer[@name='schedule']" />
		</xsl:when>
		<xsl:when test="$category = 'secondary'">
			<xsl:sequence select="$e/self::hcontainer[@name='groupOfParts'] or $e/self::part or $e/self::chapter or $e/self::section or $e/self::subsection or
				$e/self::hcontainer[@name='crossheading'] or $e/self::hcontainer[@name='subheading'] or $e/self::hcontainer[@name='P1group'] or $e/self::hcontainer[@name='schedule']" />
		</xsl:when>
		<xsl:otherwise>	<!-- euretained -->
			<xsl:sequence select="local-name($e) = ('title', 'part', 'chapter', 'section', 'subsection') or $e/self::hcontainer/@name = 'schedule'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
<xsl:function name="uk:is-big-level" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:sequence select="uk:is-big-level($e, $doc-category)" />
</xsl:function>

<xsl:function name="uk:is-p1" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:param name="category" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$category = 'primary'">
			<xsl:sequence select="$e/self::section or $e/self::paragraph/ancestor::hcontainer[@name='schedule']" />
		</xsl:when>
		<xsl:when test="$category = 'secondary'">
			<xsl:sequence select="$e/self::article or $e/self::hcontainer[@name='regulation'] or $e/self::rule or
				$e/self::paragraph/ancestor::hcontainer[@name='schedule']" />
		</xsl:when>
		<xsl:otherwise>	<!-- euretained -->
			<xsl:sequence select="exists($e[self::article] | $e[self::paragraph][ancestor::hcontainer[@name='schedule']][not(ancestor::paragraph)])" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
<xsl:function name="uk:is-p1" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:sequence select="uk:is-p1($e, $doc-category)" />
</xsl:function>

<xsl:function name="uk:is-p2" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:param name="category" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$category = 'primary'">
			<xsl:sequence select="$e/self::subsection or $e/self::subparagraph" />
		</xsl:when>
		<xsl:when test="$category = 'secondary'">
			<xsl:sequence select="$e/self::paragraph or $e/self::hcontainer[@name='SIParagraph']" />
		</xsl:when>
		<xsl:otherwise>	<!-- euretained -->
			<xsl:sequence select="$e/self::paragraph" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
<xsl:function name="uk:is-p2" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:sequence select="uk:is-p2($e, $doc-category)" />
</xsl:function>

<xsl:function name="uk:is-p3" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:param name="category" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$category = 'primary'">
			<xsl:sequence select="$e/self::subsection or $e/self::subparagraph or $e/@class=('para1','para2','para3','para4')" />
		</xsl:when>
		<xsl:when test="$category = 'secondary'">
			<xsl:sequence select="$e/self::level or $e/self::subparagraph or $e/@class=('para1','para2','para3','para4')" />
		</xsl:when>
		<xsl:otherwise>	<!-- euretained -->
			<xsl:sequence select="$e/self::level" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
<xsl:function name="uk:is-p3" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:sequence select="uk:is-p3($e, $doc-category)" />
</xsl:function>

</xsl:transform>
