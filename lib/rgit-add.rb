require "digest"
require "zlib"
require "fileutils"
require_relative "./utils"

module RGit
  def self.append_to_index(path)
    if File.open(INDEX_PATH).read.include? path then
      return
    end

    file_contents = File.read(path)
    sha = Digest::SHA1.hexdigest file_contents
    blob = Zlib::Deflate.deflate file_contents
    object_directory = "#{OBJECTS_DIRECTORY}/#{sha[0..1]}"
    FileUtils.mkdir_p object_directory
    blob_path = "#{object_directory}/#{sha[2..-1]}"

    File.write(blob_path, blob)

    File.write(INDEX_PATH, "#{sha} #{path}\n", mode: "a")
  end

  def self.add(*args)
    if !Dir.exists? RGIT_DIRECTORY
      $stderr.puts "Not an RGit project"
      exit 1
    end

    if args.empty?
      $stderr.puts "No path specified"
      exit 1
    end

    if args.first == "."
      args = Dir.glob("./**/*").reject { |f| File.directory?(f) }
    end

    args.each do |path|
      append_to_index(path)
    end
  end
end

