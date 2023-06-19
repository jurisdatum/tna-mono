<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:local="local"
	exclude-result-prefixes="xs local">

<xsl:include href="styles-eu.xsl" />


<xsl:variable name="is-primary" as="xs:boolean" select="$document-main-type = ('UnitedKingdomPublicGeneralAct','UnitedKingdomLocalAct','ScottishAct','WelshParliamentAct','WelshNationalAssemblyAct','WelshAssemblyMeasure','UnitedKingdomChurchMeasure','NorthernIrelandAct','ScottishOldAct','EnglandAct','IrelandAct','GreatBritainAct','NorthernIrelandAssemblyMeasure','NorthernIrelandParliamentAct')" />

<xsl:variable name="is-secondary" as="xs:boolean" select="$document-main-type = ('UnitedKingdomStatutoryInstrument','WelshStatutoryInstrument','ScottishStatutoryInstrument','NorthernIrelandOrderInCouncil','NorthernIrelandStatutoryRule','UnitedKingdomChurchInstrument','UnitedKingdomMinisterialDirection','UnitedKingdomMinisterialOrder','UnitedKingdomStatutoryRuleOrOrder','NorthernIrelandStatutoryRuleOrOrder')" />

<xsl:variable name="is-eu" as="xs:boolean" select="$document-main-type = ('EuropeanUnionRegulation','EuropeanUnionDecision','EuropeanUnionDirective')" />

<xsl:variable name="font" as="xs:string">
	<xsl:choose>
		<xsl:when test="$document-main-type = 'UnitedKingdomPublicGeneralAct'">
			<xsl:sequence select="'Book Antiqua'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'Times New Roman'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="font-size" as="xs:integer">
	<xsl:choose>
		<xsl:when test="$document-main-type = 'UnitedKingdomPublicGeneralAct'">
			<xsl:sequence select="22" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="24" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="space-before" as="xs:integer" select="240" />

<xsl:variable name="line-spacing" as="xs:integer" select="240" />


<xsl:variable name="p3-p4-compact-indent" as="xs:integer" select="$indent-width * 5 div 4" />


