require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

configure do
	db = get_db
	db.execute 'create table if not exists "Users"
	(
		"Id" integer primary key autoincrement,
		"Name" text,
		"Phone" text,
		"DateStamp" text,
		"Barber" text,
		"Color" text
		)'

		db.execute 'create table if not exists "Contacts"
	(
		"Id" integer primary key autoincrement,
		"Email" text,
		"Message" text
		)'

  enable :sessions
end

helpers do
  def username
	if session[:identity] == 'admin' && session[:password] == 'secret'
		session[:identity]
	else
		'Hello stranger'
	end
  end
end

before '/secure/*' do
  unless session[:identity] == 'admin' && session[:password] == 'secret'
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/login/form' do
  erb :login_form
end

get '/about' do
	erb :about
 end

 get '/visit' do
	erb :visit
 end

 get '/showusers' do
	erb ':showusers'
 end

post '/visit' do
	@username = params[:username]
	@userphone = params[:userphone]
	@usertime = params[:usertime]
	@color = params[:colorpicker]
	@barber = params[:users_barber]
	
	hash = {
		username: 'Введите имя',
		userphone: 'Введите телефон',
		usertime: 'Выберите время',
	}

	hash.each do |k, v|
		if params[k] == ''
			@error = hash[k]
			return erb :visit
		end
	end

	db = get_db

	db.execute 'insert into Users (Name, Phone, DateStamp, Barber, color) values (?,?,?,?,?)', [@username, @userphone, @usertime, @barber, @color]
	
	db.close


	f = File.open('./public/users.txt', 'a')
	f.write("User: #{@username}; Tel: #{@userphone}; Time: #{@usertime}; Color: #{@color}; Barber: #{@barber}\n")
	f.close

	erb "Вы записаны на  #{@usertime}"
 end

 get '/contacts' do
	erb :contacts
 end

 post '/contacts' do
	@usermessage = params[:usermessage]
	@usermail = params[:usermail]


	hash = {
		usermail: 'Введите адрес электронной почты',
		usermessage: 'Введите сообщение',
	}

	hash.each do |k, v|
		if params[k] == ''
			@error = hash[k]
			return erb :contacts
		end
	end

	f = File.open('./public/contacts.txt', 'a')
	f.write("Email: #{@usermail}; Message: #{@usermessage}\n")
	f.close

	db = get_db

	db.execute 'insert into Contacts (Email, Message) values (?,?)', [@usermail, @usermessage]
	
	db.close

	erb 'Ваше сообщение отправлено'
 end

post '/login/attempt' do
  session[:identity] = params['username']
  session[:password] = params['userpass']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

def get_db
	db = SQLite3::Database.new 'base.sqlite'
	db.results_as_hash = true
	return db
end