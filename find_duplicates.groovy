/*
 * Keele U.
 *
 * Find duplicate staff e-mails, poorly formatted titles and their urls.
 *
 * Author: dpestilli
 *
 */

import static groovy.io.FileType.FILES;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

def ROOT = '/opt/funnelback'
def COLLECTION = 'people'
def VIEW = 'live'

def verbose = true // Make true if you want to see detailed output of titles, e-mails, urls and their duplicates

def urls = []
def emails = []
def titles = []
def names = []

new File("${ROOT}/data/${COLLECTION}/${VIEW}/data/http/www.keele.ac.uk/").eachFileRecurse(FILES){ f ->
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
  names.add( getStaffNames(doc) );
  if( verbose ) { println urls.last(); println ''; }
}

private getStaffNames(content){
  def staffNames = []
  def h4 = content.select("h4");
  h4.each { elt ->
    if( elt.getElementsByClass("ui-widget-header").first() ){
      staffNames.add(elt.text());
    }
  }
  return staffNames;
}

private getMetaContent(content, metaName, verbose){
    Elements metaContent = content.select("meta[name=${metaName}]");
  for (Element elt : metaContent) {
    final String s = elt.attr("content");
    if(s) {
      if( verbose ) {
        def tabs = ("${metaName}".size() > 8) ? 1 : 2 // Set number of tabs for proper formatting.
        println "${metaName} --->" + ("\t" * tabs) + s;
      }
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
  println "Duplicate e-mails:\n";
  findDuplicateEmails(emails).each { email ->
    println "\t${email}";
  }
  println '\n';
  println "Proper names of staff members:\n";
  names.each { name -> println '\t' + name[0]; }
}

println "\nNumber of duplicate e-mails: " + findDuplicateEmails(emails).size();
println "Number of names containing and underscore: " + findTitlesWithUnderscores(titles).size();
