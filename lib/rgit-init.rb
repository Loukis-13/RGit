require_relative "./utils"

module RGit
  def self.init(*args)
    if Dir.exists? RGIT_DIRECTORY
      $stderr.puts "Existing RGit project"
      exit 1
    end

    Dir.mkdir RGIT_DIRECTORY
    # build objects directory
    Dir.mkdir OBJECTS_DIRECTORY
    Dir.mkdir "#{OBJECTS_DIRECTORY}/info"
    Dir.mkdir "#{OBJECTS_DIRECTORY}/pack"
    # build refs directory
    Dir.mkdir REFS_DIRECTORY
    Dir.mkdir "#{REFS_DIRECTORY}/heads"
    Dir.mkdir "#{REFS_DIRECTORY}/tags"
    # index
    File.open INDEX_PATH, 'w'
    # initialize head
    File.write("#{RGIT_DIRECTORY}/HEAD", "ref: refs/heads/master\n")

    $stdout.puts "RGit initialized in #{RGIT_DIRECTORY}"
  end
end

