/* description: Parses end executes mathematical expressions. */

%{
	var symbolTables = [{name: "Global", father: null, vars: {}}]; //Tabla de simbolos global
	var scope = 0;
	var symbolTable = symbolTables[scope]; //Tabla de simbolos actual

	function getScope() {
  		return scope;
	}

	function getFormerScope() {
   		scope--;
   		symbolTable = symbolTables[scope];
	}

	function makeNewScope(id) { // En cada declaracion de procedimiento poner esto
   		scope++;
      symbolTables[scope] =  { name: id, father: symbolTable, vars: {} };
   		symbolTable.vars[id].symbolTable = symbolTables[scope];
   		symbolTable = symbolTables[scope];
      
   		return symbolTable;
	}
	function findSymbol(x) {
  		var f;
  		var s = scope;
  		do {
    			f = symbolTables[s].vars[x];
    			s--;
  		} while (s >= 0 && !f);
  		s++;
  		return [f, s];
	}
  
	function symbolsToString(){
		symbols = [];
		for(var key in symbolTable.vars) {
	    symbols.push({id: key, type: symbolTable.vars[key].type, value: symbolTable.vars[key].value});
    };
		return symbols;
	}
  
	function reset(){
	  symbolTables = [{name: "Global", father: null, vars: {}}]; //Tabla de simbolos global
	  scope = 0;
	  symbolTable = symbolTables[scope]; //Tabla de simbolos actual
	}

//makenewscope = cuando entramos en un ambito
//getformerscope = cuando salimos de un ambito
%}

%token NUMBER ID EOF PROCEDURE CALL CONST VAR BEGIN END WHILE DO ODD IF THEN ELSE
/* operator associations and precedence */

%right THEN ELSE
%right '='
%left '+' '-'
%left '*' '/'
%left UMINUS

%start program

%% /* language grammar */
program
    : reset block DOT EOF
	  {
	    return [{symboltable: symbolsToString()}].concat($2);
	  }
    ;

reset
    : /* empty */
    {
      // Reiniciar programa.
      reset();
    }
    ;
    
block
    : block_const block_vars block_procs statement
	  {
	    $$ = [];
		
		if($3) $$ = $$.concat($3)
		
		if($$.length > 0)
		  $$ = [$$];
		
		if($4)
		  $$ = $$.concat($4);
	  }
	;
	
  block_const
      : CONST ID '=' NUMBER block_const_ids SEMICOLON
	    {
        if (symbolTable.vars[$ID]) 
          throw new Error("Constante "+$ID+" ya definida.");
	      symbolTable.vars[$ID] = { type: "CONST", value: $NUMBER }
	      $$ = [{ type: $1, id: $2, value: $4 }];
		    if($5) $$ = $$.concat($5);
	    }
	  | /* empty */
	    {
	      $$ = [];
	    }
	  ;
	
  block_const_ids
      : COMMA ID '=' NUMBER block_const_ids
	    {
        if (symbolTable.vars[$ID]) 
          throw new Error("Constante "+$ID+" ya definida.");

		    symbolTable.vars[$ID] = { type: "CONST", value: $NUMBER }
		    $$ = [{ type: "CONST", id: $2, value: $4 }];
		    if($5) $$ = $$.concat($5);
	  	}
	  | /* empty */
	  {
	    $$ = [];
	  }
	  ;
	  
  block_vars
      : VAR ID block_vars_id SEMICOLON
	    {
        if (symbolTable.vars[$ID]) 
          throw new Error("Variable "+$ID+" ya definida.");
		    symbolTable.vars[$ID] = { type: "VAR", value: "" }
		    $$ = [{ type: $1, value: $2 }];
		    if($3) $$ = $$.concat($3);
	    }
	  | /* empty */
	    {
		  $$ = [];
		}
	  ;
	  
  block_vars_id
      : COMMA ID block_vars_id
        {
          if (symbolTable.vars[$ID]) 
            throw new Error("Variable "+$ID+" ya definida.");
          symbolTable.vars[$ID] = { type: "VAR", value: "" }
          $$ = [{ type: "VAR", value: $2 }];
          if($3) $$ = $$.concat($3);
        }
	    | /* empty */
        {
          $$ = [];
        }
	    ;


  block_procs
      : PROCEDURE functionname SEMICOLON block SEMICOLON block_procs
        {
          $$ = [{type: $1, id: $2.id, parameters: $2.parameters, block: $4, symboltable: symbolsToString()}];
          getFormerScope();

          if($6) $$ = $$.concat($6);
        }
	  | /* empty */
	    {
		    $$ = [];
		  }
	  ;

  functionname
    : ID block_procs_parameters
      {
        if (symbolTable.vars[$ID]) 
          throw new Error("Función "+$ID+" ya definido.");
        symbolTable.vars[$ID] = { type: "PROCEDURE", name: $ID, value: $2.length }; // Contar parámetros en "numparameters"
        makeNewScope($ID);
        
        // Asociar los parámetros al ámbito actual.
        $2.forEach(function(p) {
          // Guardar parámetro
          console.log(p.value);
          if (symbolTable.vars[p.value]) 
            throw new Error("Identificador " + p.value + " ya definido.");
            
          symbolTable.vars[p.value] = { type: "PARAM", value: "" };
        });

        $$ = {id: $1, parameters: $2};
      }
	  ;
	  
  block_procs_parameters
      : '(' VAR ID block_procs_parameters_ids ')'
        {
          $$ = [{type: 'ID', value: $3}].concat($4);
        }
      | '(' ')'
        {
          $$ = [];
        }
      | /* empty */
        {
          $$ = [];
        }
      ;

  block_procs_parameters_ids
      : COMMA VAR ID block_procs_parameters_ids
	      {
		      $$ = [{type: 'ID', value: $3}].concat($4);
		    }
	    | /* empty */
	      {
		      $$ = [];
		    }
	    ;
		
