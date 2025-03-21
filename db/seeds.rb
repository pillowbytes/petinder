# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'open-uri'

# Clean existing data
puts "🧹 Cleaning database..."
Location.destroy_all
Pet.destroy_all
User.destroy_all

puts "🌱 Creating users, pets and locations..."

# Location coordinates for Largo da Batata area (with small variations)
largo_da_batata_coordinates = [
  { lat: -23.56683315047247, lng: -46.694642897321124 },
  { lat: -23.566842984462173, lng: -46.69512837714322 },
  { lat: -23.56715275476089, lng: -46.69447928257445 },
  { lat: -23.5672019245824, lng: -46.69428348132024 },
  { lat: -23.567315015102, lng: -46.69476091451545 }
]

# User data
users_data = [
  {
    email: "maria@example.com",
    password: "password123",
    first_name: "Maria",
    last_name: "Silva",
    street: "Rua Padre Carvalho, 25",
    city: "São Paulo",
    state: "SP",
    zip_code: "05424-010",
    country: "Brasil"
  },
  {
    email: "joao@example.com",
    password: "password123",
    first_name: "João",
    last_name: "Santos",
    street: "Rua Cardeal Arcoverde, 745",
    city: "São Paulo",
    state: "SP",
    zip_code: "05408-001",
    country: "Brasil"
  },
  {
    email: "ana@example.com",
    password: "password123",
    first_name: "Ana",
    last_name: "Ferreira",
    street: "Rua dos Pinheiros, 320",
    city: "São Paulo",
    state: "SP",
    zip_code: "05422-001",
    country: "Brasil"
  },
  {
    email: "pedro@example.com",
    password: "password123",
    first_name: "Pedro",
    last_name: "Costa",
    street: "Rua Teodoro Sampaio, 112",
    city: "São Paulo",
    state: "SP",
    zip_code: "05406-000",
    country: "Brasil"
  },
  {
    email: "julia@example.com",
    password: "password123",
    first_name: "Julia",
    last_name: "Lima",
    street: "Rua Fidalga, 58",
    city: "São Paulo",
    state: "SP",
    zip_code: "05432-000",
    country: "Brasil"
  }
]

