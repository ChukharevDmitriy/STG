<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsd="http://www.w3.org/2001/XMLSchema" version="1.0">
<xsl:output indent="yes" method="html" omit-xml-declaration="yes" />

	<xsl:template match="/xsd:schema">
		<html>
			<head>
				<title><xsl:value-of select="xsd:schema/@targetNamespace"/></title>
				<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous"/>
				<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"/>
				<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/default.min.css"/>
				<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
				<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/xml.min.js"></script>
				<script>hljs.highlightAll();</script>
			</head>
			<body>
				<div class="container">
					<h1><xsl:value-of select="./@targetNamespace"/></h1>
					<h4><span class="text-muted"><xsl:value-of select="./@version"/></span></h4>
					<p><xsl:value-of select="./xsd:annotation/xsd:documentation"/></p>
					<xsl:apply-templates/>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="xsd:annotation"/>

	<xsl:template match="xsd:import">
		<h2>Import</h2>
		<a>
			<xsl:attribute name="href">
				<xsl:value-of select="@schemaLocation"/>
			</xsl:attribute>
			<xsl:value-of select="@namespace"/>
		</a>
		<p><xsl:value-of select="xsd:annotation/xsd:documentation" /></p>
	</xsl:template>

	<xsl:template match="xsd:element">
		<xsl:call-template name="opening">
			<xsl:with-param name="type">element</xsl:with-param>
			<xsl:with-param name="pref">e</xsl:with-param>
		</xsl:call-template>
		<blockquote>
			<xsl:text>Type: </xsl:text>
			<a>
				<xsl:attribute name="href">
					#ct-<xsl:value-of select="substring-after(@type, ':')"/>
				</xsl:attribute>
				<xsl:value-of select="@type"/>
			</a>
		</blockquote>
		<xsl:call-template name="source"/>
	</xsl:template>

	<xsl:template match="xsd:simpleType">
		<xsl:call-template name="opening">
			<xsl:with-param name="type">simple type</xsl:with-param>
			<xsl:with-param name="pref">st</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="source"/>
	</xsl:template>

	<xsl:template match="xsd:group">
		<xsl:call-template name="opening">
			<xsl:with-param name="type">group</xsl:with-param>
			<xsl:with-param name="pref">g</xsl:with-param>
		</xsl:call-template>
		<xsl:for-each select="xsd:all|xsd:sequence|xsd:choice">
			<xsl:call-template name="elements"/>
		</xsl:for-each>
		<xsl:call-template name="source"/>
	</xsl:template>

	<xsl:template match="xsd:complexType">
		<xsl:call-template name="opening">
			<xsl:with-param name="type">complex type</xsl:with-param>
			<xsl:with-param name="pref">ct</xsl:with-param>
		</xsl:call-template>
		<xsl:choose>
			<xsl:when test="xsd:complexContent">
				<xsl:for-each select="xsd:complexContent/xsd:extension | xsd:complexContent/xsd:restriction">
					<blockquote>
						<xsl:text>Extends: </xsl:text>
						<a>
							<xsl:attribute name="href">
								#ct-<xsl:value-of select="substring-after(@base, ':')"/>
							</xsl:attribute>
							<xsl:value-of select="@base"/>
						</a>
					</blockquote>
					<xsl:call-template name="complex-content"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="complex-content"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="source"/>
	</xsl:template>

	<xsl:template match="xsd:attributeGroup">
		<xsl:call-template name="opening">
			<xsl:with-param name="type">attribute group</xsl:with-param>
			<xsl:with-param name="pref">ag</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="attributes"/>
		<xsl:call-template name="source"/>
	</xsl:template>


	<!-- Content -->

	<xsl:template name="opening">
		<xsl:param name="type"/>
		<xsl:param name="pref"/>
		<h2 class="mb-0 mt-4">
			<xsl:attribute name="id">
				<xsl:value-of select="$pref"/>-<xsl:value-of select="@name"/>
			</xsl:attribute>
			<xsl:value-of select="@name"/>
		</h2>
		<h6><span class="text-muted"><xsl:value-of select="$type"/></span></h6>
		<hr/>
		<p><xsl:value-of select="xsd:annotation/xsd:documentation" /></p>
	</xsl:template>


	<xsl:template name="complex-content">
		<xsl:for-each select="xsd:all|xsd:sequence|xsd:choice">
			<xsl:call-template name="elements"/>
		</xsl:for-each>
		<xsl:call-template name="attributes"/>
		<xsl:if test="xsd:attributeGroup">
			<h4>Attribute groups</h4>
			<ul>
				<xsl:for-each select="xsd:attributeGroup">
					<li><a>
						<xsl:attribute name="href">
							#ag-<xsl:value-of select="substring-after(@ref, ':')"/>
						</xsl:attribute>
						<xsl:value-of select="@ref"/>
					</a></li>
				</xsl:for-each>
			</ul>
		</xsl:if>
	</xsl:template>

	<xsl:template name="attributes">
		<xsl:if test="xsd:attribute">
			<h4>Attributes</h4>
			<table class="table table-striped table-bordered table-hover">
				<tr>
					<th>Name</th>
					<th>Type</th>
					<th>Use</th>
					<th>Description</th>
				</tr>
				<xsl:for-each select="xsd:attribute">
					<tr>
						<td><xsl:value-of select="@name"/></td>
						<td><xsl:value-of select="@type"/></td>
						<td><xsl:value-of select="@use"/></td>
						<td><xsl:value-of select="xsd:annotation/xsd:documentation"/></td>
					</tr>
				</xsl:for-each>
			</table>
		</xsl:if>
	</xsl:template>

	<xsl:template name="elements">
		<xsl:param name="title" select="'Elements'"/>
		<xsl:choose>
			<xsl:when test="child::xsd:*">
				<h4><xsl:value-of select="$title"/></h4>
				<table class="table table-striped table-bordered table-hover">
					<tr>
						<th>Name</th>
						<th>Type</th>
						<th>Cardinality</th>
						<th>Description</th>
					</tr>

					<xsl:for-each select="xsd:*">
						<xsl:if test="local-name() = 'element'">
							<tr>
								<td><xsl:value-of select="@name" /></td>
								<td><xsl:value-of select="@type" /></td>
								<td>
									<xsl:choose>
										<xsl:when test="@minOccurs"><xsl:value-of select="@minOccurs" /></xsl:when>
										<xsl:otherwise>1</xsl:otherwise>
									</xsl:choose>
									..
									<xsl:choose>
										<xsl:when test="@maxOccurs"><xsl:value-of select="@maxOccurs" /></xsl:when>
										<xsl:otherwise>1</xsl:otherwise>
									</xsl:choose>
								</td>
								<td>
									<xsl:value-of select="xsd:annotation/xsd:documentation" />
								</td>
							</tr>
						</xsl:if>
						<xsl:if test="local-name() = 'group'">
							<tr>
								<td colspan="4">
									Group:
									<a>
										<xsl:attribute name="href">
											#g-<xsl:value-of select="substring-after(@ref, ':')"/>
										</xsl:attribute>
										<xsl:value-of select="@ref"/>
									</a>
								</td>
							</tr>
						</xsl:if>
						<xsl:if test="local-name() = 'choice' or local-name() = 'sequence' or local-name() = 'all'">
							<tr>
								<td colspan="4">
									<xsl:call-template name="elements">
										<xsl:with-param name="title"><xsl:value-of select="local-name()"/></xsl:with-param>
									</xsl:call-template>
								</td>
							</tr>
						</xsl:if>
					</xsl:for-each>
				</table>
			</xsl:when>
			<xsl:otherwise><blockquote>No child elements</blockquote></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="source">
		<details>
			<summary class="text-muted">source</summary>
			<pre><code class="language-xml"><xsl:call-template name="serialize"/></code></pre>
		</details>
	</xsl:template>

	<xsl:template name="serialize">
		<xsl:param name="offs" select="''"/>
		<xsl:value-of select="$offs"/><xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/>
		<xsl:for-each select="attribute::*">
			<xsl:text> </xsl:text><xsl:value-of select="name()"/><xsl:text>="</xsl:text><xsl:value-of select="."/><xsl:text>"</xsl:text>
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="child::*">
				<xsl:text>&gt;</xsl:text>
				<xsl:for-each select="child::*">
					<xsl:text>&#xA;</xsl:text>
					<xsl:call-template name="serialize">
						<xsl:with-param name="offs"><xsl:value-of select="concat($offs, '    ')"/></xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
				<xsl:text>&#xA;</xsl:text><xsl:value-of select="$offs"/><xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
			</xsl:when>
			<xsl:when test="text() != ''">
				<xsl:text>&gt;</xsl:text><xsl:value-of select="text()"/><xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise><xsl:text>/&gt;</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>