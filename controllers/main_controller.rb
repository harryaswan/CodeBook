get '/signup/?' do
    if session[:user]
        redirect '/'
    else
        erb(:'login/signup')
    end
end

post '/signup/?' do
    @user = User.signup(params)
    if @user
        session[:user] = @user
        redirect '/'
    else
        redirect '/signup?error=true'
    end
end

get '/login/?' do
    if session[:user]
        redirect '/'
    else
        @username = params[:user] if params[:user]
        @redirect = params[:redirect] ? params[:redirect] : nil
        erb(:'login/login')
    end
end

post '/login/?' do
    @user = User.login(params)
    if @user
        session[:user] = @user
        url = '/'
        url << params[:redirect] if params[:redirect]
        redirect url
    else
        redirect '/login?user=' + params[:username]
    end
end

get '/logout/?' do
    session[:user] = nil
    redirect '/'
end

get '/account/?' do
    if @user = session[:user]
        @details = params[:details]
        @pass = params[:pass]
        erb(:'users/edit')
    else
        redirect '/login?redirect=account'
    end
end
