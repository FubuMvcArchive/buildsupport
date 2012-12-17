namespace :docs do
	desc "Tries to run a documentation project hosted in FubuWorld"
	task :run do
		fubudocs "run"
	end

	desc "'Bottles' up a single project in the solution with 'Docs' in its name"
	task :bottle do
		fubudocs "bottle"
	end

	desc "Gathers up code snippets from the solution into the Docs project"
	task :snippets do
		fubudocs "snippets"
	end
	
	desc "Rebuilds the topic tree for the Docs project from the Topics.Xml file, filling in any missing pieces"
	task :topics do
		fubudocs "build-topics"
	end
end

def self.fubudocs(args)
  fubudocs = Platform.runtime(Nuget.tool("FubuDocs", "FubuDocsRunner.exe"))
  sh "#{fubudocs} #{args}"
end
