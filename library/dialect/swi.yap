
% SWI emulation.
% written in an on-demand basis.


:- module(system, [term_to_atom/2,
		   concat_atom/2,
		   concat_atom/3,
		   setenv/2,
		   prolog_to_os_filename/2,
		   is_absolute_file_name/1,
		   read_clause/1,
		   string/1,
		   working_directory/2,
		   chdir/1,
		   compile_aux_clauses/1,
		   convert_time/2,
		   '$set_source_module'/2,
		   '$declare_module'/5,
		   '$set_predicate_attribute'/3,
		   load_foreign_library/1,
		   load_foreign_library/2,
		   use_foreign_library/1,
		   time_file/2,
		   flag/3,
		   current_flag/1
		]).

:- reexport(library(charsio),[
			      write_to_chars/2,
			      read_from_chars/2
			     ]).

:- reexport(library(lists),[append/2,
			    append/3,
			    delete/3,
			    member/2,
			    flatten/2,
			    intersection/3,
			    last/2,
			    memberchk/2,
			    max_list/2,
			    min_list/2,
			    nextto/3,
			    permutation/2,
			    reverse/2,
			    select/3,
			    selectchk/3,
			    sublist/2,
			    sumlist/2,
			    nth1/3,
			    nth0/3]).

:- reexport(library(apply),[maplist/2,
			    maplist/3,
			    maplist/4,
			    maplist/5,
			    include/3,
			    exclude/3,
			    partition/4,
			    partition/5
			   ]).

:- reexport(library(system),
	      [datime/1,
	       mktime/2,
	       file_property/2,
	       sleep/1]).

:- reexport(library(arg),
	      [genarg/3]).

:- reexport(library(apply_macros),
	      []).

:- reexport(library(terms),
	      [subsumes/2,
	       subsumes_chk/2,
	       term_hash/2,
	       unifiable/3,
	       cyclic_term/1,
	       variant/2]).

:- source.

:- style_check(all).

:- yap_flag(unknown,error).

:- yap_flag(open_expands_filename,false).

:- yap_flag(autoload,true).


:- set_prolog_flag(user_flags,silent).

:- load_foreign_files([plstream], [], initIO).

% Time is given as a float in SWI-Prolog.
swi_get_time(FSecs) :- datime(Datime),  mktime(Datime, Secs), FSecs is Secs*1.0.

goal_expansion(atom_concat(A,B),atomic_concat(A,B)).
goal_expansion(atom_concat(A,B,C),atomic_concat(A,B,C)).
%goal_expansion(arg(A,_,_),_) :- nonvar(A), !, fail.
goal_expansion(arg(A,B,C),genarg(A,B,C)).
goal_expansion(time_file(A,B),system:swi_time_file(A,B)).

goal_expansion(get_time(A),system:swi_get_time(A)).
goal_expansion(time_file(A,B),system:swi_time_file(A,B)).
goal_expansion(expand_file_name(A,B),system:swi_expand_file_name(A,B)).
goal_expansion(wildcard_match(A,B),system:swi_wilcard_match(A,B)).
goal_expansion(directory_files(A,B),system:swi_directory_files(A,B)).
goal_expansion(file_name_extension(A,B,C), system:swi_file_name_extension(A,B,C)).
goal_expansion(exists_file(A), system:swi_exists_file(A)).
goal_expansion(exists_directory(A), system:swi_exists_directory(A)).

:- dynamic swi_io/0.

