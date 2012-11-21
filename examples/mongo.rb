require 'pp'
require 'pathname'
require 'rubygems'
require 'adapter/mongo'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)
require 'toystore'

class User
  include Toy::Store
  adapter :mongo, Mongo::Connection.new.db('adapter')['testing']

  attribute :name, String
end

user = User.create(:name => 'John')

pp user
pp User.read(user.id)

user.destroy

pp User.read(user.id)
