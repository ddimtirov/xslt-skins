<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" indent="yes" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Strict//EN" />

<xsl:variable name="default-target" select="/project/@default"/>

<xsl:template match="description">            
    <div class="section">
    <pre>
	<xsl:value-of select="string(.)"/>
    </pre>
    </div>
</xsl:template>            

<xsl:template match="target" mode="details">
    <div class="target-details content toplevel-box" id="target-details-{@name}">
        <!-- Top Link -->
        <a href="#project-title" class="head-element">TOP</a>
        
        <!-- Target Name -->
        <h2 class="section-heading">
            Target: <xsl:value-of select="@name"/>
            <xsl:if test="@name=$default-target"> (default target)</xsl:if>
        </h2>

        <!-- Preconditions and required targets -->        
        <div class="thin-bar">
            <div class="preconditions">
                <xsl:if test="string-length(@if) > 0">
                    <h3>if:</h3><xsl:value-of select="@if"/> 
                </xsl:if>
                
                <xsl:if test="string-length(@unless) > 0">
                    <h3>unless:</h3><xsl:value-of select="@unless"/>
                </xsl:if>
            </div>
            <xsl:if test="string-length(@depends) > 0">
                <h3>depends on:</h3>
                <xsl:call-template name="target-list-str">
                    <xsl:with-param name="space-delimited-tasks" select="normalize-space(translate(@depends, ',', ' '))"/>
                </xsl:call-template>
            </xsl:if>
        </div>
        
        <!-- Description -->
        <xsl:if test="string-length(@description) > 0">
            <div class="description">
                <h3>Description: </h3>
                <xsl:value-of select="@description"/>
            </div>
        </xsl:if>
        
        <!-- Declarations (props, paths, etc.) -->
        <xsl:call-template name="declarations-summary"/>
        
        <!-- Task Descriptions-->
        <xsl:if test="count(*) > 0">
        <div class="tasks">
            <h3>Tasks:</h3>
            <ol>
            <xsl:for-each select="*">
                <xsl:if test="not(contains('property path classpath available condition', name()))">
                <li>
                    <strong><xsl:value-of select="name()"/></strong>
                    <xsl:if test="string-length(@if) > 0">
                        <strong> if: </strong><code><xsl:value-of select="@if"/></code>
                    </xsl:if>
                    <xsl:if test="string-length(@unless) > 0">
                        <strong> unless: </strong><code><xsl:value-of select="@unless"/></code>
                    </xsl:if>
                    <xsl:if test="string-length(@description) >0">
                        - <xsl:value-of select="@description"/>
                    </xsl:if>
                </li>
                </xsl:if>
            </xsl:for-each>
            </ol>
        </div>
        </xsl:if>
        
        <!-- List Dependent Tasks-->
        <xsl:variable name="target-name" select="@name"/>
        <xsl:if test="count(/project/target[contains(@depends, $target-name)]) > 0">
            <div class="dependent thin-bar">
                <h3>dependent: </h3>
                <xsl:for-each select="/project/target[contains(@depends, $target-name)]">
                    <xsl:call-template name="target-link">
                        <xsl:with-param name="target-name" select="@name"/>
                    </xsl:call-template>
                </xsl:for-each>
            </div>
        </xsl:if>
    </div>
</xsl:template>

<xsl:template match="target" mode="toc">
    <li>
    <xsl:call-template name="target-link">
        <xsl:with-param name="target-name" select="@name"/>
    </xsl:call-template>
    </li>
</xsl:template>            

<!--
    Process the root project element.
-->
<xsl:template match="project">
    <html>
    <head>
        <xsl:comment>XSLT stylesheet by dimiter@blue-edge.bg</xsl:comment>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <link rel="stylesheet" href="ant-skin.css" type="text/css" />
        
        <title>Ant Project Source: <xsl:value-of select="@name"/></title>
    </head>
    <body>
        <!-- BEGIN Page Heading -->
        <div id="project-head" class="section-heading">
            <h1 id="project-title">
                <xsl:value-of select="@name"/>
            </h1>
            <div id="motto">One more way to skin an Ant...</div>
        </div>
        <!-- END Page Heading -->

        <!-- BEGIN Targets TOC -->
            <div id="targets-toc" class="toplevel-box sidebar">
            <h2 class="section-heading">Targets</h2>
            <ul>
                <li><a class="virtual" href="#global-scope" title="Global Definitions">global definitions</a></li>
                <xsl:apply-templates select="target" mode="toc"/>
            </ul>
            </div>
        <!-- END Targets TOC -->

        <!-- BEGIN Project Global Scope Details -->
        <div class="target-details content toplevel-box" id="global-scope-details">
            <a href="#project-title" class="head-element">TOP</a>
            <h2 class="section-heading">Global Scope Definitions</h2>
            <div class="description">
                <xsl:apply-templates select="description"/>
            </div>
            <xsl:call-template name="declarations-summary"/>
        </div>
        <!-- END Project Global Scope Details -->
        
        <!-- Generate target details -->
        <xsl:apply-templates select="target" mode="details"/>
    </body>
  </html>
