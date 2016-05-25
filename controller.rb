require( 'sinatra' )
require( 'sinatra/contrib/all' )
require('pry-byebug')

require_relative('db/sql')

require_relative('models/comment')
require_relative('models/conversation')
require_relative('models/encrypt')
require_relative('models/message')
require_relative('models/post')
require_relative('models/user')
require_relative('models/yaynay')
require_relative('models/trending')

require_relative('controllers/class_addons')
require_relative('controllers/comment_controller')
require_relative('controllers/conversation_controller')
require_relative('controllers/main_controller')
require_relative('controllers/trending_controller')
require_relative('controllers/post_controller')
require_relative('controllers/friends_controller')
require_relative('controllers/user_controller')
require_relative('controllers/helper_functions')

enable :sessions

get '/' do
    if @user = session[:user]
        @page_num = params[:page] ? params[:page].to_i : 0;
        @posts = Post.friends_only(@user.id, @page_num)
        @post_num = Post.count_friends_only(@user.id, @page_num);
        erb(:'feed/main')
    else
        erb(:home)
    end
end
