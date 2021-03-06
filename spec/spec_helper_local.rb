dir = File.expand_path(File.dirname(__FILE__))

Dir["#{dir}/shared_examples/*.rb"].sort.each { |f| require f }

RSpec.configure do |c|
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end

def verify_exact_file_contents(subject, title, expected_lines)
  content = subject.resource('file', title).send(:parameters)[:content]
  expect(content.split("\n").reject { |line| line =~ %r{(^$|^#)} }).to match_array expected_lines
end

def verify_exact_fragment_contents(subject, title, expected_lines)
  content = subject.resource('concat::fragment', title).send(:parameters)[:content]
  expect(content.split("\n").reject { |line| line =~ %r{(^$|^#)} }).to match_array expected_lines
end

def verify_fragment_contents(subject, title, expected_lines)
  content = subject.resource('concat::fragment', title).send(:parameters)[:content]
  expect(content.split("\n") & expected_lines).to match_array expected_lines.uniq
end
