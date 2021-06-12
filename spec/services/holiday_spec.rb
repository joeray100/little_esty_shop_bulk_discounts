require 'rails_helper'

RSpec.describe Holiday, type: :model do
  it "returns holiday data" do
    mock_response =
      '[{:date=>"2021-07-05", :localName=>"Independence Day", :name=>"Independence Day", :countryCode=>"US", :fixed=>false, :global=>true, :counties=>nil, :launchYear=>nil, :type=>"Public"},
      {:date=>"2021-09-06", :localName=>"Labor Day", :name=>"Labour Day", :countryCode=>"US", :fixed=>false, :global=>true, :counties=>nil, :launchYear=>nil, :type=>"Public"},
      {:date=>"2021-10-11",
        :localName=>"Columbus Day",
        :name=>"Columbus Day",
        :countryCode=>"US",
        :fixed=>false,
        :global=>false,
        :counties=>
        ["US-AL",
          "US-AZ",
          "US-CO",
          "US-CT",
          "US-DC",
          "US-GA",
          "US-ID",
          "US-IL",
          "US-IN",
          "US-IA",
          "US-KS",
          "US-KY",
          "US-LA",
          "US-ME",
          "US-MD",
          "US-MA",
          "US-MS",
          "US-MO",
          "US-MT",
          "US-NE",
          "US-NH",
          "US-NJ",
          "US-NM",
          "US-NY",
          "US-NC",
          "US-OH",
          "US-OK",
          "US-PA",
          "US-RI",
          "US-SC",
          "US-TN",
          "US-UT",
          "US-VA",
          "US-WV"],
          :launchYear=>nil,
          :type=>"Public"}]'


        # allow_any_instance_of(Faraday::Response).to receive(Holiday.conn).and_return(mock_response)
        upcoming_holidays = Holiday.new.upcoming_holidays

        expect(upcoming_holidays).to be_a(Array)

        expect(upcoming_holidays[0]).to have_key(:name)
        expect(upcoming_holidays[0]).to have_key(:date)
      end
    end
