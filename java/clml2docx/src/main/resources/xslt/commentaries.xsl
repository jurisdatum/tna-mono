<?xml version="1.0" encoding="utf-8"?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:local="local"
	exclude-result-prefixes="xs local">

<xsl:template match="CommentaryRef[empty(key('id', @Ref))]">
	<xsl:message terminate="no">
		<xsl:text>no commentary for ref </xsl:text>
		<xsl:value-of select="@Ref" />
	</xsl:message>
</xsl:template>

<xsl:template match="CommentaryRef">
	<xsl:variable name="commentary" as="element(Commentary)" select="key('id', @Ref)[1]" />	<!-- multiple Commentaries with same id in ukpga/2011/20/2012-05-31 -->
	<xsl:variable name="type" as="xs:string" select="$commentary/@Type" />
	<xsl:variable name="is-first-ref-to-commentary" as="xs:boolean" select="empty(preceding::CommentaryRef[@Ref=current()/@Ref]) and empty(preceding::*[@CommentaryRef=current()/@Ref])" />
	<xsl:choose>
		<xsl:when test="local:show-commentary-marker($type)">
			<w:r>
			    <w:rPr>
					<w:b w:val="1" />
					<w:position w:val="6" />
			    </w:rPr>
			    <xsl:if test="$is-first-ref-to-commentary and empty(ancestor::Footnotes)">
			    	<xsl:variable name="footnote-id" as="xs:integer?" select="local:get-footnote-id-for-commentary($commentary)" />
				    <w:footnoteReference w:id="{ $footnote-id }" w:customMarkFollows="true" />
			    </xsl:if>
		        <w:t>
		        	<xsl:value-of select="$type" />
		        	<xsl:value-of select="local:get-commentary-number($commentary/@id)" />
		        </w:t>
			</w:r>
		</xsl:when>
		<xsl:when test="$is-first-ref-to-commentary">
			<w:r>
			    <w:rPr>
					<w:vanish w:val="true" />
				</w:rPr>
		    	<xsl:variable name="footnote-id" as="xs:integer" select="local:get-footnote-id-for-commentary($commentary)" />
			    <w:footnoteReference w:id="{ $footnote-id }" w:customMarkFollows="true" />
		        <w:t>
		        	<xsl:value-of select="$type" />
		        	<xsl:value-of select="local:get-commentary-number($commentary/@id)" />	<!-- @Ref = $commentary/@id -->
		        </w:t>
			</w:r>
		</xsl:when>
	</xsl:choose>
	<xsl:apply-templates />	<!-- ??? -->
</xsl:template>

<xsl:template match="CommentaryRef" mode="hidden-footnote-ref">
	<xsl:variable name="commentary" as="element(Commentary)?" select="key('id', @Ref)" />
	<xsl:if test="exists($commentary)">
		<xsl:variable name="is-first-ref-to-commentary" as="xs:boolean" select="empty(preceding::CommentaryRef[@Ref=current()/@Ref]) and empty(preceding::*[@CommentaryRef=current()/@Ref])" />
		<xsl:if test="$is-first-ref-to-commentary">
			<w:r>
			    <w:rPr>
			    	<w:vanish />
			    </w:rPr>
		    	<xsl:variable name="footnote-id" as="xs:integer" select="local:get-footnote-id-for-commentary($commentary)" />
			    <w:footnoteReference w:id="{ $footnote-id }" w:customMarkFollows="true" />
		        <w:t>
		        	<xsl:value-of select="$commentary/@Type" />
		        	<xsl:value-of select="local:get-commentary-number($commentary/@id)" />
		        </w:t>
			</w:r>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:variable name="all-commentaries-in-reference-order" as="element(Commentary)*">
	<xsl:variable name="all-elements" as="element()*" select="( //CommentaryRef | //*[exists(@CommentaryRef)] )" />
	<xsl:variable name="all-commentary-ids-with-duplicates" as="xs:string*">
		<xsl:for-each select="$all-elements">
			<xsl:choose>
				<xsl:when test="self::CommentaryRef">
					<xsl:sequence select="string(@Ref)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="string(@CommentaryRef)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="all-unique-commentary-ids-in-reference-order" as="xs:string*">
		<xsl:for-each-group select="$all-commentary-ids-with-duplicates" group-by=".">
			<xsl:sequence select="." />
		</xsl:for-each-group>
	</xsl:variable>
	<xsl:variable name="root" as="document-node()" select="root()" />
	<xsl:for-each select="$all-unique-commentary-ids-in-reference-order">
		<xsl:sequence select="key('id', ., $root)" />	<!-- self::Commentary only b/c of errors, e.g., in ukpga/1974/7 -->
	</xsl:for-each>
</xsl:variable>

