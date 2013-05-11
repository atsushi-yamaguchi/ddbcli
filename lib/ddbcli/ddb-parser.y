class Parser
options no_result_var
rule
  stmt : query
         {
           [val[0], nil, nil]
         }
       | query RUBY_SCRIPT
         {
           [val[0], :ruby, val[1]]
         }
       | query SHELL_SCRIPT
         {
           [val[0], :shell, val[1]]
         }
       | RUBY_SCRIPT
         {
           [struct(:NULL), :ruby, val[0]]
         }
       | SHELL_SCRIPT
         {
           [struct(:NULL), :shell, val[0]]
         }

  query : show_stmt
        | alter_stmt
        | use_stmt
        | create_stmt
        | drop_stmt
        | describe_stmt
        | select_stmt
        | scan_stmt
        | get_stmt
        | update_stmt
        | delete_stmt
        | insert_stmt
        | next_stmt

  show_stmt : SHOW TABLES limit_clause
              {
                struct(:SHOW_TABLES, :limit => val[2])
              }
            | SHOW REGIONS
              {
                struct(:SHOW_REGIONS)
              }
            | SHOW CREATE TABLE IDENTIFIER
              {
                struct(:SHOW_CREATE_TABLE, :table => val[3])
              }

  alter_stmt : ALTER TABLE IDENTIFIER capacity_clause
              {
                struct(:ALTER_TABLE, :table => val[2], :capacity => val[3])
              }

  use_stmt : USE IDENTIFIER
           {
             struct(:USE, :endpoint_or_region => val[1])
           }

  create_stmt : CREATE TABLE IDENTIFIER '(' create_definition ')' capacity_clause
                {
                  struct(:CREATE, val[4].merge(:table => val[2], :capacity => val[6]))
                }
              | CREATE TABLE IDENTIFIER LIKE IDENTIFIER
                {
                  struct(:CREATE_LIKE, :table => val[2], :like => val[4], :capacity => nil)
                }
              | CREATE TABLE IDENTIFIER LIKE IDENTIFIER capacity_clause
                {
                  struct(:CREATE_LIKE, :table => val[2], :like => val[4], :capacity => val[5])
                }

  create_definition : IDENTIFIER attr_type_list HASH
                      {  
                        {:hash => {:name => val[0], :type => val[1]}, :range => nil, :indices => nil}
                      }
                    | IDENTIFIER attr_type_list HASH ',' IDENTIFIER attr_type_list RANGE
                      {
                        {:hash => {:name => val[0], :type => val[1]}, :range => {:name => val[4], :type => val[5]}, :indices => nil}
                      }
                    | IDENTIFIER attr_type_list HASH ',' IDENTIFIER attr_type_list RANGE ',' index_definition_list
                      {
                        {:hash => {:name => val[0], :type => val[1]}, :range => {:name => val[4], :type => val[5]}, :indices => val[8]}
                      }

  attr_type_list : STRING
                   {
                     'S'
                   }
                 | NUMBER
                   {
                     'N'
                   }
                 | BINARY
                   {
                     'B'
                   }

  capacity_clause : READ EQ NUMBER_VALUE ',' WRITE EQ NUMBER_VALUE
                    {
                      {:read => val[2], :write => val[6]}
                    }
                  | WRITE EQ NUMBER_VALUE ',' READ EQ NUMBER_VALUE
                    {
                      {:read => val[6], :write => val[2]}
                    }

  index_definition_list : index_definition
                          {
                            [val[0]]
                          }
                        | index_definition_list ',' index_definition
                          {
                            val[0] + [val[2]]
                          }

  index_definition : INDEX IDENTIFIER '(' IDENTIFIER attr_type_list ')' index_type_definition
                     {
                       {:name => val[1], :key => val[3], :type => val[4], :projection => val[6]}
                     }

  index_type_definition : ALL
                          {
                            {:type => 'ALL'}
                          }
                        | KEYS_ONLY
                          {
                            {:type => 'KEYS_ONLY'}
                          }
                        | INCLUDE '(' index_include_attr_list ')'
                          {
                            {:type => 'INCLUDE', :attrs => val[2]}
                          }

  index_include_attr_list : IDENTIFIER
                             {
                               [val[0]]
                             }
                           | index_include_attr_list ',' IDENTIFIER
                             {
                               val[0] + [val[2]]
                             }

  drop_stmt : DROP TABLE IDENTIFIER
              {
                struct(:DROP, :table => val[2])
              }

  describe_stmt : DESCRIBE IDENTIFIER
                  {
                    struct(:DESCRIBE, :table => val[1])
                  }
                | DESC IDENTIFIER
                  {
                    struct(:DESCRIBE, :table => val[1])
                  }

  select_stmt : SELECT attrs_to_get FROM IDENTIFIER use_index_clause select_where_clause order_clause limit_clause
                {
                  struct(:SELECT, :attrs => val[1], :table => val[3], :index => val[4], :conds => val[5], :order_asc => val[6], :limit => val[7], :count => false)
                }
              | SELECT COUNT '(' '*' ')' FROM IDENTIFIER use_index_clause select_where_clause order_clause limit_clause
                {
                  struct(:SELECT, :attrs => [], :table => val[6], :index => val[7], :conds => val[8], :order_asc => val[9], :limit => val[10], :count => true)
                }

  scan_stmt : SELECT ALL attrs_to_get FROM IDENTIFIER scan_where_clause limit_clause
              {
                struct(:SCAN, :attrs => val[2], :table => val[4], :conds => val[5], :limit => val[6], :count => false)
              }
            | SELECT ALL COUNT '(' '*' ')' FROM IDENTIFIER scan_where_clause limit_clause
              {
                struct(:SCAN, :attrs => [], :table => val[7], :conds => val[8], :limit => val[9], :count => true)
              }

  get_stmt : GET attrs_to_get FROM IDENTIFIER update_where_clause
             {
               struct(:GET, :attrs => val[1], :table => val[3], :conds => val[4])
             }

  attrs_to_get: '*'
                {
                  []
                }
              | attrs_list
                {
                  val[0]
                }

  attrs_list : IDENTIFIER
               {
                 [val[0]]
               }
             | attrs_list ',' IDENTIFIER
               {
                 val[0] + [val[2]]
               }

  use_index_clause :
                   | USE INDEX '(' IDENTIFIER ')'
                     {
                       val[3]
                     }

  select_where_clause :
                      | WHERE select_expr_list
                        {
                          val[1]
                        }

  select_expr_list : select_expr
                     {
                       [val[0]]
                     }
                     | select_expr_list AND select_expr
                       {
                         val[0] + [val[2]]
                       }

  select_expr : IDENTIFIER select_operator value
                {
                  [val[0], val[1].to_s.upcase.to_sym, [val[2]]]
                }
              | IDENTIFIER BETWEEN value AND value
                {
                  [val[0], val[1].to_s.upcase.to_sym, [val[2], val[4]]]
                }

  select_operator : common_operator

  common_operator : EQ
                    {
                      :EQ
                    }
                  | LE
                    {
                      :LE
                    }
                  | LT
                    {
                      :LT
                    }
                  | GE
                    {
                      :GE
                    }
                  | GT
                    {
                      :GT
                    }
                  | BEGINS_WITH

  scan_where_clause :
                    | WHERE scan_expr_list
                      {
                        val[1]
                      }

  scan_expr_list : scan_expr
                   {
                     [val[0]]
                   }
                 | scan_expr_list AND scan_expr
                   {
                     val[0] + [val[2]]
                   }

  scan_expr : IDENTIFIER scan_operator value
              {
                [val[0], val[1].to_s.upcase.to_sym, [val[2]]]
              }
            | IDENTIFIER IN value_list
              {
                [val[0], val[1].to_s.upcase.to_sym, val[2]]
              }
            | IDENTIFIER BETWEEN value AND value
              {
                [val[0], val[1].to_s.upcase.to_sym, [val[2], val[4]]]
              }
            | IDENTIFIER IS null_operator
              {
                [val[0], val[2].to_s.upcase.to_sym, []]
              }

  scan_operator : common_operator | contains_operator
                | NE
                {
                  :NE
                }

  contains_operator : CONTAINS
                    | NOT CONTAINS
                      {
                        :NOT_CONTAINS
                      }
  null_operator : NULL
                  {
                    :NULL
                  }
                | NOT NULL
                  {
                    :NOT_NULL
                  }

  order_clause :
               | ORDER ASC
                 {
                   true
                 }
               | ORDER DESC
                 {
                   false
                 }

  limit_clause :
               | LIMIT NUMBER_VALUE
                 {
                   val[1]
                 }

  update_stmt : UPDATE IDENTIFIER set_or_add attr_to_update_list update_where_clause
                {
                  struct(:UPDATE, :table => val[1], :action => val[2], :attrs => val[3], :conds => val[4])
                }
              | UPDATE ALL IDENTIFIER set_or_add attr_to_update_list scan_where_clause limit_clause
                {
                  struct(:UPDATE_ALL, :table => val[2], :action => val[3], :attrs => val[4], :conds => val[5], :limit => val[6])
                }

  set_or_add : SET
               {
                 :PUT
               }
             | ADD
               {
                 :ADD
               }

  attr_to_update_list : attr_to_update
                        {
                          [val[0]]
                        }
                      | attr_to_update_list ',' attr_to_update
                        {
                          val[0] + [val[2]]
                        }

  attr_to_update : IDENTIFIER EQ value_or_null
                   {
                     [val[0], val[2]]
                   }

  update_where_clause : WHERE update_expr_list
                        {
                          val[1]
                        }

  update_expr_list : update_expr
                     {
                       [val[0]]
                     }
                   | update_expr_list AND update_expr
                     {
                       val[0] + [val[2]]
                     }

  update_expr : IDENTIFIER EQ value
                {
                  [val[0], val[2]]
                }

  delete_stmt : DELETE FROM IDENTIFIER update_where_clause
                {
                  struct(:DELETE, :table => val[2], :conds => val[3])
                }
              | DELETE ALL FROM IDENTIFIER scan_where_clause limit_clause
                {
                  struct(:DELETE_ALL, :table => val[3], :conds => val[4], :limit => val[5])
                }

  insert_stmt : INSERT INTO IDENTIFIER '(' attr_to_insert_list ')' VALUES insert_value_clause
                {
                  struct(:INSERT, :table => val[2], :attrs => val[4], :values => val[7])
                }

  attr_to_insert_list : IDENTIFIER
                        {
                          [val[0]]
                        }
                      | attr_to_insert_list ',' IDENTIFIER
                        {
                          val[0] + [val[2]]
                        }

  insert_value_clause : '(' insert_value_list ')'
                        {
                          [val[1]]
                        }
                      | insert_value_clause ',' '(' insert_value_list ')'
                        {
                          val[0] + [val[3]]
                        }

  insert_value_list : value
                      {
                        [val[0]]
                      }
                    | insert_value_list ',' value
                      {
                        val[0] + [val[2]]
                      }

  next_stmt : NEXT
              {
                struct(:NEXT)
              }

  value_or_null : value | NULL

  value : single_value
        | value_list

  single_value  : NUMBER_VALUE
                | STRING_VALUE
                | BINARY_VALUE

  value_list : '(' number_list ')'
               {
                 val[1]
               }
             | '(' string_list ')'
               {
                 val[1]
               }
             | '(' binary_list ')'
               {
                 val[1]
               }

  number_list : NUMBER_VALUE
                {
                  [val[0]]
                }
              | number_list ',' NUMBER_VALUE
                {
                   val[0] + [val[2]]
                }

  string_list : STRING_VALUE
                {
                  [val[0]]
                }
              | string_list ',' STRING_VALUE
                {
                   val[0] + [val[2]]
                }

  binary_list : BINARY_VALUE
                {
                  [val[0]]
                }
              | binary_list ',' BINARY_VALUE
                {
                   val[0] + [val[2]]
                }

