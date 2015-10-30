# == Schema Information
#
# Table name: locations
#
#  id             :integer          not null, primary key
#  latitude       :float
#  longitude      :float
#  address        :string(255)
#  google_address :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  listing_id     :integer
#  person_id      :string(255)
#  location_type  :string(255)
#  community_id   :integer
#  city           :string(255)
#  state          :string(255)
#  zip            :integer
#
# Indexes
#
#  index_locations_on_community_id  (community_id)
#  index_locations_on_listing_id    (listing_id)
#  index_locations_on_person_id     (person_id)
#

class Location < ActiveRecord::Base

  belongs_to :person
  belongs_to :listing
  belongs_to :community

  scope :suggest_by_name, lambda{|address| select("DISTINCT(address)").where("lower(address) like lower(?) or lower(google_address) like lower(?)", "% #{address}%", "#{address}%")}


  def search_and_fill_latlng(address=nil, locale=APP_CONFIG.default_locale)
    okresponse = false
    geocoder = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address="

    if address == nil
      address = self.address
    end

    if address != nil && address != ""
      url = URI.escape(geocoder+address)
      resp = RestClient.get(url)
      result = JSON.parse(resp.body)

      if result["status"] == "OK"
        self.latitude = result["results"][0]["geometry"]["location"]["lat"]
        self.longitude = result["results"][0]["geometry"]["location"]["lng"]
        okresponse = true
      end
    end
    okresponse
  end

   def self.get_city(zip)
     location = Location.find_by_zip(zip)
     return location.state if location.present?
     puts("here")
     state =''
     geocoder = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=#{zip}&region=us"
     if(geocoder.present?)
       url = URI.escape(geocoder)
       resp = RestClient.get(url)
       result = JSON.parse(resp.body)
       address_components = result["results"][0]["address_components"]
       address_components.each do |adddress|
         if adddress["types"][0] == 'administrative_area_level_1'
           state = adddress["long_name"]
         end
       end
     end

     state
   end

  def get_country_code
    ip = ['development', 'test'].include?(Rails.env) ? '103.242.217.18' : request.ip
    location = GeoIP.new('GeoIP.dat').country(ip)
    location.present? ? location[:country_code2] : nil
  end

end
