
	desc "Restores nuget package files"
	task :restore do
	  puts 'Restoring all the nuget package files'
	  ripple 'restore'
	end
	
	desc "Updates nuget package files to the latest"
	task :update do
	  puts 'Updating all the nuget package files'
	  ripple 'update'
	end

	desc "For CI mode, replaces all dependencies with the latest, greatest version of all"
	task :update_all_dependencies do
	  ripple 'clean'
	  ripple 'update'
	  ripple 'restore'
	end
	
	desc "restore packages if the files don't seem to exist"
	task :restore_if_missing do
	  packageFiles = Dir["#{File.dirname(__FILE__)}/src/packages/*.dll"]
	  ripple 'restore' unless packageFiles.any?
	end
	
	desc "creates a history file for nuget dependencies"
	task :history do
	  ripple 'history'
	end
	
	desc "publishes all the nuget's published by this solution"
	task :publish do
	  nuget_api_key = ENV['apikey']
	  ripple "publish #{BUILD_NUMBER} #{nuget_api_key}"
	end

  def self.ripple(args)
    ripple = Platform.runtime("buildsupport/ripple.exe") 
    sh "#{ripple} #{args}"
  end
