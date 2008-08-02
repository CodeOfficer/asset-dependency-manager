# AssetManager
# you prefer to have your js plugins as seperate files
# your js and css files all have corresponding extensions

# Notes

# hash of ...
# symbol to string
# symbol to array of string
# symbol to hash of array or string
# symbol to symbol (recursive)
# ... must include suffix, ALWAYS

module CodeOfficer 
  module AssetManager
    
    module Controller
      def initialize
        @required_javascripts ||= []
        @required_stylesheets ||= []
      end
    end
    
    module Helpers
      def add_asset_requirement(*syms)
        syms.each do |sym|
          match = asset_dependency_for(sym)
          logger.fatal { " |||||| #{match.class}" }
          case match
            when Array
              match.each { |x| add_asset_requirement_by_type(x) }
            when Hash
              match[:js].each { |x| add_asset_requirement_by_type(x) }
              match[:css].each { |x| add_asset_requirement_by_type(x) }
            when String
              add_asset_requirement_by_type(match)
            when Symbol
              add_asset_requirement(match)
          end
        end
      end
      alias_method :asset, :add_asset_requirement
      
      def asset_dependency_for(sym)
        # TODO: add memoization later?
        other_dependencies = respond_to?(:asset_dependencies) ? asset_dependencies : {}
        {
          :defaults => true
        }.merge(other_dependencies)[sym.to_sym] # || []
      end
      
      private
      
      def add_asset_requirement_by_type(asset)
        if asset.downcase =~ /js$/ then
           @required_javascripts << asset unless @required_javascripts.include?(asset)
        elsif asset.downcase =~ /css$/ then
           @required_stylesheets << asset unless @required_stylesheets.include?(asset)
        end
      end
    end
    
    module View
      # FIXME: helpers to output the controllers hash keys for js and css
      def asset_manager_tags
        logger.fatal { "JAVASCRIPTS! #{@required_javascripts.inspect}" }
        logger.fatal { "STYLESHEETS! #{@required_stylesheets.inspect}" }
        js = (@required_javascripts || []).collect { |js| javascript_include_tag("#{js}") }.join("\n")
        css = (@required_stylesheets || []).collect { |css| stylesheet_link_tag("#{css}") }.join("\n")
        content_tag :pre, h(js +"\n"+ css)
      end
    end

  end 
end