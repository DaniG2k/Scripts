require 'mechanize'

class Crawler
  def initialize(params={})
    @include_patterns = params[:include_patterns]
    @stop_url_pattern = Regexp.new params[:stop_url_pattern]
    @visited = []
  end

  def crawl(uri)
    @visited << uri unless @visited.include?(uri)
    a = Mechanize.new
    a.get(uri) do |page|
      puts "Currently scanning '#{page.title}'"
      page.links.each do |link|
        if stop_pattern_found_in(link.uri.to_s) || stop_pattern_found_in(page.uri.merge(link.uri).to_s)
          puts "\n! ! !\tStop condition reached\t! ! !"
          puts "The link was found on #{page.title} with uri #{page.uri}\n"
        else
          l = link.uri.to_s
          unless @visited.include?(l) || @visited.include?(page.uri.merge(l))
            begin
              crawl(l) if url_crawlable?(l)
            rescue ArgumentError
              url = page.uri.merge(l)
              puts "Relative url found: #{l}"
              puts "Converting to relative url: #{url}"
              crawl(url) if url_crawlable?(url.to_s)
            rescue Mechanize::UnauthorizedError
              puts "Unauthorized access: #{link.uri}"
            rescue Mechanize::ResponseCodeError
              puts "Response Code Error: #{link.uri}"
            rescue URI::InvalidURIError
              puts "Invalid URI: #{link.uri}"
              puts "Trying again with URI escaping..."
              crawl URI.escape(l)
            rescue => e
              puts e
            end
          end
        end
      end
    end
  end

  private
  def url_crawlable?(url)
    @include_patterns.any? {|pattern| url.include?(pattern) }
  end

  def stop_pattern_found_in(url)
    @stop_url_pattern =~ url
  end
end

ucl = Crawler.new(:include_patterns => ['www.ucl.ac.uk/'],
                  :stop_url_pattern => '/ucl.ac.uk')
ucl.crawl 'http://www.ucl.ac.uk/lifelearning/'
