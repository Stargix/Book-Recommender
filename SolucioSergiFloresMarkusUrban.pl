/* ******************************************

PROJECTE: Sistema de recomanació de llibres
AUTORS: Markus Urban, Sergi Flores
DATA: 26/12/2023 
ASSIGNATURA: Coneixement i Raonament Automàtics
GRAU: Grau en Intel·ligència Artificial
INSTITUCIÓ: Universitat Politècnica de Catalunya (UPC)

****************************************** */

/* LLIBRES */

/* # títol
   # autor
   # valoració
   # idioma
   # gèneres
   # pàgines
   # editorial
   # publicació
   # espais
   # personatges
*/

/* Importem la base de dades de llibres */

:- dynamic usuari/14.
:- consult(llibressergifloresmarkusurban).
:- consult(usuarissergifloresmarkusurban).
:- initialization(restart).
:- initialization(ruta).
:- encoding(utf8).


/*---------------- ESCRIU LA RUTA DEL FITXER USUARIS A ruta.pl  ----------------*/
/*      (si vols que els nous usuaris quedin guardats al teu fitxer usuaris)  */


ruta :- guardar_usuaris('ruta.pl').     % la ruta ha de ser amb barres / i entre cometes simples

% si es deixa la variable com a 'ruta.pl', el fitxer es guardarà al directori de treball del prolog amb aquest nom

/*----------- GUARDA ELS USUARIS EN UN FITXER A PART -----------*/

guardar_usuaris(Ruta) :-
    tell(Ruta),   
    listing(usuari/14),         
    told.

/* Usuaris del sistema */ 

/*---------------- FUNCIONS DEL PROGRAMA ----------------*/


/* Classifica segons la puntuaciació mínima dels crítics que desitja l'usuari */

califica(Recomanacio,Punt_2) :-
    llibre(Recomanacio, _,Calificacio_llibre,_,_,_,_,_,_,_),
    Punt_2 is Calificacio_llibre - 2.


/* Classificació per preferència de pàgines */

pagines(Nom_usuari, Recomanacio,Punt_5) :-
    (usuari(Nom_usuari, _,_,_,_,_,[_,Pagines_usuari_min,_,Pagines_usuari_max],_,_,_,_,_,_,_),
    llibre(Recomanacio, _,_,_,_,_,Pagines_llibre,_,_,_),
    Pagines_usuari_max > Pagines_llibre,
    Pagines_llibre > Pagines_usuari_min,
    Punt_5 = 1); Punt_5 = 0.

/* Classificació per preferència d'antiguitat */

any_llibre(Nom_usuari, Recomanacio,Punt_4) :-
    (usuari(Nom_usuari, _,_,_,_,[_,Any_usuari_min,_,Any_usuari_max],_,_,_,_,_,_,_,_),
    llibre(Recomanacio, _,_,_,_,_,_,_,Any_llibre,_),
    Any_llibre > Any_usuari_min,
    Any_llibre < Any_usuari_max,
    Punt_4 = 1); Punt_4 = 0.


/* Filtre d'autors no desitjats */

autor_no(Nom_usuari, Recomanacio) :-
    usuari(Nom_usuari, _,_,_,_,_,_,_,Autors_usuari,_,_,_,_,_),
    llibre(Recomanacio, Autor_llibre,_,_,_,_,_,_,_,_),
    \+ member(Autor_llibre,Autors_usuari).


/* Filtre de gèneres no desitjats */

gen_no(Nom_usuari, Recomanacio) :-
    usuari(Nom_usuari,_,_,_,_,_,_,_,_,_,_,_,Generes_no,_),
    llibre(Recomanacio,_,_,_,Generes_llibre,_,_,_,_,_),
    forall(member(Gen, Generes_no), \+ member(Gen, Generes_llibre)).


/* Filtre de llocs no desitjats */

lloc_no(Nom_usuari, Recomanacio) :-
    usuari(Nom_usuari,_,_,_,_,_,_,Lloc_usuari,_,_,_,_,_,_),
    llibre(Recomanacio,_,_,_,_,_,_,_,_,Lloc_llibre),
    forall(member(Lloc, Lloc_usuari), \+ string_in_list(Lloc, Lloc_llibre)).


/* Separació per d'Edat */

genere_edat(Edat, X,Y) :- Edat =< 12, X = 'Childrens',Y= 'School',!.
genere_edat(Edat, X,Y) :- Edat =< 18, X = 'Young Adult', Y ='Middle Grade',!.
genere_edat(Edat, X,Y) :- Edat =< 25, X = 'Young Adult', Y ='Adult',!.
genere_edat(_, 'Adult','College').


