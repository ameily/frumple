Redmine::Plugin.register :frumple do
  name 'Frumple Stock Index'
  author 'Adam Meily'
  description "Provides a method of rating a project and user value in a stock market esque environment"
  version '0.01'
  url 'https://github.com/ameily/frumple'
  author_url 'https://github.com/ameily'
  
  settings :default => {
      
  }, :partial => 'settings/frumple_settings'
end

Project.class_eval do
  has_one :market
end

User.class_eval do
    has_one :stock
end