</xsl:template>

<!--
    Outputs a table row describing each property.
    Make sure that you don't apply this template outside of the declarations-summary template.
-->
<xsl:template match="property" mode="table-NameValueDescr">
    <xsl:element name="tr">
	<!-- copy the property ID if any-->
	<xsl:if test="@id">
	    <xsl:attribute name="id">prop-<xsl:value-of select="@id"/></xsl:attribute>
	</xsl:if>
	<xsl:attribute name="class">prop-entry</xsl:attribute>
	
	<!-- Property names & prefixes column -->
	<td class="prop-name">
	    <!-- Explain */property/@prefix -->
	    <xsl:call-template name="explain">
		<xsl:with-param name="value"        select="@prefix"/>
		<xsl:with-param name="class"        select="'prop-name-fileprefix'"/>
		<xsl:with-param name="label"        select="'Prefix: '"/>
		<xsl:with-param name="explanation"  select="'Prefix to apply to properties loaded using file or resource.'"/>
	    </xsl:call-template>
	    
	    <!-- Explain */property/@environment -->
	    <xsl:call-template name="explain">
		<xsl:with-param name="value"        select="@environment"/>
		<xsl:with-param name="class"        select="'prop-name-envprefix'"/>
		<xsl:with-param name="label"        select="'EnvPrefix: '"/>
		<xsl:with-param name="explanation"  select="'The prefix to use when retrieving environment variables.'"/>
	    </xsl:call-template>
	    
	    <!-- Explain */property/@name -->
	    <xsl:call-template name="explain">
		<xsl:with-param name="value"        select="@name"/>
		<xsl:with-param name="class"        select="'prop-name-content'"/>
		<xsl:with-param name="explanation"  select="'The name of the property.'"/>
	    </xsl:call-template>
	</td>
	
	<!-- Property values column -->
	<td class="prop-value">
	    <!-- Explain */property/@environment -->
	    <xsl:call-template name="explain">
		<xsl:with-param name="value"        select="@environment"/>
		<xsl:with-param name="class"        select="'prop-value-env'"/>
		<xsl:with-param name="label"        select="'Import Environment Variables'"/>
		<xsl:with-param name="explanation"  select="'Properties will be defined for every environment variable by prefixing the supplied name and a period to the name of the variable. Note that env properties are case sensitive.'"/>
		<xsl:with-param name="flags"        select="'NoValue'"/>
	    </xsl:call-template>
	    
	    <!-- Explain */property/@location -->
	    <xsl:call-template name="explain">
		<xsl:with-param name="value"        select="@location"/>
		<xsl:with-param name="class"        select="'prop-value-filename'"/>
		<xsl:with-param name="label"        select="'Canonical Filename: '"/>
		<xsl:with-param name="explanation"  select="'Sets the property to the absolute filename of the given file.'"/>
	    </xsl:call-template>
	    
	    <!-- Explain */property/@file -->
	    <xsl:call-template name="explain">
		<xsl:with-param name="value"        select="@file"/>
		<xsl:with-param name="class"        select="'prop-value-propfile'"/>
		<xsl:with-param name="label"        select="'File: '"/>
		<xsl:with-param name="explanation"  select="'Load a property file from filesystem.'"/>
	    </xsl:call-template>
	    
	    <!-- Explain */property/@url -->
	    <xsl:call-template name="explain">
		<xsl:with-param name="value"        select="@url"/>
		<xsl:with-param name="class"        select="'prop-value-propurl'"/>
		<xsl:with-param name="label"        select="'URL: '"/>
		<xsl:with-param name="explanation"  select="'Load a property file from URL.'"/>
	    </xsl:call-template>
	    
	    <!-- Explain */property/@resource -->
	    <xsl:call-template name="explain">
		<xsl:with-param name="value"        select="@resource"/>
		<xsl:with-param name="class"        select="'prop-value-propres'"/>
		<xsl:with-param name="label"        select="'Resource: '"/>
		<xsl:with-param name="explanation"  select="'Load a property file from classpath.'"/>
	    </xsl:call-template>
	    
	    <!-- Explain */property/@refid -->
	    <xsl:call-template name="explain">
		<xsl:with-param name="value"        select="@refid"/>
		<xsl:with-param name="class"        select="'prop-value-reference'"/>
		<xsl:with-param name="label"        select="'Ref: '"/>
		<xsl:with-param name="explanation"  select="'Reference to another property by ID.'"/>
		<xsl:with-param name="link-prefix"  select="'prop-'"/>
	    </xsl:call-template>
	    
	    <!-- Explain */property/@value -->
	    <xsl:call-template name="explain">
		<xsl:with-param name="value"        select="@value"/>
		<xsl:with-param name="class"        select="'prop-value-content'"/>
		<xsl:with-param name="explanation"  select="'The value of the property.'"/>
	    </xsl:call-template>
	</td>
	
	<!-- Property comments column -->
	<td class="prop-comment">
	    <xsl:value-of select="@description"/>
	</td>
    </xsl:element>
