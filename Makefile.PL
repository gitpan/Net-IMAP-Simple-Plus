use ExtUtils::MakeMaker;
use IO::Zlib;
use Archive::Tar;

my $tar = Archive::Tar->new;
   $tar->read('Net-IMAP-Simple-1.17.tar.gz', 1);

for my $f ($tar->list_files) {
    next unless $f =~ m/1\.17\/(?:lib|t)/;

    my $x = $f;
       $x =~ s/^Net-IMAP-Simple-1\.17\///;

    $tar->extract_file($f, $x);
}

die "problem extracting Net::IMAP::Simple" unless -d 'lib' and -d 't';

print "\n\npatching ...\n\n";

if( !$ENV{SKIP_CL1} ) {
    open IN, "collect1.patch" or die $!;
    open OUT, "|-", $^X, patch => '-p1' or die $!;
    print OUT $_ while <IN>;
    close IN; close OUT;
}

if( !$ENV{SKIP_CL2} ) {
    open IN, "collect2.patch" or die $!;
    open OUT, "|-", $^X, patch => '-p1' or die $!;
    print OUT $_ while <IN>;
    close IN; close OUT;
}

if( !$ENV{SKIP_COR} ) {
    open IN, "corion.patch" or die $!;
    open OUT, "|-", $^X, 'patch' or die $!;
    print OUT $_ while <IN>;
    close IN; close OUT;
}

if( !$ENV{SKIP_UHB} ) {
    open IN, "useless-hash-bug.patch" or die $!;
    open OUT, "|-", $^X, 'patch' or die $!;
    print OUT $_ while <IN>;
    close IN; close OUT;
}

print "\n\n";

unlink $_ for glob("lib/Net/IMAP/Simple.pm.*"); # some patches add .orig
unlink $_ for glob("lib/Net/IMAP/Simple.pm[A-Za-z]*"); # some add Orig

WriteMakefile(
    NAME         => 'Net::IMAP::Simple::Plus',
    VERSION_FROM => 'Plus.pm',
    AUTHOR       => 'Paul Miller <jettero@cpan.org>',
);