
TEST_MOVIES_ = {
  'lisa_movie' => {
    'id' => 'lisa_movie',
    'actor_id' => 'lisa',
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
  'lisa_movie2' => {
    'id' => 'lisa_movie2',
    'actor_id' => 'lisa',
    'title' => 'Lisa movie2',
    'url' => 'http://lisa2.url',
    'photoset_url' => 'http://lisa2.photoset_url.url',
    'date' => Date.parse('2016-03-27'),
    'zip_url' => 'http://lisa2.zip_url.url',
    'formats' => {
      '720p' => 'http://lisa2.720p.mp4',
      '480p' => 'http://lisa2.480p.mp4',
    },
    'thumbnail' => 'http://lisa2.png'
  },
  'serina_movie' => {
    'id' => 'serina_movie',
    'actor_id' => 'serina',
    'title' => 'Serina movie',
    'url' => 'http://serina.url',
    'photoset_url' => 'http://serina.photoset_url.url',
    'date' => Date.parse('2016-02-27'),
    'zip_url' => 'http://serina.zip_url.url',
    'formats' => {
      '720p' => 'http://serina.720p.mp4',
      '480p' => 'http://serina.480p.mp4',
    },
    'thumbnail' => 'http://serina.png'
  },
  'uta_movie' => {
    'id' => 'Exclusive-Uta_highres',
    'actor_id' => 'uta',
    'title' => 'Serina movie',
    'url' => 'http://uta.url',
    'photoset_url' => 'http://uta.photoset_url.url',
    'date' => Date.parse('2016-02-27'),
    'zip_url' => 'http://uta.zip_url.url',
    'formats' => {
      '720p' => 'http://uta.720p.mp4',
      '480p' => 'http://uta.480p.mp4',
    },
    'thumbnail' => 'http://uta.png'
  },
}

def mock_movie(title='lisa_movie')
  return Shja::Movie.new(TEST_MOVIES_[title].dup)
end
