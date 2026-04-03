FactoryBot.define do
  factory :author do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    bio { Faker::Lorem.paragraph(sentence_count: 3) }
    birth_year { rand(1900..1990) }
  end
end
