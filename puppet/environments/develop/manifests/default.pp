class setup {

  $basic = [
    'vim', 'htop', 'build-essential', 'software-properties-common', 'curl', 'iptables', 'iptables-persistent',
    'zip', 'unzip', 'libpcre3', 'libpcre3-dev'
  ]

  package { $basic:
    ensure => installed
  }
}

class accounts {

  user { 'vagrant':
    ensure   => present,
    password => '$1$ImQjhUIS$oG7ejFp/tReDLujM2nkE80',
  }
}

node "vm.example" {

  include setup
  include accounts

  class { 'apache':
    default_vhost => false,
    mpm_module    => false,
  }

  class { 'apache::mod::prefork':
    startservers    => "5",
    minspareservers => "3",
    maxspareservers => "3",
    serverlimit     => "64",
    maxclients      => "64",
  }

  include apache::mod::alias
  include apache::mod::rewrite
  include apache::mod::vhost_alias

  apache::vhost { 'vm.example':
    priority      => 15,
    port          => '80',
    docroot       => '/var/www/web/',
    directories   => [{
      path            => '/var/www/web/',
      directoryindex  => 'index.php index.html index.xhtml ',
      options         => ['Indexes', 'FollowSymLinks', 'MultiViews'],
	  allow_override   => ['All'],
      override        => "all",
      custom_fragment => 'RewriteEngine on
      RewriteBase /
      RewriteCond %{REQUEST_FILENAME} !-f
      RewriteCond %{REQUEST_FILENAME} !-d
      RewriteRule ^(.*)$ index.php?q=$1 [L,QSA]'
    }],
    docroot_owner => 'vagrant',
    docroot_group => 'www-data'
  }

  firewall { '100 allow http and https access':
    dport  => [80],
    proto  => tcp,
    action => accept,
  }

  class { '::php::globals':
    php_version => '7.0',
    config_root => '/etc/php/7.0',
  } ->
    class { '::php':
      manage_repos => true,
      fpm          => false,
      dev          => true,
      composer     => true,
      pear         => true,
      phpunit      => false,
      settings     => {
        'PHP/max_execution_time'  => '300',
        'PHP/display_errors'      => 'On',
        'PHP/log_errors'          => true,
        'PHP/track_errors'        => true,
        'PHP/html_errors'         => true,
        'PHP/max_input_time'      => '300',
        'PHP/memory_limit'        => '256M',
        'PHP/post_max_size'       => '24M',
        'PHP/upload_max_filesize' => '24M',
        'PHP/expose_php'          => 'Off',
        'PHP/allow_url_fopen'     => 'On',
        'Session/cache_limiter'   => 'nocache',
        'Session/auto_start'      => '0',
        'Date/date.timezone'      => 'UTC',
      },
      extensions   => {
        ctype    => { },
        dom      => { },
        fileinfo => { },
        json     => { },
        bcmath   => { },
        mbstring => { },
        mcrypt   => { },
        mysql    => { },
        intl     => { },
        pdo      => { },
        gd       => { },
        curl     => { },
        zip      => { },
        xdebug   => { },
        memcached => { }
      }
    }

  include apache::mod::php

  class { 'mysql::server':
    root_password           => 'password',
    remove_default_accounts => true,
    override_options        => {
      'mysqld'    => {
        'connect_timeout'    => '60',
        'bind_address'       => '0.0.0.0',
        'max_connections'    => '100',
        'max_allowed_packet' => '512M',
        'thread_cache_size'  => '16',
        'query_cache_size'   => '128M',
        'log-error'          => '/var/log/mysql/mariadb.log',
        'pid-file'           => '/var/run/mysqld/mysqld.pid'
      },
      mysqld_safe => {
        'log-error' => '/var/log/mysql/mariadb.log',
      },
    }
  }

  mysql::db { 'vm_example_schema':
    user     => 'usr-vm-example',
    password => mysql_password('123456789'),
    host     => '%',
    grant    => ['ALL'],
    ensure   => present,
    charset  => 'utf8',
    collate => 'utf8_general_ci',
    sql      => '/vagrant/files/vm_example_schema.sql',
    require  => Class['mysql::server'],
  }

  class { 'mysql::bindings':
    php_enable => true,
  }

  class { 'memcached':
    max_memory => '20%',
    listen_ip => '127.0.0.1',
    tcp_port => 11211,
    udp_port => 11211,
    logfile => '/var/log/memcached.log'
  }

  firewall { '101 allow mysql access':
    dport  => [3306],
    proto  => tcp,
    action => accept,
  }

  Class['accounts'] -> Class['setup']
  Class['setup'] -> Class['apache']
  Class['apache'] -> Firewall['100 allow http and https access']
  Class['apache'] -> Class['php']
  Class['php'] -> Class['mysql::server']
  Class['mysql::server'] -> Class['memcached']
  Class['memcached'] -> Firewall['101 allow mysql access']

}