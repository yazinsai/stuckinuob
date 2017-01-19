class Section < ApplicationRecord
  has_many :lectures
  belongs_to :course
end
