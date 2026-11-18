# frozen_string_literal: true

require 'cgi'
require 'rsolr'

SitemapGenerator::Sitemap.default_host = ENV.fetch('SITE_URL')
# Keep robots.txt's /sitemap.xml URL stable as the catalog grows. The index
# stays uncompressed; the gem compresses and splits the record sitemaps.
SitemapGenerator::Sitemap.create_index = true
SitemapGenerator::Sitemap.compress = :all_but_first

solr = RSolr.connect(url: ENV.fetch('SOLR_URL', 'http://127.0.0.1:8983/solr/blacklight-core'),
                     open_timeout: 10, timeout: 60)

SitemapGenerator::Sitemap.create do
  # The gem adds the home page automatically.
  add '/about', lastmod: nil

  cursor = '*'
  loop do
    response = solr.get('select', params: {
      q: '*:*', fl: 'layer_slug_s', sort: 'layer_slug_s asc',
      rows: 1000, cursorMark: cursor, wt: 'json'
    })
    response.fetch('response').fetch('docs').each do |document|
      slug = CGI.escape(document.fetch('layer_slug_s')).gsub('+', '%20')
      add "/catalog/#{slug}", lastmod: nil
    end

    next_cursor = response.fetch('nextCursorMark')
    break if next_cursor == cursor

    cursor = next_cursor
  end
end
