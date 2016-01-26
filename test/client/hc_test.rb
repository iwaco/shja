require 'test_helper'

class ShjaClientHcTest < Minitest::Test

  def setup
    @client = Shja::Client::Hc.new
  end

  def test_fetch_actors
    letters = sequence('letters')
    ('A'..'F').each do |letter|
      @client.expects(:fetch_index_page)
        .with(letter: letter)
        .returns([letter])
        .in_sequence(letters)
    end
    actors = @client.fetch_actors(first_letter: 'A', last_letter: 'F')
    assert_equal(['A', 'B', 'C', 'D', 'E', 'F'], actors)
  end

  def test_fetch_index_page
    expected_index_url = "http://ex.shemalejapanhardcore.com/members/categories/models/1/name/A/"
    expects_urls = [0, 1]
    expects_actors = ['a', 'b']

    parser = mock()
    parser.expects(:parse_pagination).returns(expects_urls)

    Shja::Parser::HcIndexPage.stubs(:new).returns(parser)
    urls = sequence('urls')
    @client.expects(:_fetch_page).with(expected_index_url).returns('c').in_sequence(urls)
    @client.expects(:_fetch_page).with(0).returns('c').in_sequence(urls)
    parser.expects(:parse_actors).returns(expects_actors).in_sequence(urls)
    @client.expects(:_fetch_page).with(1).returns('c').in_sequence(urls)
    parser.expects(:parse_actors).returns(expects_actors).in_sequence(urls)

    actors = @client.fetch_index_page
    assert_equal(expects_actors + expects_actors, actors)
  end

  def test__fetch_page
    expected_url = 'URL'
    expected_content = 'CONTENT'
    page = mock()
    page.stubs(:content).returns(expected_content)
    @client.stubs(:is_login).returns(true)

    @client.agent.expects(:get).with(expected_url).returns(page)
    content = @client._fetch_page(expected_url)
    assert_equal(expected_content, content)
  end

  def test__fetch_index_page
    page = 'PAGE_CONTENT'
    @client.stubs(:is_login).returns(true)

    expected_url = "http://ex.shemalejapanhardcore.com/members/categories/models/11/name/Z/"
    @client.expects(:_fetch_page).with(expected_url).returns(page)
    @client._fetch_index_page(letter: 'Z', index: 10)
  end

end
