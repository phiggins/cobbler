# The directory where Shoes lives
DIR = "/usr/local/lib/shoes/"

# Shoes downloads temp stuff to this location
require 'tmpdir'
LIB_DIR = Dir.tmpdir

# Add Shoes code to the load path so that Pack's requires work
$: << File.join( DIR, "lib" )

#require File.join( File.dirname(__FILE__), 'cobbler/pack' )
require 'cobbler/pack'

class Cobbler
  VERSION = '1.0.0'

  def self.pack opts={}
    Shoes::Pack.pack opts
  end
end
