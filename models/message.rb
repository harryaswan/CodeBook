class Message

    attr_reader(:id, :s_id, :c_id, :read)

    def initialize(options)
        @id = options['id'].to_i()
        @s_id = options['s_id'].to_i()
        @c_id = options['c_id'].to_i()
        @msg = options['msg']
        @read = options['read']
    end

    def msg(user_id)
        if @read == "f" && @s_id != user_id
            sql = "UPDATE messages SET read=true WHERE id=#{@id};"
            SQLRun.exec(sql)
        end
        return @msg;
    end

    def preview()
        if @msg.length > 25
            return @msg[0..24] + "..."
        else
            return @msg
        end
    end
    def save()
        sql = "INSERT INTO messages (s_id, c_id, msg) VALUES (#{@s_id}, #{@c_id}, $$#{@msg}$$);"
        return Message.create(sql, false)
    end

    def self.last_message_in_convo(id)
        sql = "SELECT * FROM messages WHERE c_id = #{id} ORDER BY sent DESC LIMIT 1;"
        return Message.create(sql, false)
    end

    def self.in_convo(id)
        sql = "SELECT * FROM messages WHERE c_id = #{id} ORDER BY sent ASC;"
        return Message.create(sql)
    end

    def self.create(sql, multi=true)
        result = SQLRun.exec(sql)
        items = result.map {|i| Message.new(i)}
        return multi ? items : items.first
    end

end
