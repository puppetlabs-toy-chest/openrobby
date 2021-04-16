project "robby3" do |proj|
  proj.description "Robby the Helpful Robot (3)"
  proj.homepage "https://github.com/puppetlabs/robby3"
  proj.vendor "Placeholder Team <placeholder@example.com>"
  proj.license "Placeholder license"

  # Elixir require semver, which requires that version info outside of semver
  # be separated by something like hyphens.
  working_repo = File.dirname(File.dirname(File.dirname(File.realpath(__FILE__))))
  proj.setting(:working_repo, working_repo)
  elixir_version = ::Git.open(working_repo).describe("HEAD", tag: true, always: true)

  proj.version elixir_version
  proj.setting(:elixir_version, elixir_version)

  proj.setting(:prefix, "/opt/bizops/robby3")
  proj.directory proj.prefix
  proj.component "robby3"
end
