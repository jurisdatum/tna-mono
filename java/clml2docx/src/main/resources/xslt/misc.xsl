<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	exclude-result-prefixes="xs">

<xsl:template match="DecoratedGroup">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="DecoratedGroup/GroupItem">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="DecoratedGroup/GroupItemRef">
	<xsl:apply-templates />
</xsl:template>

</xsl:transform>
