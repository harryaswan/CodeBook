class YayNay

    def self.get_for_post(id)
        sql1 = "SELECT COUNT(*) AS yays FROM post_yays WHERE post_id = #{id};"
        result1 = SQLRun.exec(sql1)
        sql2 = "SELECT COUNT(*) AS nays FROM post_nays WHERE post_id = #{id};"
        result2 = SQLRun.exec(sql2)

        yays = result1[0]['yays'].to_i()
        nays = result2[0]['nays'].to_i()
        
        return [yays, nays]

    end

end