age(Nom_usuari, Recomanacio,Punt_3) :-
    (usuari(Nom_usuari,_,_,Edat,_,_,_,_,_,_,_,_,_,_),
    llibre(Recomanacio,_,_,_,Generes_llibre,_,_,_,_,_),
    ((genere_edat(Edat,Rang_edat,Rang_2),Punt_3 = 1,
    (member(Rang_edat,Generes_llibre);
    member(Rang_2,Generes_llibre)));
    \+ (member('Young Adult',Generes_llibre);                           % En el cas que no hi hagi cap característica
    member('Adult',Generes_llibre);                                     % sobre edat, no es té en compte aquest apartat
    member('Childrens',Generes_llibre)),Punt_3 = 0.5)); Punt_3 = 0.

/* Generes en comú, en funció de Num_generes_sel*/

generes(Nom_usuari,Recomanacio,Longitut_gustos) :-
    usuari(Nom_usuari,_,_,_,Generes_usuari,_,_,_,_,_,_,_,_,_),
    llibre(Recomanacio,_,_,_,Generes_llibre,_,_,_,_,_),
    intersection(Generes_usuari, Generes_llibre, Generes_comuns),
    length(Generes_comuns, Longitut_gustos),
    Longitut_gustos > 1.


/* Classificació per idiomes */

idiomes(Nom_usuari, Recomanacio) :-
    usuari(Nom_usuari,_,_,_,_,_,_,_,_,Idiomes_usuari,_,_,_,_),
    llibre(Recomanacio,_,_,Idioma_llibre,_,_,_,_,_,_),
    
    (member("English", Idiomes_usuari), Idioma_llibre = "English"
    ; member("Spanish", Idiomes_usuari), Idioma_llibre = "Spanish"
    ; member("German", Idiomes_usuari), Idioma_llibre = "German"
    ; member("French", Idiomes_usuari), Idioma_llibre = "French").


/* Funció auxiliar: ens permet determinar si un text és dins d'un element de la llista */

string_in_list(String, List) :-
    member(Element, List), % mirem els membres de la llista
    sub_string(Element,_,_,_,String). % comprovem que continguin el substring


/* Classificació per lloc de l'acció */

lloc_accio(Nom_usuari, Recomanacio,Punt_6) :-
    (usuari(Nom_usuari,_,_,_,_,_,_,_,_,_,_,Llocs_usuari,_,_),
    llibre(Recomanacio,_,_,_,_,_,_,_,_,Llocs_llibre),
    member(Lloc_individual, Llocs_usuari),
    string_in_list(Lloc_individual, Llocs_llibre),
    Punt_6 = 1); Punt_6 = 0.
    % evitar repeticions


/* Classificació per autors que es vulguin prioritzar */

autor_bons(Nom_usuari, Recomanacio,Punt_7) :-
    (usuari(Nom_usuari,_,_,_,_,_,_,_,_,_,Autors_usuari,_,_,_),
    llibre(Recomanacio, Autor_llibre,_,_,_,_,_,_,_,_),
    member(Autor_llibre,Autors_usuari), Punt_7 = 1); Punt_7 = 0.


/*---------------- SISTEMA DE RECOMANACIÓ ----------------*/

output(Nom_usuari) :- 
    usuari(Nom_usuari,_,_,_,_,_,_,_,_,_,_,_,_,_),

    elimina_duplicats(Nom_usuari, Recomanacions_ordenades),
    list_to_set(Recomanacions_ordenades, Recomanacions_no_duplicades),
    
    length(Recomanacions_no_duplicades,Longitud),
    Longitud > 0 ->
        (write("   Vols veure informació dels criteris de recomanació? (si/no): "), read(Resposta),nl,
        
        writeln("   Alguns llibres que et podrien agradar són: "), nl,nl,
        si_no_imprimir(Resposta,Recomanacions_no_duplicades,5,Nom_usuari),nl);                          % el 5 són el nombre de llibres que imprimeix
        write("   No s'ha trobat cap llibre que es pugui adaptar a les teves preferències"), nl,nl;
        write("   No s'ha trobat cap llibre que es pugui adaptar a les teves preferències"), nl,nl.

si_no_imprimir(X,Recomanacions_no_duplicades,Nombre_llibres,Nom_usuari) :-
    X = si -> imprimir_primers(Recomanacions_no_duplicades,Nombre_llibres,1,[],Nom_usuari);
    imprimir_clean(Recomanacions_no_duplicades,Nombre_llibres,1,[],Nom_usuari).


/* Elimina els duplicats de les recomanacions, els ordena per puntuació de gran a petit
   i els hi treu la puntuació associada durant el procés */

elimina_duplicats(Nom_usuari, Recomanacions_ordenades) :-
    setof(Puntuacio-Recomanacio, llibres_nous(Nom_usuari, Recomanacio, Puntuacio), Recomanacions_petit_gran),
    reverse(Recomanacions_petit_gran, Recomanacions_gran_petit),
    treure_puntuacio(Recomanacions_gran_petit, Recomanacions_ordenades).

treure_puntuacio([], []).
treure_puntuacio([_-Recomanacio|Residu], [Recomanacio|Residu_sense_puntuacio]) :-
    treure_puntuacio(Residu, Residu_sense_puntuacio).

