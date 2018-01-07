<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" indent="yes" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Strict//EN" />

<xsl:template name="bbcode-attrs">
    <xsl:param name="attrs" select="''"/>

    <xsl:variable name="name" select="substring-before($attrs, '=')"/>
    <xsl:variable name="value" select="substring-before(substring-after($attrs, '&quot;'), '&quot;')"/>
    <xsl:variable name="leftover" select="normalize-space(substring-after(substring-after($attrs, '&quot;'), '&quot;'))"/>
    
    <xsl:if test="string-length($name)>0">
	<xsl:attribute name="{$name}">
	    <xsl:value-of select="$value"/>
	</xsl:attribute>
    </xsl:if>
    <xsl:if test="string-length($leftover)>0">
	<xsl:call-template name="bbcode-attrs">
	    <xsl:with-param name="attrs" select="$leftover"/>
	</xsl:call-template>
    </xsl:if>
</xsl:template>

<xsl:template name="bbcode-element">
    <xsl:param name="element" select="''"/>
    <xsl:param name="attrs" select="''"/>
    <xsl:param name="body" select="''"/>
    
    <xsl:element name="{$element}">
	<!-- Output the attributes -->
<!--	
	<xsl:call-template name="bbcode-attrs">
	    <xsl:with-param name="attrs" select="$attrs"/>
	</xsl:call-template>
-->	
	<!--
	    Recursive call passing the element body with the tags stripped, until the
	    body's length is 0 (i.e. there are no more tags, so everything is prefix)
	-->
	<xsl:if test="string-length($body)>0">
	    <xsl:call-template name="process-bbcode">
		<xsl:with-param name="buffer" select="$body"/>
		<xsl:with-param name="debug" select="'Process the body.'"/>
	    </xsl:call-template>
	</xsl:if>
    </xsl:element>
</xsl:template>

