require File.dirname(__FILE__) + '/helper'

class TestPlaylistSearch < Test::Unit::TestCase

  def test_should_build_url_for_playlists_by_user
    request = YouTubeG::Request::UserSearch.new({:user => 'liz'}, {:playlists => true})
    assert_equal "http://gdata.youtube.com/feeds/api/users/liz/playlists", request.url
  end

end

