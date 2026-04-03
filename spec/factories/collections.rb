FactoryBot.define do
  factory :collection do
    name { Faker::Lorem.unique.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    is_public { false }
  end
end
