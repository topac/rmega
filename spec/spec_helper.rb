require 'pry'

def libpath
  File.expand_path File.join(File.dirname(__FILE__), '../lib')
end

def require_all
  $: << libpath
  require 'rmega'
end

require_all