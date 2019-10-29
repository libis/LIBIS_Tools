# Symbol monkey patch to allow map(&:method) to take arguments. Allows: [2,3].map(&:+.(10)) # => [12,13]
# See: https://stackoverflow.com/questions/23695653/can-you-supply-arguments-to-the-mapmethod-syntax-in-ruby
# for more information,
class Symbol
  def call(*args, &block)
    ->(caller, *rest) { caller.public_send(self, *rest, *args, &block) }
  end
end
