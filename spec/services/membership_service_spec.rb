require 'rails_helper'

describe "MembershipService" do
  describe "#delete_membership(membership: )" do
    before do
      @group = create(:group)
      @user = create(:user)
      @membership = create(:membership, member: @user, group: @group)

      @other_membership = create(:membership, member: @user)
    end

    it "destroys membership" do
      MembershipService.delete_membership(membership: @membership)
      expect(Membership.find_by_id(@membership.id)).to be_nil
    end

    it "destroys all member's draft buckets within the membership's group" do
      create_list(:bucket, 3, user: @user, status: 'draft', group: @group)

      MembershipService.delete_membership(membership: @membership)

      expect(Bucket.where(group: @group).length).to eq(0)
    end

    it "destroys member's funding buckets, and refunds all its contributors, and sends email notifications to refunded contributors" do
      bucket = create(:bucket, group: @group, user: @user, status: 'live', target: 1000)

      user1 = create(:user)
      membership1 = create(:membership, member: user1, group: @group)
      user2 = create(:user)
      membership2 = create(:membership, member: user2, group: @group)

      create(:allocation, user: user1, group: @group, amount: 40)
      expect(@group.balance).to eq(40)
      expect(membership1.balance).to eq(40)

      create(:allocation, user: user2, group: @group, amount: 80)
      expect(@group.balance).to eq(120)
      expect(membership2.balance).to eq(80)

      contribution1 = create(:contribution, user: user1, bucket: bucket, amount: 20)
      expect(@group.balance).to eq(100)
      expect(membership1.balance).to eq(20)

      contribution2 = create(:contribution, user: user2, bucket: bucket, amount: 30)
      expect(@group.balance).to eq(70)
      expect(membership2.balance).to eq(50)

      contribution2 = create(:contribution, user: user2, bucket: bucket, amount: 30)
      expect(@group.balance).to eq(40)
      expect(membership2.balance).to eq(20)

      ActionMailer::Base.deliveries.clear
      MembershipService.delete_membership(membership: @membership)
      sent_emails = ActionMailer::Base.deliveries
      user_1_email = sent_emails.find { |e| e.to[0] == user1.email }
      user_2_email = sent_emails.find { |e| e.to[0] == user2.email }

      expect(Bucket.find_by_id(bucket.id)).to be_nil
      expect(Contribution.find_by_id(contribution1.id)).to be_nil
      expect(Contribution.find_by_id(contribution2.id)).to be_nil
      expect(membership1.balance).to eq(40)
      expect(membership2.balance).to eq(80)
      expect(@group.balance).to eq(120)
      expect(sent_emails.length).to eq(2)
      expect(user_1_email.body.to_s).to include("$20")
      expect(user_2_email.body.to_s).to include("$60")

      ActionMailer::Base.deliveries.clear
    end

    it "destroys member's contributions on live buckets within membership's group" do
      live_group_bucket = create(:bucket, group: @group, status: 'live', target: 1000)

      create(:allocation, user: @user, group: @group, amount: 200)
      create_list(:contribution, 3, user: @user, bucket: live_group_bucket, amount: 30)

      MembershipService.delete_membership(membership: @membership)

      expect(live_group_bucket.contributions.length).to eq(0)
    end

    it "removes the user's funds from the group" do
      # create funded bucket, with target $100
      funded_bucket = create(:bucket, group: @group, target: 100, status: 'funded')
      # create live bucket, with target $100
      live_bucket = create(:bucket, group: @group, target: 100, status: 'live')
      # allocate user $100
      create(:allocation, user: @user, group: @group, amount: 100)
      # create other_user + membership
      other_user = create(:user)
      other_user_membership = create(:membership, member: other_user, group: @group)
      # allocate other_user $100
      create(:allocation, user: other_user, group: @group, amount: 100)

      # user contributes $50 to funded bucket
      create(:contribution, user: @user, bucket: funded_bucket, amount: 50)
      # other_user contributes $50 to funded bucket
      create(:contribution, user: other_user, bucket: funded_bucket, amount: 50)

      # user contributes $20 to live_bucket, twice
      create_list(:contribution, 2, user: @user, bucket: live_bucket, amount: 20)
      # other_user contributes $20 to live bucket
      create(:contribution, user: other_user, bucket: live_bucket, amount: 20)

      expect(@membership.balance).to eq(10)
      expect(other_user_membership.balance).to eq(30)
      expect(@group.balance).to eq(40)

      # delete membership service called
      MembershipService.delete_membership(membership: @membership)

      # funded bucket should still have 2 contributions, totalling to 100
      expect(funded_bucket.contributions.length).to eq(2)
      expect(funded_bucket.contributions.sum(:amount)).to eq(100)

      # live bucket should have only 1 contribution, totalling to $20
      expect(live_bucket.contributions.length).to eq(1)
      expect(live_bucket.contributions.sum(:amount)).to eq(20)

      expect(@group.balance).to eq(30)
    end

    context "user has more than one membership" do
      it "does not destroy member" do
        MembershipService.delete_membership(membership: @membership)

        expect(User.find_by_id(@user.id)).to be_truthy        
      end
    end

    context "user has only one membership" do
      it "also destroys member" do
        @other_membership.destroy
        MembershipService.delete_membership(membership: @membership)

        expect(User.find_by_id(@user.id)).to be_nil
      end
    end
  end
end