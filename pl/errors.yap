/*************************************************************************
*									 *
*	 YAP Prolog 							 *
*									 *
*	Yap Prolog was developed at NCCUP - Universidade do Porto	 *
*									 *
* Copyright L.Damas, V.S.Costa and Universidade do Porto 1985-1997	 *
*									 *
**************************************************************************
*									 *
* File:		boot.yap						 *
* Last rev:	8/2/88							 *
* mods:									 *
* comments:	error messages for YAP					 *
*									 *
*************************************************************************/

'$Error'(E) :-
	'$LoopError'(E).

'$LoopError'(_) :-
	flush_output(user_output),
	flush_output(user_error),
	fail.
'$LoopError'(Error) :- !,
	'$process_error'(Error),
	fail.
'$LoopError'(_) :-
	flush_output(user_output),
	flush_output(user_error),
	fail.

'$process_error'(abort) :- !,
        write(user_error,'[ Execution Aborted ]'),
        nl(user_error).
'$process_error'(error(Msg, Where)) :- !,
	'$set_fpu_exceptions',
	'$print_message'(error,error(Msg, Where)).
'$process_error'(Throw) :-
	print_message(error,Throw).

print_message(Level, Mss) :-
	'$print_message'(Level, Mss).

'$print_message'(force(_Severity), Msg) :- !,
	print(user_error,Msg).
'$print_message'(Severity, Msg) :-
	\+ '$undefined'(portray_message(Severity, Msg), user),
	user:portray_message(Severity, Msg), !.
'$print_message'(error,error(Msg,Where)) :-
	'$output_error_message'(Msg, Where), !.
'$print_message'(error,Throw) :-
	'$format'(user_error,"[ No handler for error ~w ]~n", [Throw]).
'$print_message'(informational,M) :-
	( '$get_value'('$verbose',on) ->
	    '$do_informational_message'(M) ;
	    true
	).
'$print_message'(warning,M) :-
	'$format'(user_error, "[ ", []),
	'$do_print_message'(M),
	'$format'(user_error, " ]~n", []).
'$print_message'(help,M) :-
	'$do_print_message'(M),
	'$format'(user_error, "~n", []).


'$do_informational_message'(loading(_,user)) :- !.
'$do_informational_message'(loading(What,AbsoluteFileName)) :- !,
	'$show_consult_level'(LC),
	'$format'(user_error, "~*|[ ~a ~a... ]~n", [LC, What, AbsoluteFileName]).
'$do_informational_message'(loaded(_,user,_,_,_)) :- !.
'$do_informational_message'(loaded(What,AbsoluteFileName,Mod,Time,Space)) :- !,
	'$show_consult_level'(LC0),
	LC is LC0+1,
	'$format'(user_error, "~*|[ ~a ~a in module ~a, ~d msec ~d bytes ]~n", [LC, What, AbsoluteFileName,Mod,Time,Space]).
'$do_informational_message'(M) :-
	'$format'("[ ", []),
	'$do_print_message'(M),
	'$format'(" ]~n", []).


%message(loaded(Past,AbsoluteFileName,user,Msec,Bytes), Prefix, Suffix) :- !,
'$do_print_message'(debug(debug)) :- !,
	'$format'(user_error,"Debug mode on.",[]).
'$do_print_message'(debug(off)) :- !,
	'$format'(user_error,"Debug mode off.",[]).
'$do_print_message'(debug(trace)) :- !,
	'$format'(user_error,"Trace mode on.",[]).
'$do_print_message'('$format'(Msg, Args)) :- !,
	'$format'(user_error,Msg,Args).
'$do_print_message'(import(Pred,To,From,private)) :- !,
	'$format'(user_error,"Importing private predicate ~w:~w to ~w.",
	[From,Pred,To]).
'$do_print_message'(no_match(P)) :- !,
	'$format'(user_error,"No matching predicate for ~w.",
	[P]).
'$do_print_message'(breakp(bp(debugger,_,_,M:F/N,_),add,already)) :- !,
	'$format'(user_error,"There is already a spy point on ~w:~w/~w.",
	[M,F,N]).	
'$do_print_message'(breakp(bp(debugger,_,_,M:F/N,_),add,ok)) :- !,
	'$format'(user_error,"Spy point set on ~w:~w/~w.",
	[M,F,N]).	
'$do_print_message'(breakp(bp(debugger,_,_,M:F/N,_),remove,last)) :- !,
	'$format'(user_error,"Spy point on ~w:~w/~w removed.",
	[M,F,N]).
'$do_print_message'(breakp(no,breakpoint_for,M:F/N)) :- !,
	'$format'(user_error,"There is no spy point on ~w:~w/~w.",
	[M,F,N]).
