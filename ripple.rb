
	desc "Restores nuget package files"
	task :restore do
	  puts 'Restoring all the nuget package files'
	  sh 'buildsupport/ripple.exe restore'
	end
	
	desc "Updates nuget package files to the latest"
	task :update do
	  puts 'Updating all the nuget package files'
	  sh 'buildsupport/ripple.exe update'
	end

	desc "For CI mode, replaces all dependencies with the latest, greatest version of all"
	task :update_all_depencencies do
	  sh 'ripple clean'
	  sh 'ripple update'
	  sh 'ripple restore'
	end
	
	desc "restore packages if the files don't seem to exist"
	task :restore_if_missing do
	  packageFiles = Dir["#{File.dirname(__FILE__)}/src/packages/*.dll"]
	  sh 'ripple restore' unless packageFiles.any?
	end
	
	desc "creates a history file for nuget dependencies"
	task :history do
	  sh 'ripple history'
	end
	
	desc "publishes all the nuget's published by this solution"
	task :publish do
	  nuget_api_key = ENV['apikey']
	  sh 'ripple publish #{BUILD_NUMBER} #{nuget_api_key}'
	end