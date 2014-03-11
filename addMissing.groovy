// Get all urls from matrixQueue.log and make sure they get added to Mercator's collections with
// a forced instant document add.

def logContents = new File('/opt/fb/custom_bin/messaging/log/matrixQueue.log').text
def lines = logContents.split("\\r?\\n")

def addList = []
def delList = []

// Separate list of document adds and document deletes into two lists.
lines.each{ line ->
  if (line.contains('instant-document-add')){
    addList << (line =~ /(http.*$)/)[0][0]
  } else if (line.contains('instant-document-delete')){
    delList << (line =~ /(http.*$)/)[0][0]
  }
}


// matrixQueue.log contains many duplicates since it tries to add a document 5 times.
// We will only do this once.
addList = addList.unique { a, b -> a <=> b }
delList = delList.unique { a, b -> a <=> b }

// List of Mercator collectioons
collections = ['boating-business',
        'engineering-capacity',
        'greenport',
        'maritime-journal',
        'motorship',
        'port-strategy',
        'seawork',
        'seawork-asia',
        'world-fishing']


// delList and addList contain a list of urls but they are not organized by collection.
// Here, we separate them by collection and return the list as a string.
def urlList(list, collection){
  def urls = []
  list.collect{
    // strip out the hyphen from the collection name
    if (it.contains("${collection.replaceAll('-','')}.com")){ urls << it }
  }
  return "${urls.join('\n')}"
}

// Make new add/delete files for each collection
[delList, addList].each { list ->
  collections.each {collection ->
    def action = (list == delList) ? 'delete' : 'add'

    // Add all missing urls to appropriate file
    // These files are all relative to the current directory.
    new File("${action}-${collection}-urls.txt").withWriter { out ->
      out.writeLine(urlList(list, collection))
    }


    // Now execute the bash command on that file
    def cmd = "/opt/fb/bin/update.pl /opt/fb/conf/global-${collection}/collection.cfg -instant-document-${action} ./${action}-${collection}-urls.txt"

    // Uncomment to see the output of which command is running:
    //println "Executing: ${cmd}"
    cmd.execute()

    // Wait for two minutes
    sleep(120000)
  }
}
