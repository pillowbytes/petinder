# db/seeds.rb
require 'open-uri'
require 'faker'

# Configurar Faker para pt-BR
Faker::Config.locale = 'pt-BR'

# Limpar sessões ativas do Devise (caso use ActiveRecord::SessionStore)
puts "🔒 Limpando sessões ativas de Devise..."
if defined?(ActiveRecord::SessionStore)
  ActiveRecord::SessionStore::Session.delete_all
  puts "🔒 Sessões ativas removidas."
else
  puts "🔒 ActiveRecord::SessionStore não definido, pulando limpeza de sessões."
end

# Limpar dados existentes
puts "🧹 Limpando banco de dados..."
Location.destroy_all
Pet.destroy_all
User.destroy_all

puts "🌱 Criando usuários, pets e localizações..."

# ----------------------------
# 1. 50 USUÁRIOS GENÉRICOS
# ----------------------------
# Definindo um box mais restrito para que os endereços fiquem concentrados em SP
generic_lat_range = (-23.600..-23.550)
generic_lng_range = (-46.700..-46.650)

# Listas de nomes para pets
dog_names = ["Thor", "Luna", "Max", "Bella", "Buddy", "Charlie", "Rocky", "Duke", "Cooper", "Zeus", "Marley", "Toby"]
cat_names = ["Simba", "Nala", "Oliver", "Lucy", "Milo", "Loki", "Chloe", "Leo", "Lily", "Sophie", "Mimi"]

50.times do |i|
  first_name = Faker::Name.first_name
  last_name  = Faker::Name.last_name
  email      = Faker::Internet.unique.email(name: "#{first_name} #{last_name}")
  street     = Faker::Address.street_address
  city       = "São Paulo"
  state      = "SP"
  zip_code   = Faker::Address.zip_code[0..8]
  country    = "Brasil"

  user = User.create!(
    email: email,
    password: "password123",
    first_name: first_name,
    last_name: last_name,
    street: street,
    city: city,
    state: state,
    zip_code: zip_code,
    country: country
  )
  # Gerar coordenadas dentro do box definido para SP
  lat = rand(generic_lat_range)
  lng = rand(generic_lng_range)
  address = "#{street}, #{city}"

  Location.create!(
    user: user,
    address: address,
    latitude: lat,
    longitude: lng,
    city: city,
    state: state,
    zipcode: zip_code
  )

  # Criar dados do pet
  species = Pet::SPECIES_OPTIONS.sample  # "Cachorro" ou "Gato"
  pet_name = species == "Cachorro" ? dog_names.sample : cat_names.sample
  breed = species == "Cachorro" ? Pet::BREED_OPTIONS["Cachorro"].sample : Pet::BREED_OPTIONS["Gato"].sample
  gender = Pet::GENDER_OPTIONS.sample
  age = rand(1..15)
  age_group = if age < 2 then "Filhote" elsif age > 7 then "Sênior" else "Adulto" end
  bio = Faker::Lorem.sentence(word_count: 10)
  temperament = Pet::TEMPERAMENT_OPTIONS.sample
  size = Pet::SIZE_OPTIONS.sample
  is_vaccinated = [true, false].sample
  is_neutered = [true, false].sample
  is_available_for_breeding = [true, false].sample
  registered_pedigree = [true, false].sample
  personality_traits = Pet::PERSONALITY_TRAITS_OPTIONS.sample(rand(1..4))
  looking_for = [Pet::LOOKING_FOR_OPTIONS.sample]
  preferred_species = [Pet::PREFERRED_SPECIES_OPTIONS.sample]
  preferred_size = [Pet::SIZE_OPTIONS.sample]
  status = "Disponível"

  pet = Pet.new(
    user: user,
    name: pet_name,
    species: species,
    breed: breed,
    age: age,
    gender: gender,
    bio: bio,
    temperament: temperament,
    size: size,
    age_group: age_group,
    is_vaccinated: is_vaccinated,
    is_neutered: is_neutered,
    is_available_for_breeding: is_available_for_breeding,
    registered_pedigree: registered_pedigree,
    personality_traits: personality_traits,
    looking_for: looking_for,
    preferred_species: preferred_species,
    preferred_size: preferred_size,
    status: status
  )

  # Anexar imagem única para o pet
  image_url = "https://picsum.photos/seed/#{pet.name.parameterize}-#{i}/500/500"
  begin
    file = URI.open(image_url)
    pet.photos.attach(io: file, filename: "pet_generic_#{i+1}.jpg", content_type: "image/jpeg")
  rescue => e
    puts "⚠️ Erro ao anexar imagem para #{pet.name}: #{e.message}"
  end
  pet.save!
