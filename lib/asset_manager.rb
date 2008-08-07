# expects to find a method called 'asset_dependencies' in your app helper file
# that returns a hash of :keys representing your :js and :css dependencies
# :keys can point to an Array or String
# 
# {
# :defaults =>      'application.js',
# :core_scripts =>  [ 'one_script.js', 'two_script.js', :defaults, 'one_style.css' ],
# :tabs =>          [ :core_scripts, 'tabs.js', 'tabs.css' ],
# :slider =>        [ 'slider/slider_one.js', 
#                     'slider/slider_two.js',
#                     'slider/slider.css' ],
# :testing =>       'whatever.js',
# :whatever =>      [ :defaults, :tabs ]
# }

module CodeOfficer 
  module AssetManager
    
    module Controller
      def initialize
        @required_javascripts ||= []
        @required_stylesheets ||= []
      end
    end
    
    module Helpers
      def add_asset_requirement(*args)
        args.each do |arg|
          case arg
            when Array
              arg.each { |x| add_asset_requirement(x) unless x.blank? }
            when Symbol
              add_asset_requirement(asset_dependency_for(arg)) 
            when String
              add_asset_requirement_by_type(arg)
          end
        end
      end
      alias_method :assets_for, :add_asset_requirement
      
      private
      
      def asset_dependency_for(sym)
        unless @required_asset_dependencies.is_a? Hash
          @required_asset_dependencies = respond_to?(:asset_dependencies) ? asset_dependencies : {}
          if @required_asset_dependencies.has_key? :defaults
            rails_defaults = ActionView::Helpers::AssetTagHelper::JAVASCRIPT_DEFAULT_SOURCES
            rails_defaults.collect! {|x| (x=~/js$/i) ? x : "#{x}.js" }
            @required_asset_dependencies.merge!({:defaults => rails_defaults})
          end
        end
        @required_asset_dependencies[sym.to_sym]
      end
      
      def add_asset_requirement_by_type(asset)
        if asset =~ /js$/i then
           @required_javascripts << asset unless @required_javascripts.include?(asset)
        elsif asset =~ /css$/i then
           @required_stylesheets << asset unless @required_stylesheets.include?(asset)
         else
        end
      end
    end
    
    module View
      # FIXME: helpers to output the controllers hash keys for js and css
      def asset_dependency_manager_tags
        js = (@required_javascripts || []).sort.collect { |js| javascript_include_tag("#{js}") }.join("\n")
        css = (@required_stylesheets || []).sort.collect { |css| stylesheet_link_tag("#{css}") }.join("\n")
        js +"\n"+ css
      end
    end

  end 
end