namespace :docs do
	desc "Tries to run a documentation project hosted in FubuWorld"
	task :run do
		fubudocs "run -o"
	end
	
	desc "Tries to run the documentation projects in this solution in a 'watched' mode in Firefox"
	task :run_firefox do
		fubudocs "run --watched --browser Firefox"
	end
	
	desc "Tries to run the documentation projects in this solution in a 'watched' mode in Firefox"
	task :run_chrome do
		fubudocs "run --watched --browser Chrome"
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
  fubudocs = File.dirname(File.expand_path(__FILE__)) + '/FubuDocsRunner.exe'
  
  sh "#{fubudocs} #{args}"
end
