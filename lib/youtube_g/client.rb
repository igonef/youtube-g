class YouTubeG
  class Client
    include YouTubeG::Logging
    include Utils

    # Previously this was a logger instance but we now do it globally
    def initialize(legacy_debug_flag = nil)
    end

    # Retrieves an array user playlists.
    #
    # === Parameters
    # If fetching playlists for a particular user:
    #   params<Hash>:: :user (required), :page (default is 1) and
    #                  :per_page(default is 25)
    #
    # === Returns
    # YouTubeG::Response::PlaylistSearch
    def playlists_by(params={})

      params[:page] = integer_or_default(params[:page], 1)

      unless params[:max_results]
        params[:max_results] = integer_or_default(params[:per_page], 25)
      end

      unless params[:offset]
        params[:offset] = calculate_offset(params[:page], params[:max_results] )
      end

      request = YouTubeG::Request::UserSearch.new(params, {:playlists => true})

      logger.debug "Submitting request [url=#{request.url}]." if logger
      parser = YouTubeG::Parser::PlaylistsFeedParser.new(request.url)
      parser.parse
    end

    # Retrieves a single YouTube playlist.
    #
    # === Parameters
    #   pid<String>:: The ID or URL of the playlist that you'd like to retrieve.
    #
    # === Returns
    # YouTubeG::Model::Playlist
    def playlist_by(pid)
      playlist_id = pid =~ /^http/ ? pid : "http://gdata.youtube.com/feeds/playlists/#{pid}"
      logger.debug "Submitting request [url=#{playlist_id}]." if logger
      parser = YouTubeG::Parser::PlaylistFeedParser.new(playlist_id)
      parser.parse
    end

    # Retrieves single playlist video or array of playlist video.
    #
    # === Parameters
    # If fetching videos (video) for a particular playlist:
    #   params<Hash>:: :playlist_id (required), :playlist_video_id,
    #                  :page (default is 1) and :per_page(default is 25)
    #
    # === Returns
    # YouTubeG::Response::VideoSearch if :playlist_video_id not present
    # YouTubeG::Model::Video if :playlist_video_id present
    #
    # === Note
    # :playlist_video_id - ID the video in playlist (by YouTubeG::Model::Video
    # in_playlist_id fuction, not YouTubeG::Model::Video unique_id method)
    def videos_by_playlist(params)
      params[:page] = integer_or_default(params[:page], 1)

      unless params[:max_results]
        params[:max_results] = integer_or_default(params[:per_page], 25)
      end

      unless params[:offset]
        params[:offset] = calculate_offset(params[:page], params[:max_results] )
      end

      request = YouTubeG::Request::PlaylistVideoSearch.new(params)

      logger.debug "Submitting request [url=#{request.url}]." if logger
      if params[:playlist_video_id] and params[:playlist_id]
        parser = YouTubeG::Parser::PlaylistVideoFeedParser.new(request.url)
        parser.parse(params[:playlist_id])
      else
        parser = YouTubeG::Parser::PlaylistVideosFeedParser.new(request.url)
        parser.parse
      end
    end

    # Retrieves an array channels.
    #
    # === Parameters
    # If fetching channels:
    #   params<Hash>::  :query, :alt (default is ATOM), :strict (default is false),
    #                   :page (default is 1) and :per_page(default is 25)
    #
    # === Returns
    # YouTubeG::Response::PlaylistSearch
    def channels_by(params={})

      params[:page] = integer_or_default(params[:page], 1)

      unless params[:max_results]
        params[:max_results] = integer_or_default(params[:per_page], 25)
      end

      unless params[:offset]
        params[:offset] = calculate_offset(params[:page], params[:max_results])
      end

      request = YouTubeG::Request::ChannelSearch.new(params)

      logger.debug "Submitting request [url=#{request.url}]." if logger
      parser = YouTubeG::Parser::ChannelsFeedParser.new(request.url)
      parser.parse
    end

    # Retrieves a single YouTube channel.
    #
    # === Parameters
    #   chid<String>:: The ID or URL of the playlist that you'd like to retrieve.
    #
    # === Returns
    # YouTubeG::Model::Channel
    def channel_by(chid)
      channel_id = chid =~ /^http/ ? chid : "http://gdata.youtube.com/feeds/api/channels/#{chid}?v=2"
      logger.debug "Submitting request [url=#{channel_id}]." if logger
      parser = YouTubeG::Parser::ChannelFeedParser.new(channel_id)
      parser.parse
    end

    # Retrieves an array of standard feed, custom query, or user videos.
    #
    # === Parameters
    # If fetching videos for a standard feed:
    #   params<Symbol>:: Accepts a symbol of :top_rated, :top_favorites, :most_viewed,
    #                    :most_popular, :most_recent, :most_discussed, :most_linked,
    #                    :most_responded, :recently_featured, and :watch_on_mobile.
    #
    #   You can find out more specific information about what each standard feed provides
    #   by visiting: http://code.google.com/apis/youtube/reference.html#Standard_feeds
    #
    #   options<Hash> (optional)::  Accepts the options of :time, :page (default is 1),
    #                               and :per_page (default is 25). :offset and :max_results
    #                               can also be passed for a custom offset.
    #
    # If fetching videos by tags, categories, query:
    #   params<Hash>:: Accepts the keys :tags, :categories, :query, :order_by,
    #                  :author, :racy, :response_format, :video_format, :page (default is 1),
    #                  and :per_page(default is 25)
    #
    #   options<Hash>:: Not used. (Optional)
    #
    # If fetching videos for a particular user:
    #   params<Hash>:: Key of :user with a value of the username.
    #   options<Hash>:: Not used. (Optional)
    # === Returns
    # YouTubeG::Response::VideoSearch
    def videos_by(params, options={})
      request_params = params.respond_to?(:to_hash) ? params : options
      request_params[:page] = integer_or_default(request_params[:page], 1)

      unless request_params[:max_results]
        request_params[:max_results] = integer_or_default(request_params[:per_page], 25)
      end

      unless request_params[:offset]
        request_params[:offset] = calculate_offset(request_params[:page], request_params[:max_results] )
      end

      if params.respond_to?(:to_hash) and not params[:user]
        request = YouTubeG::Request::VideoSearch.new(request_params)
      elsif (params.respond_to?(:to_hash) && params[:user]) || (params == :favorites)
        request = YouTubeG::Request::UserSearch.new(params, request_params)
      else
        request = YouTubeG::Request::StandardSearch.new(params, request_params)
      end

      logger.debug "Submitting request [url=#{request.url}]."
      parser = YouTubeG::Parser::VideosFeedParser.new(request.url)
      parser.parse
    end

    # Retrieves a single YouTube video.
    #
    # === Parameters
    #   vid<String>:: The ID or URL of the video that you'd like to retrieve.
    #
    # === Returns
    # YouTubeG::Model::Video
    def video_by(vid)
      video_id = vid =~ /^http/ ? vid : "http://gdata.youtube.com/feeds/videos/#{vid}"
      logger.debug "Submitting request [url=#{video_id}]." if logger
      parser = YouTubeG::Parser::VideoFeedParser.new(video_id)
      parser.parse
    end

  end
end