end

# ----------------------------
# 2. USUÁRIOS A PARTIR DE COORDENADAS ESPECÍFICAS
# ----------------------------
coordinate_groups = {
  "Parque Villa-Lobos" => [
    { lat: -23.542867, lng: -46.729952 },
    { lat: -23.543497, lng: -46.727571 },
    { lat: -23.547264, lng: -46.728751 },
    { lat: -23.544903, lng: -46.723837 },
    { lat: -23.545887, lng: -46.720017 },
    { lat: -23.544293, lng: -46.732248 },
    { lat: -23.548169, lng: -46.722507 },
    { lat: -23.544313, lng: -46.724963 },
    { lat: -23.545710, lng: -46.719653 },
    { lat: -23.546703, lng: -46.725543 },
    { lat: -23.547357, lng: -46.729287 }
  ],
  "Largo da Batata" => [
    { lat: -23.566751, lng: -46.695388 },
    { lat: -23.566788, lng: -46.694599 },
    { lat: -23.567043, lng: -46.694653 },
    { lat: -23.567239, lng: -46.694293 },
    { lat: -23.567033, lng: -46.695134 }
  ],
  "Praça do Por do Sol" => [
    { lat: -23.552719, lng: -46.703700 },
    { lat: -23.554922, lng: -46.700873 },
    { lat: -23.554042, lng: -46.701672 },
    { lat: -23.553889, lng: -46.702981 },
    { lat: -23.553830, lng: -46.702101 },
    { lat: -23.554646, lng: -46.700642 },
    { lat: -23.553702, lng: -46.703249 }
  ],
  "Praça Panamericana" => [
    { lat: -23.553739, lng: -46.709628 },
    { lat: -23.553174, lng: -46.708946 },
    { lat: -23.554113, lng: -46.708710 },
    { lat: -23.553806, lng: -46.709212 },
    { lat: -23.553292, lng: -46.708968 },
    { lat: -23.553700, lng: -46.708215 }
  ],
  "Parquinho Conde de Barcelos" => [
    { lat: -23.552632, lng: -46.713018 },
    { lat: -23.551215, lng: -46.714413 },
    { lat: -23.552322, lng: -46.713753 }
  ]
}

