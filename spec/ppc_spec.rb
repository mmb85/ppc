# frozen_string_literal: true

require "spec_helper"
require "json"

RSpec.describe Ppc do
  it "has a version number" do
    expect(Ppc::VERSION).not_to be nil
  end

  shared_context "read test support file" do |filename|
    before do
      file = File.read("spec/support/#{filename}")
      @data_hash = JSON.parse(file)
      @result = Ppc::ProcessInput.new(@data_hash).perform
    end
  end

  context "When the file contains more than 10 ocurrences of an IP" do
    include_context "read test support file", "more_than_ten_ocurrences.json"

    it "should exclude it from the results" do
      expect(@result.to_s).not_to include("55.55.55.55")
    end

    it "should not exclude other valid data" do
      expect(@result.to_s).to include("22.22.22.22")
    end
  end

  context "When the file contains 10 or less ocurrences of an IP" do
    context "When the same IP has more than one ocurrence per hour" do
      context "When the ocurrences has same amount value" do
        include_context "read test support file", "same_amount_first_ocurrence.json"

        it "should include the first ocurrence by timestamp" do
          expect(@result[0]["timestamp"]).to eq("3/11/2020 13:02:40")
          expect(@result[1]["timestamp"]).to eq("3/11/2020 16:02:36")
        end
      end

      context "When the ocurrences has different amount value" do
        include_context "read test support file", "biggest_amount.json"

        it "should include the most expensive" do
          expect(@result[0]["amount"]).to eq(10.0)
          expect(@result[1]["amount"]).to eq(6.66)
        end
      end
    end

    context "When the same IP has only one ocurrence per hour" do
      include_context "read test support file", "single_occurrence_by_ip_hour.json"

      it "should be included" do
        expect(@result).to eq(@data_hash)
      end
    end
  end
end
