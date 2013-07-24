# --                                                            ; {{{1
#
# File        : eft.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-24
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'tempfile'

require 'obfusk/util/run'
require 'obfusk/util/term'

module Eft

  OU = Obfusk::Util

  # --

  # NB: dialog works as well as whiptail, but these options will be
  # incompatible: --*-button (is: --*-label), --scrolltext

  WHIPTAIL    = 'whiptail'
  EXIT        = { ok_yes: 0, cancel_no: 1, esc: 255 }
  CHECK_OPTS  = ['--separate-output']

  OPT         = ->(o,x) { o.select { |k,v| OPTS[x][k] }
                              .map { |k,v| OPTS[x][k][v] } }
  ON_OFF      = ->(x) { x ? 'on' : 'off' }

  # --

  WHAT = {                                                      # {{{1
    show_info:  '--infobox'     , show_msg:   '--msgbox'    ,
    show_text:  '--textbox'     , ask:        '--inputbox'  ,
    ask_pass:   '--passwordbox' , ask_yesno:  '--yesno'     ,
    menu:       '--menu'        , check:      '--checklist' ,
    radio:      '--radiolist'   , gauge:      '--gauge'     ,
  }                                                             # }}}1

  OPTS = {                                                      # {{{1
    all: {
      title:          ->(t) { ['--title', t] },
      backtitle:      ->(t) { ['--backtitle', t] },
      scroll:         ->(b) { b ? ['--scrolltext'] : [] },      # ????
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
      selected:       ->(i) { ['--default-item', i] },
    },
  }                                                             # }}}1

  # --

  class Error < RuntimeError; end

  class Cfg                                                     # {{{1
    def initialize(cfg = {}, &b)
      @cfg = cfg; b[self] if b; @cfg.freeze
    end
    def call(k, *a)
      @cfg[k][*a] if @cfg[k]
    end
    def _opts; [] end
  end                                                           # }}}1

  # --

  module CfgEsc   ; def on_esc(&b)    @cfg[:on_esc]     = b end; end
  module CfgOK    ; def on_ok(&b)     @cfg[:on_ok]      = b end; end
  module CfgCancel; def on_cancel(&b) @cfg[:on_cancel]  = b end; end
  module CfgYes   ; def on_yes(&b)    @cfg[:on_yes]     = b end; end
  module CfgNo    ; def on_no(&b)     @cfg[:on_no]      = b end; end

  # --

  class CfgShowInfo   < Cfg                                   ; end
  class CfgShowMsg    < Cfg; include CfgEsc, CfgOK            ; end
  class CfgShowText   < Cfg; include CfgEsc, CfgOK            ; end
  class CfgAsk        < Cfg; include CfgEsc, CfgOK, CfgCancel ; end
  class CfgAskPass    < Cfg; include CfgEsc, CfgOK, CfgCancel ; end
  class CfgAskYesNo   < Cfg; include CfgEsc, CfgYes, CfgNo    ; end
  class CfgGauge      < Cfg                                   ; end

  # --

  class CfgMenu < Cfg                                           # {{{1
    include CfgEsc, CfgOK, CfgCancel
    def initialize(*a, &b)
      @menu = []; super; @menu.freeze
    end
    def on(tag, item, &b)
      @menu << { tag: tag, item: item, block: b }
    end
    def _menu; @menu end
  end                                                           # }}}1

  class CfgCheck < Cfg                                          # {{{1
    include CfgEsc, CfgOK, CfgCancel
    def initialize(*a, &b)
      @check = []; super; @check.freeze
    end
    def choice(tag, item, selected = false)
      @check << { tag: tag, item: item, selected: selected }
    end
    def _check; @check end
    def _opts; CHECK_OPTS; end
  end                                                           # }}}1

  class CfgRadio < Cfg                                          # {{{1
    include CfgEsc, CfgOK, CfgCancel
    def initialize(*a, &b)
      @radio = []; super; @radio.freeze
    end
    def choice(tag, item)
      @radio << { tag: tag, item: item }
    end
    def _radio; @radio end
  end                                                           # }}}1

  # --

  # show message w/o buttons, don't clear screen
  def self.show_info(text, opts = {})
    _whip :show_info, text, CfgShowInfo.new, opts
  end

  # show message w/ OK button
  def self.show_msg(text, opts = {}, &b)
    c = CfgShowMsg.new(&b)
    _whip(:show_msg, text, c, opts) { c.call :on_ok }
  end

  # show file contents or text w/ OK button
  def self.show_text(opts = {}, &b)
    _file_or_temp opts do |f|
      c = CfgShowText.new(&b)
      _whip(:show_text, f, c, opts) { c.call :on_ok }
    end
  end

  # --

  # ask for input w/ OK/Cancel buttons (and default)
  def self.ask(text, opts = {}, &b)
    c = CfgAsk.new(&b); a = opts[:default] ? [opts[:default]] : []
    _whip(:ask, text, c, opts, a) do |lines|
      c.call :on_ok, lines.first
    end
  end

  # ask for password w/ OK/Cancel buttons
  def self.ask_pass(text, opts = {}, &b)
    c = CfgAskPass.new(&b)
    _whip(:ask_pass, text, c, opts) do |lines|
      c.call :on_ok, lines.first
    end
  end

  # ask w/ Yes/No buttons
  def self.ask_yesno(text, opts = {}, &b)
    c = CfgAskYesNo.new(&b)
    _whip(:ask_yesno, text, c, opts) { c.call :on_yes }
  end

  # --

  # choose from menu w/ OK/Cancel buttons
  def self.menu(text, opts = {}, &b)                            # {{{1
    c = CfgMenu.new(&b); m = c._menu
    o = opts.merge(subheight: opts[:menu_height]).freeze
    a = m.map { |x| [x[:tag],x[:item]] } .flatten
    t = Hash[m.map { |x| [x[:tag],x] }]
    _whip(:menu, text, c, o, a) do |lines|
      tag = lines.first; t[tag][:block][tag]
    end
  end                                                           # }}}1

  # --

  # choose checkboxes w/ OK/Cancel buttons
  def self.check(text, opts = {}, &b)                           # {{{1
    c = CfgCheck.new(&b); i = c._check
    o = opts.merge(subheight: opts[:list_height]).freeze
    a = i.map { |x| [x[:tag],x[:item],ON_OFF[x[:selected]]] } .flatten
    _whip(:check, text, c, o, a) do |lines|
      c.call :on_ok, lines
    end
  end                                                           # }}}1

  # choose radiobutton w/ OK/Cancel buttons
  def self.radio(text, opts = {}, &b)                           # {{{1
    s = opts[:selected] ; f = ->(x) { ON_OFF[x == s] }
    c = CfgRadio.new(&b); i = c._radio
    o = opts.merge(subheight: opts[:list_height]).freeze
    a = i.map { |x| [x[:tag],x[:item],f[x[:tag]]] } .flatten
    _whip(:radio, text, c, o, a) do |lines|
      c.call :on_ok, lines.first
    end                                                         # }}}1
  end

  # --

  # show gauge; use lambda passed to block to move it forward by
  # passing it percent, message
  def self.gauge(text, percent, opts = {}, &b)                  # {{{1
    IO.pipe do |r, w|
      mv  = ->(pct, msg) { w.puts 'XXX', pct, msg, 'XXX', pct } # WTF!
      c   = CfgGauge.new
      o   = _whip_opts :gauge, c, opts
      c   = _whip_cmd text, opts, o, [percent]
      pid = OU.spawn *c, in: r
      r.close; b[mv]; w.close; Process.wait pid
      raise Error, 'exitstatus != 0' if $?.exitstatus != 0
    end                                                         # }}}1
  end

  # --

  # process options, run whiptail, call b[lines]/on_{cancel,no,esc}[]
  # @raise Error if unknown exitstatus
  def self._whip(what, text, cfg, opts, args = [], &b)          # {{{1
    o = _whip_opts what, cfg, opts; c = _whip_cmd text, opts, o, args
    r = _run_whip c
    case r[:exit]
    when EXIT[:ok_yes]    ; b[r[:lines]] if b
    when EXIT[:cancel_no] ; cfg.call :on_cancel; cfg.call :on_no
    when EXIT[:esc]       ; cfg.call :on_esc
    else                    raise Error, 'unknown exitstatus'
    end
    nil
  end                                                           # }}}1

  # process whiptail options
  def self._whip_opts(what, cfg, opts)                          # {{{1
     cfg._opts + [                  OPT[opts,:all],
      cfg.respond_to?(:on_ok)     ? OPT[opts,:ok]     : [],
      cfg.respond_to?(:on_cancel) ? OPT[opts,:cancel] : [],
      cfg.respond_to?(:on_yes)    ? OPT[opts,:yes]    : [],
      cfg.respond_to?(:on_no)     ? OPT[opts,:no]     : [],
      what == :menu               ? OPT[opts,:menu]   : [],
    ] .flatten + [WHAT[what]]
  end                                                           # }}}1

  # whiptail command
  def self._whip_cmd(text, opts, opt_args, args)
    h = opts[:height] || OU::Term.lines   - 4
    w = opts[:width]  || OU::Term.columns - 4
    s = opts.has_key?(:subheight) ? [opts[:subheight] || h - 8] : []
    ([WHIPTAIL] + opt_args + ['--', text, h, w] + s + args).map &:to_s
  end

  # run whiptail; return { exit: exitstatus, lines: chomped_lines }
  def self._run_whip(args)
    IO.pipe do |r, w|
      s = OU.spawn_w *args, err: w; w.close
      { exit: s.exitstatus, lines: r.readlines.map(&:chomp) }
    end
  end

  # --

  # call block w/ either opts[:file] or a tempfile w/ contents
  # opts[:text]
  def self._file_or_temp(opts, &b)                              # {{{1
    file = opts[:file]; text = opts[:text]
    raise Error, 'can\'t have file and text' if file && text
    raise Error, 'must have file or text' if !file && !text
    if file
      b[file]
    else
      Tempfile.open('eft') { |f| f.write text; f.close; b[f.path] }
    end
  end                                                           # }}}1

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
