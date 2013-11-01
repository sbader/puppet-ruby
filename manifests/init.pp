# Class: ruby
#
# This module installs a full chruby-driven ruby stack
#
class ruby(
  $default_gems      = $ruby::params::default_gems,
  $chruby_version    = $ruby::params::chruby_version,
  $chruby_root       = $ruby::params::chruby_root,
  $rubybuild_version = $ruby::params::rubybuild_version,
  $rubybuild_root    = $ruby::params::rubybuild_root,
  $user              = $ruby::params::user,
) inherits ruby::params {

  if $::osfamily == 'Darwin' {
    include boxen::config

    file {
      "${boxen::config::envdir}/rbenv.sh":
        ensure => absent ;
      "${boxen::config::envdir}/ruby.sh":
        ensure => absent ;
    }

    boxen::env_script { 'ruby':
      content  => template('ruby/ruby.sh.erb'),
      priority => 'higher',
    } -> Ruby::Gem <| |>
  }

  repository { $chruby_root:
    ensure => $chruby_version,
    source => 'postmodern/chruby',
    user   => $user,
  }

  ->
  file { "${chruby_root}/versions":
    ensure  => directory,
    owner   => $user,
  }

  ->
  repository { $rubybuild_root:
    ensure => $rubybuild_version,
    force  => true,
    source => 'sstephenson/ruby-build',
    user   => $user,
  }

  ->
  file {
    "${chruby_root}/bin/chruby-install":
      source => 'puppet:///modules/ruby/chruby-install.sh',
      owner  => $user,
      mode   => '0755' ;
    "${chruby_root}/share/chruby/better-auto.sh":
      source => 'puppet:///modules/ruby/better-auto.sh',
      owner  => $user,
      mode   => '0755' ;
  }

  ->
  Ruby::Definition <| |>

  ->
  Ruby::Version <| |>
}