/* Imprimeix la llista de llibres, associa cada llibre a un número i pregunta si es vol més informació */
/*------------- IMPRIMEIX LA LLISTA AMB TOTA LA INFORMACIÓ ADDICIONAL DE LA RECOMANACIÓ -------------*/

imprimir_primers([Recomanacio|Cua], N,Contador,Llista_num_llibres,Nom_usuari) :-
    N > 0,
    usuari(Nom_usuari,_,_,Edat,Generes_usuari,[_,Any_min,_,Any_max],[_,Pag_min,_,Pag_max],_,_,_,Autor_usr,Lloc_usr,_,Repetits),
    llibre(Recomanacio,Autor_llibre,Puntuacio,_,Generes_llibre,_,Pag_llibre,_,Any_llibre,Lloc_llibre),
    intersection(Generes_usuari, Generes_llibre, Generes_comuns),
    (\+ member(Recomanacio,Repetits) -> retract(usuari(Nom_usuari, A, B, C, D, E, F, G, H, I, J, K, L, Repetits)),
    assertz(usuari(Nom_usuari, A, B, C, D, E, F, G, H, I, J, K, L, [Recomanacio|Repetits])),ruta; true),
    write(" "),write(Contador),write('.'),
    write(Recomanacio),nl,nl,
    write("   Gèneres en comú: "),write(Generes_comuns),nl,nl,length(Generes_comuns,Punt6),

    write("   Puntuació dels crítics: "),write(Puntuacio),nl,nl,
    
    write("   El llibre interessa a gent de "),write(Edat), edat_si_no(Generes_llibre,Edat,Punt5),nl,nl,

    write("   Pàgines: "),write(Pag_llibre), write(", està en el rang de l'usuari? "),
    write("("),write(Pag_min),write("-"),write(Pag_max), write("): "),
    min_max(Pag_min,Pag_max,Pag_llibre,Punt1),nl,nl,

    write("   Data de publicació: "), write(Any_llibre),write(", està en el rang de l'usuari? "),
    write("("),write(Any_min),write("-"),write(Any_max),write("): "),
    min_max(Any_min,Any_max,Any_llibre,Punt2),

    (Lloc_usr \= [] -> 
        nl,nl,write("   Conté ubicacions de preferència? "), 
        ubi_si_no(Lloc_llibre,Lloc_usr,Punt3); Punt3 = 0),
    
    (Autor_usr \= [] -> 
        nl,nl,write("   Conté autors de preferència? "), 
        autor_si_no(Autor_llibre,Autor_usr,Punt4); Punt4 = 0),

    Punts is Punt1 + Punt2 + Punt3 + Punt4 + Punt5 + Punt6 + Puntuacio - 2,
    Punts_bons is round(Punts * 100) / 100,

    nl,nl,write("   Puntació global: "),write(Punts_bons),

    nl,nl,nl,
    N1 is N - 1,
    N2 is Contador + 1,
    
    imprimir_primers(Cua, N1, N2, [Contador, Recomanacio|Llista_num_llibres],Nom_usuari);
    pregunta_mes_info(Llista_num_llibres).

    imprimir_primers([],_,_,Llista_num_llibres,_) :-
        pregunta_mes_info(Llista_num_llibres).

/*------------- IMPRIMIR SENSE INFORMACIÓ ADDICIONAL -------------*/

imprimir_clean([],_,_,Llista_num_llibres,_) :-
    pregunta_mes_info(Llista_num_llibres).

imprimir_clean([Recomanacio|Cua], N ,Contador,Llista_num_llibres,Nom_usuari) :-
    (N > 0,
    usuari(Nom_usuari,_,_,_,_,_,_,_,_,_,_,_,_,Repetits),

    (\+ member(Recomanacio,Repetits) -> retract(usuari(Nom_usuari, A, B, C, D, E, F, G, H, I, J, K, L, Repetits)),
    assertz(usuari(Nom_usuari,A,B,C,D,E,F,G,H,I,J,K,L,[Recomanacio|Repetits])),ruta; true),

    write(" "),write(Contador),write('.'),
    write(Recomanacio),nl,nl,
    N1 is N - 1,
    N2 is Contador + 1,
    imprimir_clean(Cua, N1, N2, [Contador, Recomanacio|Llista_num_llibres],Nom_usuari));
    imprimir_clean([],_,_, Llista_num_llibres,Nom_usuari).


/*------------- FUNCIONS PER IMPRIMIR LA INFORMACIÓ ADDICIONAL -------------*/

pregunta_mes_info(Llista_num_llibres) :-
    (write("   Vols més informació d'algun llibre? (si/no): "), read(Si_no),nl,
    (Si_no = si ->
    write("   De quin llibre en vols més? (escriu el número): "), read(Num_mes_info),nl,
    dona_info(Llista_num_llibres,Num_mes_info),nl,nl,
    pregunta_mes_info(Llista_num_llibres);!)).

