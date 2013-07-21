#!/usr/bin/perl

use Modern::Perl;
use DBI;
use Data::Dumper;
use YAML::XS qw(LoadFile);

use Daemon::Generic;

my $data = YAML::XS::LoadFile ('confg.yml');
my $dbh;

newdaemon(
	progname        => 'chek_data',
	pidfile         => '/tmp/ticktockd.pid',
	);


sub gd_run {
	connect_db ();
	while (1) {
		my $data = get_data ();
		if (@{$data}) {
			my $not_check_data = check_data ($data);
		}
		else {
			print "Not data \n";
		}

		sleep (5);
}



}

sub output {
	my ($n) =  @_;
	open (OUTPUT, ">>", "ex1.ot")
		or die return " not correct";
	print OUTPUT  Dumper ($n);
	close OUTPUT;
	return 1;
}

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

sub get_data {
	my $sql = "SELECT *
			 FROM telephone_book
			 WHERE chek_value ='no'
			 ";
	my $sel_array = $dbh->selectall_arrayref ("$sql", {Slice => {} } );
	return $sel_array;
}

sub check_data {
	my ($data) = @_;
	my @not_check_data;
	my $chek_value;
	foreach my $row (@{$data}) {
		return "NOT HASH IN VALUE" unless ref($row) eq "HASH";
		if (${$row}{name} =~ m/^.{5,30}$/ & ${$row}{phone} =~ m/^.{8,15}$/ & ${$row}{work_place_id} =~ m/^\d{1,11}$/){
			$chek_value = "success";
		}
		else {
			$chek_value = "fail";
			print "WORK\n";
			push @not_check_data, { %{$row} };
		}
		#update_row( ${$row}{id}, $chek_value ) ;
	}
	print Dumper (@not_check_data);
	return \@not_check_data;
}


sub update_row {
	my ($row_id, $chek_value) = @_;
	print Dumper ($row_id);
	my $sql = "UPDATE telephone_book SET chek_value=? WHERE id = ?";
	my $sth  = $dbh->do($sql, undef, $chek_value, $row_id);
	print Dumper ($sth);
}

sub send_mail {

}
