package Util::Underscore;
#ABSTRACT: Common helper functions without having to import them

use strict;
use warnings;
no warnings 'once';

use version 0.77 (); our $VERSION = version->declare('v1.0.1');

use Scalar::Util    1.36        ();
use List::Util      1.35        ();
use List::MoreUtils 0.07        ();
use Carp                        ();
use Safe::Isa       1.000000    ();
use Try::Tiny                   ();


BEGIN {
    # check if a competing "_" exists
    if (keys %{_::}) {
        Carp::confess qq(The package "_" has already been defined);
    }
}

BEGIN {
    # prevent other "_" packages from being loaded:
    # Just setting the ${INC} entry would fail too silently,
    # so we also rigged the "import" method.
    
    $INC{'_.pm'} = *_::import = sub {
        Carp::confess qq(The "_" package is internal to Util::Underscore)
                    . qq(and must not be imported directly.\n);
    };
}



*_::class   = \&Scalar::Util::blessed;
*_::blessed = \&Scalar::Util::blessed;

*_::ref_addr = \&Scalar::Util::refaddr;

*_::ref_type = \&Scalar::Util::reftype;

*_::ref_weaken = \&Scalar::Util::weaken;

*_::ref_unweaken = \&Scalar::Util::unweaken;

*_::ref_is_weak = \&Scalar::Util::isweak;

*_::new_dual = \&Scalar::Util::dualvar;

*_::is_dual = \&Scalar::Util::isdual;

*_::is_vstring = \&Scalar::Util::isvstring;

*_::is_numeric = \&Scalar::Util::looks_like_number;

*_::is_open = \&Scalar::Util::openhandle;

*_::is_readonly = \&Scalar::Util::readonly;

sub _::prototype ($;$) {    ## no critic ProhibitSubroutinePrototypes
    if (@_ == 2) {
        goto &Scalar::Util::set_prototype if @_ == 2;
    }
    if (@_ == 1) {
        my ($coderef) = @_;
        return prototype $coderef;
    }
    else {
        Carp::confess '_::prototype(&;$) takes exactly one or two arguments';
    }
}

*_::is_tainted = \&Scalar::Util::tainted;


*_::reduce = \&List::Util::reduce;

*_::any = \&List::Util::any;

*_::all = \&List::Util::all;

*_::none = \&List::Util::none;

*_::first = \&List::MoreUtils::first_value;

*_::first_index = \&List::MoreUtils::first_index;

*_::last = \&List::MoreUtils::last_value;

*_::last_index = \&List::MoreUtils::last_index;

*_::max     = \&List::Util::max;
*_::max_str = \&List::Util::maxstr;

*_::min     = \&List::Util::min;
*_::min_str = \&List::Util::minstr;

*_::sum = \&List::Util::sum;

*_::product = \&List::Util::product;

*_::pairgrep = \&List::Util::pairgrep;

*_::pairfirst = \&List::Util::pairfirst;

*_::pairmap = \&List::Util::pairmap;

*_::shuffle = \&List::Util::shuffle;

*_::natatime = \&List::MoreUtils::natatime;

sub _::zip {
    goto &List::MoreUtils::zip;  # adios, prototypes!
}

*_::uniq = \&List::MoreUtils::uniq;

*_::part = \&List::MoreUtils::part;

*_::each_array= \&List::MoreUtils::each_arrayref;


*_::carp = \&Carp::carp;

*_::cluck = \&Carp::cluck;

*_::croak = \&Carp::croak;

*_::confess = \&Carp::confess;


*_::isa = $Safe::Isa::_isa;

*_::does = $Safe::Isa::_DOES;

*_::can = $Safe::Isa::_can;

*_::safecall = $Safe::Isa::_call_if_object;


*_::try     = \&Try::Tiny::try;
*_::catch   = \&Try::Tiny::catch;
*_::finally = \&Try::Tiny::finally;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Util::Underscore - Common helper functions without having to import them

=head1 VERSION

version v1.0.1

=head1 SYNOPSIS

    use Util::Underscore;
    
    _::croak "$foo must do Some::Role" if not _::does($foo, 'Some::Role');

=head1 DESCRIPTION

This module contains various utility functions, and makes them accessible through the C<_> package.
This allows the use of these utilities (a) without much per-usage overhead and (b) without namespace pollution.

It contains functions from the following modules:

=over 4

=item *

L<Scalar::Util>

=item *

L<List::Util>

=item *

L<List::MoreUtils>

=item *

L<Carp>

=item *

L<Safe::Isa>, which contains convenience functions for L<UNIVERSAL>

=item *

L<Try::Tiny>

=back

Not all functions from those are available, and some have been renamed.

=head1 FUNCTION REFERENCE

=head2 Scalar::Util

=over 4

=item C<$str = _::blessed $object>

=item C<$str = _::class $object>

wrapper for C<Scalar::Util::blessed>

=item C<$int = _::ref_addr $ref>

wrapper for C<Scalar::Util::refaddr>

=item C<$str = _::ref_type $ref>

wrapper for C<Scalar::Util::reftype>

=item C<_::ref_weaken $ref>

wrapper for C<Scalar::Util::weaken>

=item C<_::ref_unweaken $ref>

wrapper for C<Scalar::Util::unweaken>

=item C<$bool = _::ref_is_weak $ref>

wrapper for C<Scalar::Util::isweak>

=item C<$scalar = _::new_dual $num, $str>

wrapper for C<Scalar::Util::dualvar>

=item C<$bool = _::is_dual $scalar>

wrapper for C<Scalar::Util::isdual>

=item C<$bool = _::is_vstring $scalar>

wrapper for C<Scalar::Util::isvstring>

=item C<$bool = _::is_numeric $scalar>

wrapper for C<Scalar::Util::looks_like_number>

=item C<$fh = _::is_open $fh>

wrapper for C<Scalar::Util::openhandle>

=item C<$bool = _::is_readonly $scalar>

wrapper for C<Scalar::Util::readonly>

=item C<$str = _::prototype \&code>

=item C<_::prototype \&code, $new_proto>

gets or sets the prototype, wrapping either C<CORE::prototype> or C<Scalar::Util::set_prototype>

=item C<$bool = _::is_tainted $scalar>

wrapper for C<Scalar::Util::tainted>

=back

=head2 List::Util and List::MoreUtils

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

=head2 Carp

=over 4

=item C<_::carp "Message">

wrapper for C<Carp::carp>

=item C<_::cluck "Message">

wrapper for C<Carp::cluck>

=item C<_::croak "Message">

wrapper for C<Carp::croak>

=item C<_::confess "Message">

wrapper for C<Carp::confess>

=back

=head2 UNIVERSAL

...and other goodies from C<Safe::Isa>

=over 4

=item C<$bool = _::isa $object, 'Class'>

wrapper for C<$Safe::Isa::_isa>

=item C<$code = _::can $object, 'method'>

wrapper for C<$Safe::Isa::_can>

=item C<$bool = _::does $object, 'Role'>

wrapper for C<$Safe::Isa::_DOES>

=item C<< any = $maybe_object->_::safecall(method => @args) >>

wrapper for C<$Safe::Isa::_call_if_object>

=back

=head2 Try::Tiny

The following keywords are available:

=over 4

=item *

C<_::try>

=item *

C<_::catch>

=item *

C<_::finally>

=back

They are all direct aliases for their namesakes in C<Try::Tiny>.

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