<xsl:function name="local:get-footnote-id-for-commentary" as="xs:integer">
	<xsl:param name="commentary" as="element(Commentary)" />
	<xsl:variable name="index" as="xs:integer">
		<xsl:for-each select="$all-commentaries-in-reference-order">
			<xsl:if test=". is $commentary">
				<xsl:value-of select="position()" />
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:sequence select="$index * -1" />
</xsl:function>

<xsl:function name="local:get-footnote-id-for-commentary-id" as="xs:integer?">
	<xsl:param name="id" as="attribute()" />
	<xsl:variable name="commentary" as="element(Commentary)?" select="key('id', $id, root($id))[1]" />
	<xsl:if test="exists($commentary)">
		<xsl:sequence select="local:get-footnote-id-for-commentary($commentary)" />
	</xsl:if>
</xsl:function>

<xsl:function name="local:get-commentary-number" as="xs:integer?">
	<xsl:param name="id" as="attribute()" />
	<xsl:variable name="commentary" as="element(Commentary)?" select="key('id', $id, root($id))[1]" />	<!-- uksi/2020/822/2020-09-02 has duplicate Commentaries with same @Id -->
	<xsl:if test="exists($commentary)">
		<xsl:variable name="type" as="xs:string" select="$commentary/@Type" />
		<xsl:variable name="commentaries-of-type" as="element(Commentary)+" select="$all-commentaries-in-reference-order[@Type=$type]" />
		<xsl:variable name="index" as="xs:integer">
			<xsl:for-each select="$commentaries-of-type">
				<xsl:if test=". is $commentary">
					<xsl:value-of select="position()" />
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:sequence select="$index" />
	</xsl:if>
</xsl:function>

<xsl:function name="local:show-commentary-marker" as="xs:boolean">
	<xsl:param name="type" as="xs:string" />
	<xsl:sequence select="$type = ('F', 'M', 'X')" />
</xsl:function>

