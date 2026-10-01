# frozen_string_literal: true

module DataNexus
  # Wrapper for paginated API responses
  #
  # Provides convenience methods for accessing data and navigating through pages.
  # The underlying data remains as hashes - this class just adds pagination helpers.
  #
  # @example Accessing data
  #   collection = client.members.list
  #   collection.data.each { |member| puts member[:first_name] }
  #
  # @example Manual pagination
  #   collection = client.members.list(first: 50)
  #   while collection
  #     process(collection.data)
  #     collection = collection.next_page
  #   end
  #
  # @example Block pagination
  #   client.members.list(first: 50).each_page do |page|
  #     page.data.each { |member| puts member[:first_name] }
  #   end
  #
  class Collection
    # @return [Array<Hash>] The records in this page
    attr_reader :data

    # @return [String, nil] Cursor for the start of this page
    attr_reader :start_cursor

    # @return [String, nil] Cursor for the end of this page
    attr_reader :end_cursor

    # Initialize a new Collection
    #
    # @param response [Hash] The raw API response
    # @param resource [Object] The resource instance that made the request
    # @param params [Hash] The params used for the original request
    def initialize(response, resource:, params:)
      @data = response[:data] || []
      @start_cursor = response[:start_cursor]
      @end_cursor = response[:end_cursor]
      @has_next_page = response[:has_next_page]
      @has_previous_page = response[:has_previous_page]
      @resource = resource
      @params = params
    end

    # Check if there's a next page of results
    #
    # Uses the response's has_next_page flag when the endpoint sends one,
    # and otherwise assumes a page with an end_cursor may have a next page.
    #
    # @return [Boolean]
    def next_page?
      return false if @has_next_page == false

      !end_cursor.nil? && !end_cursor.empty?
    end

    # Fetch the next page of results
    #
    # Returns nil if the API responds with this same page again (an endpoint
    # that ignores the cursor), so iterating all pages always terminates.
    #
    # @return [Collection, nil] The next page, or nil if no more pages
    def next_page
      return nil unless next_page?

      page = @resource.list(**@params, after: end_cursor)
      page unless page&.end_cursor == end_cursor
    end

    # Check if there's a previous page of results
    #
    # Uses the response's has_previous_page flag when the endpoint sends one,
    # and otherwise assumes a page with a start_cursor may have a previous page.
    #
    # @return [Boolean]
    def previous_page?
      return false if @has_previous_page == false

      !start_cursor.nil? && !start_cursor.empty?
    end

    # Fetch the previous page of results
    #
    # Returns nil if the API responds with this same page again (an endpoint
    # that ignores the cursor).
    #
    # @return [Collection, nil] The previous page, or nil if no more pages
    def previous_page
      return nil unless previous_page?

      page = @resource.list(**@params, before: start_cursor)
      page unless page&.start_cursor == start_cursor
    end

    # Iterate through all pages starting from this one
    #
    # @yield [Collection] Each page of results
    # @return [Enumerator] If no block given
    def each_page
      return enum_for(:each_page) unless block_given?

      page = self
      while page
        yield page
        page = page.next_page
      end
    end

    # Iterate through all records across all pages
    #
    # @yield [Hash] Each record
    # @return [Enumerator] If no block given
    def each_record(&block)
      return enum_for(:each_record) unless block_given?

      each_page do |page|
        page.data.each(&block)
      end
    end

    alias each each_record

    # @return [Boolean] Whether this page has any records
    def empty?
      data.empty?
    end

    # @return [Integer] Number of records in this page
    def size
      data.size
    end

    alias length size
  end
end
