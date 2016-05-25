get '/messages' do

    if @user = session[:user]
        @conversations = @user.conversations()
        @friends = @user.friends;
        erb(:'conversations/index')
    else
        redirect '/login?redirect=messages'
    end

end

get '/messages/:id_name/?' do
    if @user = session[:user]
        if @other_user = User.get(params[:id_name])
            if @convo = Conversation.check(@user.id, @other_user.id)
                erb(:'conversations/view')
            else
                redirect '/messages'
            end
        else
            redirect '/messages'
        end
    else
        redirect '/login?redirect=messages/' + params[:id_name].to_s()
    end
end

post '/messages/:id_name/new' do
    if @user = session[:user]
        if @other_user = User.get(params[:id_name])
            if @convo = Conversation.check(@user.id, @other_user.id)
                @convo.new_msg(@user.id, params[:new_message])
                redirect '/messages/' + params[:id_name]
            else
                redirect '/messages'
            end
        else
            redirect '/messages'
        end
    else
        redirect '/login?redirect=messages/' + params[:id_name].to_s()
    end
end

post '/conversation/new' do

    if @user = session[:user]
        @conversation = Conversation.new({'a_id'=>@user.id, 'b_id'=>params[:u_id]}, true).save()
        if @conversation
            @conversation.new_msg(@user.id, params[:new_message])
        else
            redirect '/messages'
        end
        #@message = Message.new('s_id'=>@user.id, 'c_id'=>@conversation.id, 'msg'=>params[:new_message]).save()
        redirect '/messages/' + @conversation.id.to_s()
    else
        redirect '/login?redirect=messages'
    end

end
