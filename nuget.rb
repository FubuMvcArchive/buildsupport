namespace :nuget do
  buildsupport_path = File.dirname(__FILE__)
  nuget = "#{buildsupport_path}/nuget.exe"
  nugroot = File.expand_path(ENV['NUGET_HUB'] || "/nugs")
  
  task :ripple => [:ci, :push]
  
  desc "Build the nuget package"
  task :build do
    rm Dir.glob("#{ARTIFACTS}/*.nupkg")
    FileList["packaging/nuget/*.nuspec"].each do |spec|
      sh "#{nuget} pack #{spec} -o #{ARTIFACTS} -Version #{BUILD_NUMBER} -Symbols"
    end
  end
  
  desc "update dependencies from local machine"
  task :pull, [:package] do |task, args|
    Nuget.each_installed_package do |package|
      next if args[:package] && Nuget.package_name(package).downcase != args[:package].downcase
      src_package = File.join nugroot, Nuget.package_name(package)
      if File.directory? src_package
        ['lib','tools'].each do |folder|
          dst = File.join package, folder 
          src = File.join src_package, folder 
          if File.directory? src
            clean_dir dst
            cp_r src + "/.", dst, :verbose => false
            after_nuget_update(Nuget.package_name(package), dst) if respond_to? :after_nuget_update
          end
        end
        puts "pulled from #{src_package}"
      else
        puts "could not find #{src_package}"
      end
    end
  end

  desc "Updates dependencies from nuget.org"
  task :update => [:update_packages, :clean]

  task :update_packages do
    FileList["**/*.sln"].each do |proj|
      sh "#{nuget} update #{proj}"
    end
    FileList["**/packages.config"].each do |proj|
      sh "#{nuget} install #{proj} -OutputDirectory #{Nuget.package_root}"
    end
  end

  desc "pushes dependencies to central location on local machine for nuget:pull from other repos"
  task :push, [:package] => :build do |task, args|
    FileList["#{ARTIFACTS}/*.nupkg"].exclude(".symbols.nupkg").each do |file|
      next if args[:package] && Nuget.package_name(file).downcase != args[:package].downcase
      destination = File.join nugroot, Nuget.package_name(file)
      clean_dir destination
      unzip_file file, destination
      puts "pushed to #{destination}"
    end
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
      next if args[:package] && Nuget.package_name(nupkg).downcase != args[:package].downcase
      sh "#{nuget} push #{nupkg}" do |ok, res|
        puts "May not have published #{nupkg}" unless ok
      end
    end
  end	

  task :clean do
    require 'rexml/document'
    repo_paths = Nuget.repositories
    packages = repo_paths.map{|repo| Nuget.packages(repo)}.reduce(:|)

    Nuget.each_installed_package do |package|
      name = Nuget.package_name(package)
      tracked = packages.select{|p| p.include? name} 
      if tracked.any? # only remove folders for older versions of tracked packages
        should_delete = !tracked.detect{|t| package.end_with? t[name]}
        rm_rf package if should_delete
      end
    end

  end
end

module Nuget
  def self.each_installed_package
    FileList[File.join(package_root, "*")].exclude{|f| File.file?(f)}.each do |package|
      yield package
    end
  end

  def self.repositories
    repo_file_path = File.join package_root, "repositories.config"
    file = REXML::Document.new File.read repo_file_path
    file.get_elements("repositories/repository").map{|node| File.expand_path(File.join(package_root, node.attributes["path"]))}
  end

  def self.packages(package_config)
    xml = REXML::Document.new File.read package_config
    xml.get_elements('packages/package').map do |p|
      { p.attributes['id'] => p.attributes['version'] } 
    end
  end

  def self.package_root
    root = nil
    ["src", "source"].each do |d|
      packroot = File.join d, "packages"
      root = packroot if File.directory? packroot
    end
    raise "No NuGet package root found" unless root
    root
  end

  def self.package_name(filename)
    File.basename(filename, ".nupkg").gsub(/[\d.]+$/, "")
  end

  def self.tool(package, tool)
    File.join(Dir.glob(File.join(package_root,"#{package}.*")).sort.last, "tools", tool)
  end
end
