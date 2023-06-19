<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	exclude-result-prefixes="xs">


<xsl:template name="body-section-properties">
	<w:sectPr>
		<w:headerReference xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:id="body-header-first" w:type="first" />
		<w:headerReference xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:id="body-header-odd" w:type="default" />
		<w:headerReference xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:id="body-header-even" w:type="even" />
		<w:footerReference xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:id="body-footer-first" w:type="first" />
		<w:footerReference xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:id="body-footer" w:type="default" />
		<w:footerReference xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:id="body-footer" w:type="even" />
		<xsl:if test="$is-secondary">
			<w:footnotePr>
				<w:numFmt w:val="lowerLetter" />
				<w:numRestart w:val="eachPage" />
			</w:footnotePr>
		</xsl:if>
	    <w:pgSz w:w="{ $page-width }" w:h="{ $page-height }"/>
	    <w:pgMar w:top="{ $margin-width }" w:right="{ $margin-width }" w:bottom="{ $margin-width }" w:left="{ $margin-width }" w:header="{ $margin-width div 2 }" w:footer="{ $margin-width div 2 }" w:gutter="0"/>
	    <!-- <w:cols w:space="720" /> -->
	    <w:titlePg />	<!-- first page special -->
	    <!-- <w:docGrid w:linePitch="360" /> -->
	</w:sectPr>
</xsl:template>

<xsl:template name="header-relationships">
	<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="body-header-first" Type="http://purl.oclc.org/ooxml/officeDocument/relationships/header" Target="header1.xml"/>
	<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="body-header-odd" Type="http://purl.oclc.org/ooxml/officeDocument/relationships/header" Target="header2.xml"/>
	<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="body-header-even" Type="http://purl.oclc.org/ooxml/officeDocument/relationships/header" Target="header3.xml"/>
	<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="body-footer-first" Type="http://purl.oclc.org/ooxml/officeDocument/relationships/footer" Target="footer1.xml"/>
	<Relationship xmlns="http://schemas.openxmlformats.org/package/2006/relationships" Id="body-footer" Type="http://purl.oclc.org/ooxml/officeDocument/relationships/footer" Target="footer2.xml"/>
</xsl:template>

