require 'rake/tasklib'
require 'bump'

class Rake::NvieTask < Rake::TaskLib

  # defines the name of the branch that releases will be branched from (default: 
  # development)
  attr_accessor :development_branch

  # defines the prefix to use for hotfix branches (default: hotfix)
  attr_accessor :hotfix_prefix

  # defines the name of the branch that hotfixes will be branched from (default: 
  # master)
  attr_accessor :master_branch

  # defines the prefix to use for release branches (default: release)
  attr_accessor :release_prefix

  # defines the upstream remote to use when pushing and pulling code
  attr_accessor :upstream_remote

  # defines the version file path and name (default: VERSION)
  attr_accessor :version_file

  # defines the branch that will be used for current task operations
  attr_reader :working_branch

  def initialize
    self.development_branch = 'development'
    self.master_branch = 'master'
    self.hotfix_prefix = "hotfix"
    self.release_prefix = "release"

    yield(self) if block_given?

    self.upstream_remote = determine_upstream_remote unless self.upstream_remote
    @working_branch = self.development_branch

    self.define
  end


  def define

    namespace :nvie do
      namespace :new do
        desc "Creates a new release branch from development, bumps the project version, and pushes to the remote repository"
        task :release => [:prepare_release, :guard_committed, :guard_upstream] do
          create_new_branch :release
        end

        desc "Creates a new hotfix branch from master, bumps the project version, and pushes to the remote repository"
        task :hotfix => [:prepare_hotfix, :guard_committed, :guard_upstream] do
          create_new_branch :hotfix
        end

        task :prepare_hotfix do
          prepare master_branch
        end

        task :prepare_release do
          prepare development_branch
        end

        task :guard_upstream do

          fail(%Q{failed: out of sync with remote

  Your local '#{working_branch}' branch is out of sync with '#{upstream_remote}/#{working_branch}'.
  This will likely result in you branching without up to date changes.

  Make sure you have pulled and pushed all changes, and rerun the task.
          }) if local_sha != remote_sha
        end

        task :guard_committed do
          `git diff HEAD --exit-code`
          retval = $?.to_i
          fail( %Q{failed: uncommitted code

  You have uncommitted changes on your current branch.

  Commit, stash, or remove the changes, and then rerun the task.
          }) if retval != 0
        end
      end
    end
  end

  def create_new_branch(type)
    print "Checking out #{working_branch} branch\n"
    `git checkout #{working_branch}`
    print "What will the new version number be? "
    version = STDIN.gets.chomp
    relname = self.send "#{type}_name", version
    print "Creating '#{relname}' branch\n"
    `git checkout -b #{relname}`
    print "Bumping version file\n"
    Bump::Bump.run "set", version: version
    print "Pushing new branch to '#{upstream_remote}/#{relname}'\n"
    `git push #{upstream_remote} #{relname} -u`
  end

  def determine_upstream_remote
    remotes = `git remote`.split("\n")
    remotes.size == 1 ? remotes[0] : fail(%Q{failed: multiple possible upstream remotes

  You have multiple upstream remotes defined.

  Please specify the correct remote to use by setting #upstream_remote

  Available remotes:
    #{remotes.join("\n      ")}
    })
  end


  def ensure_git_fetch
    unless @__git_fetched      
      `git fetch #{upstream_remote}`
      @__git_fetched = true
    end
  end

  def hotfix_name(version)
    "#{hotfix_prefix}-#{version}"
  end
    
  def local_sha(branch = working_branch)
    `git log --pretty=format:%H #{branch} -1`.chomp
  end

  def prepare(branch)
    @working_branch = branch
    print "Using upstream remote: #{upstream_remote}\n"
    ensure_git_fetch
  end

  def release_name(version)
    "#{release_prefix}-#{version}"
  end

  def remote_sha(branch = working_branch, remote = upstream_remote)
    `git log --pretty=format:%H #{remote}/#{branch} -1`
  end
end
