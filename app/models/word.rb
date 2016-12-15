class Word < ActiveRecord::Base
  def self.all_words
    all_words = Word.all
    all_words.map(&:word)
  end
end
