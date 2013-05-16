#!/usr/bin/env ruby

# Created by Daniele Pestilli 16 May 2013
# Licensed under Create Commons Attribution License

if !ARGV[0] or !ARGV[1]
  puts <<-EOF
Please provide SEARCH_HOME and COLLECTION_NAME

Usage:
  cfg_sanity_check SEARCH_HOME COLLECTION_NAME
EOF
  abort
else
  options = {}
  options[:home] = ARGV[0]
  options[:coll_name] = ARGV[1]
  
  # This is where the two main config files are supposed to be.
  config = options[:home] + '/conf/' + options[:coll_name] + '/collection.cfg'
  default_config = options[:home] + '/conf/collection.cfg.default'

  path_error_msg = "does not exist. Please make sure the configuration files are in the correct location."
  if !File.exists? config
    puts config + path_error_msg
    abort
  elsif !File.exists? default_config
    puts default_config + path_error_msg
    abort
  end
end

# Get all the flags from files up to the equals sign
# and return a sorted and unique array of config flags
def get_flags(*files)
  matches = []
  begin
    files.each do |f|
      file = File.new(f, 'r')
      while (line = file.gets)
        m = line.match(/(^.*=)?/)
        matches << m[0] if m
      end
      file.close
    end
  rescue => err
    puts 'Exception: #{err}'
    err
  end
  matches.uniq.sort!
end

