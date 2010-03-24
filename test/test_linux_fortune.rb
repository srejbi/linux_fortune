require File.dirname(__FILE__) + '/test_helper.rb'

class TestLinuxFortune < Test::Unit::TestCase

  def setup
  end

  def test_binary_path
    LinuxFortune.binary_path=`which fortune`.strip
    assert !LinuxFortune.binary_path.nil?
    assert File.exist?(LinuxFortune.binary_path)
  end

  # test if fortune is generated
  def test_basic_generation
    lf = LinuxFortune.generate
    assert !lf.nil?                             # fortune should be present
    assert !lf.body.nil? && !lf.body.empty?     # body should be present
    assert !lf.source.nil? && !lf.source.empty? # source should be present
  end

  # verify that long gets set to false if configuring for short messages
  def test_short
    LinuxFortune.short = true
    assert LinuxFortune.short           # short should be set to true
    assert LinuxFortune.long == false   # long to false
    assert LinuxFortune.fortune_options.include?("-s")
    assert LinuxFortune.fortune_options.include?("-n") || LinuxFortune.short_length == 160
    10.times do                             # check multiple times if the generated length is ok
      lf = LinuxFortune.generate
      assert lf.body.size < LinuxFortune.short_length # check if actual size is less than the max. short length
    end
  end

  # verify that short gets set to false if configuring for long messages
  def test_long
    LinuxFortune.long = true
    assert LinuxFortune.long            # long should be set to short
    assert LinuxFortune.short == false  # short to false
    assert LinuxFortune.fortune_options.include?("-l")
    assert LinuxFortune.fortune_options.include?("-n") || LinuxFortune.short_length == 160
    5.times do                           # check multiple times if the generated length is ok
      lf = LinuxFortune.generate
      #puts "#{lf.body.size} characters"
      # TODO apparently there is an issue with 'fortune -l'; check fortune docs & bugs (manual mentions a different problem
      assert lf.body.size+10 >= LinuxFortune.short_length # check if actual size is greater than the max. short length
    end
  end

  # Fortune.body should be the same as Fortune.to_s
  def test_fortune_to_s
    lf = LinuxFortune.generate
    assert lf.body == lf.to_s
  end

  # test that there are sources
  # TODO refine test case
  def test_sources
    # just get whatever length fortunes
    LinuxFortune.short=false
    LinuxFortune.long=false

    sources = LinuxFortune.get_sources
    assert !sources.nil? and sources.size > 0
  end

  # test fortune from source
  def test_fortune_from_each_source
    sources = LinuxFortune.get_sources
    fortunes = []
    sources.each do |src|
      fortunes << src.fortune
      assert fortunes.size > 0
      #puts "#{fortunes.last.source} --- #{src.fullpath}"
      assert fortunes.last.source == src.fullpath
    end
  end

  # test if fortune messages are from the sources requested
  # TODO pick random sources from sources once sources code is functional
  def test_fortune_from_sources
    # check multiple times
    5.times do
      lf = LinuxFortune.generate(["chucknorris","linux"])
      #puts lf.source
      #puts lf.source.split("/").last
      assert ["chucknorris","linux"].include?(lf.source.split("/").last.strip)
    end
  end
end