min_max(Min,Max,Llibre,Punt_4) :-
    ((Min < Llibre,
    Max > Llibre) -> 
        Punt_4 = 1,write("Sí"));
        Punt_4 = 0,write("No").

edat_si_no(Llista_generes,Edat,Punt_1) :-
    genere_edat(Edat,Valor1,Valor2),
    write(" anys? "),
    (member(Valor1,Llista_generes);
    member(Valor2,Llista_generes)) -> write("Sí"),Punt_1 = 1; 

    \+ (member('Young Adult',Llista_generes);                           % En el cas que no hi hagi cap característica
    member('Adult',Llista_generes);                                     % sobre edat, ho deixem en potser
    member('Childrens',Llista_generes)) -> 
        write("Potser"),Punt_1 = 0.5;write("No"),Punt_1 = 0.

ubi_si_no(Lloc_llibre,Lloc_usr,Punt_2) :-
    (member(Lloc_individual, Lloc_usr),
    string_in_list(Lloc_individual, Lloc_llibre)) -> 
        write("Sí: "),write(Lloc_individual),Punt_2 = 1; write("No"),Punt_2 = 0.

autor_si_no(Lloc_llibre,Lloc_usr,Punt_3) :-
    (member(Lloc_llibre, Lloc_usr)) -> 
        write("Sí: "),write(Lloc_llibre),Punt_3 = 1; write("No"), Punt_3 = 0.

    
/* Imprimeix més informació del llibre seleccionat */

dona_info([Numero,Recomanacio|Cua],Num_mes_info) :-
    llibre(Recomanacio,Autor,Puntuacio,Idioma,Generes,_,Pagines,Editor,Any,_),
    Numero = Num_mes_info,nl,
    write("   "), write(Recomanacio),nl,nl,
    write("   Autor: "), write(Autor),nl,nl,
    write("   Puntuació: "), write(Puntuacio),nl,nl,
    write("   Idioma: "), write(Idioma),nl,nl,
    write("   Pàgines: "), write(Pagines),nl,nl,
    write("   Any de publicació: "), write(Any),nl,nl,
    write("   Editorial: "), write(Editor),nl,nl,
    write("   Gèneres: "), write(Generes),nl;
    dona_info(Cua,Num_mes_info).


/* Restriccions */

recomana(Nom_usuari, Recomanacio,Puntuacio) :-
        idiomes(Nom_usuari, Recomanacio),
        autor_no(Nom_usuari, Recomanacio),
        gen_no(Nom_usuari, Recomanacio),                    % Filtren la base de dades eliminant els llibres que no poden ser recomanats per usuari
        lloc_no(Nom_usuari, Recomanacio),

        generes(Nom_usuari, Recomanacio, Punt_1),           % Punt 1 = Nombre de gèneres, ha de ser >= a 1
        califica(Recomanacio, Punt_2),                      % Punt 2 = puntuació dels crítics - 2 (per no tenir puntuacions massa altes quan es mostra, tot i que és indiferent)
        age(Nom_usuari, Recomanacio, Punt_3),               % Punt 3 = 1 si hi ha algun gènere que concordi amb edat, 0.5 si no se sap i 0 si concorda amb una edat diferent
        any_llibre(Nom_usuari, Recomanacio, Punt_4),        % Punt 4 = 1 si es troba dins el rang, 0 si no es troba
        pagines(Nom_usuari, Recomanacio, Punt_5),           % Punt 5 = 1 si es troba dins el rang, 0 si no es troba
        lloc_accio(Nom_usuari, Recomanacio,Punt_6),         % Punt 5 = 1 si algun lloc de les preferències es troba al llibre, 0 si no
        autor_bons(Nom_usuari, Recomanacio,Punt_7),         % Es mira la puntuació global a partir dels filtres anteriors
        
        Puntuacio is Punt_1 + Punt_2 + Punt_3 + Punt_4 + Punt_5 + Punt_6 + Punt_7.  

llibres_nous(Nom_usuari, Recomanacio,Puntuacio):-
    recomana(Nom_usuari, Recomanacio,Puntuacio),
    usuari(Nom_usuari,_,_,_,_,_,_,_,_,_,_,_,_,Llista_repetits),
    llibre(Recomanacio,_,_,_,_,_,_,_,_,_),
    \+ member(Recomanacio,Llista_repetits).


/* MODE BATCH */

% Extreure els primers 5 elements de la llista

cinc_primers(L) :-
    length(L, Len),
    
    open('resultats_batch.pl', append, Stream),
    
    (Len >= 5 ->
        length(FirstFive, 5),
        append(FirstFive, _, L),
        write(Stream, FirstFive);
        
        write(Stream, L)),
    
    write(Stream, '}'),
    nl(Stream),
    nl(Stream),
    close(Stream).

