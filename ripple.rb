
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

