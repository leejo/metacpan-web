use strict;
use warnings;

use Test::More;
use Module::Runtime qw( use_module );

my $model = use_module('MetaCPAN::Web::Model::ReleaseInfo')->new;

my $rt_prefix = $model->RT_URL_PREFIX;

sub bugtracker {
    return { resources => { bugtracker => {@_} } };
}

sub get_issues_ok {
    my ( $release, $bugs, $exp, $desc ) = @_;
    my $normalized = $model->_get_issues(
        { distribution => 'X', %$release },

        # Default to rt url, but let data override.
        { bugs => { rt => { source => "${rt_prefix}X", %$bugs } } },
    );
    is_deeply $normalized, $exp, $desc;
}

subtest 'get_issues' => sub {

    get_issues_ok(
        {},
        { active => 11 },
        { url    => "${rt_prefix}X", active => 11 },
        'no resources: rt url and count',
    );

    {
        my $bt = {
            web    => 'http://issues',
            mailto => 'foo@example.com',
        };

        get_issues_ok(
            bugtracker(%$bt),
            { active => 9 },
            { url    => $bt->{web} },
            'prefer bugtracker.web',
        );

        delete $bt->{web};

        get_issues_ok(
            bugtracker(%$bt),
            { active => 9 },
            { url    => 'mailto:' . $bt->{mailto} },
            'prefer bugtracker.mailto w/o web',
        );

        delete $bt->{mailto};

        get_issues_ok(
            bugtracker(%$bt),
            { active => 9 },
            { url    => "${rt_prefix}X", active => 9 },
            'assume rt w/o web or mailto (and include counts)',
        );
    }

    # Examples found in the api (distinct after replacing dist name with X):
    foreach my $url ( qw(
        http://rt.cpan.org
        http://rt.cpan.org/Dist/Display.html?Name=X
        http://rt.cpan.org/Dist/Display.html?Queue=X
        http://rt.cpan.org/Dist/Display.html?Status=Active&Queue=X
        http://rt.cpan.org/NoAuth/Bugs.html?Auth=X
        http://rt.cpan.org/NoAuth/Bugs.html?Dist=X
        http://rt.cpan.org/NoAuth/ReportBug.html?Queue=X
        http://rt.cpan.org/Public/Bug/Report.html?Queue=X
        http://rt.cpan.org/Public/Dist/Display.html?Name=X
        http://rt.cpan.org/Public/Dist/Display.html?Name=${dist}
        http://rt.cpan.org/Public/Dist/Display.html?X
        http://rt.cpan.org/Public/Dist/Display.html?Queue=X
        http://rt.cpan.org/Public/Dist/Display.html?Status=Active&Name=X
        http://rt.cpan.org/Ticket/Create.html?Queue=X
    ) )
    {
        get_issues_ok(
            bugtracker( web => $url ),
            { active => 12 },
            { url    => $url, active => 12 },
            "alternate rt url ($url): same url and rt count",
        );
    }

    get_issues_ok(
        bugtracker( web => 'http://canhaz' ),
        { source => 'http://canhaz', active => 13 },
        { url    => 'http://canhaz', active => 13 },
        'custom bugtracker.web with matching counts: use both'
    );

    # If a dist specifies a web, and then later removes it.
    get_issues_ok(
        {},
        { source => 'anything://else', active => 13 },
        { url    => "${rt_prefix}X" },
        'no resources: rt url; counts from old source: no count'
    );

    foreach my $url ( qw(
        https://github.com/user/repo
        http://github.com/user/repo
        https://github.com/user/repo/issues
        http://www.github.com/user/repo/issues
        https://www.github.com/user/repo/tree
    ) )
    {
        get_issues_ok(
            bugtracker( web => $url ),
            { source => 'https://github.com/user/repo', active => 3 },
            { url    => $url,                           active => 3 },
            "github variation ($url) matches: specified url and count",
        );
    }

};

done_testing;
