class TestSet < Sequel::Model(:testset)
  many_to_one :database
end