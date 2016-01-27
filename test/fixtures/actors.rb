
TEST_ACTORS = {
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
}.map {|k, v| [k, Shja::Actor.new(v)]}.to_h
