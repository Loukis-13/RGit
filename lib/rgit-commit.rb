require "digest"
require "time"
require_relative "./utils"

module RGit
  COMMIT_MESSAGE_TEMPLATE = <<-TXT
# Title
#
# Body
TXT

  def self.index_files = File.open(INDEX_PATH).each_line

  def self.index_tree
    index_files.each_with_object({}) do |line, obj|
      sha, path = line.split
      segments = path.split("/")
      segments.reduce(obj) do |memo, s|
        if s == segments.last
          memo[segments.last] = sha
          memo
        else
          memo[s] ||= {}
          memo[s]
        end
      end
    end
  end

  def self.build_tree(name, tree)
    sha = Digest::SHA1.hexdigest(Time.now.iso8601 + name)
    object = RGit::ShaWriter.new(sha)

    object.write do |file|
      tree.each do |key, value|
        if value.is_a? Hash
          dir_sha = build_tree(key, value)
          file.puts "tree #{dir_sha} #{key}"
        else
          file.puts "blob #{value} #{key}"
        end
      end
    end

    sha
  end

  def self.build_commit(tree:)
    commit_message_path = "#{RGIT_DIRECTORY}/COMMIT_EDITMSG"

    `echo "#{COMMIT_MESSAGE_TEMPLATE}" > #{commit_message_path}`
    `nvim #{commit_message_path} >/dev/tty`

    message = File.read commit_message_path
    committer = "user"
    sha = Digest::SHA1.hexdigest(Time.now.iso8601 + committer)
    object = RGit::ShaWriter.new(sha)

    object.write do |file|
      file.puts "tree #{tree}"
      file.puts "author #{committer}"
      file.puts
      file.puts message
    end

    sha
  end

  def self.update_ref(commit_sha:)
    current_branch = File.read("#{RGIT_DIRECTORY}/HEAD").strip.split.last

    File.open("#{RGIT_DIRECTORY}/#{current_branch}", "w") do |file|
      file.print commit_sha
    end
  end

  def self.commit(*args)
    if index_files.count == 0
      $stderr.puts "Nothing to commit"
      exit 1
    end

    root_sha = build_tree("root", index_tree)
    commit_sha = build_commit(tree: root_sha)
    update_ref(commit_sha: commit_sha)
    File.truncate INDEX_PATH, 0
  end

end

