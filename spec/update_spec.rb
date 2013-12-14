describe 'ddbcli' do
  context 'update' do
    before do
      ddbcli(<<-'EOS')
CREATE TABLE `employees` (
  `emp_no` NUMBER HASH,
  `birth_date` STRING RANGE
) read=2 write=2;

INSERT INTO `employees`
  (`birth_date`, `emp_no`, `first_name`, `gender`, `hire_date`, `last_name`)
VALUES
  ("1956-05-15",2,"Cathie","M","1997-04-11","Keohane"),
  ("1957-09-16",4,"Aemilian","M","1990-09-25","Roccetti"),
  ("1959-07-01",4,"Dayanand","M","1989-09-01","Waterhouse"),
  ("1964-12-29",7,"Mack","F","1988-02-25","Hambrick"),
  ("1962-07-06",4,"Tristan","M","1985-07-20","Biran"),
  ("1964-04-30",2,"Akhilish","F","1985-03-21","Isaak"),
  ("1963-07-14",1,"Katsuyuki","F","1989-12-28","Weedon"),
  ("1961-10-19",2,"Collette","M","1993-02-26","Ghemri"),
  ("1955-04-26",4,"Zine","M","1991-06-19","Butner"),
  ("1961-04-28",4,"Selwyn","F","1994-08-12","Parascandalo");
      EOS
    end

    it 'update by pk' do
      ddbcli('update employees set hire_date = "1977-11-11", foo = "bar" where emp_no = 4 and birth_date = "1961-04-28"')
      out = ddbcli('select all * from employees')
      out = JSON.parse(out)

      expect(out).to eq(
[{"birth_date"=>"1956-05-15",
  "emp_no"=>2,
  "first_name"=>"Cathie",
  "gender"=>"M",
  "hire_date"=>"1997-04-11",
  "last_name"=>"Keohane"},
 {"birth_date"=>"1961-10-19",
  "emp_no"=>2,
  "first_name"=>"Collette",
  "gender"=>"M",
  "hire_date"=>"1993-02-26",
  "last_name"=>"Ghemri"},
 {"birth_date"=>"1964-04-30",
  "emp_no"=>2,
  "first_name"=>"Akhilish",
  "gender"=>"F",
  "hire_date"=>"1985-03-21",
  "last_name"=>"Isaak"},
 {"birth_date"=>"1963-07-14",
  "emp_no"=>1,
  "first_name"=>"Katsuyuki",
  "gender"=>"F",
  "hire_date"=>"1989-12-28",
  "last_name"=>"Weedon"},
 {"birth_date"=>"1964-12-29",
  "emp_no"=>7,
  "first_name"=>"Mack",
  "gender"=>"F",
  "hire_date"=>"1988-02-25",
  "last_name"=>"Hambrick"},
 {"birth_date"=>"1955-04-26",
  "emp_no"=>4,
  "first_name"=>"Zine",
  "gender"=>"M",
  "hire_date"=>"1991-06-19",
  "last_name"=>"Butner"},
 {"birth_date"=>"1957-09-16",
  "emp_no"=>4,
  "first_name"=>"Aemilian",
  "gender"=>"M",
  "hire_date"=>"1990-09-25",
  "last_name"=>"Roccetti"},
 {"birth_date"=>"1959-07-01",
  "emp_no"=>4,
  "first_name"=>"Dayanand",
  "gender"=>"M",
  "hire_date"=>"1989-09-01",
  "last_name"=>"Waterhouse"},
 {"birth_date"=>"1961-04-28",
  "emp_no"=>4,
  "first_name"=>"Selwyn",
  "foo"=>"bar",
  "gender"=>"F",
  "hire_date"=>"1977-11-11",
  "last_name"=>"Parascandalo"},
 {"birth_date"=>"1962-07-06",
  "emp_no"=>4,
  "first_name"=>"Tristan",
  "gender"=>"M",
  "hire_date"=>"1985-07-20",
  "last_name"=>"Biran"}]
      )
    end

    it 'update all' do
      ddbcli('update all employees set hire_date = "1977-11-11", foo = "bar" where gender = "F"')
      out = ddbcli('select all * from employees')
      out = JSON.parse(out)

      expect(out).to eq(
[{"birth_date"=>"1956-05-15",
  "emp_no"=>2,
  "first_name"=>"Cathie",
  "gender"=>"M",
  "hire_date"=>"1997-04-11",
  "last_name"=>"Keohane"},
 {"birth_date"=>"1961-10-19",
  "emp_no"=>2,
  "first_name"=>"Collette",
  "gender"=>"M",
  "hire_date"=>"1993-02-26",
  "last_name"=>"Ghemri"},
 {"birth_date"=>"1964-04-30",
  "emp_no"=>2,
  "first_name"=>"Akhilish",
  "foo"=>"bar",
  "gender"=>"F",
  "hire_date"=>"1977-11-11",
  "last_name"=>"Isaak"},
 {"birth_date"=>"1963-07-14",
  "emp_no"=>1,
  "first_name"=>"Katsuyuki",
  "foo"=>"bar",
  "gender"=>"F",
  "hire_date"=>"1977-11-11",
  "last_name"=>"Weedon"},
 {"birth_date"=>"1964-12-29",
  "emp_no"=>7,
  "first_name"=>"Mack",
  "foo"=>"bar",
  "gender"=>"F",
  "hire_date"=>"1977-11-11",
  "last_name"=>"Hambrick"},
 {"birth_date"=>"1955-04-26",
  "emp_no"=>4,
  "first_name"=>"Zine",
  "gender"=>"M",
  "hire_date"=>"1991-06-19",
  "last_name"=>"Butner"},
 {"birth_date"=>"1957-09-16",
  "emp_no"=>4,
  "first_name"=>"Aemilian",
  "gender"=>"M",
  "hire_date"=>"1990-09-25",
  "last_name"=>"Roccetti"},
 {"birth_date"=>"1959-07-01",
  "emp_no"=>4,
  "first_name"=>"Dayanand",
  "gender"=>"M",
  "hire_date"=>"1989-09-01",
  "last_name"=>"Waterhouse"},
 {"birth_date"=>"1961-04-28",
  "emp_no"=>4,
  "first_name"=>"Selwyn",
  "foo"=>"bar",
  "gender"=>"F",
  "hire_date"=>"1977-11-11",
  "last_name"=>"Parascandalo"},
 {"birth_date"=>"1962-07-06",
  "emp_no"=>4,
  "first_name"=>"Tristan",
  "gender"=>"M",
  "hire_date"=>"1985-07-20",
  "last_name"=>"Biran"}]
      )
    end

    it 'update add' do
      ddbcli('update all employees set foo = 500')
      ddbcli('update all employees add foo = 1000 where gender = "F"')
      out = ddbcli('select all * from employees')
      out = JSON.parse(out)

      expect(out).to eq(
[{"birth_date"=>"1956-05-15",
  "emp_no"=>2,
  "first_name"=>"Cathie",
  "foo"=>500,
  "gender"=>"M",
  "hire_date"=>"1997-04-11",
  "last_name"=>"Keohane"},
 {"birth_date"=>"1961-10-19",
  "emp_no"=>2,
  "first_name"=>"Collette",
  "foo"=>500,
  "gender"=>"M",
  "hire_date"=>"1993-02-26",
  "last_name"=>"Ghemri"},
 {"birth_date"=>"1964-04-30",
  "emp_no"=>2,
  "first_name"=>"Akhilish",
  "foo"=>1500,
  "gender"=>"F",
  "hire_date"=>"1985-03-21",
  "last_name"=>"Isaak"},
 {"birth_date"=>"1963-07-14",
  "emp_no"=>1,
  "first_name"=>"Katsuyuki",
  "foo"=>1500,
  "gender"=>"F",
  "hire_date"=>"1989-12-28",
  "last_name"=>"Weedon"},
 {"birth_date"=>"1964-12-29",
  "emp_no"=>7,
  "first_name"=>"Mack",
  "foo"=>1500,
  "gender"=>"F",
  "hire_date"=>"1988-02-25",
  "last_name"=>"Hambrick"},
 {"birth_date"=>"1955-04-26",
  "emp_no"=>4,
  "first_name"=>"Zine",
  "foo"=>500,
  "gender"=>"M",
  "hire_date"=>"1991-06-19",
  "last_name"=>"Butner"},
 {"birth_date"=>"1957-09-16",
  "emp_no"=>4,
  "first_name"=>"Aemilian",
  "foo"=>500,
  "gender"=>"M",
  "hire_date"=>"1990-09-25",
  "last_name"=>"Roccetti"},
 {"birth_date"=>"1959-07-01",
  "emp_no"=>4,
  "first_name"=>"Dayanand",
  "foo"=>500,
  "gender"=>"M",
  "hire_date"=>"1989-09-01",
  "last_name"=>"Waterhouse"},
 {"birth_date"=>"1961-04-28",
  "emp_no"=>4,
  "first_name"=>"Selwyn",
  "foo"=>1500,
  "gender"=>"F",
  "hire_date"=>"1994-08-12",
  "last_name"=>"Parascandalo"},
 {"birth_date"=>"1962-07-06",
  "emp_no"=>4,
  "first_name"=>"Tristan",
  "foo"=>500,
  "gender"=>"M",
  "hire_date"=>"1985-07-20",
  "last_name"=>"Biran"}]
      )
    end

    it 'update delete' do
      ddbcli('update all employees set hire_date = null where gender = "M"')
      out = ddbcli('select all * from employees')
      out = JSON.parse(out)

      expect(out).to eq(
[{"birth_date"=>"1956-05-15",
  "emp_no"=>2,
  "first_name"=>"Cathie",
  "gender"=>"M",
  "last_name"=>"Keohane"},
 {"birth_date"=>"1961-10-19",
  "emp_no"=>2,
  "first_name"=>"Collette",
  "gender"=>"M",
  "last_name"=>"Ghemri"},
 {"birth_date"=>"1964-04-30",
  "emp_no"=>2,
  "first_name"=>"Akhilish",
  "gender"=>"F",
  "hire_date"=>"1985-03-21",
  "last_name"=>"Isaak"},
 {"birth_date"=>"1963-07-14",
  "emp_no"=>1,
  "first_name"=>"Katsuyuki",
  "gender"=>"F",
  "hire_date"=>"1989-12-28",
  "last_name"=>"Weedon"},
 {"birth_date"=>"1964-12-29",
  "emp_no"=>7,
  "first_name"=>"Mack",
  "gender"=>"F",
  "hire_date"=>"1988-02-25",
  "last_name"=>"Hambrick"},
 {"birth_date"=>"1955-04-26",
  "emp_no"=>4,
  "first_name"=>"Zine",
  "gender"=>"M",
  "last_name"=>"Butner"},
 {"birth_date"=>"1957-09-16",
  "emp_no"=>4,
  "first_name"=>"Aemilian",
  "gender"=>"M",
  "last_name"=>"Roccetti"},
 {"birth_date"=>"1959-07-01",
  "emp_no"=>4,
  "first_name"=>"Dayanand",
  "gender"=>"M",
  "last_name"=>"Waterhouse"},
 {"birth_date"=>"1961-04-28",
  "emp_no"=>4,
  "first_name"=>"Selwyn",
  "gender"=>"F",
  "hire_date"=>"1994-08-12",
  "last_name"=>"Parascandalo"},
 {"birth_date"=>"1962-07-06",
  "emp_no"=>4,
  "first_name"=>"Tristan",
  "gender"=>"M",
  "last_name"=>"Biran"}]
      )
    end

  end
end