coordinate_groups.each do |group_name, coords_array|
  coords_array.each do |coord|
    first_name = Faker::Name.first_name
    last_name  = Faker::Name.last_name
    email = Faker::Internet.unique.email(name: "#{first_name} #{last_name}")
    street = Faker::Address.street_address
    city = "São Paulo"
    state = "SP"
    zip_code = Faker::Address.zip_code[0..8]
    country = "Brasil"

    user = User.create!(
      email: email,
      password: "password123",
      first_name: first_name,
      last_name: last_name,
      street: street,
      city: city,
      state: state,
      zip_code: zip_code,
      country: country
    )

    Location.create!(
      user: user,
      address: group_name,
      latitude: coord[:lat],
      longitude: coord[:lng],
      city: city,
      state: state,
      zipcode: zip_code
    )

    # Criar pet para este usuário
    species = Pet::SPECIES_OPTIONS.sample
    pet_name = species == "Cachorro" ? dog_names.sample : cat_names.sample
    breed = species == "Cachorro" ? Pet::BREED_OPTIONS["Cachorro"].sample : Pet::BREED_OPTIONS["Gato"].sample
    gender = Pet::GENDER_OPTIONS.sample
    age = rand(1..15)
    age_group = if age < 2 then "Filhote" elsif age > 7 then "Sênior" else "Adulto" end
    bio = Faker::Lorem.sentence(word_count: 10)
    temperament = Pet::TEMPERAMENT_OPTIONS.sample
    size = Pet::SIZE_OPTIONS.sample
    is_vaccinated = [true, false].sample
    is_neutered = [true, false].sample
    is_available_for_breeding = [true, false].sample
    registered_pedigree = [true, false].sample
    personality_traits = Pet::PERSONALITY_TRAITS_OPTIONS.sample(rand(1..4))
    looking_for = [Pet::LOOKING_FOR_OPTIONS.sample]
    preferred_species = [Pet::PREFERRED_SPECIES_OPTIONS.sample]
    preferred_size = [Pet::SIZE_OPTIONS.sample]
    status = "Disponível"

    pet = Pet.new(
      user: user,
      name: pet_name,
      species: species,
      breed: breed,
      age: age,
      gender: gender,
      bio: bio,
      temperament: temperament,
      size: size,
      age_group: age_group,
      is_vaccinated: is_vaccinated,
      is_neutered: is_neutered,
      is_available_for_breeding: is_available_for_breeding,
      registered_pedigree: registered_pedigree,
      personality_traits: personality_traits,
      looking_for: looking_for,
      preferred_species: preferred_species,
      preferred_size: preferred_size,
      status: status
    )

    image_url = "https://picsum.photos/seed/#{pet.name.parameterize}-#{rand(1000)}/500/500"
    begin
      file = URI.open(image_url)
      pet.photos.attach(io: file, filename: "#{pet.name.parameterize}-#{rand(1000)}.jpg", content_type: "image/jpeg")
    rescue => e
      puts "⚠️ Erro ao anexar imagem para #{pet.name}: #{e.message}"
    end
    pet.save!
  end
end

# ----------------------------
# 3. USUÁRIOS PARA ÁREAS ADICIONAIS
#    a) Parque da USP – 11 usuários
#    b) Praça Victor Civita – 7 usuários
# ----------------------------

# a) Parque da USP
11.times do |i|
  first_name = Faker::Name.first_name
  last_name  = Faker::Name.last_name
  email = Faker::Internet.unique.email(name: "#{first_name} #{last_name}")
  street = Faker::Address.street_address
  city = "São Paulo"
  state = "SP"
  zip_code = Faker::Address.zip_code[0..8]
  country = "Brasil"

  user = User.create!(
    email: email,
    password: "password123",
    first_name: first_name,
    last_name: last_name,
    street: street,
    city: city,
    state: state,
    zip_code: zip_code,
    country: country
  )

  # Base para Parque da USP
  base_lat = -23.5615
  base_lng = -46.7310
  lat = base_lat + rand(-0.001..0.001)
  lng = base_lng + rand(-0.001..0.001)
  address = "Parque da USP"

  Location.create!(
    user: user,
    address: address,
    latitude: lat,
    longitude: lng,
    city: city,
    state: state,
    zipcode: zip_code
  )

  species = Pet::SPECIES_OPTIONS.sample
  pet_name = species == "Cachorro" ? dog_names.sample : cat_names.sample
  breed = species == "Cachorro" ? Pet::BREED_OPTIONS["Cachorro"].sample : Pet::BREED_OPTIONS["Gato"].sample
  gender = Pet::GENDER_OPTIONS.sample
  age = rand(1..15)
  age_group = if age < 2 then "Filhote" elsif age > 7 then "Sênior" else "Adulto" end
  bio = Faker::Lorem.sentence(word_count: 10)
  temperament = Pet::TEMPERAMENT_OPTIONS.sample
  size = Pet::SIZE_OPTIONS.sample
  is_vaccinated = [true, false].sample
  is_neutered = [true, false].sample
  is_available_for_breeding = [true, false].sample
  registered_pedigree = [true, false].sample
  personality_traits = Pet::PERSONALITY_TRAITS_OPTIONS.sample(rand(1..4))
  looking_for = [Pet::LOOKING_FOR_OPTIONS.sample]
  preferred_species = [Pet::PREFERRED_SPECIES_OPTIONS.sample]
  preferred_size = [Pet::SIZE_OPTIONS.sample]
  status = "Disponível"

  pet = Pet.new(
    user: user,
    name: pet_name,
    species: species,
    breed: breed,
    age: age,
    gender: gender,
    bio: bio,
    temperament: temperament,
    size: size,
    age_group: age_group,
    is_vaccinated: is_vaccinated,
    is_neutered: is_neutered,
    is_available_for_breeding: is_available_for_breeding,
    registered_pedigree: registered_pedigree,
    personality_traits: personality_traits,
    looking_for: looking_for,
    preferred_species: preferred_species,
    preferred_size: preferred_size,
    status: status
  )

  image_url = "https://picsum.photos/seed/#{pet.name.parameterize}-usp-#{i}/500/500"
  begin
    file = URI.open(image_url)
    pet.photos.attach(io: file, filename: "usp_pet#{i+1}.jpg", content_type: "image/jpeg")
  rescue => e
    puts "⚠️ Erro ao anexar imagem para #{pet.name}: #{e.message}"
  end
  pet.save!
