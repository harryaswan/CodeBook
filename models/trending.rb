class Trending

    def self.user_with_most_posts
        sql = "SELECT user_id FROM posts GROUP BY user_id ORDER BY COUNT(user_id) DESC LIMIT 1;"
        result = SQLRun.exec(sql)
        return User.get(result[0]['user_id'])
    end

    def self.user_with_most_comments
        sql = "SELECT user_id FROM comments GROUP BY user_id ORDER BY COUNT(user_id) DESC LIMIT 1;"
        result = SQLRun.exec(sql)
        return User.get(result[0]['user_id'])
    end


    def self.post_with_most_comments
        sql = "SELECT post_id FROM comments GROUP BY post_id ORDER BY COUNT(post_id) DESC LIMIT 1;"
        result = SQLRun.exec(sql)
        return Post.find(result[0]['post_id'])
    end

    def self.most_popular_words_in_posts
        sql = "SELECT p_text as text FROM posts;"
        result = SQLRun.exec(sql)
        return Trending.calc_words(result, 5)
    end

    def self.most_popular_words_in_comments
        sql = "SELECT c_text as text FROM comments;"
        result = SQLRun.exec(sql)
        return Trending.calc_words(result, 5)
    end

    def self.calc_words(sql_result, number_of_top_words)
        words = Hash.new(0)
        sql_result.each do |result_words|
            tmp = result_words['text'].split(" ")
            tmp.each {|lone_word| words[lone_word.downcase] += 1}
        end
        return words.sort_by {|a,b| b}.reverse[0...number_of_top_words]
    end



end
