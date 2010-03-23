module LinuxFortune
  # <tt>@@binary_path</tt> - path to the 'fortune' binary
  #mattr_accessor :binary_path
  @@binary_path = "/usr/bin/fortune"

  # sets the path of the linux fortune program ("/usr/bin/fortune" by default)
  def self.binary_path=(path)
    @@binary_path = path unless @@binary_path == path
  end

  # gets the current path to the linux fortune program
  def self.binary_path
    @@binary_path
  end

  @@offensive = false

  # <tt>off</tt> - Choose only from potentially offensive aphorisms.  This option is ignored if a fortune directory is specified.
  def self.offensive=(off = true)
    @@offensive = off
  end

  def self.offensive
    @@offensive
  end

  @@equalsize = false

  # <tt>eq</tt> - Consider all fortune files to be of equal size (see discussion below on multiple files).
  def self.equalsize=(eq = true)
    @@equalsize = eq
  end

  # returns the current state of <tt>equalsize</tt>
  def self.equalsize
    @@equalsize
  end

  @@short_length = 160

  # Set  the longest fortune length (in characters) considered to be ``short'' (the default is 160).  All
  # fortunes longer than this are considered ``long''.  Be careful!  If you set the length too short  and
  # ask  for  short  fortunes, or too long and ask for long ones, fortune goes into a never-ending thrash
  # loop.
  def self.short_length=(shortlength = 160)
    @@short_length = shortlength
  end

  # gets the current maximum length considered short
  def self.short_length
    @@short_length
  end

  @@short = false

  # turns on/off short message generation
  def self.short=(shortfortunes = true)
    @@long = false if shortfortunes
    @@short = shortfortunes
  end

  # get the state of short message generation
  def self.short
    @@short
  end

  @@long = false

  # turns on/off long message generation
  def self.long=(longfortunes = true)
    @@short = false if longfortunes
    @@long = longfortunes
  end

  # gets the state of long message generation
  def self.long
    @@long
  end

  @@ignore_case = true

  # turns on/off case-insensitivity for search
  def self.ignore_case=(ignore = true)
    @@ignore_case = ignore
  end

  # gets the state of case-insensitivity
  def self.ignore_case
    @@ignore_case
  end

  # fortune source
  class FortuneSource
    @path = "/usr/share/fortune"
    @source = ""
    @weight = 0

    def init(source = nil, path = "/usr/share/fortune", weight = nil )
      @source = source
      @path = path
      @weight = weight
    end

    # sets the fortune source path
    def path=(srcpath)
      @path = srcpath
    end

    # gets the source path (directory with source)
    def path
      @path
    end

    # sets the source file name (file in FortuneSource.path)
    def source=(src)
      @source = src
    end

    # gets source file name
    def source
      @source
    end

    def weight
      @weight
    end

    # gets full path to the source
    def fullpath
      File.join(@path, @source)
    end
  end


  # The Fortune class is basicly 2 strings, source and body
  class Fortune
    @source = ""
    @body = ""

    # attribute accessors

    # gets the fortune text
    def body
      @body
    end
    # gets the fortune text (alias for body)
    alias_method(:to_s, :body)

    # gets the fortune source
    def source
      @source
    end

    def body=(text = "")
      @body = text
    end

    def source=(src = "")
      @source = src
    end

  end

  # list available sources
  def self.get_sources
    sources = []
    path = nil
    srclist = `#{self.binary_path} -f 2>&1`
    srclist.each do |source|
      weight,src = source.strip.split
      if src.match(/(\/.*)*/)
        #puts "#{src} -> #{weight}"
        path = src
      else
        sources << FortuneSource.new( :path => path, :source => src, :weight => weight )
      end
    end
    sources
  end

  # executes the fortune program
  def self.fortune(sources = nil)
    #puts "executing #{self.binary_path} -c #{fortune_options} #{sources.each { |s| s.strip }.join(" ") unless sources.nil?} 2>&1"
    `#{self.binary_path} -c #{fortune_options} #{sources.each { |s| s.strip }.join(" ") unless sources.nil?} 2>&1`
  end

  # generates a fortune message
  # <tt>sources</tt> - array of sources
  def self.generate(sources = nil)
    lf = LinuxFortune::Fortune.new
    lf.body = ""
    ftn = self.fortune(sources)
    ftn.each do |s|
      if s.match(/\(.*\)/)
        lf.source = s.gsub(/(^\()|(\)$)/, "")
      else
        lf.body << s unless s.match(/^%\n/)
      end
    end
    lf
  end

  # searches fortune sources and returns hits
  def self.search(pattern = nil)
    # TODO
  end

  protected

  # construct command line options for fortune
  def self.fortune_options
    opts = ""
    opts << "-o " if @@offensive
    opts << "-e " if @@equalsize
    opts << "-l " if @@long
    opts << "-s " if @@short
    opts << "-n #{@@short_length}" unless @@short_length == 160 or (!@@long and !@@short)
    opts 
  end
end

