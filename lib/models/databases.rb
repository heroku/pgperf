require 'attr_secure'

class Database < Sequel::Model
  plugin :timestamps
  plugin :paranoid

  attr_secure :resource_url
  attr_secure :admin_url
end
