# frozen_string_literal: true

require "ppc/version"

module Ppc
  # Will Manage click input file
  class ProcessInput
    attr_reader :json_file

    MAX_CLICK_PER_IP = 10

    def initialize(json_file)
      @json_file = json_file
    end

    def perform
      result = []
      group_by_hours.each do |ip_clicks|
        ip_clicks.each do |ip_click_per_hours|
          result << ip_click_per_hours[1].min do |a1, a2|
            [a2["amount"], a1["timestamp"]] <=> [a1["amount"], a2["timestamp"]]
          end
        end
      end

      result
    end

    def self.export_to_json(result)
      File.open("resultset.json", "w") { |f| f.write(result) }
    end

    private

    def group_by_hours
      reject_extra_clicks.map { |_, click| click.group_by { |k| extract_hour(k["timestamp"]) } }
    end

    def reject_extra_clicks
      group_by_ip.reject { |_, value| value.count > MAX_CLICK_PER_IP }
    end

    def group_by_ip
      json_file.group_by { |click| click["ip"] }
    end

    def extract_hour(timestamp)
      timestamp[/ \d{2}/].strip
    end
  end
end
