# coding: utf-8

class AssertionFailure < StandardError
end

class Object

  # Assert functionality as found in other languages (e.g. 'C').
  #
  # The assert is enabled/disabled by setting the $DEBUG global variable. If $DEBUG evaluates to true, the assertion is
  # active.
  #
  # If activated, the first argument will be evaluated and when it evaluates to true, an AssertionFailure exception will
  # be raised with the message given as the second argument.
  #
  # Alternatively, a code block may be passed to the assert. In that case the test expression is not evaluated, but used
  # as the message for the expression. The assert will yield the code block and it's result will be evaluated to decide
  # if the exception will be thrown.
  #
  # Examples:
  #
  #     require 'libis/tools/assert'
  #     assert(value > 0, 'value should be positive number')
  #
  #     # using a code block:
  #     require 'libis/tools/assert'
  #     assert 'database is not idle' do
  #       db = get_database
  #       db.status == :IDLE
  #     end
  #
  #     # using $DEBUG:
  #     $DEBUG = nil
  #     assert false, 'assert 1'        # nothing happens
  #     $DEBUG = true
  #     assert false, 'assert 2'        # AssertionFailure 'assert 2' is raised
  #     assert 'assert 3', 'assert 4' do
  #       false
  #     end                             # AssertionFailure 'assert 3' is raised
  #
  # @param [Object] test_expression the expression that will be evaluated; the message if a code block is present
  # @param [String] message exception message is no code block is present
  def assert(test_expression, message = 'assertion failure')
    if $DEBUG
      if block_given?
        message = test_expression
        test_expression = yield
      end
      raise AssertionFailure.new(message) unless test_expression
    end
  end
end
