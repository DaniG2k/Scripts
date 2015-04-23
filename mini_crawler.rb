require 'mechanize'

class Crawler
  def initialize(params={})
    @include_patterns = params[:include_patterns]
    @stop_url_pattern = params[:stop_url_pattern]
    @visited = Array.new
    @unwanted_urls = Array.new
  end
  
  def crawl(uri)
    @visited << uri unless @visited.include?(uri)
    
    agent = Mechanize.new
    agent.get(uri) do |page|
      puts "Currently scanning '#{page.title}'"
      page.links.each do |link|
        link_str = link.uri.to_s
        if(stop_pattern_found_in(link_str) || stop_pattern_found_in(page.uri.merge(link.uri).to_s))
          puts "\n! ! !\tStop condition reached\t! ! !"
          puts "Link #{link_str} was found on '#{page.title}' with uri #{page.uri}\n"
          # Append to @unwanted_urls list
          @unwanted_urls << [page.uri.to_s, link_str]
        else
          unless @visited.include?(link_str) || @visited.include?(page.uri.merge(link.uri).to_s)
            begin
              # The recursive crawl takes place here:
              crawl(link_str) if url_crawlable?(link_str)
            rescue ArgumentError
              full_url = page.uri.merge(link_str).to_s
              puts "Relative url found: #{link_str}"
              puts "Converting to relative url: #{full_url}"
              crawl(full_url) if url_crawlable?(full_url)
            rescue Mechanize::UnauthorizedError
              puts "Unauthorized access: #{link.uri}"
            rescue Mechanize::ResponseCodeError
              puts "Response Code Error: #{link.uri}"
            rescue URI::InvalidURIError
              puts "Invalid URI: #{link.uri}"
              puts "Trying again with URI escaping..."
              crawl URI.escape(link_str)
            rescue => e
              puts e
            end
          end
        end
      end
    end
  end

  def visited
    @visited
  end

  def unwanted_urls
    @unwanted_urls
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
                  :stop_url_pattern => /\/ucl.ac.uk\/?$/)
ucl.crawl 'http://www.ucl.ac.uk/lifelearning/'

puts "\n Visited urls:"
p ucl.visited
puts "\n Unwanted urls:"
p ucl.unwanted_urls