end

# b) Praça Victor Civita
7.times do |i|
  first_name = Faker::Name.first_name
  last_name  = Faker::Name.last_name
  email = Faker::Internet.unique.email(name: "#{first_name} #{last_name}")
  street = Faker::Address.street_address
  city = "São Paulo"
  state = "SP"
  zip_code = Faker::Address.zip_code[0..8]
  country = "Brasil"

  user = User.create!(
    email: email,
    password: "password123",
    first_name: first_name,
    last_name: last_name,
    street: street,
    city: city,
    state: state,
    zip_code: zip_code,
    country: country
  )

  # Base para Praça Victor Civita
  base_lat = -23.565
  base_lng = -46.688
  lat = base_lat + rand(-0.001..0.001)
  lng = base_lng + rand(-0.001..0.001)
  address = "Praça Victor Civita"

  Location.create!(
    user: user,
    address: address,
    latitude: lat,
    longitude: lng,
    city: city,
    state: state,
    zipcode: zip_code
  )

  species = Pet::SPECIES_OPTIONS.sample
  pet_name = species == "Cachorro" ? dog_names.sample : cat_names.sample
  breed = species == "Cachorro" ? Pet::BREED_OPTIONS["Cachorro"].sample : Pet::BREED_OPTIONS["Gato"].sample
  gender = Pet::GENDER_OPTIONS.sample
  age = rand(1..15)
  age_group = if age < 2 then "Filhote" elsif age > 7 then "Sênior" else "Adulto" end
  bio = Faker::Lorem.sentence(word_count: 10)
  temperament = Pet::TEMPERAMENT_OPTIONS.sample
  size = Pet::SIZE_OPTIONS.sample
  is_vaccinated = [true, false].sample
  is_neutered = [true, false].sample
  is_available_for_breeding = [true, false].sample
  registered_pedigree = [true, false].sample
  personality_traits = Pet::PERSONALITY_TRAITS_OPTIONS.sample(rand(1..4))
  looking_for = [Pet::LOOKING_FOR_OPTIONS.sample]
  preferred_species = [Pet::PREFERRED_SPECIES_OPTIONS.sample]
  preferred_size = [Pet::SIZE_OPTIONS.sample]
  status = "Disponível"

  pet = Pet.new(
    user: user,
    name: pet_name,
    species: species,
    breed: breed,
    age: age,
    gender: gender,
    bio: bio,
    temperament: temperament,
    size: size,
    age_group: age_group,
    is_vaccinated: is_vaccinated,
    is_neutered: is_neutered,
    is_available_for_breeding: is_available_for_breeding,
    registered_pedigree: registered_pedigree,
    personality_traits: personality_traits,
    looking_for: looking_for,
    preferred_species: preferred_species,
    preferred_size: preferred_size,
    status: status
  )

  image_url = "https://picsum.photos/seed/#{pet.name.parameterize}-vitorcivita-#{i}/500/500"
  begin
    file = URI.open(image_url)
    pet.photos.attach(io: file, filename: "vitorcivita_pet#{i+1}.jpg", content_type: "image/jpeg")
  rescue => e
    puts "⚠️ Erro ao anexar imagem para #{pet.name}: #{e.message}"
  end
  pet.save!
end

puts "✅ Seeding completo!"
puts "👥 Criados #{User.count} usuários"
puts "🐶🐱 Criados #{Pet.count} pets"
puts "📍 Criadas #{Location.count} localizações"
