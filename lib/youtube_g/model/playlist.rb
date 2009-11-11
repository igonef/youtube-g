class YouTubeG
  module Model
    class Playlist < YouTubeG::Record
      # id, published?, updated, category*, title, content?, link*, author?, summary?, yt:countHint

      # *String*: Specifies a URI that uniquely and permanently identifies the playlist.
      attr_reader :playlist_id

      # *Time*:: When the playlist was published on Youtube.
      attr_reader :published_at

      # *Time*:: When the playlist's data was last updated.
      attr_reader :updated_at

      # *Array*:: A array of YouTubeG::Model::Category objects that describe the playlists categories.
      attr_reader :categories

      # *String*:: Title for the playlist.
      attr_reader :title

      # *String*:: User entered description for the playlist.
      attr_reader :description

      # *String*:: Html content for the playlist.
      attr_reader :html_content

      # YouTubeG::Model::Author:: Information about the YouTube user.
      attr_reader :author

      # *String*:: Link to playlist videos feed
      attr_reader :videos_link

      # *Fixnum*:: Specifies the number of entries in a playlist feed.
      attr_reader :count_hint

      # The ID of the playlist, useful for searching for the playlist again without having to store it anywhere.
      # A regular query search, with this id will return the same playlist.
      #
      # === Example
      #   >> playlist.unique_id
      #   => "ZTUVgYoeN_o"
      #
      # === Returns
      #   String: The Youtube playlist id.
      def unique_id
        playlist_id[/playlists\/([^<]+)/, 1]
      end

      # The maximal page number for playlist videos set.
      #
      # === Example
      #   >> playlist.max_page(per_page = 10)
      #   => 3
      #
      # === Returns
      #   Integer: The maximal page number.
      def max_page(per_page = 10)
        count_hint / per_page + (count_hint % per_page == 0 ? 0 : 1)
      end

    end
  end
end
