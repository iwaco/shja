require 'mechanize'

agent = Mechanize.new
agent.user_agent = 'Mac Safari'

page = agent.post(
  'https://login.d2pass.com/mercury/check/86c4446e-390e-46ee-b0ef-483eb1082557'
)
puts page

page = agent.post(
  'https://ws.1pondo.tv/msjs/469/u7dp_35u/xhr_send',
  '["{\"MsgID\":5,\"Data\":{\"User\":\"yuan-d2pass@fraction.jp\",\"Pass\":\"mo520128\"},\"noReply\":true,\"AppID\":10,\"RequestID\":0,\"PageID\":1}"]'
)
p page
