package TelBook::Controller::TelBook;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use JSON::XS;
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TelBook::Controller::TelBook - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

 

# Начальная страница 
sub index :Path :Args() {
    my ( $self, $c ) = @_;
    $c->stash (template => 'telbook/title.tt2');
}


sub show :Chained('/') :PathPart('telbook/show') :Args() {
	my ( $self, $c) = @_;
	my $json_xs = JSON::XS->new();
	my $p = $c->request->params; 
	my $res = $c-> response;

	my $params = { 
        page_size 	=> $p->{jtPageSize},
        start_index => $p->{jtStartIndex},
        sorting 	=> $p->{jtSorting},
    };

    my %json;
    my $data = TelBook::Model::CrudInterface::show($params);
	$json{Result} = "OK";
	$json{Records} = $data;
	$json{TotalRecordCount} = TelBook::Model::CrudInterface::total_rec_count();
	$data = $json_xs->encode (\%json);
	$res->body ($data);
}


sub delete :Chained('/') :PathPart('telbook/delete') :Args() {
	my ( $self, $c) = @_;
	my $json_xs = JSON::XS->new();

	my $id = $c->request->params->{id};
	$c->model ('CrudInterface')->delete_row($id);

	my %json;
	$json{Result} = "OK";
	my $data = $json_xs->encode (\%json);
	$c->response->body($data);
}

sub edit : Chained('/') :PathPart('telbook/edit') :Args() {
	my ($self, $c) = @_;
	my $json_xs = JSON::XS->new();
	my $p = $c->request->params; 
	my $res = $c->response;

	my %json;


	my $params = { 
		id 				=> $p->{id} || '',
        name 			=> $p->{name} || '',
        phone 			=> $p->{phone} || '',
        work_place_id 	=> $p->{work_place_id} || 0,
       };

    # Отправка данных на изменение 
    if ($params->{name}=~ m/.{3,50}/ ,$params->{phone} =~ m/.{3,15}/, $params->{work_place_id} =~ m/.{1,50}/){
     	$c->model ('CrudInterface')->TelBook::Model::CrudInterface::edit($params);
		$json{Result} = "OK";
	}

	else {
		$json{Result} = "ERROR"
	}


	my $data = $json_xs->encode (\%json);	
	$res->body($data);
}

sub add : Chained('/') :PathPart('telbook/add') :Args() {
	my ( $self, $c) = @_;

	my $json_xs = JSON::XS->new();
	my $p = $c->request->params; 
	my $res = $c->response;

    my %json;
    my $data;

	my $params = { 
        name 			=> $p->{name} || '',
        phone			=> $p->{phone} || '',
        work_place_id	=> $p->{work_place_id} || 0,
    };

    if ($params->{name}=~ m/.{3,50}/ ,$params->{phone} =~ m/.{3,15}/, $params->{work_place_id} =~ m/.{1,11}/){
     	my $last_id = TelBook::Model::CrudInterface::add($params);
     	$params ->{id} = $last_id;
     	$data = TelBook::Model::CrudInterface::show($params);
     	$json{Result} = "OK";
     	$json{Record} = $data->[0];			    
	}
	else {
		$json{Result}	= "ERROR";
		$json{Message} 	= "ERROR MESSAGE";
	}

	$data = $json_xs->encode (\%json);
     		$res->body ($data);
}

=encoding utf8

=head1 AUTHOR

BanaKing,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
