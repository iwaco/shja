
TEST_MOVIES_ = {
  'lisa_movie' => {
    'actor_id' => 'actor_id',
    'title' => 'Lisa movie',
    'url' => 'http://lisa.url',
    'photoset_url' => 'http://lisa.photoset_url.url',
    'date' => Date.parse('2016-01-27'),
    'zip_url' => 'http://lisa.zip_url.url',
    'formats' => {
      '720p' => 'http://lisa.720p.mp4',
      '480p' => 'http://lisa.480p.mp4',
    },
    'thumbnail' => 'http://lisa.png'
  },
}

def mock_movie(title='lisa_movie')
  return Shja::Movie.new(TEST_MOVIES_[title].dup)
end
