module ApplicationHelper

    def link_to_external_url(options={})
        #logger.debug "Options: #{options[:value]}"
        link_to("#{options[:value].first()}", "#{options[:value].first()}") 
    end
end
