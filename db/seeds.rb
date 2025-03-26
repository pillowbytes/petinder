# db/seeds.rb
require 'faker'

# Configure Faker for Brazilian Portuguese for non-address data
Faker::Config.locale = 'pt-BR'

puts "🧹 Limpando banco de dados..."
Location.destroy_all
Pet.destroy_all
User.destroy_all

puts "🌱 Iniciando criação de usuários e pets..."

# Coordinates from your provided topojson (using the first 20 features)
coordinates = [
  { lng: -46.729952, lat: -23.542867 },
  { lng: -46.727571, lat: -23.543497 },
  { lng: -46.728751, lat: -23.547264 },
  { lng: -46.723837, lat: -23.544903 },
  { lng: -46.720017, lat: -23.545887 },
  { lng: -46.732248, lat: -23.544293 },
  { lng: -46.722507, lat: -23.548169 },
  { lng: -46.724963, lat: -23.544313 },
  { lng: -46.725543, lat: -23.546703 },
  { lng: -46.729287, lat: -23.547357 },
  { lng: -46.695388, lat: -23.566751 },
  { lng: -46.714413, lat: -23.551215 },
  { lng: -46.713753, lat: -23.552322 },
  { lng: -46.729952, lat: -23.542867 },
  { lng: -46.727571, lat: -23.543497 },
  { lng: -46.723837, lat: -23.544903 },
  { lng: -46.720017, lat: -23.545887 },
  { lng: -46.732248, lat: -23.544293 },
  { lng: -46.722507, lat: -23.548169 },
  { lng: -46.724963, lat: -23.544313 }
]

coord_index = 0

###########################
# 1. Criação de Admins
###########################

admin_users = [
  {
    email: "admin@admin.com",
    password: "123456",
    first_name: "Admin",
    last_name: "User",
    street: "Praça da Sé, 1, Sé",
    city: "São Paulo",
    state: "SP",
    zip_code: "01001-000",
    country: "Brasil",
    pet_species: "Cachorro"
  },
  {
    email: "siid.live@hotmail.com",
    password: "123456",
    first_name: "Siid",
    last_name: "User",
    street: "Rua 25 de Março, 100, Centro",
    city: "São Paulo",
    state: "SP",
    zip_code: "01002-000",
    country: "Brasil",
    pet_species: "Gato"
  }
]

admin_users.each do |admin_data|
  user = User.create!(
    email: admin_data[:email],
    password: admin_data[:password],
    first_name: admin_data[:first_name],
    last_name: admin_data[:last_name],
    street: admin_data[:street],
    city: admin_data[:city],
    state: admin_data[:state],
    zip_code: admin_data[:zip_code],
    country: admin_data[:country]
  )
  puts "👤 [Admin] Criado usuário: #{user.first_name} #{user.last_name} (#{user.email})"

  # Assign coordinate from the array
  coord = coordinates[coord_index]
  coord_index += 1

  address = "#{admin_data[:street]}, #{admin_data[:city]}"
  Location.create!(
    user: user,
    address: address,
    city: admin_data[:city],
    state: admin_data[:state],
    zipcode: admin_data[:zip_code],
    latitude: coord[:lat],
    longitude: coord[:lng]
  )
  puts "📍 [Admin] Criada localização para #{user.first_name}: #{address} (lat: #{coord[:lat]}, lng: #{coord[:lng]})"

  # Cria o pet sem anexar imagens
  species = admin_data[:pet_species]
  pet_name = if species == "Cachorro"
               ["Thor", "Luna", "Max", "Bella", "Buddy", "Charlie", "Rocky", "Duke", "Cooper"].sample
             else
               ["Simba", "Nala", "Oliver", "Lucy", "Milo", "Loki", "Chloe", "Leo", "Mimi"].sample
             end
  breed = if species == "Cachorro"
            Pet::BREED_OPTIONS["Cachorro"].sample
          else
            Pet::BREED_OPTIONS["Gato"].sample
          end
  gender = Pet::GENDER_OPTIONS.sample
  age = rand(1..15)
  age_group = age < 2 ? "Filhote" : (age > 7 ? "Sênior" : "Adulto")
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

  pet.save!
  puts "🐾 [Admin] Criado pet: #{pet.name} para #{user.first_name}"
end

###########################
# 2. Criação de 18 Usuários Regulares
###########################

