<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:local="local"
	exclude-result-prefixes="xs html local">

<xsl:key name="footnote-ref" match="FootnoteRef" use="@Ref" />

<xsl:function name="local:is-first-footnote-ref" as="xs:boolean">
	<xsl:param name="ref" as="element(FootnoteRef)" />
	<xsl:sequence select="key('footnote-ref', $ref/@Ref, root($ref))[1] is $ref" />
</xsl:function>

<xsl:function name="local:is-autonumbered" as="xs:boolean">
	<xsl:param name="ref" as="element(FootnoteRef)" />
	<xsl:variable name="footnote" as="element(Footnote)" select="key('id', $ref/@Ref, root($ref))" />
   	<xsl:sequence select="empty($footnote/child::Number)" />
</xsl:function>

<xsl:function name="local:guess-footnote-number" as="xs:integer">
	<xsl:param name="ref" as="element(FootnoteRef)" />
	<xsl:variable name="first" as="element(FootnoteRef)" select="key('footnote-ref', $ref/@Ref, root($ref))[1]" />
	<xsl:variable name="preceding" as="xs:integer" select="count($first/preceding::FootnoteRef[local:is-first-footnote-ref(.) and local:is-autonumbered(.)])" />
	<xsl:choose>
		<xsl:when test="exists($first//ancestor::html:tfoot)">
			<xsl:variable name="body" as="xs:integer" select="count($first//ancestor::html:tfoot/following-sibling::html:tbody/descendant::FootnoteRef[local:is-first-footnote-ref(.) and local:is-autonumbered(.)])" />
			<xsl:sequence select="$preceding + $body + 1" />
		</xsl:when>
		<xsl:when test="exists($first/ancestor::html:tbody)">
			<xsl:variable name="foot" as="xs:integer" select="count($first//ancestor::html:tbody/preceding-sibling::html:tfoot/descendant::FootnoteRef[local:is-first-footnote-ref(.) and local:is-autonumbered(.)])" />
			<xsl:sequence select="$preceding + $foot + 1" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$preceding + 1" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:variable name="is-footnote-style-2" as="xs:boolean" select="$is-secondary" />

<xsl:function name="local:int-to-hex" as="xs:string">
	<xsl:param name="n" as="xs:integer" />
	<xsl:variable name="digits" select="'0123456789ABCDEF'"/>
	<xsl:choose>
		<xsl:when test="$n le 16">
			<xsl:sequence select="substring($digits, $n + 1, 1)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="last" as="xs:string" select="local:int-to-hex($n mod 16)" />
			<xsl:variable name="rest" as="xs:string" select="local:int-to-hex($n idiv 16)" />
			<xsl:sequence select="concat($rest, $last)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:generate-hex-binary-id" as="xs:hexBinary">
	<xsl:param name="node" as="node()" />
	<xsl:variable name="index" as="xs:integer" select="count($node/preceding::node())" />
	<xsl:variable name="hex" as="xs:string" select="local:int-to-hex($index)" />
	<xsl:variable name="padding" as="xs:string" select="string-join(for $i in (string-length($hex) to 7) return '0', '')" />
	<xsl:variable name="padded" as="xs:string" select="concat($padding, $hex)" />
	<xsl:sequence select="xs:hexBinary($padded)" />
</xsl:function>

<xsl:template match="FootnoteRef[empty(key('id', @Ref))]">
	<xsl:message terminate="no">
		<xsl:text>no footnote for ref </xsl:text>
		<xsl:value-of select="@Ref" />
	</xsl:message>
</xsl:template>

