package Util::Underscore;

#ABSTRACT: Common helper functions without having to import them

use strict;
use warnings;

use version 0.77; our $VERSION = qv('v1.1.0');

use Scalar::Util 1.36    ();
use List::Util 1.35      ();
use List::MoreUtils 0.07 ();
use Carp       ();
use Try::Tiny  ();
use Data::Dump ();
use overload   ();


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

    ## no critic (RequireLocalizedPunctuationVars)
    $INC{'_.pm'} = *_::import = sub {
        Carp::confess qq(The "_" package is internal to Util::Underscore)
            . qq(and must not be imported directly.\n);
    };
}

my $assign_aliases;

BEGIN {
    $assign_aliases = sub {
        my ($pkg, %aliases) = @_;
        no strict 'refs';    ## no critic (ProhibitNoStrict)
        while (my ($this, $that) = each %aliases) {
            my $target = "_::${this}";
            my $source = "${pkg}::${that}";
            *{$target} = *{$source}{CODE}
                // Carp::croak "Unknown subroutine $source in assign_aliases";
        }
    };
}


# From now, every function is in the "_" package
## no critic (ProhibitMultiplePackages)
package    # Hide from PAUSE
    _;

## no critic (RequireArgUnpacking, RequireFinalReturn, ProhibitSubroutinePrototypes)

# Predeclare a few things so that we can use them in the sub definitions below.
sub blessed(_);
sub ref_type(_);


$assign_aliases->('Scalar::Util', new_dual => 'dualvar',);

sub is_dual(_) {
    goto &Scalar::Util::isdual;
}

sub is_vstring(_) {
    goto &Scalar::Util::isvstring;
}

sub is_readonly(_) {
    goto &Scalar::Util::readonly;
}

sub is_tainted (_) {
    goto &Scalar::Util::tainted;
}

sub is_plain(_) {
    defined $_[0]
        && !defined ref_type $_[0];
}

sub is_identifier(_) {
    defined $_[0]
        && scalar($_[0] =~ /\A [^\W\d]\w* \z/xsm);
}

sub is_package(_) {
    defined $_[0]
        && scalar($_[0] =~ /\A [^\W\d]\w* (?: [:][:]\w+ )* \z/xsm);
}


sub is_numeric(_) {
    goto &Scalar::Util::looks_like_number;
}

sub is_int(_) {
    ## no critic (ProhibitEnumeratedClasses)
    defined $_[0]
        && !defined ref_type $_[0]
        && scalar($_[0] =~ /\A [-]? [0-9]+ \z/xsm);
}

sub is_uint(_) {
    ## no critic (ProhibitEnumeratedClasses)
    defined $_[0]
        && !defined ref_type $_[0]
        && scalar($_[0] =~ /\A [0-9]+ \z/xsm);
}


sub ref_addr(_) {
    goto &Scalar::Util::refaddr;
}

sub ref_type(_) {
    goto &Scalar::Util::reftype;
}

sub ref_weaken(_) {
    goto &Scalar::Util::weaken;
}

sub ref_unweaken(_) {
    goto &Scalar::Util::unweaken;
}

sub ref_is_weak(_) {
    goto &Scalar::Util::isweak;
}

sub is_ref(_) {
    defined($_[0])
        && defined ref_type $_[0]
        && !defined blessed $_[0];
}

sub is_scalar_ref(_) {
    defined($_[0])
        && ('SCALAR' eq ref $_[0]
        || overload::Method($_[0], '${}'));
}

sub is_array_ref(_) {
    defined($_[0])
        && ('ARRAY' eq ref $_[0]
        || overload::Method($_[0], '@{}'));
}

sub is_hash_ref(_) {
    defined($_[0])
        && ('HASH' eq ref $_[0]
        || overload::Method($_[0], '%{}'));
}

sub is_code_ref(_) {
    defined($_[0])
        && ('CODE' eq ref $_[0]
        || overload::Method($_[0], '&{}'));
}

sub is_glob_ref(_) {
    defined($_[0])
        && ('GLOB' eq ref $_[0]
        || overload::Method($_[0], '*{}'));
}

sub is_regex(_) {
    defined(blessed $_[0])
        && ('Regexp' eq ref $_[0]
        || overload::Method($_[0], 'qr'));
}


sub blessed(_) {
    goto &Scalar::Util::blessed;
}

{
    no warnings 'once';    ## no critic (ProhibitNoWarnings)
    *class = \&blessed;
}

sub is_object(_) {
    defined blessed $_[0];
}

sub class_isa($$) {
    is_package($_[0])
        && $_[0]->isa($_[1]);
}

sub class_does($$) {
    is_package($_[0])
        && $_[0]->DOES($_[1]);
}

