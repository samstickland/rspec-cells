module RSpec
  module Cells
    module ExampleGroup
      extend ActiveSupport::Concern

      include RSpec::Rails::RailsExampleGroup
      include Cell::Testing
      include ActionController::UrlFor

      attr_reader :controller, :routes

      def method_missing(method, *args, &block)
        # Send the route helpers to the application router.
        if @routes && @routes.named_routes.helpers.include?(method)
          @controller.send(method, *args, &block)
        else
          super
        end
      end

      included do
        metadata[:type] = :cell
        before do # called before every it.
          @routes = ::Rails.application.routes
          ActionController::Base.allow_forgery_protection = false
        end

        # we always render views in rspec-cells, so turn it on.
        subject { controller }
      end
    end
  end
end

RSpec.configure do |c|
  c.include RSpec::Cells::ExampleGroup, :file_path => /spec\/cells/
  c.include RSpec::Cells::ExampleGroup, :type => :cell
end