flags = ["access_alternate=", "access_restriction=", "admin.undeletable=", "admin_email=", "analytics.data_miner.range_in_days=", "analytics.outlier.day.minimum_average_count=", "analytics.outlier.day.threshold=", "analytics.outlier.exclude_collection=", "analytics.outlier.exclude_profiles=", "analytics.outlier.hour.minimum_average_count=", "analytics.outlier.hour.threshold=", "analytics.reports.checkpoint_rate=", "analytics.reports.disable_incremental_reporting=", "analytics.reports.max_day_resolution_daterange=", "analytics.reports.max_facts_per_dimension_combination=", "annie.index_opts=", "changeover_percent=", "click_data.archive_dirs=", "click_data.num_archived_logs_to_use=", "click_data.use_click_data_in_index=", "click_data.week_limit=", "click_tracking=", "collection=", "collection_root=", "collection_type=", "connector.additional.Additional=sharepointConnectorUrl=", "connector.change_detection=", "connector.classname=", "connector.credentials.Domain=", "connector.credentials.Password=", "connector.credentials.UserName=", "connector.custom_action_java_class=", "connector.discover=", "connector.mapping.filename=", "connector.maximum_concurrent_connections=", "connector.repository.exclude_pattern=", "connector.repository.include_pattern=", "connector.selection_policy.class=", "continuous-updating.admin.auto-commit-timeout=", "continuous-updating.admin.entry-limit=", "continuous-updating.collection-mgmt.component-limit=", "continuous-updating.collection-mgmt.post-snapshot-command=", "continuous-updating.collection-mgmt.snapshot-directory=", "continuous-updating.collection-mgmt.snapshot-name=", "continuous-updating.configuration-refresh-interval=", "continuous-updating.consolidation-mgmt.consolidation-max-threads=", "continuous-updating.consolidation-mgmt.rebuild-interval=", "continuous-updating.consolidation-mgmt.rebuild-percent=", "continuous-updating.consolidation-mgmt.vacuum-only=", "continuous-updating.log-generation-limit=", "continuous-updating.log-interval=", "continuous-updating.log-level=", "continuous-updating.log-max-size=", "continuous-updating.log-name=", "continuous-updating.log-type=", "continuous-updating.logfile-pattern=", "continuous-updating.start-type=", "continuous-updating.syslog-facility=", "continuous-updating.syslog-host=", "crawler.accept_cookies=", "crawler.accept_files=", "crawler.cache.DNSCache_max_size=", "crawler.cache.LRUCache_max_size=", "crawler.cache.URLCache_max_size=", "crawler.check_alias_exists=", "crawler.checkpoint_to=", "crawler.classes.AreaCache=", "crawler.classes.Crawler=", "crawler.classes.Frontier=", "crawler.classes.Policy=", "crawler.classes.RevisitPolicy=", "crawler.classes.Scanner=", "crawler.classes.ServerCache=", "crawler.classes.ServerInfoCache=", "crawler.classes.SignatureCache=", "crawler.classes.StoreCache=", "crawler.classes.URLCache=", "crawler.classes.URLStore=", "crawler.classes.statistics=", "crawler.defer_current_info_storage=", "crawler.eliminate_duplicates=", "crawler.extract_links_from_javascript=", "crawler.follow_links_in_comments=", "crawler.form_interaction_file=", "crawler.frontier_hosts=", "crawler.frontier_num_top_level_dirs=", "crawler.frontier_port=", "crawler.frontier_use_ip_mapping=", "crawler.header_logging=", "crawler.incremental_logging=", "crawler.inline_filtering_enabled=", "crawler.link_extraction_group=", "crawler.link_extraction_regular_expression=", "crawler.logfile=", "crawler.lowercase_iis_urls=", "crawler.max_dir_depth=", "crawler.max_download_size=", "crawler.max_files_per_area=", "crawler.max_files_per_server=", "crawler.max_files_stored=", "crawler.max_individual_frontier_size=", "crawler.max_link_distance=", "crawler.max_parse_size=", "crawler.max_timeout_retries=", "crawler.max_url_length=", "crawler.max_url_repeating_elements=", "crawler.monitor_authentication_cookie_renewal_interval=", "crawler.monitor_checkpoint_interval=", "crawler.monitor_delay_type=", "crawler.monitor_halt=", "crawler.monitor_preferred_servers_list=", "crawler.monitor_time_interval=", "crawler.monitor_url_reject_list=", "crawler.non_html=", "crawler.num_crawlers=", "crawler.overall_crawl_timeout=", "crawler.overall_crawl_units=", "crawler.packages.httplib=", "crawler.parser.mimeTypes=", "crawler.protocols=", "crawler.reject_files=", "crawler.remove_parameters=", "crawler.request_delay=", "crawler.request_header=", "crawler.request_header_url_prefix=", "crawler.request_timeout=", "crawler.revisit.edit_distance_threshold=", "crawler.revisit.num_times_revisit_skipped_threshold=", "crawler.revisit.num_times_unchanged_threshold=", "crawler.robotAgent=", "crawler.secondary_store_root=", "crawler.server_alias_file=", "crawler.sslClientStore=", "crawler.sslClientStorePassword=", "crawler.sslTrustEveryone=", "crawler.sslTrustStore=", "crawler.start_urls_file=", "crawler.store_all_types=", "crawler.store_headers=", "crawler.use_sitemap_xml=", "crawler.user_agent=", "crawler.verbosity=", "crawler=", "crawler_binaries=", "data_report=", "data_root=", "db.custom_action_java_class=", "db.full_sql_query=", "db.incremental_sql_query=", "db.incremental_update_type=", "db.jdbc_class=", "db.jdbc_url=", "db.password=", "db.primary_id_column=", "db.single_item_sql=", "db.update_table_name=", "db.use_column_labels=", "db.username=", "db.xml_root_element=", "directory.context_factory=", "directory.domain=", "directory.page_size=", "directory.password=", "directory.provider_url=", "directory.search_base=", "directory.search_filter=", "directory.username=", "document_level_security.action=", "document_level_security.custom_command=", "document_level_security.max2check=", "document_level_security.mode=", "duplicate_detection=", "enable_clean_html=", "exclude_patterns=", "filecopy.cache=", "filecopy.discard_filtering_errors=", "filecopy.domain=", "filecopy.exclude_pattern=", "filecopy.filetypes=", "filecopy.include_pattern=", "filecopy.max_files_stored=", "filecopy.novell.mount_point=", "filecopy.novell.server=", "filecopy.num_fetchers=", "filecopy.num_workers=", "filecopy.passwd=", "filecopy.request_delay=", "filecopy.security_model=", "filecopy.source=", "filecopy.source_list=", "filecopy.user=", "filecopy.walker_class=", "filter.classes=", "filter.discard_filtering_errors=", "filter.num_worker_threads=", "filter.tika.types=", "filter=", "form_security.allow_exec_tags=", "form_security.allow_query_transforms=", "form_security.allow_read_tags=", "form_security.allow_result_transforms=", "ftp_passwd=", "ftp_user=", "gather.slowdown.days=", "gather.slowdown.hours.from=", "gather.slowdown.hours.to=", "gather.slowdown.request_delay=", "gather.slowdown.threads=", "gather=", "http_passwd=", "http_proxy=", "http_proxy_passwd=", "http_proxy_port=", "http_proxy_user=", "http_source_host=", "http_user=", "include_patterns=", "index=", "indexer=", "indexer_options=", "indexing.use_manifest=", "java_libraries=", "java_options=", "logging.hostname_in_filename=", "mail.on_failure_only=", "max_heap_size=", "noindex_expression=", "post_gather_command=", "post_index_command=", "post_update_command=", "pre_gather_command=", "pre_index_command=", "pre_reporting_command=", "progress_report_interval=", "query_completion.alpha=", "query_completion.delay=", "query_completion.format=", "query_completion.length=", "query_completion.program=", "query_completion.show=", "query_completion.sort=", "query_completion.source.extra=", "query_completion.source=", "query_completion=", "query_processor=", "query_processor_options=", "related.api_enabled=", "result_transform=", "retry_policy.max_tries=", "schedule.incremental_crawl_ratio=", "search_user=", "secure_dirs=", "security.earlybinding.entropysoft.exclude_domain_from_username=", "security.earlybinding.locks-keys-matcher.ldlibrarypath=", "security.earlybinding.locks-keys-matcher.name=", "security.earlybinding.reader-permissions=", "security.earlybinding.user-to-key-mapper.cache-seconds=", "security.earlybinding.user-to-key-mapper=", "service_name=", "spelling.suggestion_lexicon_weight=", "spelling.suggestion_sources=", "spelling.suggestion_threshold=", "spelling_enabled=", "squizapi.target_url=", "start_url=", "store-service.endpoint=", "store-service.port=", "store.push.collection=", "store.push.host=", "store.push.port=", "store.raw-bytes.class=", "store.temp.class=", "store.xml.class=", "tagging.enable_tagging=", "tagging.use_tag_data_in_index=", "text_miner_enabled=", "trim.cleanup_webserverworkpath=", "trim.collect_containers=", "trim.database=", "trim.default_live_links=", "trim.domain=", "trim.extracted_file_types=", "trim.filter_timeout=", "trim.free_space_check_exclude=", "trim.free_space_threshold=", "trim.gather_end_date=", "trim.gather_mode=", "trim.gather_start_date=", "trim.initial_gather=", "trim.license_number=", "trim.limit=", "trim.passwd=", "trim.properties_blacklist=", "trim.push.collection=", "trim.request_delay=", "trim.slice_size=", "trim.slice_sleep=", "trim.stats_dump_interval=", "trim.store_class=", "trim.sub_folders=", "trim.threads=", "trim.timespan.unit=", "trim.timespan=", "trim.user=", "trim.userfields_blacklist=", "trim.verbose=", "trim.web_server_work_path=", "trim.workgroup_port=", "trim.workgroup_server=", "ui.classic.qp_timeout_seconds=", "ui.modern.authentication=", "ui.modern.click_link=", "ui.modern.freemarker.display_errors=", "ui.modern.freemarker.error_format=", "ui.modern.i18n=", "ui.modern.search_link=", "ui.null_query_enabled=", "ui.secure_users=", "ui_cache_disabled=", "ui_cache_link=", "ui_click_link=", "ui_cookie_domain=", "ui_hit_first=", "ui_hit_last=", "ui_hit_next=", "ui_hit_prev=", "ui_search_link=", "ui_type=", "update.restrict_to_host=", "userid_to_log=", "vital_servers=", "warc.compression=", "workflow.publish_hook="]


missing = flags - get_flags(config, default_config)
if missing.empty?
  puts 'No flags missing!'
else
  puts "You are missing the following flags:"
  missing.each { |f| print "\t* #{f}\n" }
end
