require 'playhouse/context'
require 'cobudget/entities/budget'
require 'cobudget/entities/user'
require 'cobudget/entities/allocation_right'
require 'cobudget/composers/money_composer'
require 'cobudget/roles/budget_participant'
#require 'cobudget/roles/bucket_authorizer'

module Cobudget
  module AllocationRights
    class Get < Playhouse::Context
      actor :user, repository: User, role: BudgetParticipant
      actor :budget, repository: Budget

      def perform
        right = user.get_allocation_rights(budget)
        if right
          right.amount
        else
          nil
        end
      end
    end
  end
end