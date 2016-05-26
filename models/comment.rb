class Comment

    attr_reader(:id, :u_id, :u_name, :p_id, :commented, :text)

    def initialize(options)
        @id = options['id']
        @u_id = options['user_id']
        @u_name = User.get_fullname(@u_id)
        @p_id = options['post_id']
        @commented = options['commented']
        @text = options['c_text']
    end

    def save()
        if @text != "" && @text != " "
            sql = "INSERT INTO comments (user_id, post_id, c_text) VALUES (#{@u_id}, #{@p_id}, $$#{@text}$$) RETURNING *;"
            return Comment.create(sql, false)
        end
    end

    def edit(new_text)

        if @text != new_text
            sql = "UPDATE comments SET c_text=$$#{new_text}$$ WHERE id = #{@id} RETURNING *"
            return Comment.create(sql, false)
        else
            return self
        end

    end

    def delete()
        sql = "DELETE FROM comments where id=#{@id};"
        SQLRun.exec(sql)
        return nil
    end

    def self.find(id)
        sql = "SELECT * FROM comments WHERE id = #{id};"
        return Comment.create(sql, false)
    end

    def self.get_for_post(id)
        sql = "SELECT * FROM comments WHERE post_id = #{id} ORDER BY commented DESC;"
        return Comment.create(sql)
    end

    def self.count_for_post(id)
        sql = "SELECT COUNT(*) FROM comments WHERE post_id = #{id};"
        result = SQLRun.exec(sql)
        return result[0]['count'].to_i()
    end

    def self.create(sql, multi=true)
        result = SQLRun.exec(sql)
        items = result.map {|i| Comment.new(i)}
        return multi ? items : items.first
    end

end
