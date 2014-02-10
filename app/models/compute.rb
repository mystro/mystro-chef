class Compute
  has_and_belongs_to_many :roles, class_name: "MystroChef::Role"
end