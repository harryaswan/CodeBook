get '/users/:id_name/?' do

    if @user = session[:user]
        # TODO: something about users looking at their own profiles
        @viewing = User.get(params[:id_name])
        if @viewing.id != @user.id
            erb(:'users/view')
        else
            redirect '/friends'
        end
    else
        redirect '/login?redirect=users/' + params[:id_name]
    end

end

post '/users/edit/?' do
    if @user = session[:user]
        if params[:old_password]
            if new_user = @user.change_password(params)
                session[:user] = new_user
                redirect '/account?pass=true'
            else
                redirect '/account?pass=false'
            end
        elsif params[:f_name]
            new_user = @user.change_details(params)
            if new_user
                session[:user] = new_user
                redirect '/account?details=true'
            else
                redirect '/account?details=false'
            end
        end
    else
        redirect '/login?redirect=account'
    end
end

delete '/users/delete/?' do
    if @user = session[:user]
        if params[:delete_user]
            @user.delete()
            redirect '/logout'
        end
    else
        redirect '/login?redirect=account'
    end
end
