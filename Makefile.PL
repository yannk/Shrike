use inc::Module::Install;

name     'Shrike';
all_from 'lib/Shrike.pm';
author   'Yann Kerhervé <yannk@cpan.org>';
license  'perl';

build_requires 'Test::More';
requires       'Moose';
requires       'Sub::Install';

auto_install;

WriteAll;

