def bm25(params)
  score = 0
  doc = params[:doc]
  query = params[:query]
  k = params.fetch(:k, 1.2)
  b = params.fetch(:b, 0.75)
  delta = params.fetch(:delta, 1.0)
  
  1.upto(query.length) do |term|
    numerator = tf(:term => term, :doc => doc) * (k + 1)
    denominator = tf(:term => term, :doc => doc) + k * (1 - b + b * (document_length(doc)/avgdl))
    score += idf(term) * (numerator/denominator) + delta
  end
  score
end

def tf(params)
  term = params[:term].downcase
  doc = params[:doc]
  terms_hash = Hash.new
  
  doc_terms = doc.gsub(/[^\s\p{Alnum}\p{Han}\p{Katakana}\p{Hiragana}\p{Hangul}]/,'').downcase.split
  doc_terms.each {|t| dic[t] == 1 ? dic[t] += 1 : dic[t] = 1 }
  # Return 0 if the term doesn't exist in the document,
  # else, return the term frequency.
  terms_hash[term].nil? ? 0 : terms_hash[term]
end

def idf(term)
  numerator = total_docs - docs_containing(term) + 0.5
  denominator = docs_containing(term) + 0.5
  Math.log(numerator / denominator)
end

def total_docs
  docs.size
end

def docs_containing(term)
end

def document_length(doc)
end

def avgdl
  docs.collect {|doc| document_length(doc)}.reduce(&:+) / total_docs
end
