require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

set :port, 3000
disable :show_exceptions

$db = SQLite3::Database.new('checker.db')

$db.execute <<-SQL
  create table if not exists tokens (
    value varchar(255)
  );
SQL

helpers do
  def token_present?(token)
    $db.execute('select count(*) from tokens where value = ? limit 1', token).first.first == 1
  end

  def store_token(token)
    $db.execute('insert into tokens values (?)', token)
  end

  def remove_token(token)
    $db.execute('delete from tokens where value = ?', token)
  end
end

post '/' do
  token = params['token']
  if token
    if token_present?(token)
      status 200
    else
      store_token(token)
      status 201
    end
  else
    status 400
  end
end

get '/:token' do |token|
  if token_present?(token)
    status 200
  else
    status 404
  end
end

delete '/:token' do |token|
  if token_present?(token)
    remove_token(token)
    status 204
  else
    status 404
  end
end
