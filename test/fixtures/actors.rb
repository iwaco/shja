
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
  'chuling' => {
    'id' => 'chuling',
    'url' => 'http://chuling',
    'name' => 'Chuling',
    'thumbnail' => 'http://chuling.png'
  },
  'saki' => {
    'id' => 'saki',
    'url' => 'http://saki',
    'name' => 'Saki',
    'thumbnail' => 'http://saki.png'
  },
  'haruna' => {
    'id' => 'haruna',
    'url' => 'http://haruna',
    'name' => 'Haruna',
    'thumbnail' => 'http://haruna.png'
  },
}

def mock_actor(id='lisa')
  return Shja::Actor.new(TEST_ACTORS_[id].dup)
end
