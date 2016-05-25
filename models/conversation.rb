class Conversation

    attr_reader(:id, :a_id, :b_id, :last_message)

    def initialize(options, create=false)
        @id = options['id'].to_i()
        @a_id = options['a_id'].to_i()
        @b_id = options['b_id'].to_i()
        @last_message = create ? nil : Message.last_message_in_convo(@id)
    end

    def save()
        if @a_id != @b_id
            sql = "select * from create_convo(#{@a_id}, #{@b_id})"
            return Conversation.create(sql, false)
        else
            return nil
        end
    end

    def messages()
        return Message.in_convo(@id)
    end

    def find(id)
        sql = "SELECT * FROM conversations WHERE id = #{id};"
        return Conversation.create(sql, false)
    end

    def self.count_unread_msgs(user_id)
        sql = "select count(*) from conversations c JOIN messages m ON m.c_id = c.id where (c.a_id = #{user_id} or c.b_id = #{user_id}) and m.s_id <> #{user_id} and m.read=false;"
        result = SQLRun.exec(sql)
        return result[0]['count'].to_i()
    end

    def new_msg(user_id, msg)
        Message.new('s_id'=>user_id, 'c_id'=>@id, 'msg'=>msg).save()
    end

    def self.check(a_id, b_id)
        sql = "SELECT * FROM conversations WHERE (a_id=#{a_id} OR a_id=#{b_id}) AND (b_id=#{a_id} OR b_id=#{b_id});"
        return Conversation.create(sql, false)
    end

    def self.create(sql, multi=true)
        result = SQLRun.exec(sql)
        items = result.map {|i| Conversation.new(i)}
        return multi ? items : items.first
    end

end
