require('pg')
class SQLRun

    def self.exec(sql)
        begin
            # db = PG.connect({ dbname: 'codebook', host: 'localhost' })
            db = PG.connect( {dbname: 'dbifvpla7mc8n1', host: 'ec2-54-228-189-127.eu-west-1.compute.amazonaws.com', port: 5432, user: 'tblvokekcplfws', password: 'O9bs5kJ9gT3Hrf8eMd-a9H3XSd'})
            result = db.exec(sql)
        ensure
            db.close
        end
        return result
    end

end