'$do_print_message'(leash([])) :- !,
	'$format'(user_error,"No leashing.",
	[M,F,N]).
'$do_print_message'(leash([A|B])) :- !,
	'$format'(user_error,"Leashing set to ~w.",
	[[A|B]]).
'$do_print_message'(breakpoints([])) :- !,
	'$format'(user_error,"There are no spy-points set.",
	[M,F,N]).
'$do_print_message'(breakpoints(L)) :- !,
	'$format'(user_error,"Spy-points set on:", []),
	'$print_list_of_preds'(L).
'$do_print_message'(Messg) :-
	'$format'(user_error,"~q",Messg).

'$print_list_of_preds'([]).
'$print_list_of_preds'([P|L]) :-
	'$format'(user_error,"~n      ~w",[P]),
	'$print_list_of_preds'(L).

'$output_error_message'(context_error(Goal,Who),Where) :-
	'$format'(user_error,"[ CONTEXT ERROR- ~w: ~w appeared in ~w ]~n",
	[Goal,Who,Where]).
'$output_error_message'(domain_error(array_overflow,Opt), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: invalid index ~w for array ]~n",
	[Where,Opt]).
'$output_error_message'(domain_error(array_type,Opt), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: invalid static array type ~w ]~n",
	[Where,Opt]).
'$output_error_message'(domain_error(builtin_procedure,P), P) :-
	'$format'(user_error,"[ DOMAIN ERROR- non-iso built-in procedure  ~w ]~n",
	[P]).
'$output_error_message'(domain_error(character_code_list,Opt), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: invalid list of codes ~w ]~n",
	[Where,Opt]).
'$output_error_message'(domain_error(delete_file_option,Opt), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: invalid list of options ~w ]~n",
	[Where,Opt]).
'$output_error_message'(domain_error(operator_specifier,Op), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: invalid operator specifier ~w ]~n",
	[Where,Op]).
'$output_error_message'(domain_error(close_option,Opt), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: invalid close option ~w ]~n",
	[Where,Opt]).
'$output_error_message'(domain_error(radix,Opt), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: invalid radix ~w ]~n",
	[Where,Opt]).
'$output_error_message'(domain_error(shift_count_overflow,Opt), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: shift count overflow in ~w ]~n",
	[Where,Opt]).
'$output_error_message'(domain_error(flag_value,F+V), W) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: invalid value ~w for flag ~w ]~n",
	[W,V,F]).
'$output_error_message'(domain_error(io_mode,N), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: invalid io mode ~w ]~n",
	[Where,N]).
'$output_error_message'(domain_error(mutable,N), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: invalid mutable ~w ]~n",
	[Where,N]).
'$output_error_message'(domain_error(module_decl_options,N), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: expect module declaration options, found ~w ]~n",
	[Where,N]).
'$output_error_message'(domain_error(not_empty_list,_), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: found empty list ]~n",
	[Where]).
'$output_error_message'(domain_error(not_less_than_zero,N), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: number ~w less than zero ]~n",
	[Where,N]).
'$output_error_message'(domain_error(not_newline,N), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: number ~w not newline ]~n",
	[Where,N]).
'$output_error_message'(domain_error(not_zero,N), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: number ~w not zero ]~n",
	[Where,N]).
'$output_error_message'(domain_error(operator_priority,N), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: ~w invalid operator priority ]~n",
	[Where,N]).
'$output_error_message'(domain_error(operator_specifier,N), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: ~w invalid operator specifier ]~n",
	[Where,N]).
'$output_error_message'(domain_error(predicate_spec,N), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: ~w invalid predicate specifier ]~n",
	[Where,N]).
'$output_error_message'(domain_error(read_option,N), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: ~w invalid option to read ]~n",
	[Where,N]).
'$output_error_message'(domain_error(semantics_indicator,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected predicate indicator, got ~w ]~n",
	[Where,W]).
'$output_error_message'(domain_error(source_sink,N), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: ~w is not a source sink term ]~n",
	[Where,N]).
'$output_error_message'(domain_error(stream,What), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: ~w not a stream ]~n",
	[Where,What]).
'$output_error_message'(domain_error(stream_or_alias,What), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: ~w not a stream ]~n",
	[Where,What]).
'$output_error_message'(domain_error(stream_option,What), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: ~w not a stream option ]~n",
	[Where,What]).
'$output_error_message'(domain_error(stream_position,What), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: ~w not a stream position ]~n",
	[Where,What]).
'$output_error_message'(domain_error(stream_property,What), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: ~w not a stream property ]~n",
	[Where,What]).
