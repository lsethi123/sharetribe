describe PlanService::API::Plans do

  let(:plans_api) { PlanService::API::Api }

  describe "#create" do
    context "#get_current" do
      it "creates a new plan" do
        expires_at = 1.month.from_now.change(usec: 0)

        plans_api.plans.create(
          community_id: 123, plan: {
            plan_level: PlanService::Levels::SCALE,
            expires_at: expires_at,
          })

        res = plans_api.plans.get_current(community_id: 123)

        expect(res.success).to eq(true)
        expect(res.data).to eq(
                              community_id: 123,
                              plan_level: 4,
                              expires_at: expires_at,
                              expired: false
                            )
      end

      it "creates a new plan that never expires" do
        plans_api.plans.create(
          community_id: 123, plan: {
            plan_level: PlanService::Levels::PRO
          })

        res = plans_api.plans.get_current(community_id: 123)

        expect(res.success).to eq(true)
        expect(res.data).to eq(
                              community_id: 123,
                              plan_level: 2,
                              expires_at: nil,
                              expired: false,
                            )
      end
    end

    context "error" do
      it "raises error if both plan level and plan name are missing" do
        expect { plans_api.plans.create(
          community_id: 123, plan: {
            expires_at: 1.month.from_now
          }) }.to raise_error(ArgumentError)
      end

      it "returns error if plan can not be found" do
        res = plans_api.plans.get_current(community_id: 123)
        expect(res.success).to eq(false)
      end
    end
  end

  describe "#expired?" do
    context "success" do
      it "returns false if plan never expires" do
        plans_api.plans.create(
          community_id: 111, plan: {
            plan_level: 5,
            expires_at: nil, # plan never expires
          })

        res = plans_api.plans.expired?(community_id: 111).data
        expect(res).to eq(false)
      end

      it "returns false if plan has not yet expired" do
        plans_api.plans.create(
          community_id: 111, plan: {
            plan_level: 5,
            expires_at: 1.month.from_now,
          })

        res = plans_api.plans.expired?(community_id: 111).data
        expect(res).to eq(false)
      end

      it "returns true if plan has expired" do
        plans_api.plans.create(
          community_id: 111, plan: {
            plan_level: 5,
            expires_at: 1.month.ago,
          })

        res = plans_api.plans.expired?(community_id: 111).data
        expect(res).to eq(true)
      end
    end

    context "error" do
      it "returns error if plan can not be found" do
        res = plans_api.plans.get_current(community_id: 123)
        expect(res.success).to eq(false)
      end
    end
  end
end
