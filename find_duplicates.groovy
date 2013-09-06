/*
 * Keele
 * Find duplicate staff e-mails, poorly formatted titles and their urls.
 *
 * Author: DaniG2k
 *
 */

import static groovy.io.FileType.FILES;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

def ROOT = '/opt/funnelback/data'
def COLLECTION = 'people'
def VIEW = 'live'

def verbose = false // true if you want to see detailed output of titles, e-mails, urls and their duplicates

def urls = []
def emails = []
def titles = []

new File("${ROOT}/${COLLECTION}/${VIEW}/data/http/www.keele.ac.uk/").eachFileRecurse(FILES){ f ->
  content = f.getText()
  Document doc = Jsoup.parse(content.split("</DOCHDR>")[1]);

  Element profile = doc.getElementsByAttributeValueMatching("data-profile", "staff").first();
  if(profile) {
    content.find(/(?ism)base.href..(.*?)"/) { match, url ->
      urls.add(url);
    }
  }

  emails.add( getMetaContent(doc, "person_email", verbose) );
  titles.add( getMetaContent(doc, "DC.Title", verbose) );
  if( verbose ) { println urls.last(); println '';}
  }

private getMetaContent(content, metaName, verbose){
  Elements metaContent = content.select("meta[name=${metaName}]");
  for (Element elt : metaContent) {
    final String s = elt.attr("content");
    if(s) {
      if( verbose ) { println "${metaName}----> " + s; }
      return s;
    }
  }
}

private findTitlesWithUnderscores(titles){
  def with_underscore = []
  titles.each { t ->
    if( t.find(~/._./) ){
      with_underscore.add(t);
    }
  }
  return with_underscore;
}

private findDuplicateEmails(emails){
  def duplicates = []
  emails.each { email ->
    if( emails.count(email) > 1 && !(email in duplicates) ){
      duplicates.add(email);
    }
  }
  return duplicates;
}

if(verbose) {
  findDuplicateEmails(emails).each { email ->
    println "Duplicate e-mail: ${email}";
  }
}

println "\nNumber of duplicate e-mails: " + findDuplicateEmails(emails).size();
println "Number of names containing and underscore: " + findTitlesWithUnderscores(titles).size();