'$output_error_message'(domain_error(syntax_error_handler,What), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: ~w not a syntax error handler ]~n",
	[Where,What]).
'$output_error_message'(domain_error(time_out_spec,What), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: ~w not a valid specification for a time out ]~n",
	[Where,What]).
'$output_error_message'(domain_error(write_option,N), Where) :-
	'$format'(user_error,"[ DOMAIN ERROR- ~w: ~w invalid option to write ]~n",
	[Where,N]).
'$output_error_message'(existence_error(array,F), W) :-
	'$format'(user_error,"[ EXISTENCE ERROR- ~w could not open array ~w ]~n",
	[W,F]).
'$output_error_message'(existence_error(procedure,P), _) :-
	'$format'(user_error,"[ EXISTENCE ERROR- procedure ~w undefined ]~n",
	[P]).
'$output_error_message'(existence_error(source_sink,F), W) :-
	'$format'(user_error,"[ EXISTENCE ERROR- ~w could not find file ~w ]~n",
	[W,F]).
'$output_error_message'(existence_error(stream,Stream), Where) :-
	'$format'(user_error,"[ EXISTENCE ERROR- ~w: ~w not an open stream ]~n",
	[Where,Stream]).
'$output_error_message'(evaluation_error(int_overflow), Where) :-
	'$format'(user_error,"[ INTEGER OVERFLOW ERROR- ~w ]~n",
	[Where]).
'$output_error_message'(evaluation_error(float_overflow), Where) :-
	'$format'(user_error,"[ FLOATING POINT OVERFLOW ERROR- ~w ]~n",
	[Where]).
'$output_error_message'(evaluation_error(undefined), Where) :-
	'$format'(user_error,"[ UNDEFINED ARITHMETIC RESULT ERROR- ~w ]~n",
	[Where]).
'$output_error_message'(evaluation_error(underflow), Where) :-
	'$format'(user_error,"[ UNDERFLOW ERROR- ~w ]~n",
	[Where]).
'$output_error_message'(evaluation_error(float_underflow), Where) :-
	'$format'(user_error,"[ FLOATING POINT UNDERFLOW ERROR- ~w ]~n",
	[Where]).
'$output_error_message'(evaluation_error(zero_divisor), Where) :-
	'$format'(user_error,"[ ZERO DIVISOR ERROR- ~w ]~n",
	[Where]).
'$output_error_message'(instantiation_error, Where) :-
	'$format'(user_error,"[ INSTANTIATION ERROR- ~w: expected bound value ]~n",
	[Where]).
'$output_error_message'(permission_error(access,private_procedure,P), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: cannot see clauses for ~w ]~n",
	[Where,P]).
'$output_error_message'(permission_error(access,static_procedure,P), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: cannot access static procedure ~w ]~n",
	[Where,P]).
'$output_error_message'(permission_error(alias,new,P), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: cannot create alias ~w ]~n",
	[Where,P]).
'$output_error_message'(permission_error(create,array,P), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: cannot create array ~w ]~n",
	[Where,P]).
'$output_error_message'(permission_error(create,operator,P), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: cannot create operator ~w ]~n",
	[Where,P]).
'$output_error_message'(permission_error(input,binary_stream,Stream), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: cannot read from binary stream ~w ]~n",
	[Where,Stream]).
'$output_error_message'(permission_error(input,closed_stream,Stream), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: trying to read from closed stream ~w ]~n",
	[Where,Stream]).
'$output_error_message'(permission_error(input,past_end_of_stream,Stream), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: past end of stream ~w ]~n",
	[Where,Stream]).
'$output_error_message'(permission_error(input,stream,Stream), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: cannot read from ~w ]~n",
	[Where,Stream]).
'$output_error_message'(permission_error(input,text_stream,Stream), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: cannot read from text stream ~w ]~n",
	[Where,Stream]).
'$output_error_message'(permission_error(modify,dynamic_procedure,_), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: modifying a dynamic procedure ]~n",
	[Where]).
'$output_error_message'(permission_error(modify,flag,W), _) :-
	'$format'(user_error,"[ PERMISSION ERROR- cannot modify flag ~w ]~n",
	[W]).
'$output_error_message'(permission_error(modify,operator,W), _) :-
	'$format'(user_error,"[ PERMISSION ERROR- T cannot declare ~w an operator ]~n",
	[W]).
'$output_error_message'(permission_error(modify,static_procedure,_), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: modifying a static procedure ]~n",
	[Where]).
'$output_error_message'(permission_error(modify,static_procedure_in_use,_), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: modifying a static procedure in use ]~n",
	[Where]).
'$output_error_message'(permission_error(open,source_sink,Stream), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: cannot open file ~w ]~n",
	[Where,Stream]).
