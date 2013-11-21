class GitHub
  attr_accessor :token, :user

  def initialize(token, &block)
    @token = token
    self.user do |json|
      @user = json
      block.call
    end
  end

  def user(&block)
    self.get("https://api.github.com/user", &block)
  end

  def events(&block)
    self.get(@user['received_events_url'], &block)
  end

  def get(url, &block)
    BW::HTTP.get(url, {:credentials => {:username => @token, :password => ""}}) { |response| block.call(BW::JSON.parse(response.body)) }
  end
end