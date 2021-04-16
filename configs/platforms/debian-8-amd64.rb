platform "debian-8-amd64" do |plat|
  plat.vmpooler_template "debian-8-x86_64"
  plat.codename "jessie"

  plat.install_build_dependencies_with "DEBIAN_FRONTEND=noninteractive apt-get install -qy --no-install-recommends "
  plat.provision_with <<-SCRIPT
    set -e
    export DEBIAN_FRONTEND=noninteractive
    curl -sSLO https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
    dpkg -i erlang-solutions_1.0_all.deb
    curl -sSL https://deb.nodesource.com/setup_9.x | bash -
    apt-get update -qq
    apt-get install -qy --no-install-recommends make rsync curl devscripts fakeroot debhelper
  SCRIPT
end