<xsl:variable name="style-definitions" as="element(w:style)+">
	<w:style w:type="character" w:default="1" w:styleId="DefaultParagraphFont">
		<w:name w:val="Default Paragraph Font"/>
		<w:uiPriority w:val="1"/>
		<w:semiHidden/>
		<w:unhideWhenUsed/>
	</w:style>

	<w:style w:type="numbering" w:default="1" w:styleId="NoList">
		<w:name w:val="No List"/>
		<w:uiPriority w:val="99"/>
		<w:semiHidden/>
		<w:unhideWhenUsed/>
	</w:style>

	<w:style w:type="paragraph" w:default="1" w:styleId="Normal">
		<w:name w:val="Normal"/>
		<w:pPr>
			<w:spacing w:before="{ $space-before }" w:beforeAutospacing="0" w:after="0" w:afterAutospacing="0" w:line="240" w:lineRule="auto" />
			<w:jc w:val="both" />
		</w:pPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="Text">
		<w:name w:val="Text"/>
		<w:basedOn w:val="Normal"/>
	</w:style>
	
	<!-- prelims 1 -->
	<w:style w:type="paragraph" w:styleId="DocumentTitle">
		<w:name w:val="Document Title"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<xsl:choose>
				<xsl:when test="$is-primary">
					<w:sz w:val="{ $font-size * 2 }" />
				</xsl:when>
				<xsl:when test="$is-secondary">
					<w:sz w:val="{ $font-size * 1.5 }" />
				</xsl:when>
			</xsl:choose>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="DocumentNumber">
		<w:name w:val="Document Number"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:b w:val="true" />
			<xsl:if test="$document-main-type = ('UnitedKingdomPublicGeneralAct','UnitedKingdomLocalAct','WelshNationalAssemblyAct','WelshParliamentAct','NorthernIrelandAct')">
				<w:caps w:val="true" />
			</xsl:if>
			<xsl:if test="$document-main-type = ('UnitedKingdomChurchMeasure')">
				<w:smallCaps w:val="true"/>
			</xsl:if>
			<xsl:if test="$is-secondary">
				<w:sz w:val="{ $font-size * 1.5 }"/>
			</xsl:if>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="LongTitle">
		<w:name w:val="LongTitle"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:tabs>
				<w:tab w:val="right" w:pos="{ $content-width }"/>
			</w:tabs>
		</w:pPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="DateOfEnactment">	<!-- no longer used? -->
		<w:name w:val="Date of Enactment"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:spacing w:before="0" />
			<w:jc w:val="right" />
		</w:pPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="ASPDateOfEnactment">
		<w:name w:val="Scotish Date of Enactment"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:rPr>
			<w:b w:val="true" />
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="PreambleIntro">
		<w:name w:val="Preamble Intro"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
	</w:style>
	<w:style w:type="paragraph" w:styleId="EnactingText">
		<w:name w:val="Enacting Text"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
	</w:style>

	<!-- prelims 2 -->
	<w:style w:type="paragraph" w:styleId="Correction">
		<w:name w:val="Correction"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:i w:val="1"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="Draft">
		<w:name w:val="Draft"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:jc w:val="both" />
		</w:pPr>
		<w:rPr>
			<w:i w:val="1"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="Banner">
		<w:name w:val="Banner"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:pBdr>
				<w:top w:val="single" w:sz="15" w:space="6" w:color="000000" />
				<w:bottom w:val="single" w:sz="15" w:space="6" w:color="000000" />
			</w:pBdr>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:caps w:val="1"/>
			<w:spacing w:val="60" />
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="Subject">
		<w:name w:val="Subject"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:b w:val="true" />
			<w:caps w:val="1"/>
			<w:sz w:val="{ $font-size * 1.5 }" />
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="SubSubject">
		<w:name w:val="Sub-Subject"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:b w:val="true" />
			<w:caps w:val="1"/>
			<w:sz w:val="{ $font-size + 4 }" />
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="Approved">
		<w:name w:val="Approved"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="LaidDraft">
		<w:name w:val="Laid in Draft"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:ind w:left="{ $indent-width }" w:right="{ $indent-width }" />	<!-- same as below -->
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:i w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="Date2">
		<w:name w:val="Secondary Date"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:tabs>
				<w:tab w:val="right" w:pos="{ $content-width - $indent-width }"/>
			</w:tabs>
			<w:ind w:left="{ $indent-width }" w:right="{ $indent-width }" />	<!-- same as above -->
		</w:pPr>
		<w:rPr>
			<w:i w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="RoyalPresence">
		<w:name w:val="Roya lPresence"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="Resolution">
		<w:name w:val="Roya Resolution"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<!-- body -->
	<w:style w:type="paragraph" w:styleId="GroupNumber">
		<w:name w:val="Group Number"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="GroupHeading">
		<w:name w:val="Group Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="PartNumber">
		<w:name w:val="Part Number"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<xsl:choose>
				<xsl:when test="$is-secondary">
					<w:spacing w:before="{ $space-before * 2 }" />
				</xsl:when>
			</xsl:choose>
			<w:jc w:val="center" />
			<!-- <w:outlineLvl w:val="0"/> -->
		</w:pPr>
		<w:rPr>
			<xsl:choose>
				<xsl:when test="$is-primary">
					<w:b w:val="true" />
					<w:smallCaps w:val="true"/>
				</xsl:when>
				<xsl:when test="$is-secondary">
					<w:caps w:val="true"/>
					<w:sz w:val="{ $font-size + 4 }"/>
				</xsl:when>
			</xsl:choose>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="PartHeading">
		<w:name w:val="Part Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<xsl:choose>
				<xsl:when test="$is-primary">
					<w:smallCaps w:val="true"/>
				</xsl:when>
				<xsl:when test="$is-secondary">
					<w:sz w:val="{ $font-size + 2 }"/>
				</xsl:when>
			</xsl:choose>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="ChapterNumber">
		<w:name w:val="Chapter Number"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:b w:val="true" />
			<w:smallCaps w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="ChapterHeading">
		<w:name w:val="Chapter Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:smallCaps w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="ChapterText">
		<w:name w:val="Chapter Text"/>
		<w:basedOn w:val="Normal"/>
		<!-- <w:qFormat /> -->	<!-- This element specifies whether this style shall be treated as a primary style when this document is loaded by an application. If this element is set, then this style has been designated as being particularly important for the current document, and this information may be used by an application in any means desired. -->
	</w:style>
	<w:style w:type="paragraph" w:styleId="CrossHeadingNumber"><!-- SI Section? -->
		<w:name w:val="CrossHeading Number"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:i w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="CrossHeading">
		<w:name w:val="CrossHeading"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:i w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="SubHeadingNumber">
		<w:name w:val="SubHeading Number"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:i w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="SubHeading">
		<w:name w:val="SubHeading"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:i w:val="true"/>
		</w:rPr>
	</w:style>
	
	<!-- normal (non-compact) numbered provisions -->

	<!-- left indent of P1 heading, when next to a number -->
	<!-- check to see if this is the same of the P1 left text edge -->
	<xsl:variable name="p1-number-space" as="xs:integer" select="540" />
	
	<xsl:variable name="pnumber-space" as="xs:integer" select="270" />

	<xsl:variable name="p2-text-edge" as="xs:integer" select="720" />
	
	<xsl:variable name="p3-text-edge" as="xs:integer" select="$p2-text-edge + 720" />

	<xsl:variable name="p4-text-edge" as="xs:integer" select="$p3-text-edge + 720" />

	<xsl:variable name="p5-text-edge" as="xs:integer" select="$p4-text-edge + 720" />

	<xsl:variable name="p6-text-edge" as="xs:integer" select="$p5-text-edge + 720" />

	<xsl:variable name="p7-text-edge" as="xs:integer" select="$p5-text-edge + 720" />
	
	<!-- P1s -->
	<w:style w:type="paragraph" w:styleId="UnnumberedSectionHeading">
		<w:name w:val="Section Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
		</w:pPr>
		<w:rPr>
			<w:b w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="NumberedSectionHeading">
		<w:name w:val="Section Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:ind w:left="{ $p1-number-space }" w:hanging="{ $p1-number-space }" />
		</w:pPr>
		<w:rPr>
			<w:b w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="NumberedSection">
		<w:name w:val="Section"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:ind w:left="720" w:hanging="720" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="SectionText">
		<w:name w:val="Section Text"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:ind w:left="900" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	
	
	<!-- P1 + P2 -->
	<w:style w:type="paragraph" w:styleId="SectionAndSubsection">
		<w:name w:val="Section and Subsection"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:tabs>
				<w:tab w:val="left" w:pos="630" />	<!-- 7/16 -->
			</w:tabs>
			<w:ind w:left="1080" w:hanging="1080" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>	  
	
	<!-- P2 -->
	<w:style w:type="paragraph" w:styleId="SubsectionGroupHeading">
		<w:name w:val="Subsection Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:ind w:left="{ $p2-text-edge }" />
		</w:pPr>
		<w:rPr>
			<w:b w:val="true" />
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="SubsectionHeading">
		<w:name w:val="Subsection"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:tabs>
				<w:tab w:val="right" w:pos="{ $p2-text-edge - $pnumber-space }" />
			</w:tabs>
			<w:ind w:left="{ $p2-text-edge }" w:hanging="{ $p2-text-edge }" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="SubsectionText">
		<w:name w:val="Subsection Text"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:ind w:left="{ $p2-text-edge }" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	
	
	<!-- P2 + P3 -->
	<w:style w:type="paragraph" w:styleId="SubsectionP3Heading">
		<w:name w:val="Subsection and P3"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:tabs>
				<w:tab w:val="left" w:pos="{ 1440 - 540 }"/>	<!-- P3 left - P3 hanging -->
			</w:tabs>
			<w:spacing w:before="60" />
			<w:ind w:left="1440" w:hanging="{ (1440 - 720) + 540 }" /><!-- hading = (P3 left - P2 left) + P3 hanging -->
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	
	<!-- P3 -->
	<w:style w:type="paragraph" w:styleId="P3Heading">
		<w:name w:val="P3"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:tabs>
				<w:tab w:val="right" w:pos="{ $p3-text-edge - $pnumber-space }" />
			</w:tabs>
			<w:spacing w:before="60" />
			<w:ind w:left="{ $p3-text-edge }" w:hanging="{ $p3-text-edge }" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="P3Text">
		<w:name w:val="P3 Text"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:spacing w:before="60" />
			<w:ind w:left="1440" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<!-- P2 + P4 -->
	<w:style w:type="paragraph" w:styleId="SubsectionP4Heading">	<!-- untested -->
		<w:name w:val="P2 and P4"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:tabs>
				<w:tab w:val="left" w:pos="{ 2160 - 540 }"/>	<!-- P4 left - P4 hanging -->
			</w:tabs>
			<w:spacing w:before="60" />
			<w:ind w:left="2160" w:hanging="{ (2160 - 1440) + 540 }" /> <!-- left = P4 left --> <!-- hanging = (P4 left - P3 left) + P4 hanging -->
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<!-- P3 + P4 -->
	<w:style w:type="paragraph" w:styleId="P3P4Heading">	<!-- ukla/1994/12/enacted -->
		<w:name w:val="P3 and P4"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:tabs>
				<w:tab w:val="left" w:pos="{ 2160 - 540 }"/>	<!-- P4 left - P4 hanging -->
			</w:tabs>
			<w:spacing w:before="60" />
			<w:ind w:left="2160" w:hanging="{ (2160 - 1440) + 540 }" /> <!-- left = P4 left --> <!-- hading = (P4 left - P3 left) + P4 hanging -->
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="P4Heading">
		<w:name w:val="P4"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:tabs>
				<w:tab w:val="right" w:pos="{ $p4-text-edge - $pnumber-space }" />
			</w:tabs>
			<w:spacing w:before="60" />
			<w:ind w:left="{ $p4-text-edge }" w:hanging="{ $p4-text-edge }" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="P4Text">
		<w:name w:val="P4 Text"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:spacing w:before="60" />
			<w:ind w:left="{ $p4-text-edge }" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<!-- P4 + P5 -->
	<w:style w:type="paragraph" w:styleId="P4P5Heading">	<!-- ukla/1994/12/enacted -->
		<w:name w:val="P4 and P5"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<xsl:variable name="p5-hanging" as="xs:integer" select="540" />
			<w:tabs>
				<w:tab w:val="left" w:pos="{ $p5-text-edge - $p5-hanging }"/>
			</w:tabs>
			<w:spacing w:before="60" />
			<w:ind w:left="{ $p5-text-edge }" w:hanging="{ ( $p5-text-edge - $p4-text-edge ) + $p5-hanging }" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	
	<w:style w:type="paragraph" w:styleId="P5Heading">
		<w:name w:val="P5"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:tabs>
				<w:tab w:val="right" w:pos="{ $p5-text-edge - $pnumber-space }" />
			</w:tabs>
			<w:spacing w:before="60" />
			<w:ind w:left="{ $p5-text-edge }" w:hanging="{ $p5-text-edge }" />
		</w:pPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="P5Text">
		<w:name w:val="P5 Text"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:spacing w:before="60" />
			<w:ind w:left="{ $p5-text-edge }" />
		</w:pPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="P6Heading">
		<w:name w:val="P6"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:tabs>
				<w:tab w:val="right" w:pos="{ $p6-text-edge - $pnumber-space }" />
			</w:tabs>
			<w:spacing w:before="60" />
			<w:ind w:left="{ $p6-text-edge }" w:hanging="{ $p6-text-edge }" />
		</w:pPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="P6Text">
		<w:name w:val="P6 Text"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:spacing w:before="60" />
			<w:ind w:left="{ $p6-text-edge }" />
		</w:pPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="P7Heading">
		<w:name w:val="P7"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:tabs>
				<w:tab w:val="right" w:pos="{ $p7-text-edge - $pnumber-space }" />
			</w:tabs>
			<w:spacing w:before="60" />
			<w:ind w:left="{ $p7-text-edge }" w:hanging="{ $p7-text-edge }" />
		</w:pPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="P7Text">
		<w:name w:val="P7 Text"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:spacing w:before="60" />
			<w:ind w:left="{ $p7-text-edge }" />
		</w:pPr>
	</w:style>

	<!-- compact numbered provisions -->

	<w:style w:type="paragraph" w:styleId="SectionCompact">
		<w:name w:val="Section (compact)"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:spacing w:before="{ $space-before div 2 }" />
			<w:ind w:firstLine="{ $indent-width div 2 }" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="SectionTextCompact">
		<w:name w:val="Section Text (compact)"/>
		<w:basedOn w:val="Normal"/>
	</w:style>

	<w:style w:type="paragraph" w:styleId="SectionAndSubsectionCompact">
		<w:name w:val="Section and Subsection (compact)"/>
		<w:basedOn w:val="SectionCompact"/>
	</w:style>

	<!-- P2 compact -->
	<w:style w:type="paragraph" w:styleId="SubsectionCompact">
		<w:name w:val="Subsection (compact)"/>
		<w:basedOn w:val="SectionCompact"/>
	</w:style>
	<w:style w:type="paragraph" w:styleId="SubsectionTextCompact">
		<w:name w:val="Subsection Text (compact)"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:spacing w:before="{ $space-before div 2 }" />
			<w:ind w:left="0" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="SubsectionP3Compact">	<!-- nisr/2020/187/made -->
		<w:name w:val="Subsection and P3 (compact)"/>
		<w:basedOn w:val="SubsectionCompact"/>
	</w:style>

	<w:style w:type="paragraph" w:styleId="P3Compact">
		<w:name w:val="P3 (compact)"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:spacing w:before="{ $space-before * 3 div 8 }" />
			<w:ind w:left="{ $indent-width * 5 div 4 }" w:hanging="{ $indent-width div 2 }" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="SubsectionP4Compact">	<!-- uksi/2000/2/section/2/2 -->
		<w:name w:val="Subsection and P4 (compact)"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:tabs>	<!-- same as P4 compact -->
				<w:tab w:val="right" w:pos="{ $indent-width * 7 div 4 }"/>
			</w:tabs>
			<w:spacing w:before="60" /> <!-- same as P4 compact -->
			<w:ind w:left="{ $indent-width * 2 }" w:hanging="{ ($indent-width * 2) - ($indent-width div 2) }" />	<!-- left = P4 compact left --> <!-- hanging = P4 compact left - P2 compact firstLine -->
		</w:pPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="P3P4Compact">	<!-- untested -->
		<w:name w:val="P3 and P4 (compact)"/>
		<w:basedOn w:val="P3P4Heading"/>
		<w:qFormat/>
		<w:pPr>
			<w:spacing w:before="{ $space-before * 3 div 8 }" />
			<w:ind w:left="{ $p3-p4-compact-indent }" w:hanging="{ $indent-width div 2 }" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="P4Compact">
		<w:name w:val="P4 (compact)"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:tabs>
				<w:tab w:val="right" w:pos="{ $indent-width * 7 div 4 }"/>
			</w:tabs>
			<w:spacing w:before="60" />
			<w:ind w:left="{ $indent-width * 2 }" w:hanging="{ $indent-width }" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="P4P5Compact">	<!-- untested -->
		<w:name w:val="P4 and P5 (compact)"/>
		<w:basedOn w:val="P4P5Heading"/>
	</w:style>

	<w:style w:type="paragraph" w:styleId="P5Compact">
		<w:name w:val="P5 (compact)"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:spacing w:before="60" />
			<w:ind w:left="{ $indent-width * 11 div 4 }" w:hanging="{ $indent-width * 3 div 4 }" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	
	<w:style w:type="paragraph" w:styleId="P6Compact">
		<w:name w:val="P6 (compact)"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:spacing w:before="60" />
			<w:ind w:left="{ $indent-width * 15 div 4 }" w:hanging="{ $indent-width * 3 div 4 }" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<!-- lists -->
	<w:style w:type="paragraph" w:styleId="ListItem">
		<w:name w:val="List Item"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:spacing w:before="120" />
			<w:ind w:left="1440" w:hanging="540" />	<!-- perhaps 1440 is too much -->
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="UnnumberedListItem">
		<!-- these seem to be hanging sometimes (ukpga/1999/10/section/11/2/b) but not others (e.g., ) -->
		<w:name w:val="Unnumbered List Item"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:spacing w:before="120" />
			<w:ind w:left="720" />
		</w:pPr>
	</w:style>
	
	<!-- tables -->
	<w:style w:type="paragraph" w:styleId="TabularNumber">
		<w:name w:val="Tabular Number"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="TabularHeading">
		<w:name w:val="Tabular Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="TabularSubheading">
		<w:name w:val="Tabular Subheading"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="TableText">
		<w:name w:val="Table Text"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="TableCaption">
		<w:name w:val="Caption"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="table" w:default="1" w:styleId="TableNormal">
		<w:name w:val="Normal Table"/>
		<w:semiHidden/>
		<w:unhideWhenUsed/>
		<w:tblPr>
			<w:tblInd w:w="0" w:type="dxa"/>
			<w:tblBorders>
				<w:insideV w:val="single" w:sz="24" w:space="0" w:color="000000" />
			</w:tblBorders>
			<w:tblCellMar>
				<w:top w:w="0" w:type="dxa"/>
				<w:left w:w="108" w:type="dxa"/>
				<w:bottom w:w="0" w:type="dxa"/>
				<w:right w:w="108" w:type="dxa"/>
			</w:tblCellMar>
		</w:tblPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="TableHeader">
		<w:name w:val="Table Header"/>
		<w:basedOn w:val="TableCell"/>
		<w:rPr>
			<w:i w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="TableHeader2">
		<w:name w:val="Table Header within Body"/>
		<w:basedOn w:val="TableCell"/>
		<w:rPr>
			<w:b w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="TableCell">
		<w:name w:val="Table Cell"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:spacing w:before="0" />
			<w:jc w:val="left" />
		</w:pPr>
	</w:style>
	
	<!-- images -->
	<w:style w:type="paragraph" w:styleId="FigureNumber">
		<w:name w:val="Figure Number"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="FigureHeading">
		<w:name w:val="Figure Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="Figure"> <!-- this is for an image: Figure/Image -->
		<w:name w:val="Figure"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="Formula">
		<w:name w:val="Formula"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	
	<!-- forms -->
	<w:style w:type="paragraph" w:styleId="FormNumber">
		<w:name w:val="Form Number"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="FormHeading">
		<w:name w:val="Form Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="FormReference">
		<w:name w:val="Form Reference"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:jc w:val="right" />
		</w:pPr>
		<w:rPr>
			<w:sz w:val="{ $font-size - 4 }"/>
		</w:rPr>
	</w:style>
	
	<!-- footnotes -->
	<w:style w:type="character" w:styleId="FootnoteReference">	<!-- including the punctuation -->
		<w:name w:val="Footnote Reference"/>
		<w:rPr>
			<xsl:if test="$is-primary">
				<w:vertAlign w:val="superscript"/>
			</xsl:if>
		</w:rPr>
	</w:style>
	<w:style w:type="character" w:styleId="FootnoteNumber"> <!-- without punctuation -->
		<w:name w:val="Footnote Number"/>
		<w:basedOn w:val="FootnoteReference"/>
		<w:rPr>
			<xsl:choose>
				<xsl:when test="$is-secondary">
					<w:b w:val="true"/>
				</xsl:when>
				<xsl:when test="$is-eu">
					<w:vertAlign w:val="superscript"/>
				</xsl:when>
			</xsl:choose>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="FootnoteText">
		<w:name w:val="Footnote Text"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:spacing w:before="0" />
			<xsl:if test="$is-secondary">
				<w:ind w:left="{ $indent-width * 0.5 }" w:hanging="{ $indent-width * 0.5 }" />
			</xsl:if>
		</w:pPr>
		<w:rPr>
			<xsl:if test="$is-secondary">
				<w:sz w:val="18"/>
			</xsl:if>
		</w:rPr>
	</w:style>

	<!-- schedules -->
	<w:style w:type="paragraph" w:styleId="Schedules">
		<w:name w:val="Schedules"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<w:spacing w:before="{ $space-before * 2 }" />
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:caps w:val="1"/>
			<w:spacing w:val="60" />
			<w:sz w:val="28"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="ScheduleNumber">
		<w:name w:val="Schedule Number"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<w:tabs>
				<w:tab w:val="center" w:pos="{ round($content-width div 2) }"/>
				<w:tab w:val="right" w:pos="{ $content-width }"/>
			</w:tabs>
			<w:spacing w:before="{ $space-before * 2 }" />
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:caps w:val="1"/>
			<xsl:choose>
				<xsl:when test="$is-secondary">
					<w:sz w:val="{ $font-size + 4 }"/>
				</xsl:when>
			</xsl:choose>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="ScheduleHeading">
		<w:name w:val="Schedule Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<!-- if is-secondary and is first schedule, page break before in template -->
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<xsl:choose>
				<xsl:when test="$is-primary">
					<w:smallCaps w:val="1"/>
				</xsl:when>
				<xsl:when test="$is-secondary">
					<w:i w:val="1"/>
				</xsl:when>
			</xsl:choose>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="ScheduleSubheading">
		<w:name w:val="Schedule Subheading"/>
		<w:basedOn w:val="ScheduleHeading"/>
	</w:style>
	<w:style w:type="paragraph" w:styleId="ScheduleReferenceP">
		<w:name w:val="Schedule Reference"/>
		<w:basedOn w:val="Normal"/>
		<w:qFormat/>
		<w:pPr>
			<w:keepNext/>
			<w:spacing w:before="0" />
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:i w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="character" w:styleId="ScheduleReference">	<!-- should this have a different id than the paragraph style -->
		<w:name w:val="Schedule Reference"/>
		<w:rPr>
			 <w:caps w:val="1"/>	<!-- 1 here seems to 'negate' paragraph style??? -->
			<xsl:choose>
				<xsl:when test="$is-primary">
					 <w:sz w:val="16"/>
				</xsl:when>
				<xsl:when test="$is-secondary">
					 <w:sz w:val="{ $font-size - 4 }"/>
				</xsl:when>
			</xsl:choose>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="SchedulePartNumber">
		<w:name w:val="Schedule Part Number"/>
		<w:basedOn w:val="PartNumber"/>
		<w:rPr>
			<w:b w:val="false" />
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="ScheduleParagraphHeading">
		<w:name w:val="Schedule Paragraph Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
		</w:pPr>
		<w:rPr>
			<w:i w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="ScheduleParagraph">
		<w:name w:val="Schedule Paragraph"/>
		<w:basedOn w:val="NumberedSectionHeading"/>
		<w:rPr>
			<w:b w:val="0"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="ScheduleParagraphAndSubparagraph">
		<w:name w:val="Schedule Paragraph and Subparagraph"/>
		<w:basedOn w:val="ScheduleParagraph"/>
		<w:qFormat/>
		<w:pPr>
			<w:tabs>
				<w:tab w:val="left" w:pos="540"/>
			</w:tabs>
		</w:pPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="ScheduleSubparagraph">
		<w:name w:val="Schedule Subparagraph"/>
		<w:basedOn w:val="SubsectionHeading"/>
		<w:pPr>
		</w:pPr>
	</w:style>
	<!-- P2 + P3 -->
	<w:style w:type="paragraph" w:styleId="ScheduleSubparagraphP3">
		<w:name w:val="Schedule Subparagraph and P3"/>
		<w:basedOn w:val="SubsectionP3Heading"/>
	</w:style>
	<!-- P3 -->
	<w:style w:type="paragraph" w:styleId="ScheduleP3Heading">
		<w:name w:val="Schedule P3"/>
		<w:basedOn w:val="P3Heading"/>
		<w:pPr>
		</w:pPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="ScheduleP3Text">
		<w:name w:val="Schedule P3 Text"/>
		<w:basedOn w:val="P3Text"/>
		<w:qFormat/>
		<w:pPr>
		</w:pPr>
	</w:style>

	<!-- P2 + P4 -->
	<w:style w:type="paragraph" w:styleId="ScheduleParagraphP4Heading"> <!-- untested -->
		<w:name w:val="Schedule Paragraph and P4"/>
		<w:basedOn w:val="SubsectionP4Heading"/>
	</w:style>
	<!-- P3 + P4 -->
	<w:style w:type="paragraph" w:styleId="ScheduleP3P4Heading">	<!-- untested -->
		<w:name w:val="Schedule P3 and P4"/>
		<w:basedOn w:val="P3P4Heading"/>
	</w:style>

	<!-- P4 + P5 -->
	<w:style w:type="paragraph" w:styleId="ScheduleP4P5Heading">	<!-- untested -->
		<w:name w:val="Schedule P4 and P5"/>
		<w:basedOn w:val="P4P5Heading"/>
	</w:style>
	
	<!-- appendices -->
	<w:style w:type="paragraph" w:styleId="AppendixNumber">
		<w:name w:val="Appendix Number"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
	</w:style>
	
	<!-- signatures -->
	<w:style w:type="paragraph" w:styleId="SignatoryText">
		<w:name w:val="Signatory Text"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
		</w:pPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="PersonName">
		<w:name w:val="Person's Name"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:jc w:val="right" />
		</w:pPr>
		<w:rPr>
			<w:i w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="JobTitle">
		<w:name w:val="Job Title"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:spacing w:before="0" />
			<w:jc w:val="right" />
		</w:pPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="Department">
		<w:name w:val="Department"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:spacing w:before="0" />
			<w:jc w:val="right" />
		</w:pPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="AddressLine">
		<w:name w:val="Address"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:spacing w:before="0" />
		</w:pPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="DateSigned">
		<w:name w:val="Date Signed"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:spacing w:before="0" />
		</w:pPr>
	</w:style>
	
	<!-- explanatory notes -->
	<w:style w:type="paragraph" w:styleId="ExplanatoryNotesHeading">
		<w:name w:val="Explanatory Note Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:pageBreakBefore />	<!-- set to false for EarlierOrders -->
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:b w:val="true"/>
			<w:caps w:val="true" />
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="ExplanatoryNotesComment">
		<w:name w:val="Explanatory Note Comment"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:spacing w:before="{ $space-before * 0.5 }" />
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:i w:val="true"/>
		</w:rPr>
	</w:style>

	<!-- commentaries -->
	<w:style w:type="character" w:styleId="CommentaryRef">
		<w:name w:val="Commentary Reference"/>
		<w:rPr>
			<w:b w:val="1" />
		</w:rPr>
	</w:style>
	
	<!-- links -->
	<w:style w:type="character" w:styleId="Hyperlink">
		<w:name w:val="Link"/>
		<w:rPr>
			<w:color w:val="4682B4" />	<!-- steel blue -->
		</w:rPr>
	</w:style>
	
	<!-- extent -->
	<w:style w:type="character" w:styleId="Extent">
		<w:name w:val="Extent"/>
		<w:rPr>
			<w:shd w:val="clear" w:fill="8B008B" w:color="FFFFFF" />	<!-- 660066 is purple from leg.gov.uk -->
		</w:rPr>
	</w:style>

	<!-- EU styles -->
	<xsl:sequence select="$eu-style-definitions" />

</xsl:variable>

<xsl:function name="local:get-style" as="element(w:style)?">
	<xsl:param name="id" as="xs:string" />
	<xsl:sequence select="$style-definitions[@w:styleId=$id]" />
</xsl:function>

<xsl:template name="styles">
	<w:styles>
		<w:docDefaults>
			<w:rPrDefault>
				<w:rPr>
					<w:rFonts w:ascii="{ $font }" w:eastAsia="{ $font }" w:hAnsi="{ $font }" w:cs="{ $font }" />
					<w:sz w:val="{ $font-size }"/>
					<w:szCs w:val="{ $font-size }"/>
					<w:lang w:val="en-UK" w:eastAsia="en-UK" w:bidi="ar-SA"/>
				</w:rPr>
			</w:rPrDefault>
			<w:pPrDefault/>
		</w:docDefaults>
		<xsl:copy-of select="$style-definitions" />
	</w:styles>
</xsl:template>

</xsl:transform>
