class puppet::storeconfigs::sqlite {
	case $::operatingsystem
	{
		'ubuntu', 'debian': {
			 package{ 'sqlite3':
	    		ensure => installed,
	 		 }
	 		 package{ 'libactiverecord-ruby':
	    		ensure => installed,
	 		 }
	 		 package{'libsqlite3-ruby':
	 		 	ensure => installed,
	 		}
		}
		'centos', 'redhat', 'fedora': {
			 package{ 'sqlite':
	    		ensure => installed,
	 		 }
	 		 package{ 'rubygem-activerecord.':
	    		ensure => present,
	    		provider => installed
	 		 }
	 		 package{'rubygem-sqlite3-ruby':
	 		 	ensure => installed,
	 		}
		}
		default: {
			err('sqlite support is not completed for your OS')
		}	
	}
}
