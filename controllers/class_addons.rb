class Array

    def delete_friend(friend)
        self.each do |user|
            if user.id == friend.id
                self.delete(user)
            end
        end
    end

    def find_by_id(id)

        self.each do |item|
            if item.id == id
                return item
            end
        end
        return nil

    end

end
