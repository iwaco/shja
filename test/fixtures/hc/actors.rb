
TEST_HC_ACTORS_ = {
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
  'uta' => {
    'id' => 'uta',
    'url' => 'http://uta',
    'name' => 'Uta',
    'thumbnail' => 'http://uta.png'
  },
}

def mock_hc_actor(id='lisa')
  return Shja::Actor::Hc.new(TEST_HC_ACTORS_[id].dup)
end
