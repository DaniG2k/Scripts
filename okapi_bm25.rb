class Collection
  def initialize(params)
    @docs = params[:docs]
    @query = params[:query]
  end

  def bm25_rank
    @docs.each do |doc|
      rank = Ranker.new
    end
  end

  def containing_term(term)
    total = 0
    @docs.each do |doc|
      total += 1 if doc.include? term 
    end
    total
  end
  
  def avg_dl
    doc_lengths = 0
    @docs.each do |doc|
      doc_lengths += doc.length
    end
    doc_lengths / total_docs
  end

  def total_docs
    @docs.size
  end
end

class Query
end

class Document
  attr_accessor :rank, :body

  def initialize(params)
    @body = params.fetch(:body,'')
    @rank = params.fetch(:rank, nil)
  end

  def length
    @body.length
  end

  def include?(term)
    @body.include? term
  end
end

doc1 = Document.new(:body => "Many are convinced that they haven't seen the last of Mr. Hashimoto. On February 1st, 2014, he had already claimed he would resign as Osaka mayor. An article by Forbes quoted one politician that same year, who remarked, “Hashimoto is like a bluefin tuna: he has to keep moving [which is to say, fight with vested interests for something] to survive.” According to the Japan Times Kenji Eda, the Lower House member with whom Hashimoto jointly set up Ishin no To (Japan Innovation Party), also commented, “He’s the kind of politician who only comes along once every 20 or 30 years. I’m sure he'll be back.” Eda also said he himself would step down as party leader following this crushing defeat.")
doc2 = Document.new(:body => "Former lawyer and TV personality, Toru Hashimoto, first assumed office in November 2011. A glib speaker and lady-swooner, he is particularly admired for his ostensible strength of character and for his unconventional background: as this e-magazine has previously evinced, his father was a burakumin (historically outcast people considered impure) as well as a yakuza gang member. He committed suicide when Toru was in second grade. Mr. Hashimoto now has seven children – four daughters and three sons – with his wife Noriko, whom he publicly admitted to have cheated on with a club hostess between 2006 and 2008. In 2013, he claimed that the “comfort women” (prostitutes) that the Japanese military coerced during its invasion of Korea was “necessary” so that Japanese soldiers could have a chance “to rest” BBC News quotes.")

collection = Collection.new(:docs => [doc1, doc2], :query => "Hashimoto")

class Ranker
  attr_accessor :collection, :query

  def initialize(params)
    @collection = params[:collection]
    @query_terms = params[:query].split
  end

  def bm25(params)
    dl = @doc.length
    # Variables that can be tuned for BM25+
    k = params.fetch(:k, 1.2)
    b = params.fetch(:b, 0.75)
    delta = params.fetch(:delta, 1.0)

    score = 0
    @query_terms.each do |term|
      numerator = term_freq(term) * (k + 1)
      denominator = term_freq(term) + k * (1 - b + b * (dl / avg_dl))
      score += idf(term) * (numerator/denominator) + delta
    end
    score
  end
  
  def term_freq(term)
    # Will need something better here to clean out the documents.
    doc_terms = @doc.gsub(/[^\s\p{Alnum}\p{Han}\p{Katakana}\p{Hiragana}\p{Hangul}]/,'').downcase.split
    doc_terms.count(term) 
  end

  def idf(term)
    numerator = total_docs - containing_term(term) + 0.5
    denominator = containing_term(term) + 0.5
    Math.log(numerator / denominator)
  end
end


