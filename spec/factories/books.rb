FactoryBot.define do
  factory :book do
    title { Faker::Book.title }
    author
    genre { Book::GENRES.sample }
    read_status { "unread" }
    language { "en" }
    page_count { rand(100..800) }
    date_added { Time.current }

    trait :with_isbn do
      isbn do
        digits = Array.new(12) { rand(0..9) }
        sum = digits.each_with_index.sum { |d, i| i.even? ? d : d * 3 }
        check = (10 - (sum % 10)) % 10
        (digits << check).join
      end
    end

    trait :rated do
      rating { Book::VALID_RATINGS.sample }
    end

    trait :read do
      read_status { "read" }
      rating { Book::VALID_RATINGS.sample }
    end
  end
end
