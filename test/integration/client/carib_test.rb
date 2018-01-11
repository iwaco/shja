require_relative '../../test_helper'

class ClientCaribFunctionalTest < CaribFunctionalTest

  def test_download_index
    client.download_index() do |movie|
      assert_match /^https?:\/\/www\.caribbeancom\.com/, movie['url']
      assert_match /\d{6}-\d{3}/, movie['id']
      assert_match /https?:\/\/.*\.jpg/, movie['thumbnail']
      assert movie['title']
      assert_match /\d{4}-\d{2}-\d{2}/, movie['date']
      assert_kind_of Array,  movie['actors']

      movie = client.download_detail(movie)
      assert_kind_of Hash, movie['formats']
      movie['formats'].each do |k, v|
        assert_match /\d{3,}p/, k
        assert_match /https?:\/\/.*\.mp4/, v
      end
      assert_kind_of Array, movie['tags']
    end
  end

end