goal_expansion(open(A,B,C,D),system:swi_open(A,B,C,D)) :- swi_io.
goal_expansion(open(A,B,C), system:swi_open(A,B,C)) :- swi_io.
goal_expansion(close(A), system:swi_close(A)) :- swi_io.
goal_expansion(close(A,B), system:swi_close(A,B)) :- swi_io.
goal_expansion(set_input(A), system:swi_set_input(A)) :- swi_io.
goal_expansion(set_output(A), system:swi_set_output(A)) :- swi_io.
goal_expansion(current_input(A), system:swi_current_input(A)) :- swi_io.
goal_expansion(current_output(A), system:swi_current_output(A)) :- swi_io.
goal_expansion(get_code(A,B),system:swi_get_code(A,B)) :- swi_io.
goal_expansion(get_code(A), system:swi_get_code(A)) :- swi_io.
goal_expansion(get_char(A,B),system:swi_get_char(A,B)) :- swi_io.
goal_expansion(get_char(A), system:swi_get_char(A)) :- swi_io.
goal_expansion(get_byte(A,B),system:swi_get_byte(A,B)) :- swi_io.
goal_expansion(get_byte(A), system:swi_get_byte(A)) :- swi_io.
goal_expansion(peek_code(A,B),system:swi_peek_code(A,B)) :- swi_io.
goal_expansion(peek_code(A), system:swi_peek_code(A)) :- swi_io.
goal_expansion(peek_char(A,B),system:swi_peek_char(A,B)) :- swi_io.
goal_expansion(peek_char(A), system:swi_peek_char(A)) :- swi_io.
goal_expansion(peek_byte(A,B),system:swi_peek_byte(A,B)) :- swi_io.
goal_expansion(peek_byte(A), system:swi_peek_byte(A)) :- swi_io.
goal_expansion(put_byte(A,B),system:swi_put_byte(A,B)) :- swi_io.
goal_expansion(put_byte(A), system:swi_put_byte(A)) :- swi_io.
goal_expansion(put_code(A,B),system:swi_put_code(A,B)) :- swi_io.
goal_expansion(put_code(A), system:swi_put_code(A)) :- swi_io.
goal_expansion(put_char(A,B),system:swi_put_char(A,B)) :- swi_io.
goal_expansion(put_char(A), system:swi_put_char(A)) :- swi_io.
goal_expansion(flush_output, system:swi_flush_output).
goal_expansion(flush_output(A), system:swi_flush_output(A)) :- swi_io.
goal_expansion(at_end_of_stream(A), system:swi_at_end_of_stream(A)) :- swi_io.
goal_expansion(at_end_of_stream, system:swi_at_end_of_stream).
goal_expansion(stream_property(A,B),system:swi_stream_property(A,B)) :- swi_io.
goal_expansion(set_stream_position(A,B),system:swi_set_stream_position(A,B)) :- swi_io.

					/* edinburgh IO */
goal_expansion(see(A), system:swi_see(A)) :- swi_io.
goal_expansion(seen, system:swi_seen).
goal_expansion(seeing(A), system:swi_seeing(A)) :- swi_io.
goal_expansion(tell(A), system:swi_tell(A)) :- swi_io.
goal_expansion(append(A), system:swi_append(A)) :- swi_io.
goal_expansion(told, system:swi_told).
goal_expansion(telling(A), system:swi_telling(A)) :- swi_io.
goal_expansion(put(A,B),system:swi_put(A,B)) :- swi_io.
goal_expansion(put(A), system:swi_put(A)) :- swi_io.
goal_expansion(skip(A), system:swi_skip(A)) :- swi_io.
goal_expansion(skip(A,B),system:swi_skip(A,B)) :- swi_io.
goal_expansion(get(A), system:swi_get(A)) :- swi_io.
goal_expansion(get(A,B),system:swi_get(A,B)) :- swi_io.
goal_expansion(get0(A,B),system:swi_get0(A,B)) :- swi_io.
goal_expansion(get0(A), system:swi_get0(A)) :- swi_io.
goal_expansion(ttyflush, system:swi_ttyflush).
goal_expansion(prompt(A,B),system:swi_prompt(A,B)) :- swi_io.
goal_expansion(tab(A,B),system:swi_tab(A,B)) :- swi_io.
goal_expansion(tab(A), system:swi_tab(A)) :- swi_io.
					/* Quintus IO */
goal_expansion(byte_count(A,B),system:swi_byte_count(A,B)) :- swi_io.
goal_expansion(character_count(A,B),system:swi_character_count(A,B)) :- swi_io.
goal_expansion(line_count(A,B),system:swi_line_count(A,B)) :- swi_io.
goal_expansion(line_position(A,B),system:swi_line_position(A,B)) :- swi_io.
goal_expansion(open_null_stream(A), system:swi_open_null_stream(A)) :- swi_io.

					/* SWI specific */
