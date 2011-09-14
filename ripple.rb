
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