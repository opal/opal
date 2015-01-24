namespace :doc do
  doc_repo = Pathname(ENV['DOC_REPO'] || 'gh-pages')
  doc_base = doc_repo.join('doc')
  current_git_release = -> { `git rev-parse --abbrev-ref HEAD`.chomp }
  template_option = "--template opal --template-path #{doc_repo.join('yard-templates')}"

  directory doc_repo.to_s do
    remote = ENV['DOC_REPO_REMOTE'] || '.'
    sh 'git', 'clone', '-b', 'gh-pages', '--', remote, doc_repo.to_s
  end

  task :corelib => doc_repo.to_s do
    git  = current_git_release.call
    name = 'corelib'
    glob = 'opal/**/*.rb'

    command = "doxx --template #{doc_repo.join('doxx-templates/opal.jade')} "\
              "--source opal/corelib --target #{doc_base}/#{git}/#{name} "\
              "--title \"Opal runtime.js Documentation\" --readme opal/README.md"
    puts command; system command or $stderr.puts "Please install doxx with: npm install"

    command = "yard doc #{glob} #{template_option} "\
              "--readme opal/README.md -o #{doc_base}/#{git}/#{name}"
    puts command; system command
  end

  task :stdlib => doc_repo do
    git  = current_git_release.call
    name = 'stdlib'
    glob = '{stdlib/**/*,opal/compiler,opal/erb,opal/version}.rb'
    command = "yard doc #{glob} #{template_option} "\
              "--readme stdlib/README.md -o gh-pages/doc/#{git}/#{name}"
    puts command; system command
  end
end

task :doc => ['doc:corelib', 'doc:stdlib']