<xsl:template name="header1">	<!-- body-header-first -->
	<xsl:choose>
		<xsl:when test="$document-main-type = ('UnitedKingdomPublicGeneralAct','UnitedKingdomLocalAct','UnitedKingdomChurchMeasure')">
			<w:hdr>
				<w:p>
			        <w:pPr>
						<w:jc w:val="right" />
					</w:pPr>
					<w:r>
						<w:t>
							<xsl:attribute name="xml:space">preserve</xsl:attribute>
							<xsl:choose>
								<xsl:when test="$document-main-type = 'UnitedKingdomChurchMeasure'">
									<xsl:text>No. </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>c. </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</w:t>
					</w:r>
					<w:r>
				        <w:rPr>
				        	<w:b w:val="true" />
				        </w:rPr>
						<w:t>
							<xsl:value-of select="$document-number-formatted" />
						</w:t>
					</w:r>
				</w:p>
			</w:hdr>
		</xsl:when>
		<xsl:when test="$document-main-type = 'ScottishAct'">
			<xsl:call-template name="simple-left-header">
				<xsl:with-param name="short-type" select="'asp'" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="$document-main-type = 'WelshNationalAssemblyAct'">
			<xsl:call-template name="simple-left-header">
				<xsl:with-param name="short-type" select="'anaw'" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="$document-main-type = 'WelshParliamentAct'">
			<xsl:call-template name="simple-left-header">
				<xsl:with-param name="short-type" select="'asc'" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="$document-main-type = 'NorthernIrelandAct'">
			<w:hdr>
				<w:p>
					<w:r>
						<w:t>
							<xsl:attribute name="xml:space">preserve</xsl:attribute>
							<xsl:text>c. </xsl:text>
							<xsl:value-of select="$document-number" />
						</w:t>
					</w:r>
				</w:p>
			</w:hdr>
		</xsl:when>
		<xsl:otherwise>
			<w:hdr>
				<w:p />
			</w:hdr>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="header2">	<!-- body-header-odd -->
	<xsl:choose>
		<xsl:when test="$document-main-type = ('UnitedKingdomPublicGeneralAct','UnitedKingdomLocalAct','UnitedKingdomChurchMeasure')">
			<w:hdr>
				<w:p>
					<xsl:variable name="left-font-size" as="xs:integer" select="$font-size - 4" />
					<w:pPr>
						<w:pBdr>
							<w:bottom w:val="single" w:sz="8" w:space="1" w:color="000000" />	<!-- eighths of a point -->
						</w:pBdr>
						<w:tabs>
							<w:tab w:val="right" w:pos="{ $content-width }"/>
						</w:tabs>
					</w:pPr>
					<w:r>
				        <w:rPr>
							<w:i w:val="true" />
				        	<w:sz w:val="{ $left-font-size }" />
				        </w:rPr>
						<w:t>
							<xsl:value-of select="$document-title" />
						</w:t>
					</w:r>
					<w:r>
				        <w:rPr>
							<w:i w:val="true"/>
				        	<w:sz w:val="{ $left-font-size }" />
				        </w:rPr>
						<w:t>
							<xsl:attribute name="xml:space">preserve</xsl:attribute>
							<xsl:choose>
								<xsl:when test="$document-main-type = 'UnitedKingdomChurchMeasure'">
									<xsl:text> (No. </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> (c. </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</w:t>
					</w:r>
					<w:r>
				        <w:rPr>
							<w:b w:val="true"/>
							<w:i w:val="true"/>
				        	<w:sz w:val="{ $left-font-size }" />
				        </w:rPr>
						<w:t>
							<xsl:value-of select="$document-number-formatted" />
						</w:t>
					</w:r>
					<w:r>
				        <w:rPr>
							<w:i w:val="true"/>
				        	<w:sz w:val="{ $left-font-size }" />
				        </w:rPr>
						<w:t>
							<xsl:text>)</xsl:text>
						</w:t>
					</w:r>
					<w:r>
						<w:tab />
					</w:r>
					<w:r>
						<w:fldChar w:fldCharType="begin"/>
					</w:r>
					<w:r>
						<w:instrText> PAGE </w:instrText>
					</w:r>
					<w:r>
						<w:fldChar w:fldCharType="end"/>
					</w:r>
				</w:p>
			</w:hdr>
		</xsl:when>
		<xsl:when test="$document-main-type = 'ScottishAct'">
			<xsl:call-template name="header1" />
		</xsl:when>
		<xsl:when test="$document-main-type = 'WelshNationalAssemblyAct'">
			<xsl:call-template name="header1" />
		</xsl:when>
		<xsl:when test="$document-main-type = 'WelshParliamentAct'">
			<xsl:call-template name="header1" />
		</xsl:when>
		<xsl:when test="$document-main-type = 'NorthernIrelandAct'">
			<w:hdr>
				<w:p>
					<w:pPr>
						<w:tabs>
							<w:tab w:val="center" w:pos="{ round($content-width div 2) }"/>
						</w:tabs>
					</w:pPr>
					<w:r>
						<w:t>
							<xsl:text>c. </xsl:text>
							<xsl:value-of select="$document-number" />
						</w:t>
					</w:r>
					<w:r>
						<w:tab />
					</w:r>
					<w:r>
				        <w:rPr>
							<w:i w:val="true"/>
				        </w:rPr>
						<w:t>
							<xsl:value-of select="$document-title" />
						</w:t>
					</w:r>
				</w:p>
			</w:hdr>
		</xsl:when>
		<xsl:otherwise>
			<w:hdr>
				<w:p />
			</w:hdr>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="header3">	<!-- body-header-even -->
	<xsl:choose>
		<xsl:when test="$document-main-type = ('UnitedKingdomPublicGeneralAct','UnitedKingdomLocalAct','UnitedKingdomChurchMeasure')">
			<w:hdr>
				<w:p>
					<xsl:variable name="right-font-size" as="xs:integer" select="$font-size - 4" />
					<w:pPr>
						<w:pBdr>
							<w:bottom w:val="single" w:sz="8" w:space="1" w:color="000000" />	<!-- eighths of a point -->
						</w:pBdr>
						<w:tabs>
							<w:tab w:val="right" w:pos="{ $content-width }"/>
						</w:tabs>
					</w:pPr>
					<w:r>
						<w:fldChar w:fldCharType="begin"/>
					</w:r>
					<w:r>
						<w:instrText> PAGE </w:instrText>
					</w:r>
					<w:r>
						<w:fldChar w:fldCharType="end"/>
					</w:r>
					<w:r>
						<w:tab />
					</w:r>
					<w:r>
				        <w:rPr>
							<w:i w:val="true"/>
				        	<w:sz w:val="{ $right-font-size }" />
				        </w:rPr>
						<w:t>
							<xsl:value-of select="$document-title" />
						</w:t>
					</w:r>
					<w:r>
				        <w:rPr>
							<w:i w:val="true"/>
				        	<w:sz w:val="{ $right-font-size }" />
				        </w:rPr>
						<w:t>
							<xsl:attribute name="xml:space">preserve</xsl:attribute>
							<xsl:choose>
								<xsl:when test="$document-main-type = 'UnitedKingdomChurchMeasure'">
									<xsl:text> (No. </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> (c. </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</w:t>
					</w:r>
					<w:r>
				        <w:rPr>
							<w:b w:val="true"/>
							<w:i w:val="true"/>
				        	<w:sz w:val="{ $right-font-size }" />
				        </w:rPr>
						<w:t>
							<xsl:value-of select="$document-number-formatted" />
						</w:t>
					</w:r>
					<w:r>
				        <w:rPr>
							<w:i w:val="true"/>
				        	<w:sz w:val="{ $right-font-size }" />
				        </w:rPr>
						<w:t>
							<xsl:text>)</xsl:text>
						</w:t>
					</w:r>
				</w:p>
			</w:hdr>
		</xsl:when>
		<xsl:when test="$document-main-type = 'ScottishAct'">
			<w:hdr>
				<w:p>
					<w:pPr>
						<w:pBdr>
							<w:bottom w:val="single" w:sz="8" w:space="1" w:color="000000" />	<!-- eighths of a point -->
						</w:pBdr>
						<w:tabs>
							<w:tab w:val="right" w:pos="{ $content-width }"/>
						</w:tabs>
					</w:pPr>
					<w:r>
						<w:fldChar w:fldCharType="begin"/>
					</w:r>
					<w:r>
						<w:instrText> PAGE </w:instrText>
					</w:r>
					<w:r>
						<w:fldChar w:fldCharType="end"/>
					</w:r>
					<w:r>
						<w:tab />
					</w:r>
					<w:r>
				        <w:rPr>
							<w:i w:val="true" />
				        </w:rPr>
						<w:t>
							<xsl:value-of select="$document-title" />
						</w:t>
					</w:r>
					<w:r>
				        <w:rPr>
							<w:i w:val="true"/>
				        </w:rPr>
						<w:t>
							<xsl:attribute name="xml:space">preserve</xsl:attribute>
							<xsl:text> (asp </xsl:text>
						</w:t>
					</w:r>
					<w:r>
				        <w:rPr>
							<w:i w:val="true"/>
				        </w:rPr>
						<w:t>
							<xsl:value-of select="$document-number" />
						</w:t>
					</w:r>
					<w:r>
				        <w:rPr>
							<w:i w:val="true"/>
				        </w:rPr>
						<w:t>
							<xsl:text>)</xsl:text>
						</w:t>
					</w:r>
				</w:p>
			</w:hdr>
		</xsl:when>
		<xsl:when test="$document-main-type = 'WelshNationalAssemblyAct'">
			<xsl:call-template name="header1" />
		</xsl:when>
		<xsl:when test="$document-main-type = 'WelshParliamentAct'">
			<xsl:call-template name="header1" />
		</xsl:when>
		<xsl:when test="$document-main-type = 'NorthernIrelandAct'">
			<w:hdr>
				<w:p>
					<w:pPr>
						<w:tabs>
							<w:tab w:val="center" w:pos="{ round($content-width div 2) }"/>
						</w:tabs>
					</w:pPr>
					<w:r>
						<w:t>
							<xsl:text>c. </xsl:text>
							<xsl:value-of select="$document-number" />
						</w:t>
					</w:r>
					<w:r>
						<w:tab />
					</w:r>
					<w:r>
				        <w:rPr>
							<w:i w:val="true"/>
				        </w:rPr>
						<w:t>
							<xsl:value-of select="$document-title" />
						</w:t>
					</w:r>
				</w:p>
			</w:hdr>
		</xsl:when>
		<xsl:otherwise>
			<w:hdr>
				<w:p />
			</w:hdr>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="simple-left-header">
	<xsl:param name="short-type" as="xs:string" required="yes" />
	<w:hdr>
		<w:p>
			<w:pPr>
				<w:pBdr>
					<w:bottom w:val="single" w:sz="8" w:space="1" w:color="000000" />	<!-- eighths of a point -->
				</w:pBdr>
				<w:tabs>
					<w:tab w:val="right" w:pos="{ $content-width }"/>
				</w:tabs>
			</w:pPr>
			<w:r>
		        <w:rPr>
					<w:i w:val="true" />
		        </w:rPr>
				<w:t>
					<xsl:value-of select="$document-title" />
				</w:t>
			</w:r>
			<w:r>
		        <w:rPr>
					<w:i w:val="true"/>
		        </w:rPr>
				<w:t>
					<xsl:attribute name="xml:space">preserve</xsl:attribute>
					<xsl:text> (</xsl:text>
					<xsl:value-of select="$short-type" />
					<xsl:text> </xsl:text>
				</w:t>
			</w:r>
			<w:r>
		        <w:rPr>
					<w:i w:val="true"/>
		        </w:rPr>
				<w:t>
					<xsl:value-of select="$document-number" />
				</w:t>
			</w:r>
			<w:r>
		        <w:rPr>
					<w:i w:val="true"/>
		        </w:rPr>
				<w:t>
					<xsl:text>)</xsl:text>
				</w:t>
			</w:r>
			<w:r>
				<w:tab />
			</w:r>
			<w:r>
				<w:fldChar w:fldCharType="begin"/>
			</w:r>
			<w:r>
				<w:instrText> PAGE </w:instrText>
			</w:r>
			<w:r>
				<w:fldChar w:fldCharType="end"/>
			</w:r>
		</w:p>
	</w:hdr>
</xsl:template>


<!-- body-footer -->

<xsl:template name="footer1">
	<w:ftr>
		<w:p />
	</w:ftr>
</xsl:template>

<xsl:template name="footer2">
	<w:ftr>
		<xsl:choose>
			<xsl:when test="$document-main-type = ('NorthernIrelandAct') or $is-secondary">
				<w:p>
					<w:pPr>
						<w:jc w:val="center" />
					</w:pPr>
					<w:r>
						<w:fldChar w:fldCharType="begin"/>
					</w:r>
					<w:r>
						<w:instrText> PAGE </w:instrText>
					</w:r>
					<w:r>
						<w:fldChar w:fldCharType="end"/>
					</w:r>
				</w:p>
			</xsl:when>
			<xsl:otherwise>
				<w:p />
			</xsl:otherwise>
		</xsl:choose>
	</w:ftr>
</xsl:template>

</xsl:transform>
