# frozen_string_literal: true

require 'ruby2_keywords'

module Saharspec
  module Its
    module Call
      # For `#call`-able subject, creates nested example where subject is called with arguments
      # provided, allowing to apply block matchers like `.to change(something)` or `.to raise_error`
      # to different calls in a DRY way.
      #
      # Also, plays really well with {RSpec::Matchers#ret #ret} block matcher.
      #
      # @example
      #    let(:array) { %i[a b c] }
      #
      #    describe '#[]' do
      #      subject { array.method(:[]) }
      #
      #      its_call(1) { is_expected.to ret :b }
      #      its_call(1..-1) { is_expected.to ret %i[b c] }
      #      its_call('foo') { is_expected.to raise_error TypeError }
      #    end
      #
      #    describe '#push' do
      #      subject { array.method(:push) }
      #      its_call(5) { is_expected.to change(array, :length).by(1) }
      #    end
      #
      ruby2_keywords def its_call(*args, &block)
        # rubocop:disable Lint/NestedMethodDefinition
        describe("(#{args.map(&:inspect).join(', ')})") do
          let(:__call_subject) do
            subject.call(*args)
          end

          def is_expected
            expect { __call_subject }
          end

          example(nil, &block)
        end
        # rubocop:enable Lint/NestedMethodDefinition
      end
    end
  end
end

unless defined?(RSpec)
  if Gem::Specification.all_names.include?('rspec')
    raise 'RSpec is installed but not yet loaded'
  end

  raise 'RSpec is not present in the current environment'
end

RSpec.configure do |rspec|
  rspec.extend Saharspec::Its::Call
  rspec.backtrace_exclusion_patterns << %r{/lib/saharspec/its/call}
end

RSpec::SharedContext.include Saharspec::Its::Call
