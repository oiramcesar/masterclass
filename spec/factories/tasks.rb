FactoryBot.define do
    factory :task do
        title { Faker::Lorem.sentence }
        description {Faker::Lorem.paragraph}
        deadline {Faker::Date.forward}
        done { false }
        # user_id {"1"} --> Não faz parte de uma boa pratica, uma vez que não se sabe se este id existe, desta forma recomenda-se que seja criado um objeto ou melhor que seja determinado a instancia de um User e assim o factorybot se encarrega de recuperar o id.
        user

    end
end

