class YouTubeG
  module Request #:nodoc:
    class UserSearch < BaseSearch #:nodoc:
      attr_reader :max_results                     # max_results
      attr_reader :order_by                        # orderby, ([relevance], viewCount, published, rating)
      attr_reader :offset                          # start-index
      attr_reader :time                            # time

      def initialize(params, options={})
        @max_results, @order_by, @offset, @time = nil
        @url = base_url

        if params == :favorites
          @url << "#{options[:user]}/favorites"
          set_instance_variables(options)
        elsif params[:user] && options[:favorites]
          @url << "#{params[:user]}/favorites"
          set_instance_variables(params)
          break
        elsif params == :playlists
          @url << "#{options[:user]}/playlists"
          set_instance_variables(options)
        elsif params[:user] && options[:playlists]
          @url << "#{params[:user]}/playlists"
          set_instance_variables(options)
        elsif params[:user]
          @url << "#{params[:user]}/uploads"
          set_instance_variables(params)
        end

        @url << build_query_params(to_youtube_params)
      end

      private

      def base_url
        super << "users/"
      end

      def to_youtube_params
        {
          'max-results' => @max_results,
          'orderby' => @order_by,
          'start-index' => @offset,
          'time' => @time
        }
      end
    end

  end
end