helpers do

    def test()
        return "<p>Hello world</p>"
    end

    def display_friend(friend, confirmed=false, requested=false)

        if confirmed
            result = "<div class=\"friend\"><a href='/users/#{friend.name}'>#{friend.full_name}</a></div>"
        else
            if requested
                #delete?
                result = "<div class=\"friend\"><a href='/users/#{friend.name}'>#{friend.full_name}</a> - Requested:<form action='/friends/#{friend.id}/confirm' method='post'><input type='submit' name='delete_button' value='Delete request' /></form></div>"
            else
                #confirm?
                result = "<div class=\"friend\"><a href='/users/#{friend.name}'>#{friend.full_name}</a><form action='/friends/#{friend.id}/confirm' method='post'><input type='submit' name='delete_button' value='Delete request' /><input type='submit' name='confirm_button' value='Confirm friend' /></form></div>"
            end

        end
        return result

    end

    def display_posts(posts)
        result = posts.map do |post|
            user = User.get(post.u_id)
            "<div class='post-li'>
                <div class='post-row user-info'>
                    <img class='post-user-pic' src='/imgs/users/#{user.img}' />
                    <p class='username'>#{user.name}</p>
                </div>
                <div class='post-row post-text'>
                    <a href='/post/#{post.id}'>#{Post.convert_emoji(post.text)}</a>
                </div>
                <div class='post-row'>
                    <p> <a href='/post/#{post.id}/yay'>Yay ( #{post.yays} )</a> | <a href='/post/#{post.id}/nay'>Nay ( #{post.nays} )</a> | Comments ( #{post.comments} ) </p>
                </div>
            </div>"
        end
        if result.length == 0
            return "No posts to display..."
        else
            return result.join("")
        end

    end

    def display_comments(comments, cur_user)
        result = comments.map do |comment|
            "<div class='comment-li'>
                <p><b>#{comment.u_name}:</b> #{Post.convert_emoji(comment.text)} #{'<a href=\'/post/'+ comment.p_id.to_s() +'/comment/' + comment.id.to_s() + '/edit\'>Edit</a>' if comment.u_id.to_i() == cur_user.to_i()} | #{'<a href=\'/post/'+ comment.p_id.to_s() +'/comment/' + comment.id.to_s() + '/delete\'>Delete</a>' if comment.u_id.to_i() == cur_user.to_i()}</p>
            </div>"
        end
        if result.length == 0
            return "No comments to display..."
        else
            return result.join("")
        end

    end

    def display_user_profile(cur_user, othr_user)
        return_text = "<h1>#{othr_user.full_name}'s Profile</h1></br>"
        friends = cur_user.friends?(othr_user.id)
        if friends
            # yay you are friends
            return_text << "<p>Yay, you and #{othr_user.f_name} are friends!</p>"
            return_text << "<form class='friend_button' action='/friends/#{othr_user.id}/confirm' method='post'>"
            return_text << "<input type='submit' name='delete_button' value='Remove friend'/>"
            return_text << "</form>"

        elsif friends.nil?
            # waiting to be confirmed
            return_text << "<p>Your friendship just need's to be confirmed</p>"
        else
            # not friends - do you want to add?
            return_text << "<p>You are not friends, would you like to be?</p>"
            return_text << "<form class='friend_button' action='/friends/#{othr_user.id}/add' method='post'>"
            return_text << "<input type='submit' name='become_friends' value='Send Friend Request'/>"
            return_text << "</form>"
        end

        return_text << "<p>Name: #{othr_user.full_name}</p>"
        return_text << "<p>Username: #{othr_user.name}</p>"
        return_text << "<p>Tagline: #{Post.convert_emoji(othr_user.tagline)}</p>"
        return_text << "</br><p>Posts:</p>"

        if friends
            return_text << display_posts(othr_user.posts)
        else
            return_text << "<p>Sorry you must be friends to view their posts</p>"
        end
        return return_text
    end

    def display_post_paginator(post_num, cur_page)
        return_text = ""

        if (post_num > 10)
            num = (post_num/10.to_f).ceil
            return_text << "<p>"
            return_text << "<a href='?page=#{cur_page-1}'>&lt; Prev</a>" if cur_page-1 >= 0
            return_text << " Page #{cur_page+1} of #{num} "
            return_text << "<a href='?page=#{cur_page+1}'>Next &gt;</a>" if cur_page+1 < num
            return_text << "</p>"
        else
            return_text << "<p>Page 1 of 1</p>"
        end

        return return_text

    end

    def display_conversations(conversations, cur_user, friends)
        return_text = ""

        if conversations.length > 0
            conversations.each do |convo|
                last_message = convo.last_message
                other_user = convo.a_id == cur_user ? User.get(convo.b_id) : User.get(convo.a_id)
                return_text << "<div class='convo-li'>"
                return_text << "    <div class='convo-row'>"
                return_text << "        <a href='/messages/#{convo.a_id == cur_user ? User.get(convo.b_id).name : User.get(convo.a_id).name}'>"
                return_text << "            <p>#{other_user.full_name}</p>"
                return_text << "            <p class='message-head'>#{cur_user == last_message.s_id ? "You:": "#{other_user.f_name}:"} #{Post.convert_emoji(last_message.preview)} #{"( UNREAD )" if last_message.read == "f" && last_message.s_id != cur_user}</p>"
                return_text << "        </a>"
                return_text << "    </div>"
                return_text << "</div>"
            end
        else
            return_text = "<p>No conversations to display, Start one below...</p>"
        end
        return return_text
    end

    def display_messages(messages, user_a, user_b)
        return_text = ""
        user_hash = {user_a.id => user_a.full_name, user_b.id => user_b.full_name}

        if messages.length > 0
            messages.each do |message|

                return_text << "<div class='message'>"
                return_text << "<p><b>#{user_hash[message.s_id]}:</b> #{Post.convert_emoji(message.msg(user_a.id))}</p>"
                return_text << "</div>"

            end
        else
            return_text = "<p>No messages to display for this conversation</p>"
        end
        return return_text
    end

end
