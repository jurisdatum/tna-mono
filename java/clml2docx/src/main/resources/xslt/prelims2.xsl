<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	exclude-result-prefixes="xs">

<xsl:template match="SecondaryPrelims">
	<xsl:apply-templates select="Correction | Draft" />
	<xsl:call-template name="banner" />
	<xsl:apply-templates select="* except (Correction, Draft)" />
</xsl:template>

<xsl:template match="Correction | Correction/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Correction/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'Correction'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Draft | Draft/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Draft/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'Draft'" />
	</xsl:call-template>
</xsl:template>

<xsl:template name="banner">
	<w:p>
		<w:pPr>
			<w:pStyle w:val="Banner" />
		</w:pPr>
		<w:r>
			<w:t>
				<xsl:attribute name="xml:space">preserve</xsl:attribute>
				<xsl:choose>
					<xsl:when test="$document-main-type = ('UnitedKingdomStatutoryInstrument','NorthernIrelandOrderInCouncil')">
						<xsl:text>Statutory Instruments</xsl:text>
					</xsl:when>
					<xsl:when test="$document-main-type = 'ScottishStatutoryInstrument'">
						<xsl:text>Scottish Statutory Instruments</xsl:text>
					</xsl:when>
					<xsl:when test="$document-main-type = 'WelshStatutoryInstrument'">
						<xsl:text>Welsh Statutory Instruments</xsl:text>
					</xsl:when>
					<xsl:when test="$document-main-type = 'NorthernIrelandStatutoryRule'">
						<xsl:text>Statutory Rules of Northern Ireland</xsl:text>
					</xsl:when>
					<xsl:when test="$document-main-type = 'UnitedKingdomChurchInstrument'">
						<xsl:text>Church Instruments</xsl:text>
					</xsl:when>
					<xsl:when test="$document-main-type = 'UnitedKingdomMinisterialOrder'">
						<xsl:text>Ministerial Order</xsl:text>
					</xsl:when>
					<xsl:when test="$document-main-type = 'UnitedKingdomMinisterialDirection'">
						<xsl:text>Ministerial Directions</xsl:text>
					</xsl:when>
					<xsl:when test="$document-main-type = 'UnitedKingdomStatutoryRuleOrOrder'">
						<xsl:text>Statutory Rules and Orders</xsl:text>
					</xsl:when>
					<xsl:when test="$document-main-type = 'NorthernIrelandStatutoryRuleOrOrder'">
						<!-- ???? -->
					</xsl:when>
					<xsl:when test="$debug">
						<xsl:message terminate="yes" />
					</xsl:when>
				</xsl:choose>
			</w:t>
		</w:r>
	</w:p>
</xsl:template>

<xsl:template match="SecondaryPrelims/Number">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'DocumentNumber'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="SubjectInformation | Subject">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Subject/Title">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'Subject'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="Subject/Subtitle">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'SubSubject'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="SecondaryPrelims/Title">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'DocumentTitle'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="SecondaryPrelims/Approved">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'Approved'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="LaidDraft">
	<xsl:call-template name="p" />
</xsl:template>

<xsl:template match="LaidDraft/*">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="SiftedDate | MadeDate | LaidDate | ComingIntoForce">
	<w:p>
		<w:pPr>
			<w:pStyle w:val="Date2" />
		</w:pPr>
		<xsl:apply-templates select="Text" />
		<w:r>
			<w:tab/>
		</w:r>
		<xsl:apply-templates select="DateText" />
	</w:p>
</xsl:template>

<xsl:template match="SiftedDate/* | MadeDate/* | LaidDate/* | ComingIntoForce/*">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="SecondaryPreamble">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="SecondaryPreamble/IntroductoryText">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="SecondaryPreamble/IntroductoryText/P">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="SecondaryPreamble/IntroductoryText/P/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="SecondaryPreamble/RoyalPresence | SecondaryPreamble/RoyalPresence/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="SecondaryPreamble/RoyalPresence/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="SecondaryPreamble/EnactingText | SecondaryPreamble/EnactingText/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="SecondaryPreamble/EnactingText/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="()" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="SecondaryPreamble/EnactingText/Para/BlockText/Para/Text">
	<xsl:call-template name="block-text">
		<xsl:with-param name="style" select="'Normal'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="SecondaryPreamble/Resolution | SecondaryPreamble/Resolution/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="SecondaryPreamble/Resolution/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'Resolution'" />
	</xsl:call-template>
</xsl:template>

</xsl:transform>
