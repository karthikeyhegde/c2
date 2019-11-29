# This file is used by Rack-based servers to start the application.
require "webrick/https"
require ::File.expand_path('../config/environment',  __FILE__)
run Cement::Application


