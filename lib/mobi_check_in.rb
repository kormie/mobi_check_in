require "mobi_check_in/version"
require "mobi_check_in/git"
require "yaml"

module MobiCheckIn

  def self.isWindows?
    platform = RUBY_PLATFORM.downcase
    windows_names = %w{mswin cygwin mingw}
    windows_names.each { |name| return true if platform.include?(name) }
    false
  end

  def self.history_file
    if isWindows?
      ENV['HOME'] + '/AppData/Local/Temp/mobi_check_in.yml'
    else
      '/tmp/mobi_check_in_history.yml'
    end
  end

  def self.printable_story_number(story_number)
    if story_number =~ /^\d*$/
      "MOBI-#{story_number}"
    else
      story_number
    end
  end

  def self.incremental options={}
    pair_names = ""
    story_number = ""

    if Git.has_local_changes?
      if File.exists?(history_file)
        shove_history = YAML::load(File.open(history_file))["shove"]
        pair_names    = shove_history["pair"]
        story_number  = shove_history["story"]
      end

      begin
        $stdout.write "Pair names (separated with '/') [#{pair_names}]: "
        input = $stdin.gets.strip
        pair_names = input unless input.empty?
      end until !pair_names.empty?

      begin
        $stdout.write "Story number (NA) [#{story_number}]: "
        input = $stdin.gets.strip
        story_number = input unless input.empty?
      end until !story_number.empty?

      File.open(history_file, 'w') do |out|
        YAML.dump({ "shove" => { "pair" => pair_names, "story" => story_number } }, out)
      end

      if story_number.delete("/").downcase == "na"
        commit_message = ""
      else
        commit_message = "#{printable_story_number(story_number)} - #{pair_names} - "
      end

      author = "#{pair_names}"

      system("git add -A") if options[:add]
      puts "Enter a commit message: "
      commit_message_text = gets.chomp
      commit_message = commit_message + commit_message_text
      puts commit_message
      command = "git commit -m \"#{commit_message}\""
      system(command)
    else
      puts "No local changes to commit."
    end

  end

  def self.pre_commit_tasks
    if File::exists? '.mobi_check_in.yml'
      file = File.read('.mobi_check_in.yml')
      pre_commit_tasks = YAML::load(file)["pre_commit"]
    end
  end

  def self.push_commits
    puts "*******"
    puts "About to push these changes:"
    puts Git.local_commits
    puts "*******"
    puts "Shoving..."
    system("git sc")
  end

  def self.push_and_test
    if pre_commit_tasks
      if system(pre_commit_tasks)
        push_commits
      else
        puts "Tests failed. Shove aborted."
        exit(1)
      end
    else
      push_commits
    end
  end

  def self.amend
    if `git log --branches --not --remotes --oneline` == ""
      puts "You have no unpushed commits to amend to"
    else
      command = "git commit --amend -C HEAD"
      system(command)
    end
  end

end