<xsl:template match="FootnoteRef">
	<xsl:variable name="footnote" as="element(Footnote)" select="key('id', @Ref)" />
    <xsl:variable name="footnote-wid" as="xs:unsignedInt" select="xs:unsignedInt(number(substring(@Ref, 2)))" />
	<xsl:comment>
		<xsl:value-of select="local-name(.)" />
		<xsl:text> </xsl:text>
		<xsl:value-of select="@Ref" />
	</xsl:comment>
	<w:r>
	    <w:rPr>
	        <w:rStyle w:val="FootnoteReference"/>
	    </w:rPr>
        <w:t>(</w:t>
	</w:r>
	<xsl:choose>
		<xsl:when test="local:is-first-footnote-ref(.) and empty(ancestor::Footnote)">
			<xsl:variable name="bookmark-wid" as="xs:integer" select="local:get-bookmark-id-1(@Ref)" />
			<w:bookmarkStart w:id="{ $bookmark-wid }" w:name="_Re{ @Ref }"/>
			<w:r>
			    <w:rPr>
			        <w:rStyle w:val="FootnoteNumber"/>
			    </w:rPr>
			    <xsl:choose>
			    	<xsl:when test="exists($footnote/child::Number)">
					    <w:footnoteReference w:id="{ $footnote-wid }" w:customMarkFollows="true" />
				        <w:t>
				        	<xsl:value-of select="normalize-space($footnote/child::Number)" />
				        </w:t>
			    	</xsl:when>
			    	<xsl:otherwise>
					    <w:footnoteReference w:id="{ $footnote-wid }"/>
			    	</xsl:otherwise>
			    </xsl:choose>
			</w:r>
			<w:bookmarkEnd w:id="{ $bookmark-wid }"/>
			<!--  -->
			<xsl:for-each select="$footnote/descendant::FootnoteRef">
				<xsl:if test="local:is-first-footnote-ref(.)">	<!-- this is necessary at least to avoid duplicate bookmarks -->
					<!-- but perhaps ONLY the bookmarks should be removed if not first-ref -->
					<xsl:variable name="footnote2" as="element(Footnote)?" select="key('id', @Ref)" />
					<xsl:choose>
						<xsl:when test="exists($footnote2)">
						    <xsl:variable name="footnote2-wid" as="xs:unsignedInt" select="xs:unsignedInt(number(substring(@Ref, 2)))" />
							<xsl:variable name="bookmark2-wid" as="xs:integer" select="local:get-bookmark-id-1(@Ref)" />
							<xsl:comment>
								<xsl:value-of select="local-name(.)" />
								<xsl:text> </xsl:text>
								<xsl:value-of select="@Ref" />
							</xsl:comment>
							<w:bookmarkStart w:id="{ $bookmark2-wid }" w:name="_Re{ @Ref }"/>
							<w:r>
							    <w:rPr>
							    	<w:vanish />
							    </w:rPr>
							    <xsl:choose>
							    	<xsl:when test="exists($footnote2/child::Number)">
									    <w:footnoteReference w:id="{ $footnote2-wid }" w:customMarkFollows="true" />
								        <w:t>
								        	<xsl:value-of select="normalize-space($footnote2/child::Number)" />
								        </w:t>
							    	</xsl:when>
							    	<xsl:otherwise>
									    <w:footnoteReference w:id="{ $footnote2-wid }"/>
							    	</xsl:otherwise>
							    </xsl:choose>
							</w:r>
							<w:bookmarkEnd w:id="{ $bookmark2-wid }"/>
						</xsl:when>
						<xsl:when test="$debug">
							<xsl:message terminate="no">
								<xsl:text>no footnote for ref </xsl:text>
								<xsl:value-of select="@Ref" />
							</xsl:message>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
			</xsl:for-each>
			<xsl:apply-templates select="$footnote/descendant::CommentaryRef" mode="hidden-footnote-ref" />
			<xsl:apply-templates select="$footnote/descendant::Addition | $footnote/descendant::Substitution | $footnote/descendant::Repeal" mode="hidden-footnote-ref" />
		</xsl:when>
<!-- 		<xsl:when test="false() and exists(ancestor::Footnote)">
            <w:r>
                <w:rPr>
                    <w:rStyle w:val="FootnoteNumber"/>
                </w:rPr>
                <w:t>
                	<xsl:value-of select="local:guess-footnote-number(.)" />
                </w:t>
            </w:r>
		</xsl:when> -->
		<xsl:otherwise>
			<xsl:variable name="rsidR" as="xs:hexBinary" select="local:generate-hex-binary-id(.)" />
            <w:r w:rsidR="{ $rsidR }">
                <w:rPr>
                    <w:rStyle w:val="FootnoteNumber"/>
                </w:rPr>
                <w:fldChar w:fldCharType="begin"/>
            </w:r>
            <w:r w:rsidR="{ $rsidR }">
                <w:rPr>
                    <w:rStyle w:val="FootnoteNumber"/>
                </w:rPr>
                <w:instrText xml:space="preserve"><xsl:value-of select="concat(' NOTEREF _Re', @Ref, ' ')" /></w:instrText>	<!-- add \h to make hyperlink -->
            </w:r>
            <w:r w:rsidR="{ $rsidR }">
                <w:rPr>
                    <w:rStyle w:val="FootnoteNumber"/>
                </w:rPr>
                <w:fldChar w:fldCharType="separate"/>
            </w:r>
            <w:r w:rsidR="{ $rsidR }">
                <w:rPr>
                    <w:rStyle w:val="FootnoteNumber"/>
                </w:rPr>
                <w:t>
                	<xsl:value-of select="local:guess-footnote-number(.)" />
                </w:t>
            </w:r>
            <w:r w:rsidR="{ $rsidR }">
                <w:rPr>
                    <w:rStyle w:val="FootnoteNumber"/>
                </w:rPr>
                <w:fldChar w:fldCharType="end"/>
            </w:r>
		</xsl:otherwise>
	</xsl:choose>
 	<w:r>
	    <w:rPr>
	        <w:rStyle w:val="FootnoteReference"/>
	    </w:rPr>
        <w:t>)</w:t>
	</w:r>
