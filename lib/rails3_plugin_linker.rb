require 'active_support/inflector'
require 'thor'
require 'thor/group'

class NilClass
  def empty?
    true
  end
end

class NetzkeConfig < Thor::Group
  include Thor::Actions

  # group used when displaying thor tasks with: thor list or thor -T
  # group :netzke

  # Define arguments 
  argument :location, :type => :string, :default => '~/rails-plugins', :desc => 'Location where modules are to be stored (locally)' 

  class_option :force_all, :type => :boolean, :default => false, :desc => 'Force force of all files, including existing modules and links'
  class_option :force_links, :type => :boolean, :default => true, :desc => 'Force force of symbolic links' 
  class_option :download, :type => :boolean, :default => false, :desc => 'Download ExtJS if not found in specified extjs location'

  class_option :namespace, :type => :string, :desc => 'Namespace for plugins and configuration files (container folder)'
  class_option :modules, :type => :string, :desc => 'Module specifications for each module, fx neztke_ar:master@skozlov,netzke_core:rails3@kmandrup'

  class_option :config_file_dir, :default => '~/rails-plugins/config', :type => :string, :desc => 'Container folder for rails-plugin configuration files' 
  class_option :config_file, :default => 'plugins.config', :type => :string, :desc => 'Name of rails-plugin configuration file' 

  GITHUB = 'http://github.com'

  def main  
    load_config_file
    setup_defaults
    define_modules
    exit(-1) if !valid_context?
    configure_modules
  end   

  protected
  attr_accessor :modules_config, :module_specifications

  def load_config_file     
    @default_module_specs = ""   
       
    config_file.gsub! /^~/, ENV['HOME']
    
    file_name = File.join(config_file_dir, namespace, config_file
    
    if File.exists?(file_name)
      @default_module_specs = File.open(file_name).read 
    else
      say "module config file at #{file_name} not found"
    end
  end

  def setup_defaults       
    @modules_config ||= {} 
    all_modules = []
    all_modules << modules if modules?
    @module_specifications = all_modules.join(',') || ""
  end

  def define_modules
    @modules_config ||= {}
    return if module_specifications.empty?    
    module_defs = module_specifications.split(",")
    module_defs.each do |module_spec|
      module_spec = module_spec.strip
      if module_spec && !module_spec.empty?
        spec = module_spec.strip.split(":")
        module_name = spec[0]
        if spec[1]
          branch, account = spec[1].split("@")            
        else
          branch, account = spec[0].split("@") if spec[0]
          branch, account = "", "" if !spec[0]
        end
        set_module_config module_name.to_sym, :branch => branch, :account => account
      end
    end
  end

  def set_module_config name, module_options = {}
    mconfig = modules_config[name.to_sym] = {}
    mconfig[:branch]  = module_options[:branch]
    mconfig[:account] = module_options[:account]
  end

  def module_config name 
    modules_config[name.to_sym]
  end
  
  def valid_context?
    if !rails3_app?
      say "Must be run from a rails 3 application root directory", :red      
      return false
    end      
    true
  end

  def get_module_names
    modules_config.keys.map{|k| k.to_s}    
  end
  
  def configure_modules  
    create_module_container_dir  
    inside "#{plugin_location}" do
      get_module_names.each do |module_name|
        get_module module_name
        config_plugin module_name
      end        
    end
  end

  def create_module_container_dir
    if File.directory?(plugin_location)
      run "rm -rf #{plugin_location}" if force_all?
    end
    empty_directory "#{plugin_location}" if !File.directory?(location)
  end


  def get_module module_name   
    run "rm -rf #{module_name}" if force_all?
    if File.directory? module_name
      update_module module_name
    else
      create_module module_name
    end
  end

  def update_module module_name 
    config = module_config(module_name)          
    return if !config
    inside module_name do      
      branch = config[:branch] 
      run "git checkout #{branch}"
      run "git rebase origin/#{branch}" 
      run "git pull" 
    end
  end
    
  def create_module module_name
    # create dir for module by cloning  
    config = module_config(module_name)    
    return if !config    
    account = config[:account]    
    run "git clone #{github account}/#{module_name}.git #{module_name}" 
    inside module_name do   
      branch = config[:branch]      
      run "git checkout #{branch}"
    end
  end

  def config_plugin module_name
    inside 'vendor/plugins' do
      module_src = local_module_src(module_name) 
      run "rm -f #{module_name}" if force_links?
      run "ln -s #{module_src} #{module_name}"
    end
  end

  private

  def plugin_location             
    @plugin_location ||= if !namespace
      location 
    else
      "#{namespace}/#{location}"
    end
  end

  def config_file_dir 
    options[:config_file_dir]
  end
  
  
  def config_file 
    options[:config_file] 
  end

  def modules?
    modules    
  end

  def modules
    options[:modules]
  end

  def namespace
    options[:namespace]
  end
    
  def force_all?
    options[:force_all]
  end    

  def force_links?
    options[:force_links]
  end    

  def github account
    "#{GITHUB}/#{account}"
  end  

  def rails3_app?
    File.exist? 'Gemfile'
  end

  def local_module_src module_name
    "#{options[:location]}/#{module_name}"
  end
  
end
                  