statement
    : ID '=' expression
	    {
        var info = findSymbol($ID);
        var s = info[1];
        info = info[0];

        if (info && info.type === "VAR") { 
          $$ = {type: $2, left: {id: $1, declared_in: symbolTables[s].name }, right: $3};
        }
        else if (info && info.type === "PARAM") { //Parametro 
          $$ = {type: $2, left: {id: $1, declared_in: symbolTables[s].name }, right: $3, declared_in: symbolTables[s].name};
        }
        else if (info && info.type === "CONST") { 
           throw new Error("Symbol "+$ID+" refers to a constant");
        }
        else if (info && info.type === "PROCEDURE") { 
           throw new Error("Symbol "+$ID+" refers to a function");
        }
        else { 
           throw new Error("Symbol "+$ID+" not declared");
        }
	    }

	| CALL ID statement_call_arguments
	  {
	    var info = findSymbol($ID);
      var s = info[1];
      info = info[0];


      if (info && info.type === "VAR") { 
        throw new Error("Symbol "+$ID+" refers to a variable");
      }
      else if (info && info.type === "PARAM") { //Parametro 
         throw new Error("Symbol "+$ID+" refers to a parameter");
      }
      else if (info && info.type === "CONST") { 
         throw new Error("Symbol "+$ID+" refers to a constant");
      }
      else if (info && info.type === "PROCEDURE" && info.value == $3.length) { 
         $$ = {type: $1, id: $2, arguments: $3};
      }
      else if(info && info.type === "PROCEDURE") {
        throw new Error("Numero de argumentos invalido para " + $ID + "(" + $3.length + " de " + info.value + ")");
      }
      else { 
         throw new Error("Symbol "+$ID+" not declared");
      }

	  }
	| BEGIN statement statement_begin_st END
	  {
	    $$ = {type: $1, value: [$2].concat($3)};
	  }
	| IF condition THEN statement
	  {
	    $$ = {type: $1, condition: $2, statement: $4};
	  }
	| IF condition THEN statement ELSE statement
	  {
	    $$ = {type: "IFELSE", condition: $2, statement_true: $4, statement_false: $6};
	  }
	| WHILE condition DO statement
	  {
	    $$ = {type: $1, condition: $2, statement: $4};
	  }
	| /* empty */
	  {
	    $$ = [];
	  }
	;
	
  statement_call_arguments
      : '(' ID statement_call_arguments_ids ')'
        {
          // Comprobar que existe el identificador, y que no sea un id de PROCEDURE
          var info = findSymbol($ID);
          var s = info[1];
          info = info[0];

          if (info && info.type === "PROCEDURE") { 
            throw new Error("Symbol "+$ID+" refers to a procedure identifier.");
          }
          else if(info) {
            $$ = [{type: 'ID', value: $2}].concat($3);
          }
          else { 
             throw new Error("Symbol "+$ID+" not declared");
	        }
        }
      | '(' NUMBER statement_call_arguments_ids ')'
        {
          $$ = [{type: 'NUMBER', value: $2}].concat($3);
        }
      | '(' ')'
        {
          $$ = [];
        }
      | /* empty */
        {
          $$ = [];
        }
      ;
	  
  statement_call_arguments_ids
      : COMMA ID statement_call_arguments_ids
        {
          // Comprobar que existe el identificador, y que no sea un id de PROCEDURE
          var info = findSymbol($ID);
          var s = info[1];
          info = info[0];

          if (info && info.type === "PROCEDURE") { 
            throw new Error("Symbol "+$ID+" refers to a procedure identifier.");
          }
          else if(info) {
            $$ = [{type: 'ID', value: $2}].concat($3);
          }
          else { 
             throw new Error("Symbol "+$ID+" not declared.");
	        }
        }
	    | COMMA NUMBER statement_call_arguments_ids
        {
          $$ = [{type: 'NUMBER', value: $2}].concat($3);
        }
	    | /* empty */
        {
          $$ = [];
        }
	  ;
	
  statement_begin_st
      : SEMICOLON statement statement_begin_st
	    {
		  // Posibles problemas de compatibilidad con IE < 9
		  aux = $2;
		  if(Object.keys(aux).length == 0)
		    $$ = [];
		  else
		    $$ = [$2];
			
		  if($3) $$ = $$.concat($3)
		}
	  | /* empty */
	    {
		  $$ = [];
		}
	  ;
	
condition
    : ODD expression
	  {
	    $$ = {type: $1, value: $2};
	  }
	| expression COMPARISON expression
	  {
	    $$ = {type: $2, left: $1, right: $3};
	  }
	;
	
expression
    : expression '+' expression
	  {
	    $$ = {type: $2, left: $1, right: $3};
	  }
	| expression '-' expression
	  {
	    $$ = {type: $2, left: $1, right: $3};
	  }
	| expression '*' expression
	  {
	    $$ = {type: $2, left: $1, right: $3};
	  }
	| expression '/' expression
	  {
	    $$ = {type: $2, left: $1, right: $3};
	  }
	| '-' expression %prec UMINUS
	  {
	    $$ = {type: $1, value: $2};
	  }
	| '(' expression ')'
	  {
	    $$ = $2;
	  }
	| ID
    {
      // Comprobar si existe
      var info = findSymbol($ID);
      var s = info[1];
      info = info[0];

      if (info && info.type === "PROCEDURE")
        throw new Error("Symbol "+$ID+" refers to a procedure");
      else if (info)
        $$ = { id: $1, declared_in: symbolTables[s].name };
      else
        throw new Error("Symbol "+$ID+" not declared");
    }
	| NUMBER
	;
