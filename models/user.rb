class User


    attr_reader(:id, :name, :pass, :f_name, :l_name, :img, :tagline)

    def initialize(options)
        @id = options['id'].to_i()
        @name = options['username']
        @pass = options['password']
        @f_name = options['f_name']
        @l_name = options['l_name']
        @img = options['img_url']
        @tagline = options['tagline']
        @img = 'default.png' if @img.nil? || @img == ""
        @tagline = "Not yet set" if @tagline.nil? || @tagline == ""
    end

    def full_name()
        return "#{@f_name} #{@l_name}"
    end

    def friends()
        sql = "SELECT users.* FROM users JOIN friends ON friends.a_id=users.id OR friends.b_id=users.id WHERE users.id <> #{@id} AND (a_id=#{@id} OR b_id=#{@id});"
        return User.create(sql)
    end

    def friend_requests()
        sql = "SELECT COUNT(*) FROM friends WHERE b_id=#{@id} AND confirmed=false;"
        result = SQLRun.exec(sql)
        return result[0]['count'].to_i()
    end

    def friends?(id)
        if id != @id
            sql = "SELECT confirmed FROM friends WHERE (a_id = #{@id} OR b_id = #{@id}) AND (a_id = #{id} OR b_id = #{id});"
            result = SQLRun.exec(sql)
            if result.ntuples > 0
                if result[0]['confirmed'] == 't'
                    return true
                else
                    return nil
                end
            else
                return false
            end
        else
            return false
        end
    end

    def posts()
        sql = "SELECT * FROM posts WHERE user_id = #{@id};"
        return Post.create(sql)
    end

    def add_friends(id)
        sql = "SELECT add_friend(#{@id}, #{id});"
        SQLRun.exec(sql)
        return nil
    end

    def requested_friendship?(id)
        sql = "SELECT confirmed FROM friends WHERE a_id=#{@id} AND b_id=#{id};"
        result = SQLRun.exec(sql)
        if result.ntuples == 1
            return true
        else
            return false
        end
    end

    def confirm_friends(id, confirmed)
        if confirmed
            sql = "UPDATE friends SET confirmed=true WHERE (a_id = #{@id} OR b_id=#{@id}) AND (a_id = #{id} OR b_id = #{id});"
        else
            sql = "DELETE FROM friends WHERE (a_id = #{@id} OR b_id=#{@id}) AND (a_id = #{id} OR b_id = #{id});"
        end
        result = SQLRun.exec(sql)
        return nil
    end

    def change_password(options)
        if @pass == Encrypt.value(options[:old_password])
            if options[:new_password] == options[:new_password_confirm]
                new_pass = Encrypt.value(options[:new_password])
                sql = "UPDATE users SET password='#{new_pass}' WHERE id = #{@id} RETURNING *;"
                return User.create(sql, false)
            else
                return false
            end
        else
            return false
        end

    end

    def change_details(options)
        sql = "UPDATE users SET"
        if options[:f_name] != @f_name
            sql << " f_name='#{options[:f_name]}',"
        end
        if options[:l_name] != @l_name
            sql << " l_name='#{options[:l_name]}',"
        end
        if options[:tagline] != @tagline
            sql << " tagline='#{options[:tagline]}',"
        end
        if options[:profile_image]
            o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
            random_file_name = (0...10).map { o[rand(o.length)] }.join

            file_name = options[:profile_image][:filename]

            file_ext = file_name[file_name.index('.')..-1]

            File.open('public/imgs/users/' + random_file_name + file_ext, "w") do |f|
                f.write(options[:profile_image][:tempfile].read)
            end
            sql << " img_url='#{random_file_name + file_ext}',"
        end

        sql = sql[0...-1]

        sql << " WHERE id = #{@id} RETURNING *;"
        if sql.length > (41 + "#{@id}".length)
            return User.create(sql, false)
        else
            return false
        end
    end

    def delete()
        sql = "DELETE FROM users WHERE id = #{@id};"
        SQLRun.exec(sql)
        return nil
    end

    def conversations()
        # sql = "SELECT * FROM (SELECT c.* FROM conversations c JOIN messages m ON c_id WHERE (c.a_id=#{@id} OR c.b_id=#{@id}) ORDER BY m.sent DESC) AS stuff GROUP BY id;"
        # sql = "SELECT c.* FROM conversations c JOIN messages m ON c.id = m.c_id WHERE (c.a_id=#{@id} OR c.b_id=#{@id}) GROUP BY c.id ORDER BY m.sent;"
        # sql = "SELECT * FROM conversations WHERE (a_id=#{@id} OR b_id=#{@id}) ORDER BY id DESC;"
        sql = "select * from (select distinct on(c.id) c.*, sent from conversations c left join messages m on (c.id = m.c_id) order by c.id,m.sent desc) as b WHERE (b.a_id=#{@id} OR b.b_id=#{@id}) order by sent desc;"
        return Conversation.create(sql)
    end

    def self.get_fullname(id)
        sql = "SELECT f_name, l_name FROM users WHERE id = #{id};"
        result = SQLRun.exec(sql)
        if result.ntuples > 0
            name = result[0]['f_name']
            name << " "
            name << result[0]['l_name']
            return name
        else
            return nil
        end

    end

    def self.signup(options)
        # puts options
        if !(options[:password] == options[:password_repeated] || options[:username].empty?)
            enc_pass = Encrypt.value(options[:password])
            sql = "INSERT INTO users (username, password, f_name, l_name) VALUES ('#{options[:username].downcase}', '#{enc_pass}', '#{options[:f_name].capitalize}', '#{options[:l_name].capitalize}');"
            SQLRun.exec(sql)
            return User.login(options)
        else
            return nil
        end
    end



    def self.login(options)
        # encrypt password
        enc_pass = Encrypt.value(options[:password])
        # check if username & password present in db
        sql = "SELECT * FROM users WHERE LOWER(username) = '#{options[:username].downcase}' AND password = '#{enc_pass}';"
        # result = SQLRun.exec(sql)
        user = User.create(sql, false)
        if user
            return user
        else
            return nil
        end
        # if result.ntuples > 0
        #     return User.create(result[0], false)
        # else
        #     return nil
        # end
    end

    def self.all()
        sql = "SELECT * FROM users;"
        return User.create(sql)
    end

    def self.get(id_name)
        if id_name.to_i() > 0
            sql = "SELECT * FROM users WHERE id = #{id_name};"
        else
            sql = "SELECT * FROM users WHERE username = '#{id_name}';"
        end
        return User.create(sql, false)
    end

    def self.search(search_qry)
        # binding.pry
        search_qry.downcase!
        if !search_qry.index(" ").nil?
            split_qry = search_qry.split(" ")
            sql = "SELECT * FROM users WHERE LOWER(f_name) LIKE $$%#{split_qry[0]}%$$ OR LOWER(f_name) LIKE $$%#{split_qry[1]}%$$ OR LOWER(l_name) LIKE $$%#{split_qry[0]}%$$ OR LOWER(l_name) LIKE $$%#{split_qry[1]}%$$;"
            return User.create(sql)
        else
            sql = "SELECT * FROM users WHERE LOWER(username) LIKE $$%#{search_qry}%$$ OR LOWER(f_name) LIKE $$%#{search_qry}%$$ OR LOWER(l_name) LIKE $$%#{search_qry}%$$;"
            return User.create(sql)
        end
    end

    def self.create(sql, multi=true)
        result = SQLRun.exec(sql)
        items = result.map {|i| User.new(i)}
        return multi ? items : items.first
    end

end
