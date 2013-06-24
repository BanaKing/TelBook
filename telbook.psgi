use strict;
use warnings;

use TelBook;

my $app = TelBook->apply_default_middlewares(TelBook->psgi_app);
$app;