</xsl:template>

<xsl:template match="path|classpath" mode="table-IdPathComment">
    <xsl:element name="tr">
	<!-- copy the path ID if any-->
	<xsl:if test="@id">
	    <xsl:attribute name="id">path-<xsl:value-of select="@id"/></xsl:attribute>
	</xsl:if>
	<xsl:attribute name="class">path-entry</xsl:attribute>

	<td class="path-id">
	    <xsl:value-of select="@id"/>
	</td>
	<td class="path-value">
	    <xsl:if test="@path">
		<div>
		<xsl:call-template name="explain">
		    <xsl:with-param name="value" select="@path"/>
		    <xsl:with-param name="class" select="path-path"/>
		    <xsl:with-param name="explanation" select="'Specified using path::path attribute.'"/>
		</xsl:call-template>
		</div>
	    </xsl:if>
	    <xsl:if test="@location">
		<div>
		<xsl:call-template name="explain">
		    <xsl:with-param name="value" select="@location"/>
		    <xsl:with-param name="class" select="path-location"/>
		    <xsl:with-param name="explanation" select="'Specified using path::location attribute.'"/>
		</xsl:call-template>
		</div>
	    </xsl:if>	    
	    <xsl:for-each select="pathelement/@path">
		<div>
		<xsl:call-template name="explain">
		    <xsl:with-param name="value" select="."/>
		    <xsl:with-param name="class" select="pathelement-path"/>
		    <xsl:with-param name="explanation" select="'Specified using pathelement::path attribute.'"/>
		</xsl:call-template>
		</div>
	    </xsl:for-each>
	    <xsl:for-each select="pathelement/@location">
		<div>
		<xsl:call-template name="explain">
		    <xsl:with-param name="value" select="."/>
		    <xsl:with-param name="class" select="pathelement-location"/>
		    <xsl:with-param name="explanation" select="'Specified using pathelement::location attribute.'"/>
		</xsl:call-template>
		</div>
		<!--<div class="sub-path"><xsl:value-of select="."/></div>-->
	    </xsl:for-each>
	    <span class="todo">[dirset] [fileset] [filelist] </span>
	</td>
	<td class="path-comment">
            <xsl:value-of select="@description"/>
	</td>
    </xsl:element>
</xsl:template>

<xsl:template match="condition|available" mode="table-KindPropertyComment">
    <xsl:element name="tr">
	<!-- copy the path ID if any-->
	<xsl:if test="@id">
	    <xsl:attribute name="id">condprop-<xsl:value-of select="@id"/></xsl:attribute>
	</xsl:if>
	<xsl:attribute name="class">condprop-entry</xsl:attribute>
	<td class="kind"><xsl:value-of select="name()"/></td>
	<td class="property"><xsl:value-of select="@property"/></td>
	<td class="path-comment"><xsl:value-of select="@description"/></td>
    </xsl:element>
</xsl:template>

<xsl:template name="target-list-str">
    <xsl:param name="space-delimited-tasks"/>
    <xsl:variable name="leftover-tasks" select="substring-after($space-delimited-tasks, ' ')"/>

    <xsl:choose>
        <xsl:when test="string-length($leftover-tasks) > 0">
            <xsl:call-template name="target-link">
                <xsl:with-param name="target-name" select="substring-before($space-delimited-tasks, ' ')"/>
            </xsl:call-template>
            <xsl:call-template name="target-list-str">
                <xsl:with-param name="space-delimited-tasks" select="$leftover-tasks"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="target-link">
                <xsl:with-param name="target-name" select="$space-delimited-tasks"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!--
    Outputs a link to the target details.
    
    @param target-name is the name of the target.
