= cobbler

* http://github.com/phiggins/cobbler 

== DESCRIPTION:

Cobbler is a reworked version of the Shoes packager app that is scriptable
instead of GUI based.

== FEATURES/PROBLEMS:

* Provides scriptable interface to the Shoes packager.
* Supports most options of the GUI packager app.
* Deviates from the Raisins (Shoes 2 r1134) code little as possible.

== SYNOPSIS:

  require 'cobbler'

  Cobbler.pack( :name       => "Sample Shoes App",
                :creator    => "Anonymous",
                :version    => "1.2.3",
                :launch     => "lib/sample.rb",
                :path       => "sample_app",
                :platforms  => [ :exe, :dmg ] )

== REQUIREMENTS:

* Shoes (tested with Raisins, ie. Shoes 2 r1134)

== INSTALL:

* sudo gem install cobbler

== LICENSE:

(The MIT License)

Copyright (c) 2009 Pete Higgins

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
