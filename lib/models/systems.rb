require 'attr_secure'

class System < Sequel::Model

  plugin :timestamps
  plugin :paranoid

  attr_secure :resource_url
  attr_secure :admin_url

end
