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
end

def self.fubudocs(args)
  fubudocs = 'buildsupport/FubuDocsRunner.exe'
  sh "#{fubudocs} #{args}"
end
