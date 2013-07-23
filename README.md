[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2013-07-23

    Copyright   : Copyright (C) 2013  Felix C. Stegerman
    Version     : v0.0.1.dev

[]: }}}1

## TODO

  * finish!

## Description
[]: {{{1

  eft - ruby + whiptail

  Eft is a ruby dsl that wraps whiptail [1] to display dialog boxes;
  see example.rb for usage examples.

```ruby
Eft.ask('What is your name?') do |q|
  q.on_ok { |name| puts "Hello, #{name}!" }
end
```

[]: }}}1

## License
[]: {{{1

  GPLv2 [2].

[]: }}}1

## References
[]: {{{1

  [1] Newt (and whiptail)
  --- http://en.wikipedia.org/wiki/Newt_(programming_library)

  [2] GNU General Public License, version 2
  --- http://www.opensource.org/licenses/GPL-2.0

[]: }}}1

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