# Manual addresses list for 18 users – each address is unique and in São Paulo.
manual_addresses = [
  "Av. Paulista, 1578, Bela Vista",
  "Rua Augusta, 2400, Consolação",
  "Av. Brigadeiro Faria Lima, 2000, Itaim Bibi",
  "Rua Oscar Freire, 300, Jardins",
  "Rua da Consolação, 1580, República",
  "Av. Ibirapuera, 3500, Moema",
  "Rua dos Pinheiros, 500, Pinheiros",
  "Av. Rebouças, 1000, Pinheiros",
  "Rua Haddock Lobo, 1100, Cerqueira César",
  "Av. Angélica, 400, Higienópolis",
  "Rua da Mooca, 95, Mooca",
  "Av. São João, 2050, Centro",
  "Rua dos Alfeneiros, 600, Liberdade",
  "Av. Brasil, 1200, República",
  "Rua Augusta, 900, Consolação",
  "Av. Paulista, 2100, Bela Vista",
  "Rua Vergueiro, 1300, Liberdade",
  "Av. das Nações Unidas, 4000, Brooklin"
]

# Carrega os caminhos das imagens locais para cada espécie
dog_images = Dir.glob(Rails.root.join("db", "pet-images", "dog", "*")).sort
cat_images = Dir.glob(Rails.root.join("db", "pet-images", "cat", "*")).sort

if dog_images.size != 9 || cat_images.size != 9
  puts "❌ Espera-se 9 imagens em cada pasta (dog e cat). Verifique 'db/pet-images'."
  exit
end

total_users = manual_addresses.size  # 18 usuários

total_users.times do |i|
  # Para fins de log, escolhemos um nome de cluster de um conjunto predefinido.
  cluster_names = ["Largo da Batata", "Parque Villa-Lobos", "USP", "Victor Civita"]
  cluster_name = cluster_names[i % cluster_names.size]

  first_name = Faker::Name.first_name
  last_name  = Faker::Name.last_name
  email      = Faker::Internet.unique.email(name: "#{first_name} #{last_name}")
  street     = manual_addresses[i]
  city       = "São Paulo"
  state      = "SP"
  zip_code   = "01000-000"
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
  puts "👤 [#{cluster_name}] Criado usuário: #{user.first_name} #{user.last_name}"

  # Assign coordinate from the array
  coord = coordinates[coord_index]
  coord_index += 1

  address = "#{street}, #{city}"
  Location.create!(
    user: user,
    address: address,
    city: city,
    state: state,
    zipcode: zip_code,
    latitude: coord[:lat],
    longitude: coord[:lng]
  )
  puts "📍 [#{cluster_name}] Criada localização para #{user.first_name}: #{address} (lat: #{coord[:lat]}, lng: #{coord[:lng]})"

  # Define a espécie do pet: os 9 primeiros usuários recebem "Cachorro", os próximos 9 "Gato"
  species = i < 9 ? "Cachorro" : "Gato"
  pet_name = if species == "Cachorro"
               ["Thor", "Luna", "Max", "Bella", "Buddy", "Charlie", "Rocky", "Duke", "Cooper"].sample
             else
               ["Simba", "Nala", "Oliver", "Lucy", "Milo", "Loki", "Chloe", "Leo", "Mimi"].sample
             end
  breed = if species == "Cachorro"
            Pet::BREED_OPTIONS["Cachorro"].sample
          else
            Pet::BREED_OPTIONS["Gato"].sample
          end
  gender = Pet::GENDER_OPTIONS.sample
  age = rand(1..15)
  age_group = age < 2 ? "Filhote" : (age > 7 ? "Sênior" : "Adulto")
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

  begin
    if species == "Cachorro"
      image_path = dog_images[i]
    else
      image_path = cat_images[i - 9]
    end

    pet.photos.attach(
      io: File.open(image_path),
      filename: File.basename(image_path),
      content_type: "image/jpeg"
    )
    puts "🐾 [#{cluster_name}] Imagem anexada para #{pet.name} (#{species}) - #{File.basename(image_path)}"
  rescue => e
    puts "⚠️ [#{cluster_name}] Erro ao anexar imagem para #{pet.name}: #{e.message}"
  end

  pet.save!
  puts "🐾 [#{cluster_name}] Criado pet: #{pet.name} para #{user.first_name}"
end

puts "✅ Seeding completo!"
puts "👥 Total de usuários criados: #{User.count}"
puts "🐶🐱 Total de pets criados: #{Pet.count}"
puts "📍 Total de localizações criadas: #{Location.count}"