<xsl:function name="local:heading-before-number" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:param name="compact-format" as="xs:boolean" />
	<xsl:param name="inside-schedule" as="xs:boolean" />
	<xsl:choose>
		<xsl:when test="exists($e/self::P1) and $compact-format">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="exists($e/self::P1) and $inside-schedule">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template match="Addition | Substitution | Repeal">
	<xsl:param name="compact-format" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:param name="inside-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:variable name="is-first" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="exists(ancestor::Title/parent::P1group/child::P1[1][not(local:heading-before-number(., $compact-format, $inside-schedule))])">
				<xsl:variable name="changes-in-number" as="element()*" select="ancestor::Title/following-sibling::P1[1]/child::Pnumber/descendant::*[@ChangeId=current()/@ChangeId]" />
				<xsl:sequence select="empty(preceding::*[@ChangeId=current()/@ChangeId]) and empty(ancestor::*[@ChangeId=current()/@ChangeId]) and empty($changes-in-number)" />
			</xsl:when>
			<xsl:when test="exists(ancestor::Pnumber/parent::P1[empty(preceding-sibling::*[not(self::Title)])][not(local:heading-before-number(., $compact-format, $inside-schedule))])">
				<xsl:variable name="changes-in-title" as="element()*" select="ancestor::Pnumber/parent::P1/parent::P1group/child::Title/descendant::*[@ChangeId=current()/@ChangeId]" />
				<xsl:sequence select="empty(preceding::*[@ChangeId=current()/@ChangeId] except $changes-in-title) and empty(ancestor::*[@ChangeId=current()/@ChangeId] except $changes-in-title)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="empty(preceding::*[@ChangeId=current()/@ChangeId]) and empty(ancestor::*[@ChangeId=current()/@ChangeId])" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="is-last" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="exists(ancestor::Title/parent::P1group/child::P1[1][not(local:heading-before-number(., $compact-format, $inside-schedule))])">
				<xsl:variable name="changes-in-number" as="element()*" select="ancestor::Title/following-sibling::P1[1]/child::Pnumber/descendant::*[@ChangeId=current()/@ChangeId]" />
				<xsl:sequence select="empty(following::*[@ChangeId=current()/@ChangeId] except $changes-in-number) and empty(descendant::*[@ChangeId=current()/@ChangeId] except $changes-in-number)" />
			</xsl:when>
			<xsl:when test="exists(ancestor::Pnumber/parent::P1[empty(preceding-sibling::*[not(self::Title)])][not(local:heading-before-number(., $compact-format, $inside-schedule))])">
				<xsl:variable name="changes-in-title" as="element()*" select="ancestor::Pnumber/parent::P1/parent::P1group/child::Title/descendant::*[@ChangeId=current()/@ChangeId]" />
				<xsl:sequence select="empty(following::*[@ChangeId=current()/@ChangeId]) and empty(descendant::*[@ChangeId=current()/@ChangeId]) and empty($changes-in-title)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="empty(following::*[@ChangeId=current()/@ChangeId]) and empty(descendant::*[@ChangeId=current()/@ChangeId])" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="is-first-ref-to-commentary" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="exists(ancestor::Title/parent::P1group/child::P1[1][not(local:heading-before-number(., $compact-format, $inside-schedule))])">
				<xsl:variable name="other-elements-in-number" as="element()*" select="ancestor::Title/following-sibling::P1[1]/child::Pnumber/descendant::*[@CommentaryRef=current()/@CommentaryRef]" />
				<xsl:variable name="ref-elements-in-number" as="element()*" select="ancestor::Title/following-sibling::P1[1]/child::Pnumber/descendant::CommentaryRef[@Ref=current()/@CommentaryRef]" />
				<xsl:sequence select="empty(preceding::*[@CommentaryRef=current()/@CommentaryRef]) and empty(ancestor::*[@CommentaryRef=current()/@CommentaryRef]) and empty(preceding::CommentaryRef[@Ref=current()/@CommentaryRef]) and empty($other-elements-in-number) and empty($ref-elements-in-number)" />
			</xsl:when>
			<xsl:when test="exists(ancestor::Pnumber/parent::P1[empty(preceding-sibling::*[not(self::Title)])][not(local:heading-before-number(., $compact-format, $inside-schedule))])">
				<xsl:variable name="other-elements-in-title" as="element()*" select="ancestor::Pnumber/parent::P1/parent::P1group/child::Title/descendant::*[@CommentaryRef=current()/@CommentaryRef]" />
				<xsl:variable name="ref-elements-in-title" as="element()*" select="ancestor::Pnumber/parent::P1/parent::P1group/child::Title/descendant::CommentaryRef[@Ref=current()/@CommentaryRef]" />
				<xsl:sequence select="empty(preceding::*[@CommentaryRef=current()/@CommentaryRef] except $other-elements-in-title) and empty(ancestor::*[@CommentaryRef=current()/@CommentaryRef] except $other-elements-in-title) and empty(preceding::CommentaryRef[@Ref=current()/@CommentaryRef] except $ref-elements-in-title)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="empty(preceding::*[@CommentaryRef=current()/@CommentaryRef]) and empty(ancestor::*[@CommentaryRef=current()/@CommentaryRef]) and empty(preceding::CommentaryRef[@Ref=current()/@CommentaryRef])" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="commentary-number" as="xs:integer?" select="if (exists(@CommentaryRef)) then local:get-commentary-number(@CommentaryRef) else ()" />	<!-- Addition in ukpga/2014/12/2017-04-03 has no @CommentaryRef -->
	<xsl:if test="$is-first">
		<w:r>
			<w:rPr>
				<w:b w:val="1" />
			</w:rPr>
			<w:t>[</w:t>
		</w:r>
		<xsl:if test="exists($commentary-number)">
			<w:r>
			    <w:rPr>
					<w:b w:val="1" />
					<w:position w:val="6" />
		            <!-- <w:vertAlign w:val="superscript" /> -->
			    </w:rPr>
			    <xsl:if test="$is-first-ref-to-commentary and empty(ancestor::Footnotes)">
			    	<xsl:variable name="footnote-id" as="xs:integer?" select="local:get-footnote-id-for-commentary-id(@CommentaryRef)" />
			    	<xsl:if test="exists($footnote-id)">
					    <w:footnoteReference w:id="{ $footnote-id }" w:customMarkFollows="true" />
			    	</xsl:if>
			    </xsl:if>
		        <w:t>
		        	<xsl:text>F</xsl:text>
		        	<xsl:value-of select="$commentary-number" />
		        </w:t>
			</w:r>
		</xsl:if>
	</xsl:if>
	<xsl:apply-templates />
	<xsl:if test="$is-last">
		<w:r>
			<w:rPr>
				<w:b w:val="1" />
			</w:rPr>
			<w:t>]</w:t>
		</w:r>
	</xsl:if>
</xsl:template>

<xsl:template match="Addition | Substitution | Repeal" mode="hidden-footnote-ref">
	<xsl:variable name="is-first-for-change-id" as="xs:boolean" select="empty(preceding::*[@ChangeId=current()/@ChangeId])" />
	<xsl:variable name="is-first-for-commentary-ref" as="xs:boolean" select="empty(preceding::*[@CommentaryRef=current()/@CommentaryRef]) and empty(preceding::CommentaryRef[@Ref=current()/@CommentaryRef])" />
   	<xsl:variable name="footnote-id" as="xs:integer?" select=" if (exists(@CommentaryRef)) then local:get-footnote-id-for-commentary-id(@CommentaryRef) else ()" />
	<xsl:variable name="commentary-number" as="xs:integer?" select="if (exists(@CommentaryRef)) then local:get-commentary-number(@CommentaryRef) else ()" />
	<xsl:if test="$is-first-for-change-id and $is-first-for-commentary-ref and exists($footnote-id) and exists($commentary-number)">
		<w:r>
		    <w:rPr>
		    	<w:vanish />
		    </w:rPr>
		    <w:footnoteReference w:id="{ $footnote-id }" w:customMarkFollows="true" />
	        <w:t>
	        	<xsl:text>F</xsl:text>
	        	<xsl:value-of select="$commentary-number" />
	        </w:t>
		</w:r>
	</xsl:if>
