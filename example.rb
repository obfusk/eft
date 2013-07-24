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
      0.upto(100) do |i|
        i % 5 == 0 ? mv[i, "We're at ##{i} ..."] : mv[i]
        sleep 0.05
      end
    end
  end
  m.on('qux', 'Quixotic?') do |x|
    Eft.show_info 'Hi!'
  end
  m.on('quux', 'Quixotic!') do |x|
    Eft.show_text file: '/etc/services', scroll: true
  end
  m.on('quuux', 'There\'s more ...') do |x|
    Eft.check 'Which ones?' do |c|
      c.choice('1', 'One')
      c.choice('2', 'Two', true)
      c.choice('3', 'Three')
      c.on_ok do |choices|
        Eft.show_text text: choices*10*"\n", title: 'Multiplied!'
      end
    end
  end
  m.on('almost there', 'Just one more') do |x|
    Eft.radio 'One or none' do |c|
      c.choice('1', 'One')
      c.choice('2', 'Two')
      c.on_ok { |choice| puts "You chose: #{choice || 'none!?'}" }
    end
  end
  m.on('last one', 'Really! I promise.') do |x|
    Eft.radio 'Which one?', selected: '2' do |c|
      c.choice('1', 'One')
      c.choice('2', 'Two')
      c.choice('3', 'Three')
      c.on_ok { |choice| puts "You chose: #{choice}" }
    end
  end
  m.on_cancel { puts 'Not interested.' }
  m.on_esc    { puts 'Escaped!' }
end