sub class_can($$) {
    is_package($_[0])
        && $_[0]->can($_[1]);
}

sub isa($$) {
    blessed $_[0]
        && $_[0]->isa($_[1]);
}

sub does($$) {
    blessed $_[0]
        && $_[0]->DOES($_[1]);
}

{
    no warnings 'once';    ## no critic (ProhibitNoWarnings)
    *is_instance = \&does;
}

sub can($$) {
    blessed $_[0]
        && $_[0]->can($_[1]);
}

sub safecall($$@) {
    my $self = shift;
    my $meth = shift;
    return if not blessed $self;
    $self->$meth(@_);
}


$assign_aliases->(
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

$assign_aliases->(
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


BEGIN {
    $assign_aliases->(
        'Carp',
        carp    => 'carp',
        cluck   => 'cluck',
        croak   => 'croak',
        confess => 'confess',
    );
}

$assign_aliases->(
    'Try::Tiny',
    try     => 'try',
    catch   => 'catch',
    finally => 'finally',
);

sub carpf($@) {
    my $pattern = shift;
    @_ = sprintf $pattern, @_;
    goto &carp;
}

sub cluckf($@) {
    my $pattern = shift;
    @_ = sprintf $pattern, @_;
    goto &cluck;
}

sub croakf($@) {
    my $pattern = shift;
    @_ = sprintf $pattern, @_;
    goto &croak;
}

sub confessf($@) {
    my $pattern = shift;
    @_ = sprintf $pattern, @_;
    goto &confess;
}


$assign_aliases->('Scalar::Util', is_open => 'openhandle',);

sub _::prototype ($;$) {
    if (@_ == 2) {
        goto &Scalar::Util::set_prototype if @_ == 2;
    }
    if (@_ == 1) {
        my ($coderef) = @_;
        return prototype $coderef;    # Calls CORE::prototype
    }
    else {
        Carp::confess '_::prototype($;$) takes exactly one or two arguments';
    }
}

$assign_aliases->(
    'Data::Dump',
    pp => 'pp',
    dd => 'dd',
);


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Util::Underscore - Common helper functions without having to import them

=head1 VERSION

version v1.1.0

=head1 SYNOPSIS

    use Util::Underscore;
    
    _::croak "$foo must do Some::Role" if not _::does($foo, 'Some::Role');

=head1 DESCRIPTION

This module contains various utility functions, and makes them accessible through the C<_> package.
This allows the use of these utilities (a) without much per-usage overhead and (b) without namespace pollution.

It contains functions from the following modules:

=over 4

=item *

L<Scalar::Util|Scalar::Util>

=item *

L<List::Util|List::Util>

=item *

L<List::MoreUtils|List::MoreUtils>

=item *

L<Carp|Carp>

=item *

L<Try::Tiny|Try::Tiny>

=back

Not all functions from those are available, and some have been renamed.

=head1 FUNCTION REFERENCE

=head2 Scalars

These functions are about manipulating scalars.

=over 4

=item C<$scalar = _::new_dual $num, $str>

wrapper for C<Scalar::Util::dualvar>

=item C<$bool = _::is_dual $_>

wrapper for C<Scalar::Util::isdual>

=item C<$bool = _::is_vstring $_>

wrapper for C<Scalar::Util::isvstring>

=item C<$bool = _::is_readonly $_>

wrapper for C<Scalar::Util::readonly>

=item C<$bool = _::is_tainted $_>

wrapper for C<Scalar::Util::tainted>

=item C<$bool = _::is_plain $_>

Checks that the value is C<defined> and not a reference of any kind.
This is as close as Perl gets to checking for a string.

=item C<$bool = _::is_identifier $_>

Checks that the given string would be a legal identifier:
a letter followed by zero or more word characters.

=item C<$bool = _::is_package $_>

Checks that the given string is a valid package name.
It only accepts C<Foo::Bar> notation, not the C<Foo'Bar> form.
This does not assert that the package actually exists.

=back

=head2 Numbers

=over 4

=item C<$bool = _::is_numeric $_>

wrapper for C<Scalar::Util::looks_like_number>

=item C<$bool = _::is_int $_>

The argument is a plain scalar,
and its stringification matches a signed integer.

=item C<$bool = _::is_uint $_>

Like C<_::is_int>, but the stringification must match an unsigned integer
(i.e. the number is zero or positive).

=back

=head2 References

=over 4

=item C<$int = _::ref_addr $_>

wrapper for C<Scalar::Util::refaddr>

=item C<$str = _::ref_type $_>

wrapper for C<Scalar::Util::reftype>

=item C<_::ref_weaken $_>

wrapper for C<Scalar::Util::weaken>

=item C<_::ref_unweaken $_>

wrapper for C<Scalar::Util::unweaken>

=item C<$bool = _::ref_is_weak $_>

wrapper for C<Scalar::Util::isweak>

=back

=head3 Type Validation

These are inspired from C<Params::Util> and C<Data::Util>.

The I<reference validation> routines take one argument (or C<$_>) and return a boolean value.
They return true when the value is intended to be used as a reference of that kind:
either C<ref $arg> is of the requested type,
or it is an overloaded object that can be used as a reference of that kind.
It will not be checked that an object claims to perform an appropriate role (e.g. C<< $arg->DOES('ARRAY') >>).

=over 4

=item *

C<_::is_ref> (any nonblessed reference)

=item *

C<_::is_scalar_ref>

=item *

C<_::is_array_ref>

=item *

C<_::is_hash_ref>

=item *

C<_::is_code_ref>

=item *

C<_::is_glob_ref>

=item *

C<_::is_regex> (note that regexes are blessed objects, not plain references)

=back

=head2 Classes and Objects

=over 4

=item C<$str = _::blessed $_>

=item C<$str = _::class $_>

wrapper for C<Scalar::Util::blessed>

=item C<$bool = _::is_object $_>

Checks that the argument is a blessed object.
It's just an abbreviation for C<defined _::blessed $_>

=item C<$bool = _::class_isa $class, $supertype>

Checks that the C<$class> inherits from the given C<$supertype>, both given as strings.
In most cases, one should use C<_::class_does> instead.

=item C<$bool = _::class_does $class, $role>

Checks that the C<$class> performs the given C<$role>, both given as strings.

=item C<$bool = _::isa $object, $class>

Checks that the C<$object> inherits from the given class.
In most cases, one should use C<_::does> or C<_::is_instance> instead.

=item C<$code = _::can $object, 'method'>

Checks that the given C<$object> can perform the C<method>.
Returns C<undef> on failure, or the appropriate code ref on success,
so that one can do C<< $object->$code(@args) >> afterwards.

=item C<$bool = _::is_instance $object, $role>

=item C<$bool = _::does $object, $role>

Checks that the given C<$object> can perform the C<$role>.

=item C<< any = $maybe_object->_::safecall(method => @args) >>

This will call the C<method> only if the C<$maybe_object> is a blessed object.
We do not check that the object C<can> perform the method, so this might still raise an exception.

Context is propagated correctly to the method call.
If the C<$maybe_object> is not an object, this will simply return.
In scalar context, this evaluates to C<undef>, in list context this is the empty list.

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

=head2 Exception handling

The functions C<_::carp>, C<_::cluck>, C<_::croak>, and C<_::confess> from the C<Carp> module are available.
They all take a list of strings as argument.
How do they differ from each other?

    Stack Trace || Fatal    | Warning
    ------------##====================
        No      || croak    | carp
        Yes     || confess  | cluck

How do they differ from Perl's builtin C<die> and C<warn>?
The error messages of C<die> and C<warn> are located on the line where the exception is raised.
This makes debugging hard when the error points to some internal function of a module you are using,
as this provides no information on where your client code made a mistake.
The C<Carp> family of error functions report the error from the point of usage, and optionally provide stack traces.
If you write a module, please use the C<Carp> functions instead of plain C<die>.

Additionally, the variants C<_::carpf>, C<_::cluckf>, C<_::croakf>, and C<_::confessf> are provided.
These take a C<sprintf> patterns as first argument: C<_::carpf "pattern", @arguments>.

To handle errors, the following keywords from C<Try::Tiny> are available:

=over 4

=item *

C<_::try>

=item *

C<_::catch>

=item *

C<_::finally>

=back

They are all direct aliases for their namesakes in C<Try::Tiny>.

=head2 Miscellaneous Functions

=over 4

=item C<$fh = _::is_open $fh>

wrapper for C<Scalar::Util::openhandle>

=item C<$str = _::prototype \&code>

=item C<_::prototype \&code, $new_proto>

gets or sets the prototype, wrapping either C<CORE::prototype> or C<Scalar::Util::set_prototype>

=item C<$instance = _::package $str>

This will construct a new C<Package::Stash> instance.

=back

C<Data::Dump> is an alternative to C<Data::Dumper>.
The main difference is the output format: C<Data::Dump> output tends to be easier to read.

=over 4

=item C<$str = _::pp @values>

wrapper for C<Data::Dump::pp>

=item C<_::dd @values>

wrapper for C<Data::Dump::dd>.

=back

=head1 RELATED MODULES

The following modules were once considered for inclusion or were otherwise influental in the design of this collection:

=over 4

=item *

L<Data::Util|Data::Util>

=item *

L<Params::Util|Params::Util>

=item *

L<Safe::Isa|Safe::Isa>

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
