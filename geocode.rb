require 'csv'
require 'geocoder'
require 'geocoder/results/nominatim'

require 'yaml'
require 'awesome_print'
require 'pry'

rows = CSV.parse(File.read("sample_building_data.csv"), headers: true)
data = Array.new
simple_data = Array.new

if(File.exist?('geocache.yml'))
  geocache = YAML.load(File.read("geocache.yml"))
else
  geocache = Hash.new
end

rows.drop(1).each do |row|
  place = [row[3], row[1]].join(',')
  puts place

  if geocache.has_key?(place)
    #binding.pry
    row[6] = geocache[place].data["lat"]
    row[7] = geocache[place].data["lon"]
  else
    geo = Geocoder.search(place)
    unless geo.first.nil?
      row[6] = geo.first.coordinates[0]
      row[7] = geo.first.coordinates[1]

      simple_data << geo.first

      ap geo.first

      geocache[place] = geo.first.coordinates
      geocache[place] = geo.first
    end
    sleep 1
  end

  data << row
end

File.open("geocache.yml", "w") { |file| file.write(geocache.to_yaml) }

CSV.open("geocoded_data.csv", "w") do |csv|
  csv << data
end
