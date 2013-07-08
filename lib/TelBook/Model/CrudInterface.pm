package TelBook::Model::CrudInterface;
use Modern::Perl;
use Moose;
use DBI;
use Data::Dumper;
use YAML::XS qw(LoadFile); 
use namespace::autoclean;

extends 'Catalyst::Model';


my $data = YAML::XS::LoadFile ('confg.yml');

my $dbh;


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

# Число страниц 
sub total_rec_count {
	my ($params) = @_;
	connect_db();
	my $sth = $dbh->prepare( "SELECT COUNT(*) FROM telephone_book");
	$sth->execute();
	my $rowscount = $sth->fetchrow_array();
}


#Удаление данных
sub delete_row {
	my ($self, $id) = @_;
	connect_db();
	my $sql = "DELETE FROM telephone_book 
		WHERE id = ?";
	if ($id =~ m/\d{1,11}/){
		my $sth = $dbh -> prepare("$sql")
			or die "WRONG_VALUE";
		$sth->execute($id)
			or die "WRONG_VALUE";
		return 1;
	}
	else {return "WRONG_VALUE"; }
 }

 # Редактирование данных
sub edit {
	my ($self, $params) = @_;
	connect_db();
	my @set ;
	return "WRONG_VALUE" unless ($params->{id} =~  m/\d{1,11}/ ) ;

	if ( $params->{name} =~ m /.{3,50}/ ){
		push @set, "name='$params->{name}'\n";
	}
	if ($params->{phone} =~ m/.{3,15}/) {
		push @set, "phone='$params->{phone}'\n";
	}
	if ($params->{work_place_id} =~ m/\d{1,11}/){
		push @set, "work_place_id='$params->{work_place_id}'\n";
	}


	foreach my $one_set (@set){
		if ($one_set){
			my $sql = "UPDATE telephone_book 
			SET $one_set
			WHERE id=? ";
			my $sth =$dbh -> prepare ("$sql")
				or die "WRONG_PARAMS";
			$sth->execute($params->{id})
				or die "WRONG_PARAMS";
		}
	}
	return 1;
}

# Показ данных 
sub show {
	my ($params) = @_;
	connect_db();
	my $where;
	my $sort = '';
	my $limit = '';

	# Вывод данных по ID
	if ($params->{id} =~ m/\d{1,11}/){	 
		$where = "id=".$params->{id};
	}
	else {
			$where = '1';
	}

	# Постраничная навигация
	if ($params->{page_size}){
		$limit ="LIMIT ".$params->{start_index}.",".$params->{page_size};
	}

	# Сортировка
	if ( $params->{sorting} ) {
		$sort = "ORDER BY ".$params->{sorting};
	}  

	my $sql ="
		SELECT * 
		FROM telephone_book
		WHERE $where
		$sort
		$limit
		";
	my $sel_array = $dbh->selectall_arrayref("$sql",
		{Columns=>{} } );
}

# Втавка данных 
sub add {
	my ($params) = @_;
	connect_db();
	my @array;

	if ($params->{name}=~ m/.{3,50}/ ,$params->{phone} =~ m/.{3,15}/, $params->{work_place_id} =~ m/.{1,50}/){
		push @array, $params->{name}.";".$params->{phone}.";".$params->{work_place_id}."\n";
	}

	foreach (@array) {
			if ($_ =~ m /(^(.{3,50});(.{3,15});(\d{1,11})$)/){
			my $name_i = $2;
			my $phone_i = $3;
			my $work_place_id_i = $4;

			my $sql = "INSERT INTO telephone_book (name,phone,work_place_id)
				VALUES (?,?,?)";
			my $sth =$dbh -> prepare ("$sql")
				or die "WRONG_PARAMS";
			$sth->execute($name_i,$phone_i,$work_place_id_i)
				or die "WRONG_PARAMS";
			}
			else {return "WRONG_PARAMS";}
	}
	my $insertid = $dbh->{'mysql_insertid'};
}



1;

=head1 NAME

TelBook::Model::CrudInterface - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.


=encoding utf8

=head1 AUTHOR

BanaKing,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;