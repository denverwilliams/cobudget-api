require 'playhouse/context'
require 'cobudget/entities/user'

module Cobudget
  module Users
    class FindByEmail < Playhouse::Context
      actor :email

      def perform
        puts actors.inspect
        User.find_by_email(email)
      end 
    end 
  end 
end

