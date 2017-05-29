class Tutorial < ActiveRecord::Base
  attr_writer :current_step

  validates_presence_of :name
  validates_presence_of :number_of_pages

  has_many :pages
  has_many :subtutorials

  def current_step
    @current_step || steps.first
  end

  def steps
    %w[initial cicle confirmation]
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

  def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end
  
  def has_subtutorials?
    subtutorials.present?
  end

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end
end
