require 'eft'

Eft.menu(default: 'bar', title: 'Menu', backtitle: 'Choose!') do |m|
  m.on('foo', 'Do The Foo') do |x|
    Eft.ask('What is your name?', ok_button: 'Next') do |q1|
      q1.on_ok do |name|
        Eft.ask_pass('Password?', ok_button: 'Go!') do |q2|
          q2.on_ok do |pass|
            Eft.show_msg "Welcome, #{name}, your password is #{pass}"
          end
        end
      end
    end
  end
  m.on('bar', 'Do Bar!') do |x|
    Eft.ask_yesno 'Are you ok?' do |q|
      q.on_ok do
        puts 'Nice!'
      end
      q.on_cancel do
        puts 'Too bad!'
      end
    end
  end
  m.on('baz', 'Baz!?') do |x|
    Eft.gauge title: 'Progress' do |g|
      0.upto(100) do |progress|
        progress[i, "We're at ##{i}"]
        sleep 0.05
      end
    end
  end
  m.on_cancel do
    puts 'Not interested.'
  end
  m.on_esc do
    puts 'Escaped!'
  end
end
