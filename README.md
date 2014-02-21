[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2014-02-20

    Copyright   : Copyright (C) 2014  Felix C. Stegerman
    Version     : v0.4.2

[]: }}}1

[![Gem Version](https://badge.fury.io/rb/eft.png)](http://badge.fury.io/rb/eft)

## Description
[]: {{{1

  eft - ruby + whiptail

  Eft is a ruby dsl that wraps `whiptail` [1] to display dialog boxes;
  see `example.rb` for examples.

```ruby
Eft.ask('What is your name?') do |q|
  q.on_ok { |name| puts "Hello, #{name}!" }
end
```

[]: }}}1

## Specs & Docs

```bash
$ rake spec   # TODO
$ rake docs
```

## TODO

  * specs! (how to automate tests of whiptail? - I don't know!)
  * --noitem?
  * choose between whiptail and dialog?
  * extend w/ dialog's other dialogs?
  * remove dependency on obfusk-util?

## License

  LGPLv3+ [2].

## References

  [1] Newt (and whiptail)
  --- http://en.wikipedia.org/wiki/Newt_(programming_library)

  [2] GNU Lesser General Public License, version 3
  --- http://www.gnu.org/licenses/lgpl-3.0.html

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
