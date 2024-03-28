require 'sqlite3'

class User
    attr_accessor :id, :firstname, :lastname, :age, :password, :email

    def initialize(id, firstname, lastname, age, password, email)
        @id = id
        @firstname = firstname
        @lastname = lastname
        @age = age
        @password = password
        @email = email
    end

    def self.connection
        begin
            db = SQLite3::Database.open 'db.sql'
            db.results_as_hash = true
            db.execute "CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY, firstname TEXT, lastname TEXT, age INTEGER, password TEXT, email TEXT)"
            return db
        rescue SQLite3::Exception => e
            puts "Error occurred: #{e}"
        end
    end

    def self.create(user_info)
        db = connection
        db.execute "INSERT INTO users(firstname, lastname, age, password, email) VALUES(?, ?, ?, ?, ?)", user_info[:firstname], user_info[:lastname], user_info[:age], user_info[:password], user_info[:email]
        id = db.last_insert_row_id
        db.close
        return User.new(id, user_info[:firstname], user_info[:lastname], user_info[:age], user_info[:password], user_info[:email])
    end

    def self.find(user_id)
        db = connection
        user = db.execute("SELECT * FROM users WHERE id = ?", user_id).first
        db.close
        return nil unless user

        return User.new(user['id'], user['firstname'], user['lastname'], user['age'], user['password'], user['email'])
    end

    def self.all
        db = connection
        users = db.execute("SELECT * FROM users")
        db.close
        users.map do |user|
            User.new(user['id'], user['firstname'], user['lastname'], user['age'], user['password'], user['email'])
        end
    end

    def update(attribute, value)
        db = User.connection
        db.execute "UPDATE users SET #{attribute} = ? WHERE id = ?", value, @id
        db.close
    end

    def destroy
        db = User.connection
        db.execute "DELETE FROM users WHERE id = ?", @id
        db.close
    end

    def self.auth(email, password)
        db = connection
        user = db.execute("SELECT * FROM users WHERE email = ? AND password = ?", email, password).first
        db.close
        return nil unless user

        return User.new(user['id'], user['firstname'], user['lastname'], user['age'], user['password'], user['email'])
    end
end
