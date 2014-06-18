require 'attr_secure'

class System < Sequel::Model

  plugin :timestamps
  plugin :paranoid
  attr_secure :credentials

end
