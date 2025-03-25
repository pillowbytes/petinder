# db/seeds.rb
require 'faker'

# Configure Faker for Brazilian Portuguese
Faker::Config.locale = 'pt-BR'

puts "🧹 Limpando banco de dados..."
Location.destroy_all
Pet.destroy_all
User.destroy_all

puts "🌱 Iniciando criação de 18 usuários e pets..."

# Define clusters with a base coordinate (lat, lng) for each
clusters = {
  "Largo da Batata"   => { lat: -23.567033, lng: -46.695134 },
  "Parque Villa-Lobos" => { lat: -23.543500, lng: -46.727571 },
  "USP"               => { lat: -23.561500, lng: -46.731000 },
  "Victor Civita"     => { lat: -23.565000, lng: -46.688000 }
}
cluster_names = clusters.keys

# Load local image file paths for each species
dog_images = Dir.glob(Rails.root.join("db", "pet-images", "dog", "*")).sort
cat_images = Dir.glob(Rails.root.join("db", "pet-images", "cat", "*")).sort

if dog_images.size != 9 || cat_images.size != 9
  puts "❌ Espera-se 9 imagens em cada pasta (dog e cat). Verifique 'db/pet-images'."
  exit
end

# We'll assign first 9 users as dogs and the next 9 as cats.
total_users = 18

total_users.times do |i|
  # Determine cluster using round-robin over the cluster names.
  cluster_name = cluster_names[i % cluster_names.size]
  base_coord = clusters[cluster_name]

  # Create user with realistic Faker data
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
  puts "👤 [#{cluster_name}] Criado usuário: #{user.first_name} #{user.last_name}"

  # Generate location: start with the cluster's base coordinate and add a small random jitter
  # Jitter range is chosen randomly for natural variation.
  jitter_lat = rand(-0.0008..0.0008)
  jitter_lng = rand(-0.0008..0.0008)
  lat = base_coord[:lat] + jitter_lat
  lng = base_coord[:lng] + jitter_lng
  address = "#{street}, #{city}"  # You can also use the cluster name if preferred

  Location.create!(
    user: user,
    address: address,
    latitude: lat,
    longitude: lng,
    city: city,
    state: state,
    zipcode: zip_code
  )
  puts "📍 [#{cluster_name}] Criada localização para #{user.first_name}: (lat: #{lat.round(6)}, lng: #{lng.round(6)})"

  # Decide pet species: first 9 users get "Cachorro" (dog), next 9 get "Gato" (cat)
  species = i < 9 ? "Cachorro" : "Gato"
  pet_name = if species == "Cachorro"
               # You may choose a dog name from a fixed list or Faker data.
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

  # Attach the pet image from the local folder.
  image_path = if species == "Cachorro"
                 dog_images[i]  # since first 9 users are dogs, use index 0..8
               else
                 cat_images[i - 9]  # for users 9..17, subtract 9 for index into cat images
               end

  begin
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
