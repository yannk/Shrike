package testcommon;
use strict;
use warnings;
use Cwd;
use File::Spec::Functions qw{catdir splitdir rel2abs catfile};
use DBI;

my $base = find_base();

my $filedb = catfile($base, "shrike.db");

sub get_dsn {
    return {
        data_source => "dbi:SQLite:dbname=$filedb",
        user        => '',
        password    => '',
    };
}

sub find_base {
    my $path = $INC{ 'testcommon.pm' };
    my @paths = splitdir( Cwd::realpath( rel2abs( $path )));
    pop @paths;
    pop @paths;
    return catdir(@paths);
}

sub init_db {
    my $table = shift;
    my $dsn = get_dsn();
    my $dbh = DBI->connect(
        $dsn->{data_source}, $dsn->{user}, $dsn->{password},
#        { RaiseError => 1, PrintError => 0 },
    );

    my $file = File::Spec->catfile($base, 'sql', $table . '.sql');
    open my $fh, $file or die "Can't open $file: $!";
    my $sql = do { local $/; <$fh> };
    close $fh;

    $dbh->do( $sql );

    $dbh->disconnect;
    return $dsn;
}

END {
    unlink $filedb;
};

1;