goal_expansion(is_stream(A), system:swi_is_stream(A)) :- swi_io.
goal_expansion(set_stream(A,B),system:swi_set_stream(A,B)) :- swi_io.
goal_expansion(with_output_to(A,B),system:swi_with_output_to(A,B)) :- swi_io.
goal_expansion(set_prolog_IO(A,B,C), system:swi_set_prolog_IO(A,B,C)) :- swi_io.
goal_expansion(protocol(A), system:swi_protocol(A)) :- swi_io.
goal_expansion(protocola(A), system:swi_protocola(A)) :- swi_io.
goal_expansion(noprotocol, noprotocol).
goal_expansion(protocolling(A), system:swi_protocolling(A)) :- swi_io.
goal_expansion(prompt1(A), system:swi_prompt1(A)) :- swi_io.
goal_expansion(seek(A,B,C,D),system:swi_seek(A,B,C,D)) :- swi_io.
goal_expansion(wait_for_input(A,B,C), system:swi_wait_for_input(A,B,C)) :- swi_io.
goal_expansion(get_single_char(A), system:swi_get_single_char(A)) :- swi_io.
goal_expansion(read_pending_input(A,B,C), system:swi_read_pending_input(A,B,C)) :- swi_io.
goal_expansion(source_location(A,B),system:swi_source_location(A,B)) :- swi_io.
goal_expansion(copy_stream_data(A,B,C), system:swi_copy_stream_data(A,B,C)) :- swi_io.
goal_expansion(copy_stream_data(A,B),system:swi_copy_stream_data(A,B)) :- swi_io.

					/* SWI internal */
goal_expansion('$push_input_context', system:'swi_$push_input_context').
goal_expansion('$pop_input_context', system:'swi_$pop_input_context').
goal_expansion('$size_stream'(A,B),system:'swi_$size_stream'(A,B)) :- swi_io.

goal_expansion(working_directory(A,B),system:swi_working_directory(A,B)) :- swi_io.
goal_expansion(access_file(A,B),system:swi_access_file(A,B)) :- swi_io.
goal_expansion(size_file(A,B),system:swi_size_file(A,B)) :- swi_io.
goal_expansion(read_link(A,B,C), system:swi_read_link(A,B,C)) :- swi_io.
goal_expansion(tmp_file(A,B),system:swi_tmp_file(A,B)) :- swi_io.
goal_expansion(tmp_file_stream(A,B,C), system:swi_tmp_file_stream(A,B,C)) :- swi_io.
goal_expansion(delete_file(A), delete_file(A)) :- swi_io.
goal_expansion(delete_directory(A), delete_directory(A)) :- swi_io.
goal_expansion(make_directory(A), make_directory(A)) :- swi_io.
goal_expansion(same_file(A,B),system:swi_same_file(A,B)) :- swi_io.
goal_expansion(rename_file(A,B),system:swi_rename_file(A,B)) :- swi_io.
goal_expansion(is_absolute_file_name(A), is_absolute_file_name(A)) :- swi_io.
goal_expansion(file_base_name(A,B),system:swi_file_base_name(A,B)) :- swi_io.
goal_expansion(file_directory_name(A,B),system:swi_file_directory_name(A,B)) :- swi_io.
goal_expansion(prolog_to_os_filename(A,B),system:swi_prolog_to_os_filename(A,B)) :- swi_io.
goal_expansion('$mark_executable'(A), system:'swi_is_absolute_file_name'(A)) :- swi_io.
goal_expansion('$absolute_file_name'(A,B),system:'swi_$absolute_file_name'(A,B)) :- swi_io.


% make sure we also use 
:- user:library_directory(X),
	atom(X),
	atom_concat([X,'/dialect/swi'],SwiDir),
	\+ user:library_directory(SwiDir),
	asserta(user:library_directory(SwiDir)),
	fail
	;
	true.

:- multifile
   user:file_search_path/2.

:- dynamic
   user:file_search_path/2.

user:file_search_path(swi, Home) :-
        current_prolog_flag(home, Home).
user:file_search_path(foreign, swi(ArchLib)) :-
        current_prolog_flag(arch, Arch),
        atom_concat('lib/', Arch, ArchLib).
