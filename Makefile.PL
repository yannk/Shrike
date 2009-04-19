use inc::Module::Install;

name     'Shrike';
all_from 'lib/Shrike.pm';
author   'Yann Kerhervé <yannk@cpan.org>';
license  'perl';

build_requires 'Test::More';
requires       'Moose';
requires       'MooseX::Singleton';
requires       'Sub::Install';

test_requires  'Find::Lib';
test_requires  'Test::Exception';

auto_install;

WriteAll;

