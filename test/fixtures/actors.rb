
TEST_ACTORS_ = {
  'lisa' => {
    'id' => 'lisa',
    'url' => 'http://lisa',
    'name' => 'Lisa',
    'thumbnail' => 'http://lisa.png'
  },
  'serina' => {
    'id' => 'serina',
    'url' => 'http://serina',
    'name' => 'Serina',
    'thumbnail' => 'http://serina.png'
  },
  'serina' => {
    'id' => 'chuling',
    'url' => 'http://chuling',
    'name' => 'Chuling',
    'thumbnail' => 'http://chuling.png'
  },
}

def mock_actor(id='lisa')
  return Shja::Actor.new(TEST_ACTORS_[id].dup)
end
