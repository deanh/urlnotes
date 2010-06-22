require 'rubygems'
require 'active_record'

class UrlNote < ActiveRecord::Base; end

if __FILE__ == $0
  ActiveRecord::Base.logger = Logger.new(STDERR)
  ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database  => "../db/notes.db"
  )

  ActiveRecord::Schema.define do
    create_table :url_notes do |table|
      table.column :url, :string
      table.column :text, :text
    end
  end
end
