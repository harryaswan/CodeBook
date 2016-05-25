post '/post/:post_id/comment/add' do

    if @user = session[:user]
        @post = Post.find(params[:post_id])
        if @user.friends().find {|f| f.id == @post.u_id } || @user.id.to_i() == @post.u_id.to_i()
            comment = Comment.new({'user_id'=>@user.id, 'post_id'=>@post.id, 'c_text'=>params[:c_text]}).save()
            redirect '/post/' + params[:post_id].to_s()
        else
            redirect '/'
        end
    else
        redirect '/login?redirect=/post/'+params[:id]
    end

end

post '/post/:post_id/comment/:comment_id' do

    if @user = session[:user]
        @post = Post.find(params[:post_id])
        if @user.friends().find {|f| f.id == @post.u_id } || @user.id.to_i() == @post.u_id.to_i()
            comment = Comment.find(params[:comment_id]).edit(params[:c_text])
            redirect '/post/' + params[:post_id].to_s()
        else
            redirect '/'
        end
    else
        redirect '/login?redirect=/post/'+params[:id]
    end

end

get '/post/:post_id/comment/:comment_id/edit' do
    if @user = session[:user]
        @comment = Comment.find(params[:comment_id])
        if @comment.u_id.to_i() == @user.id.to_i()
            erb(:'comments/edit')
        else
            redirect '/post/' + params[:post_id]
        end
    else
        redirect '/login?redirect=post/' + params[:post_id]
    end
end

get '/post/:post_id/comment/:comment_id/delete' do
    if @user = session[:user]
        @comment = Comment.find(params[:comment_id])
        if @comment.u_id.to_i() == @user.id.to_i()
            @comment.delete()
        end
    end
    redirect '/post/' + params[:post_id]
end
