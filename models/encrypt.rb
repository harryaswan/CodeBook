require('base64')
class Encrypt

    def self.value(value)

        cipher = OpenSSL::Cipher.new('AES-128-CBC')
        cipher.encrypt
        cipher.key = "akpsdjfhasdpjhfaksldjfna;lsdloqeRUWERD"
        cipher.iv = "ashdadfuhadsfiasiw39393845858484"
        encrypted = cipher.update(value) + cipher.final
        return Base64.encode64(encrypted).encode('utf-8').chomp
    end

    def self.check(value_a, value_b)

        # bTgTAmKKbzlx8ZNYSyA7+A==+
        # bTgTAmKKbzlx8ZNYSyA7+A==

    end

end
