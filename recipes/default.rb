#
# Cookbook Name:: kuidev
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

def git_clone username, repo, dest
  git "git clone  #{repo}" do
    user username
    group username
    repository repo
    destination dest
    enable_submodules true
  end
end

# TODO mv to definitions
def user_config username
  user_home = ::File.join('/home', username)
  user username do
    home user_home
    shell '/bin/zsh'
    password 'qy6J7t6BP8t5c'
    supports :manage_home => true
    action :manage
  end

  %w[adm cdrom sudo dip plugdev lpadmin sambashare admin].each do |g|
    group g do
      action :manage
      append true
      members username
    end
  end

  dotfiles_home = ::File.join(user_home, '.dotfiles')
  git_clone username, 'https://github.com/kui/dotfiles.git', dotfiles_home
  execute 'install dotfiles' do
    user username
    environment 'HOME' => user_home
    cwd dotfiles_home
    command "#{dotfiles_home}/install.sh -r > install.log 2>&1"
    creates ::File.join(user_home, '.zshrc')
  end

  rbenv_home = ::File.join(user_home, '.rbenv')
  git_clone username, 'https://github.com/sstephenson/rbenv.git', rbenv_home
  directory ::File.join(rbenv_home, 'plugins') do
    owner username
    group username
    mode 00755
    action :create
  end
  git_clone username, 'https://github.com/sstephenson/ruby-build.git', ::File.join(rbenv_home, 'plugins', 'ruby-build')
  git_clone username, 'https://github.com/jamis/rbenv-gemset.git', ::File.join(rbenv_home, 'plugins', 'rbenv-gemset')
end

if platform? 'ubuntu'
  apt_repository 'emacs' do
    uri "http://ppa.launchpad.net/cassou/emacs/ubuntu"
    distribution node['lsb']['codename']
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "CEC45805"
    deb_src true
    not_if 'emacs --version | head -n 1 | grep -iF "emacs 24."'
  end
  %w[emacs24-nox emacs24-el emacs24-common-non-dfsg].each do |pkg|
    package pkg
  end
else
  log 'could not install emacs 24' do
    level :warn
  end
end

%w[zsh git openjdk-7-jdk ruby].each do |pkg|
  package pkg
end

user_config 'vagrant'
