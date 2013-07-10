// Funnelback UK
// D. Pestilli - Jul 2013
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;
import redis.clients.jedis.exceptions.JedisConnectionException;

import java.util.Date;
//import java.util.logging.Logger;

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
		def format = ''
		println date.size()
       		if (date.size() < 8 || date.size() > 10){
 		   log.info('The date format {} does not appear to be correct.', date)
		} else if(date.contains('/') && dateIsOk(date)){
			format = 'dd/MM/yyyy'
    		} else if (date.contains('-') && dateIsOk(date)){
			format = 'dd-MM-yyyy'	
		} else {
			format = 'ddMMyyyy'
		}
		def newDate = new Date().parse(format, date)
        	// return the UNIX time in milliseconds
		return newDate.getTime()
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
	
	// Close the application:
	//jpool.destroy();
}


def x = new redisMessagingTools('onfig.groovy')
println x.getMessagesByDate('02-06-2013')
println x.getMessageTTL('mykey')
