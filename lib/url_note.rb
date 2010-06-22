require 'rubygems'
require 'active_record'

class UrlNote < ActiveRecord::Base
  def self.create_db
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
end

if __FILE__ == $0
  UrlNote.create_db
end
