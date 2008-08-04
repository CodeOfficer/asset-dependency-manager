# expects to find a method called 'asset_dependencies' in your app helper file
# that returns a hash of :keys representing your :js dependencies
# 
#   {
#     :one_script =>  'one_script.js',  
#     :tabs =>        ['tabs.js', 'tabs.css'],
#     :slider =>      { :js => ['slider/slider_one.js', 'slider/slider_two.js'], :css => 'slider/slider.css' },
#     :testing =>     'whatever.js',
#     :whatever =>    :one_script
#   }

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
          case match
            when Array
              match.each { |x| add_asset_requirement_by_type(x) }
            when Hash
              match[:js].each { |x| add_asset_requirement_by_type(x) } unless match[:js].blank? 
              match[:css].each { |x| add_asset_requirement_by_type(x) } unless match[:css].blank?
            when String
              add_asset_requirement_by_type(match)
            when Symbol
              add_asset_requirement(match)
          end
        end
      end
      alias_method :assets_for, :add_asset_requirement
      
      private
      
      def asset_dependency_for(sym)
        # TODO: add memoization later?
        # TODO: provide integration with rails own defaults
        other_dependencies = respond_to?(:asset_dependencies) ? asset_dependencies : {}
        {
          :defaults => true
        }.merge(other_dependencies)[sym.to_sym] # || []
      end
      
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
        js = (@required_javascripts || []).collect { |js| javascript_include_tag("#{js}") }.join("\n")
        css = (@required_stylesheets || []).collect { |css| stylesheet_link_tag("#{css}") }.join("\n")
        js +"\n"+ css
      end
    end

  end 
end