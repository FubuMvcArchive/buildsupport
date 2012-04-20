 desc "Update buildsupport submodule"
 task :update_buildsupport do
  #Go update the buildsupport submodule so it's always current.
  Dir.chdir("buildsupport") do
    puts "*** Updating buildsupport..."
    sh 'git fetch'
    sh 'git checkout master'
    sh 'git rebase origin/master'
    puts "*** Buildsupport updated."
	end
 end