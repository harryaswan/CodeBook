
post '/post/new/?' do
    if @user = session[:user]
        post = Post.new({'user_id'=>@user.id, 'p_text'=>params[:post_text]}).save()
        redirect '/post/' + post.id.to_s()
    else
        redirect '/'
    end
end

get '/post/:id/?' do
    if @user = session[:user]
        @post = Post.find(params[:id])
        if @user.friends().find {|f| f.id == @post.u_id } || @user.id.to_i() == @post.u_id.to_i()
            @comments = Comment.get_for_post(@post.id)
            erb(:'posts/view')
        else
            redirect '/'
        end
    else
        redirect '/login?redirect=post/' + params[:id]
    end
end

get '/post/:id/yay' do
    if @user = session[:user]
        @post = Post.find(params[:id])
        if @user.friends().find {|f| f.id == @post.u_id } || @user.id.to_i() == @post.u_id.to_i()
            @post.yay(@user.id)
            # redirect '/post/' + params[:id]
            redirect back
        else
            redirect '/'
        end
    else
        redirect '/login?redirect=post/' + params[:id]
    end
end

get '/post/:id/nay' do
    if @user = session[:user]
        @post = Post.find(params[:id])
        if @user.friends().find {|f| f.id == @post.u_id } || @user.id.to_i() == @post.u_id.to_i()
            @post.nay(@user.id)
            # redirect '/post/' + params[:id]
            redirect back
        else
            redirect '/'
        end
    else
        redirect '/login?redirect=post/' + params[:id]
    end
end

post '/post/:id/?' do
    if @user = session[:user]
        @post = Post.find(params[:id]).edit(params[:p_text])
        redirect '/post/' + params[:id]
    else
        redirect '/post/' + params[:id]
    end
end

get '/post/:id/edit' do
    if @user = session[:user]
        @post = Post.find(params[:id])
        if @post.u_id.to_i() == @user.id.to_i()
            erb(:'posts/edit')
        else
            redirect '/post/' + params[:id]
        end
    end
end

get '/post/:id/delete' do
    if @user = session[:user]
        @post = Post.find(params[:id])
        if @post.u_id.to_i() == @user.id.to_i()
            @post.delete()
        end
    end
    redirect '/'
end
