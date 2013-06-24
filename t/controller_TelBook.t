use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TelBook';
use TelBook::Controller::TelBook;

ok( request('/telbook')->is_success, 'Request should succeed' );
done_testing();
