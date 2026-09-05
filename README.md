
# NAME

Path::Try - Path::Tiny wrapper for seamless file operations on potentially bad paths and oddly encoded file content

# SYNOPSIS

    package Path::Try::Example;

    use v5.44;

    use Path::Try;
    use List::Util qw'any';

    our @paths;

    sub add_paths (@path) {
        foreach my $line (
            grep {
                # No need to print errors manually, if used with qw':debug' or
                # environment variable PATH_TRY_DEBUG=1, Path::Tiny construction
                # parameters, caller and internal lexical variables, exception
                # text, etc. will be printed automatically with a stack trace

                $_->isa('Path::Try::Error')
            }    # Remove paths that threw an error
            map { path($_)->realpath }    # Check if filesystem can resolve path
            map { path($_)->lines_utf8( { chomp => 1 } ) }
            @path    # Read list of paths without dieing, even in case of bad
            # content encoding, non-existent paths, mixed absolute and relative
            # paths, path separatorrs, temporary network outages or local resource
            # over-utilization, etc.
        )
        {
            if ( my $path = path($line)->realpath ) {
                push @paths, $path
                unless any { $_ eq $path || $_->digest eq $path->digest }
                @paths    # Avoid duplicates (by path or by file checksum)
            }
        }
    }

# DESCRIPTION

Path::Try is a no-fail wrapper around Path::Tiny that removes the tedium of mid-job failure due to filesystem error or content encoding issues on paths that may be non-existent, inaccessible, or otherwise problematic.

...

# LICENSE

Copyright (C) Ian P Bradley.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Ian P Bradley <ian.bradley@studiocrabapple.com>
