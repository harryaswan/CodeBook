get '/friends/?' do

    if @user = session[:user]
        @friends = @user.friends
        @users = User.all()
        @friends.each {|f| @users.delete_friend(f)}
        erb(:'friends/index')
    else
        redirect '/login?redirect=friends'
    end

end

post '/friends/?' do
    if @user = session[:user]

        params[:user]

        erb(:'friends/index')
    else
        redirect '/login?redirect=friends'
    end
end

post '/friends/:id/add/?' do
    if @user = session[:user]
        @user.add_friends(params[:id].to_i())
        redirect '/users/' + params[:id]
    else
        redirect '/login?redirect=friends' + params[:id]
    end

end

post '/friends/:id/confirm/?' do
    if @user = session[:user]
        if params[:confirm_button]
            @user.confirm_friends(params[:id].to_i(), true)
            redirect '/users/' + params[:id]
        elsif params[:delete_button]
            @user.confirm_friends(params[:id].to_i(), false)
            redirect '/friends'
        end
    else
        redirect '/login?redirect=friends' + params[:id]
    end
end
