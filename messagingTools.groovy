mport redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;
import redis.clients.jedis.exceptions.JedisConnectionException;

import java.util.Date;
//import java.util.logging.Logger;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


class redisMessagingTools {

        def port = 6379
        def timeout = 5
        static password //'AnwkHnT2lnGL5Qdlp9hb+A'
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
                        log.info("properties {} set on {}", config.toString(), this.class)
                } catch(FileNotFoundException e) {
                                   log.info("File {} produced error: {}", pathToConfig, e)
                }
                try {
                        /* JedisPool constructor takes poolConfig, host, port, timeout and password */
                        jpool =  new JedisPool(new JedisPoolConfig(), hostName, port, timeout, password)
                } catch(Exception e) {
                        log.info("Could not open connection to RedisDB: {}\n{}", e, e.getStackTrace())
                }
        }
        /* Returns a Date object in milliseconds from
        * either ddMMyyyy or dd/MM/yyyy
        */
        def parseDate(String date) {
                def s = date.contains('/') ? "dd/MM/yyyy" : "ddMMyyyy"
                def newDate = new Date().parse(s, date)
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
                        def queue = 'myzset'
                        messages = messageDb.zrangeByScore(queue, start, stop)
                } finally {
                        this.jpool.returnResource(messageDb)
                }
                return messages
        }

        // Get a key's Time To Live
                def getMessageTTL(key) {
                def msg = this.jpool.getResource()
                return msg.ttl(key)
        }
        //println getMessageTTL('mykey')

        // Close the application:
        //jpool.destroy();
}


def x = new redisMessagingTools('config.groovy')
println x.getMessagesByDate('02062013')