---- header

require 'strscan'
require 'ddbcli/ddb-binary'

module DynamoDB

---- inner

KEYWORDS = %w(
  ADD
  ALL
  ALTER
  AND
  ASC
  BEGINS_WITH
  BETWEEN
  BINARY
  CREATE
  CONTAINS
  COUNT
  DELETE
  DESCRIBE
  DESC
  DROP
  FROM
  GET
  HASH
  INCLUDE
  INDEX
  INSERT
  INTO
  IN
  IS
  KEYS_ONLY
  LIKE
  LIMIT
  NEXT
  NOT
  NUMBER
  ORDER
  RANGE
  READ
  REGIONS
  SELECT
  SET
  SHOW
  STRING
  TABLES
  TABLE
  UPDATE
  VALUES
  WHERE
  WRITE
  USE
)

KEYWORD_REGEXP = Regexp.compile("(?:#{KEYWORDS.join '|'})\\b", Regexp::IGNORECASE)

def initialize(obj)
  src = obj.is_a?(IO) ? obj.read : obj.to_s
  @ss = StringScanner.new(src)
end

@@structs = {}

def struct(name, attrs = {})
  unless (clazz = @@structs[name])
    clazz = attrs.empty? ? Struct.new(name.to_s) : Struct.new(name.to_s, *attrs.keys)
    @@structs[name] = clazz
  end

  obj = clazz.new

  attrs.each do |key, val|
    obj.send("#{key}=", val)
  end

  return obj
