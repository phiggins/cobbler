require 'shoes/shy'
require 'binject'
require 'open-uri'

class Shoes
  module Pack
    def self.debug *args
      puts args
    end

    def self.error *args
      $stderr.puts *args
    end

    def self.rewrite a, before, hsh
      File.open(before) do |b|
        b.each do |line|
          a << line.gsub(/\#\{(\w+)\}/) { hsh[$1] }
        end
      end
    end

    def self.pkg(platform, opt)
      url = case opt        
        when :yes, true then
          "http://shoes.heroku.com/pkg/raisins/#{platform}/shoes"
        when :novideo then
          "http://shoes.heroku.com/pkg/raisins/#{platform}/shoes-novideo"
      end

      debug "Getting shoes url from #{url}" if url

      if url
        url = open(url).read.strip
        debug "Downloading shoes from #{url}"
        save = File.join(LIB_DIR, File.basename(url))
        File.exists?(save) ? open(save) : open(url)
      end
    end

    def self.exe(script, opt, &blk)
      size = File.size(script)
      f = File.open(script)
      exe = Binject::EXE.new(File.join(DIR, "static", "stubs", "blank.exe"))
      size += script.length
      exe.inject("SHOES_FILENAME", File.basename(script))
      size += File.size(script)
      exe.inject("SHOES_PAYLOAD", f)
      f2 = pkg("win32", opt)
      if f2
        size += File.size(f2.path)
        f3 = File.open(f2.path, 'rb')
        exe.inject("SHOES_SETUP", f3)
      end

      count, last = 0, 0.0
      exe.save(script.gsub(/\.\w+$/, '') + ".exe") do |len|
        count += len
        prg = count.to_f / size.to_f
        blk[last = prg] if blk and prg - last > 0.02 and prg < 1.0
      end

      f.close
      if f2
        f2.close
        f3.close
      end
      blk[1.0] if blk
    end

    def self.dmg(script, opt, &blk)
      name = File.basename(script).gsub(/\.\w+$/, '')
      app_name = name.capitalize.gsub(/[-_](\w)/) { $1.capitalize }
      vol_name = name.capitalize.gsub(/[-_](\w)/) { " " + $1.capitalize }
      app_app = "#{app_name}.app"
      vers = [1, 0]

      tmp_dir = File.join(LIB_DIR, "+dmg")
      FileUtils.rm_rf(tmp_dir)
      FileUtils.mkdir_p(tmp_dir)
      FileUtils.cp(File.join(DIR, "static", "stubs", "blank.hfz"),
                   File.join(tmp_dir, "blank.hfz"))
      app_dir = File.join(tmp_dir, app_app)
      res_dir = File.join(tmp_dir, app_app, "Contents", "Resources")
      mac_dir = File.join(tmp_dir, app_app, "Contents", "MacOS")
      [res_dir, mac_dir].map { |x| FileUtils.mkdir_p(x) }
      FileUtils.cp(File.join(DIR, "static", "Shoes.icns"), app_dir)
      FileUtils.cp(File.join(DIR, "static", "Shoes.icns"), res_dir)
      File.open(File.join(app_dir, "Contents", "PkgInfo"), 'w') do |f|
        f << "APPL????"
      end
      File.open(File.join(app_dir, "Contents", "Info.plist"), 'w') do |f|
        f << <<END
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleGetInfoString</key>
  <string>#{app_name} #{vers.join(".")}</string>
  <key>CFBundleExecutable</key>
  <string>#{name}-launch</string>
  <key>CFBundleIdentifier</key>
  <string>org.hackety.#{name}</string>
  <key>CFBundleName</key>
  <string>#{app_name}</string>
  <key>CFBundleIconFile</key>
  <string>Shoes.icns</string>
  <key>CFBundleShortVersionString</key>
  <string>#{vers.join(".")}</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
  <key>IFMajorVersion</key>
  <integer>#{vers[0]}</integer>
  <key>IFMinorVersion</key>
  <integer>#{vers[1]}</integer>
</dict>
</plist>
END
      end
      File.open(File.join(app_dir, "Contents", "version.plist"), 'w') do |f|
        f << <<END
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>BuildVersion</key>
  <string>1</string>
  <key>CFBundleVersion</key>
  <string>#{vers.join(".")}</string>
  <key>ProjectName</key>
  <string>#{app_name}</string>
  <key>SourceVersion</key>
  <string>#{Time.now.strftime("%Y%m%d")}</string>
</dict>
</plist>
END
      end
      File.open(File.join(mac_dir, "#{name}-launch"), 'w') do |f|
        f << <<END
#!/bin/bash
SHOESPATH=/Applications/Shoes.app/Contents/MacOS
APPPATH="${0%/*}"
unset DYLD_LIBRARY_PATH
cd "$APPPATH"
echo "[Pango]" > /tmp/pangorc
echo "ModuleFiles=$SHOESPATH/pango.modules" >> /tmp/pangorc
if [ ! -d /Applications/Shoes.app ]
  then ./cocoa-install
fi
open -a /Applications/Shoes.app "#{File.basename(script)}"
# DYLD_LIBRARY_PATH=$SHOESPATH PANGO_RC_FILE="$APPPATH/pangorc" $SHOESPATH/shoes-bin "#{File.basename(script)}"
END
      end
      FileUtils.cp(script, File.join(mac_dir, File.basename(script)))
      FileUtils.cp(File.join(DIR, "static", "stubs", "cocoa-install"),
        File.join(mac_dir, "cocoa-install"))

      dmg = Binject::DMG.new(File.join(tmp_dir, "blank.hfz"), vol_name)
      f2 = pkg("osx", opt)
      if f2
        dmg.grow(10)
        dmg.inject_file("setup.dmg", f2.path)
      end
      dmg.inject_dir(app_app, app_dir)
      dmg.chmod_file(0755, "#{app_app}/Contents/MacOS/#{name}-launch")
      dmg.chmod_file(0755, "#{app_app}/Contents/MacOS/cocoa-install")
      dmg.save(script.gsub(/\.\w+$/, '') + ".dmg") do |perc|
        blk[perc * 0.01] if blk
      end
      FileUtils.rm_rf(tmp_dir)
      blk[1.0] if blk
    end

    def self.linux(script, opt, &blk)
      name = File.basename(script).gsub(/\.\w+$/, '')
      app_name = name.capitalize.gsub(/[-_](\w)/) { $1.capitalize }
      run_path = script.gsub(/\.\w+$/, '') + ".run"
      tgz_path = script.gsub(/\.\w+$/, '') + ".tgz"
      tmp_dir = File.join(LIB_DIR, "+run")
      FileUtils.mkdir_p(tmp_dir)
      pkgf = pkg("linux", opt)
      prog = 1.0
      if pkgf
        size = Shy.hrun(pkgf)
        pblk = Shy.progress(size) do |name, perc, left|
          blk[perc * 0.5]
        end if blk
        Shy.xzf(pkgf, tmp_dir, &pblk)
        prog -= 0.5
      end

      FileUtils.cp(script, File.join(tmp_dir, File.basename(script)))
      File.open(File.join(tmp_dir, "sh-install"), 'wb') do |a|
        rewrite a, File.join(DIR, "static", "stubs", "sh-install"),
          'SCRIPT' => "./#{File.basename(script)}"
      end
      FileUtils.chmod 0755, File.join(tmp_dir, "sh-install")

      raw = Shy.du(tmp_dir)
      File.open(tgz_path, 'wb') do |f|
        pblk = Shy.progress(raw) do |name, perc, left|
          blk[prog + (perc * prog)]
        end if blk
        Shy.czf(f, tmp_dir, &pblk)
      end
       
      md5, fsize = Shy.md5sum(tgz_path), File.size(tgz_path)
      File.open(run_path, 'wb') do |f|
        rewrite f, File.join(DIR, "static", "stubs", "blank.run"),
          'CRC' => '0000000000', 'MD5' => md5, 'LABEL' => app_name, 'NAME' => name,
          'SIZE' => fsize, 'RAWSIZE' => (raw / 1024) + 1, 'TIME' => Time.now, 'FULLSIZE' => raw
        File.open(tgz_path, 'rb') do |f2|
          f.write f2.read(8192) until f2.eof
        end
      end
      FileUtils.chmod 0755, run_path
      FileUtils.rm_rf(tgz_path)
      FileUtils.rm_rf(tmp_dir)
      blk[1.0] if blk
    end
  end
end