</xsl:template>

<xsl:template match="Footnotes" />

<xsl:template name="footnotes">
	<xsl:variable name="compact-format" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$document-category = 'secondary'">
				<xsl:sequence select="true()" />
			</xsl:when>
			<xsl:when test="$document-main-type = 'NorthernIrelandAct'">
				<xsl:sequence select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<w:footnotes>
		<xsl:apply-templates select="/Legislation/Footnotes/*">
			<xsl:with-param name="compact-format" select="$compact-format" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="/Legislation/MarginNotes/*">
			<xsl:with-param name="compact-format" select="$compact-format" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="/Legislation/Commentaries/Commentary">
			<xsl:with-param name="compact-format" select="$compact-format" tunnel="yes" />
		</xsl:apply-templates>
	</w:footnotes>
</xsl:template>

<xsl:template match="Footnote">
	<w:footnote w:id="{ number(substring(@id, 2)) }"> <!-- w:type="normal" -->
		<xsl:apply-templates />
	</w:footnote>
</xsl:template>

<xsl:template match="Footnote/Number">
</xsl:template>

<xsl:template match="FootnoteText | FootnoteText/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="FootnoteText/Para/Text | FootnoteText/Text">
    <w:p>
        <w:pPr>
            <w:pStyle w:val="FootnoteText"/>
        </w:pPr>
        <xsl:apply-templates />
    </w:p>
</xsl:template>

<xsl:template match="FootnoteText/*[1]/*[1][self::Text] | FootnoteText/*[1][self::Text]" priority="1">
	<xsl:variable name="footnote" as="element(Footnote)" select="ancestor::Footnote[1]" />
	<xsl:variable name="tab-after-number" as="xs:boolean" select="$is-footnote-style-2" />
    <w:p>
        <w:pPr>
            <w:pStyle w:val="FootnoteText"/>
        </w:pPr>
		<xsl:choose>
			<xsl:when test="exists($footnote/child::Number)">
		        <w:r>
		            <w:rPr>
		                <w:rStyle w:val="FootnoteReference"/>
		            </w:rPr>
            		<w:t>
			        	<xsl:value-of select="normalize-space($footnote/child::Number)" />
            		</w:t>
		        </w:r>
			</xsl:when>
			<xsl:when test="empty($footnote/parent::Footnotes)">	<!-- it's a table (foot)note --> <!-- nisr/2002/20/made -->
		        <w:r>
		            <w:rPr>
		                <w:rStyle w:val="FootnoteReference"/>
		            </w:rPr>
		            <w:t>(</w:t>
		            <w:t>	<!-- didn't add FootnoteNumber style here b/c it's not used with 'normal' table footnotes -->
			        	<xsl:value-of select="number(substring($footnote/@id, 2))" />
		            </w:t>
		            <w:t>)</w:t>
		        </w:r>
			</xsl:when>
			<xsl:otherwise>
		        <w:r>
		            <w:rPr>
		                <w:rStyle w:val="FootnoteReference"/>
		            </w:rPr>
		            <w:t>(</w:t>
		        </w:r>
		        <w:r>
		            <w:rPr>
		                <w:rStyle w:val="FootnoteNumber"/>
		            </w:rPr>
		            <w:footnoteRef />
		        </w:r>
		        <w:r>
		            <w:rPr>
		                <w:rStyle w:val="FootnoteReference"/>
		            </w:rPr>
		            <w:t>)</w:t>
		        </w:r>
			</xsl:otherwise>
		</xsl:choose>
        <w:r>	<!-- space between number and text -->
			<xsl:choose>
				<xsl:when test="$tab-after-number">
					<w:tab />
				</xsl:when>
				<xsl:otherwise>
		            <w:t>
						<xsl:attribute name="xml:space">preserve</xsl:attribute>
		            	<xsl:text> </xsl:text>
		            </w:t>
				</xsl:otherwise>
			</xsl:choose>
        </w:r>
        <xsl:apply-templates />
    </w:p>
</xsl:template>

</xsl:transform>
