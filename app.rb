require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'



configure do
  enable :sessions
end

helpers do
  def username
	if session[:identity] == 'admin' && session[:password] == 'secret'
		session[:identity]
	else
		'Hello stranger'
	end
    #session[:identity] ? session[:identity] : 'Hello stranger'
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

post '/visit' do
	@username = params[:username]
	@userphone = params[:userphone]
	@usertime = params[:usertime]
	@color = params[:colorpicker]

	x = ''
	case params[:users_barber]
	when '1'
		x = "; Barber: Walter White"
	when '2'
		x = "; Barber: Jessie Pinkman"
	when '3'
		x = "; Barber: Gus Fring"
	end

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

	f = File.open('./public/users.txt', 'a')
	f.write("User: #{@username}; Tel: #{@userphone}; Time: #{@usertime}; Color: #{@color}" + x +"\n")
	f.close

	erb "Вы записаны на  #{@usertime}"
 end

 get '/contacts' do
	erb :contacts
 end

 post '/contacts' do
	@usermail = params[:usermail]
	@usermessage = params[:usermessage]

	f = File.open('./public/contacts.txt', 'a')
	f.write("Email: #{@usermail}; Message: #{@usermessage}\n")
	f.close

	erb :contacts
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