# Pet data
pets_data = [
  {
    name: "Thor",
    species: "dog",
    breed: "Labrador",
    age: 3,
    gender: "male",
    bio: "Um cachorrinho brincalhão que adora passeios longos e brincar de buscar.",
    temperament: "friendly",
    size: "large",
    age_group: "adult",
    is_vaccinated: true,
    is_neutered: true,
    is_available_for_breeding: false,
    registered_pedigree: true,
    personality_traits: ["affectionate", "loyal", "playful"],
    looking_for: ["socialize"],
    preferred_species: ["dog"],
    preferred_size: ["medium"],
    status: "available",
    image_url: "https://images.unsplash.com/photo-1587300003388-59208cc962cb?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1770&q=80"
  },
  {
    name: "Luna",
    species: "dog",
    breed: "Golden_Retriever",
    age: 2,
    gender: "female",
    bio: "Uma companheira leal que adora carinhos e cafunés na barriga.",
    temperament: "calm",
    size: "large",
    age_group: "adult",
    is_vaccinated: true,
    is_neutered: false,
    is_available_for_breeding: true,
    registered_pedigree: true,
    personality_traits: ["affectionate", "loyal", "intelligent"],
    looking_for: ["breeding"],
    preferred_species: ["dog"],
    preferred_size: ["large"],
    status: "available",
    image_url: "https://images.unsplash.com/photo-1552053831-71594a27632d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1624&q=80"
  },
  {
    name: "Max",
    species: "dog",
    breed: "Bulldog",
    age: 4,
    gender: "male",
    bio: "Um cachorro energético que adora correr e brincar ao ar livre.",
    temperament: "energetic",
    size: "medium",
    age_group: "adult",
    is_vaccinated: true,
    is_neutered: true,
    is_available_for_breeding: false,
    registered_pedigree: false,
    personality_traits: ["active", "playful", "social"],
    looking_for: ["socialize"],
    preferred_species: ["dog"],
    preferred_size: ["medium"],
    status: "available",
    image_url: "https://images.unsplash.com/photo-1583337130417-3346a1be7dee?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1644&q=80"
  },
  {
    name: "Bella",
    species: "dog",
    breed: "Poodle",
    age: 1,
    gender: "female",
    bio: "Uma cachorrinha doce que se dá bem com crianças e outros animais.",
    temperament: "playful",
    size: "small",
    age_group: "puppy",
    is_vaccinated: true,
    is_neutered: false,
    is_available_for_breeding: false,
    registered_pedigree: true,
    personality_traits: ["affectionate", "intelligent", "curious"],
    looking_for: ["socialize"],
    preferred_species: ["dog"],
    preferred_size: ["small"],
    status: "available",
    image_url: "https://images.unsplash.com/photo-1594149929911-78975a43d4f5?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1770&q=80"
  },
  {
    name: "Simba",
    species: "cat",
    breed: "Maine_Coon",
    age: 3,
    gender: "male",
    bio: "Um gato curioso que adora explorar e escalar.",
    temperament: "friendly",
    size: "large",
    age_group: "adult",
    is_vaccinated: true,
    is_neutered: true,
    is_available_for_breeding: false,
    registered_pedigree: true,
    personality_traits: ["curious", "intelligent", "active"],
    looking_for: ["socialize"],
    preferred_species: ["cat"],
    preferred_size: ["medium"],
    status: "available",
    image_url: "https://images.unsplash.com/photo-1533738363-b7f9aef128ce?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1770&q=80"
  },
  {
    name: "Nala",
    species: "cat",
    breed: "Siamese",
    age: 2,
    gender: "female",
    bio: "Uma felina preguiçosa que adora tomar sol perto da janela.",
    temperament: "calm",
    size: "medium",
    age_group: "adult",
    is_vaccinated: true,
    is_neutered: false,
    is_available_for_breeding: true,
    registered_pedigree: true,
    personality_traits: ["independent", "affectionate", "intelligent"],
    looking_for: ["breeding"],
    preferred_species: ["cat"],
    preferred_size: ["medium"],
    status: "available",
    image_url: "https://images.unsplash.com/photo-1573865526739-10659fec78a5?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1770&q=80"
  },
  {
    name: "Oliver",
    species: "cat",
    breed: "Bengal",
    age: 1,
    gender: "male",
    bio: "Um gatinho brincalhão que adora perseguir brinquedos e fios.",
    temperament: "energetic",
    size: "medium",
    age_group: "kitten",
    is_vaccinated: true,
    is_neutered: false,
    is_available_for_breeding: false,
    registered_pedigree: true,
    personality_traits: ["playful", "active", "curious"],
    looking_for: ["socialize"],
    preferred_species: ["cat"],
    preferred_size: ["medium"],
    status: "available",
    image_url: "https://images.unsplash.com/photo-1577023311546-cdc07a8454d9?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1828&q=80"
  },
  {
    name: "Lucy",
    species: "cat",
    breed: "Persian",
    age: 5,
    gender: "female",
    bio: "Uma gata digna que aprecia um ambiente tranquilo.",
    temperament: "shy",
    size: "small",
    age_group: "senior",
    is_vaccinated: true,
    is_neutered: true,
    is_available_for_breeding: false,
    registered_pedigree: true,
    personality_traits: ["affectionate", "gentle", "independent"],
    looking_for: ["socialize"],
    preferred_species: ["cat"],
    preferred_size: ["small"],
    status: "available",
    image_url: "https://images.unsplash.com/photo-1518791841217-8f162f1e1131?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1770&q=80"
  }
]

