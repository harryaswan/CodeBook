class Post

    attr_reader(:id, :u_id, :u_name, :text, :yays, :nays, :comments)
    def initialize(options)
        @id = options['id'].to_i()
        @u_id = options['user_id'].to_i()
        @u_name = User.get_fullname(@u_id)
        @text = options['p_text']
        @yays, @nays = YayNay.get_for_post(@id)
        @comments = Comment.count_for_post(@id)
    end

    def save()
        sql = "INSERT INTO posts (user_id, p_text) VALUES ('#{@u_id}', $$#{@text}$$) RETURNING *;"
        return Post.create(sql, false)
    end

    def delete()
        sql = "DELETE FROM posts where id=#{@id};"
        SQLRun.exec(sql)
        return nil
    end

    def edit(new_text)

        if @text != new_text
            sql = "UPDATE posts SET p_text=$$#{new_text}$$ WHERE id = #{@id} RETURNING *"
            return Post.create(sql, false)
        else
            return self
        end

    end


    def yay(id)
        #sql = "DO $do$ BEGIN DELETE FROM post_yays WHERE post_id = #{@id} AND user_id = #{id}; IF NOT FOUND THEN INSERT INTO post_yays (post_id, user_id) VALUES (#{@id}, #{id}); END IF; END $do$"
        sql = "SELECT yay(#{@id}, #{id});"
        SQLRun.exec(sql)
        return nil
    end


    def nay(id)
        #sql = "DO $do$ BEGIN DELETE FROM post_nays WHERE post_id = #{@id} AND user_id = #{id}; IF NOT FOUND THEN INSERT INTO post_nays (post_id, user_id) VALUES (#{@id}, #{id}); END IF; END $do$"
        sql = "SELECT nay(#{@id}, #{id});"
        SQLRun.exec(sql)
        return nil
    end

    def self.find(id)
        sql = "SELECT * FROM posts WHERE id = #{id};"
        return Post.create(sql, false)
    end

    def self.create(sql, multi=true)
        result = SQLRun.exec(sql)
        items = result.map {|i| Post.new(i)}
        return multi ? items : items.first
    end

    def self.all(page=0)
        sql = "SELECT * FROM posts;"
        return Post.create(sql)
    end

    def self.friends_only(id, page=0)
        sql = "SELECT my.* FROM posts my WHERE my.user_id = #{id} UNION (SELECT p.* FROM posts p JOIN friends f ON (p.user_id = f.a_id OR p.user_id = f.b_id) WHERE ((f.a_id = #{id} OR f.b_id = #{id}) AND f.confirmed=true) OR p.user_id=#{id}) ORDER BY posted DESC LIMIT 10 OFFSET #{10*page};"
        return Post.create(sql)
    end

    def self.count_friends_only(id, page=0)
        sql = "SELECT COUNT(my.*) FROM posts my WHERE my.user_id = #{id} UNION (SELECT COUNT(*) FROM (SELECT DISTINCT p.* FROM posts p JOIN friends f ON (p.user_id = f.a_id OR p.user_id = f.b_id) WHERE ((f.a_id = #{id} OR f.b_id = #{id}) AND f.confirmed=true)) AS temp);"
        # sql = "SELECT COUNT(*) FROM posts p JOIN friends f ON (p.user_id = f.a_id OR p.user_id = f.b_id) WHERE ((f.a_id = #{id} OR f.b_id = #{id}) AND f.confirmed=true) OR p.user_id=#{id};"
        result = SQLRun.exec(sql)
        if result.ntuples > 1
            return result[1]['count'].to_i()
        else
            return result[0]['count'].to_i()
        end
        return 0
    end

    def self.feed(id)
        # oin friends table to posts table on a_id equals user id OR b_id equals user id WHERE posts.user_id <> to the current user id
        sql = "SELECT p.* FROM posts p JOIN friends f ON f.user_id=p.a_id OR f.user_id=p.b_id WHERE p.user_id <> #{id};"
        return Post.create(sql)
    end

    def self.convert_emoji(text)

        replacements = [
            [":)", "&#x1f642;"],
            [":D", "&#x1f603;"],
            [":(", "&#x2639;"],
            [";)", "&#x1f609;"],
            [":*", "&#x1f618;"],
            [":P", "&#x1f61b;"],
            [":')", "&#x1f602;"],
            [":'(", "&#x1f62d;"],
            [":geek:", "&#x1f913;"],
            ["(:", "&#x1f643;"],
            [":poop:", "&#x1f4a9;"],
            [":see:", "&#x1f648;"],
            [":hear:", "&#x1f649;"],
            [":speak:", "&#x1f64a;"],
            [":+1:", "&#x1f44d;"],
            [":ok:", "&#x1f44c;"]
        ]

        return replacements.inject(text) {|str, (k,v)| str.gsub(k,v)}

    end

end
