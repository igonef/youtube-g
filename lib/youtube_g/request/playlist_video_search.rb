class YouTubeG
  module Request #:nodoc:
    class PlaylistVideoSearch < BaseSearch #:nodoc:
      attr_reader :max_results                     # max_results
      attr_reader :order_by                        # orderby, ([relevance], viewCount, published, rating)
      attr_reader :offset                          # start-index

      def initialize(params)
        @max_results, @order_by, @offset = nil
        @url = base_url

        @url << "/" << params[:playlist_id] if params[:playlist_id]
        # Return a single video in playlist (base_url + /playlist_id/playlist_video_id)
        return @url << "/" << params[:playlist_video_id] if params[:playlist_video_id] and params[:playlist_id]

        @url << "/-/" if (params[:categories] || params[:tags])
        @url << categories_to_params(params.delete(:categories)) if params[:categories]
        @url << tags_to_params(params.delete(:tags)) if params[:tags]

        set_instance_variables(params)

        if( params[ :only_embeddable ] )
          @video_format = ONLY_EMBEDDABLE
        end

        @url << build_query_params(to_youtube_params)
      end

      private

      def base_url #:nodoc:
        super << "playlists"
      end

      def to_youtube_params #:nodoc:
        {
          'max-results' => @max_results,
          'orderby' => @order_by,
          'start-index' => @offset
        }
      end
    end

  end
end