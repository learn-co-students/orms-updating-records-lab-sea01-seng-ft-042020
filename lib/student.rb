require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def save
    sql = <<-SQL
    INSERT INTO students (name, grade)
    VALUES (?, ?)
    SQL

    sql2 = <<-SQL
    SELECT id
    FROM students
    ORDER BY id DESC
    LIMIT 1
    SQL

    if id == nil
      DB[:conn].execute(sql, self.name, self.grade)
      self.id = DB[:conn].execute(sql2)[0][0]
    else
      self.update
    end
  end

  def update
    sql = <<-SQL
    UPDATE students
    SET name = ?, grade = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE students(
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    self.new(row[0],row[1],row[2])
  end

  def self.find_by_name(name)
    self.all.find {|student| student.name = name}
  end

  def self.all
    sql = <<-SQL
    SELECT *
    FROM students
    SQL

    students = DB[:conn].execute(sql)
    students.map {|student| self.new_from_db(student)}
  end
end
