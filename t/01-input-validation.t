use strict;
use warnings;
use lib 'lib';
use Mojolicious::Plugin::InputValidation;
use Test::More;

is err({ foo => '2018-07-27T11:23:47Z' }, { foo => iv_datetime }),
    '', 'simple matching hash';

is err({ bar => 42 }, { foo => iv_datetime }),
    "Unexpected keys 'bar' found at path /",
    'simple hash - misspelled key';

is err({ foo => 42 }, { foo => iv_datetime, bar => iv_datetime }),
    "Missing keys 'bar' at path /",
    'simple hash - missing key';

is err({ foo => '2018-07-27T11:23:47' }, { foo => iv_datetime }),
    "Value '2018-07-27T11:23:47' does not match datetime format at path /foo",
    'simple hash - wrong datetime format';

is err({ foo => { bar => 42 } }, { foo => { bar => iv_int } }),
    '', 'multilevel hash with integer';
is err({ foo => { bar => 42.3 } }, { foo => { bar => iv_float } }),
    '', 'multilevel hash with float';
is err({ foo => { bar => 42.3 } }, { foo => { bar => iv_int } }),
    "Value '42.3' is not an integer at path /foo/bar",
    'multilevel hash with integer';
is err({ foo => { bar => 42 } }, { foo => { bar => iv_float } }),
    "Value '42' is not a float at path /foo/bar",
    'multilevel hash with float';

is err({ foo => { bar => 'flubberworms47' } }, { foo => { bar => iv_word } }),
    '', 'multilevel hash with word characters';
is err({ foo => { bar => 'flubber-worms47' } }, { foo => { bar => iv_word } }),
    "Value 'flubber-worms47' does not match word characters only at path /foo/bar",
    'multilevel hash with word characters';

is err({ foo => ['2018-07-27T11:23:47Z'] }, { foo => [iv_datetime] }),
    '', 'array with one element';
is err({ foo => [1, 2, 3, 4, 'a'] }, { foo => iv_array(of => iv_int, max => 5) }),
    "Value 'a' is not an integer at path /foo/4", 'array with one wrong element';

is err({ bar => 'flubber-worms47' }, { bar => iv_any(pattern => qr/flubber.*/) }),
     '', 'hash with pattern (1)';

is err({ bar => 'flubber-worms47' }, { bar => iv_any(pattern => qr/(flubberworms47|test|test2)/) }),
     "Value 'flubber-worms47' does not match at path /bar",
     'hash with pattern (2)';

is err({ foo => { bar => 'flubber-worms47' } }, { foo => { bar => iv_any(pattern => qr/(flubber-worms47|test|test2)/) } }),
    '', 'hash with hash with pattern (1)';

is err({ foo => { bar => 'worms47' } }, { foo => { bar => iv_any(pattern => qr/(flubber-worms47|test|test2)/) } }),
   "Value 'worms47' does not match at path /foo/bar",
   'hash with hash with pattern (2)';

is err({ foo => [{ bar => 'flubber-worms47' }] }, { foo => iv_array(of => { bar => iv_any(pattern => qr/(flubber-worms47|test|test2)/) }) }),
    '', 'hash with array of hashes (1)';

is err({ foo => [{ bar => 'worms47' }] }, { foo => iv_array(of => { bar => iv_any(pattern => qr/(flubber-worm47|test|test2)/) }) }),
    "Value 'worms47' does not match at path /foo/0/bar",
    'hash with array of hashes (2)';

done_testing;

sub err { Mojolicious::Plugin::InputValidation::_validate_structure(@_) }
