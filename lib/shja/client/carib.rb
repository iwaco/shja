
class Shja::Client::Carib < Shja::D2PassClient

  def agent_class
    Shja::Agent::Carib
  end

  def download_index(start_page: 0, last_page: 0)
    rtn = []
    agent.login
    (start_page..last_page).each do |index|
      index += 1
      url = "http://www.caribbeancom.com/listpages/all#{index}.htm"
      Shja.log.info("Fetch Index: #{url}")
      html = agent.fetch_page(url)

      Shja::Parser::CaribIndexPage.new(html).parse do |movie|
        Shja.log.info("Processing: #{movie['title']}")
        if block_given?
          yield movie
        else
          rtn << movie
        end
      end
    end

    return rtn
  end

  def download_detail(movie)
    url = movie['url']
    Shja.log.info("Loading Detail for: #{url}")
    html = agent.fetch_page(url)
    Shja::Parser::CaribDetailPage.new(html).parse(movie)
  end

end
