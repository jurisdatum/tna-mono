<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:local="local"
	exclude-result-prefixes="xs local">


<xsl:variable name="eu-style-definitions" as="element(w:style)+">

	<w:style w:type="paragraph" w:styleId="EUDocumentTitle">
		<w:name w:val="Document Title"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:b w:val="true" />
		</w:rPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="EUPreamble">
		<w:name w:val="Preamble"/>
		<w:basedOn w:val="Normal"/>
	</w:style>

	<w:style w:type="paragraph" w:styleId="EUPreambleNumbered">
		<w:name w:val="Numbered Preamble"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:ind w:left="{ $indent-width }" w:hanging="{ $indent-width }" />
		</w:pPr>
	</w:style>
	
	
	<!-- big levels -->
	
	<w:style w:type="paragraph" w:styleId="EUPartNumber">
		<w:name w:val="Part Number"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="EUPartHeading">
		<w:name w:val="Part Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="EUTitleNumber">
		<w:name w:val="Title Number"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="EUTitleHeading">
		<w:name w:val="Title Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="EUChapterNumber">
		<w:name w:val="Chapter Number"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="EUChapterHeading">
		<w:name w:val="Chapter Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="EUSectionNumber">
		<w:name w:val="Section Number"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:spacing w:val="60" />
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="EUSectionHeading">
		<w:name w:val="Section Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:spacing w:val="60" />
		</w:rPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="EUSubsectionNumber">
		<w:name w:val="Subsection Number"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="EUSubsectionHeading">
		<w:name w:val="Subsection Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	
	
	<!-- provisions -->

	<w:style w:type="paragraph" w:styleId="EUArticleNumber">
		<w:name w:val="Article Number"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:i w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="EUArticleHeading">
		<w:name w:val="Article Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
			<w:b w:val="true"/>
			<w:i w:val="true"/>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="EUArticleText">
		<w:name w:val="Article Text"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<w:style w:type="paragraph" w:styleId="EUParagraph">
		<w:name w:val="Paragraph"/>
		<w:basedOn w:val="Normal"/>
	</w:style>

	<w:style w:type="paragraph" w:styleId="Division">
		<w:name w:val="Division"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:ind w:left="{ $indent-width }" w:hanging="{ $indent-width }" />
		</w:pPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="UnnumberedDivision">
		<w:name w:val="UnnumberedDivision"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:ind w:left="{ $indent-width }" />
		</w:pPr>
	</w:style>

	<!-- signatures -->

	<w:style w:type="paragraph" w:styleId="SigneeText">
		<w:name w:val="Signee Text"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:jc w:val="right" />
		</w:pPr>
	</w:style>
	
	<!-- annexes -->

	<w:style w:type="paragraph" w:styleId="EUAnnexNumber">
		<w:name w:val="Annex Number"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>
	<w:style w:type="paragraph" w:styleId="EUAnnexHeading">
		<w:name w:val="Annex Heading"/>
		<w:basedOn w:val="Normal"/>
		<w:pPr>
			<w:keepNext/>
			<w:jc w:val="center" />
		</w:pPr>
		<w:rPr>
		</w:rPr>
	</w:style>

	<!-- tables -->

	<w:style w:type="table" w:styleId="EUTableDefault">
		<w:name w:val="EU Table"/>
		<w:tblPr>
			<w:tblBorders>
				<w:top w:val="single" w:sz="6" w:space="0" w:color="auto" />
				<w:bottom w:val="single" w:sz="6" w:space="0" w:color="auto" />
				<w:insideH w:val="single" w:sz="6" w:space="0" w:color="auto" />
				<w:insideV w:val="single" w:sz="6" w:space="0" w:color="auto" />
			</w:tblBorders>
			<w:tblCellMar>
				<w:top w:w="60" w:type="dxa"/>
				<w:left w:w="60" w:type="dxa"/>
				<w:bottom w:w="60" w:type="dxa"/>
				<w:right w:w="60" w:type="dxa"/>
			</w:tblCellMar>
		</w:tblPr>
	</w:style>

</xsl:variable>

</xsl:transform>
