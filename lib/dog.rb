require 'pry'

class Dog
attr_reader :id
attr_accessor :name, :breed

def initialize(name:, breed:, id: nil)
    @name = name 
    @breed = breed
    @id = id 
end

  def self.create_table
  sql = "CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
  )"
   DB[:conn].execute(sql)
  end

  def self.drop_table 
   DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save 
   sql = <<-SQL 
       INSERT INTO dogs (name,breed)
       VALUES (? , ?)
   SQL
     
   DB[:conn].execute(sql, self.name, self.breed)
   @id = DB[:conn].execute("SELECT last_insert_rowid() from dogs").first.first
   self
  end

  def self.create(attr)
   new_dog = self.new(attr)
   new_dog.save
   new_dog
  end

  def self.new_from_db(row) 
   hash = {name: row[1], breed: row[2], id: row[0]}
   dog = Dog.new(hash)
   dog
  end
  
  def self.find_by_id(id)
  res = DB[:conn].execute("SELECT * FROM dogs WHERE id= ? LIMIT 1", id).first
  Dog.new_from_db(res)
  end

  def self.find_or_create_by(name:, breed:)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).first
  
  if dog !=nil 
    dog_data = dog[0]
    dog = Dog.new_from_db(dog_data)
  else 
    dog = Dog.create({name: name, breed: breed})
 
   end
  dog
  end

  def self.find_by_name(name) 
   self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name).first)
   end

 def update 
  DB[:conn].execute("UPDATE dogs SET name = ?, breed =? WHERE id = ?", self.name,self.breed, self.id)
 end

end
