# --                                                            ; {{{1
#
# File        : eft.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-23
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'tempfile'

require 'obfusk/util/run'
require 'obfusk/util/term'

module Eft

  # --default-item string
  # --separate-output
  # --scrolltext

  # --yesno text height width
  # --inputbox text height width [init] > STDERR
  # --passwordbox text height width
  # --menu text height width menu-height [ tag item ] ...
  # --checklist text height width list-height [ tag item status ] ...
  # --radiolist text height width list-height [ tag item status ] ...
  # --gauge text height width percent

  # for (( i = 0; i <= 100; ++i)); do sleep .1; echo $i; echo XXX;
  # echo $i; echo FOO $i; echo XXX; done | whiptail --gauge text 10 70
  # 10

  # 0 -> yes/ok
  # 1 -> no/cancel
  # -1 (255) -> esc/???

  # --foo -- ...

  # --

  OU = Obfusk::Util

  # --

  WHIPTAIL = 'whiptail'

  EXIT = { ok_yes: 0, cancel_no: 1, esc: 255 }

  WHAT = {                                                      # {{{1
    show_info:  '--infobox',
    show_msg:   '--msgbox',
    show_text:  '--textbox',
    ask:        '--inputbox',
    ask_pass:   '--passwordbox',
    ask_yesno:  '--yesno',
    check:      '--checklist',
    menu:       '--menu',
    radio:      '--radiolist',
    gauge:      '--gauge',
  }                                                             # }}}1

  OPTS = {                                                      # {{{1
    all: {
      title:          ->(t) { ['--title', t] },
      backtitle:      ->(t) { ['--backtitle', t] },
    },
    ok: {
      ok_button:      ->(t) { ['--ok-button', t] },
    },
    cancel: {
      cancel_button:  ->(t) { ['--cancel-button', t] },
      no_cancel:      ->(b) { b ? ['--nocancel'] : [] },
    },
    yes: {
      yes_button:     ->(t) { ['--yes-button', t] },
    },
    no: {
      no_button:      ->(t) { ['--no-button', t] },
      default_no:     ->(b) { b ? ['--default-no'] : [] },
    },
    menu: {
      default_item:   ->(i) { ['--default-item', i] },
    },
  }                                                             # }}}1

  OPT = ->(o,x) { o.select { |k,v| OPTS[x][k] }
                      .map { |k,v| OPTS[x][k][v] } }

  # --

  class Error < RuntimeError; end

  class Cfg
    def initialize(cfg = {})
      @cfg = cfg
    end
    def config
      @cfg.freeze
    end
  end

  # --

  module CfgEsc
    def on_esc(&b)
      @cfg[:on_esc] = b
    end
  end

  module CfgOK
    def on_ok(&b)
      @cfg[:on_ok] = b
    end
  end

  module CfgCancel
    def on_cancel(&b)
      @cfg[:on_cancel] = b
    end
  end

  module CfgYes
    def on_yes(&b)
      @cfg[:on_yes] = b
    end
  end

  module CfgNo
    def on_no(&b)
      @cfg[:on_no] = b
    end
  end

  # --

  class CfgShowInfo < Cfg
  end

  class CfgShowMsg < Cfg
    include CfgEsc, CfgOK
    def config
      c = super
      d = c.merge on_ok: ->(e) { c[:on_ok][] if c[:on_ok] }
      d.freeze
    end
  end

  class CfgShowText < Cfg
    include CfgEsc, CfgOK
    def config
      c = super
      d = c.merge on_ok: ->(e) { c[:on_ok][] if c[:on_ok] }
      d.freeze
    end
  end

  class CfgAsk < Cfg
    include CfgEsc, CfgOK, CfgCancel
    def config
      c = super
      d = c.merge on_ok: ->(e) { c[:on_ok][] if c[:on_ok] }
      d.freeze
    end
  end

  class CfgAskPass < Cfg
    include CfgEsc, CfgOK, CfgCancel
    def config
      c = super
      d = c.merge on_ok: ->(e) { c[:on_ok][e.first] if c[:on_ok] }
      d.freeze
    end
  end

  class CfgAskYesNo < Cfg
    include CfgEsc, CfgYes, CfgNo
    # ...
  end

  class CfgCheck < Cfg
    include CfgEsc, CfgOK, CfgCancel
    # ...
  end

  class CfgMenu < Cfg
    include CfgEsc, CfgOK, CfgCancel
    # ...
  end

  class CfgRadio < Cfg
    include CfgEsc, CfgOK, CfgCancel
    # ...
  end

  class CfgGauge < Cfg
    # ...
  end

  # --

  # show message w/o OK button, don't clear screen
  def self.show_info(text, opts = {})
    _whip :show_info, text, CfgShowInfo, opts, [], nil
  end

  # show message w/ OK button
  def self.show_msg(text, opts = {}, &b)
    _whip :show_msg, text, CfgShowMsg, opts, [], b
  end

  # show file contents or text
  def self.show_text(opts = {}, &b)                             # {{{1
    f = ->(x) { _whip :show_text, x, CfgShowText, opts, [], b }
    file = opts[:file]; text = opts[:text]
    raise Error, 'can\'t have file and text' if file && text
    raise Error, 'must have file or text' if !file && !text
    if file
      f[file]
    else
      Tempfile.open('eft') { |x| x.write text; x.close; f[x.path] }
    end
  end                                                           # }}}1

  # --

  # ask for line of input
  def self.ask(text, opts = {}, &b)
    _whip :ask, text, CfgAsk, opts, [], b
  end

  # ask for password
  def self.ask_pass(text, opts = {}, &b)
  end

  # choose yes or no
  def self.ask_yesno(text, opts = {}, &b)
  end

  # --

  # choose checkboxes
  def self.check(opts = {}, &b)
  end

  # choose from menu
  def self.menu(opts = {}, &b)
  end

  # choose radiobox
  def self.radio(opts = {}, &b)
  end

  # --

  # show gauge
  def self.gauge(opts = {}, &b)
  end

  # --

  # process options, run whiptail, call on_{ok,yes,cancel,no,esc},
  # return { exit:, err: }
  # @raise Error if unknown exitstatus
  def self._whip(what, text, cfg, opts, args, b)                # {{{1
    x = cfg.new; b[x] if b; c = x.config
    o = [                               OPT[opts,:all],
      cfg.method_defined?(:on_ok)     ? OPT[opts,:ok]     : [],
      cfg.method_defined?(:on_cancel) ? OPT[opts,:cancel] : [],
      cfg.method_defined?(:on_yes)    ? OPT[opts,:yes]    : [],
      cfg.method_defined?(:on_no)     ? OPT[opts,:no]     : [],
      what == :menu                   ? OPT[opts,:menu]   : [],
    ] .flatten
    r = _run_whip text, c, [WHAT[what]] + o, args
    case r[:exit]
    when EXIT[:ok_yes]
      c[:on_ok][r[:err]] if c[:on_ok]
      c[:on_yes][r[:err]] if c[:on_yes]
    when EXIT[:cancel_no]
      c[:on_cancel][] if c[:on_cancel]
      c[:on_no][] if c[:on_no]
    when EXIT[:esc]
      c[:on_esc][] if c[:on_esc]
    else
      raise Error, 'unknown exitstatus'
    end
    r
  end                                                           # }}}1

  # run whiptail; return { exit: exitstatus, err: chomped_lines }
  def self._run_whip(text, cfg, opts, args)                     # {{{1
    h = cfg[:height] || OU::Term.lines   - 4
    w = cfg[:width]  || OU::Term.columns - 4
    s = cfg.has_key?(:subheight) ? [cfg[:subheight] || h - 8] : []
    a = ([WHIPTAIL] + opts + ['--', text, h, w] + s + args).map &:to_s
    IO.pipe do |r, w|
      s = OU.spawn_w *a, err: w; w.close
      { exit: s.exitstatus, err: r.readlines.map { |x| x.chomp } }
    end
  end                                                           # }}}1

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
