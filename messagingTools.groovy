// Funnelback UK
// D. Pestilli - Jul 2013
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;
import redis.clients.jedis.exceptions.JedisConnectionException;

import java.util.Date;
import java.text.SimpleDateFormat;
//import java.util.logging.Logger;

import groovy.json.JsonBuilder;
import groovy.json.JsonSlurper;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


def checkConfigFileExists(pathToConfig){
	def config_file = new File(pathToConfig)
	if(!config_file.exists()){
		println 'Config file does not seem to exist.'
		return false
	} else {
		return true
	}
}

class redisMessagingTools {

        def port = 6379
	def timeout = 100
        static hostName
	static password
	static queueName
	Logger log
	JedisPool jpool

	redisMessagingTools(pathToConfig) {
		this.log = LoggerFactory.getLogger('redisToolsClient')
		log.info('Starting Client')
		
		try {	
			log.info("Attempting to parse {} configuration file", pathToConfig)
			def config = new ConfigSlurper().parse(new File(pathToConfig).toURL())
			redisMessagingTools.queueName = config.queueName ?: 'matrix'
			redisMessagingTools.password = config.password ?: ''
 			redisMessagingTools.hostName = config.hostName ?: 'localhost'
			log.info("properties {} set on {}", config.toString(), this.class)

			// Only try creating a new jedis pool object if the config file
			// was successfully found.
			try {
				/* JedisPool constructor takes poolConfig, host, port, timeout and password */
				jpool =  new JedisPool(new JedisPoolConfig(), hostName, port, timeout, password)
			} catch(Exception e) {
				log.info("Could not open connection to RedisDB: {}\n{}", e, e.getStackTrace())
			}
		} catch(FileNotFoundException e) {
			log.info("File {} produced error: {}", pathToConfig, e)
		}
		
	}
	
	def checkAmericanDate(d, m){
		// If the day is less than 12 and the month is less than 31
		// this might be an American format date. Return with swapped values.
		d <= 12 && d >= 1 && m <= 31 && m >= 12 ? [m, d] : [d, m]
	}

	def dateIsOk(String date){
		def d = date[0..1].toInteger()
    		def m = date[3..4].toInteger()
		def day = checkAmericanDate(d, m)[0]
		def month = checkAmericanDate(d, m)[1]
		def year = date[6..-1].toInteger()
		
    		if(day > 31 || day < 1){
        		log.info('Invalid day input.')
			return false
		} else if(month > 12 || month < 1) {
		        log.info('Invalid month input.')
			return false
		} else if(year < 1970){
		        log.info('Invalid year input.')
			return false
		} else {
			return true
		}
	}	

	/* Returns a Date object in milliseconds from
 	* either ddMMyyyy or dd/MM/yyyy
 	*/
	def parseDate(String date) {
		def pattern = ''
       		def temp = date.trim()
		date = temp

		if (date.size() < 8 || date.size() == 9 || date.size() > 10){
 		   log.info('The date format {} does not appear to be correct.', date)
		} else if(date.contains('/') && dateIsOk(date)){
			pattern = 'dd/MM/yyyy'
    		} else if (date.contains('-') && dateIsOk(date)){
			pattern = 'dd-MM-yyyy'	
		} else {
			pattern = 'ddMMyyyy'
		}
		try{
			Date d = new SimpleDateFormat(pattern, Locale.ENGLISH).parse(date)
			//println d.getTime()
			// return the UNIX time in milliseconds
			return d.getTime()
		} catch(Exception e){
			log.info('A date error has occurred: {}', e)
		}
	}

	/* Input one, possibly two dates. If no second
	 * date is specified, default to inputting the
	 * same one twice
	 */
	def getMessagesByDate(dateA, dateB=dateA) {
		def start = parseDate(dateA)
		def stop = parseDate(dateB)	
		if( start == stop ){ stop += 86399000 } // milliseconds in a day
		
		def messageDb = this.jpool.getResource()
		try{
			def messages = messageDb.zrangeByScore(this.queueName, start, stop)
			return messages
		} finally {
			this.jpool.returnResource(messageDb)
		}
		return null
	}
	
	// Get a key's Time To Live
	def getMessageTTL(key) {
		def msg = this.jpool.getResource()
		return msg.ttl(key)
	}
	

	def zAddMessage(key, score=0, member=''){
		def messageDb = this.jpool.getResource()
		try{
			messageDb.zadd(key, score, member);
		} finally {
			this.jpool.returnResource(messageDb)
		}
	}

	def zRemMessage(key, member){
		def messageDb = this.jpool.getResource()
		try{
			messageDb.zrem(key, member);
		} finally {
			this.jpool.returnResource(messageDb)
		}
	}
	// Close the application:
	//this.jpool.destroy();

}

/*
// Convert a hash object to a string
// This makes it easier to put hashes into redis
def hashToString(hash) {
	return hash.toString()
}
// Convert a string object to a hash map
// This makes it easier to retrieve hashes from redis
// that are being stored as strings.
def stringToHash(String s) {
	def map = [:]
	def string = s[1..-2]
	def strarray = string.split(",")
	
	strarray.each { kvarray ->
		def kv = kvarray.trim().split(':')
		map[kv[0]] = kv[1]
	}
	return map
}
*/

def serialize(hash){
	builder = new JsonBuilder()
	builder(hash)
	return builder.toString()
}

def deserialize(String s){
	slurper = new JsonSlurper()
	return slurper.parseText(s)
}


def x = new redisMessagingTools('config.groovy')
def hash = [0:'tiger', 1:'mouse', 2:'rabbit', 3:'dragon'] 
println x.parseDate('11-07-2013')

x.zAddMessage('myzset', 1373497200000, 'cat')
x.zAddMessage('myzset', 1373497200001, 'dog')

x.zAddMessage('myzset', 1373497200002, serialize(hash))
println x.getMessagesByDate('11072013')

println '\nConvert string back to hash:\n  '+deserialize(serialize(hash))

println x.getMessagesByDate('11072013')
println '\nRemove string \'cat\' from myzset:\n  '
x.zRemMessage('myzset', 'cat')
println x.getMessagesByDate('11072013')

println '\nRemove hashmap:\n  '
x.zRemMessage('myzset',serialize(hash))
println x.getMessagesByDate('11072013')
println '\n'
println x.getMessagesByDate('02-06-2013')
println x.getMessageTTL('mykey')

