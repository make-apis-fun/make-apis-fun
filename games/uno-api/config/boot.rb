ENV['RACK_ENV'] ||= 'development'

root = File.dirname(__FILE__) + '/..'

$LOAD_PATH.unshift(root)

initializers_path = File.join(File.dirname(__FILE__), 'initializers')

initializer_paths = Dir[File.join(initializers_path, '*.rb')]
initializer_paths.each { |file| require file }
