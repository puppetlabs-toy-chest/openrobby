require 'git'

component "robby3" do |pkg, settings, platform|
  # Use the working directory as the repo, and check out the current HEAD. This
  # is useful if you want your packaging job to run on a branch, or if you want
  # to run it locally for development.
  pkg.url settings[:working_repo]
  pkg.ref ::Git.open(settings[:working_repo]).object("HEAD").sha

  pkg.license "Placeholder license"
  pkg.version settings[:elixir_version]

  pkg.requires ["postgresql", "imagemagick"]

  pkg.build_requires ["esl-erlang=1:20.3.8.6", "elixir=1.5.2-1", "tar", "git", "nodejs"]
  pkg.build do
    [
      "./build.sh",
    ]
  end

  tarball = "_build/prod/rel/robby3/releases/#{settings[:elixir_version]}/robby3.tar.gz"
  pkg.install { ["tar -xz -C #{settings[:prefix]} -f #{tarball}"] }

  # We want the configuration file in a predictable place, namely
  # /opt/robby3/robby3.conf. Unfortunately, the app wants it elsewhere.
  # This copies it into the predictable place, and makes the app's version of
  # the file into a symlink.
  source_conf = File.join(settings[:prefix], "releases", settings[:elixir_version], "robby3.conf")
  final_conf = File.join(settings[:prefix], "robby3.conf")
  pkg.install do
    [
      "cp #{source_conf} #{final_conf}",
      "chmod 0600 #{final_conf}",
      "rm #{source_conf}",
      "ln -s #{final_conf} #{source_conf}",
    ]
  end

  pkg.configfile final_conf, mode: "0600"

  pkg.install_file "packaging/robby3.init", "/etc/init.d/robby3", mode: "0755"
  pkg.add_preremove_action ['removal', 'upgrade'], [
    <<-SCRIPT
      if [ -x /etc/init.d/robby3 ]; then
        /usr/sbin/service robby3 stop
      fi
    SCRIPT
  ]

  pkg.add_postinstall_action ['install', 'upgrade'], "systemctl daemon-reload"
end