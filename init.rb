# Include hook code here

require 'asset_manager'

ActionController::Base.send :include, CodeOfficer::AssetManager::Controller

ActionController::Base.send :helper, CodeOfficer::AssetManager::Helpers

ActionView::Base.send :include, CodeOfficer::AssetManager::View