% Re-implementació de la funció recomanadora estàndard. El nombre de llibres queda prefixat
% per evitar la interacció directa

output_batch(Nom_usuari) :- 
    
    elimina_duplicats(Nom_usuari, Recomanacions_ordenades),
    list_to_set(Recomanacions_ordenades, Recomanacions_no_duplicades),
    
    length(Recomanacions_no_duplicades,Longitud),
    Longitud > 0 ->
        
        cinc_primers(Recomanacions_no_duplicades);

        open('resultats_batch.pl',append,Stream),
        write(Stream, "[]}"),
        nl(Stream),
        nl(Stream),
        close(Stream).


% Veure el directori de treball Prolog

directori_fitxer :-
    working_directory(Carpeta, Carpeta),nl,
    write("   El fitxer de recomanacions s'ha guardat al directori "),nl,nl,write("   "), write(Carpeta), nl,nl.


batch :-
    findall(Nom_usuari, usuari(Nom_usuari,_,_,_,_,_,_,_,_,_,_,_,_,_), Usuaris_repetits),
    list_to_set(Usuaris_repetits, Usuaris),
    imprimir_usuaris_batch(Usuaris),
    directori_fitxer.


% Pas base (llista buida)
imprimir_usuaris_batch([]).

% Pas recursiu (recomanar per a cada usuari)
imprimir_usuaris_batch([Usuari_1|Cua]) :-
    
    open('resultats_batch.pl',append,Stream),
    write(Stream, '{nom_usuari: "'),
    write(Stream, Usuari_1),
    write(Stream, '", llibres_recomanats: '),
    close(Stream),

    output_batch(Usuari_1),

    % Crida recursiva (amb la cua)
    imprimir_usuaris_batch(Cua).


/*---------------- COMANDES DEL SISTEMA ----------------*/

/* Ajuda a l'usuari */

help :-

