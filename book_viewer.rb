require "tilt/erubis"
require "sinatra"
require "sinatra/reloader" if development?

helpers do
  def in_paragraphs(string)
    string.split("\n\n").map.with_index do |paragraph, index|
      "<p id='#{index}'>" + paragraph + "</p>"
    end.join
  end

  def highlighted(string, highlight)
    string.gsub(highlight, "<strong>#{highlight}</strong>")
  end
end

before do
  @contents = File.readlines("data/toc.txt")
end

def each_chapter
  return to_enum(:each_chapter) unless block_given?

  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield(name, number, contents)
  end
end

def matches(query)
  results = []
  return results if !query || query.empty?

  each_chapter do |chapter_name, chapter_number, contents|
    if contents.match(query)
      contents.split("\n\n").each_with_index do |para_text, para_index|
        if para_text.match(query)
          result =
            {
              para_text: para_text,
              para_index: para_index,
              chapter_name: chapter_name,
              chapter_number: chapter_number
            }
          results << result
        end
      end
    end
  end

  results
end


get "/search" do
  query = params[:query]
  @results = matches(query)
  erb(:search)
end


get "/" do
  @title = 'The Adventures of Sherlock Holmes'

  erb(:home)
end

get "/test" do
  @words = ["blubber", "beluga", "galoshes", "mukluk", "narwhal"]
  erb :test
end

get "/chapters/:number" do |number|
  num = number.to_i
  chapter_name = @contents[num - 1]
  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{params['number']}.txt")

  erb(:chapter)
end

not_found do
  redirect '/'
  puts "have redirected!"
end