'$output_error_message'(permission_error(output,binary_stream,Stream), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: cannot write to binary stream ~w ]~n",
	[Where,Stream]).
'$output_error_message'(permission_error(output,stream,Stream), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: cannot write to ~w ]~n",
	[Where,Stream]).
'$output_error_message'(permission_error(output,text_stream,Stream), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: cannot write to text stream ~w ]~n",
	[Where,Stream]).
'$output_error_message'(permission_error(resize,array,P), Where) :-
	'$format'(user_error,"[ PERMISSION ERROR- ~w: cannot resize array ~w ]~n",
	[Where,P]).
'$output_error_message'(representation_error(character), Where) :-
	'$format'(user_error,"[ REPRESENTATION ERROR- ~w: expected character ]~n",
	[Where]).
'$output_error_message'(representation_error(character_code), Where) :-
	'$format'(user_error,"[ REPRESENTATION ERROR- ~w: expected character code ]~n",
	[Where]).
'$output_error_message'(representation_error(max_arity), Where) :-
	'$format'(user_error,"[ REPRESENTATION ERROR- ~w: number too big ]~n",
	[Where]).
'$output_error_message'(syntax_error(_,Position,_,Term,Pos,Start), Where) :-
	'$format'(user_error,"[ ~w ",[Where]),
	'$dump_syntax_error_line'(Start,Position),
	'$dump_syntax_error_term'(10,Pos, Term),
	'$format'(user_error,".~n]~n",[]).
'$output_error_message'(system_error, Where) :-
	'$format'(user_error,"[ SYSTEM ERROR- ~w ]~n",
	[Where]).
'$output_error_message'(system_error(Message), Where) :-
	'$format'(user_error,"[ SYSTEM ERROR- ~w at ~w]~n",
	[Message,Where]).
'$output_error_message'(type_error(T,_,Err,M), _Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected ~w, got ~w ]~n",
	[T,Err,M]).
'$output_error_message'(type_error(array,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected array, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(atom,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected atom, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(atomic,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected atomic, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(byte,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected byte, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(callable,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected callable goal, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(character,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected character, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(character_code,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected character code, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(compound,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected compound, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(db_reference,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected data base reference, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(db_term,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected data base term, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(evaluable,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected evaluable term, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(float,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected float, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(in_byte,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected byte, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(in_character,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected atom character, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(in_character_code,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected character code, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(integer,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected integer, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(key,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected database key, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(leash_mode,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected modes for leash, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(list,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected list, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(number,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected number, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(pointer,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected pointer, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(predicate_indicator,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected predicate indicator, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(unsigned_byte,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected unsigned byte, got ~w ]~n",
	[Where,W]).
'$output_error_message'(type_error(variable,W), Where) :-
	'$format'(user_error,"[ TYPE ERROR- ~w: expected unbound variable, got ~w ]~n",
	[Where,W]).
'$output_error_message'(unknown, Where) :-
	'$format'(user_error,"[ EXISTENCE ERROR- procedure ~w undefined ]~n",
	[Where]).


'$dump_syntax_error_line'(Pos,_) :-
	'$format'(user_error,"at line ~d:~n",
	[Pos]).

'$dump_syntax_error_term'(0,J,L) :- !,
	'$format'(user_error,"~n", []),
	'$dump_syntax_error_term'(10,J,L).
'$dump_syntax_error_term'(_,0,L) :- !,
	'$format'(user_error,"~n<==== HERE ====>~n", []),
	'$dump_syntax_error_term'(10,-1,L).
'$dump_syntax_error_term'(_,_,[]) :- !.
'$dump_syntax_error_term'(I,J,[T-P|R]) :-
	'$dump_error_token'(T),
	I1 is I-1,
	J1 is J-1,
	'$dump_syntax_error_term'(I1,J1,R).

'$dump_error_token'(atom(A)) :- !,
	'$format'(user_error," ~a", [A]).
'$dump_error_token'(number(N)) :- !,
	'$format'(user_error," ~w", [N]).
'$dump_error_token'(var(_,S,_)) :- !,
	'$format'(user_error," ~s ", [S]).
'$dump_error_token'(string(S)) :- !,
	'$format'(user_error," ""~s""", [S]).
'$dump_error_token'('(') :-
	'$format'(user_error,"(", []).
'$dump_error_token'(')') :-
	'$format'(user_error," )", []).
'$dump_error_token'(',') :-
	'$format'(user_error," ,", []).
'$dump_error_token'(A) :-
	'$format'(user_error," ~a", [A]).


