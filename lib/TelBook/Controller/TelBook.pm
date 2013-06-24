package TelBook::Controller::TelBook;
use Moose;
use namespace::autoclean;

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
sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->response->redirect( '/telbook/show_table/0' );
}

# Показ таблицы данных 
sub show_table :Chained('/') :PathPart('telbook/show_table') :Args() {
	my ( $self, $c, $page) = @_;
	my $p = $c->request->params; 
	my $params;

    # Навигация
	my $total = TelBook::Model::CrudInterface::total_page($page);
    $c->stash->{table_content} = TelBook::Model::CrudInterface::show($params, $page);
	$c->stash->{page} = $page;
	$c->stash->{total} = $total;
}

# Сортировка по значению 
sub sort :Chained('/') :PathPart('telbook/sort') :Args() {
	my ($self, $c, $fldid, $order, $page) = @_;
	$c->model ('CrudInterface')->connect_db();


	# Переключатель сортировки
	if ($order eq "ASC"){ 
		$order = "DESC";
		$c->stash->{order}="DESC";
	}
	else { 
		$order = "ASC";
		$c->stash->{order}="ASC";

	}

	# Навигация
	my $total = TelBook::Model::CrudInterface::total_page($page);
	$c->stash->{page} = $page;
	$c->stash->{total} = $total;
	$c->stash->{table_content} = TelBook::Model::CrudInterface::sort($fldid, $order, $page);
	$c->stash (template => 'telbook/show_table.tt2');
}

# Добавление данных 
sub add :Chained('/') :PathPart('telbook/add') {
	my ($self, $c, $flag) = @_;
	my $p = $c->request->params; 

	my $params = { 
        name=>$p->{name},
        phone=>$p->{phone},
        work_place_id=>$p->{work_place_id},
    };

	$c->model ('CrudInterface')->connect_db();

	# Проверка на правильность данных и обработка запроса 
	if ($flag eq "insert"){
     	if ($params->{name}=~ m/.{3,50}/ ,$params->{phone} =~ m/.{3,15}/, $params->{work_place_id} =~ m/.{1,50}/){
     		$c->model ('CrudInterface')->TelBook::Model::CrudInterface::add($params);
     		$c->stash->{status_msg} = "Добавлены новые данные Имя: $params->{name} Телефон : $params->{phone} Место работы : $params->{work_place_id}  ";
     		$c->stash (template => 'telbook/show_table.tt2');
			$c->forward('show_table');
		}
		else {
			$c->stash->{error_msg} = 'Введены неверные значения';
			$c->stash (template => 'telbook/show_table.tt2');
			$c->forward('show_table');

		}
    }
}


# Удаление 
sub delete :Chained('/') :PathPart('telbook/delete') {
	my ($self, $c, $id) = @_;

	$c->model ('CrudInterface')->connect_db();
	$c->model ('CrudInterface')->delete_row($id);
	$c->stash->{status_msg} = 'Строка со значением id : '.$id.' была удалена';
	$c->stash(template => 'telbook/show_table.tt2');
	$c->forward('show_table/0');
}

# Редактирование 
sub edit :Chained('/') :PathPart('telbook/edit'){
	my ($self, $c, $id, $flag) = @_;
	my $p = $c->request->params; 

	# Подключение и вывод запрашиваемой таблицы 
	$c->model ('CrudInterface')->connect_db();

	my $params = { 
		id => $id,
        name => $p->{name},
        phone => $p->{phone},
        work_place_id => $p->{work_place_id},
       };
 	$c->stash->{table_content} = TelBook::Model::CrudInterface::show($params);

    # Отправка данных на изменение 
	if ($flag eq "update"){
     		if ($params->{name}=~ m/.{3,50}/ ,$params->{phone} =~ m/.{3,15}/, $params->{work_place_id} =~ m/.{1,50}/){
     			$c->model ('CrudInterface')->TelBook::Model::CrudInterface::edit($params);
     			$c->stash->{table_content} = TelBook::Model::CrudInterface::show($params);
     			$c->stash (template => 'telbook/show_table.tt2');
				$c->stash->{status_msg} = 'Строка со значением id : '.$id.' была изменена';

			}

		else {
			$c->stash->{error_msg} = 'Введены неверные значения';
			$c->stash (template => 'telbook/show_table.tt2');
			$c->response->redirect( '/telbook/show_table/0' );

			$c->forward('show_table');
		}
	}	
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
