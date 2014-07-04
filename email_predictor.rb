#!/usr/bin/ruby

class Advisor
  attr_reader :name, :domain
  # Use an args hash in case we want to easily add other
  # parameters in the future without remembering their order.
  def initialize(args)
    @name = args[:name]
    @domain = args[:domain]
  end
  def email
    EmailPredictor.new(:name => @name, :domain => @domain).predict_email
  end
end

class EmailPredictor
  attr_reader :name, :domain
  
  def initialize(args)
    @name = args[:name]
    @domain = args[:domain]
    # A database of known name/email pairs.
    @db = {
      "John Ferguson" => "john.ferguson@alphasights.com",
      "Damon Aw" => "damon.aw@alphasights.com",
      "Linda Li" => "linda.li@alphasights.com",
      "Larry Page" => "larry.p@google.com",
      "Sergey Brin" => "s.brin@google.com",
      "Steve Jobs" => "s.j@apple.com"
    }
  end
  
  def predict_email
    # Lambdas for our possible e-mail formats
    fn_ln = -> (n, d){"#{n.join('.')}@#{d}"}
    fn_li = -> (n, d){"#{n[0]}.#{n[1][0]}@#{d}"}
    fi_ln = -> (n, d){"#{n[0][0]}.#{n[1]}@#{d}"}
    fi_li = -> (n, d){"#{n[0][0]}.#{n[1][0]}@#{d}"}
    
    predicted_email_type = nil
    # First, check if it's in the db of known email formats.
    @db.each do |k, v|
      db_obj = Email.new(:name => k, :email => v)
      if @domain == db_obj.domain
        predicted_email_type = db_obj.type
        break
      end
    end
    
    split_name = @name.downcase.split
    case predicted_email_type
    when "FirstName.LastName"
      fn_ln.call(split_name, @domain)
    when "FirstName.LastInital"
      fn_li.call(split_name, @domain)
    when "FirstInitial.LastName"
      fi_ln.call(split_name, @domain)
    when "FirstInitial.LastInital"
      fi_li.call(split_name, @domain)
    else
      [fn_ln.call(split_name, @domain),
      fn_li.call(split_name, @domain),
      fi_ln.call(split_name, @domain),
      fi_li.call(split_name, @domain)]
    end
  end
end

class Email
  attr_reader :email, :name
  
  def initialize(args)
    @name = args[:name]
    @email = args[:email]
  end
  
  def domain
    /@(.*$)/.match(@email)[1]
  end
  
  def type
    case @email
    when first_name_dot_last_name
      "FirstName.LastName"
    when first_name_dot_last_initial
      "FirstName.LastInital"
    when first_initial_dot_last_name
      "FirstInitial.LastName"
    when first_initial_dot_last_initial
      "FirstInitial.LastInital"
    else
      # We shouldn't have to reach this :P
      "Unknown e-mail format."
    end
  end
  
  private
  # We could make these lambda functions or something
  # else but this makes for better readability.
    def first_name_dot_last_name
      /(^\w\w+\.\w\w+)@/
    end
    def first_name_dot_last_initial
      /(^\w\w+\.\w)@/
    end
    def first_initial_dot_last_name
      /(^\w\.\w\w+)@/
    end
    def first_initial_dot_last_initial
      /(^\w\.\w)@/
    end
end

# Tests:
Advisor.new(:name => "Peter Wong", :domain => "alphasights.com").email == "peter.wong@alphasights.com"
Advisor.new(:name => "Craig Silverstein", :domain => "google.com").email == "craig.s@google.com"
Advisor.new(:name => "Steve Wozniak", :domain => "apple.com").email == "s.w@apple.com"
Advisor.new(:name => "Barack Obama", :domain => "whitehouse.gov").email == ['barack.obama@whitehouse.gov', 'barack.o@whitehouse.gov', 'b.obama@whitehouse.gov', 'b.o@whitehouse.gov']
