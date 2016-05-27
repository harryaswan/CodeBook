require('pg')
class SQLRun

    def self.exec(sql)
        begin
            # db = PG.connect({ dbname: 'codebook', host: 'localhost' })
            db = PG.connect( {dbname: 'd2ipapqomj5dq5', host: 'ec2-54-243-201-116.compute-1.amazonaws.com', port: 5432, user: 'gmwruaareztcpe', password: 'mAR_K_AuMf62uge-Kr43vgUyQw'})
            result = db.exec(sql)
        ensure
            db.close

        rescue NoMethodError
        end
        return result
    end

end
