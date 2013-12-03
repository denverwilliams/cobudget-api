require 'active_record'

module Cobudget
  class Budget < ActiveRecord::Base
    has_many :buckets
    has_many :allocation_rights
    has_many :allocations
    has_many :accounts, as: :owner
  end
end