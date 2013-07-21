#!usr/bin/perl 

use DBI; 
use Modern::Perl;
use Data::Dumper;
use YAML::XS qw(LoadFile); 


my $data = YAML::XS::LoadFile ('confg.yml');

my $dbh;

print Dumper ($data);
#Подключение к серверу MySQL
sub connect_db { 

my $database = $data->{Connect_data}{database};
my $user = $data->{Connect_data}{user};
my $password = $data->{Connect_data}{password};
my $host = $data->{Connect_data}{host};

my $data_source = "DBI:mysql:database=$database;host=$host";	
$dbh = DBI ->connect ($data_source, $user, $password)
	or die "Not conneted";
return 1;
}


