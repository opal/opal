class Opal::Handlebars

rule

tagret
  : program
    {
      result = val[0]
    }

program
  : statements simpleInverse statements
    {
      result = s(:program, val[0], val[2])
    }
  | statements
    {
      result = s(:program, val[0])
    }
  |
    {
      result = s(:program, [])
    }

statements
  : statement
    {
      result = [val[0]]
    }
  | statements statement
    {
      val[0].push val[1]
      result = val[0]
    }

statement
  : openInverse program closeBlock
    {
      result = s(:block, val[0], val[1], val[1], val[2])
    }
  | openBlock program closeBlock
    {
      result = s(:block, val[0], val[1], val[1], val[2])
    }
  | mustache
    {
      result = val[0]
    }
  | partial
    {
      result = val[0]
    }
  | CONTENT
    {
      result = s(:content, val[0])
    }
  | COMMENT
    {
      result = s(:comment, val[0])
    }

openBlock
  : OPEN_BLOCK inMustache CLOSE
    {
      result = s(:mustache, val[1][0], val[1][1])
    }

openInverse
  : OPEN_INVERSE inMustache CLOSE
    {
      result = s(:mustache, val[1][0], val[1][1])
    }

closeBlock
  : OPEN_ENDBLOCK path CLOSE
    {
      result = val[1]
    }

mustache
  : OPEN inMustache CLOSE
    {
      result = s(:mustache, val[1][0], val[1][1])
    }
  | OPEN_UNESCAPED inMustache CLOSE
    {
      result = s(:mustache, val[1][0], val[1][1], true)
    }

partial
  : OPEN_PARTIAL path CLOSE
    {
      result = s(:partial, val[1])
    }
  | OPEN_PARTIAL path path CLOSE
    {
      result = s(:partial, val[1], val[2])
    }

simpleInverse
  : OPEN_INVERSE CLOSE
    {
    }

inMustache
  : path params hash
    {
      result = [[val[0]] + val[1], val[2]]
    }
  | path params
    {
      result = [[val[0]] + val[1], nil]
    }
  | path hash
    {
      result = [[val[0]], val[1]]
    }
  | path
    {
      result = [[val[0]], nil]
    }
  | DATA
    {
      result = [s(:data, val[0]), nil]
    }

params
  : params param
    {
      val[0].push val[1]
      result = val[0]
    }
  | param
    {
      result = [val[0]]
    }

param
  : path
    {
      result = val[0]
    }
  | STRING
    {
      result = s(:string, val[0])
    }
  | INTEGER
    {
      result = s(:integer, val[0])
    }
  | BOOLEAN
    {
      result = s(:boolean, val[0])
    }
  | DATA
    {
      result = s(:data, val[0])
    }

hash
  : hashSegments
    {
      result = s(:hash, val[0])
    }

hashSegments
  : hashSegments hashSegment
    {
      val[0] << val[1]
      result = val[0]
    }
  | hashSegment
    {
      result = [val[0]]
    }

hashSegment
  : ID EQUALS path
    {
      result = [val[0], val[2]]
    }
  | ID EQUALS STRING
    {
      result = [val[0], s(:string, val[2])]
    }
  | ID EQUALS INTEGER
    {
      result = [val[0], s(:integer, val[2])]
    }
  | ID EQUALS BOOLEAN
    {
      result = [val[0], s(:boolean, val[2])]
    }
  | ID EQUALS DATA
    {
      result = [val[0], s(:data, val[2])]
    }

path
  : pathSegments
    {
      result = s(:id, val[0])
    }

pathSegments
  : pathSegments SEP ID
    {
      val[0] << val[2]
      result = val[0]
    }
  | ID
    {
      result = [val[0]]
    }

end

---- inner