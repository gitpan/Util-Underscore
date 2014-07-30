package Util::Underscore::ListUtils;

#ABSTRACT: Interface to List::Util and List::MoreUtils
#CONTRIBUTOR: Lukas Atkinson (cpan: AMON) <amon@cpan.org>
#CONTRIBUTOR: Olivier Mengué (cpan: DOLMEN) <dolmen@cpan.org>

use strict;
use warnings;


## no critic (ProhibitMultiplePackages)
package    # hide from PAUSE
    _;

## no critic (ProtectPrivateVars)
$Util::Underscore::_ASSIGN_ALIASES->(
    'List::Util',
    reduce    => 'reduce',
    any       => 'any',
    all       => 'all',
    none      => 'none',
    max       => 'max',
    max_str   => 'maxstr',
    min       => 'min',
    min_str   => 'minstr',
    sum       => 'sum',
    product   => 'product',
    pairgrep  => 'pairgrep',
    pairfirst => 'pairfirst',
    pairmap   => 'pairmap',
    shuffle   => 'shuffle',
);

## no critic (ProtectPrivateVars)
$Util::Underscore::_ASSIGN_ALIASES->(
    'List::MoreUtils',
    first       => 'first_value',
    first_index => 'first_index',
    last        => 'last_value',
    last_index  => 'last_index',
    natatime    => 'natatime',
    uniq        => 'uniq',
    part        => 'part',
    each_array  => 'each_arrayref',
);

sub zip {
    goto &List::MoreUtils::zip;    # adios, prototypes!
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Util::Underscore::ListUtils - Interface to List::Util and List::MoreUtils

=head1 VERSION

version v1.2.0_1

=head1 FUNCTION REFERENCE

=over 4

=item C<$scalar = _::reduce { BLOCK } @list>

wrapper for C<List::Util::reduce>

=item C<$bool = _::any { PREDICATE } @list>

wrapper for C<List::Util::any>

=item C<$bool = _::all { PREDICATE } @list>

wrapper for C<List::Util::all>

=item C<$bool = _::none { PREDICATE } @list>

wrapper for C<List::Util::none>

=item C<$scalar = _::first { PREDICATE } @list>

wrapper for C<List::MoreUtils::first_value>

=item C<$int = _::first_index { PREDICATE } @list>

wrapper for C<List::MoreUtils::first_index>

=item C<$scalar = _::last { PREDICATE } @list>

wrapper for C<List::MoreUtils::last_value>

=item C<$int = _::last_index { PREDICATE } @list>

wrapper for C<List::MoreUtils::last_index>

=item C<$num = _::max     @list>

=item C<$str = _::max_str @list>

wrappers for C<List::Util::max> and C<List::Util::maxstr>, respectively.

=item C<$num = _::min     @list>

=item C<$str = _::min_str @list>

wrappers for C<List::Util::min> and C<List::Util::minstr>, respectively.

=item C<$num = _::sum 0, @list>

wrapper for C<List::Util::sum>

=item C<$num = _::product @list>

wrapper for C<List::Util::product>

=item C<%kvlist = _::pairgrep { PREDICATE } %kvlist>

wrapper for C<List::Util::pairgrep>

=item C<($k, $v) = _::pairfirst { PREDICATE } %kvlist>

wrapper for C<List::Util::pairfirst>

=item C<%kvlist = _::pairmap { BLOCK } %kvlist>

wrapper for C<List::Util::pairmap>

=item C<@list = _::shuffle @list>

wrapper for C<List::Util::shuffle>

=item C<$iter = _::natatime $size, @list>

wrapper for C<List::MoreUtils::natatime>

=item C<@list = _::zip \@array1, \@array2, ...>

wrapper for C<List::MoreUtils::zip>

Unlike C<List::MoreUtils::zip>, this function directly takes I<array
references>, and not array variables. It still uses the same implementation.
This change makes it easier to work with anonymous arrayrefs, or other data that
isn't already inside a named array variable.

=item C<@list = _::uniq @list>

wrapper for C<List::MoreUtils::uniq>

=item C<@list = _::part { INDEX_FUNCTION } @list>

wrapper for C<List::MoreUtils::part>

=item C<$iter = _::each_array \@array1, \@array2, ...>

wrapper for C<List::MoreUtils::each_arrayref>

=back

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/latk/Underscore/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Lukas Atkinson <amon@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Lukas Atkinson.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
