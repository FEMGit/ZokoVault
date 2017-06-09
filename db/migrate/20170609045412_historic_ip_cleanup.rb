class HistoricIpCleanup < ActiveRecord::Migration
  def change
    UserTraffic.where("ip_address ilike ? ", "10.%").find_each(:batch_size => 1000) do |user_traffic|
      user_traffic.update(:ip_address => "--")
    end
  end
end