</xsl:template>


<xsl:template match="Commentaries" />

<xsl:template match="Commentary">
	<w:footnote w:id="{ local:get-footnote-id-for-commentary(.) }">
		<xsl:apply-templates />
	</w:footnote>
</xsl:template>

<xsl:template match="Commentary/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Commentary/Para/Text">
    <w:p>
        <w:pPr>
            <w:pStyle w:val="FootnoteText"/>
        </w:pPr>
        <xsl:apply-templates />
    </w:p>
</xsl:template>

<xsl:template match="Commentary/Para[1]/Text[1]" priority="1">
    <w:p>
        <w:pPr>
            <w:pStyle w:val="FootnoteText"/>
        </w:pPr>
        <w:r>
			<w:rPr>
				<w:b w:val="1" />
			</w:rPr>
        	<w:t>
        		<xsl:value-of select="../../@Type" />
        		<xsl:value-of select="local:get-commentary-number(../../@id)" />
        	</w:t>
        </w:r>
        <w:r>	<!-- space between number and text -->
			<xsl:variable name="tab-after-number" as="xs:boolean" select="$is-footnote-style-2" />
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


<!-- margin notes -->

<xsl:template match="MarginNotes" />

<xsl:variable name="commentary-count" as="xs:integer" select="count(/Legislation/Commentaries/Commentary)" />

<xsl:function name="local:get-footnote-id-for-margin-note" as="xs:integer">
	<xsl:param name="margin-note" as="element(MarginNote)" />
	<xsl:sequence select="($commentary-count + count($margin-note/preceding-sibling::MarginNote) + 1) * -1" />
</xsl:function>

<xsl:function name="local:get-footnote-id-for-margin-note-ref" as="xs:integer?">
	<xsl:param name="ref" as="element(MarginNoteRef)" />
	<xsl:variable name="margin-note" as="element(MarginNote)?" select="key('id', $ref/@Ref, root($ref))[1]" />
	<xsl:if test="exists($margin-note)">
		<xsl:sequence select="local:get-footnote-id-for-margin-note($margin-note)" />
	</xsl:if>
</xsl:function>

<xsl:function name="local:get-m-note-number-for-margin-note" as="xs:integer?">
	<xsl:param name="id" as="attribute()" />
	<xsl:variable name="margin-note" as="element(MarginNote)?" select="key('id', $id, root($id))[1]" />
	<xsl:variable name="m-notes" as="element(Commentary)*" select="$all-commentaries-in-reference-order[@Type='M']" />
	<xsl:sequence select="count($m-notes) + count($margin-note/preceding-sibling::MarginNote) + 1" />
</xsl:function>

<xsl:template match="MarginNoteRef">
	<xsl:variable name="footnote-id" as="xs:integer?" select="local:get-footnote-id-for-margin-note-ref(.)" />
	<xsl:if test="exists($footnote-id)">
		<w:r>
			<w:rPr>
				<w:b w:val="1" />
				<w:position w:val="6" />
			</w:rPr>
			<w:footnoteReference w:id="{ $footnote-id }" w:customMarkFollows="true" />
			<w:t>
				<xsl:text>M</xsl:text>
				<xsl:value-of select="local:get-m-note-number-for-margin-note(@Ref)" />
			</w:t>
		</w:r>
	</xsl:if>
</xsl:template>

<xsl:template match="MarginNote">
	<w:footnote w:id="{ local:get-footnote-id-for-margin-note(.) }">
		<xsl:apply-templates />
	</w:footnote>
</xsl:template>

<xsl:template match="MarginNote/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="MarginNote/Para/Text">
	<xsl:call-template name="p">
		<xsl:with-param name="style" select="'FootnoteText'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="MarginNote/Para[1]/Text[1]" priority="1">
	<w:p>
		<w:pPr>
			<w:pStyle w:val="FootnoteText"/>
		</w:pPr>
		<w:r>
			<w:rPr>
				<w:b w:val="1" />
				<w:position w:val="6" />
			</w:rPr>
			<w:t>
				<xsl:text>M</xsl:text>
				<xsl:value-of select="local:get-m-note-number-for-margin-note(../../@id)" />
			</w:t>
		</w:r>
		<w:r>	<!-- space between number and text -->
			<xsl:variable name="tab-after-number" as="xs:boolean" select="$is-footnote-style-2" />
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