user:file_search_path(foreign, swi(lib)).


%
% maybe a good idea to eventually support this in YAP.
% but for now just ignore it.
%
load_foreign_library(P,Command) :-
	absolute_file_name(P,[file_type(executable),solutions(first),file_errors(fail)],Lib),
	load_foreign_files([Lib],[],Command).

load_foreign_library(P) :-
	prolog:load_foreign_library(P,install).

:- dynamic loaded/1.
use_foreign_library(A) :-
	loaded(foreign_library(A)), !.
use_foreign_library(A) :-
	load_foreign_library(A),
	assert(loaded(foreign_library(A))).

term_to_atom(Term,Atom) :-
	nonvar(Atom), !,
	atom_codes(Atom,S),
	read_from_chars(S,Term).
term_to_atom(Term,Atom) :-
	write_to_chars(Term,S),
	atom_codes(Atom,S).

concat_atom([A|List], Separator, New) :- var(List), !,
	atom_codes(Separator,[C]),
	atom_codes(New, NewChars),
	split_atom_by_chars(NewChars,C,L,L,A,List).
concat_atom(List, Separator, New) :-
	add_separator_to_list(List, Separator, NewList),
	atomic_concat(NewList, New).


split_atom_by_chars([],_,[],L,A,[]):-
	atom_codes(A,L).
split_atom_by_chars([C|NewChars],C,[],L,A,[NA|Atoms]) :- !,
	atom_codes(A,L),
	split_atom_by_chars(NewChars,C,NL,NL,NA,Atoms).
split_atom_by_chars([C1|NewChars],C,[C1|LF],LAtom,Atom,Atoms) :-
	split_atom_by_chars(NewChars,C,LF,LAtom,Atom,Atoms).

add_separator_to_list([], _, []).
add_separator_to_list([T], _, [T]) :- !.
add_separator_to_list([H|T], Separator, [H,Separator|NT]) :-
	add_separator_to_list(T, Separator, NT).

concat_atom(List, New) :-
	atomic_concat(List, New).


setenv(X,Y) :- unix(putenv(X,Y)).

prolog_to_os_filename(X,X).

is_absolute_file_name(X) :-
	absolute_file_name(X,X).

read_clause(X,Y) :-
	read_term(X,Y,[singetons(warning)]).

string(_) :- fail.

bindings_message(V) -->
       { cvt_bindings(V, Bindings) },
       prolog:message(query(_YesNo,Bindings)), !.

cvt_bindings([],[]).
cvt_bindings([[Name|Value]|L],[AName=Value|Bindings]) :-
	atom_codes(AName, Name),
	cvt_bindings(L,Bindings).

working_directory(OCWD,NCWD) :-
	getcwd(OCWD),
	(var(NCWD) -> true ; cd(NCWD)).

chdir(X) :- cd(X).

% Time is received as int, and converted to "..."
% ctime is a built-in.
convert_time(X,Y) :- swi:ctime(X,Y).

compile_aux_clauses([]).
compile_aux_clauses([(:- G)|Cls]) :-
	prolog_load_context(module, M),
	once(M:G),
	compile_aux_clauses(Cls).
compile_aux_clauses([Cl|Cls]) :-
	prolog_load_context(module, M),
	assert_static(M:Cl),
	compile_aux_clauses(Cls).

'$set_source_module'(Source0, SourceF) :-
	prolog_load_context(module, Source0), !,
	module(SourceF).
'$set_source_module'(Source0, SourceF) :-
	current_module(Source0, SourceF).

'$declare_module'(Name, Context, _, _, _) :-
	add_import_module(Name, Context, start).

'$set_predicate_attribute'(_, _, _).

flag(Key, Old, New) :-
	recorded(Key, Old, R), !,
	(
	 Old \== New
	->
	 erase(R),
	 recorda(Key, New, _)
	;
	 true
	).
flag(Key, 0, New) :-
	functor(Key, N, Ar),
	functor(K, N, Ar),
	assert(flag(K)),
	recorda(K, New, _).

current_flag(Key) :-
	swi:flag(Key).