# Create users, locations, and pets
users_data.each_with_index do |user_data, index|
  # Create user
  user = User.create!(
    email: user_data[:email],
    password: user_data[:password],
    first_name: user_data[:first_name],
    last_name: user_data[:last_name],
    street: user_data[:street],
    city: user_data[:city],
    state: user_data[:state],
    zip_code: user_data[:zip_code],
    country: user_data[:country]
  )

  puts "👤 Criado usuário: #{user.first_name} #{user.last_name}"

  # Create location for user
  coords = largo_da_batata_coordinates[index]
  location = Location.create!(
    user: user,
    address: user_data[:street] + ", " + user_data[:city],
    latitude: coords[:lat],
    longitude: coords[:lng],
    city: user_data[:city],
    state: user_data[:state],
    zipcode: user_data[:zip_code]
  )

  puts "📍 Criada localização para #{user.first_name} em Largo da Batata"

  # Assign 1-2 pets to each user
  start_index = index
  num_pets = [1, 2].sample

  num_pets.times do |i|
    pet_index = (start_index + i) % pets_data.length
    pet_data = pets_data[pet_index]

    # Create pet
    pet = Pet.new(
      user: user,
      name: pet_data[:name],
      species: pet_data[:species],
      breed: pet_data[:breed],
      age: pet_data[:age],
      gender: pet_data[:gender],
      bio: pet_data[:bio],
      temperament: pet_data[:temperament],
      size: pet_data[:size],
      age_group: pet_data[:age_group],
      is_vaccinated: pet_data[:is_vaccinated],
      is_neutered: pet_data[:is_neutered],
      is_available_for_breeding: pet_data[:is_available_for_breeding],
      registered_pedigree: pet_data[:registered_pedigree],
      personality_traits: pet_data[:personality_traits],
      looking_for: pet_data[:looking_for],
      preferred_species: pet_data[:preferred_species],
      preferred_size: pet_data[:preferred_size],
      status: pet_data[:status]
    )

    begin
      # Attach image from URL
      file = URI.open(pet_data[:image_url])
      pet.photos.attach(io: file, filename: "#{pet_data[:name].downcase}.jpg", content_type: "image/jpeg")

      pet.save!
      puts "🐾 Criado pet: #{pet.name} (#{pet.species}) para #{user.first_name}"
    rescue => e
      puts "⚠️ Erro ao anexar imagem: #{e.message}"

      # Fallback to alternative image URL if the primary fails
      begin
        file = URI.open("https://picsum.photos/seed/#{pet_data[:name].sum}/500/500")
        pet.photos.attach(io: file, filename: "#{pet_data[:name].downcase}_alt.jpg", content_type: "image/jpeg")
        pet.save!
        puts "🐾 Criado pet com imagem alternativa: #{pet.name}"
      rescue => e2
        puts "❌ Não foi possível anexar nem mesmo uma imagem alternativa: #{e2.message}"
        # Ensure at least one pet per user by continuing without image
        pet.save(validate: false)
        puts "🐾 Criado pet sem imagem: #{pet.name}"
      end
    end
  end

  # Ensure each user has at least one pet
  if user.pets.empty?
    # Add a fallback pet if all attempts failed
    fallback_pet = Pet.new(
      user: user,
      name: "Pet #{user.first_name}",
      species: ["dog", "cat"].sample,
      breed: "Other",
      age: rand(1..10),
      gender: ["male", "female"].sample,
      bio: "Pet de emergência criado para #{user.first_name}.",
      temperament: Pet::TEMPERAMENT_OPTIONS.sample,
      size: Pet::SIZE_OPTIONS.sample,
      age_group: Pet::AGE_GROUP_OPTIONS.sample,
      is_vaccinated: true,
      is_neutered: true,
      is_available_for_breeding: false,
      registered_pedigree: false,
      personality_traits: [Pet::PERSONALITY_TRAITS_OPTIONS.sample],
      looking_for: ["socialize"],
      preferred_species: ["anything"],
      preferred_size: [Pet::SIZE_OPTIONS.sample],
      status: "available"
    )

    # Try to attach a generic image
    begin
      file = URI.open("https://picsum.photos/seed/fallback#{rand(1000)}/500/500")
      fallback_pet.photos.attach(io: file, filename: "fallback_pet.jpg", content_type: "image/jpeg")
    rescue => e
      puts "⚠️ Não foi possível anexar imagem para pet de emergência: #{e.message}"
    end

    fallback_pet.save!
    puts "🆘 Criado pet de emergência para #{user.first_name}"
  end
end

puts "✅ Seeding completo!"
puts "👥 Criados #{User.count} usuários"
puts "🐶🐱 Criados #{Pet.count} pets"
puts "📍 Criados #{Location.count} localizações"
