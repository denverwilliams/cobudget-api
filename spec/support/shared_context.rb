module MyLetDeclarations
  extend RSpec::SharedContext

  # Everything you need for a basic test
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:membership) { create(:membership, group: group) }
  let(:allocation) { create(:allocation, group: group) }
  let(:bucket) { create(:bucket, group: group) }
  let(:contribution) { create(:contribution, bucket: bucket) }

  # Convenience methods for testing permissions
  let(:make_user_group_member) { create(:membership, group: group, member: user) }
  let(:make_user_group_admin) { create(:membership, group: group, member: user, is_admin: true) }

  # HTTP status codes
  let(:success) { 200 }
  let(:created) { 201 }
  let(:bad_request) { 400 }
  let(:unauthorized) { 401 }
  let(:forbidden) { 403 }
  let(:conflict) { 409 }
  let(:unprocessable) { 422 }

  def create_bucket_participant(bucket:, subscribed:, type: :commenter)
    participant = create(:user, subscribed_to_participant_activity: subscribed)
    create(:membership, member: participant, group: bucket.group)
    case type
      when :commenter then create(:comment, bucket: bucket, user: participant)
      when :funder then create(:contribution, bucket: bucket, user: participant)
    end
    participant
  end
end

RSpec.configure { |c| c.include MyLetDeclarations }
