require 'eft'

Eft.menu('Choices:', selected: 'bar', title: 'Menu',
         backtitle: 'Choose!') do |m|
  m.on('foo', 'Do The Foo') do |x|
    Eft.ask('What is your name?', ok_button: 'Next',
            default: 'Anonymous') do |q1|
      q1.on_ok do |name|
        Eft.ask_pass('Secret?', ok_button: 'Go!') do |q2|
          q2.on_ok do |sec|
            Eft.show_msg "Welcome #{name}, your secret is #{sec}"
          end
        end
      end
    end
  end
  m.on('bar', 'Do Bar!') do |x|
    Eft.ask_yesno 'Is everything going well?' do |q|
      q.on_yes  { puts 'Nice!' }
      q.on_no   { puts 'Too bad!' }
    end
  end
  m.on('baz', 'Baz!?') do |x|
    Eft.gauge '...', 0, title: 'Progress' do |mv|
      0.upto(100) { |i| mv[i, "We're at ##{i} ..."]; sleep 0.05 }
    end
  end
  m.on_cancel { puts 'Not interested.' }
  m.on_esc    { puts 'Escaped!' }
end
