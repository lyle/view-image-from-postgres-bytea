#!/usr/bin/env ruby

require "bundler/setup"
require 'sinatra'
require 'rubygems'
require 'data_mapper'
require 'dm-core'
#require 'quick_magick'
require 'pry'
require 'pg'

 
 DataMapper::Logger.new(STDOUT, :debug)
 DataMapper.setup(:default, 'postgres://readgs:readme@localhost/geekspeak_production')
 
class Show
     include DataMapper::Resource
     property :id, Serial
     property :title, String
     property :abstract, Text
     property :content, Text
     property :showtime, DateTime
     belongs_to :teaser, 'Image',
      :child_key  => [:teaser_id],
      :required => false
     has n, :imagesshow, "Images_Shows"
     
  def to_param 
    self.showtime.strftime("%Y/%m/%d")
  end
end

class Image
    include DataMapper::Resource 
    property :id, Serial
    property :name, String
    property :data, Binary,   :lazy => true
    
    has n, :teaseshow, 'Show',
      :parent_key => [ :id ],      # local to this model (Blog)
      :child_key  => [ :teaser_id ]  # in the remote model (Post)
    has n, :imagesshow, 'Images_Shows'
    
end

class Images_Shows
  include DataMapper::Resource
  property :show_id, Serial
  property :image_id, Serial
  belongs_to :show
  belongs_to :image
end

DataMapper.finalize
 
get '/' do
   @shows = Show.all(:limit => 400)
   erb :index
end

get %r{/shows/(\d\d\d\d/\d\d/\d\d)/teaser.jpg} do
  @theDate = params[:captures].first
  @dayStart = DateTime.parse("#{@theDate}T00:00:00")
  @dayEnd = DateTime.parse("#{@theDate}T24:00:00")
  @show = Show.first(:showtime => @dayStart..@dayEnd)
  
  content_type 'text/plain'
  PGconn.unescape_bytea(@show.teaser.data)
end

get %r{/shows/(\d\d\d\d/\d\d/\d\d)/(.*\.jpg)} do
  @theDate = params[:captures].first
  @dayStart = DateTime.parse("#{@theDate}T00:00:00")
  @dayEnd = DateTime.parse("#{@theDate}T24:00:00")
  @show = Show.first(:showtime => @dayStart..@dayEnd)
  @image = @show.imagesshow.images.first(:name=>params[:captures].last)
  content_type 'image/jpg'
  PGconn.unescape_bytea(@image.data)
  
end

get %r{/shows/(\d\d\d\d/\d\d/\d\d)/} do
  @theDate = params[:captures].first
  @dayStart = DateTime.parse("#{@theDate}T00:00:00")
  @dayEnd = DateTime.parse("#{@theDate}T24:00:00")
  @show = Show.first(:showtime => @dayStart..@dayEnd)
  "Hello, '#{params[:captures].first}'! #{@show.title}"   
  # - #{@show.title}"
  
end

def mtext_process(text)
  acronym_matcher= /\[\s?([A-Z]*)\s?\|\s?([\w\s\/]*)\s?\]/
  link_matcher= /\[([^|\]]*)\|\s?(https*:\/\/[^\]]*)\]/
 
  text.gsub!(acronym_matcher, '<acronym title="\2">\1</acronym>')
  text.gsub!(link_matcher, '<a href="\2">\1</a>')
  
end

def teaser_image(show)
  if show.teaser_id then
		return "<img src='/shows/#{show.to_param}/#{show.teaser.name}' />"
	end
end

