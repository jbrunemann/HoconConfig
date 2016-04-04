<cfcomponent output="false">
	<cffunction name="init" returntype="any">
		<cfset variables.registry = "http://repo1.maven.org/maven2/">
		<cfset variables.type = "maven">
		<cfset variables.saveDir = getTempDirectory()>
	</cffunction>

	<cffunction name="install" returntype="any">
		<cfargument name="artifactId" type="string" required="true" />
		<cfargument name="version" type="string" required="true" />
		<cfargument name="groupId" type="string" required="true" />

		<cfset var httpResults = {}>
		<cfset var fileName = getFileName(argumentCollection=arguments)>
		<cfset var path = getPath(argumentCollection=arguments)>
		<cfset var targetUrl = variables.registry & path & fileName>
		<cfset var fileOnDisk = variables.saveDir & arguments.groupId & "." & fileName>

		<cfif not fileExists(fileOnDisk)>
			<cfhttp url="#targetUrl#" throwonerror="false" timeout="60" getasbinary="true" result="httpResults">
			</cfhttp>

			<cfif httpResults.responseheader.status_code eq "200">
				<cfset fileWrite(fileOnDisk, httpResults.fileContent)>
			<cfelse>
				<cfthrow message="Download failed!" />
			</cfif>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="new" returntype="any">
		<cfargument name="className" type="string" required="true" />

		<cfset var jars = directoryList(variables.saveDir, false, "path", "*.jar", "")>

		<cfset var targetObject = createObject("java", arguments.classname, arrayToList(jars))>
		<cfreturn targetObject>
	</cffunction>

	<cffunction name="getPath" returntype="string">
		<cfargument name="artifactId" type="string" required="true" />
		<cfargument name="version" type="string" required="true" />
		<cfargument name="groupId" type="string" required="true" />
	
		<cfreturn replaceNoCase(arguments.groupId, ".", "/", "ALL") & "/" & arguments.artifactId & "/" & arguments.version & "/">
	</cffunction>

	<cffunction name="getFileName" returntype="string">
		<cfargument name="artifactId" type="string" required="true" />
		<cfargument name="version" type="string" required="true" />
	
		<cfreturn arguments.artifactId & "-" & arguments.version & ".jar">
	</cffunction>
</cfcomponent>