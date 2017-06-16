class UpdateTutorialNames < ActiveRecord::Migration
  def change
    Tutorial.find_by(name: "I have a will.").update(name: "My Will(s)")
    Tutorial.find_by(name: "I have insurance.").update(name: "My Insurance")
    Tutorial.find_by(name: "I have tax documents.").update(name: "My Taxes")
    Tutorial.find_by(name: "I have a trust.").update(name: "My Trust(s)")
    Tutorial.find_by(name: "I have financial information.").update(name: "My Financial Information")
    Tutorial.find_by(name: "I own a vehicle.").update(name: "My Vehicle(s)")
    Tutorial.find_by(name: "I have a home.").update(name: "My Home")
    Tutorial.find_by(name: "I have a family.").update(name: "My Family")
  end
end
