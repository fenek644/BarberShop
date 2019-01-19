require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'

configure do
  db = SQLite3::Database.new 'barbershop.sql'

  db.execute 'CREATE TABLE IF NOT EXISTS
     `Users`
     (
        "id" INTEGER PRIMARY KEY AUTOINCREMENT,
        "name" TEXT,
        "phone" text,
        "datestamp" text,
        "master" text,
        "color" text
     )'

end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/visit_mess' do
	erb :visit_mess
end

get '/about' do
  # @error = "something wrong!!!"
	erb :about
end

get '/visit' do
	erb :visit
  end

get '/contacts' do
	erb :contacts
end

get '/contacts_mess' do
  erb :contacts_mess
end

get '/showusers' do
  erb "Hello World"
end


post '/visit' do
  @user_name = params[:username]
  @phone = params[:phone]
  @date_time = params[:date_time]

  @master = params[:master]
  @color = params[:colorpicker]

  hh = {
      :username => "Введите имя",
      :phone => "Введите номер телефона",
      :date_time => "Введите дату и время посещения"
  }

  @error = hh.select {|key, | params[key] == ""}.values.join(", ")

  if @error != ""
    return  erb :visit
  else
    @error = NIL
  end


  db = get_db
  db.execute 'insert into Users
     (
        name,
        phone,
        datestamp,
        master,
        color
        )
      values
      (
        ?, ?, ?, ?, ?
      )', [@user_name, @phone, @date_time, @master, @color]




  f = File.open './public/user.txt', 'a'
  f.puts "User: #{@user_name}, Phone: #{@phone}, Date and Time: #{@date_time} . Ваш мастер - #{@master}. "
  f.close


  erb :visit_mess
  # erb "OK #{@user_name}; вы записаны на #{@date_time}; ваш мастер #{@master}; выбранный цвет #{@color}"
end


def get_db

  db = SQLite3::Database.new 'barbershop.sql'
  db.results_as_hash = true
  return  db
end


post '/contacts' do
  @email = params[:email]
  @message = params[:message]


    hh = {
        :email => "Введите адрес электронной почты",
        :message => "Ваше сообщение пусто - введите текст сообщения",
    }

    @error = hh.select {|key, | params[key] == ""}.values.join(", ")

    if @error != ""
      return  erb :contacts
    else
      @error = NIL
    end


  f = File.open './public/contacts.txt', 'a'
  f.puts "email: #{@email}, Сообщение: #{@message}. "
  f.close


  #  отправляем письмо администратору(диспечеру) по сообщениям

  Pony.mail({
                :subject => "Обращение с сайта парикмахерской!", # задаем тему письма
                :body => "Клиент с адресом - #{@email} прислал следующее сообщение - \"#{@message}\"",  # задаем содержимое письма, его тело
                :to => "email администратора обращений", # кому отправить письмо
                :from => "специальный (рабочий) email сайта", # наш обратный адрес, от кого письмо



                # Ниже идут опции класса Pony для почтового ящика на Mail.ru
                # подробнее об опциях Pony см. документацию https://github.com/benprew/pony

                # :via => :smtp,
                # :via_options => {
                #     :address => 'smtp.mail.ru', # это хост, сервер отправки почты
                #     :port => '465', # порт
                #     :tls => true,   # если сервер работает в режиме TLS
                #     :user_name => my_mail, # используем наш адрес почты как логин
                #     :password => password, # задаем введенный в консоли пароль
                #     :authentication => :plain  # "обычный" тип авторизации по паролю
                # }

                # Это опции класса Pony для почтового ящика Gmail.com
                #
                :via => :smtp,
                    :via_options => {
                    :address => 'smtp.gmail.com',
                    :port => '587',
                    :enable_starttls_auto => true,
                    :user_name => "специальный (рабочий) email сайта", # используем наш адрес почты как логин
                    :password => "паспорт рабочего email-а сайта" ,# задаем введенный в консоли пароль
                    :authentication => :plain,
                }



                # Это опции класса Pony для почтового ящика на Яндексе
                #
                # :via => :smtp,
                # :via_options => {
                #     :address => 'smtp.yandex.ru',
                #     :port => '465',
                #     :enable_starttls_auto => true,
                #     :tls => true,
                #     :user_name => my_mail, # используем наш адрес почты как логин
                #     :password => password, # задаем введенный в консоли пароль
                #     :authentication => :plain,
                # }


                # о том какие опции нужно задавать для вашего почтового ящика,
                # если это не мэйл и не gmail - см. документацию вашего почтового провайдера
                # или не поленитесь и заведите тестовый ящик на мэйл.ру или gmail, ради такого дела :)
                })
  #  отправляем автоматический ответ обратившемуся на сайт парикмахерской.

  Pony.mail({
                :subject => "Авто ответ на обращение с сайта парикмахерской!", # задаем тему письма
                :body => "Здравствуйте уважаемый обладатель адреса  #{@email}! Это парикмахерская, мы получили ваше обращение.
В ближайшее время - ответим.",  # задаем содержимое письма, его тело
                :to => @email, # кому отправить письмо
                :from => "специальный (рабочий) email сайта", # наш обратный адрес, от кого письмо




                :via => :smtp,
                :via_options => {
                    :address => 'smtp.gmail.com',
                    :port => '587',
                    :enable_starttls_auto => true,
                    :user_name => "специальный (рабочий) email сайта", # используем наш адрес почты как логин
                    :password => "паспорт рабочего email-а сайта", # задаем введенный в консоли пароль
                    :authentication => :plain,
                }
            })


  erb :contacts_mess

  # erb "Спасибо за обращение, в ближайшее время вам ответят"
  # erb :contacts
end


