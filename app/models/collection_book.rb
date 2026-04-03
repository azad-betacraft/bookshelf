class CollectionBook < ApplicationRecord
  belongs_to :collection
  belongs_to :book

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :book_id, uniqueness: { scope: :collection_id, message: "already exists in this collection" }
end
