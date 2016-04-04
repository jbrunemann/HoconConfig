component 
{
	public Config function init(required string confDir, boolean provided)
	{
		var confDir = arguments.confDir;

		var default = createObject("java", "java.io.File").init(confDir & "default.conf");
		var overrides = createObject("java", "java.io.File").init(confDir & "overrides.conf");

		if (not structKeyExists(arguments, "provided") or not arguments.provided) {
			var configFactory = new PackageDownloader()
				.install("config", "1.2.1", "com.typesafe")
				.new("com.typesafe.config.ConfigFactory");
 		} else {
			try {
				var configFactory = createObject("java", "com.typesafe.config.ConfigFactory");
			} catch (lucee.commons.lang.ClassException cfcatch) {
				throw(message="Failed to load! Are you sure you provided the jar yourself?");
			}
		}
		
		configFactory.invalidateCaches();

		var config = ConfigFactory.parseFile(overrides)
			.withFallBack(ConfigFactory.parseFile(default))
			.withFallBack(ConfigFactory.parseString("application{}"));

		// Converts HashMap to Struct
		var config_struct = structNew();
		structAppend(config_struct, config.getObject("application").unwrapped());

		structInsert(variables, "config", config_struct);
		structInsert(variables, "configObject", config);

		return this;
	}

	public struct function get()
	{
		return variables.config;
	}

	public any function getObject()
	{
		return variables.configObject;
	}

	public void function dump() output="true"
	{
		writeOutput("<pre>" & variables.configObject.root().render() & "</pre>");
	}	
}