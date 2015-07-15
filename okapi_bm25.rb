class Ranker
  def initialize(params)
    @doc = params[:doc]
    @query_terms = params[:query].split

    # Variables that can be used for BM25+
    @k = params.fetch(:k, 1.2)
    @b = params.fetch(:b, 0.75)
    @delta = params.fetch(:delta, 1.0)
  end

  def bm25
    score = 0
    @query_terms.each do |term|
      numerator = term_freq(term) * (@k + 1)
      denominator = term_freq(term) + @k * (1 - @b + @b * (@doc.length / avg_dl))
      score += idf(term) * (numerator/denominator) + @delta
    end
    score
  end
  
  def term_freq(term)
    terms_hash = Hash.new
    doc_terms = @doc.gsub(/[^\s\p{Alnum}\p{Han}\p{Katakana}\p{Hiragana}\p{Hangul}]/,'').downcase.split
    
    # Count occurrences of term in @doc and
    # add them to terms_hash.
    doc_terms.each do |t|
      if terms_hash[t].nil?
        terms_hash[t] = 1
      else
        terms_hash[t] += 1
      end
    end
    # Return 0 if the term doesn't exist in the document,
    # else, return the term frequency.
    terms_hash[term].nil? ? 0 : terms_hash[term]
  end

  def idf(term)
    numerator = total_docs - docs_containing_term + 0.5
    denominator = docs_containing_term + 0.5
    Math.log(numerator / denominator)
  end
end

class DocAnalyser
  attr_accessor :docs, :term

  def initialize(params)
    @docs = params[:docs]
    @term = params[:term]
  end

  def total
    @docs.size
  end
  
  def avg_dl
    doc_lengths = 0
    @docs.each {|doc| doc_lengths += doc.length}
    doc_lengths / total_docs
  end

  def containing_term
    total = 0
    @docs.each {|doc| total += 1 if doc.include?(@term)}
    total
  end
end