end
private :struct

def scan
  tok = nil

  until @ss.eos?
    if (tok = @ss.scan /\s+/)
      # nothing to do
    elsif (tok = @ss.scan /(?:<>|!=|>=|<=|>|<|=)/)
      sym = {
        '<>' => :NE,
        '!=' => :NE,
        '>=' => :GE,
        '<=' => :LE,
        '>'  => :GT,
        '<'  => :LT,
        '='  => :EQ,
      }.fetch(tok)
      yield [sym, tok]
    elsif (tok = @ss.scan KEYWORD_REGEXP)
      yield [tok.upcase.to_sym, tok]
    elsif (tok = @ss.scan /NULL/i)
      yield [:NULL, nil]
    elsif (tok = @ss.scan /`(?:[^`]|``)*`/)
      yield [:IDENTIFIER, tok.slice(1...-1).gsub(/``/, '`')]
    elsif (tok = @ss.scan /x'(?:[^']|'')*'/) #'
      hex = tok.slice(2...-1).gsub(/''/, "'")
      bin = DynamoDB::Binary.new([hex].pack('H*'))
      yield [:BINARY_VALUE, bin]
    elsif (tok = @ss.scan /x"(?:[^"]|"")*"/) #"
      hex = tok.slice(2...-1).gsub(/""/, '"')
      bin = DynamoDB::Binary.new([hex].pack('H*'))
      yield [:BINARY_VALUE, bin]
    elsif (tok = @ss.scan /'(?:[^']|'')*'/) #'
      yield [:STRING_VALUE, tok.slice(1...-1).gsub(/''/, "'")]
    elsif (tok = @ss.scan /"(?:[^"]|"")*"/) #"
      yield [:STRING_VALUE, tok.slice(1...-1).gsub(/""/, '"')]
    elsif (tok = @ss.scan /\d+(?:\.\d+)?/)
      yield [:NUMBER_VALUE, (tok =~ /\./ ? tok.to_f : tok.to_i)]
    elsif (tok = @ss.scan /[,\(\)\*]/)
      yield [tok, tok]
    elsif (tok = @ss.scan /\|(?:.*)/)
      yield [:RUBY_SCRIPT, tok.slice(1..-1)]
    elsif (tok = @ss.scan /\!(?:.*)/)
      yield [:SHELL_SCRIPT, tok.slice(1..-1)]
    elsif (tok = @ss.scan /[-.0-9a-z_]*/i)
      yield [:IDENTIFIER, tok]
    else
      raise Racc::ParseError, ('parse error on value "%s"' % @ss.rest.inspect)
    end
  end

  yield [false, 'EOF']
end
private :scan

def parse
  yyparse self, :scan
end

def self.parse(obj)
  self.new(obj).parse
end

---- footer

end # DynamoDB
