class puppet($run_master = false,
             $run_agent = false,
             $puppetmaster_address = "",
             $runinterval = 120,
             $extra_modules = "") {

	package { puppet-common:
		ensure => present
	}

	if ($run_master) {
		package { "puppetmaster-passenger":
			ensure => present
		}

		package { "ruby-activerecord":
			ensure => present
		}

		package { "ruby-sqlite3":
			ensure => present
		}

		File <| title == "/etc/puppet/puppet.conf" |> {
			notify +> Exec["restart-puppetmaster"]
		}

		file { "/etc/puppet/autosign.conf":
      ensure => present,
			content   => template('puppet/autosign.conf.erb'),
		}

		exec { "restart-puppetmaster":
			command => "/usr/sbin/service puppetmaster restart",
			require => Package[puppetmaster],
			refreshonly => true
		}
	}

	if ($run_agent) {
		package { puppet:
			ensure => present
		}

		file { "/etc/default/puppet":
			content => template('puppet/defaults.erb'),
			notify => Exec["restart-puppet"],
		}

		File <| title == "/etc/puppet/puppet.conf" |> {
			notify +> Exec["restart-puppet"]
		}

		file { "/etc/init.d/puppet":
			mode => 0755,
			owner => root,
			group => root,
			content => template('puppet/init.erb'),
			notify => Exec["restart-puppet"]
		}

		exec { "restart-puppet":
			command => "/usr/sbin/service puppet restart",
			require => Package[puppet],
			refreshonly => true
		}

	}

	file { "/etc/puppet/puppet.conf":
		content => template('puppet/puppet.conf.erb'),
		require => Package[puppet-common]
	}
}
