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

require 'obfusk/util/run'
require 'obfusk/util/term'

module Eft

  # --default-item string
  # --separate-output
  # --scrolltext

  # --yesno text height width
  # --msgbox text height width
  # --infobox text height width ?
  # --inputbox text height width [init] > STDERR
  # --passwordbox text height width
  # --textbox file height width
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

  EXIT = { 0 => [:ok, :yes], 1 => [:cancel, :no], 255 => [:esc] }

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

  # --

  class Cfg
    attr_reader :cfg
    def initialize(cfg = {})
      @cfg = cfg
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
  end

  class CfgShowText < Cfg
    include CfgEsc, CfgOK
  end

  class CfgAsk < Cfg
    include CfgEsc, CfgOK, CfgCancel
  end

  class CfgAskPass < Cfg
    include CfgEsc, CfgOK, CfgCancel
  end

  class CfgAskYesNo < Cfg
    include CfgEsc, CfgYes, CfgNo
  end

  class CfgCheck < Cfg
    include CfgEsc, CfgOK, CfgCancel
  end

  class CfgMenu < Cfg
    include CfgEsc, CfgOK, CfgCancel
  end

  class CfgRadio < Cfg
    include CfgEsc, CfgOK, CfgCancel
  end

  class CfgGauge < Cfg
  end

  # --

  # show message w/o OK button and clearing screen
  def self.show_info(msg, opts = {}, &b)
  end

  # show message w/ OK button
  def self.show_msg(mgs, opts = {}, &b)
  end

  # file !!!
  def self.show_text(opts = {}, &b)
  end

  # --

  def self.ask(opts = {}, &b)
  end

  def self.ask_pass(opts = {}, &b)
  end

  def self.ask_yesno(opts = {}, &b)
  end

  # --

  def self.check(opts = {}, &b)
  end

  def self.menu(opts = {}, &b)
  end

  def self.radio(opts = {}, &b)
  end

  # --

  def self.gauge(opts = {}, &b)
  end

  # --

  def self._whip(what, cfg, opts, args)

  end

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
