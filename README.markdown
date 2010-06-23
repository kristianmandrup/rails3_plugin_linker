# Rails 3 plugin linker

This task helps download plugins from github and link to these plugins from a Rails 3 app to facilitate development and debugging while maintaining each plugin separately and allow reuse in multiple applications. This is a simpler (and perhaps better?) alternative to using git submodules.
  
## Install

<code>gem install rails3_plugin_linker</code>

## Usage

Must be run from the root of a Rails 3 application.

+Display usage instructions+  

<code>rails3_plugin_linker --help</code> 

*Note: Ignore the double rails3_plugin_linker after usage: (which is currently an "error" in Thor)*

## Usage examples

+Use defaults+

<code>$ rails3_plugin_linker --namespace netzke</code>

Clones plugins from default github account in <code>~/rails3-plugins/netzke</code>

+Clone plugins from specific github account+

<code>$ rails3_plugin_linker --account kmandrup</code>

Clones plugins from 'kmandrup' github account in <code>~/rails3-plugins</code>

+Specify location of where to store plugins+

<code>$ rails3_plugin_linker ../my/place --namespace netzke</code>

Retrieves and places plugins in <code>../my/place/netzke</code>.

+Force overwrite of local plugins by newly retrieved remote plugins. Also forces overwrite of all symbolic links+

<code>$ rails3_plugin_linker --force-all</code>

+Detailed specifications of each module to include as plugin+

<code>$ rails3_plugin_linker --namespace netzke --modules neztke_ar:master@skozlov,netzke_core:rails3@kmandrup</code>

+Using config file for default modules specifications+
     
*~/rails3-plugins/netzke/plugins.config* (default config file)
<pre>
netzke_core:rails3@kmandrup
</pre>

<code>$ rails3_plugin_linker --modules neztke_ar:master@skozlov</code>

+Specifying custom config file for default modules specifications+
     
*~/configurations/modules.config* (default config file)
<pre>
netzke-core:rails3@kmandrup, neztke-basepack:rails3@skozlov 
</pre>

Modules specs in the modules option always override those found in the config file

<code>$ rails3_plugin_linker --modules neztke_ar:master@skozlov,neztke-basepack:rails3@kmandrup --config-file ~/configurations/modules.config</code>

## Copyright

Copyright (c) 2009 Kristian Mandrup

