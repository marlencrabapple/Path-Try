requires 'perl', 'v5.40';

requires 'Unicode::UTF8';
requires 'IO::Handle::Common';
requires 'Object::Pad';
requires 'Path::Tiny';
requires 'Syntax::Keyword::Try';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

on 'develop' => sub {
    recommends 'Minilla';
    recommends 'Perl::Tidy';
    recommends 'Perl::Critic';
    recommends 'Perl::Critic::Community';
    recommends 'Devel::Trace';
};

on 'build' => sub {
    requires 'Module::Build::Tiny';
};

