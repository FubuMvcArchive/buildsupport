namespace :docs do
	desc "Tries to run a documentation project hosted in FubuWorld"
	task :run do
		sh "buildsupport/FubuDocs/FubuDocsRunner.exe run"
	end

	desc "'Bottles' up a single project in the solution with 'Docs' in its name"
	task :bottle do
		sh "buildsupport/FubuDocs/FubuDocsRunner.exe bottle"
	end

	desc "Gathers up code snippets from the solution into the Docs project"
	task :snippets do
		sh "buildsupport/FubuDocs/FubuDocsRunner.exe snippets"
	end
	
	desc "Rebuilds the topic tree for the Docs project from the Topics.Xml file, filling in any missing pieces"
	task :topics do
		sh "buildsupport/FubuDocs/FubuDocsRunner.exe build-topics"
	end
end
