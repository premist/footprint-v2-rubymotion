class Foursquare
  def initialize(params = {})
    @base_url = params[:base_url] || "https://api.foursquare.com/v2"
    @api_version = params[:api_version] || "20151217"
    @client_id = params[:client_id] || App::Env["FOURSQUARE_CLIENT_ID"]
    @client_secret = params[:client_secret] || App::Env["FOURSQUARE_CLIENT_SECRET"]
  end

  def qs_prefix
    "?client_id=#{@client_id}&client_secret=#{@client_secret}&v=#{@api_version}"
  end

  def get_venues(params = {}, &block)
    latitude = params[:latitude]
    longitude = params[:longitude]
    query = params[:query]

    qs = qs_prefix + "&ll=#{latitude},#{longitude}"
    qs << "&query=#{query.escape_url}" if query != nil

    AFMotion::JSON.get("#{@base_url}/venues/search#{qs}") do |response|
      venues = response.object["response"]["venues"]

      block.call(venues)
    end
  end
end
