namespace :nuget do
  buildsupport_path = File.dirname(__FILE__)
  nuget = "#{buildsupport_path}/nuget.exe"
  nugroot = File.expand_path("/nugs")
  
  desc "Build the nuget package"
  task :build do
    rm Dir.glob("#{ARTIFACTS}/*.nupkg")
    FileList["packaging/nuget/*.nuspec"].each do |spec|
      sh "#{nuget} pack #{spec} -o #{ARTIFACTS} -Version #{BUILD_NUMBER} -Symbols"
    end
  end
  
  desc "update dependencies from local machine"
  task :pull, [:package] do |task, args|
    FileList[File.join(package_root, "*")].exclude{|f| File.file?(f)}.each do |package|
      next if args[:package] && package_name(package).downcase != args[:package].downcase
      dst = File.join package, "lib"
      src = File.join nugroot, package_name(package), "lib"
      if File.directory? src
        clean_dir dst
        cp_r src + "/.", dst, :verbose => false
        puts "pulled from #{src}"
        after_nuget_update(package_name(package), dst) if respond_to? :after_nuget_update
      end
    end
  end

  desc "Updates dependencies from nuget.org"
  task :update do
    FileList["**/packages.config"].each do |proj|
      sh "#{nuget} update #{proj}"
      sh "#{nuget} install #{proj}"
    end
  end

  desc "pushes dependencies to central location on local machine for nuget:pull from other repos"
  task :push, [:package] => :build do |task, args|
    FileList["#{ARTIFACTS}/*.nupkg"].exclude(".symbols.nupkg").each do |file|
      next if args[:package] && package_name(file).downcase != args[:package].downcase
      destination = File.join nugroot, package_name(file)
      clean_dir destination
      unzip_file file, destination
      puts "pushed to #{destination}"
    end
  end

  def package_root
    root = nil
    ["src", "source"].each do |d|
      packroot = File.join d, "packages"
      root = packroot if File.directory? packroot
    end
    raise "No NuGet package root found" unless root
    root
  end

  def package_name(filename)
    File.basename(filename, ".nupkg").gsub(/[\d.]+$/, "")
  end

  def clean_dir(path)
    mkdir_p path, :verbose => false
    rm_r Dir.glob(File.join(path, "*.*")), :verbose => false
  end
		
  def unzip_file (file, destination)
    require 'rubygems'
    require 'zip/zip'
    Zip::ZipFile.open(file) { |zip_file|
     zip_file.each { |f|
       f_path=File.join(destination, f.name)
       FileUtils.mkdir_p(File.dirname(f_path))
       zip_file.extract(f, f_path) unless File.exist?(f_path)
     }
    }
  end
	
  desc "Pushes nuget packages to the official feed"
  task :release, [:package] do |t, args|
    require 'open-uri'
    release_path = "#{buildsupport_path}/nuget_release"
    clean_dir release_path

    artifact_url = "http://teamcity.codebetter.com/guestAuth/repository/downloadAll/#{@teamcity_build_id}/.lastSuccessful/artifacts.zip"
    puts "downloading artifacts from teamcity.codebetter.com"
    artifact = open(artifact_url)
    unzip_file artifact.path, release_path
    FileList["#{release_path}/*.nupkg"].exclude(".symbols.nupkg").each do |nupkg|
      next if args[:package] && package_name(nupkg).downcase != args[:package].downcase
      sh "#{nuget} push #{nupkg}" do |ok, res|
        puts "May not have published #{nupkg}" unless ok
      end
    end
  end	
end

def package_tool(package, tool)
  File.join(Dir.glob("src/packages/#{package}.*").sort.last, "tools", tool)
end