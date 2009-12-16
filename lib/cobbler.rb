# The directory where Shoes lives
DIR = "/usr/local/lib/shoes/"

# Shoes downloads temp stuff to this location
require 'tmpdir'
LIB_DIR = Dir.tmpdir

# Add Shoes' dir to the load path so that Pack's requires work
$LOAD_PATH << File.join( DIR, "lib" )

require 'cobbler/pack'

class Cobbler
  VERSION = '1.1.0'

  def self.pack opts={}
    puts "pack called with opts: #{opts.inspect}"

    path = opts[:path]

    shy_path = if File.directory? path
      path.gsub(%r![\\/]+$!, '') + ".shy"
    else
      path.gsub(/\.\w+$/, '') + ".shy"
    end

    puts "shy_path: #{shy_path}"

    shy_meta = Shy.new
    shy_meta.name     = opts[:name]     || "shoes_app"
    shy_meta.creator  = opts[:creator]  || "Anonymous Coward"
    shy_meta.version  = opts[:version]  || "0.0.0"
    shy_meta.launch   = opts[:launch]   || path

    puts "shy_meta: #{shy_meta.inspect}"

    blk           = opts[:progress]   || proc {|*frac| } # noop
    platforms     = opts[:platforms]  || [ :shy, :exe, :run, :dmg ]
    include_shoes = opts[:include_shoes]

    Shy.c(shy_path, shy_meta, path, &blk)

    platforms.each do |platform|
      case platform
        when :exe
          puts "Working on an .exe for Windows."
          Shoes::Pack.exe( shy_path, include_shoes, &blk )
        when :dmg
          puts "Working on a .dmg for Mac OS X."
          Shoes::Pack.dmg( shy_path, include_shoes, &blk )
        when :run
          puts "Working on a .run for Linux."
          Shoes::Pack.linux( shy_path, include_shoes, &blk )
      end
    end

    unless platforms.include? :shy
      FileUtils.rm_rf( shy_path )
    end
  end
end