<xsl:template name="process-bbcode">
    <xsl:param name="prefix" select="''"/>
    <xsl:param name="buffer"  select="''"/>
    <xsl:param name="body" select="''"/>
    <xsl:param name="tag-name" select="''"/>
    <xsl:param name="tag-attrs" select="''"/>
    <xsl:param name="tag-nesting" select="0"/>
    <xsl:param name="debug" select="'Start of processing.'"/>

    <xsl:choose>
        <!-- Process body text -->
        <xsl:when test="string-length($prefix)=0 and string-length(body)=0 and not(contains($buffer, '['))">
            <xsl:value-of select="$buffer"/>
        </xsl:when>

        <!-- Process root level tags-->
        <xsl:when test="$tag-nesting=0">

            <!-- Dump the body text before the open tag -->
            <xsl:value-of select="$prefix"/>
            
            <!-- Output the element as XML (process '$body') -->
	    <xsl:choose>
		<xsl:when test="$tag-name='h1'">
		    <xsl:call-template name="bbcode-element">
			<xsl:with-param name="element" select="'h3'"/>
			<xsl:with-param name="attrs" select="$tag-attrs"/>
			<xsl:with-param name="body" select="$body"/>
		    </xsl:call-template>
		</xsl:when>
		<xsl:when test="$tag-name='h2'">
		    <xsl:call-template name="bbcode-element">
			<xsl:with-param name="element" select="'h4'"/>
			<xsl:with-param name="attrs" select="$tag-attrs"/>
			<xsl:with-param name="body" select="$body"/>
		    </xsl:call-template>
		</xsl:when>
		<xsl:when test="$tag-name='h3'">
		    <xsl:call-template name="bbcode-element">
			<xsl:with-param name="element" select="'h5'"/>
			<xsl:with-param name="attrs" select="$tag-attrs"/>
			<xsl:with-param name="body" select="$body"/>
		    </xsl:call-template>
		</xsl:when>
		<xsl:when test="$tag-name='h4'">
		    <xsl:call-template name="bbcode-element">
			<xsl:with-param name="element" select="'h6'"/>
			<xsl:with-param name="attrs" select="$tag-attrs"/>
			<xsl:with-param name="body" select="$body"/>
		    </xsl:call-template>
		</xsl:when>
		<xsl:when test="$tag-name='h5'">
		    <xsl:call-template name="bbcode-element">
			<xsl:with-param name="element" select="'h7'"/>
			<xsl:with-param name="attrs" select="$tag-attrs"/>
			<xsl:with-param name="body" select="$body"/>
		    </xsl:call-template>
		</xsl:when>
		<xsl:when test="$tag-name='h6'">
		    <xsl:call-template name="bbcode-element">
			<xsl:with-param name="element" select="'h8'"/>
			<xsl:with-param name="attrs" select="$tag-attrs"/>
			<xsl:with-param name="body" select="$body"/>
		    </xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
		    <xsl:call-template name="bbcode-element">
			<xsl:with-param name="element" select="$tag-name"/>
			<xsl:with-param name="attrs" select="$tag-attrs"/>
			<xsl:with-param name="body" select="$body"/>
		    </xsl:call-template>
		</xsl:otherwise>
	    </xsl:choose>


            <xsl:variable name="next-tag" select="
                substring-before(substring-after(normalize-space($buffer),'['), ']')
            "/>

            <!-- Process the rest of the '$buffer' -->
            <xsl:choose>
                <!-- Process the remaining buffer as body text if it soesn't contain tags. -->
		<xsl:when test="string-length($next-tag)=0">
                    <xsl:call-template name="process-bbcode">
                        <xsl:with-param name="buffer" select="$buffer"/>
                        <xsl:with-param name="debug" select="'Finishing the buffer.'"/>
                    </xsl:call-template>
		</xsl:when>
		
                <!-- Start new element with attributes -->
                <xsl:when test="contains($next-tag, '=')">
                    <xsl:variable name="next-tag-name"       select="substring-before($next-tag, ' ')"/>
                    <xsl:variable name="next-tag-attributes" select="substring-after($next-tag, ' ')"/>
                    <xsl:call-template name="process-bbcode">
                        <xsl:with-param name="tag-attrs"    select="$next-tag-attributes"/>
                        <xsl:with-param name="tag-name"     select="$next-tag-name"/>
                        <xsl:with-param name="tag-nesting"  select="1"/>
                        <xsl:with-param name="prefix"       select="substring-before($buffer, '[')"/>
                        <xsl:with-param name="buffer"       select="substring-after ($buffer, ']')"/>
                        <xsl:with-param name="debug"	    select="'Start new tag with attrs.'"/>
                    </xsl:call-template>
                </xsl:when>

                <!-- Start new element without attributes -->
                <xsl:otherwise>
                    <xsl:call-template name="process-bbcode">
                        <xsl:with-param name="tag-name"     select="$next-tag"/>
                        <xsl:with-param name="tag-nesting"  select="1"/>
                        <xsl:with-param name="prefix"       select="substring-before($buffer, '[')"/>
                        <xsl:with-param name="buffer"       select="substring-after($buffer, ']')"/>
                        <xsl:with-param name="debug"        select="'Start new tag without attrs.'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <!-- ?? Proces nested tags of the same type -->
        <xsl:when test="contains($buffer, '[/$tag]')">
            <xsl:variable name="tag" select="
                normalize-space(substring-before(substring-after($buffer, '['), ']'))
            "/>
            <xsl:variable name="next-tag-name" select="normalize-space(substring-before($tag, ' '))"/>
            <xsl:choose>
                <xsl:when test="
                    starts-with($tag, normalize-space($tag-name))
                    and (
                        (string-length(tag-name) = string-length(tag))
                        or
                        contains(' /]', substring($tag, string-length(tag-name) + 1, 1))
                    )
                ">
                    <xsl:call-template name="process-bbcode">
                        <xsl:with-param name="prefix" select="$prefix"/>
                        <xsl:with-param name="body" select="
                            concat($body, concat(substring-before($buffer, ']'), ']'))
                        "/>
                        <xsl:with-param name="buffer" select="
                            substring-after($buffer, ']')
                        "/>
                        <xsl:with-param name="tag-name" select="$tag-name"/>
                        <xsl:with-param name="tag-attrs" select="$tag-attrs"/>
                        <xsl:with-param name="tag-nesting" select="$tag-nesting + 1"/>
                        <xsl:with-param name="debug" select="'Unknown 1.'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$next-tag-name=concat('/', normalize-space($tag-name))">
                    <xsl:call-template name="process-bbcode">
                        <xsl:with-param name="prefix" select="$prefix"/>
                        <xsl:with-param name="body" select="
                            concat($body, concat(substring-before($buffer, ']'), ']'))
                        "/>
                        <xsl:with-param name="buffer" select="
                            substring-after($buffer, ']')
                        "/>
                        <xsl:with-param name="tag-name" select="$tag-name"/>
                        <xsl:with-param name="tag-attrs" select="$tag-attrs"/>
                        <xsl:with-param name="tag-nesting" select="$tag-nesting - 1"/>
                        <xsl:with-param name="debug" select="'Unknown 2.'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:when>
        <!-- ?? Pop the content before the closing tag with zero nesting -->
	<xsl:otherwise>
            <xsl:variable name="tag-closing" select="concat(concat('[/', $tag-name), ']')"/>
            <xsl:call-template name="process-bbcode">
                <xsl:with-param name="prefix"      select="$prefix"/>
                <xsl:with-param name="body"        select="substring-before($buffer, $tag-closing)"/>
                <xsl:with-param name="buffer"      select="substring-after ($buffer, $tag-closing)"/>
                <xsl:with-param name="tag-name"    select="$tag-name"/>
                <xsl:with-param name="tag-attrs"   select="$tag-attrs"/>
                <xsl:with-param name="tag-nesting" select="0"/>
                <xsl:with-param name="debug"       select="'Output element.'"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="test">            
    <html><body>
        <xsl:call-template name="process-bbcode">
            <xsl:with-param name="buffer" select="string(.)"/>
        </xsl:call-template>
    </body></html>
</xsl:template>            

</xsl:stylesheet>