write("
      ,   ,
     /////|   FILTRA TOTS ELS LLIBRES PER:
    ///// |      
   |===|  |   {busca('x')} -> entre cometes simples        
   | h |  |   
   | e |  |   lloc
   | l |  |   autor      
   | p | /   gènere
   |===|/   personatge     
   '---'    

"),
    writeln("   {help} -> mostra les comandes"),nl,
    writeln("   {start} -> comença el programa,"),nl,
    writeln("   {crear} -> crea el teu propi usuari"),nl,
    writeln("   {usuaris} -> llista tots els usuaris"),nl,
    writeln("   {batch} -> processar múltiples usuaris"),nl,
    writeln("   {busca('x')} -> llista els llibres que tinguin x"),nl,nl.


busca(Busca) :-
    findall(Recomanacio, ciutat(Recomanacio, Busca), RecomCiutat),
    findall(Recomanacio, personatges(Recomanacio, Busca), RecomPersonatge),
    findall(Recomanacio, autors(Recomanacio, Busca), RecomAutor),
    findall(Recomanacio, genere_busca(Recomanacio, Busca), RecomGen),

    append([RecomCiutat, RecomPersonatge, RecomAutor,RecomGen], RecomTotal),
    list_to_set(RecomTotal, RecomNoRepe),nl,
    
    imprimir_llibres(RecomNoRepe).

ciutat(Recomanacio, Ciutat) :-
    llibre(Recomanacio,_,_,_,_,_,_,_,_,LlistaCiutats),
    string_in_list(Ciutat, LlistaCiutats).

genere_busca(Recomanacio, Genere) :-
    llibre(Recomanacio,_,_,_,Llista_gen,_,_,_,_,_),
    member(Genere, Llista_gen).

personatges(Recomanacio, Personatge) :-
    llibre(Recomanacio,_,_,_,_,LlistaPersonatges,_,_,_,_),
    member(Personatge, LlistaPersonatges).

autors(Recomanacio, Autor) :-
    llibre(Recomanacio,Autor,_,_,_,_,_,_,_,_).

imprimir_llibres([]).
imprimir_llibres([Cap|Cua]) :-
    write(' - '),
    write(Cap),nl,nl,
    imprimir_llibres(Cua).


/* Llista tots els usuaris, amb el seu nom i cognom */

usuaris :-
    
    findall(Nom_usuari, usuari(Nom_usuari,_,_,_,_,_,_,_,_,_,_,_,_,_), Usuari_1),nl,
    imprimir_usuaris(Usuari_1,1,[]).

imprimir_usuaris([Usuari_1|Cua_1], Contador,Llista_num_usr) :-
    (usuari(Usuari_1,Nom_2,Cognom_3,_,_,_,_,_,_,_,_,_,_,_),
    write(" "),write(Contador),write('.'),
    write(Usuari_1), write(": "),write(Nom_2), write(" "), write(Cognom_3), nl,nl,

    N is Contador + 1,
    imprimir_usuaris(Cua_1,N,[Contador, Usuari_1|Llista_num_usr])).

imprimir_usuaris([], _, Llista_num_usr) :-
    pregunta_mes_usr(Llista_num_usr).

pregunta_mes_usr(Llista_num_usr) :-
    (write("   Vols més informació d'algun usuari? (si/no): "), read(Si_no),nl,
    (Si_no = si ->
    write("   De quin usuari en vols més? (escriu el número): "), read(Num_mes_info),nl,
    dona_info_usr(Llista_num_usr,Num_mes_info),nl,nl,
    pregunta_mes_usr(Llista_num_usr);!)).

dona_info_usr([Numero,Usuari|Cua],Num_mes_info) :-
    usuari(Usuari,Nom,Cognom,Edat,Generes_pref,[_,Any_min,_,Any_max],[_,Pag_min,_,Pag_max],Ubi_no,Autors_no,Idiomes,Autors_si,Ubi,Generes_no,Recom),
    Numero = Num_mes_info,nl,
    write("   "), write(Usuari),write(": "),write(Nom), write(" "), write(Cognom),nl,nl,
    write("   Edat: "), write(Edat),nl,nl,
    write("   Idiomes: "), write(Idiomes),nl,nl,
    write("   Gèneres preferits: "), write(Generes_pref),nl,nl,
    write("   Gèneres que no vol: "), write(Generes_no),nl,nl,
    write("   Rang de pàgines: "), write('('),write(Pag_min-Pag_max),write(')'),nl,nl,
    write("   Rang d'anys de publicació: "), write('('),write(Any_min-Any_max),write(')'),nl,nl,
    write("   Autors preferits: "), write(Autors_si),nl,nl,
    write("   Autors que no vol: "), write(Autors_no),nl,nl,
    write("   Llocs preferits: "), write(Ubi),nl,nl,
    write("   Llocs que no vol: "), write(Ubi_no),nl,nl,
    write("   Llibres recomanats: "), write(Recom),nl,nl;
    dona_info_usr(Cua,Num_mes_info).

restart :-	

    write("
       _______
      /      /,  
     /      //   SISTEMA RECOMANADOR DE LLIBRES
    /______//    Desenvolupat per Markus Urban i Sergi Flores  
   (______(/

    "), nl,

    writeln("   {help} -> mostra més comandes"),nl,
    writeln("   {start} -> comença el programa"),nl,
    writeln("   {crear} -> crea el teu propi usuari"),nl,
    writeln("   {usuaris} -> llista tots els usuaris"),nl,
    writeln("   {batch} -> processar múltiples usuaris"),nl,
    writeln("   {busca('x')} -> llista els llibres que tinguin x"),nl,nl.
    
/* Inicia la recomanació de llibres */

start :-
    nl,
    write("
   (\\ 
   \\'\\ 
   \\'\\    __________  
   / '|  ()_________)
   \\ '/   \\ ~~~~~~~~ \\
    \\      \\ ~~~~~~   \\
    ==).     \\__________\\
    (__)      ()__________)
"),nl,

write("   Escriu el teu nom d'usuari: "),
read(Nom_usuari), nl,

(usuari(Nom_usuari, N,_,_,_,_,_,_,_,_,_,_,_,_) -> login(N), output(Nom_usuari) ; resposta_si_no).

login(Nom) :-
    write("   Hola de nou, "),
    write(Nom), nl,nl.

/* Fa una pregunta si respons si, ignora en els altres casos */

    resposta_si_no :-
        write("   Aquest usuari no existeix, vols crear un compte nou? (si/no): "),
        read(X),
        X == si -> nl,crear; 
        start.


/*----------- FUNCIONS PEL FUNCIONAMENT DE CREA -----------*/

/* Transforma llistes de lletres [a,b,c] en la llista de gèneres respectius ['Adventure',...] */

llegir_lletres(Llista_resultat,Base):-

    read_line_to_codes(user_input, Codis),
    eliminar_punts(Codis, NoPunt),
    string_codes(Input, NoPunt),
    atomic_list_concat(Lletres, ',', Input),
    lletres_a_generes(Lletres, Llista_resultat,Base).
    
lletres_a_generes([], [],_).
lletres_a_generes([Lletra | RestaLletres], [Genere | RestaGeneres],Base) :-

    ((Base = idioma ->
        lletra_idm(Lletra, Genere)); 
    (Base = tipus ->
        lletra_tps(Lletra, Genere));
    lletra_gen(Lletra, Genere)),
    lletres_a_generes(RestaLletres, RestaGeneres,Base).


/* Elimina els punts de la llista de codis ASCII dels inputs, així no dona errors al processar les cadenes de text */

eliminar_punts([], []).
eliminar_punts([46|Cua], NoPunts) :- % 46 és el codi ASCII pel punt '.'
    !,
    eliminar_punts(Cua, NoPunts).
eliminar_punts([Cap|Cua], [Cap|NoPunts]) :-
    eliminar_punts(Cua, NoPunts).


/* Torna a preguntar el nom d'usuari si aquest ja existeix */

pregunta_usuari(Nom_usuari) :-
    repeat,
    write("   1. Escriu un nom d'usuari (minúscules): "),
    read(Nom_usuari), nl,
        (usuari(Nom_usuari,_,_,_,_,_,_,_,_,_,_,_,_,_) ->
        write("   Aquest usuari ja existeix, escull un altre nom"), nl, nl,
        fail;true,!).


/* En el cas que es vulgui eliminar un autor et fa una llista, sinó retorna una llista buida */

resposta_eliminats(X, Ban,Text,Els) :-
        read_line_to_codes(user_input, _),                   % neteja el buffer
        (X == si,
        writeln("   (Separats per comes)"),nl,
        write("   Escriu "),write(Els),write(" que"),write(Text),write("vulguis: "), 

        read_line_to_codes(user_input, Codis),
        eliminar_punts(Codis, NoPunt),
        string_codes(Input, NoPunt),
        atomic_list_concat(Ban, ',', Input),                  % Treu els espais i comes
        nl);

        Ban = [].


/* En el cas que l'input sigui una variable, el transforma en un àtom (li posa cometes) */

posar_cometes(Atom) :-                           
    (read_line_to_codes(user_input, Codis),
    eliminar_punts(Codis, NoPunt),
    atom_string(Atom, NoPunt)).
   
generes_no(Generes_no) :-
    repeat,
    (write("   Escriu els gèneres que no vulguis (separats per comes): "), 

    (llegir_lletres(Generes_no,generes),nl ->  true;   
    nl,write("   (Ingressa un gènere vàlid)"), nl,nl,fail),!).

/*----------- FUNCIÓ PER LA CREACIÓ D'USUARIS -----------*/

crear :-
    nl,write("   CREA UN COMPTE NOU"), nl, nl, 
    pregunta_usuari(Nom_usuari),
    read_line_to_codes(user_input, _),                   % neteja el buffer

    write("   2. Escriu el teu nom: "),
    posar_cometes(Nom),nl,                      % Transorma les variables: Pere --> 'Pere' a àtoms constants

    write("   3. Escriu el teu cognom: "),
    posar_cometes(Cognom),nl,
    
    repeat,
    write("   4. Escriu la teva edat: "),
    read(Edat),

    (number(Edat)->  nl;
    nl,write("   (Ingressa un valor vàlid)"), nl,nl,fail),!,

    read_line_to_codes(user_input, _),                          % neteja el buffer
    write("   5. Escriu els idiomes que vols llegir: "),nl,nl,
    write("   [an] Anglès        [al] Alemany"),nl,
    write("   [es] Espanyol      [fr] Francès"),nl,nl,

    repeat,
    
    write("   Escriu-los separats per comes sense espais: "),
    
    (llegir_lletres(Idiomes,idioma),nl ->  true; 
    nl,write("   (Ingressa un idioma vàlid)"), nl,nl,fail),!,
    
    write("   6. Quins tipus de llibre t'agraden? : "),nl,nl,
    write("   [nv] Noveles       [te] Teatre"),nl,
    write("   [cl] Clàssics      [bg] Biografies"),nl,
    write("   [po] Poesia        [cc] Contes curts"),nl,
    write("   [fa] Faules        [al] Audiollibres"),nl,nl,

    repeat,
    write("   Escriu-los separats per comes sense espais: "),
     
    (llegir_lletres(Tipus_llibre,tipus),nl ->  true;   
    nl,write("   (Ingressa un gènere vàlid)"), nl,nl,fail),!,
    
    write("   7. Selecciona els teus preferits:"),nl,nl,
    write("   [a] Aventura            [n] No ficticia"),nl,
    write("   [b] Ficció              [ñ] Religió"),nl,
    write("   [c] Ciencia-Ficció      [o] Drama"),nl,
    write("   [ç] Crim                [p] Paranormal"),nl,
    write("   [d] Distòpia            [q] Filosofia"),nl,
    write("   [e] Èpica               [r] Romanç"),nl,
    write("   [f] Fantasia            [s] Suspens"),nl,
    write("   [g] Gòtic               [t] Thriller"),nl,
    write("   [h] Històric            [u] Urbà"),nl,
    write("   [i] Contemporani        [v] Vampirs"),nl,
    write("   [j] Juvenil             [w] Màgia"),nl,
    write("   [k] Comèdia             [x] Ficció històrica"),nl,
    write("   [l] literatura          [y] Humor"),nl,
    write("   [m] Misteri             [z] LGBT"),nl,nl,

    repeat,
    write("   Escriu els teus preferits (separats per comes sense espais): "),
    
    (llegir_lletres(Generes_tematics,generes),nl ->  true;   
    nl,write("   (Ingressa un gènere vàlid)"), nl,nl,fail),!,

    append(Generes_tematics, Tipus_llibre, Generes),
    
                           % neteja el buffer
    write("   Hi ha algun gènere que no vulguis recomanat? (si/no): "), 
    read(Gen_si_no),nl,
    read_line_to_codes(user_input, _),   
    
    (Gen_si_no = si -> generes_no(Generes_no); true),

    repeat,
    write("   8. Selecciona el MÍNIM de pagines que vulguis que tingui el llibre: "), 
    read(Min_pag),nl,

    (number(Min_pag) ->  true;
    write("   (Ingressa un valor vàlid)"), nl,nl,fail),!,

    repeat,
    write("   9. Selecciona el MÀXIM de pagines que vulguis que tingui el llibre: "), 
    read(Max_pag),nl,
    (number(Max_pag) ->  true;
    write("   (Ingressa un valor vàlid)"), nl,nl,fail),!,

    repeat,
    write("   10. A partir de quin any vols que s'hagin publicat els llibres "), 
    read(Min_any),nl,
    (number(Min_any) ->  true;
    write("   (Ingressa un valor vàlid)"), nl,nl,fail),!,

    repeat,
    write("   11. Selecciona l'any màxim de publicaciò que vulguis en els llibres: "), 
    read(Max_any),nl,
    (number(Max_any) ->  true;
    nl,write("   (Ingressa un valor vàlid)"), nl,nl,fail),!,

    write("   12. Vols afegir alguna ubicació que tingui més preferència? (si/no): "),
    read(Resposta_ciutat),nl,
    resposta_eliminats(Resposta_ciutat, Ciutat_ban," ","les"),

    write("   13. Vols afegir alguna ubicació que no surti recomanada? (si/no): "),
    read(Resposta_ciutat_ban),nl,
    resposta_eliminats(Resposta_ciutat_ban, Ciutat," no ","les"),

    write("   14. Vols afegir algun autor que tingui més preferència? (si/no): "),
    read(Resposta_personatge),nl,
    resposta_eliminats(Resposta_personatge, Personatge_ban," ","els"),

    write("   15. Hi ha algun autor que no vulguis que et surti recomanat? (si/no): "),
    read(Resposta_autors),nl,
    resposta_eliminats(Resposta_autors, Autors_ban," no ","els"),

    

    

    assertz(usuari(Nom_usuari, Nom, Cognom, Edat, Generes, [posteriors, Min_any, anteriors, Max_any], 
    [extensio_min,Min_pag,extensio_max,Max_pag],Ciutat, Autors_ban,Idiomes,Personatge_ban,Ciutat_ban,Generes_no,[])),
    /*
    fitxer(usuari(Nom_usuari, Nom, Cognom, Edat, Generes, [posteriors, Min_any, anteriors, Max_any],
    [extensio_min,Min_pag,extensio_max,Max_pag],Valoracio, Autors_ban,Idiomes,Personatge_ban,Ciutat_ban,Num_generes_sel,[])),
    */
    nl, ruta,

    writeln("   Usuari creat amb èxit"), nl.


/*----------- MINI BASE DE DADES AMB LES RELACIONS ENTRE LLETRES I GENERES O IDIOMES -----------*/

lletra_idm(an, "English").
lletra_idm(al, "German").
lletra_idm(es, "Spanish").
lletra_idm(fr, "French").

lletra_tps(nv, 'Novels').
lletra_tps(cl, 'Classics').
lletra_tps(po, 'Poetry').
lletra_tps(fa, 'Animals').
lletra_tps(te, 'Plays').
lletra_tps(bg, 'Biography').
lletra_tps(cc, 'Short Stories').
lletra_tps(al, 'Audiobook').

lletra_gen(a, 'Adventure').
lletra_gen(b, 'Fiction').
lletra_gen(c, 'Science Fiction').
lletra_gen(d, 'Dystopia').
lletra_gen(e, 'Epic Fantasy').
lletra_gen(f, 'Fantasy').
lletra_gen(g, 'Gothic').
lletra_gen(h, 'Historical').             
lletra_gen(i, 'Contemporary').
lletra_gen(j, 'Juvenile').
lletra_gen(k, 'Comedy').                   
lletra_gen(l, 'Literature').                
lletra_gen(n, 'Nonfiction').         
lletra_gen(o, 'Drama').
lletra_gen(p, 'Paranormal').
lletra_gen(q, 'Philosophy').
lletra_gen(r, 'Romance').
lletra_gen(s, 'Suspense').
lletra_gen(t, 'Thriller').
lletra_gen(u, 'Urban Fantasy').
lletra_gen(v, 'Vampires').
lletra_gen(w, 'Magic').
lletra_gen(x, 'Historical Fiction').
lletra_gen(y, 'Humor').
lletra_gen(z, 'LGBT'). 
lletra_gen(ñ, 'Religion').
lletra_gen(ç, 'Crime'). 
lletra_gen(m, 'Mystery'). 
   