-->
<xsl:template name="target-link">
    <xsl:param name="target-name"/>
    <xsl:for-each select="/project/target[@name=$target-name]">
        <!-- Add a class to default-target links -->
        <a href="#target-details-{@name}" title="{@description}">
           <xsl:if test="@name=$default-target">
               <xsl:element name="class">default-target</xsl:element>
           </xsl:if>
           <xsl:value-of select="@name"/>
        </a>
        <xsl:text> </xsl:text>
    </xsl:for-each>
</xsl:template>

<!--
    Output a summary of all properties nodes defined directly under the current node.
-->
<xsl:template name="declarations-summary">
    <xsl:if test="count(property) > 0">
        <div class="properties">
            <h3>Properties:</h3>
            <table>
            <thead>
            <tr>
                <th>Name</th>
                <th>Value</th>
                <th>Comment</th>
            </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="property" mode="table-NameValueDescr"/>
            </tbody>
            </table>
        </div>
    </xsl:if>    

    <xsl:if test="count(condition|available)>0">
        <div class="paths">
            <h3>Conditional Properties:</h3>
            <table>
            <thead>
            <tr>
                <th>Kind</th>
                <th>Property</th>
                <th>Comment</th>
            </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="condition|available" mode="table-KindPropertyComment"/>
            </tbody>
            </table>
        </div>
    </xsl:if>

    <xsl:if test="count(path)>0">
        <div class="paths">
            <h3>Paths:</h3>
            <table>
            <thead>
            <tr>
                <th>Id</th>
                <th>Path</th>
                <th>Comment</th>
            </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="path" mode="table-IdPathComment"/>
            </tbody>
            </table>
        </div>
    </xsl:if>

    <div class="todo">
	[import]     [antlib]
	[permisions] [propertyset]
	[taskdef]    [preset]      [xmlcatalog] 
	[fileset]    [filelist]    [dirset]   [zipfileset]
	[patternset] [mapper]      [selector]
	[filter]     [filterchain] [filterset]
	[BBcode in freetext]
    </div>
    
    <div class="wontdo">
    [assertion] 
    </div>
</xsl:template>


<!--
    Output a summary of a single node in the form:

    <span class="$class" title="$explanation">
        <em>$label</em>
        <code><a>$value</a></code>
    </span>.

    The <a> element's href attribute is generated if link-prefix, link-suffix or when the
    'Link' flag is specified. The URL is in the form '#<prefix><node-string-value><suffix>'.

    @param value is an XPath expression specifying the context node.
           If NULL set, the template doesn't produce any output.
    @param class is the css class of the element enclosing this templates's output.
    @param label is output before the value of the node.
           If the label is not specified, the label output is omitted.
    @param explanation long explanation of the node.
    @param link-prefix inserted before the node's string value to form the link URL.
    @param link-suffix inserted after the node's string value to form the link URL.
    @param flags string of misc. space separated tokens, which could be used
           to modify the behaviour of the template:
           #- NoValue - suppress the output of the value of the node.
           #- Link - generate link to node's string value (see link prefix and suffix).
-->
<xsl:template name="explain">
    <xsl:param name="value"/>
    <xsl:param name="class"/>
    <xsl:param name="label"/>
    <xsl:param name="explanation"/>
    <xsl:param name="link-prefix"/>
    <xsl:param name="link-suffix"/>
    <xsl:param name="flags"/> 

    <xsl:if test="$value">
        <span class="{$class}" title="{$explanation}">
            <xsl:if test="$label">
                <em><xsl:value-of select="$label"/></em>
            </xsl:if>

            <xsl:if test="not(contains($flags,'NoValue'))">
                <code>
                <xsl:choose>
                    <xsl:when test="boolean($link-prefix) or boolean($link-suffix) or contains($flags,'Link')">
                        <a title="{$explanation}" href="#{$link-prefix}{@refid}{$link-suffix}">
                            <xsl:value-of select="$value"/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$value"/>
                    </xsl:otherwise>
                </xsl:choose>
                </code>
            </xsl:if>
        </span>
    </xsl:if>
</xsl:template>
</xsl:stylesheet> 
