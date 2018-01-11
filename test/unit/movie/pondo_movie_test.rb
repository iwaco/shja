require 'test_helper'

# class PondoMovieTest < ShjaPondoTest
#   attr_reader :movie
#
#   def setup
#     super
#     # @movie = mock_pondo_movie('mari_movie')
#   end
#
#   def test_enable_snake_case_attributes
#     assert_equal(movie['MovieID'], movie.movie_id)
#     assert_equal(movie['UCNAME'], movie.uc_name)
#   end
#
#   def test_to_path_with_sym
#     assert_equal(
#       File.join(context.target_dir, "2016-06/061516_317"),
#       movie.to_path(:dir_url)
#     )
#   end
#
#   def test_to_path
#     assert_equal(
#       File.join(context.target_dir, "2016-06/061516_317"),
#       movie.to_path(movie.dir_url)
#     )
#   end
#
#   def test_dir_url
#     assert_equal("2016-06/061516_317", movie.dir_url)
#   end
#
#   def test_thumbnail_url
#     assert_equal("2016-06/061516_317.jpg", movie.thumbnail_url)
#   end
#
#   def test_photoset_metadata_url
#     assert_equal("2016-06/061516_317/photoset_metadata.json", movie.photoset_metadata_url)
#   end
#
#   def test_metadata_url
#     assert_equal("2016-06/061516_317/metadata.json", movie.metadata_url)
#   end
#
#   def test_photoset_metadata_real_url
#     assert_equal("http://www.1pondo.tv/dyn/ren/movie_galleries/3440.json", movie.photoset_metadata_remote_url)
#   end
#
#   def test_metadata_real_url
#     assert_equal("http://www.1pondo.tv/dyn/ren/movie_details/3440.json", movie.metadata_remote_url)
#   end
#
#   def test_detail
#     movie.stubs(:to_path).returns(File.join(PONDO_FAKE_RESPONSE_DIR, "details_00.json"))
#     assert_kind_of(Shja::Movie::Pondo::Detail, movie.detail)
#   end
#
# end

# class PondoMovieDetailsTest < ShjaPondoTest
#
#   def get_detail
#     Shja::Movie::Pondo::Detail.new(
#       context,
#       File.join(PONDO_FAKE_RESPONSE_DIR, "details_00.json")
#     )
#   end
#
#   def test_remote_url
#     detail = get_detail
#
#     assert_equal(
#       ["http://dl11.1pondo.tv/member/movies/060216_309/240p.mp4", 178915007],
#       detail.remote_url("240p")
#     )
#     assert_equal(
#       ["http://dl11.1pondo.tv/member/movies/060216_309/1080p.mp4", 1939044192],
#       detail.remote_url("1080p")
#     )
#   end
#
#   def test_formats
#     detail = get_detail
#
#     assert_equal(["240p", "360p", "480p", "720p", "1080p"], detail.formats)
#   end
#
#   def test_default_format
#     detail = get_detail
#
#     assert_equal("1080p", detail.default_format)
#   end
# end
