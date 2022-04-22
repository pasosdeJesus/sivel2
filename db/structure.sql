SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: es_co_utf_8; Type: COLLATION; Schema: public; Owner: -
--

CREATE COLLATION public.es_co_utf_8 (provider = libc, locale = 'es_CO.UTF-8');


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: completa_obs(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.completa_obs(obs character varying, nuevaobs character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
      BEGIN
        RETURN CASE WHEN obs IS NULL THEN nuevaobs
          WHEN obs='' THEN nuevaobs
          WHEN RIGHT(obs, 1)='.' THEN obs || ' ' || nuevaobs
          ELSE obs || '. ' || nuevaobs
        END;
      END; $$;


--
-- Name: divarr(anyarray); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.divarr(in_array anyarray) RETURNS SETOF text
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT ($1)[s] FROM generate_series(1,array_upper($1, 1)) AS s;
$_$;


--
-- Name: edad_de_fechanac(integer, integer, integer, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.edad_de_fechanac(anionac integer, mesnac integer, dianac integer, fechahecho date) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
	aniohecho INTEGER = EXTRACT(year FROM fechahecho);
	meshecho INTEGER = EXTRACT(month FROM fechahecho);
	diahecho INTEGER = EXTRACT(day FROM fechahecho);
	na INTEGER;
BEGIN
	na = CASE WHEN anionac IS NULL OR aniohecho IS NULL THEN 
		NULL
	ELSE
		aniohecho - anionac
	END;
	na = CASE WHEN mesnac IS NOT NULL AND meshecho IS NOT NULL AND 
		mesnac > meshecho OR 
		(dianac IS NOT NULL AND diahecho IS NOT NULL 
		  AND dianac > diahecho) THEN
		na - 1
	ELSE
		na
	END;

	RETURN na;

END;$$;


--
-- Name: f_unaccent(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.f_unaccent(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
      SELECT public.unaccent('public.unaccent', $1)  
      $_$;


--
-- Name: first_element(anyarray); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.first_element(anyarray) RETURNS anyelement
    LANGUAGE sql IMMUTABLE
    AS $_$
            SELECT ($1)[1] ;
            $_$;


--
-- Name: first_element_state(anyarray, anyelement); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.first_element_state(anyarray, anyelement) RETURNS anyarray
    LANGUAGE sql IMMUTABLE
    AS $_$
            SELECT CASE WHEN array_upper($1,1) IS NULL
                THEN array_append($1,$2)
                ELSE $1
            END;
            $_$;


--
-- Name: probapellido(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.probapellido(in_text text) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
	SELECT sum(ppar) FROM (SELECT p, probcadap(p) AS ppar FROM (
		SELECT p FROM divarr(string_to_array(trim($1), ' ')) AS p) 
		AS s) AS s2;
$_$;


--
-- Name: probcadap(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.probcadap(in_text text) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT CASE WHEN (SELECT SUM(frec) FROM napellidos)=0 THEN 0
        WHEN (SELECT COUNT(*) FROM napellidos WHERE apellido=$1)=0 THEN 0
        ELSE (SELECT frec/(SELECT SUM(frec) FROM napellidos) 
            FROM napellidos WHERE apellido=$1)
        END
$_$;


--
-- Name: probcadh(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.probcadh(in_text text) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
	SELECT CASE WHEN (SELECT SUM(frec) FROM nhombres)=0 THEN 0
		WHEN (SELECT COUNT(*) FROM nhombres WHERE nombre=$1)=0 THEN 0
		ELSE (SELECT frec/(SELECT SUM(frec) FROM nhombres) 
			FROM nhombres WHERE nombre=$1)
		END
$_$;


--
-- Name: probcadm(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.probcadm(in_text text) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
	SELECT CASE WHEN (SELECT SUM(frec) FROM nmujeres)=0 THEN 0
		WHEN (SELECT COUNT(*) FROM nmujeres WHERE nombre=$1)=0 THEN 0
		ELSE (SELECT frec/(SELECT SUM(frec) FROM nmujeres) 
			FROM nmujeres WHERE nombre=$1)
		END
$_$;


--
-- Name: probhombre(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.probhombre(in_text text) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
	SELECT sum(ppar) FROM (SELECT p, peso*probcadh(p) AS ppar FROM (
		SELECT p, CASE WHEN rnum=1 THEN 100 ELSE 1 END AS peso 
		FROM (SELECT p, row_number() OVER () AS rnum FROM 
			divarr(string_to_array(trim($1), ' ')) AS p) 
		AS s) AS s2) AS s3;
$_$;


--
-- Name: probmujer(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.probmujer(in_text text) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
	SELECT sum(ppar) FROM (SELECT p, peso*probcadm(p) AS ppar FROM (
		SELECT p, CASE WHEN rnum=1 THEN 100 ELSE 1 END AS peso 
		FROM (SELECT p, row_number() OVER () AS rnum FROM 
			divarr(string_to_array(trim($1), ' ')) AS p) 
		AS s) AS s2) AS s3;
$_$;


--
-- Name: rand(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rand() RETURNS double precision
    LANGUAGE sql
    AS $$SELECT random();$$;


--
-- Name: sip_edad_de_fechanac_fecharef(integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sip_edad_de_fechanac_fecharef(anionac integer, mesnac integer, dianac integer, anioref integer, mesref integer, diaref integer) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$
        SELECT CASE 
          WHEN anionac IS NULL THEN NULL
          WHEN anioref IS NULL THEN NULL
          WHEN mesnac IS NULL OR dianac IS NULL OR mesref IS NULL OR diaref IS NULL THEN 
            anioref-anionac 
          WHEN mesnac < mesref THEN
            anioref-anionac
          WHEN mesnac > mesref THEN
            anioref-anionac-1
          WHEN dianac > diaref THEN
            anioref-anionac-1
          ELSE 
            anioref-anionac
        END 
      $$;


--
-- Name: sivel2_gen_polo_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sivel2_gen_polo_id(presponsable_id integer) RETURNS integer
    LANGUAGE sql
    AS $$
        WITH RECURSIVE des AS (
          SELECT id, nombre, papa_id 
          FROM sivel2_gen_presponsable WHERE id=presponsable_id 
          UNION SELECT e.id, e.nombre, e.papa_id 
          FROM sivel2_gen_presponsable e INNER JOIN des d ON d.papa_id=e.id) 
        SELECT id FROM des WHERE papa_id IS NULL;
      $$;


--
-- Name: sivel2_gen_polo_nombre(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sivel2_gen_polo_nombre(presponsable_id integer) RETURNS character varying
    LANGUAGE sql
    AS $$
        SELECT CASE 
          WHEN fechadeshabilitacion IS NULL THEN nombre
          ELSE nombre || '(DESHABILITADO)' 
        END 
        FROM sivel2_gen_presponsable 
        WHERE id=sivel2_gen_polo_id(presponsable_id)
      $$;


--
-- Name: soundexesp(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.soundexesp(input text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT COST 500
    AS $$
DECLARE
	soundex text='';	
	-- para determinar la primera letra
	pri_letra text;
	resto text;
	sustituida text ='';
	-- para quitar adyacentes
	anterior text;
	actual text;
	corregido text;
BEGIN
       -- devolver null si recibi un string en blanco o con espacios en blanco
	IF length(trim(input))= 0 then
		RETURN NULL;
	end IF;
 
 
	-- 1: LIMPIEZA:
		-- pasar a mayuscula, eliminar la letra "H" inicial, los acentos y la enie
		-- 'holá coñó' => 'OLA CONO'
        input=translate(ltrim(trim(upper(input)),'H'),'ÑÁÉÍÓÚÀÈÌÒÙÜ',
            'NAEIOUAEIOUU');
 
		-- eliminar caracteres no alfabéticos (números, símbolos como &,%,",*,!,+, etc.
		input=regexp_replace(input, '[^a-zA-Z]', '', 'g');
 
	-- 2: PRIMERA LETRA ES IMPORTANTE, DEBO ASOCIAR LAS SIMILARES
	--  'vaca' se convierte en 'baca'  y 'zapote' se convierte en 'sapote'
	-- un fenomeno importante es GE y GI se vuelven JE y JI; CA se vuelve KA, etc
	pri_letra =substr(input,1,1);
	resto =substr(input,2);
	CASE 
		when pri_letra IN ('V') then
			sustituida='B';
		when pri_letra IN ('Z','X') then
			sustituida='S';
		when pri_letra IN ('G') AND substr(input,2,1) IN ('E','I') then
			sustituida='J';
		when pri_letra IN('C') AND substr(input,2,1) NOT IN ('H','E','I') then
			sustituida='K';
		else
			sustituida=pri_letra;
 
	end case;
	--corregir el parametro con las consonantes sustituidas:
	input=sustituida || resto;		
 
	-- 3: corregir "letras compuestas" y volverlas una sola
	input=REPLACE(input,'CH','V');
	input=REPLACE(input,'QU','K');
	input=REPLACE(input,'LL','J');
	input=REPLACE(input,'CE','S');
	input=REPLACE(input,'CI','S');
	input=REPLACE(input,'YA','J');
	input=REPLACE(input,'YE','J');
	input=REPLACE(input,'YI','J');
	input=REPLACE(input,'YO','J');
	input=REPLACE(input,'YU','J');
	input=REPLACE(input,'GE','J');
	input=REPLACE(input,'GI','J');
	input=REPLACE(input,'NY','N');
	-- para debug:    --return input;
 
	-- EMPIEZA EL CALCULO DEL SOUNDEX
	-- 4: OBTENER PRIMERA letra
	pri_letra=substr(input,1,1);
 
	-- 5: retener el resto del string
	resto=substr(input,2);
 
	--6: en el resto del string, quitar vocales y vocales fonéticas
	resto=translate(resto,'@AEIOUHWY','@');
 
    --7: convertir las letras foneticamente equivalentes a numeros  
    --   (esto hace que B sea equivalente a V, C con S y Z, etc.)
	resto=translate(resto, 'BPFVCGKSXZDTLMNRQJ', '111122222233455677');
	-- así va quedando la cosa
	soundex=pri_letra || resto;
 
	--8: eliminar números iguales adyacentes (A11233 se vuelve A123)
	anterior=substr(soundex,1,1);
	corregido=anterior;
 
	FOR i IN 2 .. length(soundex) LOOP
		actual = substr(soundex, i, 1);
		IF actual <> anterior THEN
			corregido=corregido || actual;
			anterior=actual;			
		END IF;
	END LOOP;
	-- así va la cosa
	soundex=corregido;
 
	-- 9: siempre retornar un string de 4 posiciones
	soundex=rpad(soundex,4,'0');
	soundex=substr(soundex,1,4);		
 
	-- YA ESTUVO
	RETURN soundex;	
END;	
$$;


--
-- Name: soundexespm(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.soundexespm(in_text text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
SELECT ARRAY_TO_STRING(ARRAY_AGG(soundexesp(s)),' ')
FROM (SELECT UNNEST(STRING_TO_ARRAY(
		REGEXP_REPLACE(TRIM($1), '  *', ' '), ' ')) AS s                
	      ORDER BY 1) AS n;
$_$;


--
-- Name: substring_index(text, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.substring_index(text, text, integer) RETURNS text
    LANGUAGE sql
    AS $_$SELECT array_to_string((string_to_array($1, $2)) [1:$3], $2);$_$;


--
-- Name: first(anyelement); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.first(anyelement) (
    SFUNC = public.first_element_state,
    STYPE = anyarray,
    FINALFUNC = public.first_element
);


--
-- Name: acto_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.acto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: apo214_asisreconocimiento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_asisreconocimiento (
    id bigint NOT NULL,
    lugarpreliminar_id integer,
    persona_id integer,
    organizacion character varying(5000),
    posicion integer
);


--
-- Name: apo214_asisreconocimiento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_asisreconocimiento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_asisreconocimiento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_asisreconocimiento_id_seq OWNED BY public.apo214_asisreconocimiento.id;


--
-- Name: apo214_cobertura; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_cobertura (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: apo214_cobertura_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_cobertura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_cobertura_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_cobertura_id_seq OWNED BY public.apo214_cobertura.id;


--
-- Name: apo214_disposicioncadaveres; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_disposicioncadaveres (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: apo214_disposicioncadaveres_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_disposicioncadaveres_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_disposicioncadaveres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_disposicioncadaveres_id_seq OWNED BY public.apo214_disposicioncadaveres.id;


--
-- Name: apo214_elementopaisaje; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_elementopaisaje (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: apo214_elementopaisaje_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_elementopaisaje_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_elementopaisaje_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_elementopaisaje_id_seq OWNED BY public.apo214_elementopaisaje.id;


--
-- Name: apo214_evaluacionriesgo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_evaluacionriesgo (
    id bigint NOT NULL,
    riesgo_id integer,
    descripcion character varying(5000),
    calificacion integer
);


--
-- Name: apo214_evaluacionriesgo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_evaluacionriesgo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_evaluacionriesgo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_evaluacionriesgo_id_seq OWNED BY public.apo214_evaluacionriesgo.id;


--
-- Name: apo214_infoanomalia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_infoanomalia (
    id bigint NOT NULL,
    anomalia character varying(100),
    descripcion character varying(5000),
    latitud double precision,
    longitud double precision,
    area character varying(1024),
    anexo_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: apo214_infoanomalia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_infoanomalia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_infoanomalia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_infoanomalia_id_seq OWNED BY public.apo214_infoanomalia.id;


--
-- Name: apo214_infoanomalialugar; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_infoanomalialugar (
    id bigint NOT NULL,
    lugarpreliminar_id integer NOT NULL,
    infoanomalia_id integer NOT NULL
);


--
-- Name: apo214_infoanomalialugar_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_infoanomalialugar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_infoanomalialugar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_infoanomalialugar_id_seq OWNED BY public.apo214_infoanomalialugar.id;


--
-- Name: apo214_listaanexo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_listaanexo (
    id bigint NOT NULL,
    fecha date,
    lugarpreliminar_id integer NOT NULL,
    anexo_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: apo214_listaanexo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_listaanexo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_listaanexo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_listaanexo_id_seq OWNED BY public.apo214_listaanexo.id;


--
-- Name: apo214_listadepositados; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_listadepositados (
    id bigint NOT NULL,
    lugarpreliminar_id integer NOT NULL,
    persona_id integer NOT NULL
);


--
-- Name: apo214_listadepositados_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_listadepositados_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_listadepositados_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_listadepositados_id_seq OWNED BY public.apo214_listadepositados.id;


--
-- Name: apo214_listaevariesgo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_listaevariesgo (
    id bigint NOT NULL,
    lugarpreliminar_id integer NOT NULL,
    evaluacionriesgo_id integer NOT NULL
);


--
-- Name: apo214_listaevariesgo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_listaevariesgo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_listaevariesgo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_listaevariesgo_id_seq OWNED BY public.apo214_listaevariesgo.id;


--
-- Name: apo214_listainfofoto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_listainfofoto (
    id bigint NOT NULL,
    fecha date,
    lugarpreliminar_id integer NOT NULL,
    anexo_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: apo214_listainfofoto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_listainfofoto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_listainfofoto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_listainfofoto_id_seq OWNED BY public.apo214_listainfofoto.id;


--
-- Name: apo214_listapersofuentes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_listapersofuentes (
    id bigint NOT NULL,
    lugarpreliminar_id integer NOT NULL,
    persona_id integer NOT NULL,
    telefono character varying(1000),
    observacion character varying(5000)
);


--
-- Name: apo214_listapersofuentes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_listapersofuentes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_listapersofuentes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_listapersofuentes_id_seq OWNED BY public.apo214_listapersofuentes.id;


--
-- Name: apo214_listasuelo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_listasuelo (
    id bigint NOT NULL,
    lugarpreliminar_id integer NOT NULL,
    suelo_id integer NOT NULL
);


--
-- Name: apo214_listasuelo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_listasuelo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_listasuelo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_listasuelo_id_seq OWNED BY public.apo214_listasuelo.id;


--
-- Name: apo214_lugarpreliminar; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_lugarpreliminar (
    id bigint NOT NULL,
    fecha date,
    codigositio character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    nombreusuario character varying,
    organizacion character varying,
    ubicacionpre_id integer,
    id_persona integer,
    parentezco character varying,
    grabacion boolean,
    telefono character varying,
    tipotestigo_id integer,
    otrotipotestigo character varying,
    hechos text,
    ubicaespecifica text,
    disposicioncadaveres_id integer,
    otradisposicioncadaveres character varying(1000),
    tipoentierro_id integer,
    min_depositados integer,
    max_depositados integer,
    fechadis date,
    horadis time without time zone,
    insitu boolean,
    otrolubicacionpre_id integer,
    detallesasesinato character varying(5000),
    nombrepropiedad character varying(5000),
    detallesdisposicion character varying(5000),
    nomcomoseconoce character varying(1000),
    elementopaisaje_id integer,
    cobertura_id integer,
    interatroprevias character varying(5000),
    interatroactuales character varying(5000),
    usoterprevios character varying(5000),
    usoteractuales character varying(5000),
    accesolugar character varying(5000),
    perfilestratigrafico character varying(5000),
    observaciones character varying(5000),
    procesoscul character varying(5000),
    desgenanomalia character varying(5000),
    evaluacionlugar character varying(5000),
    riesgosdanios character varying(500),
    archivokml_id integer
);


--
-- Name: apo214_lugarpreliminar_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_lugarpreliminar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_lugarpreliminar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_lugarpreliminar_id_seq OWNED BY public.apo214_lugarpreliminar.id;


--
-- Name: apo214_propietario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_propietario (
    id bigint NOT NULL,
    id_lugarpreliminar integer,
    id_persona integer,
    telefono character varying,
    observaciones character varying(5000)
);


--
-- Name: apo214_propietario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_propietario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_propietario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_propietario_id_seq OWNED BY public.apo214_propietario.id;


--
-- Name: apo214_riesgo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_riesgo (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: apo214_riesgo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_riesgo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_riesgo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_riesgo_id_seq OWNED BY public.apo214_riesgo.id;


--
-- Name: apo214_suelo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_suelo (
    id bigint NOT NULL,
    profinicial character varying(100),
    proffinal character varying(100),
    color character varying(100),
    textura character varying(100),
    humedad character varying(100),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: apo214_suelo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_suelo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_suelo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_suelo_id_seq OWNED BY public.apo214_suelo.id;


--
-- Name: apo214_tipoentierro; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_tipoentierro (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: apo214_tipoentierro_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_tipoentierro_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_tipoentierro_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_tipoentierro_id_seq OWNED BY public.apo214_tipoentierro.id;


--
-- Name: apo214_tipotestigo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apo214_tipotestigo (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: apo214_tipotestigo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.apo214_tipotestigo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apo214_tipotestigo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.apo214_tipotestigo_id_seq OWNED BY public.apo214_tipotestigo.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: caso_etiqueta_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.caso_etiqueta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: caso_presponsable_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.caso_presponsable_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_caso_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso (
    id integer DEFAULT nextval('public.sivel2_gen_caso_id_seq'::regclass) NOT NULL,
    titulo character varying(50),
    fecha date NOT NULL,
    hora character varying(10),
    duracion character varying(10),
    memo text NOT NULL,
    grconfiabilidad character varying(5),
    gresclarecimiento character varying(5),
    grimpunidad character varying(8),
    grinformacion character varying(8),
    bienes text,
    id_intervalo integer DEFAULT 5,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ubicacion_id integer
);


--
-- Name: victima_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.victima_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_victima (
    hijos integer,
    id_profesion integer DEFAULT 22 NOT NULL,
    id_rangoedad integer DEFAULT 6 NOT NULL,
    id_filiacion integer DEFAULT 10 NOT NULL,
    id_sectorsocial integer DEFAULT 15 NOT NULL,
    id_organizacion integer DEFAULT 16 NOT NULL,
    id_vinculoestado integer DEFAULT 38 NOT NULL,
    id_caso integer NOT NULL,
    organizacionarmada integer DEFAULT 35 NOT NULL,
    anotaciones character varying(1000),
    id_persona integer NOT NULL,
    id_etnia integer DEFAULT 1 NOT NULL,
    id_iglesia integer DEFAULT 1,
    orientacionsexual character(1) DEFAULT 'S'::bpchar NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.victima_seq'::regclass) NOT NULL,
    CONSTRAINT victima_hijos_check CHECK (((hijos IS NULL) OR ((hijos >= 0) AND (hijos <= 100)))),
    CONSTRAINT victima_orientacionsexual_check CHECK (((orientacionsexual = 'L'::bpchar) OR (orientacionsexual = 'G'::bpchar) OR (orientacionsexual = 'B'::bpchar) OR (orientacionsexual = 'T'::bpchar) OR (orientacionsexual = 'O'::bpchar) OR (orientacionsexual = 'H'::bpchar) OR (orientacionsexual = 'S'::bpchar)))
);


--
-- Name: cben1; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cben1 AS
 SELECT caso.id AS id_caso,
    subv.id_victima,
    subv.id_persona,
    1 AS npersona,
    'total'::text AS total
   FROM public.sivel2_gen_caso caso,
    public.sivel2_gen_victima victima,
    ( SELECT sivel2_gen_victima.id_persona,
            max(sivel2_gen_victima.id) AS id_victima
           FROM public.sivel2_gen_victima
          GROUP BY sivel2_gen_victima.id_persona) subv
  WHERE ((caso.fecha >= '2020-02-12'::date) AND (caso.fecha <= '2029-03-01'::date) AND (subv.id_victima = victima.id) AND (caso.id = victima.id_caso));


--
-- Name: sip_clase_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_clase_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_clase; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_clase (
    id_clalocal integer,
    id_tclase character varying(10) DEFAULT 'CP'::character varying NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2001-01-01'::date NOT NULL,
    fechadeshabilitacion date,
    latitud double precision,
    longitud double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_municipio integer,
    id integer DEFAULT nextval('public.sip_clase_id_seq'::regclass) NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT clase_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_departamento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_departamento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_departamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_departamento (
    id_deplocal integer,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT CURRENT_DATE NOT NULL,
    fechadeshabilitacion date,
    latitud double precision,
    longitud double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_pais integer NOT NULL,
    id integer DEFAULT nextval('public.sip_departamento_id_seq'::regclass) NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    codiso character varying(6),
    catiso character varying(64),
    CONSTRAINT departamento_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_municipio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_municipio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_municipio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_municipio (
    id_munlocal integer,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT CURRENT_DATE NOT NULL,
    fechadeshabilitacion date,
    latitud double precision,
    longitud double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_departamento integer,
    id integer DEFAULT nextval('public.sip_municipio_id_seq'::regclass) NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT municipio_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_ubicacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_ubicacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_ubicacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_ubicacion (
    id integer DEFAULT nextval('public.sip_ubicacion_id_seq'::regclass) NOT NULL,
    id_tsitio integer DEFAULT 1 NOT NULL,
    id_caso integer NOT NULL,
    latitud double precision,
    longitud double precision,
    sitio character varying(500) COLLATE public.es_co_utf_8,
    lugar character varying(500) COLLATE public.es_co_utf_8,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_pais integer,
    id_departamento integer,
    id_municipio integer,
    id_clase integer
);


--
-- Name: cben2; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cben2 AS
 SELECT cben1.id_caso,
    cben1.id_victima,
    cben1.id_persona,
    cben1.npersona,
    cben1.total,
    ubicacion.id_departamento,
    departamento.nombre AS departamento_nombre,
    ubicacion.id_municipio,
    municipio.nombre AS municipio_nombre,
    ubicacion.id_clase,
    clase.nombre AS clase_nombre
   FROM (((((public.cben1
     JOIN public.sivel2_gen_caso caso ON ((cben1.id_caso = caso.id)))
     LEFT JOIN public.sip_ubicacion ubicacion ON ((caso.ubicacion_id = ubicacion.id)))
     LEFT JOIN public.sip_departamento departamento ON ((ubicacion.id_departamento = departamento.id)))
     LEFT JOIN public.sip_municipio municipio ON ((ubicacion.id_municipio = municipio.id)))
     LEFT JOIN public.sip_clase clase ON ((ubicacion.id_clase = clase.id)))
  GROUP BY cben1.id_caso, cben1.id_victima, cben1.id_persona, cben1.npersona, cben1.total, ubicacion.id_departamento, departamento.nombre, ubicacion.id_municipio, municipio.nombre, ubicacion.id_clase, clase.nombre;


--
-- Name: combatiente_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.combatiente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_persona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_persona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_persona (
    id integer DEFAULT nextval('public.sip_persona_id_seq'::regclass) NOT NULL,
    nombres character varying(100) NOT NULL COLLATE public.es_co_utf_8,
    apellidos character varying(100) NOT NULL COLLATE public.es_co_utf_8,
    anionac integer,
    mesnac integer,
    dianac integer,
    sexo character(1) NOT NULL,
    numerodocumento character varying(100),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_pais integer,
    nacionalde integer,
    tdocumento_id integer,
    id_departamento integer,
    id_municipio integer,
    id_clase integer,
    CONSTRAINT persona_check CHECK (((dianac IS NULL) OR (((dianac >= 1) AND (((mesnac = 1) OR (mesnac = 3) OR (mesnac = 5) OR (mesnac = 7) OR (mesnac = 8) OR (mesnac = 10) OR (mesnac = 12)) AND (dianac <= 31))) OR (((mesnac = 4) OR (mesnac = 6) OR (mesnac = 9) OR (mesnac = 11)) AND (dianac <= 30)) OR ((mesnac = 2) AND (dianac <= 29))))),
    CONSTRAINT persona_mesnac_check CHECK (((mesnac IS NULL) OR ((mesnac >= 1) AND (mesnac <= 12)))),
    CONSTRAINT persona_sexo_check CHECK (((sexo = 'S'::bpchar) OR (sexo = 'F'::bpchar) OR (sexo = 'M'::bpchar)))
);


--
-- Name: sivel2_gen_acto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_acto (
    id_presponsable integer NOT NULL,
    id_categoria integer NOT NULL,
    id_persona integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.acto_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_categoria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_categoria (
    id integer NOT NULL,
    fechacreacion date DEFAULT CURRENT_DATE NOT NULL,
    fechadeshabilitacion date,
    id_pconsolidado integer,
    contadaen integer,
    tipocat character(1) DEFAULT 'I'::bpchar,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    supracategoria_id integer,
    CONSTRAINT "$3" CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion))),
    CONSTRAINT categoria_tipocat_check CHECK (((tipocat = 'I'::bpchar) OR (tipocat = 'C'::bpchar) OR (tipocat = 'O'::bpchar)))
);


--
-- Name: sivel2_gen_supracategoria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_supracategoria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_supracategoria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_supracategoria (
    codigo integer,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    id_tviolencia character varying(1) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    id integer DEFAULT nextval('public.sivel2_gen_supracategoria_id_seq'::regclass) NOT NULL,
    CONSTRAINT supracategoria_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: cvt1; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cvt1 AS
 SELECT DISTINCT acto.id_caso,
    acto.id_persona,
    acto.id_categoria,
    supracategoria.id_tviolencia,
    categoria.nombre AS categoria
   FROM (((((public.sivel2_gen_acto acto
     JOIN public.sivel2_gen_caso caso ON ((acto.id_caso = caso.id)))
     JOIN public.sivel2_gen_categoria categoria ON ((acto.id_categoria = categoria.id)))
     JOIN public.sivel2_gen_supracategoria supracategoria ON ((categoria.supracategoria_id = supracategoria.id)))
     JOIN public.sivel2_gen_victima victima ON (((victima.id_persona = acto.id_persona) AND (victima.id_caso = caso.id))))
     JOIN public.sip_persona persona ON ((persona.id = acto.id_persona)));


--
-- Name: fotra_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fotra_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_campohc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_campohc (
    id integer NOT NULL,
    doc_id integer NOT NULL,
    nombrecampo character varying(127) NOT NULL,
    columna character varying(5) NOT NULL,
    fila integer
);


--
-- Name: heb412_gen_campohc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_campohc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_campohc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_campohc_id_seq OWNED BY public.heb412_gen_campohc.id;


--
-- Name: heb412_gen_campoplantillahcm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_campoplantillahcm (
    id integer NOT NULL,
    plantillahcm_id integer,
    nombrecampo character varying(183),
    columna character varying(5)
);


--
-- Name: heb412_gen_campoplantillahcm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_campoplantillahcm_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_campoplantillahcm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_campoplantillahcm_id_seq OWNED BY public.heb412_gen_campoplantillahcm.id;


--
-- Name: heb412_gen_campoplantillahcr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_campoplantillahcr (
    id bigint NOT NULL,
    plantillahcr_id integer,
    nombrecampo character varying(127),
    columna character varying(5),
    fila integer
);


--
-- Name: heb412_gen_campoplantillahcr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_campoplantillahcr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_campoplantillahcr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_campoplantillahcr_id_seq OWNED BY public.heb412_gen_campoplantillahcr.id;


--
-- Name: heb412_gen_carpetaexclusiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_carpetaexclusiva (
    id bigint NOT NULL,
    carpeta character varying(2048),
    grupo_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: heb412_gen_carpetaexclusiva_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_carpetaexclusiva_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_carpetaexclusiva_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_carpetaexclusiva_id_seq OWNED BY public.heb412_gen_carpetaexclusiva.id;


--
-- Name: heb412_gen_doc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_doc (
    id integer NOT NULL,
    nombre character varying(512),
    tipodoc character varying(1),
    dirpapa integer,
    url character varying(1024),
    fuente character varying(1024),
    descripcion character varying(5000),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    adjunto_file_name character varying,
    adjunto_content_type character varying,
    adjunto_file_size bigint,
    adjunto_updated_at timestamp without time zone,
    nombremenu character varying(127),
    vista character varying(255),
    filainicial integer,
    ruta character varying(2047),
    licencia character varying(255),
    tdoc_id integer,
    tdoc_type character varying
);


--
-- Name: heb412_gen_doc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_doc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_doc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_doc_id_seq OWNED BY public.heb412_gen_doc.id;


--
-- Name: heb412_gen_formulario_plantillahcm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_formulario_plantillahcm (
    formulario_id integer,
    plantillahcm_id integer
);


--
-- Name: heb412_gen_formulario_plantillahcr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_formulario_plantillahcr (
    id bigint NOT NULL,
    plantillahcr_id integer,
    formulario_id integer
);


--
-- Name: heb412_gen_formulario_plantillahcr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_formulario_plantillahcr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_formulario_plantillahcr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_formulario_plantillahcr_id_seq OWNED BY public.heb412_gen_formulario_plantillahcr.id;


--
-- Name: heb412_gen_plantilladoc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_plantilladoc (
    id bigint NOT NULL,
    ruta character varying(2047),
    fuente character varying(1023),
    licencia character varying(1023),
    vista character varying(127),
    nombremenu character varying(127)
);


--
-- Name: heb412_gen_plantilladoc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_plantilladoc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_plantilladoc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_plantilladoc_id_seq OWNED BY public.heb412_gen_plantilladoc.id;


--
-- Name: heb412_gen_plantillahcm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_plantillahcm (
    id integer NOT NULL,
    ruta character varying(2047) NOT NULL,
    fuente character varying(1023),
    licencia character varying(1023),
    vista character varying(127) NOT NULL,
    nombremenu character varying(127) NOT NULL,
    filainicial integer NOT NULL
);


--
-- Name: heb412_gen_plantillahcm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_plantillahcm_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_plantillahcm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_plantillahcm_id_seq OWNED BY public.heb412_gen_plantillahcm.id;


--
-- Name: heb412_gen_plantillahcr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_plantillahcr (
    id bigint NOT NULL,
    ruta character varying(2047),
    fuente character varying(1023),
    licencia character varying(1023),
    vista character varying(127),
    nombremenu character varying(127)
);


--
-- Name: heb412_gen_plantillahcr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_plantillahcr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_plantillahcr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_plantillahcr_id_seq OWNED BY public.heb412_gen_plantillahcr.id;


--
-- Name: homonimosim_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.homonimosim_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_usuario (
    id_usuario integer NOT NULL,
    id_caso integer NOT NULL,
    fechainicio date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: iniciador; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.iniciador AS
 SELECT sivel2_gen_caso_usuario.id_caso,
    sivel2_gen_caso_usuario.fechainicio AS fecha_inicio,
    min(sivel2_gen_caso_usuario.id_usuario) AS id_funcionario
   FROM public.sivel2_gen_caso_usuario,
    ( SELECT funcionario_caso_1.id_caso,
            min(funcionario_caso_1.fechainicio) AS m
           FROM public.sivel2_gen_caso_usuario funcionario_caso_1
          GROUP BY funcionario_caso_1.id_caso) c
  WHERE ((sivel2_gen_caso_usuario.id_caso = c.id_caso) AND (sivel2_gen_caso_usuario.fechainicio = c.m))
  GROUP BY sivel2_gen_caso_usuario.id_caso, sivel2_gen_caso_usuario.fechainicio
  ORDER BY sivel2_gen_caso_usuario.id_caso, sivel2_gen_caso_usuario.fechainicio;


--
-- Name: mr519_gen_campo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_campo (
    id bigint NOT NULL,
    nombre character varying(512) NOT NULL,
    ayudauso character varying(1024),
    tipo integer DEFAULT 1 NOT NULL,
    obligatorio boolean,
    formulario_id integer NOT NULL,
    nombreinterno character varying(60),
    fila integer,
    columna integer,
    ancho integer,
    tablabasica character varying(32)
);


--
-- Name: mr519_gen_campo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_campo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_campo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_campo_id_seq OWNED BY public.mr519_gen_campo.id;


--
-- Name: mr519_gen_encuestapersona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_encuestapersona (
    id bigint NOT NULL,
    persona_id integer,
    formulario_id integer,
    fecha date,
    fechainicio date NOT NULL,
    fechafin date,
    adurl character varying(32),
    respuestafor_id integer
);


--
-- Name: mr519_gen_encuestapersona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_encuestapersona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_encuestapersona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_encuestapersona_id_seq OWNED BY public.mr519_gen_encuestapersona.id;


--
-- Name: mr519_gen_encuestausuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_encuestausuario (
    id bigint NOT NULL,
    usuario_id integer NOT NULL,
    fecha date,
    fechainicio date NOT NULL,
    fechafin date,
    respuestafor_id integer
);


--
-- Name: mr519_gen_encuestausuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_encuestausuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_encuestausuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_encuestausuario_id_seq OWNED BY public.mr519_gen_encuestausuario.id;


--
-- Name: mr519_gen_formulario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_formulario (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    nombreinterno character varying(60)
);


--
-- Name: mr519_gen_formulario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_formulario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_formulario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_formulario_id_seq OWNED BY public.mr519_gen_formulario.id;


--
-- Name: mr519_gen_opcioncs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_opcioncs (
    id bigint NOT NULL,
    campo_id integer NOT NULL,
    nombre character varying(1024) NOT NULL,
    valor character varying(60) NOT NULL
);


--
-- Name: mr519_gen_opcioncs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_opcioncs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_opcioncs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_opcioncs_id_seq OWNED BY public.mr519_gen_opcioncs.id;


--
-- Name: mr519_gen_planencuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_planencuesta (
    id bigint NOT NULL,
    fechaini date,
    fechafin date,
    formulario_id integer,
    plantillacorreoinv_id integer,
    adurl character varying(32),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mr519_gen_planencuesta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_planencuesta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_planencuesta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_planencuesta_id_seq OWNED BY public.mr519_gen_planencuesta.id;


--
-- Name: mr519_gen_respuestafor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_respuestafor (
    id bigint NOT NULL,
    formulario_id integer,
    fechaini date NOT NULL,
    fechacambio date NOT NULL
);


--
-- Name: mr519_gen_respuestafor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_respuestafor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_respuestafor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_respuestafor_id_seq OWNED BY public.mr519_gen_respuestafor.id;


--
-- Name: mr519_gen_valorcampo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_valorcampo (
    id bigint NOT NULL,
    campo_id integer NOT NULL,
    valor character varying(5000),
    respuestafor_id integer NOT NULL,
    valorjson json
);


--
-- Name: mr519_gen_valorcampo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_valorcampo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_valorcampo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_valorcampo_id_seq OWNED BY public.mr519_gen_valorcampo.id;


--
-- Name: napellidos; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.napellidos AS
 SELECT s.apellido,
    count(*) AS frec
   FROM ( SELECT public.divarr(string_to_array(btrim((sip_persona.apellidos)::text), ' '::text)) AS apellido
           FROM public.sip_persona,
            public.sivel2_gen_victima
          WHERE (sivel2_gen_victima.id_persona = sip_persona.id)) s
  GROUP BY s.apellido
  ORDER BY (count(*))
  WITH NO DATA;


--
-- Name: nhombres; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.nhombres AS
 SELECT s.nombre,
    count(*) AS frec
   FROM ( SELECT public.divarr(string_to_array(btrim((sip_persona.nombres)::text), ' '::text)) AS nombre
           FROM public.sip_persona,
            public.sivel2_gen_victima
          WHERE ((sivel2_gen_victima.id_persona = sip_persona.id) AND (sip_persona.sexo = 'M'::bpchar))) s
  GROUP BY s.nombre
  ORDER BY (count(*))
  WITH NO DATA;


--
-- Name: nmujeres; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.nmujeres AS
 SELECT s.nombre,
    count(*) AS frec
   FROM ( SELECT public.divarr(string_to_array(btrim((sip_persona.nombres)::text), ' '::text)) AS nombre
           FROM public.sip_persona,
            public.sivel2_gen_victima
          WHERE ((sivel2_gen_victima.id_persona = sip_persona.id) AND (sip_persona.sexo = 'F'::bpchar))) s
  GROUP BY s.nombre
  ORDER BY (count(*))
  WITH NO DATA;


--
-- Name: persona_nomap; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.persona_nomap AS
 SELECT sip_persona.id,
    upper(btrim(((btrim((sip_persona.nombres)::text) || ' '::text) || btrim((sip_persona.apellidos)::text)))) AS nomap
   FROM public.sip_persona
  WITH NO DATA;


--
-- Name: primerusuario; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.primerusuario AS
 SELECT sivel2_gen_caso_usuario.id_caso,
    min(sivel2_gen_caso_usuario.fechainicio) AS fechainicio,
    public.first(sivel2_gen_caso_usuario.id_usuario) AS id_usuario
   FROM public.sivel2_gen_caso_usuario
  GROUP BY sivel2_gen_caso_usuario.id_caso
  ORDER BY sivel2_gen_caso_usuario.id_caso;


--
-- Name: resagresion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resagresion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sip_anexo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_anexo (
    id integer NOT NULL,
    descripcion character varying(1500) NOT NULL COLLATE public.es_co_utf_8,
    adjunto_file_name character varying(255),
    adjunto_content_type character varying(255),
    adjunto_file_size integer,
    adjunto_updated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sip_anexo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_anexo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_anexo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_anexo_id_seq OWNED BY public.sip_anexo.id;


--
-- Name: sip_bitacora; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_bitacora (
    id bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    ip character varying(100),
    usuario_id integer,
    url character varying(1023),
    params character varying(5000),
    modelo character varying(511),
    modelo_id integer,
    operacion character varying(63),
    detalle json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sip_bitacora_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_bitacora_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_bitacora_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_bitacora_id_seq OWNED BY public.sip_bitacora.id;


--
-- Name: sip_etiqueta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_etiqueta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_etiqueta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_etiqueta (
    id integer DEFAULT nextval('public.sip_etiqueta_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT CURRENT_DATE NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT etiqueta_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_etiqueta_municipio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_etiqueta_municipio (
    etiqueta_id bigint NOT NULL,
    municipio_id bigint NOT NULL
);


--
-- Name: sip_fuenteprensa_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_fuenteprensa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_fuenteprensa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_fuenteprensa (
    id integer DEFAULT nextval('public.sip_fuenteprensa_id_seq'::regclass) NOT NULL,
    tfuente character varying(25),
    nombre character varying(500) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2001-01-01'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT sip_fuenteprensa_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_grupo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_grupo (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sip_grupo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_grupo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_grupo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_grupo_id_seq OWNED BY public.sip_grupo.id;


--
-- Name: sip_grupo_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_grupo_usuario (
    usuario_id integer NOT NULL,
    sip_grupo_id integer NOT NULL
);


--
-- Name: sip_grupoper_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_grupoper_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_grupoper; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_grupoper (
    id integer DEFAULT nextval('public.sip_grupoper_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    anotaciones character varying(1000),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sip_mundep_sinorden; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sip_mundep_sinorden AS
 SELECT ((sip_departamento.id_deplocal * 1000) + sip_municipio.id_munlocal) AS idlocal,
    (((sip_municipio.nombre)::text || ' / '::text) || (sip_departamento.nombre)::text) AS nombre
   FROM (public.sip_municipio
     JOIN public.sip_departamento ON ((sip_municipio.id_departamento = sip_departamento.id)))
  WHERE ((sip_departamento.id_pais = 170) AND (sip_municipio.fechadeshabilitacion IS NULL) AND (sip_departamento.fechadeshabilitacion IS NULL))
UNION
 SELECT sip_departamento.id_deplocal AS idlocal,
    sip_departamento.nombre
   FROM public.sip_departamento
  WHERE ((sip_departamento.id_pais = 170) AND (sip_departamento.fechadeshabilitacion IS NULL));


--
-- Name: sip_mundep; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.sip_mundep AS
 SELECT sip_mundep_sinorden.idlocal,
    sip_mundep_sinorden.nombre,
    to_tsvector('spanish'::regconfig, public.unaccent(sip_mundep_sinorden.nombre)) AS mundep
   FROM public.sip_mundep_sinorden
  ORDER BY (sip_mundep_sinorden.nombre COLLATE public.es_co_utf_8)
  WITH NO DATA;


--
-- Name: sip_oficina; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_oficina (
    id integer NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT CURRENT_DATE,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8
);


--
-- Name: sip_oficina_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_oficina_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_oficina_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_oficina_id_seq OWNED BY public.sip_oficina.id;


--
-- Name: sip_orgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_orgsocial (
    id bigint NOT NULL,
    grupoper_id integer NOT NULL,
    telefono character varying(500),
    fax character varying(500),
    direccion character varying(500),
    pais_id integer,
    web character varying(500),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    fechadeshabilitacion date
);


--
-- Name: sip_orgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_orgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_orgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_orgsocial_id_seq OWNED BY public.sip_orgsocial.id;


--
-- Name: sip_orgsocial_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_orgsocial_persona (
    id bigint NOT NULL,
    persona_id integer NOT NULL,
    orgsocial_id integer,
    perfilorgsocial_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    correo character varying(100),
    cargo character varying(254)
);


--
-- Name: sip_orgsocial_persona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_orgsocial_persona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_orgsocial_persona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_orgsocial_persona_id_seq OWNED BY public.sip_orgsocial_persona.id;


--
-- Name: sip_orgsocial_sectororgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_orgsocial_sectororgsocial (
    orgsocial_id integer,
    sectororgsocial_id integer
);


--
-- Name: sip_pais; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_pais (
    id integer NOT NULL,
    nombre character varying(200) COLLATE public.es_co_utf_8,
    nombreiso_espanol character varying(200),
    latitud double precision,
    longitud double precision,
    alfa2 character varying(2),
    alfa3 character varying(3),
    codiso integer,
    div1 character varying(100),
    div2 character varying(100),
    div3 character varying(100),
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    nombreiso_ingles character varying(512),
    nombreiso_frances character varying(512),
    ultvigenciaini date,
    ultvigenciafin date
);


--
-- Name: sip_pais_histvigencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_pais_histvigencia (
    id bigint NOT NULL,
    pais_id integer,
    vigenciaini date,
    vigenciafin date NOT NULL,
    codiso integer,
    alfa2 character varying(2),
    alfa3 character varying(3),
    codcambio character varying(4)
);


--
-- Name: sip_pais_histvigencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_pais_histvigencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_pais_histvigencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_pais_histvigencia_id_seq OWNED BY public.sip_pais_histvigencia.id;


--
-- Name: sip_pais_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_pais_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_pais_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_pais_id_seq OWNED BY public.sip_pais.id;


--
-- Name: sip_perfilorgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_perfilorgsocial (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sip_perfilorgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_perfilorgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_perfilorgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_perfilorgsocial_id_seq OWNED BY public.sip_perfilorgsocial.id;


--
-- Name: sip_persona_trelacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_persona_trelacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_persona_trelacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_persona_trelacion (
    persona1 integer NOT NULL,
    persona2 integer NOT NULL,
    id_trelacion character(2) DEFAULT 'SI'::bpchar NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sip_persona_trelacion_id_seq'::regclass) NOT NULL
);


--
-- Name: sip_sectororgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_sectororgsocial (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sip_sectororgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_sectororgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_sectororgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_sectororgsocial_id_seq OWNED BY public.sip_sectororgsocial.id;


--
-- Name: sip_tclase; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_tclase (
    id character varying(10) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2001-01-01'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT tipo_clase_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_tdocumento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_tdocumento (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    sigla character varying(100),
    formatoregex character varying(500),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8
);


--
-- Name: sip_tdocumento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_tdocumento_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_tdocumento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_tdocumento_id_seq OWNED BY public.sip_tdocumento.id;


--
-- Name: sip_tema; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_tema (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    nav_ini character varying(8),
    nav_fin character varying(8),
    nav_fuente character varying(8),
    fondo_lista character varying(8),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    btn_primario_fondo_ini character varying(127),
    btn_primario_fondo_fin character varying(127),
    btn_primario_fuente character varying(127),
    btn_peligro_fondo_ini character varying(127),
    btn_peligro_fondo_fin character varying(127),
    btn_peligro_fuente character varying(127),
    btn_accion_fondo_ini character varying(127),
    btn_accion_fondo_fin character varying(127),
    btn_accion_fuente character varying(127),
    alerta_exito_fondo character varying(127),
    alerta_exito_fuente character varying(127),
    alerta_problema_fondo character varying(127),
    alerta_problema_fuente character varying(127),
    fondo character varying(127),
    color_fuente character varying(127),
    color_flota_subitem_fuente character varying,
    color_flota_subitem_fondo character varying
);


--
-- Name: sip_tema_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_tema_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_tema_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_tema_id_seq OWNED BY public.sip_tema.id;


--
-- Name: sip_trelacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_trelacion (
    id character(2) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2001-01-01'::date NOT NULL,
    fechadeshabilitacion date,
    inverso character varying(2),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT tipo_relacion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_trivalente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_trivalente (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sip_trivalente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_trivalente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_trivalente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_trivalente_id_seq OWNED BY public.sip_trivalente.id;


--
-- Name: sip_tsitio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_tsitio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_tsitio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_tsitio (
    id integer DEFAULT nextval('public.sip_tsitio_id_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT CURRENT_DATE NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT tipo_sitio_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_ubicacionpre; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_ubicacionpre (
    id bigint NOT NULL,
    nombre character varying(2000) NOT NULL COLLATE public.es_co_utf_8,
    pais_id integer,
    departamento_id integer,
    municipio_id integer,
    clase_id integer,
    lugar character varying(500),
    sitio character varying(500),
    tsitio_id integer,
    latitud double precision,
    longitud double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    nombre_sin_pais character varying(500)
);


--
-- Name: sip_ubicacionpre_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_ubicacionpre_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_ubicacionpre_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_ubicacionpre_id_seq OWNED BY public.sip_ubicacionpre.id;


--
-- Name: sivel2_gen_actividadoficio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_actividadoficio (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_gen_actividadoficio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_actividadoficio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_actividadoficio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_actividadoficio_id_seq OWNED BY public.sivel2_gen_actividadoficio.id;


--
-- Name: sivel2_gen_actocolectivo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_actocolectivo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_actocolectivo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_actocolectivo (
    id_presponsable integer NOT NULL,
    id_categoria integer NOT NULL,
    id_grupoper integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sivel2_gen_actocolectivo_id_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_anexo_caso_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_anexo_caso_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_anexo_caso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_anexo_caso (
    id integer DEFAULT nextval('public.sivel2_gen_anexo_caso_id_seq'::regclass) NOT NULL,
    id_caso integer NOT NULL,
    fecha date NOT NULL,
    fechaffrecuente date,
    fuenteprensa_id integer,
    id_fotra integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_anexo integer NOT NULL
);


--
-- Name: sivel2_gen_antecedente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_antecedente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_antecedente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_antecedente (
    id integer DEFAULT nextval('public.sivel2_gen_antecedente_id_seq'::regclass) NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT "$1" CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion > fechacreacion)))
);


--
-- Name: sivel2_gen_antecedente_caso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_antecedente_caso (
    id_antecedente integer NOT NULL,
    id_caso integer NOT NULL
);


--
-- Name: sivel2_gen_antecedente_combatiente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_antecedente_combatiente (
    id_antecedente integer NOT NULL,
    id_combatiente integer NOT NULL
);


--
-- Name: sivel2_gen_antecedente_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_antecedente_victima (
    id_antecedente integer NOT NULL,
    id_victima integer NOT NULL
);


--
-- Name: sivel2_gen_antecedente_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_antecedente_victimacolectiva (
    id_antecedente integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_caso_categoria_presponsable_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_caso_categoria_presponsable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso_categoria_presponsable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_categoria_presponsable (
    id_categoria integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_caso_presponsable integer,
    id integer DEFAULT nextval('public.sivel2_gen_caso_categoria_presponsable_id_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_caso_contexto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_contexto (
    id_caso integer NOT NULL,
    id_contexto integer NOT NULL
);


--
-- Name: sivel2_gen_caso_etiqueta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_etiqueta (
    id_caso integer NOT NULL,
    id_etiqueta integer NOT NULL,
    id_usuario integer NOT NULL,
    fecha date NOT NULL,
    observaciones character varying(5000),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.caso_etiqueta_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_caso_fotra_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_caso_fotra_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso_fotra; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_fotra (
    id_caso integer NOT NULL,
    id_fotra integer,
    anotacion character varying(1024),
    fecha date NOT NULL,
    ubicacionfisica character varying(1024),
    tfuente character varying(25),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    id integer DEFAULT nextval('public.sivel2_gen_caso_fotra_seq'::regclass) NOT NULL,
    anexo_caso_id integer
);


--
-- Name: sivel2_gen_caso_frontera; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_frontera (
    id_frontera integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_caso_fuenteprensa_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_caso_fuenteprensa_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso_fuenteprensa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_fuenteprensa (
    fecha date NOT NULL,
    ubicacion character varying(1024),
    clasificacion character varying(100),
    ubicacionfisica character varying(1024),
    fuenteprensa_id integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sivel2_gen_caso_fuenteprensa_seq'::regclass) NOT NULL,
    anexo_caso_id integer
);


--
-- Name: sivel2_gen_caso_presponsable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_presponsable (
    id_caso integer NOT NULL,
    id_presponsable integer NOT NULL,
    tipo integer DEFAULT 0 NOT NULL,
    bloque character varying(50),
    frente character varying(50),
    brigada character varying(50),
    batallon character varying(50),
    division character varying(50),
    id integer DEFAULT nextval('public.caso_presponsable_seq'::regclass) NOT NULL,
    otro character varying(500),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_caso_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_region (
    id_caso integer NOT NULL,
    id_region integer NOT NULL
);


--
-- Name: sivel2_gen_caso_respuestafor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_respuestafor (
    caso_id integer NOT NULL,
    respuestafor_id integer NOT NULL
);


--
-- Name: sivel2_gen_combatiente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_combatiente (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL,
    alias character varying(500),
    edad integer,
    sexo character varying(1) DEFAULT 'S'::character varying NOT NULL,
    id_resagresion integer DEFAULT 1 NOT NULL,
    id_profesion integer DEFAULT 22,
    id_rangoedad integer DEFAULT 6,
    id_filiacion integer DEFAULT 10,
    id_sectorsocial integer DEFAULT 15,
    id_organizacion integer DEFAULT 16,
    id_vinculoestado integer DEFAULT 38,
    id_caso integer,
    organizacionarmada integer DEFAULT 35,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_gen_combatiente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_combatiente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_combatiente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_combatiente_id_seq OWNED BY public.sivel2_gen_combatiente.id;


--
-- Name: sivel2_gen_presponsable_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_presponsable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_presponsable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_presponsable (
    id integer DEFAULT nextval('public.sivel2_gen_presponsable_id_seq'::regclass) NOT NULL,
    fechacreacion date DEFAULT CURRENT_DATE NOT NULL,
    fechadeshabilitacion date,
    papa_id integer,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT presuntos_responsables_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_conscaso1; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sivel2_gen_conscaso1 AS
 SELECT caso.id AS caso_id,
    caso.fecha,
    caso.memo,
    array_to_string(ARRAY( SELECT (((COALESCE(departamento.nombre, ''::character varying))::text || ' / '::text) || (COALESCE(municipio.nombre, ''::character varying))::text)
           FROM ((public.sip_ubicacion ubicacion
             LEFT JOIN public.sip_departamento departamento ON ((ubicacion.id_departamento = departamento.id)))
             LEFT JOIN public.sip_municipio municipio ON ((ubicacion.id_municipio = municipio.id)))
          WHERE (ubicacion.id_caso = caso.id)), ', '::text) AS ubicaciones,
    array_to_string(ARRAY( SELECT (((persona.nombres)::text || ' '::text) || (persona.apellidos)::text)
           FROM public.sip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.id_persona) AND (victima.id_caso = caso.id))), ', '::text) AS victimas,
    array_to_string(ARRAY( SELECT presponsable.nombre
           FROM public.sivel2_gen_presponsable presponsable,
            public.sivel2_gen_caso_presponsable caso_presponsable
          WHERE ((presponsable.id = caso_presponsable.id_presponsable) AND (caso_presponsable.id_caso = caso.id))), ', '::text) AS presponsables,
    array_to_string(ARRAY( SELECT (((((((supracategoria.id_tviolencia)::text || ':'::text) || categoria.supracategoria_id) || ':'::text) || categoria.id) || ' '::text) || (categoria.nombre)::text)
           FROM public.sivel2_gen_categoria categoria,
            public.sivel2_gen_supracategoria supracategoria,
            public.sivel2_gen_acto acto
          WHERE ((categoria.id = acto.id_categoria) AND (supracategoria.id = categoria.supracategoria_id) AND (acto.id_caso = caso.id))), ', '::text) AS tipificacion
   FROM public.sivel2_gen_caso caso;


--
-- Name: sivel2_gen_conscaso; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.sivel2_gen_conscaso AS
 SELECT sivel2_gen_conscaso1.caso_id,
    sivel2_gen_conscaso1.fecha,
    sivel2_gen_conscaso1.memo,
    sivel2_gen_conscaso1.ubicaciones,
    sivel2_gen_conscaso1.victimas,
    sivel2_gen_conscaso1.presponsables,
    sivel2_gen_conscaso1.tipificacion,
    now() AS ultimo_refresco,
    to_tsvector('spanish'::regconfig, public.unaccent(((((((((((((sivel2_gen_conscaso1.caso_id || ' '::text) || replace(((sivel2_gen_conscaso1.fecha)::character varying)::text, '-'::text, ' '::text)) || ' '::text) || sivel2_gen_conscaso1.memo) || ' '::text) || sivel2_gen_conscaso1.ubicaciones) || ' '::text) || sivel2_gen_conscaso1.victimas) || ' '::text) || sivel2_gen_conscaso1.presponsables) || ' '::text) || sivel2_gen_conscaso1.tipificacion))) AS q
   FROM public.sivel2_gen_conscaso1
  WITH NO DATA;


--
-- Name: sivel2_gen_consexpcaso; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.sivel2_gen_consexpcaso AS
 SELECT conscaso.caso_id,
    conscaso.fecha,
    conscaso.memo,
    conscaso.ubicaciones,
    conscaso.victimas,
    conscaso.presponsables,
    conscaso.tipificacion,
    conscaso.ultimo_refresco,
    conscaso.q,
    caso.titulo,
    caso.hora,
    caso.duracion,
    caso.grconfiabilidad,
    caso.gresclarecimiento,
    caso.grimpunidad,
    caso.grinformacion,
    caso.bienes,
    caso.id_intervalo,
    caso.created_at,
    caso.updated_at
   FROM (public.sivel2_gen_conscaso conscaso
     JOIN public.sivel2_gen_caso caso ON ((caso.id = conscaso.caso_id)))
  WHERE (conscaso.caso_id IN ( SELECT sivel2_gen_conscaso.caso_id
           FROM public.sivel2_gen_conscaso
          WHERE ((sivel2_gen_conscaso.caso_id = ANY (ARRAY[1140, 1166, 25356, 1110, 1115, 125214, 25310, 26928, 26420, 25125, 26451, 24931, 24943, 24976, 24977, 25024, 24764, 24877, 24883, 161023, 161025, 11342, 161022, 161024, 27978, 22229, 24884, 33452, 24905, 24860, 24937, 1011, 24941, 24944, 24962, 24938, 24981, 2193, 26388, 26136, 1013, 25067, 28409, 25060, 160340, 26343, 24261, 26381, 29160, 26390, 2989, 26389, 1697, 26398, 26399, 3857, 879, 930, 932, 125124, 161026, 161027, 938, 955, 956, 954, 26074, 24657, 26108, 969, 2644, 972, 1454, 973, 25139, 976, 1040, 1043, 161028, 1050, 1052, 1053, 1054, 26444, 1074, 25161, 26416, 1005, 25192, 26237, 26240, 24719, 28416, 26249, 24774, 24776, 26258, 26257, 890, 24775, 26262, 918, 24777, 26280, 26288, 26296, 1077, 26304, 24809, 24827, 26442, 125069, 998, 28422, 26358, 1439, 2164, 26357, 26809, 26361, 26339, 873, 875, 884, 7254, 893, 882, 906, 907, 917, 24885, 2705, 919, 921, 923, 927, 1121, 1124, 1126, 1129, 1130, 1131, 1133, 1137, 2687, 2724, 1142, 1144, 1132, 1153, 1155, 1165, 1167, 2692, 2694, 2695, 1192, 1193, 1195, 1202, 1203, 1183, 1208, 1211, 1214, 1216, 14884, 1217, 1218, 9340, 1219, 1220, 1389, 146767, 1222, 1225, 1237, 1252, 1254, 24459, 1259, 1261, 1265, 1266, 2634, 1271, 1262, 1277, 2635, 2823, 1283, 1285, 1286, 1400, 1419, 1456, 1463, 1467, 22231, 1469, 2985, 1471, 1478, 1486, 1487, 1511, 1512, 1513, 1473, 1515, 3199, 1295, 1296, 1300, 1302, 2674, 1304, 1306, 1516, 1311, 1314, 1316, 21567, 1318, 1324, 1328, 1319, 1556, 1558, 1559, 1562, 17785, 1564, 1337, 1339, 9412, 1347, 1671, 1349, 1356, 1565, 1703, 3374, 2506, 1615, 1567, 1636, 1637, 125070, 1364, 1365, 1366, 1369, 2203, 1373, 1375, 1377, 3858, 1667, 2676, 2581, 1672, 2837, 1714, 7255, 24478, 1675, 1677, 1679, 1682, 1684, 1687, 1673, 1683, 2198, 1685, 1390, 1393, 1395, 24863, 125071, 1696, 24484, 1740, 1748, 1796, 1801, 1803, 1808, 125072, 1594, 4199, 2730, 1522, 3101, 1411, 1416, 2766, 1544, 24114, 1900, 1921, 2191, 16116, 1922, 1925, 1869, 1426, 1503, 1504, 1526, 2961, 3084, 2046, 1532, 1528, 1536, 2733, 1543, 2152, 1550, 1551, 25478, 1582, 1586, 1588, 1604, 2751, 1606, 2735, 1608, 2311, 1627, 1635, 1612, 1643, 1772, 1776, 1644, 1647, 1664, 1666, 1702, 1724, 1733, 3859, 3226, 2960, 2316, 1760, 1762, 3813, 1764, 1769, 1768, 1781, 1782, 1804, 1811, 1815, 1822, 2834, 2288, 14780, 1867, 1868, 2755, 30614, 2149, 1927, 2762, 1890, 2758, 2175, 20278, 1933, 4790, 2207, 2211, 2218, 125075, 5346, 2318, 156629, 2329, 1979, 2037, 2151, 2150, 4053, 2159, 2158, 140502, 2043, 2184, 23996, 2080, 2084, 2076, 17603, 3514, 2087, 2102, 2103, 2700, 2109, 3205, 2321, 2122, 2128, 2685, 2144, 2162, 2170, 17906, 2188, 2194, 2195, 2415, 3206, 2435, 2224, 2971, 2598, 2247, 2477, 2536, 3214, 2253, 2264, 2270, 2268, 2269, 2272, 2275, 2277, 2290, 2289, 2293, 2325, 2326, 2308, 2330, 2334, 2337, 2340, 2342, 2347, 2322, 2354, 2357, 2881, 2361, 2359, 2363, 2370, 2366, 2372, 2349, 2384, 2388, 2704, 2379, 2675, 3212, 3029, 2410, 3225, 2456, 2464, 2467, 31770, 2471, 2472, 2474, 20698, 2475, 2476, 2558, 2541, 2482, 2489, 5230, 2465, 2497, 2492, 146276, 4689, 2509, 2510, 2503, 11333, 2518, 2520, 2527, 2531, 2535, 2539, 2869, 31773, 2543, 5071, 2550, 2574, 2589, 2590, 4224, 2876, 2882, 2600, 4389, 2811, 21532, 6843, 22566, 2603, 4412, 2610, 2606, 2658, 2708, 3256, 2723, 2729, 2732, 3887, 2948, 2951, 3004, 2885, 2896, 2899, 2903, 2916, 2902, 2919, 7263, 2915, 2917, 2777, 3922, 2798, 2780, 3124, 3894, 2936, 2940, 2944, 2952, 2958, 2805, 13970, 2806, 2875, 3927, 2812, 25359, 2819, 2810, 2814, 2838, 2969, 2970, 2974, 3003, 3008, 2858, 2862, 2865, 2868, 2866, 2872, 29470, 2878, 2883, 2889, 42587, 18338, 2931, 2933, 3085, 2941, 2959, 3260, 2968, 2977, 2990, 2992, 18455, 2994, 2995, 2997, 3011, 2980, 2991, 2998, 3018, 3017, 3020, 3021, 144994, 3024, 3025, 3097, 2508, 3031, 24894, 3038, 3033, 3043, 3045, 3906, 3245, 3923, 3075, 3477, 3369, 3376, 3410, 3455, 3392, 3467, 3099, 3100, 14127, 3102, 4415, 3104, 34254, 3471, 3078, 3079, 3080, 4390, 3125, 3142, 31776, 3453, 3145, 3393, 4409, 26236, 3113, 3119, 3118, 3318, 125216, 3148, 3140, 3153, 3152, 3155, 3491, 3496, 3502, 3312, 3530, 3192, 25529, 3542, 3544, 3559, 3591, 3601, 3609, 3168, 3461, 150806, 3169, 3176, 4586, 3246, 3251, 3261, 3253, 3265, 3287, 3294, 3280, 3302, 3307, 3308, 3309, 13580, 3314, 3316, 3292, 17247, 3362, 3372, 144762, 3413, 3388, 3418, 3429, 3431, 3433, 3438, 3442, 3444, 125217, 3448, 26489, 3476, 3517, 3519, 144763, 3446, 3449, 3912, 3437, 26209, 138515, 4492, 3473, 3495, 3498, 3637, 3511, 3510, 3679, 8125, 3488, 3655, 3527, 3531, 3810, 4301, 3533, 24244, 3536, 3541, 26306, 3543, 3550, 3552, 3558, 3564, 3574, 3579, 5200, 4520, 3561, 3806, 3799, 3639, 3796, 3808, 4289, 3603, 3686, 3623, 3627, 3613, 3839, 3865, 3636, 3646, 3647, 3848, 3667, 31083, 3668, 3669, 3524, 3674, 3673, 3676, 3684, 3692, 4302, 4203, 3696, 3702, 3704, 3708, 3715, 3716, 3717, 3725, 3735, 3738, 3745, 3915, 3763, 3526, 3765, 3748, 4356, 3783, 3866, 3888, 26331, 3890, 9643, 8412, 3834, 3853, 3864, 4036, 4309, 4042, 4086, 4138, 4195, 4204, 4577, 4307, 4129, 4206, 4583, 4208, 3930, 24190, 3933, 3940, 4258, 3942, 4209, 3946, 3951, 4215, 4218, 4231, 3945, 4230, 4236, 4825, 4237, 4684, 4683, 3957, 3959, 3979, 3988, 4321, 3990, 3991, 3974, 4352, 4005, 3998, 4249, 4015, 4824, 4024, 4026, 4028, 4029, 4030, 4033, 6126, 4621, 4354, 4325, 4386, 125218, 4044, 4049, 4051, 4056, 31289, 4057, 4106, 4717, 4108, 4060, 4055, 4288, 4144, 4062, 4417, 4088, 4089, 4459, 28880, 4090, 4104, 4112, 4114, 2928, 4118, 5145, 4131, 4136, 4135, 4140, 4184, 24193, 4580, 4147, 4151, 4158, 4172, 4174, 146459, 4525, 147435, 4177, 4720, 4443, 4715, 4180, 4349, 3044, 4194, 4202, 4210, 4227, 4235, 4255, 4260, 4265, 4263, 4269, 4225, 4229, 24743, 4271, 4287, 4308, 4395, 4397, 4399, 4323, 4403, 4402, 4418, 4420, 4421, 4427, 4445, 4447, 4457, 4439, 4460, 4521, 4612, 4615, 4629, 4630, 4472, 4473, 4671, 4477, 4478, 4479, 4481, 4485, 4711, 4703, 4510, 4710, 4540, 3547, 4650, 4658, 4661, 4483, 5089, 4662, 4682, 5649, 4691, 4700, 17829, 4714, 4843, 4528, 4535, 38708, 4542, 4544, 4740, 4524, 4747, 4751, 4784, 4555, 5648, 4560, 4749, 4688, 4763, 4785, 5478, 20072, 4811, 1406, 13481, 4561, 4574, 4595, 4563, 5341, 4597, 4611, 4639, 4642, 4604, 4657, 4673, 4678, 5106, 4889, 22480, 4697, 4701, 5074, 4712, 4734, 4819, 4746, 4769, 4770, 4771, 5311, 4798, 4818, 4953, 4955, 6133, 4996, 5002, 4799, 4812, 4815, 4816, 9749, 4942, 5006, 5029, 5038, 26636, 5062, 5099, 5218, 5219, 5286, 5290, 4839, 4864, 5291, 5102, 5112, 3555, 4886, 2947, 4894, 5535, 4939, 27438, 5343, 5295, 5300, 5305, 5307, 5310, 4835, 4841, 4848, 5315, 4851, 1231, 5317, 5320, 4881, 4883, 4882, 19816, 4892, 4893, 4896, 4897, 4900, 4902, 4976, 4903, 5326, 5329, 5337, 4911, 4905, 4914, 4918, 3731, 4921, 4928, 4930, 5339, 4927, 4994, 4971, 5340, 5342, 5344, 5345, 5348, 5355, 5767, 5357, 5110, 5165, 5232, 19526, 5360, 5616, 5363, 4935, 4936, 4944, 4954, 4945, 4969, 4512, 5049, 5053, 5063, 5065, 5079, 5271, 5081, 5086, 5092, 5096, 5149, 5178, 5528, 5111, 5117, 5118, 5119, 5120, 5122, 5131, 5132, 7800, 5134, 5140, 5142, 5147, 5155, 5156, 5157, 5162, 5180, 5172, 5173, 5194, 5196, 5198, 26863, 5203, 5207, 5208, 5023, 5209, 19256, 5211, 5212, 5214, 5215, 5216, 5225, 6135, 5229, 5227, 5238, 5231, 5249, 5251, 5248, 5254, 5256, 5260, 5262, 5263, 5024, 5261, 5244, 5275, 5279, 5280, 5905, 5292, 5294, 5296, 5321, 19550, 5366, 5430, 5498, 5505, 5789, 5507, 5934, 5513, 5516, 5517, 6129, 5518, 5368, 5369, 5382, 5532, 5372, 5373, 5375, 5379, 5729, 5540, 5547, 5548, 5543, 5901, 5549, 5551, 5385, 5794, 6898, 7117, 6131, 5386, 5388, 5390, 5393, 5395, 5396, 5741, 5757, 5739, 5417, 5441, 5443, 5446, 5448, 5452, 5453, 5983, 7681, 29509, 5466, 5450, 5455, 5907, 5482, 5537, 5891, 5652, 5791, 5592, 5593, 5594, 5600, 5814, 5856, 5932, 5867, 29294, 5868, 5872, 5871, 5870, 14201, 5986, 5990, 6301, 5995, 6004, 5866, 5877, 5603, 5928, 5992, 6127, 5945, 5953, 5963, 5966, 5968, 5975, 5972, 5982, 5150, 5631, 6015, 6022, 6006, 6256, 6044, 6052, 6053, 6125, 9012, 6139, 7334, 6141, 6143, 7478, 6147, 6149, 5674, 6408, 5599, 5676, 5687, 5670, 5672, 5689, 5770, 5772, 5775, 8172, 6073, 6882, 6072, 6160, 6357, 6155, 6167, 6178, 5694, 5700, 5715, 5724, 5751, 5750, 5754, 5762, 5765, 5933, 5778, 5786, 5800, 5804, 5815, 6687, 5817, 5821, 3855, 7958, 5820, 5808, 5810, 5811, 5812, 5837, 6024, 6026, 6032, 5243, 6019, 6025, 6029, 6031, 5851, 5853, 5855, 5859, 17065, 5865, 5864, 5900, 5909, 5913, 5915, 5929, 5944, 5955, 5960, 6075, 6083, 6113, 6115, 6168, 6174, 7819, 6200, 7820, 7735, 6239, 6190, 7903, 6404, 6191, 6192, 6193, 6273, 26129, 6275, 7843, 7833, 5362, 6751, 6317, 6330, 6339, 6342, 6370, 6381, 6430, 7831, 6410, 6485, 6488, 6489, 6490, 9604, 6213, 6214, 6216, 6219, 6224, 6492, 6230, 6236, 6248, 6268, 6476, 6414, 147377, 6527, 6434, 6272, 6274, 6278, 6288, 7821, 6296, 6412, 7175, 7844, 7846, 6371, 7904, 6391, 6394, 6397, 7985, 6415, 6420, 6421, 6396, 6439, 6443, 7633, 6440, 6464, 7253, 6466, 7987, 6471, 6473, 6474, 6579, 6586, 6589, 6497, 6600, 6665, 6683, 8708, 6686, 6704, 6710, 6660, 6675, 7778, 6727, 6728, 7171, 6730, 7790, 11527, 6848, 6503, 6504, 6739, 6745, 6747, 6759, 6813, 9371, 22531, 6515, 6946, 7806, 6520, 6640, 6529, 6986, 6989, 6993, 6997, 7001, 9614, 7003, 6543, 125219, 6568, 6571, 6606, 6560, 6612, 6624, 6659, 7566, 6947, 6661, 6664, 6666, 6672, 6673, 6674, 6676, 6854, 31607, 9157, 6690, 6694, 6696, 6707, 6740, 6742, 6744, 6764, 7571, 6921, 7670, 6777, 6780, 6789, 6791, 6795, 6807, 6833, 7933, 6847, 6861, 6903, 6909, 6910, 6919, 6920, 6975, 7943, 6937, 6945, 6953, 6954, 6979, 6960, 6967, 6966, 6969, 6971, 7121, 7124, 7134, 7014, 7965, 7968, 7168, 7181, 7048, 7256, 17222, 7192, 7209, 7068, 7188, 7073, 7075, 7082, 7089, 7474, 2297, 8263, 7086, 7095, 7072, 7076, 7148, 7219, 7185, 7257, 7230, 7320, 7321, 9309, 7371, 9312, 7274, 7667, 7462, 7471, 7482, 7277, 22535, 7486, 7492, 7491, 7496, 7859, 7865, 7304, 7309, 7291, 7300, 7354, 7508, 7874, 7630, 125220, 7887, 7634, 7964, 7895, 7901, 7917, 7503, 7919, 7682, 7323, 7324, 7327, 7330, 5445, 9776, 7331, 7336, 7944, 7956, 7668, 7980, 7345, 7347, 7979, 8003, 8023, 8030, 8032, 8033, 8036, 7351, 7356, 8691, 7359, 7363, 7408, 7409, 7410, 7413, 7414, 7692, 7415, 7826, 7421, 7422, 7428, 7841, 7439, 7432, 7605, 8423, 7459, 7461, 7463, 11896, 7497, 7527, 7533, 5988, 8149, 9179, 7532, 7536, 7538, 7873, 7577, 7586, 7595, 9777, 9177, 7619, 9332, 7649, 7650, 7686, 8229, 7733, 8114, 8140, 8066, 8085, 8083, 8097, 8098, 8103, 8115, 8161, 8170, 7455, 2783, 8235, 8219, 8169, 8335, 8448, 8514, 8425, 8555, 8576, 8588, 8594, 8600, 8601, 8607, 8608, 8609, 8592, 8876, 2303, 8178, 8180, 8628, 8634, 8640, 8661, 8664, 12825, 11176, 8688, 2996, 8695, 8698, 8702, 8205, 8237, 5522, 9787, 8252, 8919, 8265, 8271, 9797, 8291, 8276, 8307, 8310, 8315, 8355, 8363, 8362, 8366, 23930, 8373, 9368, 8385, 8399, 8843, 8329, 24230, 8847, 8849, 125221, 8864, 8850, 8894, 8409, 8865, 8841, 8339, 8342, 8347, 146599, 8401, 8407, 8408, 8426, 8437, 8440, 8405, 8443, 8442, 8454, 8455, 8458, 8462, 4150, 8467, 8477, 8481, 8482, 8488, 8497, 8502, 8480, 9292, 8643, 8507, 8535, 8554, 8557, 8581, 8617, 8618, 125222, 8726, 8623, 8620, 8624, 38784, 5524, 8626, 8641, 9723, 8665, 8671, 8825, 8830, 23928, 13099, 9758, 8080, 8683, 8722, 8690, 8754, 8756, 8774, 8794, 8797, 8798, 8801, 8803, 8923, 8929, 13276, 8818, 8851, 15251, 8915, 8917, 9159, 8924, 8934, 24236, 8957, 8889, 8510, 8898, 24002, 125223, 8914, 8215, 13248, 8931, 8969, 9690, 18847, 158956, 24129, 8978, 9497, 8992, 8960, 9058, 9078, 8962, 8961, 8963, 9299, 16149, 11027, 9501, 9086, 9124, 9691, 3340, 9145, 8972, 9154, 9156, 9188, 9210, 9213, 8977, 9268, 9725, 9295, 9061, 145485, 9401, 28234, 9425, 9449, 9451, 9561, 9597, 13333, 14573, 9688, 9646, 12169, 145026, 11253, 14409, 8983, 9471, 9478, 9480, 9529, 9531, 9537, 9539, 24124, 9548, 9543, 9544, 9555, 9026, 9010, 9629, 9673, 9059, 9077, 9158, 9186, 9195, 9197, 9202, 9237, 9189, 9241, 9248, 9261, 9263, 9271, 9244, 9285, 36345, 18038, 24122, 9493, 9520, 9526, 9554, 28236, 9581, 9582, 9595, 9596, 9624, 9634, 9606, 9650, 9651, 9652, 9756, 16537, 21552, 9748, 9759, 9761, 14802, 9792, 24395, 9796, 9700, 9804, 9709, 9729, 138145, 30928, 12216, 16245, 16538, 13058, 11762, 11022, 17383, 9732, 9734, 9760, 9741, 9775, 9788, 9762, 11137, 13788, 14342, 10755, 137829, 13222, 15562, 24189, 138319, 15488, 17947, 137832, 17122, 12528, 35066, 13168, 18306, 11988, 27620, 11458, 13003, 16180, 14132, 12443, 12243, 11062, 11061, 16575, 11006, 144772, 20297, 21783, 21232, 10615, 20057, 138334, 15598, 12428, 11184, 11906, 11336, 15474, 12451, 10533, 13352, 10687, 13635, 11456, 19080, 12339, 14112, 17148, 24003, 1480, 12481, 17302, 18520, 16306, 20280, 14708, 18401, 11500, 17635, 137834, 15013, 23734, 23744, 23753, 24424, 23919, 23931, 23937, 9757, 24299, 20611, 22151, 20910, 21184, 20443, 20350, 23791, 23805, 23830, 23831, 23828, 2935, 23845, 23853, 23738, 23739, 23987, 23948, 24007, 24012, 3336, 24031, 25746, 24034, 23874, 24037, 2964, 23991, 23866, 23871, 158946, 24032, 24039, 3271, 23749, 23747, 24038, 24057, 24060, 24063, 24065, 24083, 24085, 24134, 145779, 24136, 24399, 17684, 23761, 24170, 24177, 24180, 24182, 24187, 24201, 24199, 23780, 23781, 27941, 23858, 24500, 23869, 23882, 23884, 23860, 158967, 158968, 23777, 144701, 23785, 23788, 23790, 24243, 23793, 24250, 24348, 24341, 23806, 3338, 23817, 23821, 23823, 24697, 24394, 24420, 23911, 3720, 23941, 23922, 23990, 24006, 24080, 24407, 24082, 24117, 24144, 24145, 24430, 24273, 24514, 24575, 24292, 11497, 24305, 24320, 24627, 29313, 24328, 24349, 24379, 24396, 24409, 24411, 25915, 125226, 24446, 24570, 24839, 24520, 24461, 24463, 24766, 24482, 24608, 24630, 24642, 24624, 1646, 17428, 24489, 24511, 24515, 24999, 26375, 146359, 25782, 25932, 24587, 24593, 5526, 24609, 24628, 5819, 24701, 28383, 29505, 25542, 26502, 25545, 26741, 24716, 24638, 24698, 25082, 24646, 29070, 24780, 24784, 24786, 24790, 24797, 24807, 24819, 25677, 24821, 25668, 158965, 24835, 24837, 5708, 24853, 24845, 25924, 25147, 25460, 25499, 25584, 25590, 25594, 25664, 25477, 25667, 25676, 25445, 25539, 28526, 25555, 25560, 25550, 2618, 28886, 26481, 26750, 125082, 18559, 25802, 25803, 25567, 28428, 25577, 25586, 5527, 25808, 25607, 26698, 25613, 25589, 26427, 25969, 25591, 25801, 25792, 25785, 25790, 25918, 26501, 25794, 26434, 25651, 25693, 26326, 18851, 25692, 25695, 28954, 25728, 25720, 25772, 25777, 25922, 25944, 24254, 26479, 125412, 25811, 25949, 25957, 26319, 26276, 25899, 25982, 25991, 26033, 25947, 26053, 16763, 26093, 26100, 25970, 26010, 146766, 26101, 26487, 26068, 25818, 26356, 26203, 26206, 26441, 26461, 26471, 26476, 145753, 26493, 14041, 26687, 26565, 26574, 26581, 26583, 26596, 26598, 26600, 25854, 25885, 25891, 26059, 26931, 25908, 3583, 25948, 25959, 29804, 26196, 25972, 25979, 25981, 26004, 26003, 26016, 26018, 26031, 26032, 26554, 26049, 26055, 26054, 26142, 28413, 26422, 26384, 28437, 26202, 145267, 26204, 26747, 26212, 26207, 26231, 26133, 26537, 26540, 29761, 28425, 26676, 11817, 26462, 26464, 26468, 26475, 26910, 26753, 26478, 26524, 26523, 26529, 26532, 26533, 14437, 26812, 26589, 26683, 28181, 22450, 26822, 26585, 26751, 26781, 26707, 26915, 26714, 26613, 26752, 26759, 26913, 28245, 27408, 26611, 26671, 26774, 26862, 125229, 26605, 26779, 26936, 26919, 28511, 26615, 14224, 27241, 26788, 26728, 26740, 26815, 26612, 26618, 26829, 26835, 26849, 28385, 26859, 26866, 26869, 26870, 26640, 26647, 27249, 26649, 26641, 26663, 26664, 26418, 26749, 26754, 26756, 26766, 26775, 26778, 26982, 32301, 26784, 26790, 26780, 26793, 26875, 144804, 26798, 26807, 26935, 1707, 26872, 26821, 26805, 26937, 26828, 26890, 26893, 27067, 33339, 27237, 2352, 26836, 26837, 4223, 27022, 18700, 28419, 26852, 26907, 27403, 26929, 26960, 26857, 26858, 27091, 26873, 26874, 26997, 27004, 3070, 27039, 27042, 27044, 27048, 27049, 27056, 27060, 12042, 27063, 27065, 26884, 26885, 27092, 3087, 27246, 27251, 27016, 27253, 27094, 27096, 27121, 27105, 27252, 26901, 26904, 1649, 26908, 27223, 27239, 27337, 33717, 26986, 27364, 27365, 27034, 27259, 27312, 28447, 27318, 28731, 1650, 27321, 2481, 27322, 27266, 26925, 28390, 27347, 27015, 27342, 27343, 27355, 27362, 27376, 27377, 27379, 27381, 27358, 26938, 26943, 11072, 26945, 27446, 27448, 27203, 27456, 27506, 27470, 27265, 26989, 27025, 27028, 27030, 27033, 17098, 27118, 27129, 27130, 27144, 28166, 27145, 27254, 27974, 28117, 9135, 27227, 27229, 27231, 27235, 27238, 27263, 28586, 27236, 27244, 27119, 28421, 27320, 27324, 27288, 1519, 27768, 27328, 27344, 27944, 27356, 27389, 27400, 27844, 27407, 27411, 27417, 27426, 27430, 27432, 27437, 27453, 27726, 27465, 27404, 27946, 28488, 27568, 27480, 28221, 27482, 27485, 30626, 27492, 27493, 27498, 27840, 27500, 30037, 27505, 27520, 27600, 27525, 27769, 27710, 27770, 27784, 27787, 16261, 27951, 27679, 144995, 28331, 28056, 28031, 1651, 27848, 27837, 27558, 27561, 27606, 27615, 27670, 28432, 27713, 27716, 28030, 18376, 27763, 27782, 27790, 27817, 28175, 28914, 27655, 27896, 27904, 27933, 27833, 28179, 27947, 144745, 27671, 27674, 27675, 27676, 27943, 27956, 27977, 4981, 28302, 28035, 28038, 28257, 28046, 28052, 28077, 31620, 27684, 27692, 27693, 27695, 27697, 27699, 28094, 28195, 28085, 28087, 28497, 28101, 28107, 28108, 28395, 28110, 28116, 28159, 27704, 27705, 27706, 27707, 28404, 28121, 28124, 28185, 28188, 28216, 3112, 27988, 28565, 28218, 28219, 28322, 4226, 28325, 28342, 27841, 28344, 27746, 27748, 27751, 27752, 27815, 31718, 27827, 28303, 27828, 28941, 14673, 28054, 28010, 27829, 27830, 27831, 27853, 27906, 27910, 27914, 28379, 3115, 27942, 27971, 27983, 27985, 28176, 28005, 27938, 125231, 28063, 28095, 28104, 28122, 28154, 28180, 28223, 28228, 28240, 28262, 28453, 28267, 28279, 28280, 28286, 28346, 28386, 28387, 28643, 28638, 28393, 28454, 28406, 28459, 28953, 28582, 28732, 28498, 28861, 28525, 28585, 28641, 28584, 28501, 28502, 28514, 28819, 28958, 28520, 28468, 30472, 28545, 28548, 28566, 3608, 28571, 30090, 28669, 28645, 28647, 28372, 28382, 28384, 28822, 28864, 28388, 28959, 30031, 28482, 28492, 24222, 28536, 28546, 30482, 30087, 125232, 28597, 30084, 30109, 28619, 28620, 28621, 17614, 28633, 28977, 4228, 28867, 29166, 2580, 29071, 28868, 28869, 29531, 28848, 28896, 29109, 28664, 28680, 30112, 31406, 28901, 145681, 28915, 28923, 30148, 28930, 28728, 28807, 30047, 28933, 28683, 28689, 28942, 28944, 28956, 28685, 28969, 30110, 30111, 28829, 28978, 28981, 28984, 30115, 28986, 24221, 28991, 28995, 29000, 29003, 28699, 28706, 28707, 28993, 28696, 28745, 3610, 28711, 28712, 138626, 29807, 29038, 29039, 29040, 4931, 29054, 28955, 28730, 35106, 28735, 28736, 28737, 28739, 28742, 28743, 28744, 30379, 28754, 28759, 28760, 28762, 28763, 29058, 29069, 34176, 28767, 28768, 29075, 3109, 28770, 28772, 28776, 28780, 28766, 28784, 29116, 29117, 29118, 29114, 29121, 28842, 4932, 29281, 29127, 28791, 28798, 28800, 28808, 3522, 28809, 30021, 28818, 28820, 28827, 28830, 29081, 11810, 28835, 28837, 28838, 28839, 30039, 24260, 28897, 28908, 28957, 28992, 29011, 29024, 29028, 29037, 29491, 30057, 31603, 29060, 29087, 29098, 29099, 29100, 29101, 29132, 29135, 3282, 29138, 29140, 29146, 29149, 29155, 29535, 29154, 29158, 29159, 29161, 29280, 144930, 29282, 30075, 29229, 30078, 29285, 29311, 21481, 29446, 29312, 29164, 4685, 29169, 29800, 3516, 29171, 29679, 29332, 29173, 29337, 144850, 29475, 29344, 29345, 29346, 29347, 29349, 29178, 29370, 7788, 29525, 29529, 29534, 30232, 31360, 29536, 29538, 29388, 29748, 29467, 29521, 29180, 29181, 29184, 29372, 29190, 29192, 29194, 29524, 29198, 29199, 30072, 29539, 5962, 29540, 29541, 29547, 29551, 29619, 29210, 30380, 142325, 5169, 29233, 29557, 29248, 3713, 29272, 29566, 29569, 29252, 29254, 29341, 29391, 32517, 29400, 7753, 29257, 29263, 29265, 29264, 29441, 29862, 29274, 16428, 29275, 29503, 29287, 29674, 29329, 29662, 29342, 29950, 29409, 29413, 30248, 29420, 29433, 29439, 3341, 29448, 29451, 29577, 30236, 29479, 31900, 29570, 29568, 29647, 29484, 30254, 29489, 29495, 29692, 30092, 29497, 29858, 29578, 30408, 29711, 29554, 29758, 29567, 30880, 29671, 29682, 29684, 29686, 29688, 30402, 29701, 7504, 29575, 30400, 29576, 29745, 29779, 29784, 29787, 29786, 18804, 29788, 29792, 29596, 30418, 29588, 29808, 29881, 30517, 30428, 29887, 4984, 29891, 29854, 146568, 32550, 30438, 29893, 29895, 29897, 29898, 29900, 29905, 29907, 29607, 29608, 29609, 29909, 29921, 29864, 3883, 29944, 29952, 29670, 29954, 29958, 29938, 29962, 29961, 26432, 29811, 29978, 5403, 29963, 29964, 29966, 29969, 20283, 30016, 29971, 29617, 29620, 29631, 29640, 29641, 29643, 29644, 29824, 29825, 29995, 30001, 30008, 29860, 29648, 29661, 30329, 29677, 124719, 30321, 30322, 29815, 29818, 29844, 29851, 30604, 29989, 30360, 23509, 159188, 3653, 30083, 30323, 29725, 30333, 29735, 29734, 30335, 29736, 5469, 30337, 29742, 29751, 29754, 29831, 29803, 29840, 29845, 29855, 29868, 29871, 30609, 29872, 29874, 29988, 30451, 29876, 29875, 29880, 29884, 29866, 29922, 29923, 29928, 29934, 29936, 29937, 30004, 29946, 31154, 30395, 30128, 29984, 29985, 29943, 30251, 30789, 29994, 30269, 30457, 30575, 30026, 30053, 30130, 30131, 30134, 25596, 30245, 30247, 30250, 145769, 30255, 30253, 30285, 30304, 30310, 30412, 2622, 30941, 30415, 30413, 20406, 30465, 30561, 30563, 30368, 30477, 30518, 30280, 30520, 30524, 159224, 146411, 3767, 30527, 30562, 30537, 30541, 32025, 30555, 27576, 30566, 30568, 30290, 30291, 30296, 30299, 30303, 36320, 30569, 30311, 124529, 3345, 30339, 30348, 30297, 31981, 30364, 30374, 30376, 30377, 30589, 30985, 30712, 146200, 30962, 30437, 3753, 30439, 31869, 30441, 30442, 30448, 30669, 30464, 30468, 30475, 30528, 31797, 30534, 30540, 30624, 30898, 30637, 30628, 31096, 30676, 30696, 125087, 30698, 30710, 30715, 30730, 30751, 30756, 30728, 146201, 30737, 30734, 30736, 30833, 32127, 30917, 30923, 20701, 30747, 30758, 158970, 30765, 32111, 30784, 30786, 30788, 30794, 30806, 7252, 30823, 30867, 30924, 30931, 30933, 31291, 30606, 30772, 9013, 30610, 31078, 30990, 31007, 31011, 31013, 30638, 31012, 26268, 31014, 158963, 31015, 31060, 31790, 4704, 30617, 31115, 31125, 31156, 31158, 31166, 31881, 31178, 30879, 30651, 30664, 31584, 30666, 30630, 30633, 30699, 30779, 30932, 30938, 30964, 30785, 30825, 31307, 30829, 30787, 31484, 30930, 30891, 31064, 30897, 30902, 30970, 31518, 2784, 31021, 31475, 31028, 31040, 31070, 31091, 31077, 31357, 31122, 35007, 31143, 31181, 31131, 31203, 31244, 31578, 31240, 31266, 31337, 31341, 31355, 18907, 31191, 31471, 31474, 31375, 31376, 25144, 31381, 18939, 16431, 31705, 31386, 31237, 31312, 159106, 31308, 31322, 31319, 31346, 31351, 31571, 31378, 31388, 31610, 31434, 33035, 31414, 31416, 31440, 31441, 31934, 31590, 31451, 31467, 31439, 31443, 31469, 31566, 31544, 31497, 31565, 2284, 31573, 31611, 31612, 31622, 31624, 33036, 31574, 31575, 31576, 31577, 31623, 31629, 31594, 31583, 31585, 31579, 31482, 31485, 31487, 31783, 31785, 31598, 31601, 31604, 31618, 31505, 31524, 31632, 31676, 31677, 31646, 31649, 31683, 31670, 31758, 31765, 31803, 36298, 31875, 31885, 31917, 31878, 31927, 31945, 31586, 31684, 31686, 31962, 31687, 32906, 31685, 31696, 26071, 31703, 31750, 31788, 31753, 31821, 31810, 125972, 3657, 31831, 31836, 31948, 32032, 31850, 32087, 32101, 31846, 31870, 31882, 31884, 31891, 32021, 26272, 25536, 32020, 32524, 31894, 18586, 31897, 31906, 2727, 31947, 31949, 24481, 32326, 31963, 31972, 31988, 31990, 31993, 31985, 32049, 32148, 32078, 32277, 32260, 21137, 18967, 32296, 32003, 125089, 32062, 32071, 31992, 32108, 32123, 31996, 31997, 32113, 7762, 32542, 31998, 31999, 32426, 32314, 32004, 32005, 32007, 32122, 32126, 32165, 8134, 32013, 32017, 32018, 32424, 32090, 32092, 32104, 32086, 32134, 32114, 32420, 32139, 32533, 32177, 2261, 32307, 32333, 33033, 32334, 32313, 32394, 32399, 32403, 32450, 32749, 32405, 32407, 32412, 32397, 24653, 32435, 32439, 32442, 32465, 32444, 32466, 32685, 32447, 32449, 32454, 4565, 32338, 32481, 32930, 32522, 8527, 32527, 32531, 32532, 9414, 32388, 3207, 32536, 32537, 32538, 32408, 32421, 20255, 32539, 32541, 32772, 32352, 24654, 32353, 32354, 32363, 32365, 32368, 32746, 32569, 32366, 33402, 32545, 32395, 32436, 32755, 32570, 32578, 32373, 26373, 32376, 32377, 32587, 32589, 4995, 32661, 128063, 32382, 32390, 32391, 32404, 32406, 32490, 150640, 32440, 34194, 32443, 32446, 33878, 32459, 32467, 32472, 32474, 32476, 32480, 32484, 32503, 32508, 32509, 32510, 32511, 32512, 32514, 32563, 32588, 32697, 32807, 32827, 32843, 32805, 32869, 32879, 32711, 32708, 32715, 125974, 32897, 32898, 33247, 32902, 32911, 33438, 32778, 34286, 5176, 32561, 32994, 33020, 33022, 33028, 33029, 33030, 33031, 32790, 902, 32971, 32957, 32963, 33258, 33836, 32815, 33013, 33042, 33087, 33097, 33136, 33159, 33101, 2832, 32817, 33259, 32846, 32852, 32875, 32878, 33562, 32896, 32901, 32910, 32886, 32913, 3755, 32924, 2910, 4998, 31127, 32981, 33254, 33100, 34037, 32983, 32995, 33004, 33007, 33016, 33005, 1258, 33023, 33025, 33925, 33082, 33250, 1545, 33126, 33139, 33164, 33179, 33161, 33279, 1269, 33290, 33292, 33305, 33370, 33436, 33313, 33338, 11467, 34430, 33246, 33418, 33282, 33281, 33315, 33318, 33322, 33628, 33694, 33734, 33439, 33455, 33736, 33892, 158989, 33325, 33326, 34625, 33333, 36003, 36007, 35035, 34031, 33363, 33365, 33866, 34163, 34281, 34383, 24869, 125073, 34415, 33936, 34110, 1699, 36487, 34629, 34046, 34164, 34627, 34609, 7374, 34169, 34118, 34120, 34122, 34241, 34130, 34149, 34140, 34141, 34419, 34451, 34504, 34510, 34520, 34596, 34607, 34624, 34655, 34657, 34407, 34444, 34476, 34478, 34567, 34595, 34606, 34611, 34638, 34646, 35018, 35022, 2285, 26266, 35025, 4154, 35034, 35032, 35039, 35049, 34438, 35069, 35072, 35079, 35091, 35030, 32173, 32171, 35101, 35105, 32961, 32568, 24655, 35127, 30270, 35117, 35125, 9134, 35132, 32904, 32575, 25375, 33158, 33182, 33271, 32479, 3184, 32161, 31242, 32311, 33283, 33267, 33268, 35031, 35134, 159685, 33274, 25404, 35154, 984, 33260, 135640, 33306, 33304, 33265, 33298, 33865, 33289, 33316, 35136, 35139, 33634, 33854, 146265, 35159, 18695, 35160, 35161, 35162, 35177, 35122, 35138, 33855, 33880, 9361, 35646, 35224, 5502, 25325, 18935, 34628, 35205, 35210, 6725, 33845, 33903, 33912, 33642, 33907, 32591, 33632, 21259, 33906, 3757, 35299, 35229, 7694, 3925, 26430, 33721, 33732, 33733, 33705, 33703, 33596, 25330, 33006, 35230, 35241, 135641, 1264, 33856, 33549, 33577, 33556, 33622, 34401, 34402, 35128, 135642, 35172, 33320, 33512, 33627, 34470, 33560, 25025, 33567, 33620, 33588, 33589, 33591, 33602, 36297, 35564, 33890, 33640, 35883, 25377, 26512, 33487, 33569, 33493, 33496, 33144, 7784, 33598, 33597, 33533, 33534, 33535, 34328, 33585, 35941, 1260, 31824, 5353, 33454, 33681, 33668, 35821, 33435, 33656, 33645, 34258, 32978, 33650, 6461, 33641, 35861, 6046, 35554, 7715, 33421, 33636, 35246, 36287, 33633, 33718, 33540, 34652, 125062, 35063, 35610, 33707, 33564, 33003, 135643, 33623, 33575, 33194, 22783, 33582, 33583, 34623, 35033, 35644, 32832, 32452, 33121, 135644, 31616, 32159, 32140, 32042, 35158, 35930, 32044, 34360, 9393, 31651, 31656, 31626, 35203, 35144, 35801, 35806, 35170, 34179, 35208, 35028, 35040, 36329, 33554, 35131, 35200, 35201, 35658, 35681, 35046, 28134, 34653, 35956, 35050, 34644, 35340, 35637, 35639, 35642, 35648, 35652, 35656, 35657, 25274, 35976, 35999, 35716, 12554, 36119, 35743, 35749, 35752, 1272, 35760, 35862, 35865, 35390, 35392, 35872, 35882, 10512, 36009, 36010, 36026, 25213, 36036, 36056, 36059, 36085, 35345, 35346, 35362, 35513, 35396, 35434, 35436, 35438, 135645, 35449, 35450, 36120, 35495, 35496, 35574, 35498, 35499, 35500, 27851, 35512, 35516, 35519, 35520, 35525, 10282, 35270, 24899, 36122, 34349, 35286, 36243, 32276, 146266, 35190, 3873, 35766, 36016, 35609, 35972, 35775, 35748, 35559, 35565, 35562, 34423, 35195, 35667, 35156, 24902, 24903, 35683, 35058, 24965, 35053, 36273, 36286, 35567, 28137, 36054, 34651, 2627, 35179, 35076, 34523, 24904, 24908, 35026, 36296, 3257, 35654, 35685, 33871, 35802, 35597, 35600, 135972, 35591, 35617, 35583, 35593, 35493, 26073, 36314, 36316, 35317, 35641, 17806, 35738, 35820, 35772, 35771, 14389, 16389, 35163, 35199, 35895, 35477, 27864, 35274, 35276, 36509, 35337, 35413, 35622, 35524, 35736, 36326, 36002, 1405, 35898, 36300, 35238, 35287, 3131, 35815, 2559, 35836, 34316, 35319, 35060, 35410, 36299, 35605, 34302, 35856, 34216, 35789, 35088, 35880, 35824, 35547, 36336, 35682, 35653, 1273, 35718, 33396, 35928, 34498, 36205, 3129, 33946, 34408, 36217, 33394, 32160, 36359, 34242, 36363, 160343, 6462, 34416, 34556, 36100, 35064, 33704, 3360, 32706, 32923, 36232, 36185, 35997, 35949, 25008, 36136, 1275, 160354, 146478, 35817, 36332, 35938, 35875, 35868, 35860, 135973, 35858, 35878, 35881, 35278, 35962, 1274, 35977, 125074, 5376, 34180, 36476, 34610, 160359, 34446, 34602, 35707, 33314, 36046, 36321, 36052, 36271, 34422, 35182, 35356, 35167, 36145, 36407, 36151, 25226, 147397, 35699, 35196, 6518, 35175, 35151, 35240, 35869, 35924, 36372, 24595, 36254, 35358, 35226, 35399, 35322, 2697, 35855, 35192, 35211, 35212, 36042, 35164, 35207, 35488, 33329, 35121, 36090, 25428, 35946, 36366, 36409, 36410, 32757, 160366, 29896, 35937, 24656, 36027, 35353, 36517, 125016, 36520, 36497, 35479, 30179, 1168, 36515, 25014, 1355, 25250, 25822, 36118, 34474, 35100, 8038, 36448, 35852, 35293, 35021, 35209, 36512, 1376, 35491, 36285, 1505, 1713, 35016, 35019, 1247, 35090, 35024, 35294, 35102, 35704, 35690, 35351, 35886, 35887, 35909, 35990, 26301, 35133, 35289, 35455, 35236, 25316, 25429, 35756, 6519, 35696, 35966, 35728, 35912, 35081, 35082, 35848, 24787, 36538, 36107, 35521, 21489, 2698, 35684, 35315, 35290, 35915, 35306, 35176, 35218, 24789, 36112, 36183, 36171, 36212, 36426, 36427, 25358, 36440, 25433, 36460, 36424, 35118, 36473, 35913, 36485, 6048, 24678, 25361, 25279, 25321, 25363, 25469, 5579, 25470, 6626, 1015, 25362, 25364, 25367, 25366, 2647, 2216, 19471, 25282, 25407, 25416, 25212, 25369, 25376, 25378, 25414, 25420, 2646, 25423, 25424, 25368, 25432, 25374, 25384, 25392, 25395, 25396, 25268, 25418, 25412, 12509, 26443, 1162, 1164, 25349, 14600, 25357, 1111, 1112, 25236, 1114, 25126, 968, 25290, 26453, 2665, 25271, 25302, 25194, 6050, 7991, 25253, 25049, 25260, 1093, 25119, 25123, 1096, 27481, 24966, 24969, 1280, 26760, 25135, 25157, 1086, 24926, 1080, 1082, 1084, 24970, 24949, 24887, 24958, 24960, 24964, 9422, 25122, 124488, 24948, 24973, 8598, 24975, 24978, 25020, 124483, 24824, 24680, 24940, 26125, 24942, 24957, 24961, 7034, 24986, 1281, 24991, 19446, 24988, 24995, 25000, 26151, 24893, 26166, 25016, 1036, 25018, 25019, 24791, 25001, 26171, 25004, 25005, 25006, 26174, 26271, 25071, 25114, 21516, 26216, 26347, 26348, 25003, 25007, 6562, 25041, 1044, 25132, 25134, 26184, 25068, 25069, 25070, 26345, 25073, 25083, 25088, 25092, 25087, 25072, 1019, 151078, 9419, 1021, 1023, 1026, 25099, 25100, 25104, 26393, 26425, 876, 25098, 24706, 11683, 1206, 950, 1032, 1034, 1037, 1039, 2677, 1042, 1045, 1046, 1047, 1056, 24658, 12028, 2629, 1058, 1061, 24705, 1062, 1070, 1072, 2625, 26218, 25077, 1073, 24713, 26220, 2608, 1059, 6590, 26107, 1006, 1007, 2623, 26176, 24659, 26188, 16273, 11858, 26112, 1009, 26120, 26401, 26407, 28415, 26415, 2630, 25165, 1018, 9542, 7675, 26191, 24704, 24707, 26309, 24664, 2678, 24710, 24718, 26242, 26243, 28410, 1173, 26428, 25177, 26435, 1004, 26448, 24796, 1012, 24660, 26127, 24661, 24681, 8208, 26152, 26185, 24700, 24721, 1020, 24722, 24725, 24738, 26245, 24740, 24765, 24771, 26250, 26251, 8781, 26259, 24778, 26260, 24779, 24663, 24675, 24781, 24783, 26275, 26277, 26279, 26282, 26351, 15490, 7780, 26286, 1175, 26285, 26289, 26290, 26292, 1031, 26295, 26297, 25076, 24785, 26302, 24803, 26310, 24806, 1186, 24810, 24812, 1481, 24814, 1200, 24816, 26312, 26317, 24820, 26318, 26382, 1109, 1120, 1123, 1125, 1279, 1085, 1091, 1127, 1128, 1188, 1189, 1134, 1156, 35489, 26359, 6536, 26335, 26338, 24862, 17452, 26352, 26354, 24870, 1201, 26360, 26363, 26364, 26376, 26368, 24872, 27575, 26372, 953, 26374, 904, 6537, 24881, 1160, 909, 24886, 24888, 915, 916, 924, 925, 940, 1255, 2693, 2671, 986, 1136, 1138, 1148, 1149, 1150, 1151, 1152, 1154, 1163, 146855, 1169, 1170, 1178, 1181, 1182, 1184, 1282, 125119, 1185, 1197, 1204, 1207, 1210, 1213, 1215, 1221, 1223, 1224, 1226, 1227, 1228, 1701, 1343, 1229, 1236, 1241, 1242, 1243, 1245, 1246, 1284, 1501, 1325, 1249, 1253, 1408, 2205, 1744, 1479, 1484, 1510, 1291, 1509, 1322, 1323, 1326, 1327, 1563, 1514, 1294, 1297, 1299, 1301, 2691, 1308, 1346, 1350, 1742, 2637, 1310, 1313, 2639, 1521, 1557, 1560, 1779, 1561, 1330, 1332, 2662, 1338, 1342, 1344, 2230, 1351, 2663, 2169, 1358, 1911, 1569, 1613, 2982, 1619, 1621, 1623, 1767, 1331, 1628, 1549, 1648, 1362, 1367, 1370, 1371, 1374, 1398, 1718, 2302, 1746, 1418, 1655, 1657, 1659, 1661, 1805, 1663, 1766, 1674, 3217, 1378, 1681, 1688, 1689, 1690, 1394, 2852, 2579, 1797, 1800, 1802, 1806, 1410, 20546, 20628, 2251, 1554, 1412, 2636, 1414, 1415, 3186, 1441, 1420, 2962, 2772, 1525, 2115, 1885, 1421, 1422, 20530, 1555, 1425, 1428, 2701, 1431, 1999, 1435, 1437, 1438, 1442, 1443, 1446, 1451, 2680, 1775, 3083, 159065, 1777, 1466, 2725, 1470, 1485, 1500, 1506, 15231, 1609, 1726, 1518, 2237, 1523, 1530, 1531, 1535, 8784, 1540, 1541, 4294, 1574, 1575, 1577, 1589, 1592, 1599, 1600, 1603, 1625, 6227, 1633, 1638, 1730, 1731, 7151, 1639, 1640, 17130, 1642, 1654, 1658, 2741, 2743, 1700, 2745, 1706, 1709, 1662, 1722, 2748, 1727, 7913, 2215, 1728, 1729, 2984, 1734, 1717, 1738, 1741, 3023, 2208, 3879, 1870, 5025, 1747, 1749, 2156, 1751, 1757, 3081, 1759, 2055, 2110, 1758, 1761, 1763, 1774, 1780, 1818, 1817, 1823, 1828, 1852, 1854, 1855, 1856, 2986, 2126, 1926, 5919, 2010, 2124, 4432, 2028, 1934, 2036, 2125, 2176, 137838, 2178, 2196, 2199, 2201, 2200, 2220, 26128, 2672, 2688, 1952, 2282, 3955, 3202, 4575, 1969, 1975, 1980, 1960, 3218, 3219, 4213, 1989, 2681, 2002, 2035, 1997, 1988, 1990, 1993, 2053, 2054, 2130, 2131, 2132, 2888, 3938, 2427, 2058, 5950, 2088, 2089, 2090, 2091, 2092, 2154, 2093, 2094, 2358, 2095, 2097, 2085, 2105, 2107, 2119, 3721, 2134, 2135, 2136, 2553, 2137, 2430, 146184, 3227, 2129, 2138, 2148, 2155, 2157, 8451, 2163, 2165, 2168, 2174, 2177, 2181, 2179, 2183, 2187, 2189, 2684, 2190, 2222, 2419, 2423, 2425, 3618, 2428, 2431, 2432, 2238, 2436, 2434, 2438, 2437, 2441, 2219, 2225, 2709, 2227, 2615, 2223, 2232, 2248, 2231, 2235, 2234, 2241, 2244, 2324, 2245, 2312, 2246, 2243, 2439, 4576, 2444, 2446, 2453, 2287, 2301, 2305, 2252, 2250, 2258, 2260, 2266, 2265, 2313, 2314, 2274, 2271, 2276, 2278, 2279, 2281, 2599, 2602, 2607, 3861, 2295, 2299, 2309, 2310, 2328, 2327, 2331, 2339, 2341, 2344, 2343, 2345, 2346, 2348, 2350, 2351, 2396, 2355, 18934, 2356, 2360, 146242, 2494, 3088, 2369, 2373, 2374, 2376, 2378, 2382, 2383, 2649, 2386, 7153, 2389, 2390, 2392, 2393, 2394, 2397, 2398, 3278, 2487, 2493, 2528, 2404, 2406, 2650, 2450, 2455, 2460, 2459, 2457, 2462, 2461, 2463, 2466, 2468, 2470, 2478, 2479, 2480, 2484, 2752, 2485, 2654, 2491, 2496, 2500, 2499, 2505, 135208, 2504, 2514, 2512, 2515, 2516, 2517, 2519, 2513, 2521, 2524, 145775, 2764, 2525, 146134, 2530, 2526, 13858, 2534, 2538, 2699, 3823, 2546, 2551, 2552, 2554, 2555, 2556, 2560, 2561, 2564, 34518, 2566, 2666, 2568, 2569, 2573, 2586, 2587, 2588, 2591, 2592, 2593, 2596, 3905, 2611, 2626, 2638, 2655, 2906, 3072, 3889, 2879, 2842, 2661, 2710, 2711, 2887, 5587, 2715, 2717, 2642, 2728, 2734, 2742, 2744, 2746, 2771, 2770, 2824, 2907, 2943, 2757, 2760, 2781, 2870, 2761, 2884, 2886, 2890, 2894, 160525, 2895, 2900, 2914, 2913, 2918, 2920, 2922, 11581, 2897, 2769, 2965, 2972, 2973, 2773, 2788, 2792, 2793, 2797, 3891, 2800, 2938, 2942, 2953, 5732, 2803, 2807, 2813, 2816, 2818, 2826, 2821, 2822, 3082, 2825, 2827, 2831, 2835, 2909, 2830, 2840, 2841, 2967, 3005, 3006, 3009, 3554, 3010, 2845, 2880, 3149, 2893, 3073, 2901, 2854, 2908, 2929, 2976, 2978, 2993, 2844, 2848, 2912, 2923, 2925, 2926, 2850, 3062, 3013, 2851, 2853, 2855, 2857, 2859, 2863, 2864, 3000, 3012, 3014, 3015, 3002, 3193, 3195, 3197, 3209, 3210, 3231, 3127, 3233, 3237, 3046, 3047, 3048, 3049, 3050, 3051, 3052, 3053, 3123, 3269, 3016, 3019, 3022, 3026, 3028, 3030, 24684, 3035, 3036, 3032, 3037, 3161, 3183, 3185, 3187, 3191, 3054, 3055, 3056, 3057, 3058, 3862, 3060, 3270, 3272, 3273, 10584, 3274, 3275, 3324, 3342, 3344, 3346, 3347, 3348, 160459, 3352, 3063, 3068, 3456, 3069, 3071, 3074, 4375, 3355, 3357, 4347, 3361, 3364, 3371, 3108, 3122, 3370, 3126, 3400, 3402, 3403, 3407, 3406, 3409, 3464, 3089, 3090, 3092, 3091, 3096, 3098, 3103, 3106, 3105, 3120, 3130, 3135, 3138, 3144, 3150, 24598, 3151, 3156, 3157, 3854, 3578, 3158, 3479, 3493, 3593, 3494, 3499, 3850, 3503, 147305, 3509, 34351, 4423, 3549, 3569, 3571, 3575, 3576, 3481, 146243, 3580, 3581, 3584, 3586, 3589, 3587, 3786, 3599, 3597, 3600, 3602, 3604, 3592, 3605, 3606, 3259, 3399, 18571, 3267, 4372, 4359, 3165, 3174, 3190, 3194, 7580, 3196, 3863, 3230, 3238, 3788, 3242, 3944, 3250, 3892, 3249, 3897, 3255, 18339, 6963, 3898, 3264, 3263, 3305, 3266, 3276, 3281, 3279, 3284, 3283, 3286, 3285, 3288, 3907, 5646, 3291, 3296, 3299, 3304, 3322, 3327, 4588, 3298, 3300, 3311, 3313, 3306, 3335, 3380, 3379, 3315, 3317, 3321, 3319, 3412, 3411, 3415, 3532, 3320, 3328, 4589, 3332, 3375, 2424, 3334, 3910, 3358, 3366, 3368, 3416, 3421, 3534, 3792, 1191, 3384, 3396, 3398, 3422, 3901, 3920, 3615, 3367, 3373, 10949, 3382, 3383, 3482, 4335, 3487, 3385, 3390, 3391, 3394, 4232, 3535, 3427, 3428, 3430, 3432, 3434, 3902, 3903, 3440, 3443, 3489, 3500, 3521, 3523, 3525, 3790, 3540, 3546, 3548, 3553, 3556, 3650, 3652, 3811, 3611, 3560, 3563, 3565, 3566, 3644, 3568, 3624, 3572, 3632, 3798, 3802, 3803, 3805, 3809, 3841, 146192, 3616, 3625, 3626, 3677, 3629, 3630, 3631, 3939, 3822, 11164, 3837, 6039, 3651, 3654, 3838, 2418, 3842, 3844, 5073, 3847, 3836, 3671, 3672, 24600, 3675, 3869, 3872, 3877, 3880, 3691, 3882, 3633, 3635, 3638, 3642, 3641, 3643, 3664, 3665, 3670, 4338, 3680, 3681, 3685, 3687, 3689, 3690, 3694, 3693, 4216, 3724, 3718, 3727, 3726, 7480, 3729, 3730, 3733, 3734, 3960, 3683, 3697, 3698, 3705, 4736, 3746, 3749, 3747, 4211, 3750, 3751, 3754, 7584, 3707, 3712, 3714, 3913, 3737, 3916, 4339, 3743, 3744, 3742, 3831, 3756, 3758, 4590, 3762, 3773, 3950, 3761, 3778, 7567, 3779, 4246, 3785, 3814, 3817, 3818, 3821, 3824, 3827, 3958, 3961, 3829, 3832, 3833, 3870, 3881, 4490, 3885, 3886, 11013, 4219, 4220, 4240, 4243, 4244, 4730, 3993, 3893, 5957, 3962, 3964, 3965, 147315, 3921, 3928, 4192, 4197, 3932, 3934, 3936, 13860, 3943, 3948, 3970, 3952, 3954, 4212, 3994, 3995, 3996, 5572, 4245, 4238, 4292, 3968, 3969, 3971, 3972, 3977, 4489, 3978, 3980, 3983, 3987, 3984, 3989, 4250, 20345, 4252, 4251, 4253, 4293, 4004, 4006, 4008, 4304, 4010, 4598, 4011, 4014, 4016, 4165, 4017, 4018, 4021, 4023, 4022, 4027, 4345, 4355, 4025, 4032, 4031, 4034, 4035, 4259, 4286, 4290, 4291, 4295, 4296, 4297, 4037, 4040, 4041, 4709, 4167, 4365, 4310, 4317, 4582, 4324, 4328, 4360, 4362, 4082, 4130, 4363, 5684, 4093, 4364, 4366, 4058, 4368, 5075, 4592, 4600, 146355, 4388, 4043, 4503, 4046, 4214, 4383, 4074, 4075, 4078, 4081, 5247, 4084, 4085, 4221, 4414, 4087, 4092, 4094, 4095, 4591, 4713, 4111, 4396, 4281, 4437, 4438, 4385, 4045, 4048, 4050, 4061, 5644, 4065, 4067, 4070, 4069, 4071, 4072, 4098, 4155, 4157, 4096, 4100, 4101, 4164, 4109, 4113, 4609, 4116, 4166, 4168, 4610, 4133, 4425, 4426, 4119, 4121, 4156, 4160, 4188, 4159, 4123, 4125, 4120, 4656, 4169, 5626, 4428, 146354, 4705, 4706, 4126, 4602, 4132, 4964, 4141, 4139, 4161, 4163, 4280, 17896, 4262, 4171, 4173, 4178, 4181, 4185, 4187, 4424, 4190, 5645, 4191, 4282, 4796, 4797, 4193, 4196, 4247, 4311, 5136, 4606, 4320, 4327, 4431, 4435, 4257, 4266, 4264, 4267, 4268, 4270, 4274, 4276, 4277, 4279, 4745, 4284, 4488, 4283, 4303, 4394, 4305, 146331, 4578, 4346, 4348, 4444, 15322, 4628, 4648, 4640, 4793, 4456, 4458, 4468, 4504, 4484, 14896, 4509, 4367, 4392, 4400, 4466, 4405, 4407, 4404, 4416, 4440, 5082, 4442, 4448, 4470, 4474, 4451, 4516, 4603, 4608, 4627, 31261, 4626, 5638, 4635, 4632, 4461, 4462, 4562, 4463, 4464, 4465, 4467, 4469, 4482, 5347, 4693, 4638, 5158, 4668, 4675, 4973, 4719, 5019, 4491, 4493, 4494, 4498, 4725, 7592, 4499, 5259, 4497, 4501, 4526, 4505, 4507, 4679, 4695, 4788, 4699, 4707, 4718, 4722, 4517, 4518, 4519, 4522, 4523, 4566, 4527, 4529, 4530, 4533, 4532, 4538, 4552, 4553, 4557, 4558, 4559, 4643, 4645, 4644, 4646, 4729, 4564, 5135, 5610, 4830, 4571, 4572, 4573, 4593, 4594, 18100, 4607, 4614, 4622, 4624, 4637, 4676, 4647, 4653, 4652, 4659, 4760, 4761, 5084, 4759, 4765, 4766, 5001, 8022, 5003, 4665, 4690, 4698, 5224, 4723, 7581, 4732, 4726, 4733, 4741, 4743, 4750, 4752, 5841, 4757, 4767, 5128, 4773, 4776, 4774, 5647, 4775, 4789, 4791, 5097, 4794, 5042, 4906, 5171, 4934, 4949, 4951, 4957, 4959, 4963, 4966, 4967, 4993, 13144, 4804, 4806, 4808, 7013, 4813, 5658, 5105, 5116, 4838, 5009, 5014, 5015, 5054, 5055, 5020, 5026, 5027, 5143, 5031, 5032, 5078, 6134, 5595, 5035, 5036, 5298, 5030, 5037, 5041, 5045, 5046, 5048, 5050, 5052, 5057, 7822, 4834, 4983, 5064, 5324, 5364, 5066, 5068, 4873, 5293, 5299, 5304, 5308, 5309, 4823, 4827, 5314, 4863, 5170, 4828, 4831, 4832, 4833, 4836, 5931, 4840, 4846, 4844, 5660, 4885, 4850, 4852, 4853, 4854, 4857, 5316, 5318, 5319, 4867, 4868, 4866, 4869, 4871, 4872, 4874, 7808, 4962, 4878, 4879, 4880, 4884, 4888, 4898, 5322, 4901, 4904, 5323, 5361, 5325, 5327, 4907, 4908, 4915, 4916, 4919, 4965, 4920, 4922, 4970, 4972, 4923, 4924, 4925, 4926, 4929, 5349, 5350, 5354, 5358, 5144, 4937, 4938, 6132, 4943, 4946, 4947, 33944, 4950, 14842, 4952, 4956, 4958, 4960, 5072, 4968, 4975, 4977, 4978, 4979, 4980, 4989, 4990, 4992, 4991, 5760, 5013, 5016, 146332, 5022, 15207, 5044, 5047, 5056, 5058, 5067, 5069, 5085, 5087, 5166, 5766, 5164, 5419, 5168, 5091, 5093, 5094, 5098, 5100, 5104, 5108, 5109, 5115, 5121, 5123, 5124, 5125, 5126, 5130, 5191, 5133, 5137, 5148, 5153, 5154, 5253, 5257, 5273, 5167, 5175, 5174, 5245, 5177, 5179, 5181, 5182, 5731, 5185, 5161, 5186, 5189, 5188, 5190, 5192, 5195, 5201, 5425, 5427, 5255, 5252, 5199, 5202, 5205, 5204, 5274, 5210, 5213, 5217, 5223, 5226, 5228, 5233, 5234, 5235, 5236, 5237, 5239, 5240, 5241, 5242, 5246, 5250, 5265, 5276, 5277, 5282, 8826, 17493, 5839, 15953, 5285, 5297, 5301, 5560, 5303, 5336, 5338, 5733, 5398, 5495, 5503, 5399, 5401, 5405, 5411, 5421, 5289, 5418, 5447, 5449, 5451, 5561, 8635, 5471, 5487, 5497, 5506, 5508, 5546, 5509, 5511, 5514, 8829, 5512, 5550, 5759, 5523, 149041, 5431, 5370, 5371, 5378, 5377, 5380, 5881, 5381, 5383, 5465, 5474, 5539, 5415, 5475, 5477, 5429, 5657, 5656, 5576, 5598, 5597, 5525, 5538, 5903, 5553, 5908, 5557, 5432, 5484, 5442, 5577, 5463, 5707, 5468, 5470, 5473, 5807, 5654, 5559, 5562, 5563, 5564, 5565, 5902, 5490, 5567, 5570, 5571, 5387, 5880, 5392, 5397, 5400, 5413, 5785, 5536, 5481, 5485, 5486, 5483, 5737, 5496, 5499, 146333, 5501, 5531, 5534, 7732, 5591, 5734, 5609, 5613, 5650, 5651, 6023, 21916, 5578, 5580, 5583, 5586, 5585, 5589, 7811, 5661, 5690, 5727, 5736, 5745, 5747, 5758, 5761, 5779, 5781, 5783, 7754, 5793, 6196, 5799, 5798, 5816, 5941, 5959, 5608, 5935, 6282, 125167, 5844, 5850, 5852, 5854, 5860, 5861, 5863, 6144, 6145, 5873, 5874, 5875, 5948, 18295, 5876, 5878, 5879, 5882, 5884, 5883, 5885, 5886, 5887, 5890, 5893, 5924, 5602, 5604, 5605, 5606, 6146, 6150, 5627, 5628, 5636, 6385, 23950, 6117, 5607, 5936, 5938, 5961, 5967, 5965, 5970, 5969, 5971, 5974, 5973, 5977, 5978, 5979, 5980, 5981, 5614, 6152, 5615, 5619, 5625, 6018, 5629, 5774, 5989, 5994, 7174, 5997, 6000, 6002, 6003, 6005, 6007, 6008, 6010, 6011, 6153, 6014, 5637, 5639, 5640, 6122, 6124, 6130, 6136, 6140, 6142, 5666, 146340, 5671, 5673, 5677, 21530, 6316, 5679, 5680, 5678, 5682, 5683, 5685, 6209, 5686, 5748, 5749, 5688, 6151, 6161, 6067, 5823, 6169, 13738, 6175, 6177, 159064, 5709, 6303, 6182, 6184, 9811, 5691, 6040, 5693, 5696, 5740, 5735, 5813, 5695, 6297, 5698, 6030, 5704, 5705, 5706, 8419, 5713, 5714, 5717, 6386, 5719, 5722, 5728, 6388, 5822, 5763, 6100, 5764, 5768, 5776, 5777, 5773, 5780, 7747, 5788, 5802, 5803, 5805, 7813, 5824, 6041, 5826, 5827, 5829, 5831, 5830, 17832, 11549, 5840, 5842, 5843, 5857, 5894, 5895, 5896, 145758, 5897, 5899, 5910, 7205, 5911, 7751, 7740, 5918, 5917, 5920, 6456, 6038, 5921, 5922, 23731, 5925, 5927, 5940, 5942, 5946, 5956, 5964, 5985, 6066, 6068, 5987, 6063, 16540, 6074, 6114, 5991, 5993, 6028, 6033, 6036, 6037, 9667, 6353, 6045, 6047, 6049, 6051, 6055, 6056, 6108, 6058, 6060, 6061, 6065, 6069, 6071, 6276, 6078, 6082, 6085, 6086, 6088, 6089, 6090, 6092, 6093, 6094, 6097, 6095, 145759, 6099, 6105, 6106, 6116, 6118, 6120, 6121, 6123, 6154, 6156, 6157, 6328, 6158, 6164, 6170, 6186, 6198, 6199, 6201, 6207, 7741, 6237, 6348, 6238, 6243, 6189, 6188, 6194, 6247, 6246, 6271, 6289, 6298, 6306, 7845, 7860, 6311, 8827, 7879, 6345, 6352, 6314, 6319, 6320, 6321, 6322, 6324, 6325, 6326, 6327, 6329, 6331, 6333, 6365, 6336, 147523, 6340, 6355, 6356, 6358, 6359, 6366, 6368, 6362, 6383, 6392, 6405, 7912, 8040, 8005, 6465, 6486, 6491, 8602, 7764, 6215, 8935, 6217, 125095, 6643, 6441, 6220, 6222, 6244, 6245, 6250, 7743, 9089, 6264, 15249, 6277, 6280, 7745, 8937, 7265, 6283, 6285, 6286, 6290, 7739, 6771, 2291, 6382, 15545, 7832, 6293, 6346, 6347, 6350, 7880, 6363, 6369, 6874, 6373, 6374, 6376, 7152, 6447, 6377, 6460, 6378, 6390, 6399, 6400, 6401, 6402, 6416, 6417, 6418, 6419, 6424, 6425, 6426, 6427, 6429, 6433, 6436, 6435, 6594, 17697, 7224, 9780, 6448, 6446, 6457, 6458, 6467, 6493, 6469, 6575, 6681, 6578, 21538, 6706, 6709, 6713, 23956, 6475, 6477, 6479, 6480, 7989, 6478, 6507, 6541, 6602, 6632, 6658, 6615, 6663, 6679, 6797, 6695, 159070, 159066, 6563, 7993, 6567, 6580, 6581, 6582, 6588, 6800, 6592, 6729, 6498, 6499, 6608, 6757, 146341, 6717, 6719, 6720, 7782, 6505, 7750, 6733, 6735, 6737, 6741, 6754, 6828, 7752, 6794, 6796, 6799, 6907, 6801, 6802, 6803, 6808, 6810, 7998, 6818, 14667, 6824, 6830, 6508, 6509, 6510, 6837, 7789, 6839, 6840, 6844, 17892, 6851, 6876, 6878, 6880, 6884, 6883, 6540, 7772, 9784, 6886, 6888, 6889, 6891, 6890, 6892, 7792, 9396, 7794, 7795, 7456, 6900, 7796, 6523, 6760, 6524, 6526, 6528, 6530, 6532, 6535, 6533, 6539, 16475, 6934, 6977, 6982, 6984, 7802, 6991, 6992, 6994, 7803, 7804, 6998, 6542, 6549, 6550, 6635, 7834, 23851, 6551, 8597, 6553, 6554, 6557, 6703, 6705, 23723, 6555, 6564, 6565, 6598, 7629, 6607, 6617, 6619, 6620, 6756, 6761, 6762, 6622, 6623, 6625, 145756, 4772, 7847, 6638, 7862, 6645, 6647, 6736, 6738, 7786, 7771, 6752, 7676, 6763, 9764, 6765, 7916, 7925, 8599, 6646, 6649, 6648, 6650, 6651, 6653, 6654, 6655, 6667, 18765, 6670, 6678, 7881, 6693, 6697, 6699, 7767, 6819, 6769, 6770, 6773, 6779, 6781, 7774, 6785, 7926, 6788, 6793, 6826, 7962, 6831, 6835, 6838, 6845, 22540, 6850, 146356, 7332, 6852, 6856, 16433, 6857, 6858, 7935, 7937, 6862, 7942, 6863, 6865, 6870, 6871, 6875, 6877, 6879, 6905, 6908, 7941, 6914, 6915, 6956, 6961, 146006, 6922, 6923, 146548, 6925, 6929, 6927, 140963, 6932, 7945, 6940, 6941, 7140, 7047, 6942, 6943, 6944, 6952, 7130, 7007, 6951, 1502, 6955, 6964, 7564, 6968, 7949, 6978, 7756, 7960, 7120, 7126, 7129, 7137, 7143, 7144, 7141, 7147, 7002, 7006, 7017, 7019, 7020, 7142, 7030, 7033, 7029, 9557, 7035, 7099, 7037, 7183, 7038, 7040, 7041, 7021, 7023, 7022, 7024, 7025, 7026, 7156, 7159, 7163, 7966, 7173, 7177, 7180, 7763, 7984, 7042, 7195, 7039, 7043, 7757, 24044, 7050, 7797, 7055, 7054, 7759, 7057, 7058, 7060, 7061, 7189, 7194, 7716, 7196, 7810, 10993, 7200, 7201, 7229, 7816, 7066, 7823, 7825, 7078, 7074, 7080, 7081, 7083, 7079, 7085, 7092, 7093, 18400, 7096, 7097, 7100, 7186, 7101, 7238, 7103, 7105, 7107, 7104, 7106, 7108, 7109, 7111, 7110, 7836, 7116, 7118, 7125, 7127, 7839, 7380, 7187, 7190, 7191, 7206, 7212, 7214, 7215, 7216, 7220, 7221, 7222, 7223, 7227, 7258, 7259, 8034, 7271, 7261, 7282, 7234, 9308, 8278, 7233, 7236, 7358, 7296, 8173, 7239, 7240, 7241, 7242, 7243, 7244, 7245, 7246, 7247, 7248, 7249, 7250, 7251, 7280, 7316, 7369, 7377, 7382, 7383, 7386, 7384, 7388, 7390, 7392, 7807, 7267, 7270, 7272, 7275, 7848, 7426, 7850, 7852, 7477, 7854, 7857, 7488, 7310, 7311, 7957, 7484, 7490, 7494, 9304, 7283, 7287, 146489, 7288, 7290, 7292, 7294, 7295, 7299, 7302, 7303, 7305, 9344, 7868, 7307, 7312, 7313, 7308, 7315, 7872, 9310, 7512, 7568, 147566, 7570, 125077, 7575, 7429, 7569, 7578, 7319, 7625, 7628, 7554, 7975, 7632, 7677, 8035, 7679, 7689, 7693, 9692, 7882, 8326, 7889, 7338, 7890, 7864, 7892, 7894, 7896, 7897, 7898, 7939, 7946, 7437, 7967, 7899, 7977, 7900, 7902, 7905, 7597, 7908, 7914, 7348, 7918, 7923, 7924, 7922, 7339, 7340, 7328, 7928, 7932, 7552, 7978, 7981, 7983, 7341, 7342, 7343, 7990, 7992, 7994, 137843, 8020, 8024, 8027, 8028, 8041, 8343, 7353, 7835, 7643, 7368, 7370, 7379, 7385, 7391, 5976, 7425, 7817, 7405, 7407, 7411, 7449, 7837, 7824, 7418, 7537, 7420, 7427, 7435, 7436, 7438, 8547, 9363, 7440, 7856, 7528, 7444, 7447, 7851, 7458, 7465, 7470, 7472, 7502, 7501, 7505, 7507, 7509, 7511, 7514, 7515, 7517, 7555, 7550, 7513, 7520, 7558, 7565, 7518, 7858, 18887, 9785, 7539, 7540, 7631, 7714, 7541, 7544, 7546, 7866, 7870, 13004, 7557, 7587, 7590, 146490, 9326, 7878, 9318, 9328, 7602, 7603, 7606, 7612, 7611, 7615, 7883, 9178, 7618, 7713, 7636, 15017, 145778, 9794, 7639, 7640, 8136, 7684, 24058, 7645, 7646, 7695, 7648, 7651, 7652, 7654, 7657, 7659, 9218, 7661, 8148, 7663, 7664, 7717, 8954, 9219, 8176, 7672, 8138, 7673, 7678, 7683, 7685, 7688, 3703, 1620, 7699, 7700, 7701, 7702, 7703, 7704, 7705, 7706, 7707, 7709, 7710, 7711, 7712, 7718, 7719, 7720, 7721, 7722, 7725, 7726, 7728, 7729, 7731, 9173, 7891, 7907, 8283, 8009, 8010, 8011, 8014, 11718, 8016, 8043, 8089, 8111, 8049, 10796, 9391, 8117, 8118, 8120, 8122, 8124, 8126, 8137, 8142, 8145, 8532, 8154, 8157, 8158, 8082, 8042, 8044, 8045, 15489, 8050, 8052, 8053, 8055, 8056, 8059, 8060, 8061, 8058, 8064, 8063, 8068, 9343, 8074, 8150, 8073, 8078, 8081, 8087, 8163, 8091, 8090, 8092, 8093, 9778, 8095, 8101, 8100, 8102, 9276, 8099, 8106, 8109, 8116, 8119, 8131, 8121, 8344, 8434, 8151, 8153, 8155, 8156, 8164, 8174, 8185, 8227, 8226, 8228, 8231, 8233, 8234, 8165, 8166, 8167, 8332, 8372, 8377, 8413, 8415, 8427, 8432, 8447, 8449, 8452, 8674, 8504, 8516, 8521, 8524, 8526, 8171, 8548, 8549, 8553, 8175, 8556, 8558, 8566, 8568, 8570, 8574, 8578, 8580, 8584, 24476, 8591, 8593, 8595, 8596, 8603, 8605, 23994, 8701, 8704, 8611, 24202, 8713, 8716, 8719, 8711, 8186, 8183, 8631, 8636, 8638, 8642, 8223, 24001, 8696, 8958, 8700, 8706, 8707, 16527, 8273, 8710, 8255, 8188, 8196, 8197, 8189, 8195, 8202, 8203, 8199, 8337, 8207, 8204, 8211, 8210, 8391, 8212, 8250, 8254, 8256, 8258, 8259, 9118, 8214, 8216, 8217, 9402, 8220, 8225, 8224, 8721, 8723, 8340, 8724, 8728, 25995, 8730, 8244, 8245, 8248, 8393, 8246, 8264, 8266, 8269, 8280, 8281, 8282, 8506, 8883, 8289, 145777, 8290, 8324, 8292, 8297, 8299, 8300, 8298, 9170, 9327, 8303, 9721, 8306, 8394, 8308, 8309, 8311, 8304, 8317, 8318, 23865, 8319, 8321, 8320, 8325, 8330, 8333, 8359, 8741, 8744, 8746, 8748, 8760, 8762, 8839, 8840, 8508, 27890, 8346, 8846, 8854, 8856, 8862, 9392, 8867, 8874, 8872, 8875, 8878, 8881, 8882, 8349, 8351, 8352, 8519, 11460, 8354, 8357, 8360, 8371, 8379, 8388, 8400, 8402, 8403, 8471, 8956, 23925, 8406, 17588, 24848, 8411, 8416, 8420, 8422, 8424, 9366, 8433, 8435, 8436, 8446, 8456, 8901, 8461, 8463, 8669, 8464, 8469, 9427, 8468, 8474, 8473, 8484, 8483, 8490, 8492, 8494, 8495, 8500, 8662, 8503, 8511, 8637, 8517, 8525, 29718, 8657, 9356, 8539, 8541, 9055, 8545, 8552, 2749, 8567, 8666, 24174, 8573, 8575, 8577, 24172, 8582, 8583, 8610, 8687, 8615, 8616, 8622, 8667, 9549, 8668, 8670, 8828, 8625, 8627, 147468, 8948, 8630, 8633, 8639, 8646, 8651, 8649, 8652, 19954, 8656, 8658, 8659, 9718, 143966, 8675, 16529, 9036, 8680, 8681, 8682, 8685, 8689, 8712, 8714, 8717, 8720, 8738, 8742, 8743, 8745, 8747, 8912, 8785, 8749, 8751, 8944, 8945, 8990, 8750, 8758, 8763, 8765, 8767, 8771, 8775, 8786, 9369, 11327, 8788, 8789, 8791, 8790, 8824, 8793, 8842, 9103, 8799, 8796, 8951, 8805, 8806, 8808, 8811, 8812, 8813, 8820, 8884, 8853, 8857, 8916, 9265, 8819, 8823, 11173, 8946, 15561, 24231, 13314, 8844, 8848, 9786, 9350, 8910, 8927, 8928, 8933, 8932, 8991, 9267, 8942, 8947, 8949, 8885, 24198, 8890, 8895, 18294, 8925, 18553, 8993, 8994, 15237, 8965, 9044, 9053, 9056, 9060, 9064, 9073, 8971, 9076, 9080, 9085, 9091, 9092, 9139, 24232, 9236, 9094, 9096, 9097, 9109, 9111, 9112, 9113, 9117, 9119, 8970, 8973, 9200, 8974, 9129, 9131, 9137, 9161, 9163, 9167, 9168, 8979, 13762, 9171, 9172, 9183, 9190, 9192, 9547, 9198, 9203, 9206, 9211, 9215, 9397, 8975, 9269, 9272, 9275, 9277, 9280, 9284, 9024, 9282, 18555, 8981, 18367, 9289, 9290, 9294, 9296, 9395, 9297, 4870, 9550, 9300, 9301, 9305, 9317, 9329, 9338, 9351, 9353, 9454, 9566, 20835, 24084, 9429, 9433, 9437, 9439, 9441, 9443, 9473, 9527, 144704, 8995, 146495, 8996, 8997, 8998, 24068, 24071, 14275, 9455, 9483, 21013, 9477, 9457, 9510, 9513, 9515, 9458, 9535, 13285, 8999, 24237, 148199, 9459, 9460, 24107, 9540, 3570, 9475, 9485, 9498, 9506, 9517, 9519, 9421, 9522, 9525, 13307, 9018, 9020, 9001, 9004, 9005, 9637, 9007, 9130, 9008, 6249, 9556, 9558, 9663, 9476, 9551, 9278, 9011, 9426, 9015, 24073, 9032, 9034, 9033, 9050, 9035, 9564, 9160, 9235, 9563, 9040, 9041, 9042, 9569, 9599, 9682, 9601, 9620, 9331, 9621, 9627, 9631, 9633, 9660, 9668, 9669, 9670, 9671, 9672, 9674, 9676, 9675, 9677, 9678, 9324, 9683, 9684, 9685, 9687, 9045, 9046, 9553, 9143, 9047, 9048, 9049, 9054, 9057, 9062, 13602, 9065, 9072, 9074, 9079, 9082, 9087, 9100, 9102, 9104, 9107, 9108, 9110, 9123, 9125, 9128, 37392, 9136, 9138, 9141, 9146, 9148, 9149, 9151, 9240, 9153, 9155, 9423, 9162, 9164, 9302, 9169, 9182, 18144, 9147, 11566, 15242, 9191, 24055, 9201, 9204, 9221, 9231, 9233, 9413, 9238, 9239, 9245, 9246, 9255, 9587, 9257, 9259, 9260, 9264, 9270, 9274, 9283, 9281, 9291, 9293, 9316, 9320, 9319, 24108, 9334, 9349, 9352, 9387, 9388, 9524, 9398, 9407, 9428, 147469, 24123, 9442, 9444, 9448, 9450, 13069, 9452, 9461, 9474, 9481, 9484, 9486, 9487, 18402, 9492, 148200, 9491, 13848, 24125, 9499, 9500, 9502, 9504, 9507, 9511, 9679, 9518, 9552, 9560, 9570, 9616, 9572, 17120, 9576, 9577, 9647, 9580, 9584, 9653, 9654, 9655, 15503, 9586, 9589, 38595, 9594, 9578, 9600, 9605, 9607, 24138, 9611, 9612, 9613, 9615, 9617, 147522, 9619, 9628, 24150, 9638, 9641, 9648, 9707, 9658, 23757, 9661, 9665, 21397, 19812, 9731, 9744, 9745, 17237, 17951, 9752, 9795, 9799, 9802, 9808, 9717, 9722, 15003, 14643, 16353, 15938, 9767, 17517, 5675, 9763, 13225, 24126, 9769, 9710, 23927, 152971, 14904, 9782, 9715, 16148, 9751, 9789, 9708, 9807, 12178, 11525, 10663, 11578, 16220, 12145, 9699, 14422, 141075, 9701, 16379, 9712, 9711, 9713, 9714, 148239, 9724, 9726, 11180, 17924, 13305, 14907, 18300, 14103, 9733, 9735, 9736, 9737, 9800, 9738, 14735, 9740, 12196, 12047, 9742, 9743, 9746, 9747, 24131, 14731, 9754, 17292, 9755, 20274, 13623, 12257, 11186, 159067, 18706, 11345, 9768, 9770, 9773, 13161, 18608, 9774, 11523, 9772, 13768, 12272, 12829, 13353, 14918, 16974, 10811, 14955, 146769, 18948, 21475, 22265, 21607, 13748, 2409, 10800, 11347, 18975, 18600, 11224, 26682, 15198, 11719, 14623, 18572, 12010, 3463, 16402, 20276, 20135, 13422, 19853, 19387, 18903, 12404, 13073, 10998, 13581, 10853, 14248, 17152, 17070, 15328, 14130, 13733, 11425, 15602, 14831, 14116, 13270, 21465, 19411, 19310, 16867, 10626, 14050, 13680, 22189, 14199, 20981, 13053, 11004, 15993, 14460, 10842, 16152, 15587, 16749, 16710, 16330, 13986, 11478, 13968, 35572, 20666, 19793, 19741, 19755, 18389, 18730, 18946, 18036, 148240, 18502, 18167, 13872, 18246, 4782, 17873, 16624, 17835, 21703, 21760, 21217, 20306, 20576, 19808, 20119, 24469, 19743, 19531, 19213, 19230, 18429, 16142, 10979, 12569, 13076, 14669, 22190, 14457, 11216, 11189, 11118, 16173, 17190, 16254, 18377, 20906, 20694, 20748, 19216, 11236, 15126, 18491, 11472, 17765, 13844, 18011, 18481, 15391, 15287, 16601, 17297, 17200, 17902, 14763, 16504, 16931, 15399, 15544, 22155, 22585, 20745, 21847, 21855, 21636, 20017, 20056, 19546, 14971, 13045, 10643, 13801, 12794, 18770, 10841, 17422, 11139, 21451, 16013, 13850, 17147, 14854, 13718, 15927, 14814, 18141, 22385, 20852, 20907, 21082, 20619, 19177, 18705, 24470, 15375, 15261, 18666, 18653, 16465, 18740, 11897, 22191, 17112, 12120, 13294, 18241, 14782, 11074, 12325, 12137, 11868, 14400, 12112, 12076, 19191, 18535, 15321, 12389, 13250, 14357, 14086, 16139, 13525, 13482, 15179, 13995, 18249, 13382, 10892, 12218, 15260, 19529, 21796, 19818, 19181, 13147, 18937, 16408, 14830, 18920, 14308, 16426, 17577, 17365, 13085, 12356, 13029, 11262, 15100, 11389, 22283, 21533, 21223, 19888, 19304, 11256, 15021, 14606, 11414, 20181, 13165, 10581, 10854, 15950, 10564, 15724, 13879, 10915, 14825, 14580, 17849, 21655, 21666, 19889, 19769, 18874, 18802, 18811, 18534, 11904, 14432, 14387, 17284, 10478, 15607, 17135, 20562, 14710, 10929, 144083, 13162, 16185, 17460, 12842, 18242, 145376, 19301, 21936, 21041, 20875, 18324, 13119, 17874, 18485, 10492, 13070, 11246, 13727, 28222, 13132, 13463, 20442, 19390, 11872, 14598, 13419, 12114, 10926, 12012, 11562, 18734, 21884, 24471, 19761, 13151, 18769, 16444, 16342, 18174, 11083, 12476, 17848, 16499, 23653, 16372, 16501, 16565, 17475, 22967, 23587, 23592, 22223, 22224, 22262, 20877, 16648, 36698, 148241, 20125, 19924, 18452, 18895, 18311, 14806, 14744, 24472, 17847, 159068, 11541, 15802, 16649, 18232, 16651, 21573, 16528, 21853, 16645, 19583, 18908, 18913, 18871, 18997, 18058, 14317, 12784, 13952, 14556, 18665, 18660, 12905, 16317, 16485, 18664, 18922, 22318, 21833, 21835, 21642, 22055, 21393, 21116, 21138, 18861, 19046, 17943, 17783, 16599, 11495, 15989, 15928, 17333, 16131, 10242, 13662, 14716, 14170, 147001, 21877, 20805, 159987, 20218, 17081, 15078, 17939, 14841, 16071, 16839, 12986, 13367, 13157, 11751, 13478, 17390, 11569, 10873, 12253, 147081, 10969, 11290, 11053, 16222, 16231, 13661, 12716, 18423, 15875, 18062, 21518, 159069, 19263, 19837, 19200, 18970, 14995, 13310, 14505, 16236, 15994, 14601, 12894, 11934, 14848, 16383, 14450, 14690, 13041, 16435, 13532, 14044, 16121, 18857, 16767, 12802, 15729, 13446, 16739, 15862, 10883, 17348, 13534, 21174, 15736, 17568, 17981, 14250, 15853, 14252, 20686, 22723, 12135, 15867, 13948, 22195, 13693, 13223, 21726, 16770, 12305, 15306, 15894, 16193, 14961, 16357, 15221, 13019, 17762, 22927, 20013, 20355, 21519, 17844, 147582, 18584, 17436, 15369, 11449, 22421, 19405, 17278, 11422, 18595, 12996, 15882, 10659, 21602, 16322, 15206, 15595, 22952, 21301, 22074, 21418, 14311, 18671, 17502, 17923, 17552, 16455, 14878, 16813, 20152, 17175, 14101, 15058, 15499, 19931, 21997, 19011, 19711, 19670, 15086, 12585, 12849, 11291, 18927, 12735, 14088, 38727, 11545, 15861, 13524, 17642, 13242, 14337, 14521, 12387, 11476, 13636, 16755, 14145, 12066, 12836, 15977, 11658, 11453, 15361, 10292, 14544, 13629, 14332, 10928, 12535, 16160, 15635, 15641, 11081, 20103, 21178, 20203, 19397, 19361, 10805, 19146, 15580, 14446, 22930, 22632, 21055, 19821, 19284, 15254, 15187, 12781, 12463, 12071, 22934, 22314, 12778, 12270, 18965, 13451, 11589, 14251, 22348, 11482, 14547, 14621, 12878, 15990, 15482, 15601, 13886, 12344, 14253, 11912, 16219, 14838, 15387, 11580, 18748, 16064, 16771, 21073, 15509, 16203, 16226, 12559, 10712, 11318, 16439, 16003, 13545, 16937, 15240, 16305, 10542, 19859, 20734, 10277, 20307, 14375, 15903, 16188, 16962, 16661, 13668, 15980, 15304, 18220, 17012, 14863, 13094, 23732, 13297, 13171, 19209, 19153, 16382, 17958, 16481, 18207, 17710, 15677, 13011, 20311, 21523, 20942, 20439, 20577, 19820, 19831, 19897, 19329, 19662, 11082, 18516, 17903, 10531, 18390, 10689, 17867, 17512, 17777, 19925, 17799, 14548, 13630, 12652, 22168, 22310, 21869, 21187, 21164, 20312, 20254, 19779, 18206, 18342, 18047, 15281, 15309, 22848, 22815, 20988, 22199, 22425, 21886, 21756, 21399, 21235, 20171, 20659, 20618, 19630, 18896, 19015, 17670, 18115, 14635, 18657, 17685, 18176, 18164, 16042, 11504, 15205, 12725, 22275, 21211, 20359, 19489, 19962, 18999, 12932, 13255, 14639, 11008, 148144, 13823, 12989, 23255, 14509, 15385, 12733, 14594, 12319, 14198, 11070, 13339, 15147, 20515, 21694, 12457, 16456, 12217, 14883, 15002, 14915, 15951, 17238, 12288, 12335, 14085, 11263, 16128, 147079, 15331, 17537, 20386, 20487, 19771, 20035, 16293, 11272, 10532, 13578, 13562, 11991, 18641, 18175, 18773, 12314, 16307, 11079, 15397, 18720, 22462, 20176, 19671, 18639, 12703, 14508, 15069, 10571, 10612, 14581, 10675, 15522, 12075, 22300, 22388, 22183, 20332, 22006, 21113, 20394, 19906, 19022, 22198, 19451, 19016, 18677, 10932, 16493, 14627, 14452, 17094, 20966, 14986, 15995, 12599, 11232, 16743, 16449, 17123, 14133, 20215, 19114, 21502, 18995, 20598, 14012, 14480, 13903, 10635, 13375, 17564, 17126, 16001, 15094, 11367, 17933, 22690, 22319, 19421, 18814, 12007, 13056, 22332, 22598, 11508, 12152, 13890, 10945, 11978, 11886, 14223, 15104, 12590, 13763, 13631, 22836, 20051, 22469, 22470, 22145, 21908, 19195, 19857, 18374, 17768, 13134, 12560, 11586, 18569, 12295, 11430, 13343, 10965, 17585, 11853, 10565, 11287, 16141, 11067, 17121, 14966, 13997, 19890, 19854, 18850, 15991, 18149, 11065, 16123, 12281, 12622, 15631, 11313, 13881, 14265, 22703, 20492, 21896, 21638, 19341, 20585, 20073, 18776, 13930, 16985, 13937, 16469, 16349, 14257, 16401, 18444, 14589, 14984, 21545, 17934, 22111, 22056, 21238, 13980, 12059, 14046, 20032, 15332, 16346, 14037, 13322, 11092, 11646, 12228, 13731, 16387, 16482, 15081, 16050, 14004, 20222, 21747, 19849, 21494, 17516, 11534, 15298, 18651, 18487, 17888, 18746, 23913, 14773, 18470, 22909, 22664, 19215, 18807, 19119, 10482, 17811, 18059, 14179, 14714, 11343, 11612, 14897, 13347, 21741, 21374, 19250, 16136, 14702, 21520, 13566, 15238, 17461, 17865, 17935, 16471, 18043, 17508, 22058, 21705, 20179, 19043, 20045, 19185, 20941, 10546, 13900, 16515, 15102, 16747, 17263, 13174, 16235, 12819, 15060, 13102, 11117, 10795, 10691, 13406, 12421, 11275, 11741, 13068, 10638, 12085, 15942, 10379, 11259, 11218, 11147, 24518, 14363, 10692, 10690, 17234, 14425, 18211, 13681, 12486, 10902, 147418, 13194, 12313, 10882, 18450, 13715, 148242, 14501, 13260, 15992, 11205, 14572, 13966, 10862, 18228, 14488, 125131, 17301, 10621, 18153, 11588, 10616, 20096, 22377, 22004, 21683, 16302, 17681, 10378, 15478, 16589, 16895, 14189, 17099, 13252, 14194, 22378, 22025, 1321, 22079, 21888, 21810, 21332, 21283, 21050, 14006, 14466, 14769, 11496, 17073, 16208, 10534, 13138, 12580, 12557, 16598, 16340, 13439, 14610, 15978, 17032, 14611, 145754, 12224, 20837, 13971, 12158, 15874, 11490, 13742, 15084, 21241, 12439, 13987, 17871, 14628, 11257, 14741, 12402, 14397, 22661, 12955, 16622, 16491, 16495, 14191, 16587, 12182, 15388, 10539, 12398, 12172, 10574, 16500, 14274, 23701, 20059, 15107, 15333, 11530, 20448, 15691, 13535, 13062, 21409, 13207, 15362, 13166, 10850, 18473, 13164, 18973, 11323, 10911, 11462, 14017, 15326, 19276, 13121, 19539, 14287, 13897, 17458, 17779, 17757, 15370, 17185, 12635, 15678, 17587, 13398, 20212, 22790, 22489, 20277, 19260, 18810, 18897, 13217, 22779, 22879, 13489, 14065, 11600, 12570, 12682, 17658, 18266, 13320, 13605, 20427, 12548, 20094, 19971, 19324, 18863, 10859, 12761, 11602, 11905, 15099, 14976, 11134, 19679, 125099, 17616, 22339, 22417, 11125, 19552, 14865, 13031, 11851, 15746, 19569, 11822, 16024, 12885, 15348, 10849, 18711, 16374, 27607, 19994, 10867, 16274, 13784, 12034, 17357, 20597, 11564, 14676, 13340, 10967, 13938, 17690, 20318, 14429, 10790, 14591, 11465, 12817, 13237, 13767, 10632, 12171, 19639, 16536, 15247, 13016, 15828, 10856, 15625, 11670, 13039, 18732, 23583, 22926, 22959, 20285, 22465, 21104, 19030, 19247, 19490, 18598, 14280, 18750, 10717, 12660, 17931, 13325, 22518, 22023, 21264, 20338, 20508, 19835, 18856, 20169, 20002, 19822, 19434, 19437, 19050, 18704, 18263, 18882, 18880, 19226, 18998, 18264, 13190, 13822, 18190, 11415, 21336, 13816, 18878, 23102, 22707, 22061, 22697, 20528, 21687, 20284, 19174, 13473, 19033, 18649, 13810, 10718, 15858, 15668, 15819, 13238, 16789, 14166, 16617, 11399, 17698, 17434, 13828, 19266, 22565, 21109, 17446, 20398, 16569, 17747, 14230, 16748, 14571, 14484, 13781, 13017, 14032, 12211, 12412, 125101, 18607, 17515, 20294, 22230, 19000, 19278, 18996, 13901, 22543, 15301, 14900, 11764, 17324, 10814, 12507, 15560, 15596, 19082, 19265, 22000, 21840, 21610, 20823, 19347, 18426, 14770, 16555, 21704, 18723, 18188, 21471, 16397, 16411, 18054, 10554, 12823, 21089, 22266, 22077, 21066, 20501, 13246, 20565, 20115, 21476, 18812, 19021, 18848, 11887, 18350, 17833, 11885, 13163, 17233, 16548, 11427, 16412, 11466, 13797, 10398, 11661, 14788, 17304, 10624, 18427, 11208, 11889, 13766, 11330, 12785, 11261, 11211, 11551, 20622, 21566, 19296, 18852, 15511, 11543, 11553, 17313, 14193, 16477, 17394, 4913, 14801, 14416, 12251, 17366, 14210, 12502, 17521, 18835, 11407, 19722, 14009, 16618, 10839, 12108, 16784, 14631, 13676, 16363, 13796, 14436, 15741, 23737, 10604, 12013, 22789, 22849, 20563, 22541, 22226, 21536, 20812, 22069, 19264, 20347, 18797, 11242, 18309, 18084, 12239, 12974, 11443, 21016, 14398, 18314, 11281, 148037, 16614, 14270, 15866, 16611, 13771, 21302, 22246, 20288, 21386, 21114, 19910, 19367, 19554, 18799, 13770, 17370, 15312, 13046, 10959, 17353, 14282, 12832, 19412, 12496, 16080, 16596, 17139, 13247, 13005, 13821, 12696, 10919, 2332, 15885, 22520, 21828, 19875, 14115, 15004, 18020, 17584, 10861, 17980, 15780, 15743, 13969, 16756, 14087, 12961, 147089, 12091, 11911, 11089, 12014, 11529, 29163, 12379, 27608, 21280, 10930, 13309, 12115, 4674, 12129, 10380, 11237, 11892, 11538, 21699, 13232, 21617, 12687, 3529, 1476, 10651, 11200, 13124, 12459, 16414, 14001, 16751, 16291, 13678, 11049, 19001, 12804, 14406, 17759, 10860, 12092, 15588, 10921, 13830, 22371, 17545, 12173, 11690, 13497, 11221, 21915, 21850, 20899, 19543, 13929, 11418, 16313, 14072, 14226, 18438, 15783, 17113, 16256, 11621, 14658, 16118, 16545, 17108, 15530, 14054, 16334, 22003, 20130, 17271, 15177, 15899, 14415, 17553, 13234, 18166, 15491, 18674, 18399, 25485, 19231, 21135, 21131, 23028, 15417, 10723, 17051, 16232, 13618, 13460, 12850, 16658, 16513, 18661, 18272, 18614, 19985, 18439, 12855, 11801, 12896, 14701, 30732, 12720, 11577, 10483, 11936, 16057, 14910, 18267, 19137, 19086, 20233, 22134, 20223, 19369, 145386, 145387, 11699, 14625, 15234, 18397, 22504, 21033, 22177, 15485, 17067, 20019, 19339, 19650, 15034, 11340, 12769, 18255, 148299, 17443, 23061, 21256, 20414, 13298, 11640, 18126, 23912, 15275, 13753, 22611, 22579, 10312, 12365, 13882, 12431, 12441, 12748, 17640, 12004, 19969, 12561, 18407, 14680, 10880, 13131, 16993, 13735, 21590, 16564, 148289, 18594, 18150, 145389, 16995, 19366, 18375, 18187, 18219, 17402, 18394, 19694, 21585, 19141, 18104, 16709, 18497, 10657, 11710, 16095, 18202, 18024, 12234, 16202, 17414, 10543, 16539, 20191, 22413, 19842, 19318, 19155, 19069, 17129, 18068, 12774, 12613, 14759, 13907, 18652, 16906, 11579, 13468, 11540, 17294, 11325, 13055, 14844, 21441, 10409, 20707, 21529, 11129, 20028, 19661, 16887, 15794, 159040, 125103, 15512, 11650, 14527, 11479, 14426, 15933, 12323, 16210, 13798, 12928, 13351, 14023, 11488, 12494, 10707, 15523, 15335, 15719, 15493, 12020, 15192, 15464, 12110, 16260, 10916, 11522, 17178, 18690, 16437, 16398, 10797, 14749, 15932, 20052, 13227, 15781, 14567, 15973, 13344, 15367, 15670, 15879, 13977, 15184, 13402, 12109, 19081, 13218, 12676, 18592, 144721, 22666, 22663, 22288, 21564, 21440, 10802, 16558, 22299, 15066, 22353, 12601, 11560, 15210, 14506, 16804, 15285, 17780, 14111, 22345, 22276, 20881, 10835, 16458, 17701, 4500, 17043, 11480, 13876, 14334, 14963, 16312, 20747, 18486, 11447, 21563, 11361, 15195, 16156, 16007, 16134, 10791, 18357, 15798, 15984, 14981, 16201, 13362, 11914, 12072, 11437, 13875, 14381, 21980, 13256, 12174, 16155, 10669, 13259, 13323, 16107, 19976, 15186, 13271, 12360, 10702, 12449, 14411, 13651, 14049, 16147, 20341, 17221, 15568, 11283, 17209, 16698, 10764, 10672, 14892, 14489, 16392, 15050, 13736, 15118, 16541, 10767, 18160, 13807, 18254, 17125, 12512, 13818, 17664, 13088, 14876, 12697, 21507, 16638, 19914, 22146, 22253, 21885, 21689, 20809, 21115, 19517, 17827, 16388, 12093, 17192, 15315, 14609, 15948, 16508, 12927, 24209, 16171, 15837, 17953, 18568, 17057, 17124, 14644, 10674, 19731, 20623, 20450, 19839, 19287, 18697, 10845, 10614, 16300, 12368, 13024, 16077, 15966, 21081, 22370, 21548, 19399, 13450, 21442, 20674, 19602, 19607, 19058, 14858, 14829, 16635, 14820, 17100, 13182, 12472, 14464, 24592, 10816, 11571, 12193, 22505, 22203, 20828, 21894, 17157, 21849, 21226, 15734, 19902, 19877, 20393, 14937, 17194, 15844, 12891, 14957, 11881, 15550, 14982, 10815, 10966, 12906, 11875, 12717, 16103, 11986, 15506, 19905, 20023, 15149, 19088, 17573, 18336, 18369, 16347, 11087, 17116, 18345, 15246, 12408, 19452, 16228, 14724, 14941, 21159, 18199, 24512, 20441, 20354, 19644, 15072, 15218, 13571, 16394, 11559, 11623, 10540, 24140, 16496, 15970, 13633, 20164, 21688, 16957, 20636, 20639, 20494, 20589, 13825, 17511, 24633, 13192, 15849, 11701, 18640, 18495, 17480, 20368, 22349, 22346, 21882, 21287, 20520, 16058, 18383, 17963, 14301, 13695, 18742, 16673, 12987, 13967, 16664, 13221, 22945, 22948, 22538, 22546, 20992, 22358, 22359, 22400, 22291, 20908, 21070, 20370, 20371, 20404, 20566, 19871, 19640, 19656, 15869, 14423, 18182, 18035, 12671, 12900, 14202, 17254, 12990, 21521, 21798, 20940, 20676, 19736, 19559, 15567, 19693, 15957, 12141, 20506, 15680, 11808, 13266, 22252, 15154, 18434, 16676, 25509, 12704, 20943, 22307, 21173, 20714, 19414, 19781, 20352, 19436, 19521, 19545, 17027, 17045, 17825, 17908, 18362, 20041, 22309, 21935, 21846, 21201, 21429, 21044, 19198, 18904, 17620, 144700, 17853, 17534, 17562, 17945, 20464, 22511, 22507, 22485, 21298, 21046, 20258, 19322, 19513, 18819, 13081, 18585, 11146, 15320, 18364, 17774, 18458, 15716, 18361, 18286, 22731, 21443, 22356, 20836, 20472, 21199, 19673, 20691, 20725, 20614, 20490, 19498, 19757, 19532, 17583, 16677, 17984, 11471, 13408, 13710, 18420, 17048, 15046, 15044, 20965, 20380, 20353, 20697, 20048, 20053, 19502, 13685, 31818, 12661, 18566, 18370, 20804, 22196, 22639, 21738, 21635, 21660, 21026, 21015, 20376, 20257, 20959, 19707, 20710, 19706, 20279, 19193, 19212, 18889, 18805, 12533, 13942, 11622, 18963, 31815, 20856, 22963, 22279, 21597, 20978, 20293, 20340, 20331, 20220, 20265, 19756, 18691, 19885, 19238, 19359, 19152, 18890, 19020, 15779, 23914, 12795, 14107, 22946, 22974, 20378, 22261, 21664, 21054, 20470, 20651, 19342, 20058, 19814, 20021, 19298, 19316, 19604, 19445, 19211, 19077, 24211, 12869, 18034, 17580, 12964, 12679, 11319, 17756, 22303, 21903, 21090, 20382, 20718, 20728, 20210, 19202, 20063, 20730, 19285, 19508, 18813, 14541, 16092, 18466, 17008, 20723, 22350, 21820, 21822, 11898, 20429, 20435, 18783, 19891, 20603, 19658, 18792, 18701, 20342, 20034, 19740, 18027, 17810, 11928, 22983, 21358, 22078, 22104, 22008, 20999, 21222, 20976, 21230, 20246, 21154, 20964, 20604, 20395, 17483, 21431, 24644, 21157, 11238, 18289, 14159, 18014, 22958, 22034, 22271, 19746, 20749, 20360, 20967, 20260, 19724, 19415, 19520, 19669, 14666, 23762, 24095, 18505, 18359, 18301, 22847, 20468, 20291, 20753, 20558, 20584, 20399, 20270, 20271, 20259, 19737, 19760, 19013, 19048, 19469, 16612, 18344, 13921, 17021, 20194, 17622, 15039, 24516, 148248, 19251, 20449, 15433, 23636, 20469, 22329, 22284, 21155, 19811, 19461, 16270, 18303, 18365, 23952, 19606, 12993, 20802, 21748, 20880, 20799, 21449, 21049, 21152, 20737, 20217, 12286, 18227, 13152, 18317, 23877, 23855, 23993, 20466, 21126, 18335, 18298, 18509, 10636, 16997, 18268, 24016, 24020, 23569, 22961, 20961, 22785, 22171, 22406, 22263, 21889, 21439, 20962, 20471, 20447, 20349, 20067, 19657, 17694, 23736, 27909, 12766, 18091, 23895, 17997, 145755, 20055, 13018, 24009, 22694, 20970, 22357, 22402, 22092, 20383, 19844, 20074, 19758, 18990, 19449, 16027, 14870, 140934, 13563, 16175, 13483, 20402, 17022, 13591, 18629, 18296, 12981, 15005, 15153, 23740, 23741, 23768, 23742, 24636, 23735, 19848, 22109, 21289, 19773, 19294, 18892, 18902, 23832, 23833, 23986, 23834, 23837, 23838, 23839, 23840, 23841, 23846, 24087, 23847, 23848, 25694, 24021, 24022, 24024, 24029, 24033, 24079, 24036, 23743, 24213, 24215, 23763, 24219, 23752, 24120, 23751, 24118, 24041, 24069, 24072, 24086, 24216, 145757, 24205, 24223, 23767, 26681, 24091, 34287, 24109, 24119, 24496, 24139, 24141, 23755, 23758, 23760, 26145, 24217, 24218, 24897, 23770, 23773, 23776, 24233, 159107, 23798, 24290, 23799, 24284, 24283, 24143, 24272, 24220, 24149, 24156, 24159, 24164, 24166, 24354, 24171, 24175, 24179, 24181, 24183, 24184, 24235, 23782, 23783, 24287, 23802, 23803, 24238, 24059, 23787, 23804, 24293, 24364, 24295, 23786, 24258, 24262, 24276, 24279, 24289, 23792, 23800, 123801, 24365, 24309, 24336, 23852, 23854, 23897, 24343, 24346, 24350, 24352, 24353, 23910, 24355, 24356, 23916, 24357, 24358, 24363, 24366, 24367, 153199, 24369, 24370, 23902, 24137, 24371, 24392, 23898, 23935, 23864, 24373, 24374, 23807, 23808, 23809, 23810, 23811, 24388, 28086, 23815, 34117, 24410, 24427, 23908, 23857, 23861, 23820, 23822, 23824, 23825, 23826, 23827, 24384, 24387, 145179, 34256, 23892, 24389, 24391, 27585, 24393, 24408, 24127, 23909, 23867, 23868, 23873, 23875, 23879, 23880, 23883, 23885, 145180, 24135, 23974, 23888, 23889, 23890, 23891, 23893, 23894, 23938, 23896, 25660, 23900, 23901, 23917, 23918, 23920, 23921, 23923, 24061, 23980, 23926, 24326, 23933, 23934, 23936, 23940, 24152, 23942, 23943, 23939, 23944, 23947, 23951, 23955, 23957, 23959, 23960, 23961, 24043, 23962, 23968, 23970, 23971, 23979, 23978, 23981, 23985, 23989, 23992, 23997, 23998, 23995, 23999, 24000, 24458, 24028, 24049, 24051, 24052, 24053, 24206, 24054, 24062, 11055, 24076, 24096, 24104, 24157, 24158, 24161, 24167, 24173, 24176, 24188, 24303, 3775, 24191, 24192, 24194, 24195, 24596, 24200, 24212, 15181, 29798, 24214, 24829, 24229, 25066, 24301, 24576, 24240, 24246, 24297, 24300, 24249, 24251, 24252, 24253, 24255, 24267, 24268, 24270, 24318, 24332, 24275, 24280, 24291, 24294, 24296, 24302, 24306, 24311, 24547, 24312, 24315, 24316, 24298, 24618, 24314, 24319, 31915, 24585, 24455, 25638, 24605, 24611, 34257, 24317, 24438, 24439, 24441, 24662, 24340, 24344, 24347, 24351, 24377, 24383, 24400, 24402, 26141, 24686, 25036, 29055, 24615, 146457, 24454, 24612, 24614, 24403, 24405, 24406, 24413, 24428, 24429, 24432, 24433, 24435, 24436, 24437, 24440, 24444, 24445, 24464, 24450, 24451, 26792, 24452, 24453, 24485, 24519, 24617, 24553, 24559, 24561, 24562, 24567, 24569, 24571, 24474, 24475, 24572, 24578, 24581, 24582, 24583, 24584, 24521, 24522, 24462, 24468, 24467, 146693, 24594, 24622, 24527, 25035, 26808, 24526, 24529, 24531, 29006, 24685, 24619, 25762, 24535, 24626, 24488, 24491, 24495, 24499, 24498, 24509, 24507, 24699, 24746, 24523, 24525, 11839, 24532, 24533, 24510, 24621, 24749, 24534, 24540, 25887, 24693, 24543, 24545, 148001, 24548, 24632, 24551, 25037, 24558, 24560, 24573, 25009, 25448, 24607, 24610, 25958, 24625, 24688, 24694, 14650, 24639, 24844, 24640, 24641, 24729, 24730, 24736, 24739, 24741, 25064, 147474, 24747, 24742, 24748, 24751, 25444, 25661, 24846, 24753, 25086, 25454, 25453, 25456, 25457, 147479, 25463, 25468, 25486, 25447, 25472, 25727, 25498, 25473, 25474, 25476, 25479, 24759, 25010, 24754, 24761, 27112, 24750, 24850, 25450, 25451, 26516, 25458, 25459, 24762, 24767, 24648, 24650, 24788, 24808, 24811, 24813, 24815, 24832, 24838, 25565, 24840, 24841, 24842, 25446, 25500, 25502, 25503, 25533, 25581, 25583, 25592, 25605, 25724, 25629, 28411, 25490, 25491, 25624, 25494, 25654, 25655, 25657, 25658, 25659, 25662, 25665, 25666, 25670, 25671, 25672, 25673, 25674, 25678, 26932, 25680, 25506, 25507, 25627, 26305, 25729, 25732, 25508, 25513, 25514, 25517, 25522, 25527, 25528, 25530, 25531, 25532, 25703, 27260, 25711, 25713, 25715, 25717, 25719, 25721, 25723, 25623, 25737, 25738, 25939, 25744, 25748, 25534, 25537, 25568, 25538, 25540, 26810, 25544, 25546, 25548, 25549, 25552, 25547, 25626, 25571, 25558, 25554, 25559, 25562, 26162, 25564, 25759, 25798, 26164, 25767, 25769, 25773, 25807, 25809, 25566, 25569, 25570, 26561, 25776, 25580, 25648, 30883, 25778, 25608, 25788, 27284, 25726, 25806, 25656, 25574, 25579, 25593, 25598, 25606, 27401, 25609, 25906, 25611, 26445, 25709, 25612, 25615, 25619, 25690, 25621, 26431, 25632, 25633, 25636, 25639, 25644, 25645, 26036, 25647, 31951, 26894, 25650, 25653, 147680, 25679, 25681, 25682, 25683, 25686, 25698, 25697, 25701, 25706, 25710, 25733, 25736, 25743, 25745, 147721, 25749, 25752, 25929, 25755, 26438, 11021, 25756, 25766, 25770, 26159, 27548, 25775, 25779, 25780, 25784, 26085, 25786, 25789, 25795, 26195, 25987, 26559, 159076, 27667, 25810, 25812, 25821, 25833, 25962, 25890, 25907, 25909, 25912, 26440, 26180, 25927, 25928, 25858, 25861, 25926, 25934, 25936, 25938, 26458, 17715, 25946, 25954, 145761, 26030, 26034, 26197, 28600, 26079, 28423, 26083, 25876, 26411, 26088, 25942, 26089, 26241, 26311, 26313, 26314, 26320, 26091, 26099, 26092, 25849, 25848, 26861, 26095, 26096, 25819, 26149, 26153, 145760, 26140, 26211, 26213, 26226, 26227, 17676, 26238, 25905, 26097, 26273, 26303, 26327, 27574, 26102, 26130, 28424, 26201, 25815, 25816, 26688, 26307, 26324, 26323, 25877, 25878, 26557, 26483, 26328, 26330, 26563, 26567, 26569, 25826, 25835, 25871, 25827, 25831, 26333, 26379, 26380, 26396, 25993, 26402, 26403, 28427, 26473, 26490, 26491, 25837, 25839, 26495, 26498, 25852, 25853, 25851, 25855, 25856, 26508, 145896, 25910, 26586, 26590, 26593, 26594, 26595, 25842, 25843, 26161, 25845, 25846, 25850, 25863, 25945, 25864, 25868, 25873, 25874, 25875, 27557, 25888, 25889, 25893, 25895, 25897, 25904, 26194, 25919, 26050, 25950, 26005, 26012, 26006, 25956, 26013, 25960, 25961, 25967, 25971, 27785, 27526, 25978, 25980, 30500, 25986, 26199, 25999, 29144, 26000, 26002, 26007, 26009, 26017, 26021, 26019, 26025, 26026, 145409, 27995, 26040, 26044, 26051, 26056, 26057, 26058, 26062, 26063, 28429, 26470, 26060, 26067, 26077, 26148, 26150, 26178, 27439, 26522, 26534, 26528, 159078, 26181, 26208, 26426, 28418, 26232, 26604, 26472, 26482, 26484, 27139, 26934, 26911, 26607, 26697, 145117, 26518, 26527, 26531, 26536, 26541, 26546, 26545, 26521, 26603, 28462, 26547, 28485, 26553, 26552, 26643, 26556, 26555, 27261, 27528, 26562, 26623, 26566, 26629, 26906, 26668, 26591, 26602, 27523, 26896, 26648, 26650, 28189, 26777, 26842, 26921, 26783, 27327, 26785, 26606, 26622, 26608, 26616, 26642, 26817, 26638, 28549, 26820, 26824, 26833, 26865, 26867, 26871, 26961, 26621, 26620, 26624, 26628, 26632, 26634, 26637, 26652, 26654, 26912, 26657, 26660, 26661, 26666, 26670, 26672, 26675, 26677, 26685, 27923, 26693, 26699, 18515, 26701, 26905, 26705, 26706, 26709, 18475, 27371, 28314, 26713, 26731, 26736, 26755, 26757, 26758, 26762, 26768, 148139, 26769, 26771, 28603, 27399, 26776, 26782, 27154, 27155, 26791, 26796, 26958, 27257, 26799, 26803, 26816, 26818, 27158, 26825, 26832, 26834, 26843, 26844, 26846, 26847, 26850, 27243, 26855, 26933, 26957, 28191, 26966, 27192, 28426, 27981, 27098, 27010, 27013, 26886, 27157, 26892, 27138, 27064, 27232, 27019, 27024, 27027, 27043, 27045, 27046, 145118, 27242, 27058, 27061, 27062, 27068, 27114, 27120, 27425, 27153, 27305, 27273, 27378, 26883, 26897, 27073, 27076, 27084, 27086, 27095, 27101, 27103, 27108, 27123, 159108, 27304, 27165, 26942, 27202, 27349, 27206, 27210, 27221, 148283, 27245, 27262, 27315, 27317, 27319, 26918, 26923, 26927, 26926, 27323, 27292, 27326, 27532, 27330, 27332, 27339, 28463, 27351, 27353, 27359, 27360, 27369, 26987, 27383, 27440, 28034, 26947, 26949, 26951, 26953, 26956, 27395, 22835, 27409, 27427, 27708, 27547, 26981, 32254, 27009, 27592, 27464, 27467, 27142, 27469, 27471, 27472, 145119, 27474, 27478, 27258, 26968, 26971, 26973, 26975, 27188, 26974, 27012, 27018, 27093, 27264, 27031, 27036, 27133, 27140, 27164, 146541, 27035, 27040, 27070, 27072, 27560, 27078, 30238, 27082, 27089, 27090, 27102, 27104, 27280, 27605, 27125, 27126, 144769, 27127, 27170, 27174, 27176, 27136, 27177, 27335, 27181, 27186, 27187, 27189, 27190, 27216, 27233, 27234, 27193, 27196, 27197, 27200, 27256, 27207, 27212, 144771, 27214, 27215, 27247, 27518, 28041, 27747, 27287, 27217, 27297, 27298, 27291, 27299, 27301, 27329, 27331, 27218, 27226, 27278, 27279, 27282, 27283, 27285, 27286, 27398, 27306, 27307, 27413, 28431, 17159, 27419, 27421, 146542, 27428, 27483, 27718, 27348, 27720, 27352, 28439, 27386, 27391, 27392, 27393, 27394, 28464, 27402, 27727, 27610, 27412, 27441, 27445, 27495, 27447, 27449, 27512, 27451, 27452, 27454, 27457, 27477, 27565, 27611, 27517, 28136, 28193, 27569, 27573, 27486, 27489, 28512, 27501, 27502, 27507, 27589, 27591, 27595, 27597, 27550, 27603, 29766, 27519, 27521, 27524, 147334, 27529, 28169, 27527, 27531, 27536, 27537, 27545, 27551, 27542, 27553, 27617, 27761, 27766, 31569, 125106, 27590, 27832, 5193, 27665, 27594, 27618, 27865, 27866, 27622, 27625, 27626, 27627, 27623, 27628, 27629, 27673, 27758, 11044, 27582, 27586, 27588, 27666, 28025, 27596, 27598, 27601, 27719, 28058, 27634, 14119, 27621, 27644, 29249, 27648, 27660, 27895, 28022, 27662, 28024, 27772, 27980, 28162, 27862, 27863, 27717, 28040, 27721, 27728, 27734, 27743, 27635, 27636, 27638, 125108, 27982, 30102, 27642, 125109, 28147, 27643, 27745, 27749, 28042, 27777, 27646, 27647, 27791, 28171, 27803, 27806, 27819, 27825, 27834, 27842, 27653, 27970, 15025, 27678, 34397, 27654, 27657, 27856, 27867, 27868, 28183, 27975, 27994, 27870, 27989, 135673, 28037, 27877, 28177, 27907, 27930, 27937, 30019, 28408, 28465, 28489, 27958, 27959, 28503, 28036, 28039, 28157, 28045, 28051, 28066, 28068, 30177, 28069, 28070, 28071, 28100, 28073, 28074, 28076, 28109, 12186, 27694, 27696, 30034, 27700, 28079, 28081, 28199, 28088, 28090, 28187, 27736, 125110, 28096, 28098, 28111, 28114, 27824, 27835, 28115, 28142, 28165, 28197, 28198, 28323, 28209, 27816, 28212, 28288, 27730, 27731, 27732, 30718, 28227, 28231, 28248, 28229, 28345, 28255, 28261, 28289, 28319, 27920, 28321, 27846, 28333, 28338, 28335, 28341, 27740, 27738, 28168, 139383, 27779, 27783, 27919, 27922, 28043, 27847, 27869, 28055, 27979, 27991, 28000, 28550, 27801, 27888, 27897, 27880, 28018, 27915, 27917, 27918, 27926, 27925, 28170, 28172, 27976, 28080, 28300, 27800, 27804, 27810, 27839, 27882, 27884, 27886, 27889, 28021, 27898, 27899, 27900, 27905, 27908, 28078, 27928, 27929, 27931, 27934, 28050, 28053, 28102, 28099, 28148, 27998, 28125, 28004, 28003, 28008, 28011, 32486, 28059, 28060, 28082, 28273, 28093, 28278, 28224, 28263, 28357, 28097, 28119, 28123, 28067, 28149, 28435, 28152, 28153, 28186, 140914, 28220, 28226, 28230, 17379, 28235, 28238, 28244, 28761, 28250, 28254, 28259, 28266, 28268, 28271, 144773, 28275, 28276, 28282, 28284, 28285, 28291, 28580, 28292, 28294, 28265, 28293, 144873, 28305, 28312, 28310, 28313, 30035, 28533, 28572, 28510, 28495, 28499, 28893, 28360, 28376, 28377, 28381, 28396, 28397, 28614, 28354, 28918, 28399, 28359, 146357, 13356, 30032, 32851, 28380, 28434, 125111, 30007, 147323, 28504, 28506, 144791, 28541, 28402, 30024, 28351, 28352, 28353, 28635, 28456, 29268, 28494, 28481, 28507, 28362, 28363, 125112, 28634, 28888, 28637, 28639, 28640, 28657, 28658, 28371, 28378, 28483, 30030, 28484, 30033, 28599, 28365, 30014, 28649, 28653, 12821, 28368, 28578, 30068, 28609, 30013, 28389, 31048, 28403, 28474, 28496, 28523, 28528, 28530, 28405, 144944, 28451, 28455, 28568, 28574, 30017, 28862, 28458, 28461, 28878, 28471, 28477, 28540, 28576, 28581, 28583, 28588, 28591, 28596, 28927, 28618, 146543, 28624, 28622, 28626, 28628, 28631, 28682, 28694, 30096, 34171, 30097, 30100, 30018, 30046, 28665, 28921, 28671, 20422, 28674, 28675, 28678, 28677, 28676, 28681, 28903, 28905, 28907, 28909, 28912, 28913, 28917, 32786, 28919, 29472, 28686, 28691, 30104, 28939, 30106, 28949, 28964, 29047, 28967, 30108, 28979, 30113, 28982, 29019, 29025, 147335, 28764, 29059, 28828, 28988, 29512, 30726, 29797, 29052, 29001, 28695, 28700, 30117, 28710, 30121, 30341, 28716, 30144, 11879, 30145, 30146, 28843, 31798, 29508, 30241, 29035, 10660, 28733, 28741, 144938, 28752, 28755, 30161, 30239, 30207, 29064, 29067, 140701, 29068, 30991, 28773, 28778, 28841, 29219, 30237, 28781, 28783, 28950, 30020, 28786, 28794, 28787, 29107, 30240, 30490, 30262, 28811, 28815, 28824, 28858, 33466, 28834, 28832, 28851, 28876, 29277, 29189, 30265, 28970, 30268, 29128, 28792, 29351, 28793, 28797, 28799, 28801, 28803, 28804, 28806, 28826, 28845, 28846, 28849, 28850, 30042, 28900, 28902, 28904, 29955, 29162, 30040, 28924, 28938, 29796, 29042, 28940, 28943, 28945, 28968, 29007, 30260, 29013, 29014, 29020, 30054, 29023, 29026, 29034, 29036, 29072, 29493, 29156, 30483, 29085, 5504, 29496, 32051, 30488, 29488, 29749, 29094, 29093, 29143, 29148, 29152, 29153, 145104, 29179, 29204, 35631, 29250, 29340, 29343, 29591, 29348, 14908, 30213, 30605, 29278, 29305, 29308, 29167, 29767, 30342, 125115, 29188, 29174, 29320, 30211, 30212, 30209, 29702, 29336, 30222, 30223, 29355, 29183, 30312, 29191, 29790, 29200, 29201, 30491, 18636, 29532, 30224, 29364, 29365, 30225, 29374, 34246, 29665, 29317, 29458, 29464, 29468, 29453, 29511, 29522, 29224, 29185, 29186, 29533, 159093, 159091, 30226, 29221, 30227, 29382, 29384, 29555, 30242, 29393, 29395, 29397, 29401, 29418, 29222, 29195, 30066, 29537, 29543, 29220, 29414, 29544, 29235, 29236, 29425, 29795, 146694, 29545, 30202, 29548, 29549, 30298, 29205, 29269, 29206, 29215, 30076, 29234, 29237, 29559, 29247, 29289, 125116, 29299, 29471, 29292, 29293, 159080, 138579, 30492, 30249, 34300, 29415, 31165, 29253, 29426, 29956, 29279, 18928, 29256, 29258, 29288, 29259, 29295, 30495, 159551, 29261, 29267, 29270, 29273, 29283, 29286, 29290, 29291, 29296, 29325, 29327, 29328, 30317, 29335, 29410, 30217, 29367, 29429, 30219, 29483, 30407, 30218, 29377, 30343, 29381, 29387, 29389, 29678, 147387, 29755, 30243, 34301, 29423, 30252, 29478, 145796, 11202, 29454, 29456, 29889, 30231, 30508, 30220, 29498, 36280, 159563, 30221, 29436, 29438, 29437, 29442, 29443, 29444, 29445, 29992, 34019, 30235, 29449, 29486, 30398, 14098, 29769, 29771, 29487, 29492, 6119, 29500, 29507, 29515, 29517, 29518, 29773, 30332, 29813, 30509, 30189, 29526, 29658, 30191, 29776, 29785, 29837, 29550, 29712, 30229, 29558, 30190, 29744, 29777, 147388, 30230, 29654, 30501, 29699, 29574, 29705, 29715, 29716, 35355, 29839, 30411, 145884, 30420, 29586, 29587, 29590, 30003, 29802, 29806, 15006, 29812, 29843, 29886, 29646, 29906, 29908, 29913, 29599, 16450, 29600, 38984, 29606, 30198, 159547, 30200, 29633, 29636, 29706, 29642, 29953, 29960, 29717, 29959, 29967, 29970, 29615, 29616, 30338, 29973, 29628, 35307, 29629, 29630, 29996, 29998, 30002, 29799, 30005, 30519, 30328, 29666, 29689, 29704, 30331, 30063, 11201, 29817, 29730, 30493, 29838, 147390, 29741, 29752, 30497, 29762, 29763, 29764, 29869, 29770, 29805, 30351, 30352, 30353, 30354, 30355, 29846, 29848, 29850, 30357, 29853, 30361, 29857, 29867, 30401, 30585, 29873, 29877, 30381, 29882, 29910, 29911, 29915, 30387, 29917, 147391, 29918, 29919, 29916, 32075, 29920, 30394, 29930, 29933, 29935, 29939, 30419, 30301, 29941, 19220, 29975, 29977, 30071, 30073, 30127, 29979, 29981, 29986, 29991, 30105, 30550, 30009, 30015, 30056, 155933, 30060, 30029, 30807, 30038, 30487, 30282, 30065, 30074, 30080, 30089, 30095, 30103, 30502, 123954, 30558, 30116, 30201, 30120, 30123, 30314, 30320, 30155, 30167, 30358, 30168, 30129, 30319, 30141, 30531, 30369, 30180, 30199, 30567, 30204, 30486, 30151, 30277, 30158, 30159, 30503, 30160, 30172, 30206, 30417, 30208, 30467, 31554, 30215, 30263, 30267, 30275, 30284, 30300, 30302, 30636, 30378, 30279, 30403, 30410, 30421, 30425, 30427, 30432, 30504, 30450, 30453, 30489, 30471, 30476, 30484, 30619, 30857, 30506, 33440, 30515, 30276, 30429, 30278, 30281, 30522, 30525, 30496, 30386, 123955, 30539, 30543, 30546, 30583, 147336, 31921, 30548, 30559, 30305, 30565, 30574, 30576, 30578, 30579, 30371, 34173, 30582, 30584, 30586, 30434, 30577, 30591, 30593, 30595, 31009, 18106, 30588, 30592, 30292, 30494, 30673, 30516, 30306, 30359, 30362, 147392, 30436, 30511, 30635, 30639, 32012, 30526, 32977, 30667, 30440, 30449, 30452, 30485, 30560, 30573, 30601, 146064, 30616, 30470, 21867, 30473, 30478, 30498, 30480, 30481, 30505, 30507, 30514, 30532, 30533, 30535, 30536, 30538, 30684, 30648, 30655, 31761, 30652, 30654, 30663, 30665, 30594, 30671, 30740, 30677, 30679, 147393, 30680, 30681, 30824, 30687, 31835, 31374, 30694, 36644, 145640, 30600, 30790, 30700, 30720, 30722, 30831, 31135, 32052, 34115, 30731, 30805, 30629, 30910, 31005, 30733, 30735, 30738, 30769, 30773, 30780, 30791, 30813, 30602, 30819, 30821, 145084, 15878, 30830, 30864, 30882, 30892, 30893, 30911, 30915, 30920, 30612, 30613, 30615, 31136, 145885, 31144, 31151, 31153, 31155, 31159, 30919, 30925, 17804, 31008, 30926, 30620, 30623, 31053, 31128, 135468, 30670, 31160, 31161, 30927, 17956, 30929, 30608, 30611, 31133, 30936, 138591, 31010, 31002, 31107, 31119, 30996, 30937, 30940, 30943, 31018, 30955, 30959, 30961, 30984, 30988, 30904, 31000, 31001, 31004, 31006, 31164, 159543, 31169, 31168, 31171, 145886, 31177, 15294, 30640, 30644, 30646, 30658, 30661, 30746, 30675, 30678, 30685, 30686, 30856, 30848, 31118, 32073, 30688, 30692, 30695, 30697, 30714, 30749, 30754, 32047, 30759, 30776, 12464, 30862, 30803, 30816, 30818, 30828, 30834, 147395, 30852, 30853, 30854, 30860, 30865, 30863, 30887, 30896, 30886, 30901, 31710, 30939, 30944, 31241, 30949, 30868, 30979, 30871, 30873, 31126, 31129, 32105, 31120, 31462, 30875, 30878, 30877, 30881, 145887, 30951, 30953, 30958, 30993, 30960, 31022, 30963, 31317, 31409, 30968, 30969, 30971, 31463, 30972, 31255, 30973, 30975, 30976, 30977, 30978, 30981, 30986, 30987, 30989, 30994, 31019, 31025, 31507, 30980, 31103, 31199, 31464, 31446, 31026, 31034, 31037, 144815, 31049, 31054, 31055, 31061, 31062, 31067, 31095, 31089, 31188, 31190, 31192, 147433, 31428, 31063, 31068, 31069, 20381, 31046, 146067, 31072, 31073, 31109, 31111, 31112, 31074, 31076, 31082, 31081, 31080, 31084, 31086, 31377, 31413, 31090, 31097, 159546, 31100, 31101, 31137, 31142, 31145, 31175, 31176, 31179, 31182, 31184, 31257, 31262, 31264, 31193, 40569, 31196, 159549, 159550, 22214, 31411, 31212, 31239, 31202, 31205, 18479, 31272, 31263, 31265, 31270, 31292, 31294, 31296, 31339, 31343, 31345, 18488, 31415, 31256, 31398, 31867, 31455, 31401, 31402, 31404, 31273, 31407, 31214, 135213, 31213, 125122, 31223, 31297, 31216, 31452, 31454, 31456, 31260, 31281, 31217, 31219, 31218, 31221, 31258, 31220, 31224, 31225, 31465, 31466, 31470, 31472, 31476, 31477, 31229, 31596, 33157, 145888, 31238, 32097, 31247, 31737, 31267, 31269, 31271, 31287, 31277, 31303, 125123, 31795, 31302, 10766, 31326, 33331, 31423, 147765, 31822, 31424, 31279, 31435, 32048, 31286, 31290, 31293, 31387, 31295, 31298, 31299, 31300, 31733, 31309, 31506, 11025, 31520, 31479, 31480, 138233, 31362, 31521, 23359, 23511, 31907, 31533, 34278, 31310, 31371, 31311, 31315, 31316, 159619, 159614, 31389, 146068, 31447, 31547, 31318, 31320, 31356, 31336, 31481, 31739, 31321, 31324, 31368, 31334, 125127, 31329, 31328, 31361, 31359, 31330, 31331, 125125, 31372, 145889, 31380, 31382, 31905, 31332, 31344, 31347, 31348, 31349, 31352, 31353, 32067, 31363, 31364, 31365, 11260, 31391, 31393, 31509, 159610, 18057, 32069, 31394, 31395, 31397, 31449, 31410, 31426, 31430, 31486, 31431, 31437, 31633, 31556, 31508, 31871, 32264, 31595, 31513, 32072, 31560, 159628, 31496, 31498, 31563, 31519, 31523, 31549, 31529, 31570, 147318, 31581, 31589, 31593, 31536, 31488, 32804, 31499, 34389, 31490, 125126, 31515, 31491, 31492, 31494, 31537, 31538, 20465, 31650, 31493, 31501, 31648, 31503, 31602, 16272, 31517, 31873, 34339, 31525, 31526, 31527, 31532, 31531, 32060, 31630, 31545, 31546, 31893, 31877, 31550, 31668, 31673, 31682, 31719, 31724, 31727, 31617, 31800, 31728, 11964, 31743, 31807, 31715, 31716, 31754, 31760, 31763, 31764, 31641, 31941, 31726, 160416, 31766, 32064, 32456, 31621, 31772, 31777, 31767, 31932, 31709, 10901, 31768, 11965, 20538, 146615, 31769, 31647, 31771, 31778, 31779, 31557, 31792, 31794, 31879, 31883, 160402, 31919, 31926, 31929, 31928, 31930, 31592, 31925, 31826, 31933, 31936, 31937, 31939, 31938, 31940, 31987, 31989, 31561, 31562, 31699, 31706, 31712, 31729, 32046, 31735, 31736, 147320, 31804, 31809, 31811, 35765, 31564, 31588, 12226, 31625, 31631, 31669, 31671, 31899, 31678, 31688, 31694, 31742, 31791, 31802, 31820, 31904, 31744, 31745, 31747, 31749, 31746, 31751, 31757, 32050, 14533, 32053, 31955, 31958, 31759, 31967, 31782, 31828, 31832, 31839, 31866, 31841, 32251, 31895, 31896, 31898, 31903, 31851, 31853, 31854, 31852, 32066, 31857, 33735, 31872, 31874, 31876, 31909, 31910, 32035, 31916, 31924, 31946, 31952, 31959, 22140, 31968, 31974, 31975, 32096, 31976, 31978, 31982, 31983, 32121, 31984, 31986, 32043, 32054, 32055, 25040, 32070, 19442, 32084, 32100, 32106, 32727, 32112, 14699, 32117, 32125, 32250, 34051, 38327, 135628, 32312, 32294, 32297, 32246, 32252, 32253, 32255, 32256, 32262, 32265, 32372, 32008, 33956, 32270, 32142, 32515, 32034, 32298, 32302, 32304, 32306, 124121, 32088, 32308, 32322, 32327, 32039, 32006, 33332, 32728, 32009, 32010, 32011, 32328, 33160, 32519, 32014, 32019, 32022, 32024, 32028, 32030, 32033, 32059, 32074, 32076, 32081, 32083, 36275, 32164, 32344, 33163, 32278, 32102, 32107, 32109, 32120, 32124, 32128, 32133, 32135, 32136, 33465, 32137, 32141, 32146, 32169, 32457, 32555, 32279, 32295, 32309, 32319, 32330, 32335, 32380, 32396, 32401, 32409, 32410, 32414, 32416, 32418, 32530, 147396, 32518, 32419, 11015, 25505, 32487, 32491, 32370, 160520, 32427, 32429, 32437, 32448, 32336, 32337, 32339, 32341, 139286, 32455, 32955, 32458, 32468, 32483, 32485, 32547, 33166, 32493, 32495, 32497, 32500, 32367, 32505, 32520, 32526, 32528, 32580, 32543, 32348, 32350, 32356, 32521, 32357, 32359, 32362, 32549, 32551, 32572, 32574, 32576, 32383, 32425, 32579, 32582, 32461, 32583, 32678, 32463, 32381, 145890, 32586, 32375, 32590, 148143, 32594, 32595, 32641, 32646, 33986, 32386, 32652, 32654, 32656, 32554, 160427, 34509, 32597, 32599, 32601, 32733, 32606, 125710, 32668, 148301, 32608, 144806, 32650, 32683, 32663, 32552, 32462, 32664, 32496, 32667, 32670, 32392, 32393, 144817, 32672, 32675, 32398, 32417, 34385, 32885, 32674, 32676, 32677, 32513, 32679, 32384, 32385, 32387, 32400, 32411, 32413, 160494, 32415, 32434, 32470, 32471, 32473, 32477, 32482, 32492, 145891, 32494, 32499, 32501, 32504, 32506, 32507, 32544, 32546, 32548, 32558, 32559, 32560, 32571, 32690, 32701, 32573, 32577, 32642, 32598, 32686, 32839, 33685, 32841, 32834, 32607, 32612, 32614, 32638, 32644, 32648, 32653, 32688, 33379, 32695, 34244, 33294, 32696, 32698, 32717, 33114, 32766, 32781, 32821, 32825, 147398, 33388, 32868, 32876, 32883, 32737, 32887, 32709, 32712, 32713, 32719, 32721, 32734, 32736, 32753, 32754, 32738, 33204, 32739, 32741, 32742, 147434, 32891, 32895, 32747, 32748, 32750, 32763, 147641, 32751, 32752, 32909, 32912, 32916, 32919, 32927, 32931, 32932, 32935, 32936, 33930, 32942, 32944, 32947, 145096, 33046, 32951, 32952, 32780, 32956, 32958, 32986, 32991, 33000, 147401, 33041, 32785, 33048, 33049, 33050, 32993, 33051, 32767, 32802, 32808, 32770, 32773, 32774, 32771, 33060, 33062, 33064, 33074, 33078, 33080, 33083, 33085, 33089, 33106, 144872, 33099, 33105, 33109, 33134, 33165, 32782, 10664, 32783, 33389, 32884, 32788, 32791, 32792, 32795, 32796, 32797, 32798, 32800, 32801, 32803, 33014, 145734, 32812, 32813, 32816, 32972, 32822, 32920, 32888, 1705, 32838, 33015, 32844, 34177, 32850, 144871, 32854, 34363, 33797, 33010, 33012, 33202, 33185, 32905, 32881, 32965, 124241, 33120, 33391, 32973, 32975, 32980, 32982, 32987, 33021, 33054, 33061, 33077, 33086, 33088, 33098, 33108, 33187, 33119, 33123, 33124, 25251, 140852, 33133, 33181, 33183, 33188, 33208, 35112, 33263, 33138, 33140, 33141, 33143, 33145, 33147, 34303, 33149, 33150, 34172, 33152, 33153, 33155, 33175, 33176, 33445, 33178, 33184, 147399, 33189, 33310, 33311, 33190, 33191, 33192, 33170, 33461, 33174, 33275, 33286, 33288, 33293, 33299, 33302, 34073, 34326, 33401, 33539, 34369, 33341, 33342, 33450, 34136, 33210, 33212, 33205, 34106, 33222, 33224, 33296, 34374, 33223, 33237, 33405, 33395, 33239, 33355, 33242, 33244, 33249, 33424, 33251, 16438, 33262, 33264, 145742, 33291, 33253, 33255, 33362, 33371, 33372, 33392, 34245, 33412, 33415, 33416, 33419, 33420, 33417, 33266, 33276, 25582, 33284, 33690, 34094, 33297, 33324, 33328, 33337, 33350, 33358, 33360, 33442, 33369, 33651, 42379, 33716, 33719, 34327, 33374, 33407, 33413, 33799, 144818, 33427, 33429, 33437, 33647, 33451, 33453, 33457, 33458, 33603, 33613, 33614, 33987, 33816, 34024, 34035, 33644, 33957, 33896, 33692, 33730, 33757, 33818, 33820, 34232, 33731, 34238, 33714, 33885, 33894, 34236, 33722, 36844, 34068, 33984, 33985, 33893, 125134, 34357, 33884, 33868, 34519, 33954, 33955, 33959, 33966, 33970, 25585, 33971, 33976, 33995, 33969, 34030, 34043, 34045, 34048, 34107, 33914, 34105, 33686, 34207, 34102, 34104, 145323, 34058, 34112, 34088, 34089, 34091, 34116, 34092, 34093, 34097, 34098, 33608, 34099, 34100, 34103, 144758, 34014, 34108, 34109, 33800, 33838, 34259, 34133, 33888, 33915, 33988, 34127, 33917, 34155, 33536, 32031, 33552, 33654, 33999, 33891, 125136, 34006, 33691, 33916, 34119, 159646, 145912, 33693, 33883, 33886, 33887, 34004, 33813, 33697, 33889, 33874, 34027, 34033, 159630, 145745, 33715, 125135, 33918, 33981, 33815, 34233, 34280, 33920, 125137, 34001, 34002, 159629, 34003, 34221, 34007, 34008, 34398, 33922, 34158, 34036, 34017, 34039, 145735, 159089, 31827, 33937, 33979, 33990, 33991, 33994, 33997, 34308, 34010, 34166, 34011, 34021, 145736, 159092, 34040, 34063, 34038, 34041, 34044, 34047, 34049, 34159, 34052, 34151, 145324, 34125, 34075, 34275, 34079, 34128, 34055, 34056, 34060, 34059, 34062, 34231, 34313, 34067, 34072, 34071, 34251, 34253, 34162, 34168, 34070, 145866, 34500, 34074, 34076, 34078, 34174, 34080, 34081, 34082, 34090, 34114, 34124, 34154, 34156, 34237, 34243, 34153, 34157, 34161, 34129, 34132, 145305, 34167, 34170, 34178, 34183, 34184, 34196, 34225, 34227, 34229, 34247, 34248, 34250, 34260, 34261, 34317, 38986, 34126, 34131, 34134, 34135, 34139, 34142, 34144, 34143, 34146, 34145, 34147, 34148, 34150, 34230, 34228, 34152, 23638, 34191, 34372, 34190, 37683, 34160, 34165, 16448, 34175, 34314, 34182, 34185, 34263, 23639, 34186, 34358, 34187, 34285, 32223, 34192, 34195, 34197, 34198, 34200, 34204, 34205, 34209, 34210, 34219, 34220, 34222, 34546, 34226, 34277, 34264, 34266, 34268, 34304, 34329, 34376, 18551, 34262, 34378, 34315, 34380, 34270, 34271, 34272, 34273, 34276, 34282, 34283, 34284, 34288, 34290, 34292, 34293, 34294, 34295, 34296, 34297, 34298, 124306, 34299, 34394, 34310, 33586, 34319, 34321, 34322, 34406, 34418, 34420, 34424, 34425, 34341, 34348, 34350, 34395, 34399, 34431, 34433, 34340, 34441, 34458, 34460, 34499, 35926, 34501, 36672, 34502, 34598, 34600, 124495, 34342, 34346, 34347, 34503, 34506, 34511, 34521, 34330, 34337, 34561, 34445, 33578, 34338, 34524, 34525, 34604, 34532, 34371, 34622, 145867, 34381, 34440, 34439, 34456, 34459, 33819, 34353, 34633, 34608, 34639, 137791, 34645, 34648, 34355, 34356, 145738, 34375, 34379, 34442, 34468, 34469, 34487, 32969, 34632, 34483, 33492, 34488, 34497, 34540, 34549, 34543, 34552, 34555, 34564, 34566, 34571, 34658, 25075, 34634, 144741, 34640, 33837, 35349, 22819, 34573, 34575, 31960, 33919, 31957, 31799, 147400, 34083, 155538, 31664, 34580, 34590, 35015, 34434, 34255, 34417, 33910, 34493, 32198, 31038, 31666, 32269, 32266, 35097, 145325, 32222, 35116, 1292, 31956, 30405, 32310, 18630, 34085, 34414, 31961, 26261, 34605, 32428, 33864, 144867, 31338, 33926, 33812, 33446, 37341, 33349, 22467, 33252, 33285, 33811, 35150, 33932, 33240, 32714, 35123, 35119, 35213, 33786, 145741, 33287, 36216, 32705, 33899, 32707, 32710, 33911, 33599, 33034, 32922, 35140, 3387, 33521, 33862, 33863, 33728, 159095, 147403, 33939, 33872, 33947, 33879, 33858, 13337, 33876, 33814, 34069, 33827, 33472, 33829, 33900, 33570, 34066, 33760, 17054, 33723, 33817, 33839, 33834, 35664, 33822, 33710, 33709, 33738, 33739, 17322, 33768, 33770, 148306, 33740, 33765, 32451, 35237, 35261, 148496, 159097, 33785, 33741, 35309, 33753, 33772, 16434, 33773, 33776, 33778, 33779, 145740, 33810, 33235, 11864, 36884, 159626, 33489, 33725, 33726, 33759, 33646, 147402, 35283, 33908, 33909, 18044, 35308, 35284, 24025, 33923, 34516, 33234, 33572, 17499, 34505, 33980, 34432, 34400, 34522, 33218, 33233, 33488, 33664, 145743, 33199, 33490, 33491, 36915, 33431, 17101, 33501, 33474, 33541, 1791, 33625, 33557, 33558, 33593, 33595, 145916, 34064, 33590, 33519, 36283, 33381, 33594, 33414, 33473, 33477, 33478, 33481, 33514, 33483, 35722, 33600, 34579, 17752, 33486, 33503, 33509, 18577, 33515, 33516, 33523, 33525, 33528, 33529, 37602, 33537, 33546, 33550, 33561, 33638, 32880, 33565, 33604, 33601, 1962, 33612, 33551, 33616, 33673, 33611, 33617, 35805, 34453, 5306, 33621, 33630, 33635, 18098, 33643, 33657, 33196, 33648, 33665, 33667, 33669, 2364, 33679, 33682, 33663, 33689, 33713, 32453, 34404, 33563, 33607, 37673, 33411, 33425, 32138, 13751, 33428, 159624, 33579, 33382, 145862, 31041, 35650, 23718, 33580, 33568, 33195, 33510, 33213, 33484, 32867, 32882, 32866, 33853, 33448, 33449, 33581, 33384, 33201, 33566, 31039, 31032, 125118, 33555, 33553, 144876, 20946, 33524, 33444, 31781, 32899, 33480, 33348, 33351, 31638, 31825, 33383, 33038, 33044, 145744, 32824, 144874, 33380, 159636, 159673, 33385, 37122, 32157, 33386, 1813, 33270, 31045, 31639, 32038, 33400, 160038, 33404, 32131, 35020, 35811, 34000, 33406, 32894, 37810, 32132, 34617, 31066, 33017, 33009, 31636, 31637, 36376, 31817, 21543, 31789, 37020, 32996, 31003, 35067, 32775, 159631, 32063, 35957, 35579, 31814, 32130, 37651, 32065, 32057, 32058, 34370, 34354, 34603, 159638, 159643, 33214, 32115, 31635, 35120, 31868, 33927, 31662, 33975, 40062, 31663, 34306, 32182, 32183, 31634, 32200, 31642, 31653, 31654, 35279, 36070, 30414, 31665, 33948, 34311, 33950, 34599, 34307, 36023, 34588, 35036, 34635, 145746, 35628, 34013, 35335, 34366, 36256, 34217, 35071, 35822, 34211, 34206, 35850, 145915, 34312, 34572, 33998, 34597, 35070, 35750, 100029, 35073, 34410, 15404, 34396, 34582, 34587, 34392, 34601, 34643, 34558, 34568, 145897, 35663, 35661, 34467, 35792, 35814, 34578, 34455, 34614, 36284, 37660, 35041, 35842, 145818, 35826, 34452, 145898, 35470, 31608, 36318, 35885, 35888, 34512, 40063, 34642, 34390, 35008, 34563, 35791, 35596, 34403, 32694, 36072, 35774, 35643, 146273, 36061, 36258, 35701, 35746, 35740, 35755, 35759, 35762, 36202, 145391, 36034, 36040, 36038, 22278, 36041, 36044, 35418, 147324, 36099, 36045, 36076, 144734, 36047, 36048, 36050, 36053, 36057, 36063, 36068, 36069, 36082, 35531, 36084, 36086, 35430, 35472, 36096, 36180, 35422, 35423, 35339, 35341, 1841, 35343, 145913, 35398, 35465, 20921, 35476, 35497, 36144, 125300, 36159, 32174, 32170, 36198, 36218, 145945, 36219, 35481, 33850, 147938, 35788, 35480, 145899, 36240, 146175, 34214, 36226, 35544, 36102, 35483, 35758, 34527, 32175, 35969, 36272, 11440, 31606, 36236, 35807, 33958, 32162, 32166, 26694, 32167, 32168, 33973, 35955, 38990, 35891, 32172, 33843, 36173, 34087, 159632, 35982, 35984, 35415, 35267, 35268, 33848, 33898, 36246, 36249, 36252, 123947, 36253, 35971, 34473, 33024, 36147, 34486, 145914, 36104, 35987, 36066, 35944, 34484, 35974, 35062, 127718, 35411, 35338, 35265, 35421, 35951, 35968, 35961, 124986, 35963, 35970, 35953, 159633, 35973, 35254, 34095, 35959, 36011, 35942, 34199, 35568, 35377, 40082, 36051, 36043, 36347, 35948, 35420, 143956, 34659, 34437, 36274, 35785, 35586, 35922, 159660, 159662, 159655, 25761, 35702, 145943, 35754, 144223, 35757, 35536, 35724, 35145, 35903, 35897, 35655, 159649, 137694, 35174, 35292, 35383, 35369, 34022, 35381, 35588, 36163, 145243, 35614, 34613, 147405, 35388, 35403, 40530, 35590, 37669, 36360, 144739, 35992, 35589, 35599, 35408, 35761, 35619, 35370, 36315, 36317, 159659, 35733, 35996, 35983, 35753, 36080, 36081, 36078, 35428, 37021, 35647, 35629, 36230, 35851, 35387, 35400, 35405, 35080, 147406, 35223, 35098, 35232, 35202, 35478, 35258, 135696, 35149, 146016, 34023, 14668, 35426, 36342, 35640, 36311, 35781, 32562, 36324, 36330, 35790, 35561, 35832, 142016, 35890, 34215, 35630, 35708, 36350, 36646, 36351, 35867, 33949, 35786, 36146, 7588, 35700, 33783, 25894, 36341, 145148, 11035, 11372, 35705, 36334, 37675, 35666, 36335, 34513, 35084, 35173, 36241, 33364, 35688, 138609, 35669, 35576, 35894, 35954, 35936, 35632, 35905, 35906, 33774, 18766, 35678, 35896, 33782, 33972, 34570, 35686, 36172, 34029, 127720, 35673, 36406, 36339, 36383, 138569, 36370, 32704, 36155, 34012, 36960, 35703, 34450, 34409, 34574, 138610, 36092, 36365, 36377, 35670, 35892, 34569, 37044, 36127, 36162, 34559, 38829, 36382, 36368, 36161, 36028, 35986, 34084, 34557, 34620, 159657, 159653, 33993, 145984, 36089, 34586, 35078, 35952, 145917, 35419, 36990, 159656, 34508, 32921, 33755, 146053, 33032, 32984, 36373, 15657, 1517, 35829, 10609, 36049, 36037, 16040, 34526, 36013, 36374, 36375, 35710, 32928, 35893, 32929, 32926, 33784, 35819, 35473, 35092, 36169, 36331, 35250, 32966, 33940, 33835, 33748, 36091, 33787, 147408, 36381, 33037, 34386, 36333, 36319, 36369, 35988, 36371, 35904, 36988, 36328, 36008, 36094, 36055, 5771, 35598, 35515, 35009, 35336, 36251, 35773, 36353, 35907, 145430, 36234, 147409, 36167, 36238, 35800, 35810, 145985, 36129, 36581, 34592, 35706, 35474, 35350, 35375, 11215, 36113, 35379, 35435, 38172, 145281, 35555, 35484, 160891, 35165, 36386, 36405, 15920, 145440, 36093, 36064, 125627, 35180, 36062, 35482, 36358, 34649, 24930, 36337, 35838, 34507, 36384, 32979, 36385, 36157, 30625, 36393, 35244, 36220, 36338, 36221, 36403, 34449, 35204, 38105, 36022, 36671, 4189, 33931, 36348, 36404, 36000, 35934, 36088, 36020, 38807, 135889, 138071, 35998, 34050, 36158, 147570, 35830, 35975, 35994, 35518, 35831, 36021, 36149, 38510, 36176, 6452, 36024, 37045, 33974, 36137, 36143, 36152, 36153, 35253, 36156, 36177, 35965, 36527, 36191, 36012, 36247, 36248, 36259, 36165, 34435, 36168, 36994, 36174, 36175, 36401, 36181, 36237, 36235, 36444, 36189, 36150, 38989, 159710, 34647, 32158, 36858, 35711, 35884, 36516, 36018, 36182, 35879, 36388, 34515, 147466, 36227, 3975, 34213, 35108, 35401, 35391, 36481, 142017, 36479, 36489, 37782, 36491, 38688, 36514, 1527, 1159, 34490, 36200, 34034, 34612, 35220, 36065, 35155, 36521, 38866, 33354, 36114, 1725, 36032, 33989, 35083, 35191, 34457, 35260, 35262, 36513, 147410, 145986, 1230, 1572, 1427, 35114, 35115, 35130, 34413, 35264, 35552, 35485, 35492, 35142, 35061, 35532, 147569, 37100, 35363, 35440, 35538, 35442, 36652, 35462, 35714, 36184, 35376, 35742, 36031, 35194, 36035, 35549, 145662, 35649, 35841, 9358, 35042, 36797, 35919, 35717, 35947, 35950, 35967, 35055, 9273, 35057, 36103, 147571, 35282, 35550, 35384, 35385, 36288, 35794, 35546, 35548, 159458, 35099, 35902, 147572, 35005, 36461, 36707, 35447, 36439, 35217, 35940, 125568, 35539, 35876, 35129, 35406, 35816, 146065, 35219, 35776, 35899, 35978, 35818, 36735, 35943, 33875, 147321, 35921, 36712, 36186, 35354, 35920, 35697, 36139, 35674, 35679, 18352, 35698, 35929, 35809, 35870, 35911, 35910, 146183, 35093, 35095, 35551, 35863, 145780, 138612, 144730, 35569, 35853, 35923, 1949, 35347, 35730, 35575, 34365, 35235, 35359, 36665, 35854, 35221, 35900, 36135, 36121, 35793, 35713, 36005, 36483, 35687, 2045, 37037, 22522, 36625, 35566, 35901, 36170, 17964, 36179, 33095, 33376, 36116, 37203, 33366, 33849, 33238, 34654, 36357, 35737, 36164, 36845, 36166, 34656, 36138, 21551, 37257, 36586, 34631, 36130, 35096, 35494, 36387, 35557, 35914, 23147, 159714, 36595, 35558, 36820, 38572, 36510, 14403, 37082, 11306, 35166, 35085, 36001, 36411, 36207, 147322, 36178, 35995, 36017, 36019, 36160, 36142, 37137, 35960, 36900, 35981, 159696, 36599, 36400, 36250, 2040, 35709, 36641, 36408, 36415, 36416, 36430, 11056, 38915, 36431, 36442, 36459, 35618, 146614, 36694, 35372, 36108, 36465, 36584, 36474, 36443, 36908, 36619, 36025, 36482, 36451, 36894, 35366, 27423, 36535, 36528, 36532, 36534, 36686, 34077, 36910, 36621, 124299, 36568, 35360, 35193, 35275, 36574, 35592, 36649, 36550, 36917, 35563, 36585, 36397, 36647, 36984, 35985, 36687, 36651, 36662, 126022, 36399, 36394, 145362, 36648, 36642, 36600, 36605, 36609, 36612, 36615, 35672, 36420, 36633, 35429, 36673, 36639, 23581, 146496, 36927, 36645, 36640, 146616, 36654, 36635, 126345, 36657, 36661, 36781, 36663, 36733, 36664, 159083, 38916, 36666, 36668, 36670, 36678, 35414, 36831, 35416, 35675, 36697, 35620, 36740, 146617, 18130, 36795, 36802, 21504, 36425, 35845, 36344, 36708, 36838, 36719, 36722, 36131, 36124, 36730, 36843, 36747, 38797, 18076, 34101, 36879, 36742, 34218, 35169, 36755, 36757, 36759, 36772, 36790, 36929, 36799, 36803, 36804, 36806, 126023, 36810, 36821, 36823, 36826, 35712, 36852, 35751, 35006, 36899, 22999, 36835, 36840, 36841, 146619, 36846, 36847, 36848, 36851, 36878, 36850, 36849, 36855, 36881, 36932, 36856, 36867, 37241, 36869, 36870, 35135, 146620, 35979, 35989, 40446, 35993, 36892, 36893, 146621, 36902, 18257, 36905, 36947, 36948, 41377, 36949, 37023, 36950, 36952, 36953, 36954, 36955, 36975, 36992, 36991, 36993, 18562, 36998, 37076, 37013, 37010, 37025, 37084, 37237, 37085, 37086, 37091, 37102, 38837, 31335, 37038, 37066, 37071, 37074, 37105, 37090, 37114, 37116, 37123, 35475, 36773, 37132, 146622, 38271, 30055, 35534, 37170, 37156, 36421, 36815, 37563, 22433, 22150, 37144, 37149, 37154, 37157, 37158, 37159, 146623, 37160, 36813, 25243, 36508, 37165, 37215, 37240, 14295, 37180, 36462, 36500, 36511, 145918, 37182, 37185, 37204, 37206, 37207, 128073, 37208, 37210, 37209, 36413, 100253, 37222, 127792, 146577, 37152, 37155, 22024, 37227, 37151, 37231, 36552, 36486, 100254, 36539, 144996, 36455, 36454, 36519, 124173, 36522, 36419, 36468, 37737, 36414, 10890, 36435, 36456, 38029, 36549, 36659, 36530, 36395, 36412, 36364, 36676, 36438, 36959, 36478, 36441, 37376, 36811, 36418, 36327, 36480, 36432, 37218, 37217, 37214, 36484, 38945, 36488, 36457, 36471, 37645, 145663, 36475, 21487, 36453, 36490, 36477, 36472, 36470, 37285, 36545, 36931, 100146, 36937, 36726, 36563, 36557, 36569, 128075, 127520, 37256, 125838, 146673, 36533, 37383, 36582, 36622, 37367, 36636, 100075, 36875, 36880, 36951, 36591, 147331, 36544, 36693, 36709, 15243, 36685, 36607, 124316, 36596, 38061, 36885, 144997, 36876, 36873, 36723, 37228, 36762, 36824, 37002, 36791, 36768, 36741, 36836, 37343, 36798, 38783, 36703, 36728, 36906, 36767, 36997, 13957, 37295, 37316, 37545, 36996, 11364, 37294, 28044, 37297, 144999, 37325, 37298, 37299, 24959, 37375, 38274, 37403, 146502, 37296, 37301, 37335, 38174, 37302, 13747, 37320, 37303, 37364, 37361, 37329, 37304, 37306, 37307, 37309, 100056, 36832, 37348, 37354, 147332, 159698, 37326, 37327, 37328, 37332, 146674, 37357, 147573, 37360, 20480, 37363, 37153, 37344, 37346, 37281, 12000, 18929, 37368, 37369, 37372, 37374, 11880, 37386, 37040, 37377, 37382, 37385, 37381, 37036, 37401, 37963, 37379, 37380, 37384, 135729, 37030, 37027, 36921, 37399, 125401, 37405, 37409, 37411, 37412, 37413, 37414, 37415, 37417, 37418, 37419, 34223, 36957, 38093, 36935, 36713, 100018, 37181, 37430, 37187, 37255, 37300, 37315, 157494, 37362, 36971, 100024, 37437, 100026, 100014, 100009, 36789, 100007, 37366, 37083, 38974, 36445, 147325, 36594, 36770, 38820, 36367, 147464, 100010, 36669, 37259, 36548, 36943, 36589, 36446, 36450, 36417, 37552, 23445, 30590, 36598, 36941, 145177, 37127, 37145, 23577, 36643, 36577, 135109, 37211, 36956, 36547, 36942, 36936, 36518, 36923, 36601, 36958, 36985, 36944, 100085, 37177, 36602, 37175, 37402, 36724, 145539, 37448, 37191, 37205, 36578, 144967, 37196, 37202, 37200, 21021, 37178, 36720, 36732, 36618, 36616, 36529, 36565, 36974, 36715, 36765, 36758, 36680, 36727, 36761, 147376, 37190, 38965, 36769, 36624, 36380, 36590, 36531, 36613, 36540, 36543, 145283, 36611, 36536, 37216, 37221, 147574, 37458, 37459, 36684, 36702, 36681, 37183, 36632, 124522, 36866, 137806, 37008, 21544, 37006, 36891, 36689, 36679, 36711, 38084, 36692, 36561, 36604, 36608, 124643, 36610, 36606, 36916, 36634, 37103, 37864, 36631, 37081, 36714, 145874, 12370, 36716, 37129, 37224, 36745, 37223, 25315, 36874, 36882, 36842, 36854, 36861, 38831, 147465, 145320, 127423, 35908, 37125, 36699, 36736, 100172, 36756, 36725, 36688, 145402, 36961, 36743, 36696, 36800, 36792, 37242, 36650, 37017, 37135, 36911, 37258, 38123, 6059, 37378, 37097, 100042, 37150, 100028, 36964, 36796, 37070, 37126, 100023, 36658, 100025, 37546, 37029, 37121, 37032, 100013, 37305, 37331, 37140, 36785, 37874, 159177, 37351, 37350, 37349, 145120, 100016, 37406, 147326, 37342, 145869, 37194, 37134, 12291, 36748, 5655, 37062, 38127, 147467, 37067, 100017, 36868, 147327, 37063, 100043, 36784, 36863, 127719, 38961, 37261, 145122, 100304, 100041, 100001, 36788, 37060, 37059, 37019, 36783, 36883, 38891, 37267, 37268, 38884, 37254, 37271, 37270, 37269, 37046, 145252, 145988, 37266, 37265, 37264, 37048, 36901, 37263, 37260, 36809, 36963, 36909, 36754, 11873, 147470, 37024, 37547, 37064, 37028, 37111, 37094, 36887, 36914, 36750, 140995, 36780, 37275, 36787, 37068, 37049, 37047, 36860, 36837, 37112, 36751, 37113, 37075, 37039, 37876, 37486, 100038, 100003, 37488, 36525, 36575, 37184, 37186, 100019, 36738, 14211, 36623, 36564, 36537, 37491, 38407, 37455, 36620, 37454, 36812, 145987, 37324, 38858, 36801, 36691, 100015, 145870, 36924, 159701, 125142, 100002, 36690, 36710, 36752, 36774, 37930, 36701, 36886, 37079, 36859, 36808, 100036, 36766, 37054, 36829, 37480, 36597, 36807, 36912, 37050, 37053, 37101, 37699, 146383, 160438, 37479, 37494, 137653, 100021, 100022, 37115, 159702, 36898, 38036, 36828, 36888, 37138, 37483, 37489, 22152, 36277, 37490, 37605, 37515, 37526, 37492, 37493, 138613, 24264, 37407, 11984, 37503, 37408, 37495, 37508, 37592, 37607, 23717, 37496, 37497, 38421, 37498, 145318, 37529, 37541, 37556, 37555, 37504, 37507, 38008, 17672, 158976, 37509, 36402, 36422, 145434, 36196, 26064, 147328, 38045, 38599, 27281, 28438, 147329, 100020, 37589, 21120, 100074, 38967, 37179, 37539, 37542, 37543, 138615, 159497, 23576, 23589, 37548, 37643, 37561, 37549, 37551, 17818, 145871, 158983, 158906, 38013, 100048, 37558, 100130, 100135, 37560, 145919, 37565, 37568, 37575, 37573, 37574, 18319, 37655, 145312, 158971, 37576, 147471, 37578, 37579, 37717, 18620, 37582, 37641, 158977, 158973, 159189, 37583, 37584, 37787, 21143, 37758, 41309, 125079, 37706, 158974, 11820, 100057, 100060, 37718, 37776, 16338, 37724, 37725, 37729, 124428, 37733, 145317, 37734, 37760, 145313, 37778, 37779, 125080, 38433, 159003, 100059, 37780, 37872, 37783, 14171, 37784, 37785, 125081, 138616, 37899, 37786, 37800, 37562, 37723, 42192, 37878, 16365, 26065, 145314, 37914, 147177, 135272, 100087, 100088, 100093, 100108, 100109, 100115, 100122, 100124, 100126, 100131, 100142, 38042, 100165, 145872, 100278, 37948, 16442, 38095, 38056, 37540, 37559, 146723, 37663, 37772, 37484, 37485, 38439, 38057, 37626, 37487, 37777, 100084, 38938, 17421, 37774, 37678, 37649, 17814, 100052, 100050, 100049, 100082, 100103, 100143, 37500, 100071, 100077, 18304, 37501, 145873, 37781, 100086, 100101, 138538, 38072, 38444, 37502, 145964, 37505, 100148, 38073, 100068, 100149, 37499, 40114, 37789, 37722, 159700, 23633, 21582, 14924, 37553, 38074, 100147, 39966, 100137, 100123, 100081, 37727, 100158, 100118, 100073, 138371, 100104, 40071, 100120, 37564, 100105, 5033, 159385, 100062, 100096, 100090, 100054, 100066, 38468, 38587, 138074, 100138, 16646, 11057, 100098, 100061, 145315, 37880, 100100, 100091, 100092, 37703, 100151, 100083, 18073, 100079, 100089, 38871, 100114, 38059, 100132, 145316, 100067, 15528, 37567, 100107, 145574, 37570, 38081, 38090, 100045, 38570, 100055, 100053, 37569, 37571, 38488, 128027, 37566, 12713, 100106, 38179, 37550, 100140, 37923, 138025, 37572, 38060, 100046, 100141, 100116, 37580, 38075, 147178, 37577, 100112, 37715, 160436, 37747, 100136, 100139, 38070, 100070, 100119, 100133, 100063, 100064, 100113, 37687, 37807, 38082, 38088, 38089, 100095, 100117, 100144, 100145, 100121, 100065, 37860, 100099, 100072, 100078, 100111, 38068, 38069, 38076, 38077, 38078, 38085, 38086, 38087, 38600, 38091, 38083, 38094, 37721, 37984, 38099, 38100, 16476, 37636, 37682, 145732, 920, 14478, 10903, 38101, 37887, 37883, 37595, 37627, 1846, 37537, 125146, 37634, 37522, 37620, 37585, 38605, 37890, 37520, 38120, 38166, 147179, 125097, 37161, 37646, 37632, 37527, 37844, 37653, 37672, 38566, 38180, 38171, 38173, 38204, 37681, 11819, 37684, 37525, 38103, 38104, 37790, 38276, 37700, 38108, 38106, 38012, 38129, 38113, 38128, 38116, 38165, 37775, 38114, 38010, 38118, 38119, 37749, 37788, 37730, 38581, 145875, 37863, 38132, 38111, 38133, 38134, 38135, 100094, 37519, 37531, 1103, 38163, 38374, 37528, 145321, 1953, 38686, 37808, 37813, 37535, 37821, 38124, 38125, 38130, 38136, 100102, 37532, 38164, 37534, 37521, 38138, 38139, 30126, 38155, 38215, 33002, 962, 147374, 1315, 38197, 147577, 1913, 4724, 38178, 38167, 25023, 10264, 37481, 100110, 38148, 38151, 38168, 38169, 38170, 38152, 38157, 38158, 147375, 38161, 38211, 38185, 38187, 38189, 38209, 38190, 38203, 38201, 38205, 38206, 38380, 38384, 38391, 35694, 38230, 35252, 38319, 146375, 38316, 11811, 126011, 38346, 25333, 125328, 135715, 15029, 38365, 38370, 38372, 11812, 38491, 38812, 38492, 1894, 38495, 38533, 100256, 38499, 38502, 38602, 38597, 38628, 124331, 38681, 38507, 38862, 38725, 38508, 38511, 37388, 38515, 38513, 38603, 38608, 38516, 38534, 38517, 38518, 38525, 38527, 145322, 38529, 38532, 147829, 100164, 38537, 38571, 40432, 145804, 38540, 38542, 38544, 38548, 38547, 38685, 38552, 38584, 10974, 38781, 38553, 38574, 38560, 38561, 38563, 38593, 38594, 38568, 38932, 38738, 38569, 18026, 37506, 38576, 26308, 40632, 38894, 8000, 38657, 38675, 38680, 38679, 38729, 10576, 125150, 38900, 38709, 38710, 38711, 27182, 38917, 125171, 38872, 158671, 38713, 38712, 146058, 100173, 38724, 38749, 38715, 38931, 38726, 100178, 38731, 38716, 38717, 38718, 146059, 38723, 26069, 146454, 26105, 38933, 14852, 38734, 38735, 38736, 38737, 38739, 38740, 10826, 38752, 145805, 38903, 38307, 147378, 38937, 38912, 38914, 158677, 38744, 38868, 38882, 146060, 38745, 38746, 10889, 38923, 18411, 38754, 38766, 38770, 38885, 38888, 38890, 125180, 38901, 38908, 38910, 38911, 38918, 38920, 38925, 38926, 38160, 38928, 38790, 38930, 38973, 38934, 38935, 147379, 38940, 100255, 100228, 23843, 38941, 22784, 38952, 38956, 38963, 38985, 38817, 38966, 38970, 38972, 38881, 38870, 38977, 100286, 38366, 38922, 38929, 100233, 38936, 38939, 100323, 146682, 38958, 39008, 38500, 100168, 100184, 100170, 100174, 100290, 100258, 100266, 100291, 100264, 100260, 100195, 38287, 26990, 38149, 38864, 38156, 38154, 38198, 146139, 39981, 38186, 38805, 38677, 146683, 38867, 38893, 38162, 38887, 38512, 125153, 988, 38682, 147380, 38776, 38363, 39035, 38431, 100214, 100198, 100280, 100283, 100176, 37104, 37092, 100251, 146198, 37088, 38850, 38869, 38877, 145806, 37110, 38849, 38898, 38844, 38909, 37387, 42720, 39825, 100162, 100205, 100163, 38808, 100160, 38526, 100183, 100169, 100175, 100192, 100166, 100279, 100284, 100226, 100288, 100217, 100216, 100223, 146684, 100224, 38792, 38546, 38902, 28747, 100282, 100308, 100191, 100272, 7166, 100204, 11814, 100238, 38897, 146685, 38497, 147866, 100212, 100225, 100261, 1884, 100208, 100218, 100213, 100222, 38838, 100244, 100252, 100259, 100287, 24088, 100220, 100207, 100231, 100230, 38875, 100232, 100235, 100262, 100248, 100257, 100246, 100202, 100190, 38809, 100200, 100250, 100249, 147632, 39793, 100247, 100275, 100263, 100265, 100274, 100236, 38619, 39016, 100328, 38676, 159706, 100237, 100242, 100241, 100302, 100316, 100243, 23305, 100297, 100298, 38656, 16846, 100306, 100327, 146501, 100219, 38733, 100326, 146686, 39779, 146117, 100314, 100319, 100201, 38635, 100321, 38329, 38873, 159050, 100240, 100203, 38368, 1716, 26369, 1904, 100311, 14762, 100211, 159098, 100221, 100305, 38924, 146458, 100303, 100309, 38811, 100293, 100294, 19115, 100295, 100313, 100312, 100315, 100189, 36580, 100300, 100330, 37089, 38824, 38976, 39017, 38819, 38785, 15750, 9405, 37107, 37109, 38842, 100289, 38919, 38841, 31134, 38748, 36926, 38796, 38806, 100394, 36498, 36523, 38921, 36502, 38848, 36494, 38913, 100125, 38840, 36492, 36506, 36505, 38839, 36501, 36507, 38845, 36495, 153206, 38835, 38846, 36729, 38590, 38892, 40965, 38880, 38803, 39013, 39014, 146503, 38760, 39005, 38895, 38789, 38788, 38859, 38947, 38955, 38957, 38959, 38795, 38975, 39020, 39022, 38836, 39024, 39023, 39025, 39026, 38857, 38786, 39019, 38799, 38821, 38865, 39012, 38851, 10964, 21964, 38801, 38787, 38960, 39027, 39781, 38843, 38828, 38964, 38793, 38889, 38782, 38777, 38980, 146687, 38847, 38815, 38822, 38834, 38853, 125181, 38899, 38962, 38968, 38981, 39011, 39015, 39018, 135374, 39021, 39028, 38949, 39056, 38768, 147576, 147181, 38774, 37533, 7231, 7232, 38092, 100199, 38550, 38194, 38761, 100299, 39007, 38983, 39063, 900, 38771, 38672, 100320, 38762, 38687, 38200, 39004, 38202, 159081, 38555, 39031, 125161, 145965, 38504, 23294, 27124, 12282, 38896, 39751, 29304, 39000, 39002, 100185, 29063, 40013, 144715, 100329, 38213, 100322, 100177, 21356, 38743, 38109, 12382, 125160, 159708, 38159, 24925, 38193, 125169, 24616, 38732, 11818, 100325, 39116, 39121, 100167, 35864, 147475, 38147, 100292, 125162, 100012, 38153, 100161, 39243, 1591, 147476, 39117, 128524, 144752, 14335, 25814, 38759, 3628, 160875, 100181, 100180, 100188, 38767, 28705, 38150, 22818, 146816, 100179, 158534, 21514, 38144, 100281, 23121, 39006, 100182, 41244, 125273, 38769, 100171, 38728, 20843, 38191, 38182, 38184, 147472, 38199, 123981, 40356, 2034, 100310, 38188, 38183, 100206, 38196, 38950, 38763, 28029, 38699, 1626, 125173, 39037, 9165, 125076, 38773, 38208, 147580, 100210, 100197, 2416, 38523, 100196, 147477, 38207, 100227, 38210, 38521, 146010, 38690, 100267, 38564, 125164, 123941, 159712, 38991, 38146, 124402, 100317, 100245, 100276, 39806, 15215, 39001, 100277, 134996, 33280, 125683, 38700, 30770, 39003, 38988, 38982, 39118, 38741, 38730, 38747, 38742, 100324, 38907, 38905, 38876, 39114, 146817, 39115, 39119, 124821, 39120, 39122, 39123, 33605, 147578, 22514, 2161, 100150, 31539, 125178, 28032, 16517, 100229, 100129, 100159, 28015, 34591, 100069, 100051, 23120, 39172, 100127, 147637, 37591, 146410, 37524, 124788, 31200, 159719, 159717, 124787, 145966, 11544, 125176, 125158, 12700, 125157, 17957, 125174, 13936, 125175, 125177, 1029, 124897, 124987, 125139, 125159, 28019, 125100, 125133, 27881, 28033, 27122, 125105, 39334, 26340, 27111, 1002, 28513, 27113, 125023, 38707, 125186, 38810, 159690, 38705, 38706, 960, 124337, 38693, 31911, 965, 19180, 38751, 1907, 38753, 38755, 961, 38695, 38696, 38697, 39429, 100361, 125083, 999, 125035, 1092, 22087, 38756, 38757, 38701, 38758, 38764, 38775, 38692, 125200, 1107, 38698, 38702, 38703, 966, 123986, 38704, 39034, 125156, 963, 125085, 17816, 125084, 39405, 1001, 12353, 947, 125039, 1063, 22027, 125020, 125163, 11206, 124887, 1008, 39531, 146404, 39541, 125056, 125148, 146405, 125194, 146509, 5818, 146608, 125094, 125190, 39513, 125036, 125192, 125191, 39527, 125193, 125202, 39982, 39761, 125015, 39564, 1071, 146774, 146406, 39804, 125044, 125195, 146870, 146499, 125203, 146818, 125045, 125196, 1081, 125197, 125155, 872, 39576, 125019, 125198, 146017, 1010, 146498, 127579, 146819, 125199, 1083, 125151, 125128, 125170, 1087, 125201, 125022, 1089, 39610, 125067, 18146, 125204, 40108, 39651, 39653, 125206, 40430, 125092, 1094, 125025, 125205, 1099, 40944, 125066, 39657, 39662, 125207, 125068, 39673, 125026, 39675, 125208, 39676, 1887, 146737, 39706, 1964, 35056, 39702, 158435, 39693, 125057, 1240, 39683, 125048, 39688, 26734, 100345, 39691, 39715, 39705, 39722, 1824, 39692, 125211, 36962, 100386, 39696, 39697, 39698, 39778, 125212, 146500, 39699, 39700, 39701, 39763, 39707, 1256, 39807, 39787, 39708, 39709, 39710, 39712, 970, 14401, 39713, 39714, 39984, 39723, 39760, 125140, 1097, 39718, 39719, 896, 1196, 39735, 39727, 39720, 39721, 39829, 159099, 125147, 1106, 39725, 39726, 39728, 899, 14377, 39826, 39729, 39731, 39785, 39732, 40264, 125377, 10629, 125143, 39736, 39737, 39738, 39734, 125172, 39740, 929, 39741, 39743, 898, 39746, 20062, 39748, 125058, 39759, 1886, 39744, 39742, 934, 147436, 39786, 39906, 22752, 125144, 22167, 39747, 39758, 39750, 981, 39752, 39753, 159056, 39755, 39756, 888, 126038, 40045, 125145, 39762, 39764, 39765, 39767, 39777, 137969, 1959, 39813, 2022, 125129, 4387, 5584, 39704, 159060, 159723, 39770, 39774, 39792, 100331, 125093, 5630, 39802, 124881, 39773, 39790, 39824, 125138, 39776, 145765, 39775, 39803, 39783, 39818, 125088, 39784, 948, 125154, 145326, 125090, 147653, 39831, 39791, 125113, 39797, 39795, 39799, 39798, 147134, 39800, 897, 125107, 39808, 39809, 39810, 39811, 39805, 40945, 39812, 936, 39814, 125215, 39816, 20953, 39815, 39819, 125086, 39820, 125246, 39821, 100511, 125243, 146820, 39833, 39852, 39621, 39830, 20902, 124233, 885, 39862, 1404, 1583, 39850, 39851, 39937, 39853, 39854, 125227, 39855, 39876, 39856, 125230, 1602, 146821, 39861, 39863, 10812, 39864, 39866, 100483, 125233, 903, 39867, 125228, 931, 125842, 39947, 146822, 39983, 39874, 39930, 39875, 39873, 39894, 100507, 39877, 883, 39882, 39995, 39891, 889, 39893, 124295, 39895, 926, 39898, 39928, 39929, 146902, 39934, 39900, 957, 880, 39917, 39920, 124514, 881, 158841, 39925, 124717, 1066, 39685, 39936, 39932, 27645, 1014, 39940, 39944, 39970, 1098, 23421, 39979, 39948, 146092, 39949, 39950, 1105, 39951, 39953, 1090, 40001, 39969, 16287, 877, 100539, 39956, 39957, 39998, 123901, 39958, 40006, 11050, 41188, 39971, 39996, 39959, 39961, 1101, 159651, 40002, 39962, 41189, 39992, 39963, 39967, 100410, 39968, 39972, 39973, 39975, 39976, 39977, 40125, 39978, 39993, 39974, 39980, 39985, 39986, 39989, 1585, 40011, 31306, 26020, 39987, 39990, 40005, 39994, 39997, 40000, 160873, 40003, 40004, 144759, 40007, 13866, 40008, 40009, 1858, 40010, 40012, 28892, 1864, 31305, 40047, 1873, 31304, 1831, 1830, 40025, 40026, 40029, 147526, 146504, 40028, 40031, 1897, 25510, 40036, 1892, 40038, 40035, 100047, 145808, 158984, 40032, 146505, 40027, 1837, 40033, 100301, 100334, 40024, 1842, 40030, 40049, 40040, 40041, 1844, 40043, 100338, 100408, 40037, 1859, 1711, 1693, 16457, 100209, 1847, 1878, 100239, 1652, 100435, 100436, 100340, 100342, 100351, 100352, 100356, 100375, 100385, 147682, 100389, 100392, 100405, 100421, 11203, 100441, 100445, 100451, 40034, 100462, 100531, 100461, 100518, 100460, 100470, 26969, 100482, 100505, 125381, 40050, 100490, 26680, 100492, 100528, 100530, 26439, 100500, 100501, 17513, 100504, 100512, 100510, 100521, 100520, 100517, 100524, 100527, 100547, 100532, 135283, 100538, 147527, 40048, 40051, 40053, 1821, 40055, 40057, 39687, 39999, 39711, 40059, 39686, 40060, 1881, 100357, 100355, 100529, 100551, 36228, 100344, 39689, 39694, 39681, 100353, 100350, 100369, 146823, 100368, 40127, 158985, 39682, 1956, 100335, 145374, 100343, 29243, 100346, 100341, 7906, 16668, 100332, 100337, 100348, 100453, 100458, 100446, 100448, 125281, 145463, 100450, 39832, 100360, 9003, 40078, 40081, 100455, 39398, 100526, 100427, 36211, 40066, 7783, 40068, 7542, 40069, 39757, 13944, 40070, 39745, 100522, 7579, 40074, 18609, 34181, 100358, 100391, 40083, 100432, 160441, 100366, 40084, 100371, 40101, 100374, 100523, 39749, 40085, 100363, 1845, 100370, 100372, 100373, 40086, 10973, 1853, 100449, 35502, 100443, 160440, 100548, 147528, 40109, 100382, 100546, 100509, 18820, 100525, 100419, 100540, 100519, 160480, 100502, 100514, 100516, 100396, 100513, 146578, 100420, 100429, 100542, 100388, 100378, 100377, 100494, 10905, 146506, 100387, 100384, 100376, 100393, 13642, 100402, 160442, 39724, 148281, 100398, 1819, 100400, 100397, 100413, 100457, 100452, 100401, 100395, 100407, 100403, 100412, 100411, 100379, 40102, 15292, 100380, 1916, 14568, 100454, 23138, 100438, 100485, 100484, 100428, 100416, 100415, 100418, 100434, 100440, 146824, 100406, 100444, 100459, 100456, 29213, 39780, 100472, 39336, 100473, 27115, 100480, 100479, 146825, 39991, 7653, 26341, 31640, 146508, 39912, 7690, 100478, 100498, 20523, 40948, 100496, 100488, 100469, 100471, 100481, 39198, 146867, 28251, 100475, 100477, 100497, 100474, 40054, 2030, 100467, 40097, 100486, 100491, 100425, 100508, 11243, 14522, 27152, 40080, 35002, 100537, 2033, 100489, 27538, 100493, 100503, 100499, 100550, 42161, 39857, 39858, 15228, 40111, 39587, 40113, 39836, 146868, 39611, 39927, 160516, 29645, 16063, 39921, 40099, 29141, 40100, 39841, 39671, 39801, 39868, 29314, 40103, 40106, 40107, 39911, 40110, 29307, 39730, 39544, 39845, 159276, 125132, 18622, 39914, 100187, 40115, 40119, 100285, 40120, 40121, 40122, 40123, 40124, 39941, 1910, 30851, 100506, 1895, 40092, 39789, 146579, 40158, 39922, 126050, 39954, 39837, 39828, 40140, 39939, 40136, 40137, 39938, 40022, 34193, 39952, 146869, 40067, 39965, 146580, 40163, 40166, 40073, 2139, 20244, 39964, 158996, 25273, 16626, 40075, 40079, 30391, 39823, 15744, 20831, 39827, 100543, 7594, 146170, 2421, 160439, 17692, 39924, 39834, 39943, 39847, 30181, 18363, 39849, 39848, 40161, 18694, 39859, 40142, 40143, 146581, 39840, 29957, 14872, 40150, 2145, 40199, 20762, 1820, 18855, 125120, 2020, 145509, 125104, 15272, 40241, 40056, 40064, 40065, 125437, 22594, 11305, 39059, 125117, 125098, 100390, 23745, 100383, 40270, 9266, 1936, 39754, 40148, 147654, 39716, 39680, 39679, 39494, 40269, 21560, 100404, 39493, 40251, 39860, 100468, 100439, 40261, 124974, 124556, 100464, 100465, 40146, 40265, 100463, 100476, 39768, 100430, 19792, 100381, 39923, 23976, 40266, 40267, 23795, 127952, 100423, 100534, 40259, 146826, 100533, 8007, 40252, 40253, 158986, 40263, 1832, 39788, 100417, 40898, 100442, 40256, 39822, 100549, 27021, 40257, 8715, 40258, 40262, 125121, 40271, 40272, 40273, 40276, 145609, 40997, 126291, 42167, 7583, 39532, 40280, 40279, 40287, 40288, 1656, 40289, 40290, 40291, 40292, 22256, 1918, 7736, 40254, 40260, 19403, 2146, 40268, 40274, 40147, 1898, 40275, 25455, 40277, 40278, 1816, 40284, 100339, 25634, 147655, 40286, 39678, 41293, 39794, 158987, 39796, 15553, 40144, 40145, 8071, 39988, 40159, 100399, 2077, 7769, 40964, 40317, 40285, 40354, 145546, 25081, 40370, 138184, 40374, 40377, 147656, 1407, 1783, 159250, 2483, 22447, 1520, 1789, 1835, 40282, 38541, 38556, 1444, 8559, 8855, 1866, 1788, 1790, 1794, 1795, 146827, 1857, 1908, 1917, 1938, 1945, 16326, 1877, 2121, 2197, 1976, 1970, 1587, 1610, 1861, 124570, 125289, 1946, 1972, 2142, 42042, 1935, 124874, 1957, 124883, 2000, 2032, 1929, 1891, 33696, 2001, 146828, 124886, 1896, 1901, 1940, 1955, 3846, 1967, 10918, 2006, 2042, 2067, 2319, 42135, 1915, 2167, 147363, 125304, 2616, 2240, 1981, 2249, 2317, 1992, 143462, 2049, 2185, 1939, 1948, 2078, 2025, 2420, 40752, 1971, 2005, 2012, 2014, 2016, 3189, 2004, 2007, 2008, 2011, 2013, 2015, 2017, 2018, 2023, 16309, 2026, 2071, 147135, 2082, 2050, 14261, 36214, 2062, 125329, 2070, 2112, 2849, 124257, 125040, 2052, 2064, 2068, 1982, 2624, 1977, 1889, 1899, 2098, 1579, 35444, 2101, 35075, 1978, 2632, 1665, 1686, 124906, 14503, 22255, 1849, 1961, 2069, 16511, 124801, 2106, 2210, 125312, 124655, 2682, 125152, 40105, 147702, 124369, 11409, 2583, 123984, 1937, 2368, 124709, 125141, 125054, 124489, 125330, 2059, 36126, 123985, 34528, 35197, 35141, 124783, 3077, 125324, 125325, 2905, 2696, 2683, 22295, 22312, 24590, 124716, 18921, 125484, 34547, 35504, 35506, 35004, 36242, 124125, 36233, 17859, 35571, 35318, 35877, 35931, 36111, 35439, 36204, 14923, 146829, 6406, 14891, 40497, 18283, 149000, 124260, 146171, 40585, 40597, 146173, 146172, 40641, 40647, 124289, 40570, 40659, 16368, 40837, 40516, 3333, 17809, 40721, 40725, 146583, 42023, 145167, 40739, 124814, 40774, 2021, 40803, 41128, 40836, 10644, 123987, 125647, 42017, 40821, 40823, 40825, 40833, 42051, 40840, 40842, 40843, 40844, 40861, 147703, 40847, 11429, 40848, 41201, 139230, 40849, 40869, 25187, 40850, 40851, 40852, 40881, 40860, 124461, 40853, 124501, 40854, 40856, 40864, 40865, 145450, 40858, 40859, 40877, 40862, 146585, 40938, 40947, 40863, 40866, 40868, 40867, 40870, 40871, 40873, 40874, 15227, 40941, 40883, 40884, 40886, 40887, 41245, 40893, 40894, 40895, 40888, 22620, 40909, 40899, 40901, 40896, 40917, 40918, 40919, 40915, 146903, 40916, 40946, 40939, 40950, 40951, 158438, 40902, 40905, 40906, 40994, 40907, 40967, 40908, 40936, 40910, 40911, 146584, 41094, 40920, 40913, 40922, 41067, 40619, 40931, 41011, 40924, 40937, 12131, 40925, 40940, 40943, 40926, 40927, 41191, 40930, 146586, 146883, 40932, 40933, 40934, 41206, 40935, 141070, 40953, 40879, 40955, 41231, 40969, 40956, 40957, 41190, 16554, 16694, 40958, 41096, 40876, 40960, 40962, 40963, 21497, 40966, 40991, 41137, 40558, 41203, 40923, 40972, 40942, 40975, 40976, 146587, 146884, 964, 40983, 40990, 41061, 22313, 41070, 40999, 40996, 41002, 41003, 41007, 41009, 41010, 41020, 41021, 41058, 41232, 22088, 41069, 40600, 42080, 41024, 41025, 41030, 41032, 38765, 34005, 41036, 41037, 41038, 124632, 41040, 41172, 41041, 41042, 41039, 41043, 41044, 146885, 41046, 41047, 41049, 41053, 41055, 41063, 41068, 146904, 145967, 16864, 41081, 41083, 41079, 41088, 41170, 41097, 17793, 41098, 41066, 160447, 41106, 41087, 41240, 26765, 146588, 41365, 146886, 41073, 40904, 41229, 41183, 41185, 41207, 41299, 124645, 17087, 41093, 41186, 40775, 146959, 41078, 40912, 40437, 40914, 41177, 41178, 41179, 41292, 145304, 13691, 40971, 41290, 41208, 41209, 146589, 40949, 41193, 41196, 41241, 41197, 41198, 41200, 128573, 139007, 41199, 41202, 41205, 17962, 41235, 41237, 41238, 41236, 41291, 41211, 41213, 41214, 41217, 41218, 41220, 41221, 41222, 41223, 41227, 41230, 41295, 41239, 41250, 41251, 41252, 41255, 41253, 41256, 41257, 41258, 41259, 41306, 41288, 41266, 25280, 41273, 123939, 41274, 41275, 41277, 41278, 41280, 41283, 41284, 41285, 41287, 145968, 41289, 146942, 11003, 40579, 41294, 41296, 146960, 41297, 41301, 41302, 41303, 41304, 41307, 41308, 41310, 41311, 41312, 41313, 40638, 147090, 145751, 41314, 40614, 40508, 41315, 41317, 41318, 41320, 41321, 41322, 41323, 41324, 139133, 41325, 42134, 41212, 40622, 41326, 41328, 41327, 41330, 41331, 41332, 41335, 41279, 41356, 42027, 40841, 147049, 41262, 40846, 40885, 40839, 41333, 18536, 40845, 40892, 42060, 40891, 42022, 125390, 160549, 41366, 40318, 40755, 40857, 40968, 41105, 15820, 42085, 41338, 158637, 40970, 41103, 41090, 40463, 41243, 10779, 22810, 40503, 40438, 40612, 41370, 41084, 41204, 40433, 40753, 40835, 42021, 123903, 42039, 20564, 40496, 146961, 40505, 40483, 41102, 40392, 40504, 40635, 40636, 40506, 40465, 40610, 40756, 41091, 40830, 40616, 41340, 40445, 40633, 40630, 40535, 40482, 124129, 42036, 42030, 40554, 42046, 42177, 42055, 42024, 42025, 42128, 42026, 42041, 42029, 42018, 125649, 42040, 42147, 42031, 42170, 42173, 42037, 42038, 159524, 159735, 42081, 42137, 42087, 40601, 123904, 42057, 42174, 42052, 21506, 42054, 42077, 42136, 125440, 42072, 42138, 42152, 40770, 42059, 12595, 42013, 22182, 17486, 42056, 42158, 42178, 42139, 123957, 123905, 42140, 42014, 18237, 42179, 42028, 42058, 42143, 18006, 42175, 42126, 42045, 160531, 125468, 147000, 42086, 42155, 40642, 40750, 42125, 42171, 42131, 42180, 7381, 42144, 41101, 42181, 42132, 42133, 42164, 42169, 42159, 20305, 146941, 42071, 30330, 41089, 16468, 42150, 42043, 41095, 40628, 42142, 42145, 42073, 147002, 25288, 42044, 42067, 29105, 40767, 42182, 42160, 42090, 42165, 40534, 42075, 40637, 42074, 146335, 42130, 42183, 42015, 42032, 42089, 42047, 42048, 126294, 124212, 40779, 40772, 123899, 42062, 40977, 42068, 42069, 42049, 42034, 42129, 40590, 42033, 41184, 25051, 40974, 42149, 42016, 42168, 41264, 41216, 39905, 40757, 123898, 41387, 42035, 123982, 42064, 42050, 123823, 41008, 17861, 123826, 123824, 123825, 123828, 123830, 123840, 41334, 124237, 160515, 18250, 41107, 41100, 123936, 41192, 41350, 30416, 41300, 7604, 145749, 41050, 146274, 21989, 40993, 40995, 40998, 41001, 25145, 123979, 41004, 41017, 41045, 41005, 41006, 146337, 19786, 21913, 41052, 41012, 41013, 41182, 41014, 41015, 41054, 25270, 25426, 41018, 41019, 41022, 41023, 146336, 41026, 41027, 41057, 123958, 123959, 41028, 41092, 41029, 41076, 41077, 123942, 41031, 41033, 41034, 123960, 41075, 135789, 123812, 123813, 41048, 42084, 123815, 41225, 41248, 41276, 41051, 40510, 17739, 123818, 123820, 123821, 40607, 29673, 123822, 123829, 123835, 123834, 21825, 41060, 123961, 40599, 1573, 41064, 29560, 123857, 39902, 30082, 41357, 123962, 123964, 123859, 29239, 42148, 137818, 26577, 40594, 124496, 123875, 123817, 41116, 41035, 30469, 123966, 40992, 41065, 2003, 124499, 27240, 135665, 18368, 123877, 41000, 123819, 41056, 123907, 124123, 40042, 24390, 26588, 145610, 124194, 40921, 28629, 125589, 41353, 26447, 147133, 123940, 123900, 123980, 40954, 123908, 124548, 42154, 21771, 42172, 41384, 41385, 1483, 27522, 123917, 42070, 24983, 123965, 21779, 42123, 123923, 123924, 41219, 42053, 123975, 123836, 145959, 42083, 42012, 124473, 42082, 42079, 24709, 124571, 42019, 124134, 42020, 25193, 25332, 124165, 21787, 21795, 42163, 39904, 145615, 2056, 3200, 123841, 41355, 40984, 123967, 123968, 4584, 25029, 124485, 124560, 42157, 42124, 42162, 42146, 145611, 123918, 42127, 27228, 124182, 123919, 123920, 7393, 7395, 7614, 7746, 7798, 9038, 9357, 9771, 146637, 25181, 25047, 25336, 2086, 123932, 123933, 38079, 123949, 15571, 7696, 7572, 41180, 123938, 123976, 16619, 25220, 16629, 124572, 39739, 25013, 40929, 123948, 145752, 27434, 24974, 123950, 25219, 123952, 25027, 123953, 27641, 30124, 25057, 30315, 25097, 25142, 25278, 123983, 26429, 123977, 26656, 25306, 135015, 2116, 2075, 124128, 124130, 124264, 25031, 25348, 123969, 123970, 123971, 123972, 123973, 123974, 27624, 28118, 123989, 123990, 28595, 123994, 124096, 30409, 124166, 1075, 2065, 1986, 874, 124108, 878, 1363, 1616, 1403, 1944, 1954, 2066, 147704, 2019, 124802, 145612, 1974, 2057, 146174, 124573, 1987, 2501, 123997, 123999, 40126, 42141, 124084, 124112, 124115, 124126, 124243, 124021, 124042, 124061, 124065, 124066, 124070, 124075, 42066, 124098, 124127, 10982, 124170, 124169, 124772, 42076, 124082, 124141, 124574, 42078, 124085, 124086, 124087, 124089, 124090, 124094, 124105, 146015, 124392, 124323, 124325, 124189, 124551, 135669, 21929, 35677, 124143, 124144, 124145, 124147, 124238, 124217, 42153, 124504, 124164, 124187, 32056, 124195, 124219, 124213, 124291, 15983, 124229, 124225, 124290, 124296, 124389, 124234, 135663, 124349, 124236, 17815, 124244, 124240, 124245, 14977, 124251, 124267, 124262, 146591, 124379, 124297, 124298, 124324, 124318, 124322, 124287, 16608, 124544, 124266, 124269, 124224, 15009, 124274, 124353, 124273, 124276, 124334, 41016, 124285, 124286, 124292, 124857, 124288, 124326, 124333, 124329, 124328, 16158, 124355, 124332, 124500, 124335, 124338, 124339, 124345, 2939, 124350, 2802, 124399, 145892, 124351, 124354, 124491, 124373, 124395, 124394, 124387, 145614, 124478, 124393, 124396, 2966, 124929, 124513, 124398, 135684, 23548, 124401, 145849, 124497, 124498, 124494, 41194, 124417, 124419, 124420, 124421, 124422, 124423, 124463, 23319, 124468, 124465, 124425, 146984, 13433, 124484, 124561, 124490, 124486, 124549, 124482, 145850, 124424, 124430, 124433, 145375, 124450, 124452, 124469, 124471, 17089, 124480, 20957, 124505, 124507, 124509, 124531, 124511, 124512, 124510, 124550, 124638, 124515, 124525, 124527, 124526, 124784, 124516, 23410, 124542, 124543, 124547, 124895, 124545, 124546, 124552, 124553, 124554, 30674, 13395, 124789, 124530, 124528, 124541, 124533, 124695, 124535, 124536, 124537, 124538, 124539, 124540, 124555, 124557, 124558, 124559, 146701, 17090, 17091, 124774, 14789, 17813, 23419, 124636, 124747, 124580, 124637, 124639, 124640, 124641, 158640, 124562, 124564, 41181, 124654, 124644, 16607, 18868, 125439, 124565, 124566, 124567, 124569, 146857, 124584, 124578, 19803, 124581, 124582, 124583, 124626, 124585, 124659, 124670, 124586, 124587, 124588, 124589, 124622, 124830, 124685, 124623, 124624, 124625, 145616, 124648, 124669, 31973, 124662, 125393, 124627, 23372, 124629, 124630, 159408, 37212, 124676, 124631, 31655, 124773, 124633, 124634, 124635, 124642, 23371, 124646, 21668, 124663, 10981, 124689, 124688, 38992, 124649, 124691, 124791, 159740, 124652, 32870, 124674, 124657, 32872, 124660, 124656, 124686, 124696, 124690, 124692, 124694, 124790, 126124, 124661, 124668, 124858, 124664, 124678, 124665, 124796, 124666, 124671, 124683, 124682, 124684, 146702, 124667, 2273, 124673, 26342, 124699, 124677, 124679, 124681, 124680, 23316, 124697, 124698, 124701, 26346, 2307, 26334, 27110, 28020, 124705, 38996, 124703, 124704, 124718, 38995, 124706, 125431, 124940, 124708, 124707, 124710, 2648, 124711, 30081, 124712, 124770, 124744, 142270, 29527, 124715, 124756, 124757, 124721, 147705, 124777, 2775, 124722, 124723, 124746, 124724, 159100, 124726, 41263, 124727, 124792, 123854, 124728, 124908, 124795, 124749, 124939, 159104, 124732, 124776, 124782, 124778, 124779, 147792, 124730, 124740, 124759, 124760, 124763, 124771, 124725, 124800, 124780, 124781, 124753, 124751, 124754, 124893, 124765, 124766, 124767, 124293, 124768, 124769, 124794, 124808, 124914, 124775, 124793, 124797, 124798, 124799, 124804, 124805, 159105, 126342, 124806, 124807, 124812, 124809, 124920, 124813, 39945, 124840, 124844, 124880, 124984, 124901, 24434, 11546, 25757, 124855, 23026, 124859, 124892, 124860, 124864, 124869, 24927, 124878, 124877, 124879, 124962, 23208, 124885, 22764, 124882, 146704, 124888, 124894, 124971, 124384, 124896, 124899, 124900, 21057, 124967, 124902, 124903, 124904, 124913, 124955, 124957, 124956, 124506, 124958, 125006, 159061, 124985, 124966, 124963, 124965, 124977, 124970, 124969, 124979, 124982, 124983, 124980, 124868, 147793, 124991, 124990, 124992, 124998, 26344, 124978, 125009, 12056, 124575, 146052, 124577, 124981, 145361, 125029, 24921, 124628, 124004, 12793, 125623, 124729, 124650, 124658, 124936, 126162, 125003, 146939, 124875, 125010, 147863, 5268, 125004, 10992, 124064, 124810, 124077, 124935, 124063, 23405, 124752, 124073, 15314, 146713, 125371, 2847, 124687, 124693, 124761, 124762, 124755, 12375, 145618, 18710, 10888, 145403, 11542, 17605, 159002, 125007, 125434, 125008, 125011, 125012, 125013, 124563, 10985, 10991, 18033, 125017, 147120, 24987, 14435, 125038, 125042, 125024, 124884, 125021, 125031, 125030, 125027, 124889, 125032, 125033, 125034, 11167, 125037, 146338, 125379, 124891, 124890, 11014, 124845, 124867, 125391, 125043, 124873, 24919, 124944, 124870, 125046, 3215, 28997, 125047, 124854, 11619, 2924, 125061, 124853, 3323, 124851, 124849, 124951, 4145, 125555, 125469, 125394, 125374, 15279, 125049, 125055, 5270, 125059, 125060, 125063, 3228, 3840, 125376, 146940, 3508, 3445, 125352, 4054, 125436, 4175, 146277, 3929, 3042, 125064, 125337, 125339, 2747, 159085, 2808, 2981, 3007, 3147, 3203, 3204, 148135, 3789, 125357, 125358, 125359, 125372, 125373, 18658, 145624, 159084, 3386, 4369, 145620, 14518, 4865, 125382, 145327, 125380, 125384, 146463, 125417, 12455, 5008, 125360, 125362, 125363, 125365, 125368, 25920, 125366, 125445, 146466, 147937, 24263, 25799, 125369, 125370, 125378, 125402, 125403, 125406, 125420, 125545, 125423, 127123, 125424, 9207, 30796, 125425, 125426, 125428, 125407, 125418, 125408, 125405, 125438, 7738, 25675, 10891, 125409, 11489, 125410, 125411, 125416, 125413, 125414, 125429, 125430, 125442, 8621, 125544, 125546, 125556, 4702, 5456, 125669, 125433, 125446, 125448, 4708, 147003, 125456, 144799, 125450, 125452, 125453, 25026, 16337, 15273, 125454, 24823, 8645, 4786, 147005, 125455, 5278, 125457, 7963, 125460, 125461, 125462, 125463, 125464, 125465, 125475, 19523, 4948, 125487, 5220, 125471, 125472, 125474, 125552, 125553, 22129, 21101, 125476, 28490, 125481, 5267, 3492, 5436, 125488, 125490, 125492, 125493, 127186, 125485, 125486, 125473, 7011, 6538, 6987, 7226, 26219, 7582, 9645, 125548, 9603, 125549, 24132, 24133, 125554, 24492, 24493, 24826, 24945, 125419, 24989, 24985, 125421, 125422, 25058, 125427, 125630, 25313, 125608, 125432, 125435, 125441, 24792, 125443, 25002, 24825, 125444, 24932, 14516, 24982, 37581, 125482, 25319, 125489, 14560, 125491, 125559, 25238, 125558, 35633, 125564, 125563, 125565, 125567, 15609, 24895, 24946, 24979, 24933, 24992, 25015, 26123, 147123, 25062, 25063, 24666, 25281, 125609, 25022, 24665, 24670, 24672, 24929, 25017, 25021, 145625, 24915, 25173, 25030, 25127, 25033, 25039, 25168, 25056, 25011, 25048, 25248, 25249, 25028, 25044, 15012, 25225, 25174, 125652, 146520, 25061, 25183, 25184, 25169, 147951, 25186, 25204, 25252, 125572, 25191, 25203, 25255, 25258, 25262, 145050, 125644, 25218, 25292, 125574, 25295, 25301, 25299, 25032, 25053, 25055, 25050, 25304, 125575, 125576, 125579, 125580, 25267, 125581, 145580, 25109, 125604, 125593, 125605, 125607, 13043, 30618, 25110, 25112, 125582, 125583, 125585, 125586, 125596, 125597, 125592, 125599, 25223, 125600, 125602, 125603, 125606, 125610, 125611, 125612, 125615, 125613, 125616, 125617, 125618, 125619, 4731, 125622, 125466, 125632, 125633, 125634, 25180, 147952, 125635, 125636, 125637, 125638, 125639, 125640, 125641, 125643, 25131, 125645, 125646, 18017, 25240, 25138, 25148, 25150, 25323, 25326, 25152, 25178, 25195, 25207, 25208, 25209, 25211, 25215, 25312, 25259, 25261, 25182, 25188, 25190, 25210, 125653, 25214, 125654, 25221, 25441, 25222, 25231, 25241, 25318, 125655, 25246, 25244, 25245, 25266, 25272, 25294, 25296, 25297, 25090, 25103, 25105, 25205, 25317, 25107, 25108, 25117, 145628, 25120, 25124, 125656, 25136, 140962, 25137, 25320, 25146, 25159, 25160, 25189, 25347, 125657, 25153, 25303, 145629, 4495, 10995, 25155, 25163, 25327, 25158, 125659, 25176, 125660, 25185, 125661, 125662, 125664, 11684, 125666, 125668, 125658, 25198, 25200, 25331, 25339, 22296, 25370, 25365, 25308, 25345, 25805, 25431, 25314, 146897, 25442, 25516, 25341, 25354, 25344, 25351, 25394, 25403, 25408, 25439, 25734, 25518, 25783, 25406, 125676, 11241, 15436, 125675, 146278, 125716, 25791, 125677, 125723, 25879, 25829, 24984, 125684, 125689, 125699, 125698, 34309, 125702, 125705, 125708, 7012, 125709, 125712, 125715, 125741, 146521, 125697, 125722, 23680, 125724, 22970, 125737, 125726, 26043, 125749, 23640, 23646, 23644, 23622, 23719, 23651, 22568, 23453, 26210, 125764, 146522, 26106, 125728, 125729, 32967, 125740, 11041, 125743, 23657, 23656, 23664, 23658, 125751, 125752, 125760, 23672, 4047, 125763, 125787, 23671, 23726, 23669, 23676, 23677, 125836, 125837, 16530, 125878, 125840, 125887, 125888, 125894, 125932, 125927, 23455, 23662, 16483, 23597, 23473, 145631, 146612, 23544, 23565, 23553, 23558, 23594, 23567, 23670, 23570, 23620, 23451, 23683, 28190, 23557, 146638, 125955, 23552, 23632, 23554, 23471, 16650, 23472, 23443, 23444, 23441, 144968, 23474, 23725, 23431, 23440, 10994, 23517, 23448, 23691, 23467, 23427, 17140, 23452, 23450, 23456, 23614, 22228, 23459, 23462, 23437, 23442, 23461, 126201, 23530, 23340, 145632, 145633, 125954, 15349, 23435, 23430, 23439, 23369, 23512, 23267, 16685, 23506, 23601, 23538, 147533, 145634, 26169, 26224, 23555, 23334, 23493, 23495, 23497, 23498, 23617, 23503, 23504, 23375, 23333, 23320, 23596, 23328, 23329, 145378, 125928, 26126, 23348, 26122, 26183, 144970, 125936, 147136, 23339, 23612, 23479, 23487, 125934, 26177, 26135, 26124, 26154, 26175, 23324, 23343, 23344, 23349, 23345, 23350, 23351, 23550, 23352, 23056, 23332, 145380, 26228, 26222, 26270, 125952, 26225, 26230, 23335, 23482, 23696, 23698, 15873, 23157, 23411, 125937, 125947, 125949, 125960, 23480, 125957, 23611, 23356, 23357, 23397, 4162, 4322, 26370, 26300, 125939, 26410, 26748, 26763, 125961, 26831, 27032, 125941, 145636, 146317, 23383, 23390, 23386, 23391, 23628, 23289, 23363, 23382, 23385, 23387, 23268, 23401, 23378, 23326, 23489, 144969, 23423, 23367, 23403, 23510, 23070, 146523, 23376, 23396, 23398, 23402, 23400, 23416, 4496, 9545, 23618, 23422, 23610, 23300, 23323, 23714, 23038, 23273, 23374, 23276, 23418, 23278, 23277, 23279, 23282, 23296, 23303, 23299, 23271, 23283, 23288, 23290, 23285, 23292, 23311, 23312, 23313, 23314, 23054, 23317, 23315, 23606, 19556, 145635, 22302, 18157, 23014, 23015, 23020, 23021, 146983, 23280, 23022, 23258, 23712, 22998, 23041, 23257, 147981, 23262, 23032, 23068, 22334, 23198, 23103, 23100, 23082, 23097, 23162, 23172, 23174, 23204, 23246, 23065, 21425, 23141, 23237, 125968, 11043, 127033, 23096, 23062, 23216, 23217, 23241, 22807, 23231, 23233, 23242, 23245, 23247, 20322, 23144, 23143, 125969, 125976, 125973, 125981, 23030, 19813, 23227, 23223, 13369, 145637, 125993, 145639, 146524, 125992, 23043, 23225, 23226, 23228, 23232, 23085, 22830, 6698, 23142, 23139, 23191, 125985, 145638, 23150, 23243, 23151, 23219, 23031, 125989, 23012, 23135, 23239, 23124, 13396, 23050, 23087, 23091, 20579, 23108, 23094, 23093, 23083, 23099, 125988, 146221, 23010, 15965, 125991, 147062, 23086, 23088, 23089, 23112, 146272, 23116, 23117, 23163, 23251, 23250, 22851, 125995, 125997, 126020, 125998, 23189, 126010, 145641, 23111, 22914, 23158, 23128, 23132, 23183, 126096, 125999, 23192, 146268, 148243, 23187, 126000, 23179, 126002, 23071, 144973, 126003, 27581, 18299, 126298, 23161, 23170, 23169, 23173, 23176, 15214, 23178, 23182, 23193, 126005, 146269, 27442, 27562, 126006, 126007, 126008, 126021, 23004, 126009, 23190, 12803, 23159, 22900, 23027, 126012, 11781, 126014, 126015, 126016, 126017, 126018, 126019, 126024, 126025, 126051, 126052, 126053, 128071, 18238, 126049, 137650, 126341, 126290, 126027, 126033, 126034, 126287, 126036, 126045, 126047, 126048, 126044, 20409, 28105, 27818, 126099, 27999, 148244, 148245, 148246, 28472, 28375, 126275, 28615, 146370, 28508, 18201, 28509, 126054, 13888, 127055, 126056, 126057, 28014, 126101, 146270, 126249, 138017, 126156, 127020, 126068, 126071, 126072, 126083, 126084, 126139, 126086, 126085, 126091, 126095, 40989, 146271, 11962, 145643, 5541, 126106, 126107, 147063, 126108, 127015, 145989, 126110, 126111, 126121, 126122, 125557, 126274, 126220, 126132, 31609, 126125, 126127, 126268, 126129, 126138, 126194, 13364, 126130, 126234, 126270, 126245, 126153, 127813, 126131, 126133, 126266, 126148, 126134, 126271, 126114, 28367, 29297, 29298, 159004, 126135, 126136, 126237, 126149, 126150, 126151, 126140, 28016, 126219, 126143, 126144, 126145, 126146, 126147, 126154, 126155, 126221, 13295, 126260, 159109, 126227, 19898, 126157, 39844, 39843, 126188, 29899, 30672, 159118, 141694, 126163, 126165, 126174, 126231, 127192, 127081, 126175, 127025, 30922, 126224, 126226, 126225, 126250, 126253, 126259, 126277, 127113, 127205, 127185, 126279, 126278, 145642, 126280, 126281, 17812, 159114, 126283, 126284, 126285, 147115, 126288, 127027, 126289, 126293, 126329, 126330, 126336, 134950, 127004, 127138, 159116, 159110, 30051, 147007, 125459, 126308, 127009, 146229, 100318, 126314, 126317, 126320, 126322, 126323, 126321, 126328, 127013, 127179, 126337, 127103, 126339, 138081, 127088, 126340, 17985, 126347, 126351, 126353, 127031, 127018, 126299, 127073, 145644, 127233, 15753, 127139, 127143, 12096, 127110, 145941, 127086, 18806, 127182, 127068, 127080, 127202, 127021, 127038, 127107, 16021, 127187, 127023, 127108, 127022, 127083, 127190, 127024, 127948, 127026, 127152, 127161, 126120, 127147, 42270, 127101, 134977, 8869, 127037, 127151, 127098, 127041, 127129, 127234, 127044, 127166, 127208, 15065, 127206, 127047, 126297, 125361, 127104, 127221, 127224, 127210, 127232, 135084, 127236, 125621, 126211, 10838, 127239, 126264, 126123, 126230, 142163, 125759, 125601, 147116, 127242, 125540, 126001, 126004, 127249, 126257, 11570, 126205, 11034, 127250, 126303, 126209, 126255, 135092, 126235, 126296, 126325, 125994, 125990, 127252, 125986, 125987, 126197, 7451, 9416, 9364, 18194, 24524, 26080, 127482, 126040, 146698, 127253, 126200, 147118, 125825, 126207, 13494, 146640, 11046, 127245, 127256, 127240, 18541, 126248, 126187, 126335, 20675, 126039, 145647, 25216, 146779, 127246, 126306, 127241, 126037, 128552, 125733, 126300, 126307, 125935, 126041, 145645, 127533, 126292, 125745, 125449, 126327, 126118, 125958, 125979, 126172, 127244, 145462, 126295, 125447, 126276, 125629, 125395, 127251, 125970, 125765, 126141, 126309, 127553, 125924, 125883, 42237, 125761, 126310, 146582, 125386, 126331, 127140, 126311, 126326, 126198, 125667, 12070, 126212, 125628, 147121, 125786, 126238, 145646, 126218, 147151, 146785, 125598, 127229, 126332, 125514, 127247, 126352, 126349, 126343, 126333, 127355, 127010, 145648, 125343, 126112, 126158, 125620, 127141, 125642, 125499, 126217, 126246, 17203, 17399, 17755, 135232, 127072, 127106, 125594, 17542, 127071, 127070, 125707, 125500, 127075, 127084, 127169, 127076, 127538, 125518, 127052, 18510, 125529, 127003, 127176, 127178, 125982, 125975, 158627, 158847, 127175, 127184, 127006, 145464, 127177, 127173, 127014, 127005, 126183, 127007, 127012, 127011, 127002, 146786, 127164, 126232, 125519, 125524, 127171, 127163, 127165, 127137, 127121, 145654, 127078, 127376, 127077, 127198, 127136, 127135, 125528, 127060, 158975, 22870, 127134, 127094, 125879, 127170, 12765, 127050, 127067, 125513, 126348, 127066, 127069, 126243, 127016, 127357, 126090, 18422, 127181, 125470, 127180, 127183, 145650, 127481, 145946, 125533, 127115, 125944, 127120, 127017, 127019, 146787, 127142, 127082, 127130, 145857, 127128, 146668, 134951, 144928, 144934, 127131, 159036, 127133, 127059, 127085, 127087, 125700, 127049, 11834, 127111, 127191, 127112, 145903, 127750, 126318, 16494, 126319, 5668, 127195, 127172, 127194, 127153, 127188, 127189, 17225, 125527, 127193, 127145, 127211, 127196, 127174, 16223, 127197, 127028, 144567, 127144, 127154, 10980, 17442, 126215, 125893, 127156, 127218, 127124, 126265, 42470, 42352, 127132, 127061, 127062, 127063, 127030, 125718, 127064, 159049, 145542, 127079, 127095, 127091, 125736, 127089, 127093, 127036, 17143, 146641, 16666, 126316, 125509, 11374, 125331, 125756, 127092, 126315, 128121, 145540, 126258, 127090, 126282, 127207, 126216, 148284, 126222, 15229, 127200, 127225, 126254, 159129, 23513, 10976, 125483, 126252, 126032, 127203, 125754, 127199, 126251, 127201, 126256, 126240, 10988, 127155, 125479, 23665, 159132, 127040, 126267, 126247, 126273, 127035, 127034, 125962, 145651, 125748, 125758, 125692, 127168, 127119, 127127, 125525, 125543, 125511, 147124, 12061, 126113, 127219, 125678, 158869, 42426, 127126, 125399, 127100, 125298, 127751, 125338, 125512, 127677, 159139, 127159, 7853, 125587, 126344, 127057, 127056, 127097, 125296, 125688, 125753, 11037, 11803, 127204, 22563, 127039, 127043, 126242, 127158, 127149, 126092, 125521, 125573, 127546, 145541, 127150, 125347, 127157, 125547, 127148, 4633, 125478, 125480, 125501, 125502, 125397, 125566, 126109, 126105, 127053, 125940, 126093, 127209, 126074, 126088, 126100, 127045, 127048, 125739, 125398, 127054, 126080, 127046, 125385, 126089, 126087, 126078, 126079, 125494, 125738, 18124, 127118, 125503, 125508, 125495, 125510, 125535, 125517, 125532, 158861, 127116, 125497, 125505, 11428, 125685, 145545, 125686, 127549, 125526, 125880, 127354, 126094, 127117, 125498, 125534, 125496, 125520, 125531, 125523, 125522, 125515, 139049, 125506, 125507, 15276, 125530, 125625, 127212, 125516, 125626, 127215, 127213, 6398, 125943, 125322, 127214, 127248, 126126, 146669, 125911, 125317, 125648, 126119, 24443, 126116, 159150, 125364, 125706, 125727, 125946, 135567, 126115, 125570, 126117, 146935, 125375, 125687, 125665, 146371, 125711, 125966, 125096, 125550, 125631, 125349, 125964, 125950, 134959, 159148, 125663, 125388, 147364, 125561, 125571, 125624, 127226, 125713, 125720, 126097, 126026, 125963, 125695, 126164, 22599, 125721, 125679, 126046, 127685, 126206, 159157, 10895, 127295, 125670, 126142, 127298, 126160, 125701, 159154, 125696, 127305, 125694, 126076, 127478, 127296, 127544, 146128, 125680, 125681, 24818, 126228, 24178, 24330, 128095, 24304, 25553, 127274, 126196, 127278, 126073, 126069, 126067, 127277, 127304, 127275, 11028, 127280, 127288, 127291, 125415, 126102, 127297, 127678, 126286, 127299, 127300, 127301, 127302, 127303, 125344, 127162, 31075, 127065, 127675, 145656, 127105, 20029, 146168, 127114, 125674, 23648, 125671, 127352, 127146, 127160, 127485, 14240, 127429, 127428, 146980, 127593, 127330, 127102, 159135, 23642, 22917, 127243, 126338, 145655, 146670, 127074, 127167, 127283, 127484, 125477, 127029, 125827, 127364, 127470, 125404, 159170, 159174, 135289, 125788, 127324, 127332, 127334, 127276, 127287, 127285, 127282, 126075, 31085, 9101, 127587, 127216, 127349, 127475, 127350, 127353, 127360, 127361, 127363, 127362, 127472, 125744, 127382, 127384, 146342, 127386, 6924, 127227, 127430, 127435, 127437, 127438, 8955, 127586, 21568, 127441, 127442, 127448, 127455, 127459, 127465, 127469, 146671, 8222, 159180, 135209, 127547, 127548, 15846, 127488, 127490, 127555, 127492, 127493, 127494, 127495, 127497, 127501, 159172, 127504, 127505, 127506, 127509, 127557, 127559, 127560, 127561, 127562, 127564, 146372, 17468, 127567, 146672, 127578, 19473, 127580, 127582, 18662, 127588, 127583, 127585, 146562, 127595, 127596, 127597, 127598, 127604, 127605, 127607, 127608, 127610, 127766, 127789, 127951, 127612, 127613, 127884, 127617, 127616, 127622, 127623, 127624, 127626, 127625, 127627, 127630, 127635, 127639, 127695, 127721, 127640, 127638, 127646, 127647, 127676, 127651, 127654, 127648, 127658, 127661, 127662, 127665, 127666, 23655, 127674, 127684, 127735, 35412, 127693, 127694, 15475, 127698, 2949, 127671, 127672, 127794, 127673, 127708, 126029, 127681, 127683, 127696, 127699, 127700, 127701, 127702, 127703, 127704, 127705, 127706, 127707, 127769, 127709, 127710, 127711, 127712, 127713, 127716, 127717, 127768, 145657, 127791, 127722, 22286, 127723, 18120, 147182, 127724, 127737, 127893, 159168, 127732, 127733, 127734, 127725, 127726, 127727, 127729, 127730, 127680, 146788, 127752, 127790, 127771, 135974, 127850, 127731, 135086, 127736, 127739, 127740, 127741, 127742, 127743, 127744, 127745, 127738, 127746, 127748, 127749, 127753, 147184, 159176, 127747, 127754, 127755, 127758, 127760, 127761, 127762, 127763, 127764, 127765, 127767, 146789, 127770, 127773, 127772, 127774, 127775, 12016, 146129, 127776, 127777, 127780, 127781, 127782, 127784, 127785, 127787, 128091, 127788, 127793, 127795, 127796, 127786, 127812, 127797, 127798, 127799, 127800, 127802, 127801, 127803, 127805, 127827, 127867, 145990, 127868, 146853, 127807, 23649, 146595, 127809, 127810, 127811, 127814, 127815, 127816, 127817, 127818, 127819, 127820, 127821, 127823, 127824, 127950, 127825, 127829, 127830, 127857, 127888, 127831, 127832, 127833, 127835, 127838, 127839, 127840, 127842, 127845, 127846, 127847, 6809, 127848, 127849, 42414, 127887, 22232, 127851, 127854, 127858, 127859, 127860, 127861, 127863, 127864, 127865, 127862, 127866, 145991, 147185, 127889, 127869, 127870, 127871, 127874, 127876, 127877, 127878, 127879, 127828, 7929, 127915, 127882, 128068, 147186, 127883, 127890, 127892, 127895, 127897, 127921, 127923, 146854, 127902, 127903, 127904, 127905, 20862, 42382, 127960, 128130, 127906, 127910, 127909, 128056, 127932, 159181, 135742, 127933, 145992, 127940, 127943, 128069, 127934, 127935, 127936, 146373, 7049, 127937, 127939, 127941, 127942, 147008, 127983, 147306, 127944, 128064, 127945, 159166, 159167, 127946, 127953, 127954, 127955, 128028, 128526, 8509, 127956, 18088, 21457, 127984, 128029, 128032, 159222, 159211, 128001, 128036, 128023, 128129, 134990, 27826, 128053, 128050, 128057, 142419, 23661, 128072, 33172, 124975, 128026, 128034, 127531, 128044, 135113, 128045, 128049, 128055, 146426, 128176, 146187, 128076, 128078, 11029, 128077, 128081, 128079, 128082, 128083, 128089, 128097, 128101, 42350, 128523, 42364, 128096, 128547, 42372, 128098, 128092, 128099, 128128, 146427, 135013, 135115, 16377, 128100, 128140, 42278, 128102, 128131, 11030, 128103, 128108, 134975, 134988, 134978, 42370, 144971, 128107, 128104, 8655, 128088, 128105, 128013, 128125, 128134, 16168, 135884, 135019, 134969, 135112, 134984, 128112, 128113, 128114, 42383, 128115, 128116, 42406, 128117, 128120, 128123, 127536, 128124, 128127, 134952, 127836, 128153, 128133, 128549, 128135, 128136, 135966, 128087, 128142, 128145, 128146, 14592, 128152, 128163, 128548, 128164, 128167, 128169, 128170, 134954, 146188, 42309, 128172, 128165, 134979, 135004, 134981, 15888, 42362, 128177, 128538, 128544, 128537, 11170, 1171, 128158, 146189, 128159, 135116, 134993, 135018, 134982, 135139, 135029, 42366, 42353, 127387, 135083, 134957, 135059, 134958, 134989, 135017, 134970, 134998, 146428, 134972, 135100, 135069, 135110, 134992, 128178, 135135, 135134, 42490, 135141, 128188, 128187, 128186, 2153, 135142, 135143, 6639, 135145, 135147, 135148, 42620, 144972, 135150, 42356, 42377, 135880, 42320, 42440, 42232, 42389, 42327, 42233, 42395, 42225, 42234, 42439, 42386, 147224, 42381, 42369, 20321, 42277, 42230, 42231, 42451, 42399, 42335, 42235, 42303, 42304, 42480, 42305, 42226, 42398, 20079, 146131, 42289, 42423, 42292, 42433, 127534, 42308, 42249, 42239, 42273, 42241, 42243, 42245, 42413, 147044, 42331, 42401, 21022, 42504, 42455, 42456, 128143, 42251, 42283, 42478, 128012, 42252, 42258, 42254, 42294, 42463, 42341, 42506, 128060, 42479, 42508, 42260, 135167, 42295, 42263, 147091, 42296, 42297, 11861, 42510, 42298, 135151, 135152, 14082, 127697, 127853, 127783, 127778, 127434, 135453, 127474, 137717, 144978, 147095, 127508, 128051, 127447, 127463, 127462, 127444, 127558, 127759, 128132, 127602, 127432, 42190, 127461, 127439, 127541, 127471, 128161, 17380, 127498, 128144, 127483, 127476, 127489, 42348, 127503, 18808, 143856, 144974, 128151, 135156, 18602, 128155, 127550, 127496, 127480, 14657, 128062, 128059, 144984, 128042, 127806, 146429, 127566, 128162, 128154, 128157, 147137, 127414, 135114, 127375, 11058, 144786, 128156, 127599, 17205, 15529, 127620, 127425, 127426, 15027, 11047, 127808, 127422, 127410, 127388, 127880, 127949, 127565, 127652, 127584, 127891, 127603, 127668, 135588, 127552, 127600, 10464, 128086, 128010, 128048, 135125, 146430, 13150, 19360, 127591, 127619, 127590, 127563, 128030, 21142, 128173, 144976, 127545, 127611, 128037, 127898, 18010, 135540, 127631, 127643, 127670, 128168, 127633, 146431, 128171, 127467, 128175, 128137, 144975, 128147, 127660, 127896, 127649, 15868, 128085, 146432, 127679, 127728, 127918, 146434, 128033, 127886, 127826, 128093, 21121, 128090, 127947, 128180, 146433, 128038, 42301, 42269, 11821, 42284, 127576, 18737, 127342, 127899, 42396, 42501, 42502, 42448, 42450, 159158, 42650, 13826, 11140, 42493, 127900, 128009, 127554, 127443, 147183, 42469, 128008, 128022, 42392, 127601, 159221, 147096, 127913, 127340, 127333, 42334, 18463, 128000, 27424, 42330, 128018, 128014, 42390, 144977, 127477, 127994, 42393, 42394, 42391, 127667, 147277, 135508, 137682, 128184, 127385, 28213, 128182, 127966, 128185, 127486, 128021, 11017, 127993, 42333, 135169, 11519, 159225, 147161, 127468, 42290, 135603, 42397, 11827, 127551, 135487, 42355, 42268, 135593, 20699, 42385, 42288, 135166, 42274, 127351, 42280, 42281, 135144, 127326, 127369, 135149, 42484, 42329, 6928, 42337, 42238, 42485, 135489, 127458, 42374, 135452, 13865, 135154, 42267, 127907, 42266, 127359, 135153, 135403, 135511, 135138, 42375, 144209, 8950, 42421, 127325, 128160, 42497, 127779, 42291, 42228, 42236, 128007, 10896, 42498, 42315, 128118, 42240, 42312, 42242, 42282, 135355, 42378, 42286, 42313, 42492, 42491, 42247, 42481, 42326, 128004, 127389, 42344, 14354, 42340, 42338, 42328, 42336, 127629, 159517, 42325, 42307, 42365, 42424, 42425, 42400, 42427, 42438, 128017, 42306, 42422, 128006, 128005, 128541, 146435, 144387, 127440, 42402, 128015, 127356, 127998, 128174, 42310, 18774, 42227, 146436, 42465, 147591, 42262, 135140, 42458, 42505, 159264, 135161, 135160, 135159, 135168, 10986, 144979, 135158, 135157, 42454, 42461, 42460, 42404, 42452, 42489, 42459, 42256, 11615, 135485, 42457, 135172, 135512, 42279, 42250, 42472, 128550, 42408, 42347, 42403, 42332, 42339, 144981, 42345, 42272, 14343, 159226, 159597, 127964, 135592, 127569, 135162, 127592, 42407, 42405, 135165, 135164, 146485, 42255, 135170, 42314, 127575, 135604, 135122, 127628, 135444, 42467, 128546, 135173, 128540, 147339, 14255, 42462, 135360, 42466, 127974, 128527, 127996, 135171, 127589, 135513, 159231, 42464, 127664, 42261, 135128, 42360, 135121, 42259, 42253, 128557, 42359, 18779, 42257, 42474, 128043, 128039, 128035, 42351, 42376, 127632, 135483, 144982, 128507, 10898, 23222, 135016, 42476, 42482, 135132, 42477, 135129, 42473, 14836, 135127, 42494, 42343, 159227, 42346, 144983, 135858, 42349, 42429, 42432, 42499, 42500, 42412, 42410, 42293, 42264, 11894, 135123, 128046, 42509, 42468, 42507, 42475, 42416, 42415, 42361, 42357, 15502, 42495, 135176, 42276, 159232, 159228, 135118, 42367, 42363, 147162, 42275, 128040, 42316, 147278, 159257, 127682, 127609, 27750, 42358, 42380, 14552, 42486, 159229, 42342, 42324, 42317, 147163, 42318, 15934, 42445, 159233, 159234, 42435, 42323, 42441, 16526, 128074, 135120, 21368, 23619, 42605, 42436, 42442, 135014, 42444, 127507, 146132, 42443, 42319, 135101, 128119, 134980, 42619, 22138, 128047, 135133, 135126, 135117, 128574, 135178, 159239, 10387, 128110, 127991, 135530, 135363, 10947, 147164, 134986, 135005, 135006, 135009, 134968, 134999, 135020, 127634, 135064, 135000, 127881, 135349, 135056, 134983, 135107, 127636, 135088, 135079, 127692, 135010, 134949, 135105, 144985, 135106, 145942, 135284, 147165, 14919, 127637, 127714, 127756, 146486, 128031, 135312, 135956, 42244, 135163, 128511, 42287, 18117, 42419, 42229, 42224, 42300, 128066, 11583, 147584, 42302, 127446, 135124, 128571, 42418, 42449, 10946, 127843, 127841, 12690, 42322, 135271, 128570, 42248, 135780, 42299, 127659, 42503, 127653, 135196, 147307, 42488, 15514, 134953, 135288, 146487, 21993, 42496, 127855, 42483, 42471, 147252, 127804, 42411, 42265, 135098, 42437, 128016, 42311, 127669, 42434, 146538, 135095, 146565, 42285, 42368, 42371, 42373, 42354, 42384, 146728, 135282, 135747, 42387, 135204, 135205, 135177, 42417, 128166, 42446, 12011, 128179, 135211, 135212, 13893, 135411, 127331, 134973, 135155, 146539, 128126, 135189, 146180, 127844, 135295, 146510, 19515, 16700, 15757, 14290, 14653, 135277, 135279, 135281, 135748, 100362, 135290, 135291, 3447, 135293, 135294, 1198, 135347, 135474, 18155, 135326, 135329, 135332, 135358, 135336, 135341, 135342, 135344, 135345, 135346, 15956, 4001, 15379, 125383, 135381, 19049, 135348, 135795, 135352, 135377, 20042, 39955, 6020, 135366, 135367, 135368, 135369, 135364, 135372, 7210, 17794, 135416, 135406, 135383, 135384, 135387, 135708, 3567, 5374, 135393, 135394, 135396, 135398, 15377, 135480, 19772, 135491, 147253, 15925, 135413, 135421, 17335, 135448, 135454, 135479, 21478, 135482, 135484, 17524, 147562, 135490, 135488, 135529, 135516, 135493, 135656, 135495, 135496, 135497, 135498, 135707, 135522, 135499, 135501, 135502, 135505, 135506, 135507, 135531, 135544, 15455, 135515, 135557, 135519, 135520, 135521, 135517, 135709, 135523, 135524, 135525, 135526, 145346, 135527, 135528, 135532, 135558, 15897, 14246, 135533, 135534, 135535, 135536, 147586, 135672, 135537, 135538, 135539, 20500, 135542, 135543, 20729, 135518, 135605, 18331, 135559, 135545, 135546, 42589, 135547, 135574, 146594, 135548, 135549, 135550, 135551, 12191, 11474, 135552, 14070, 135566, 135629, 15101, 135572, 135555, 135556, 135618, 135560, 135561, 135577, 135562, 135563, 135564, 11439, 135565, 135634, 135568, 135570, 135702, 135571, 42103, 135600, 135573, 135575, 135576, 135578, 135579, 135580, 135581, 135582, 135635, 135637, 135583, 135584, 135585, 11605, 135586, 135587, 135590, 135594, 135595, 146596, 12937, 11086, 135597, 135612, 135638, 135624, 135627, 135646, 23668, 159267, 135598, 135599, 135601, 135606, 135947, 135607, 135608, 135609, 135610, 135611, 135647, 135648, 135751, 135614, 135615, 135616, 21706, 135617, 135619, 135620, 135613, 135621, 145811, 10948, 135622, 135623, 135753, 135649, 135633, 135650, 135730, 14795, 12913, 135674, 135676, 135690, 135679, 147563, 135692, 18353, 18993, 135703, 135705, 137715, 135706, 146597, 135711, 42185, 17164, 135721, 135724, 135727, 18251, 135731, 18161, 135732, 135733, 135734, 137742, 135736, 135740, 135741, 135758, 13712, 17385, 10865, 16819, 19970, 135779, 135767, 135784, 16683, 135786, 135788, 13193, 135796, 135797, 159254, 135791, 135792, 135896, 17909, 135890, 139896, 135859, 135862, 16535, 135793, 147255, 135798, 11532, 14222, 159242, 135799, 135800, 135952, 137745, 145244, 135891, 16478, 159269, 135803, 135804, 128020, 135865, 135807, 135805, 135801, 135808, 135874, 135875, 147256, 135809, 135810, 135867, 16990, 135811, 135831, 16467, 135824, 26549, 42186, 135813, 135876, 135877, 145248, 135814, 135868, 135863, 135815, 135816, 135819, 145268, 135823, 10908, 135832, 135830, 42621, 135825, 135888, 135826, 135828, 135854, 135872, 135861, 137719, 135834, 135869, 146598, 13013, 135835, 135836, 135591, 135833, 135838, 135841, 17932, 135843, 135845, 135846, 135848, 135849, 135873, 135864, 12678, 145947, 135871, 135938, 135975, 137807, 135878, 135879, 16074, 145246, 135881, 135882, 135883, 135967, 135969, 135970, 147639, 135971, 12320, 16902, 135886, 135885, 137804, 135897, 135898, 135903, 137670, 18532, 14296, 124056, 135986, 10990, 16835, 135941, 10611, 135953, 12268, 135962, 137649, 13594, 23674, 42540, 17992, 135965, 135976, 135981, 137740, 20706, 19685, 135979, 18313, 135998, 17770, 17639, 137768, 17883, 17114, 19129, 137747, 20688, 22063, 21454, 137820, 147564, 12675, 12475, 14524, 17760, 18627, 11288, 137782, 137681, 18334, 21588, 137675, 21531, 21870, 159240, 20633, 17527, 137815, 10809, 42213, 137695, 12670, 137692, 137816, 12668, 22114, 19382, 21261, 10821, 11124, 137720, 17078, 14215, 137814, 17431, 137785, 137762, 13245, 12579, 20913, 21292, 19768, 19996, 42216, 13092, 15152, 42214, 14144, 42004, 19410, 147565, 14696, 10655, 42006, 15617, 17578, 14360, 12625, 14284, 135821, 12529, 42637, 18966, 11165, 10334, 16109, 13624, 12947, 13949, 20163, 19417, 19487, 23630, 42215, 15755, 14566, 16644, 16647, 13508, 17265, 16089, 10502, 136013, 146181, 42212, 18387, 16350, 15164, 147152, 20922, 13458, 11431, 14379, 12629, 14500, 11196, 12347, 20327, 21750, 147257, 15363, 12640, 17464, 1268, 18669, 42005, 16518, 15526, 21720, 22085, 21737, 21063, 16968, 42002, 12073, 42007, 42008, 17500, 12154, 11310, 42010, 16516, 19946, 19447, 27802, 19503, 42011, 16217, 14652, 42121, 12992, 15959, 11620, 21785, 22064, 146358, 21868, 18881, 42003, 13051, 42106, 147258, 42198, 13577, 18405, 12009, 18340, 20855, 21791, 20047, 42110, 12341, 42120, 42111, 42184, 17893, 42107, 42187, 42109, 42108, 146118, 13409, 21110, 20661, 20541, 19805, 18545, 11649, 42156, 42218, 42211, 159244, 159243, 42122, 42188, 42189, 146561, 15556, 15777, 20732, 42191, 11730, 13025, 21940, 42063, 12862, 19064, 21401, 42112, 11423, 17110, 15425, 42195, 16216, 18318, 10999, 11613, 15839, 11657, 11254, 147259, 10843, 10837, 22397, 42196, 18542, 42088, 13181, 42197, 16798, 18108, 22877, 22076, 21925, 20846, 21234, 19074, 42097, 11679, 42105, 42114, 42091, 18550, 42199, 21198, 42065, 159251, 10820, 17184, 42200, 15068, 42220, 10634, 42201, 16605, 18061, 20724, 22192, 12918, 159256, 19235, 16075, 42092, 15202, 42093, 42119, 21595, 42094, 15889, 15277, 14428, 19974, 19019, 42098, 147309, 42095, 42202, 42203, 19089, 13023, 15188, 12846, 12667, 18628, 42101, 20491, 20221, 19667, 42099, 42151, 14499, 12482, 145809, 14663, 42204, 42205, 15930, 17746, 147310, 11294, 14221, 42100, 146153, 21875, 18843, 18983, 17978, 12811, 17982, 22572, 159274, 18212, 147260, 42102, 42208, 42166, 42117, 42115, 42207, 20437, 42104, 20235, 19272, 19362, 21773, 21534, 21986, 42206, 42209, 16524, 14968, 16655, 42118, 42116, 16200, 15395, 12473, 146563, 18278, 21167, 147419, 15822, 12027, 10877, 12267, 17009, 13592, 14027, 17138, 16132, 18274, 15175, 11585, 21527, 19336, 13413, 15789, 19079, 17767, 17540, 147261, 20527, 22668, 22508, 22564, 21945, 21524, 21881, 21801, 21398, 20434, 20046, 19959, 19355, 18894, 15585, 145269, 17199, 13868, 14902, 15054, 14496, 42246, 42671, 15825, 11674, 11565, 11714, 17252, 13626, 17161, 16332, 10693, 15644, 15178, 14344, 12531, 11182, 145810, 10920, 20213, 18162, 146424, 15642, 15405, 13568, 12301, 19568, 15636, 12982, 18172, 15063, 15061, 17572, 16987, 19838, 20689, 21382, 11442, 15019, 21987, 18472, 147154, 13722, 16634, 19354, 21474, 13066, 16352, 14420, 15521, 16079, 14929, 15555, 16356, 145271, 12903, 15018, 16358, 18506, 21402, 20553, 19118, 18840, 15459, 16845, 14309, 42271, 17303, 42453, 17789, 147262, 18114, 20240, 22142, 19876, 18815, 16723, 12620, 14914, 15816, 11969, 145932, 14150, 17039, 16711, 22614, 21058, 20185, 19986, 19581, 147442, 42409, 11536, 13729, 16754, 17880, 16879, 11974, 11539, 13728, 147156, 22993, 20214, 20891, 20795, 20635, 20717, 19663, 16460, 13393, 18418, 17381, 17967, 14069, 13653, 14137, 11531, 15723, 19817, 18906, 12454, 12711, 147443, 42652, 15981, 14168, 13488, 13183, 18512, 147263, 42653, 15944, 22641, 22012, 21708, 21782, 19870, 19791, 20123, 19464, 19017, 13280, 13514, 13639, 15683, 12929, 15742, 13862, 147264, 14338, 12567, 15717, 11107, 147319, 16157, 14513, 14028, 147444, 12930, 17611, 16066, 14597, 12542, 13964, 21937, 10887, 18403, 12621, 14167, 13963, 15241, 14073, 17618, 17405, 16406, 11223, 16832, 17604, 146230, 14402, 16707, 19370, 20015, 13512, 16265, 10833, 12111, 12479, 16447, 18002, 16778, 147579, 42661, 13430, 144783, 16318, 42515, 15020, 16246, 19990, 19164, 18914, 13569, 16948, 14778, 17246, 16913, 14385, 17608, 18052, 16452, 18702, 16276, 42512, 15418, 15864, 42514, 15116, 26916, 18209, 13674, 11277, 16531, 18004, 147337, 20228, 18926, 20918, 16062, 18579, 14183, 42519, 21295, 16738, 10997, 12385, 42520, 42522, 15015, 16020, 16659, 16487, 16506, 10577, 10286, 11874, 9303, 42708, 16106, 18192, 13526, 12048, 11133, 11105, 17652, 17017, 42521, 42709, 24490, 19540, 42596, 16441, 16102, 19872, 42628, 15501, 16859, 16059, 147458, 42580, 14376, 146157, 11420, 21777, 20423, 12701, 145381, 16660, 42555, 147445, 16745, 15141, 16955, 13557, 16396, 14946, 147338, 147303, 14846, 16837, 15686, 42526, 10807, 11128, 12608, 42675, 17291, 42553, 18462, 14089, 16247, 19577, 21923, 19014, 21347, 21192, 19306, 19850, 18754, 16680, 15516, 17318, 10607, 18539, 14293, 14608, 42554, 16642, 18714, 16010, 22637, 146601, 14173, 42662, 17567, 15429, 12403, 144780, 12468, 13935, 15368, 15365, 14711, 16951, 42591, 17590, 13130, 11192, 15863, 147340, 42640, 42677, 11604, 18756, 16199, 12316, 18456, 14121, 16047, 18900, 42607, 14826, 10591, 16218, 15748, 22157, 21405, 20208, 20617, 19259, 42542, 18346, 11436, 15546, 16498, 11469, 16046, 18097, 22456, 15760, 15859, 16780, 22038, 12458, 12851, 13084, 17290, 42593, 18500, 14953, 16631, 17387, 42668, 12264, 147536, 18071, 16070, 147446, 17177, 42608, 42538, 17831, 17802, 17713, 17413, 146231, 42586, 15212, 18022, 145933, 135726, 19823, 20824, 19165, 20117, 19883, 17891, 16189, 42611, 17591, 17535, 42566, 17533, 17109, 146232, 17624, 42666, 18443, 21484, 12244, 20379, 19782, 20143, 144813, 42613, 147695, 42571, 15123, 146600, 18080, 18623, 14719, 18151, 13703, 13857, 21609, 21512, 21296, 21403, 19832, 15785, 42578, 12081, 42612, 14232, 18619, 18953, 15346, 17001, 12297, 16684, 17481, 146695, 17729, 18942, 42665, 136026, 146696, 14767, 11641, 11169, 13981, 10899, 13792, 11179, 10827, 12520, 14164, 11204, 17358, 18042, 145934, 18786, 18905, 42533, 13656, 15090, 17845, 14951, 16729, 147583, 135248, 13513, 42625, 11213, 135436, 146566, 135652, 21789, 21817, 21634, 20833, 21364, 20649, 19655, 42577, 42694, 42536, 18021, 13954, 11676, 127834, 15128, 147304, 10869, 13241, 18183, 18618, 19562, 19268, 42723, 13304, 14996, 12915, 13281, 11755, 14732, 22133, 22030, 15064, 11980, 42585, 11982, 15323, 13272, 42576, 17745, 136025, 17615, 42604, 17916, 13517, 12917, 11301, 42693, 16137, 11278, 20557, 21669, 18125, 42615, 15552, 135737, 16213, 136001, 14651, 14528, 135664, 11902, 15176, 16035, 16972, 146182, 15443, 12427, 13206, 17286, 17412, 17127, 17778, 14849, 135822, 12593, 146697, 15457, 15422, 12746, 22260, 136010, 136024, 135686, 14857, 21605, 136014, 18556, 20140, 14485, 135181, 17970, 146569, 12488, 135666, 135687, 20602, 10884, 135856, 42518, 20206, 135958, 136023, 126203, 14990, 18158, 145385, 135735, 146464, 14692, 12688, 10695, 1095, 147818, 135782, 12617, 147454, 13549, 135955, 135375, 135287, 135292, 135919, 20086, 135681, 1157, 135785, 135728, 18307, 13597, 145948, 135934, 135959, 16044, 42722, 10793, 135713, 135710, 135746, 135961, 135920, 19376, 137703, 159277, 146796, 136028, 12615, 135339, 14371, 135353, 135790, 135960, 17917, 135397, 135722, 14299, 135739, 147431, 13619, 16163, 135752, 14614, 13118, 147447, 135395, 135977, 16125, 13418, 13579, 135893, 17218, 135964, 135400, 147432, 16190, 135759, 135921, 135429, 14948, 42524, 3179, 135417, 135418, 135935, 19159, 15565, 135957, 135698, 12436, 135738, 147421, 135749, 135688, 16844, 42676, 146233, 14152, 42511, 42599, 42603, 40952, 42602, 14947, 16489, 11103, 22390, 16221, 10650, 16687, 42600, 11012, 42651, 42513, 42609, 42601, 42638, 42717, 147448, 15702, 17293, 42517, 42618, 42516, 135201, 17435, 42561, 135260, 135262, 42710, 42564, 19144, 137689, 42597, 42707, 42549, 42551, 42635, 135983, 41072, 42634, 42645, 136009, 159278, 42627, 135313, 17868, 42579, 145949, 42623, 16367, 19161, 42523, 42622, 16935, 147585, 42636, 42531, 42541, 18136, 146590, 42525, 42598, 42629, 42670, 135980, 135988, 135391, 135945, 42704, 42688, 146267, 42692, 42630, 135850, 42590, 159281, 145468, 42537, 135907, 42713, 42592, 19989, 11096, 42655, 42527, 135908, 42528, 135671, 17257, 42529, 146360, 42574, 42714, 42631, 135723, 135851, 135982, 42639, 135940, 42664, 135261, 136000, 135948, 135390, 42646, 42582, 135389, 135925, 136027, 19075, 135922, 15769, 135206, 42647, 42678, 135388, 135994, 42679, 42562, 135270, 146361, 135984, 42556, 146234, 42633, 42700, 135985, 17049, 147461, 15106, 159275, 28196, 42657, 42595, 42560, 42632, 42543, 40889, 42715, 135263, 42691, 14060, 42594, 135670, 135359, 42545, 135269, 42563, 42680, 147132, 42581, 135554, 42667, 135553, 135273, 42697, 42610, 42565, 42588, 42702, 42546, 42575, 135327, 18287, 42642, 135247, 135844, 42721, 42557, 135328, 146680, 42689, 42567, 135274, 146772, 42568, 137911, 42583, 135276, 42674, 42684, 136035, 42698, 147489, 13780, 40890, 42682, 42530, 42569, 135987, 42701, 135931, 135373, 42570, 42718, 42690, 42683, 42626, 42719, 14586, 22153, 42614, 42681, 42532, 42703, 15366, 12706, 17595, 42535, 22105, 42539, 135207, 42699, 27820, 19862, 17699, 147426, 12693, 15773, 135993, 42669, 146362, 15749, 135847, 135210, 17657, 135191, 21909, 32263, 42624, 135989, 22424, 15606, 13855, 14185, 135990, 135992, 135275, 146363, 11499, 13585, 135362, 1079, 135266, 135951, 135995, 42673, 17879, 42648, 135944, 146570, 137739, 42685, 135504, 42686, 18522, 135215, 42724, 135427, 135217, 21404, 135451, 136002, 136005, 147449, 19135, 16351, 147462, 42696, 42572, 16472, 14574, 42659, 16025, 135254, 136032, 147629, 13392, 13240, 13104, 146732, 146592, 42663, 135357, 13575, 135946, 146770, 135689, 13951, 28734, 42660, 11463, 137690, 135258, 11005, 14734, 14487, 135351, 135370, 30804, 135216, 135842, 19988, 135280, 135249, 15446, 135252, 20931, 135667, 135256, 135259, 11331, 40903, 135278, 14909, 145617, 135285, 135286, 135659, 21863, 128084, 135361, 147588, 136019, 136006, 136033, 135887, 135675, 145114, 135677, 124651, 135660, 135337, 13284, 15244, 136029, 147589, 159289, 13368, 13236, 137803, 146227, 11011, 10847, 135378, 135382, 135900, 22653, 10848, 10864, 11403, 135385, 19007, 146703, 135255, 135668, 135909, 135910, 135913, 135914, 135916, 21616, 21624, 135428, 146734, 146311, 42695, 135776, 128080, 16734, 11162, 18612, 12645, 137613, 135682, 18392, 42606, 143829, 146312, 11779, 42706, 12241, 135923, 135569, 135685, 16420, 136037, 147590, 135743, 137714, 19400, 135902, 135632, 135999, 17230, 17914, 18051, 135905, 135695, 13600, 18739, 16091, 137821, 137673, 137822, 146313, 137800, 147345, 11151, 42711, 135335, 13475, 13899, 27723, 135602, 137746, 137738, 19139, 146314, 137741, 42705, 137790, 137711, 135343, 12125, 42616, 137789, 135654, 16994, 137817, 25557, 136003, 15943, 42559, 137699, 137697, 137683, 137678, 11995, 146407, 17251, 12610, 18471, 10618, 135631, 137679, 17288, 137813, 12471, 16928, 18655, 137672, 18523, 136038, 42550, 17602, 135242, 136031, 23764, 19826, 19308, 42649, 42643, 18325, 19777, 21672, 42584, 11001, 136039, 136040, 30974, 42548, 135630, 137771, 14204, 16421, 27793, 135929, 14297, 137776, 42547, 145894, 17154, 15599, 137661, 137706, 42617, 137716, 135541, 27455, 137658, 137660, 20539, 145619, 136015, 135820, 137787, 137808, 137805, 146235, 135310, 135323, 17910, 10936, 20522, 22682, 22684, 12139, 137671, 137812, 13831, 14095, 137709, 137677, 11293, 1239, 15915, 27861, 159283, 14559, 21493, 137783, 20647, 146228, 136016, 135991, 2759, 128521, 11149, 12636, 136041, 137655, 10719, 18982, 15071, 135794, 137691, 137809, 137651, 15390, 137802, 137786, 13814, 14562, 15426, 42096, 137794, 14292, 18023, 137698, 147427, 136030, 137702, 137772, 137701, 135662, 42672, 21897, 146318, 135895, 137744, 137737, 147450, 137819, 137792, 137674, 26940, 17797, 147428, 11680, 14324, 135694, 11160, 149865, 150003, 7378, 2114, 146611, 9184, 9446, 9424, 9662, 9753, 23759, 146154, 23765, 23958, 24155, 24130, 24597, 24168, 24996, 147640, 25714, 25691, 26179, 985, 146514, 26337, 26366, 26845, 26509, 2286, 1601, 26551, 146236, 19371, 147451, 28146, 14993, 145270, 146319, 26786, 26022, 26146, 27390, 27366, 28103, 17396, 12584, 10575, 28295, 5681, 147581, 28400, 146399, 136007, 21385, 135514, 3229, 4999, 5663, 7010, 6829, 8395, 3617, 14269, 31248, 13111, 17689, 14273, 34138, 10831, 11172, 901, 18121, 17711, 1771, 13461, 12921, 11452, 14059, 15480, 11397, 13516, 19004, 18396, 12826, 14217, 5833, 12639, 16800, 146733, 21746, 25340, 147482, 28106, 146237, 14578, 18008, 1825, 1905, 15150, 18395, 18087, 21681, 13609, 13167, 14958, 12860, 18233, 145236, 14808, 14494, 14563, 15836, 17327, 12180, 12750, 16667, 11247, 21344, 19734, 17391, 13611, 6652, 16194, 146771, 19936, 20090, 25471, 13777, 26217, 145272, 26316, 1235, 146238, 33330, 13775, 13318, 10515, 16177, 11251, 18315, 22798, 24487, 12853, 21482, 21643, 19672, 1238, 1850, 18728, 14154, 21633, 21843, 21883, 22180, 24880, 13645, 6218, 16033, 146155, 18302, 25038, 20473, 20551, 20387, 20256, 20275, 20262, 17449, 24939, 25353, 146493, 10374, 26254, 10652, 14890, 12493, 27316, 31148, 2096, 16768, 25247, 33432, 935, 18561, 1100, 12957, 24947, 25012, 17165, 26223, 14962, 12407, 16519, 21313, 17775, 19863, 12055, 19311, 12181, 17425, 18293, 11255, 12477, 16878, 12523, 14945, 14174, 18184, 11464, 16669, 13974, 18976, 18842, 11576, 13264, 20784, 14312, 16069, 13269, 11572, 14315, 13772, 14471, 14542, 10931, 16100, 20460, 20084, 13924, 14713, 18348, 14289, 25130, 14163, 12522, 15952, 12686, 951, 12006, 146343, 25115, 25149, 19101, 11595, 32840, 10751, 14263, 146773, 145273, 14715, 17241, 10851, 147452, 18134, 25413, 1641, 12230, 17687, 18530, 147439, 11097, 12208, 14216, 16961, 11122, 14748, 12078, 15338, 12372, 15699, 16206, 14579, 18223, 15356, 12828, 16806, 15075, 22488, 18977, 18981, 12641, 18410, 13871, 13383, 19485, 19365, 146735, 159381, 13905, 15604, 23756, 15283, 23946, 15162, 20664, 10863, 10844, 20456, 13998, 13212, 12326, 147440, 17781, 15219, 11700, 17742, 21612, 15131, 15073, 12164, 11185, 14750, 10904, 15532, 12816, 16179, 18582, 13705, 13993, 16039, 15062, 14936, 13965, 18573, 14537, 15692, 14935, 17060, 19610, 159012, 11528, 18077, 12594, 13135, 146736, 18025, 18453, 18862, 16916, 16285, 15386, 17155, 20817, 145275, 15220, 17269, 16045, 18459, 22977, 22170, 16836, 14507, 16959, 18507, 16130, 18610, 17242, 17378, 15722, 15000, 11582, 18373, 13235, 18326, 13283, 21419, 19947, 19616, 13291, 16282, 15159, 14557, 14535, 14805, 12279, 15026, 17423, 16842, 18951, 13992, 14181, 13654, 20018, 11166, 22393, 21467, 21757, 14889, 20800, 20224, 20548, 20122, 20127, 19950, 19649, 18891, 17030, 11487, 11698, 14634, 16297, 15620, 18476, 13996, 12574, 13012, 15823, 147483, 19300, 17548, 17280, 14599, 17965, 22158, 18217, 22753, 22754, 22554, 21369, 20453, 11652, 17418, 18290, 15097, 146738, 16720, 17182, 15067, 10829, 22144, 147525, 16184, 14304, 20333, 20044, 19363, 16671, 15481, 15381, 18384, 18082, 16233, 12744, 14468, 147484, 20175, 21839, 21006, 146791, 158751, 20684, 145626, 21219, 21240, 14153, 146240, 13607, 12153, 16073, 15167, 18508, 17355, 11473, 16889, 146156, 21966, 15291, 19547, 15805, 15189, 10939, 18064, 21718, 13407, 16969, 18570, 17168, 22154, 20685, 16623, 18312, 145621, 20301, 18958, 19979, 19919, 19303, 17407, 12558, 15199, 146739, 20782, 159287, 145101, 16038, 145622, 21954, 10989, 19856, 15250, 18028, 17019, 16488, 13387, 17351, 18075, 18343, 18000, 160290, 16976, 16975, 21517, 20896, 18696, 18809, 19625, 13499, 10934, 16704, 14061, 13928, 19374, 21394, 19797, 20066, 21056, 16693, 15815, 20778, 21417, 20200, 19907, 19331, 19006, 18142, 18018, 18001, 18435, 146792, 20329, 18096, 21078, 21824, 21445, 21258, 20302, 21541, 19483, 19217, 18131, 18260, 18678, 17884, 18687, 19142, 17538, 22497, 21902, 21981, 21752, 20630, 20549, 20149, 19255, 19457, 16904, 15831, 17764, 16207, 16609, 18736, 16691, 12893, 137921, 34235, 12919, 21657, 20663, 20417, 14266, 145623, 18763, 19267, 15374, 17613, 18391, 16570, 15384, 12663, 147485, 21257, 20458, 19497, 17467, 15121, 11095, 146497, 11161, 146567, 10763, 21470, 16174, 17646, 17519, 19283, 21359, 19652, 18693, 15775, 11244, 11376, 145627, 15155, 14656, 11927, 16446, 11033, 18465, 15821, 20269, 21064, 14328, 13449, 18216, 145630, 17235, 12991, 12770, 20136, 19935, 144895, 15890, 14987, 17736, 16385, 20452, 16802, 14502, 13038, 14630, 11031, 18839, 11230, 12911, 19833, 146793, 13405, 15476, 16224, 10677, 18056, 146158, 13983, 22384, 19574, 146513, 17571, 147642, 18050, 14157, 146794, 19384, 19076, 17523, 18236, 159288, 18557, 20760, 18066, 13379, 146515, 11187, 12604, 22524, 20769, 20141, 13330, 19083, 19647, 15266, 147643, 147819, 13503, 17850, 13552, 16856, 17092, 14693, 11007, 11009, 11434, 14978, 13096, 11116, 13267, 13273, 11282, 17219, 21461, 16484, 18672, 13063, 15765, 17393, 13054, 14839, 11270, 21247, 19246, 18712, 14684, 159290, 13420, 18950, 14811, 10868, 15143, 17727, 18235, 18138, 13254, 159286, 159285, 20412, 14681, 146365, 16022, 16765, 18519, 14486, 12187, 16858, 17409, 21721, 10962, 21237, 20367, 19476, 18933, 15468, 13669, 15264, 16049, 11509, 15856, 21892, 20807, 21190, 14787, 10935, 33921, 17029, 17328, 12405, 11252, 146409, 146516, 15921, 18177, 146795, 146366, 11535, 15406, 16327, 18039, 148213, 21960, 147453, 19691, 19951, 18112, 12329, 13208, 146517, 20197, 15127, 19218, 159296, 14834, 15960, 17887, 13745, 15357, 15728, 20121, 19937, 12596, 13010, 21003, 14190, 19614, 18959, 19664, 12442, 17018, 17730, 14869, 19280, 17732, 138105, 14369, 21341, 20524, 19689, 18822, 15824, 146518, 146519, 20668, 22325, 36282, 16970, 20496, 18005, 15252, 11144, 15010, 16759, 15766, 22336, 12738, 18484, 15083, 17282, 14565, 19204, 16942, 146797, 13258, 11668, 10319, 12698, 16713, 14816, 20488, 21637, 18354, 13487, 11626, 16827, 13841, 14965, 14430, 15827, 19505, 14013, 13842, 14182, 16953, 14772, 18398, 19005, 19456, 21480, 16065, 14660, 10834, 138156, 18762, 13476, 14497, 13641, 14688, 16980, 20893, 19955, 138171, 18095, 20655, 148006, 15268, 12634, 15109, 16988, 18037, 16112, 14394, 18503, 18616, 20101, 20554, 148007, 18248, 17993, 19051, 15772, 19222, 13454, 13916, 147486, 147455, 14003, 20232, 10103, 21075, 19533, 15270, 14374, 14249, 15706, 15731, 12160, 14920, 13065, 17055, 14532, 14847, 146798, 18341, 20810, 13216, 144782, 21420, 16296, 18111, 14942, 17227, 11638, 21876, 141303, 14451, 15967, 21963, 19008, 21758, 19978, 17625, 17340, 146412, 18563, 22739, 22484, 21448, 21352, 12999, 15590, 14792, 21276, 21274, 19244, 15518, 14737, 17162, 16982, 147779, 20192, 146413, 21744, 22139, 21630, 19894, 20037, 12979, 16679, 22305, 13401, 146799, 18085, 15040, 16891, 14235, 19373, 21730, 21251, 18430, 14956, 17006, 19274, 17342, 17643, 15048, 14582, 13638, 146041, 19666, 145207, 146085, 21311, 20193, 18685, 17400, 17417, 18320, 18464, 21069, 18154, 20375, 12616, 14575, 16030, 14084, 20885, 21396, 21083, 20234, 20207, 19965, 19444, 19455, 10678, 17969, 11181, 11514, 145674, 17728, 15496, 13528, 11156, 16577, 21755, 20529, 19262, 14364, 147795, 17976, 12581, 19929, 14021, 18393, 18596, 20249, 16009, 21255, 19395, 19009, 19802, 15806, 17989, 21576, 14177, 13555, 16810, 148150, 14305, 10661, 14055, 21697, 22029, 17869, 16717, 14473, 14278, 17977, 13215, 13707, 11561, 15958, 147487, 14706, 18258, 146800, 20146, 147456, 21999, 138391, 19240, 17974, 16967, 22478, 16514, 16269, 21077, 21314, 20024, 19061, 19157, 16054, 14123, 15525, 17095, 16795, 16041, 14218, 16637, 12780, 16052, 13666, 13061, 20955, 17961, 18499, 18560, 17539, 12768, 11375, 17080, 17837, 14459, 22026, 20424, 19398, 18992, 17597, 146350, 18580, 18590, 10941, 13176, 10822, 14333, 14722, 18123, 17677, 17565, 20657, 11048, 10933, 138472, 12643, 11064, 17310, 17438, 16811, 10551, 21047, 18083, 14970, 13243, 20552, 16818, 14768, 16834, 11806, 12446, 15441, 18738, 138425, 17594, 19917, 21306, 21146, 19494, 18119, 147457, 12118, 146007, 14894, 10709, 22007, 16862, 12202, 17111, 10525, 19229, 16692, 16636, 12943, 139540, 11736, 147488, 138495, 13700, 14517, 12970, 17166, 15280, 19346, 16850, 16860, 17115, 146526, 15038, 12452, 15929, 10701, 13027, 146349, 20560, 20286, 20518, 19549, 19939, 19053, 14156, 14458, 15031, 14640, 12895, 146008, 10641, 10547, 14622, 15573, 18496, 146527, 15650, 14665, 16572, 16722, 10808, 16466, 13604, 15438, 13324, 12415, 147086, 15949, 15594, 20182, 19012, 10594, 14388, 14954, 16915, 18468, 17440, 147276, 146528, 14885, 20426, 20201, 19338, 19068, 18626, 17424, 17479, 17482, 17510, 147459, 138516, 17769, 18554, 19958, 21391, 21244, 12940, 20687, 20525, 20534, 20741, 19646, 12543, 18143, 16006, 19948, 10569, 16933, 16424, 17721, 22725, 21309, 147460, 20162, 20531, 20721, 19328, 19995, 138505, 19281, 19500, 19040, 10819, 13274, 147490, 13536, 13906, 12381, 10937, 16910, 14340, 15832, 14756, 16779, 17551, 18247, 19899, 20841, 19721, 18139, 14118, 17064, 10697, 15166, 17503, 17754, 14109, 13137, 14793, 16978, 14237, 11068, 11040, 14359, 16315, 21587, 14169, 12777, 11494, 12321, 11214, 19654, 11226, 13326, 13139, 147491, 144890, 12005, 12723, 16262, 14746, 14725, 12312, 146414, 15941, 16391, 15804, 11726, 15507, 145676, 11114, 22125, 146415, 18546, 16592, 17453, 15427, 15454, 18611, 21695, 20195, 21670, 21125, 21128, 20430, 21088, 19435, 19325, 19332, 18003, 13614, 145083, 14093, 16940, 11069, 18719, 16568, 18079, 10500, 13071, 11371, 13595, 20168, 20887, 19584, 15547, 146416, 17679, 16591, 16277, 15872, 18425, 20535, 17649, 146805, 18621, 17987, 18836, 16678, 146636, 12334, 15787, 16949, 10549, 17863, 15183, 20313, 20184, 20642, 14637, 19032, 18565, 10308, 11274, 12541, 12834, 146316, 13699, 16803, 14612, 13761, 16032, 14481, 17119, 19100, 14821, 12603, 16674, 13896, 16841, 16918, 13658, 14306, 16932, 16663, 17740, 15940, 16154, 18265, 22604, 22236, 21814, 18987, 17520, 20308, 146529, 15297, 18593, 15022, 146417, 13927, 17364, 18949, 17144, 146806, 17936, 147333, 16927, 19841, 21749, 21455, 21091, 21107, 21163, 21942, 20428, 19628, 16926, 14024, 10648, 17300, 15513, 16422, 13933, 16640, 14453, 15393, 13335, 16923, 13437, 13621, 15165, 13643, 146807, 17069, 12384, 12148, 14349, 17656, 17691, 146530, 15704, 13920, 13427, 12102, 15172, 13791, 18972, 17636, 13349, 12106, 19601, 14281, 147630, 13692, 21696, 17014, 12835, 16098, 17204, 14068, 18650, 11217, 16034, 21239, 16727, 16464, 14438, 13711, 12967, 14645, 147343, 19364, 10909, 15747, 146531, 14026, 14367, 15217, 14799, 12140, 16934, 18451, 15448, 15841, 16929, 146511, 17337, 13774, 17266, 12883, 11913, 16011, 13956, 16829, 14186, 14483, 16417, 13923, 13716, 12397, 17433, 16785, 14720, 16031, 17317, 17082, 16150, 12518, 14294, 13744, 158950, 13299, 10866, 16799, 17160, 14307, 12729, 147492, 18615, 16794, 16881, 17068, 23729, 12800, 16898, 16883, 22575, 16996, 12611, 19869, 14214, 15049, 16331, 13582, 11337, 14873, 13946, 10686, 16505, 13839, 17898, 18873, 12902, 17549, 18288, 146512, 10696, 146808, 147344, 18454, 17488, 145278, 22734, 22039, 19551, 19326, 19560, 19674, 19479, 18854, 18548, 18689, 17532, 18358, 14950, 13999, 17638, 18327, 18089, 146446, 14405, 11994, 17404, 20586, 22035, 19514, 19934, 146532, 19668, 19055, 18679, 18543, 14632, 18625, 18116, 18680, 18501, 21316, 21250, 20085, 20672, 20065, 20064, 20069, 19956, 20027, 19631, 19102, 19138, 14972, 18090, 18133, 13740, 146607, 12399, 15336, 12786, 13778, 12833, 19096, 19878, 19964, 19881, 147631, 19624, 19450, 19433, 1712, 13278, 15905, 145086, 18885, 14142, 13835, 16084, 15378, 145085, 12546, 11695, 12715, 22269, 19394, 20226, 19203, 14515, 21387, 159298, 19682, 14538, 15829, 13853, 13149, 146809, 21961, 10713, 14444, 14148, 12200, 18328, 19286, 19206, 15618, 15840, 18347, 16068, 137823, 16324, 11284, 137824, 24994, 18514, 20087, 21354, 16114, 137825, 18518, 137826, 14129, 18271, 12827, 17904, 13646, 10578, 15253, 13679, 12627, 12167, 15466, 10757, 14241, 11145, 14555, 11939, 11188, 13204, 15624, 10567, 12801, 10556, 12247, 16015, 16946, 14011, 11138, 13417, 17912, 11688, 11486, 12480, 15898, 18859, 21790, 15145, 14949, 13754, 19143, 10662, 14654, 10872, 10870, 13720, 18552, 145089, 18489, 146009, 18549, 18603, 11378, 17801, 16369, 20499, 13702, 11168, 15726, 14922, 19953, 17634, 12049, 12315, 12532, 145095, 20335, 15696, 17229, 12978, 14440, 14365, 19106, 16979, 18329, 146533, 22340, 19391, 19378, 11413, 145097, 18330, 17824, 16584, 17738, 16702, 19221, 21061, 21094, 21444, 15845, 19977, 19219, 19225, 16616, 14590, 16018, 14999, 12121, 12460, 12343, 16117, 13843, 17843, 19148, 17395, 147346, 11154, 146661, 21793, 21649, 20510, 13673, 12824, 11229, 11457, 11121, 12530, 16253, 11450, 16726, 16229, 146656, 10836, 10852, 16099, 15563, 147634, 14740, 13790, 13976, 18606, 17952, 18107, 145099, 15134, 14751, 13542, 146534, 13048, 16606, 16600, 19090, 12898, 14316, 21007, 21362, 20388, 20457, 19060, 21700, 12589, 11210, 13457, 16196, 12249, 16947, 16675, 14615, 10665, 146657, 14952, 13759, 19056, 20314, 12362, 13523, 10752, 12968, 16848, 142080, 11882, 15533, 13170, 11733, 12149, 145247, 12163, 13455, 12975, 15936, 13655, 17181, 16078, 13773, 16283, 15987, 12726, 19703, 12705, 17323, 15200, 13178, 13677, 16757, 17102, 10545, 10676, 15286, 146856, 16029, 15871, 16341, 11085, 15095, 11749, 11568, 146535, 12331, 16697, 18355, 14753, 16186, 12276, 16386, 13660, 18074, 16556, 22801, 20178, 22692, 22360, 21682, 20894, 20895, 20984, 20624, 20299, 20592, 19982, 21509, 19882, 19847, 19317, 19585, 18078, 17836, 17543, 18498, 18482, 17808, 18261, 147635, 22194, 22451, 20606, 22372, 22251, 21592, 20702, 20648, 20266, 20100, 20097, 19873, 20071, 19911, 19710, 19561, 146536, 19588, 18971, 18601, 17504, 18159, 18189, 16571, 16574, 18321, 20971, 21598, 147636, 21714, 21722, 21027, 21262, 20948, 20374, 20295, 19967, 20001, 19738, 19716, 19648, 19002, 18406, 18381, 18016, 19223, 17647, 11421, 22842, 22972, 22799, 21584, 22704, 22186, 22254, 20973, 21864, 21051, 20825, 21272, 21547, 20544, 20588, 19472, 18883, 18784, 18171, 18624, 146537, 17858, 11448, 17817, 147437, 17497, 22780, 21084, 20242, 22650, 22651, 21539, 21647, 21363, 21149, 20678, 20644, 20543, 19744, 19754, 19463, 19477, 19094, 18305, 14926, 18408, 16532, 18148, 13372, 17683, 22552, 21100, 21428, 21426, 10703, 11051, 20358, 20216, 20083, 20631, 15300, 20432, 20705, 20003, 19727, 19475, 12219, 13002, 14310, 11109, 16533, 12043, 12861, 12859, 14448, 146241, 15282, 11507, 15914, 18372, 18884, 19632, 21994, 21977, 20304, 18849, 14833, 11552, 13988, 13616, 146662, 20410, 21995, 20993, 16825, 147684, 20043, 18759, 18800, 14418, 12273, 17554, 17576, 12074, 11304, 11311, 12304, 14804, 11599, 11060, 146858, 18474, 15583, 13146, 20763, 19207, 18910, 19029, 15626, 15865, 15233, 13663, 15258, 13456, 16328, 18445, 15052, 14595, 146540, 11194, 17295, 16082, 16151, 16115, 17011, 15211, 139138, 13984, 20361, 147685, 21103, 19210, 18682, 18683, 18379, 11867, 18432, 147831, 14063, 16248, 18715, 146639, 22530, 22019, 21851, 21698, 20892, 20901, 20845, 20838, 21028, 21410, 20968, 20626, 18918, 18094, 10391, 146859, 16127, 14467, 146743, 21873, 19922, 20850, 21450, 21122, 21205, 20095, 19926, 19186, 12327, 15056, 15290, 16268, 16370, 147732, 11804, 16172, 20107, 22448, 21806, 19430, 16344, 14569, 147733, 17459, 10544, 21388, 21085, 19289, 19252, 21601, 12813, 11502, 14649, 13603, 13141, 12624, 10878, 13961, 11961, 15230, 16963, 17350, 14052, 22561, 20599, 22293, 22411, 22277, 22648, 19920, 19726, 19775, 21579, 18790, 18795, 18845, 14835, 14162, 12503, 18417, 12926, 12262, 21604, 17784, 10590, 11555, 20646, 22545, 22420, 22412, 21794, 21491, 145688, 20401, 20252, 21540, 19309, 19675, 19003, 13064, 18015, 17146, 15492, 16463, 15531, 14723, 15342, 16242, 11567, 10298, 14861, 13288, 11884, 15627, 15194, 10586, 147438, 12394, 10537, 146860, 11269, 15877, 12143, 13572, 10538, 22179, 13787, 13800, 15371, 14549, 18954, 16561, 12555, 14138, 16418, 13474, 15751, 15648, 15640, 15638, 15651, 15671, 15698, 146861, 16580, 15976, 15216, 10828, 13159, 14424, 21583, 19923, 19621, 18768, 16497, 16552, 14764, 12197, 10804, 15070, 11326, 14347, 145098, 13978, 17050, 11329, 15456, 14927, 14077, 10830, 17307, 14779, 14427, 22980, 20177, 146544, 15382, 18193, 14321, 13060, 13783, 12456, 10631, 11249, 12029, 15538, 16182, 15534, 10714, 11760, 139897, 11245, 14139, 10760, 11678, 22672, 23002, 20822, 21225, 19290, 19659, 15964, 11248, 146545, 14140, 14421, 14025, 13100, 13743, 12952, 15313, 13776, 13360, 12175, 15185, 16192, 16076, 12674, 14739, 15945, 11084, 13105, 13764, 14733, 15245, 17035, 11141, 14102, 12582, 146665, 10566, 11574, 15222, 13036, 12966, 18281, 17360, 17792, 17889, 17621, 22028, 22272, 20848, 20928, 19402, 21031, 21129, 18200, 18778, 18777, 18718, 18262, 17593, 17886, 22273, 146666, 22320, 22107, 21818, 20808, 22065, 21012, 21177, 20385, 21535, 19961, 19780, 19785, 19709, 19527, 19404, 19439, 19536, 19408, 19448, 19493, 17819, 18382, 18433, 18291, 17773, 16696, 12069, 15675, 13869, 22881, 20467, 22827, 22523, 22181, 20826, 21266, 20960, 20219, 21010, 20575, 20154, 20583, 20155, 19892, 21859, 12045, 12618, 18380, 18118, 14510, 12540, 16553, 147441, 16005, 15652, 16576, 19173, 12797, 14472, 13075, 15886, 14092, 13849, 13847, 12223, 15477, 12359, 144439, 13380, 14646, 12447, 16875, 147524, 15479, 15603, 14062, 15197, 14546, 16138, 12508, 20330, 15924, 13713, 12689, 14455, 11506, 11584, 11446, 17795, 10886, 16378, 11963, 12946, 17707, 16627, 15296, 14718, 16251, 16695, 15364, 10957, 18979, 18654, 18772, 18122, 17703, 18688, 18540, 11857, 18019, 18256, 17210, 16613, 16055, 16375, 17900, 17243, 16085, 11537, 16355, 20695, 21743, 20930, 17085, 20696, 20587, 19525, 11267, 11016, 12358, 11309, 10984, 10975, 16343, 10983, 11231, 17088, 10893, 14205, 18668, 11866, 16399, 17579, 17560, 18284, 11026, 14314, 10913, 17894, 10806, 13158, 16023, 11296, 19763, 12511, 13214, 12994, 11916, 12564, 15305, 10876, 11018, 13915, 17988, 18745, 17842, 17575, 18875, 18244, 22816, 20165, 21988, 21338, 20392, 19807, 17544, 17547, 17320, 18547, 17846, 15557, 17211, 13760, 15092, 15968, 17075, 11687, 13345, 13083, 12406, 12206, 13414, 11143, 11142, 12890, 19578, 146675, 13486, 12805, 11477, 16249, 13732, 12278, 15201, 15543, 15204, 14208, 15288, 14636, 13891, 15857, 15790, 17267, 15791, 14078, 19236, 16520, 15986, 13887, 16234, 139436, 16238, 15504, 13769, 17314, 17469, 17803, 22729, 21339, 19567, 11023, 18409, 18564, 18741, 18931, 14368, 20573, 22494, 22587, 22369, 21805, 21367, 20272, 139454, 20061, 19045, 20030, 18841, 18978, 14726, 145658, 16752, 14997, 148286, 14626, 15997, 16909, 14442, 146714, 146744, 14372, 15424, 11073, 12854, 14588, 16314, 17776, 17352, 17751, 19070, 17369, 16373, 18681, 146642, 11344, 16594, 146780, 21874, 21723, 20889, 146374, 19025, 145100, 17875, 16436, 12724, 17216, 17838, 21809, 17170, 17854, 139458, 18713, 12023, 145160, 17921, 21659, 21207, 20091, 145930, 11715, 145204, 17919, 147776, 20102, 18253, 18186, 12739, 16984, 144935, 20060, 13648, 15484, 11747, 144852, 14445, 20080, 12763, 144936, 15843, 15396, 13779, 10247, 145659, 15373, 15076, 10637, 10481, 10328, 12099, 11328, 20081, 11675, 145660, 13697, 12277, 10606, 20750, 19660, 12275, 12104, 146676, 12280, 12274, 12466, 12605, 14540, 147493, 14020, 12573, 15971, 16105, 14797, 16776, 16787, 13145, 16551, 18191, 14410, 13741, 14461, 16643, 144937, 14245, 13724, 16303, 16301, 16423, 13758, 20431, 16153, 15461, 16381, 146781, 138192, 21395, 19836, 20082, 18285, 11485, 18270, 18259, 145203, 10633, 147494, 146700, 14302, 17968, 17870, 12866, 138022, 14200, 19034, 22607, 21701, 21831, 20879, 21023, 19787, 19291, 18782, 12830, 10623, 12963, 13277, 15148, 14479, 14721, 23730, 18645, 18385, 18604, 17558, 12737, 16462, 18924, 17171, 146011, 145164, 18724, 22238, 21557, 21279, 17002, 18858, 12632, 13423, 10647, 10794, 146284, 11498, 11557, 12631, 10608, 12179, 15088, 12909, 13683, 13032, 16016, 11322, 15295, 14905, 14543, 11660, 16733, 14736, 12162, 10705, 15793, 14040, 10778, 11268, 10315, 12201, 147699, 13750, 11135, 13172, 11890, 12796, 12198, 11720, 13671, 10536, 12790, 14774, 14231, 10382, 10700, 12925, 11483, 15339, 15623, 13219, 13593, 16212, 15923, 13749, 12146, 145465, 13493, 11784, 14529, 14531, 15360, 15359, 15653, 13911, 22940, 13975, 19188, 145661, 17796, 18030, 16407, 13203, 16945, 13244, 16354, 139708, 12489, 13006, 14901, 16419, 14091, 18168, 13665, 15649, 15662, 17186, 15687, 15656, 15659, 146830, 22936, 21778, 15660, 15661, 15633, 15643, 15645, 15439, 15762, 15689, 15578, 15575, 11919, 15570, 15684, 17877, 14551, 17505, 16255, 13014, 14917, 146831, 20267, 10817, 10699, 10081, 12712, 12598, 14674, 17840, 15497, 14187, 15111, 11131, 14818, 20337, 22805, 22090, 21686, 20166, 21035, 20174, 12336, 15289, 16183, 15985, 15262, 12245, 14286, 13640, 18617, 17334, 147501, 16162, 10943, 12214, 145466, 15901, 14413, 16281, 12283, 15208, 20956, 19801, 16227, 11153, 15487, 10769, 14247, 14738, 12736, 147495, 139619, 16205, 13077, 16999, 21216, 16298, 16786, 147650, 20851, 16258, 12889, 13187, 17197, 15754, 14613, 17212, 13169, 11685, 147496, 12910, 16872, 13426, 10625, 15303, 17305, 18170, 15045, 12426, 16187, 19426, 14081, 14561, 18775, 17367, 18404, 16542, 18388, 17529, 147497, 18416, 140038, 18952, 17582, 18587, 137899, 21452, 22483, 22287, 22308, 21580, 21959, 20282, 19827, 19984, 17530, 17862, 17855, 17507, 17518, 17541, 17807, 17901, 21549, 20693, 22032, 21377, 17995, 20682, 19845, 19778, 19541, 19187, 18698, 18591, 17826, 17864, 147693, 18527, 22939, 22962, 22855, 20559, 22781, 21526, 20882, 21268, 21148, 20951, 20578, 20273, 20077, 139624, 19742, 19767, 19340, 18828, 17466, 18032, 147777, 17702, 147498, 137909, 138187, 11225, 18196, 10963, 11366, 13209, 15673, 145461, 22396, 19966, 19960, 20038, 19729, 19337, 19166, 15714, 15795, 6389, 145664, 137857, 15796, 147778, 146705, 137844, 137845, 137846, 137847, 137910, 24549, 24793, 24501, 137848, 137850, 137851, 137858, 28872, 137860, 147499, 137904, 137872, 137875, 6103, 137862, 137854, 137880, 144297, 137863, 137866, 137868, 137870, 137869, 146706, 137864, 139337, 137882, 137885, 145665, 137936, 145666, 33011, 137934, 145206, 137937, 144902, 137941, 146012, 137958, 137954, 137959, 145767, 137952, 138127, 146832, 36079, 138007, 138010, 138011, 138012, 138018, 138008, 138026, 145667, 138041, 145668, 127645, 137974, 137979, 137977, 137982, 137991, 137995, 138016, 138088, 138020, 138047, 138021, 138023, 138051, 138027, 138032, 138040, 138033, 138029, 138256, 138048, 138036, 138044, 147500, 138042, 146014, 138043, 138045, 138049, 138050, 138053, 138054, 138056, 148290, 39896, 138059, 138061, 139559, 138068, 138062, 138063, 138065, 138066, 138124, 138113, 138073, 138241, 137985, 138070, 138075, 138076, 138176, 138069, 138077, 138078, 146936, 138092, 138121, 138122, 138261, 138119, 145511, 138080, 138082, 137774, 138097, 145669, 138095, 138093, 138096, 138091, 138175, 138094, 138125, 138130, 145766, 144305, 35152, 138109, 146030, 138136, 138106, 138107, 138116, 148291, 138327, 138114, 138108, 145554, 138102, 146707, 138100, 138182, 138101, 138099, 139889, 138126, 138129, 138110, 138115, 138137, 138111, 138234, 138118, 138120, 139184, 138146, 138214, 146450, 138159, 159162, 138123, 138128, 138132, 138134, 138135, 138209, 138199, 138152, 140040, 138138, 138223, 138139, 145121, 138163, 138268, 138213, 138140, 138141, 138143, 138144, 138131, 138147, 138148, 147197, 138170, 138181, 138267, 138149, 138153, 138848, 138166, 138154, 138161, 138167, 138168, 145548, 138155, 138221, 138180, 138356, 138173, 138210, 145670, 139827, 146451, 138158, 138806, 138160, 138162, 138165, 145125, 138246, 138169, 138195, 138196, 138307, 138172, 138186, 146452, 138198, 34576, 140753, 138183, 138174, 146708, 138228, 138266, 138185, 138201, 139869, 138177, 146453, 138178, 138179, 138188, 138194, 138211, 138189, 138190, 138193, 138231, 138200, 138311, 138220, 138851, 138197, 138207, 138244, 138208, 145671, 138212, 138216, 138559, 138217, 138232, 138496, 138218, 138219, 138275, 138222, 138224, 138225, 138226, 138243, 138802, 138704, 138291, 138239, 145931, 42687, 138229, 138315, 138301, 138242, 138263, 138230, 147047, 138250, 138235, 138236, 138237, 138238, 138240, 138245, 138262, 143498, 138265, 145883, 138249, 138248, 138270, 138254, 138251, 138252, 138253, 138255, 145672, 138257, 138706, 140036, 138258, 138259, 138260, 138279, 138269, 138271, 138284, 145276, 138272, 138292, 138273, 139587, 138281, 138274, 138276, 138856, 138277, 138317, 138278, 139171, 138330, 138459, 138280, 138306, 138282, 138285, 138286, 138403, 145170, 144776, 138287, 138288, 138987, 138289, 138853, 138294, 138290, 138302, 138377, 138321, 138316, 138296, 138429, 138303, 138978, 138295, 138297, 138338, 138299, 138304, 138293, 146833, 138314, 138320, 139710, 146550, 138322, 138323, 138332, 138337, 138407, 141673, 158556, 138353, 138395, 138396, 138346, 138367, 138331, 138729, 138325, 138329, 138738, 138376, 138354, 138333, 138342, 138335, 138339, 138340, 138336, 138341, 138355, 138363, 146782, 138369, 138728, 138408, 139060, 138343, 138347, 138350, 138352, 138357, 138358, 138359, 138370, 138366, 138361, 138772, 138386, 138388, 139567, 144838, 146709, 138375, 138380, 145208, 146062, 138381, 138389, 138446, 138445, 138397, 138384, 138385, 147502, 146710, 138387, 138398, 140494, 138394, 147696, 138400, 138399, 139115, 138402, 138418, 146167, 138404, 138540, 139119, 138409, 138450, 138426, 138453, 138536, 138411, 138415, 138586, 138412, 138422, 138417, 138492, 146711, 138420, 138421, 138565, 138447, 11271, 138431, 138438, 138473, 138433, 138440, 139275, 138443, 147503, 138427, 138520, 145209, 138444, 138449, 138454, 138482, 138589, 138484, 138526, 138485, 138488, 138531, 145211, 138452, 138543, 138463, 138464, 138458, 138462, 138460, 138465, 138808, 138471, 138494, 138539, 138466, 138468, 138467, 138413, 145679, 139197, 138477, 139196, 138475, 139276, 138486, 138511, 138534, 138487, 138489, 138476, 138497, 138493, 138778, 138522, 138567, 138637, 146712, 138499, 140291, 138523, 138587, 138854, 138544, 138895, 138498, 138503, 138528, 138767, 138506, 138507, 139129, 138512, 138514, 138535, 138541, 138517, 138518, 138519, 138545, 146263, 138530, 138804, 138547, 139145, 138533, 138542, 138537, 138585, 145675, 138549, 141563, 138550, 138164, 145280, 147694, 159299, 138546, 138117, 145470, 138564, 138548, 144841, 138593, 138631, 146244, 138594, 145936, 138383, 142274, 138845, 138560, 138554, 138556, 138590, 138558, 138557, 19126, 138555, 138563, 138501, 138562, 138571, 145937, 147883, 138570, 138572, 138574, 159300, 138575, 144583, 138584, 138582, 139046, 138576, 146551, 138578, 138157, 23575, 139303, 138580, 138013, 138583, 138645, 138378, 26235, 145266, 138581, 145677, 138595, 146552, 138592, 138596, 159301, 138030, 138455, 138921, 32873, 138649, 139215, 138597, 139216, 145998, 137849, 159307, 138428, 138028, 138435, 138430, 139072, 138457, 138633, 21501, 140446, 138432, 138712, 138437, 138442, 138448, 138451, 138656, 147697, 141314, 21692, 21788, 19277, 138046, 138461, 138470, 138481, 138490, 159294, 138491, 138646, 138647, 138393, 138504, 138598, 138508, 159297, 140434, 138513, 138599, 146553, 138510, 138600, 138602, 140046, 138603, 138401, 145682, 138702, 145938, 144238, 138768, 146554, 138521, 138525, 138368, 138705, 138532, 138529, 138392, 138434, 138655, 138405, 138406, 22912, 22867, 140628, 138410, 138652, 137935, 138568, 145997, 138414, 21957, 139530, 138423, 138419, 138605, 138606, 138653, 139075, 138561, 138849, 146834, 146555, 159235, 138663, 138424, 138104, 137871, 137836, 138639, 137940, 138348, 138283, 138654, 147698, 138604, 138072, 137830, 138636, 138103, 138607, 138566, 159321, 144847, 146715, 137873, 146556, 137831, 138227, 137840, 138625, 138703, 145680, 137853, 138191, 23666, 140372, 138553, 137839, 145347, 36667, 137827, 137856, 138629, 21958, 138551, 137828, 137833, 139187, 137835, 138627, 137837, 138264, 146212, 146716, 138416, 138037, 139052, 138725, 138608, 138382, 138638, 138456, 142309, 138664, 138479, 138672, 138480, 139123, 138668, 138474, 138573, 138624, 138623, 138665, 140559, 138673, 146717, 138483, 138379, 138469, 138632, 139068, 138390, 138524, 138643, 140570, 146718, 138642, 138640, 8104, 138641, 138650, 138648, 138662, 138846, 138674, 138675, 138676, 138724, 138680, 138678, 138679, 138677, 138684, 138814, 138688, 27593, 139087, 138693, 138696, 138694, 138695, 14268, 138701, 138783, 138714, 138720, 138719, 138723, 139098, 124818, 138764, 145183, 138733, 138781, 138731, 138753, 138732, 138735, 138737, 138736, 138730, 11315, 138746, 21826, 140606, 138747, 138790, 138748, 138762, 138749, 25355, 138763, 138775, 138765, 138776, 138771, 138774, 138769, 140079, 138799, 139384, 138796, 138785, 138912, 138780, 138813, 140242, 138782, 138792, 139113, 138795, 138803, 138817, 138819, 138841, 138847, 31889, 145210, 138855, 139094, 147207, 139760, 139154, 138858, 139037, 138862, 145245, 138863, 146281, 138869, 138903, 145213, 138864, 32163, 139262, 138919, 139168, 138871, 139150, 138877, 138884, 146719, 138870, 138882, 138929, 138908, 138873, 138918, 139233, 159311, 138886, 138885, 146720, 138888, 139292, 138913, 139015, 145550, 138932, 138923, 138924, 138925, 138926, 138927, 138928, 138950, 139023, 139024, 139767, 138930, 138934, 139047, 138935, 138933, 138936, 138937, 138943, 141575, 139204, 139238, 139021, 138976, 139012, 145215, 34111, 139026, 139031, 139027, 139267, 139028, 139033, 139030, 145684, 159315, 23563, 139025, 148292, 139036, 126272, 139239, 139043, 142978, 139034, 141033, 139039, 139210, 139035, 139041, 139053, 139054, 139182, 139050, 139070, 139084, 139088, 139165, 139065, 139104, 145349, 139174, 139093, 139131, 145298, 159322, 141129, 139045, 139048, 139056, 139057, 139059, 139067, 139063, 139114, 139066, 146643, 139809, 139139, 139502, 139076, 139071, 147093, 139074, 139194, 139078, 139081, 139102, 139103, 139086, 139118, 146644, 146648, 139398, 139077, 139096, 139080, 146721, 139141, 139135, 139111, 139126, 139107, 139112, 139136, 139132, 139083, 139085, 139097, 139101, 139110, 139120, 139108, 139105, 159324, 142215, 13429, 18597, 139121, 139117, 139116, 139128, 139169, 139142, 139137, 138098, 139140, 139180, 139143, 139189, 144839, 139181, 9574, 139144, 146646, 139241, 139151, 139147, 147142, 139166, 139738, 139195, 139146, 139149, 139155, 139156, 139157, 139253, 139190, 139839, 139205, 139191, 139160, 139167, 139161, 139158, 139162, 139164, 139172, 139173, 139178, 139202, 139203, 139370, 139237, 139175, 139176, 139193, 139192, 147884, 139211, 139198, 139497, 139199, 139209, 139201, 139278, 145699, 139206, 145371, 146722, 139207, 139208, 140557, 139269, 139212, 139213, 139280, 139847, 139229, 3484, 139224, 139217, 139235, 139226, 139218, 139242, 140899, 139225, 139264, 139219, 139221, 139222, 139223, 142478, 139328, 140241, 139228, 139245, 139243, 139232, 139227, 139234, 139244, 139285, 139231, 140767, 139246, 139259, 139247, 139527, 139249, 139260, 139250, 139251, 139252, 139703, 139261, 139255, 139256, 139257, 139258, 139263, 142944, 139268, 139270, 139271, 139272, 139273, 147211, 139277, 139274, 139279, 139282, 139283, 139284, 139474, 139287, 139288, 138552, 140857, 139293, 139413, 142278, 139294, 139300, 139296, 145348, 139339, 139295, 139385, 139297, 139323, 139504, 139325, 139298, 145182, 139301, 139302, 140146, 139315, 139306, 139305, 144843, 139484, 139310, 139313, 139330, 139440, 139309, 139311, 146557, 139491, 139372, 144856, 139375, 135837, 139348, 141011, 139314, 139340, 139341, 139443, 139476, 146558, 139595, 124741, 139318, 145300, 139317, 139321, 139320, 139322, 146282, 139350, 139338, 7840, 139344, 139329, 139331, 139335, 139374, 144844, 139354, 139355, 141008, 139333, 139334, 139336, 147567, 139367, 139342, 139377, 145686, 139347, 147143, 139573, 139349, 139346, 139613, 139368, 139508, 145499, 139446, 139353, 139357, 147894, 140860, 139356, 139369, 144845, 144846, 139380, 139433, 142440, 139381, 146283, 145351, 139444, 139371, 139410, 139358, 139359, 139365, 139364, 139360, 139362, 139363, 139543, 144848, 139366, 140087, 139382, 139386, 139387, 139392, 139400, 139404, 139401, 140225, 144849, 140877, 139405, 139408, 139435, 141089, 139402, 139186, 139393, 139394, 139395, 139390, 139397, 139472, 146613, 159331, 141067, 139399, 139496, 139406, 139403, 139388, 139411, 139414, 139422, 139426, 139416, 139420, 140500, 139415, 139418, 139424, 139507, 139468, 139423, 139434, 139572, 139467, 139570, 145353, 139419, 139735, 139425, 139438, 139506, 139511, 146724, 139452, 139437, 139427, 139430, 139480, 139431, 139432, 139486, 140235, 139429, 139489, 139439, 139441, 139453, 139451, 139442, 139571, 147144, 139549, 145691, 141685, 145307, 159326, 139450, 139611, 139460, 139503, 139456, 139471, 139470, 145311, 139457, 145373, 139459, 139461, 139566, 146725, 139485, 139475, 145406, 139463, 139469, 139465, 139477, 139487, 139479, 139482, 139478, 139523, 142139, 139483, 139492, 139481, 139490, 139546, 139495, 145551, 141210, 139493, 139498, 139568, 139488, 139592, 139509, 139499, 139494, 139524, 139533, 139525, 145352, 139501, 139564, 139516, 139518, 139517, 145029, 139512, 145214, 139574, 146677, 139513, 139515, 139520, 139417, 139534, 139531, 139529, 139445, 139522, 139532, 139526, 139538, 145802, 139541, 139537, 145308, 139200, 145355, 139544, 139547, 139617, 139536, 139545, 139542, 147145, 2690, 139731, 139539, 139548, 139600, 139554, 139555, 145309, 139556, 139557, 147885, 139561, 139562, 139236, 139563, 139565, 140086, 139558, 139582, 139575, 139601, 145310, 139560, 139583, 141058, 139578, 140083, 139579, 139577, 139576, 139585, 140073, 139591, 139163, 139598, 139594, 139447, 139586, 139590, 139588, 139589, 139615, 139707, 139407, 146061, 139596, 145972, 146678, 139599, 139603, 139608, 139618, 139900, 139612, 139473, 138779, 139826, 145687, 139614, 146726, 138716, 139771, 141684, 145396, 146679, 139327, 139604, 139605, 139607, 139616, 139609, 139610, 146727, 139220, 140085, 138750, 139593, 139628, 145357, 139550, 139636, 141001, 139345, 139637, 138726, 139510, 139265, 138794, 147886, 139756, 139960, 139500, 139352, 147146, 160556, 138611, 139466, 139122, 138727, 139635, 139724, 139722, 145358, 159328, 139332, 145589, 139505, 139281, 141059, 145359, 139514, 139307, 139291, 141381, 138791, 138818, 139051, 139725, 140024, 139055, 139064, 139109, 139698, 139519, 139069, 139134, 139770, 138920, 145250, 139106, 139886, 159342, 141390, 139606, 144651, 139625, 139289, 139553, 139528, 145217, 139535, 139062, 141753, 139580, 145776, 138634, 141316, 139552, 139378, 140069, 138938, 160624, 147196, 139125, 139248, 139720, 145607, 139082, 145176, 140571, 159329, 159455, 141408, 139684, 146730, 139179, 139148, 139622, 139409, 147147, 139718, 139728, 139727, 139022, 147194, 141525, 138788, 139464, 141706, 139304, 139709, 139633, 139730, 139690, 145608, 159332, 146395, 141529, 139630, 145807, 139597, 138142, 18277, 147195, 38689, 139705, 145173, 139632, 139879, 159364, 139685, 141301, 138931, 139702, 140029, 139623, 139343, 139396, 139683, 139759, 139626, 139629, 141449, 139631, 139634, 139807, 139639, 139638, 138014, 141632, 146731, 139686, 139687, 139688, 140269, 139319, 138815, 139706, 139732, 147887, 100076, 139808, 138052, 139766, 139696, 139695, 139691, 139692, 139689, 139699, 139694, 147888, 139712, 139704, 143119, 139713, 139714, 139773, 139715, 139716, 139729, 139758, 140923, 146029, 139751, 139747, 139741, 139752, 139762, 139742, 139743, 145705, 139744, 139754, 146740, 139745, 139753, 141084, 144775, 140425, 139746, 139755, 139748, 139877, 139749, 139750, 139765, 139761, 139768, 139764, 139763, 139769, 142247, 139774, 145690, 139772, 142903, 139775, 139834, 127875, 139740, 139787, 139778, 139782, 139780, 139863, 139817, 142445, 139785, 140928, 139925, 140044, 139794, 139781, 139783, 20009, 139789, 139788, 139790, 139791, 139797, 139798, 139793, 139795, 139890, 139814, 139804, 139792, 139800, 139799, 139803, 139837, 11411, 139818, 143187, 139806, 144301, 138860, 139849, 139805, 139815, 139816, 139812, 139813, 139842, 139829, 147889, 144823, 139880, 139846, 144003, 139833, 159388, 139819, 139821, 139822, 139824, 142915, 139840, 139903, 139823, 141574, 139831, 139832, 139836, 139835, 3539, 139838, 141437, 139920, 139854, 139240, 139853, 139254, 139921, 145360, 140929, 142665, 139923, 139884, 139862, 139860, 141302, 139857, 139858, 141460, 141675, 141576, 142271, 147504, 139918, 139866, 139895, 139875, 139885, 139867, 139870, 141687, 140837, 141577, 139874, 146205, 145372, 145363, 139924, 139878, 139882, 139881, 141578, 141677, 139888, 140308, 139899, 139902, 140050, 139892, 139901, 139893, 139898, 140020, 140012, 139927, 139928, 139929, 139883, 140043, 146741, 141579, 141678, 139905, 139907, 139917, 141679, 140973, 139951, 139908, 139910, 147505, 139919, 140003, 141681, 139942, 139943, 139944, 139939, 145882, 141992, 140005, 139991, 140023, 139950, 139947, 139961, 139989, 139962, 146742, 139958, 139965, 139955, 141680, 139966, 139987, 144910, 139967, 139969, 140032, 139972, 146206, 139968, 140033, 139982, 139976, 140016, 139978, 140006, 140039, 142423, 139983, 145365, 139979, 140627, 146057, 139980, 139984, 139986, 139990, 140345, 139985, 140010, 139993, 140025, 140027, 139801, 140035, 139994, 140002, 140530, 139997, 140001, 140000, 140014, 140654, 140017, 140098, 139926, 140015, 140008, 140018, 140019, 138770, 140022, 147198, 140042, 140030, 140031, 140041, 139937, 140076, 140061, 142175, 140099, 140113, 139856, 139931, 139934, 140088, 140090, 146745, 139909, 140993, 139844, 139935, 147890, 145812, 140070, 140072, 140967, 139933, 140074, 140071, 140077, 140075, 140081, 146746, 140504, 140092, 140082, 145813, 140106, 140111, 140110, 141459, 140930, 140080, 140100, 140218, 140122, 140123, 141566, 140147, 140204, 140315, 140121, 145781, 140142, 142176, 140128, 140205, 147506, 140130, 140936, 145108, 141699, 141754, 141756, 141755, 140155, 147748, 140134, 140135, 140869, 140314, 140143, 147199, 140327, 140145, 140192, 140174, 141689, 141700, 140964, 141567, 140149, 140215, 140295, 140153, 140162, 140769, 140157, 140231, 140159, 140267, 140938, 140966, 141568, 141133, 142656, 140169, 141078, 141572, 140173, 140172, 140213, 140165, 140171, 147381, 145299, 141569, 141690, 140176, 140178, 141571, 140179, 145480, 139736, 140420, 140202, 145692, 139946, 140360, 141570, 140221, 141097, 144896, 141692, 140184, 140183, 146208, 140208, 140197, 140190, 142905, 140243, 140212, 142898, 140224, 147200, 140219, 140181, 140193, 140200, 140210, 140216, 140223, 140237, 140239, 140238, 140240, 140233, 140232, 140572, 140260, 145694, 145302, 140227, 140234, 141548, 140255, 140229, 140258, 146209, 145814, 140574, 140246, 141539, 140298, 140339, 145525, 141538, 139971, 140278, 140274, 146752, 140516, 140290, 140280, 144086, 141056, 140294, 140276, 140279, 140337, 145174, 140328, 141537, 140281, 145957, 140296, 140292, 140282, 140313, 140283, 140329, 140286, 140284, 140304, 140287, 140288, 140348, 140303, 140297, 145693, 140293, 141179, 140300, 140301, 146210, 140302, 146753, 140311, 140306, 140316, 140341, 140382, 140305, 140310, 140312, 140537, 140307, 140583, 140320, 146754, 142273, 142276, 140340, 140335, 140318, 140402, 147201, 140325, 140324, 140326, 140330, 140321, 146755, 140332, 140972, 140323, 140319, 142275, 140331, 140336, 140338, 141183, 147202, 142431, 140342, 145301, 140343, 140344, 142071, 140346, 140349, 140333, 140352, 142470, 140374, 144908, 147203, 140381, 140347, 140353, 140350, 140703, 146756, 140207, 140351, 140383, 140354, 140398, 140411, 140384, 140248, 140369, 142513, 140501, 140253, 140371, 140256, 140357, 140358, 140263, 140266, 14553, 142467, 140361, 142394, 140273, 140359, 140362, 140368, 146757, 140373, 146211, 145306, 140299, 140309, 140385, 140366, 140365, 140409, 140367, 141186, 146758, 143039, 140375, 140376, 140377, 140378, 140380, 140379, 140387, 140395, 144916, 140437, 141450, 140407, 144898, 145303, 143727, 140390, 140389, 140392, 140396, 140394, 142449, 140393, 144642, 142902, 140399, 140866, 140428, 145531, 140400, 140401, 141009, 140404, 140408, 140403, 142451, 140405, 140410, 140429, 140412, 140413, 140444, 140415, 140423, 146226, 140424, 141095, 147892, 140414, 140417, 140426, 140421, 140418, 146593, 140419, 140422, 140427, 140904, 145356, 140430, 140431, 140443, 140433, 140435, 140441, 139058, 140454, 145497, 140484, 140455, 140486, 140436, 146213, 140439, 159333, 140440, 140474, 141710, 145473, 140442, 141546, 140666, 140665, 141504, 125651, 159335, 140447, 140466, 140456, 140476, 141091, 140448, 145025, 140478, 140449, 140450, 140782, 140451, 140485, 141541, 140740, 140545, 140453, 145474, 140452, 140461, 143011, 140469, 140468, 140519, 140472, 140470, 140463, 144054, 140457, 140458, 140460, 140462, 142618, 140464, 140465, 140467, 140473, 140479, 140482, 140475, 147508, 140483, 140480, 140680, 140924, 144768, 140481, 140710, 141438, 143111, 140495, 140487, 140488, 140489, 140490, 140518, 141543, 145222, 141544, 140497, 140496, 140493, 140499, 140515, 141730, 140755, 140533, 141477, 140554, 140505, 142994, 140507, 140506, 140784, 141035, 140509, 140510, 140553, 140511, 140512, 140513, 140416, 140655, 140514, 140521, 140736, 140649, 140523, 140558, 140525, 140517, 140531, 145598, 140528, 140564, 140578, 140526, 140534, 140552, 140674, 141361, 145524, 140535, 143025, 140562, 145815, 140536, 140539, 140540, 140391, 140541, 140555, 140548, 140573, 140544, 140922, 140547, 140546, 141046, 140550, 140551, 140927, 140549, 140679, 140556, 140150, 140900, 140925, 140584, 140563, 140565, 140569, 140597, 140613, 140592, 140640, 145526, 140568, 140566, 140561, 140567, 140581, 140580, 140576, 140582, 140602, 140600, 140588, 140590, 145367, 140657, 145569, 140587, 140591, 140652, 142769, 140996, 140656, 140593, 140594, 140596, 140598, 140601, 140603, 140641, 159336, 140604, 140635, 140658, 140659, 140605, 140611, 140615, 140663, 141294, 140609, 140607, 140668, 145459, 139711, 2774, 140637, 140639, 140651, 140650, 140614, 140661, 140765, 140617, 140619, 140671, 140618, 140542, 141004, 140543, 140621, 142998, 140633, 140634, 141229, 140757, 140560, 140575, 140667, 140107, 146215, 146216, 145366, 139830, 141094, 140577, 140585, 140673, 140788, 140766, 140595, 140677, 140675, 140754, 140620, 140678, 140676, 140459, 140140, 140682, 140681, 140683, 39842, 140702, 140632, 28075, 140910, 140699, 140911, 141087, 140714, 141012, 140705, 140692, 140684, 140763, 146759, 140687, 140686, 140688, 140748, 140746, 140689, 142338, 140747, 140932, 140955, 140696, 140691, 146760, 140697, 140693, 140694, 140933, 140700, 140752, 141051, 140759, 140758, 140711, 140712, 140912, 140704, 140764, 140761, 140730, 144899, 140739, 140706, 147208, 141439, 140664, 141102, 141505, 140787, 140723, 140722, 140786, 141018, 146783, 140725, 31741, 140720, 145134, 140715, 140716, 140717, 140783, 140785, 140772, 140970, 145695, 140731, 140732, 141252, 140734, 141053, 139891, 140906, 140771, 140760, 141433, 140777, 144900, 140776, 140719, 140406, 140744, 141759, 140913, 140901, 140982, 141096, 146761, 141017, 146217, 140775, 140861, 141047, 140778, 140498, 140864, 140943, 142279, 142213, 139868, 140859, 141516, 139810, 139737, 138312, 140047, 140355, 139948, 140616, 142509, 140849, 140850, 140851, 140856, 140940, 146218, 139757, 140028, 142572, 139852, 141098, 140871, 140492, 142277, 140853, 141080, 139861, 147507, 139825, 140718, 139938, 147509, 144907, 141424, 139940, 139723, 139930, 139992, 139701, 159338, 159339, 139865, 140779, 140780, 140503, 5059, 140880, 139152, 145501, 158990, 140356, 139095, 139299, 147209, 140882, 147568, 139693, 140026, 140892, 139796, 140013, 141019, 140774, 140180, 140890, 158991, 14887, 145370, 145696, 141300, 140589, 140579, 139802, 141020, 141315, 141105, 140916, 140285, 140790, 143196, 140773, 139855, 140289, 140520, 140898, 140917, 141014, 143154, 140690, 140477, 141077, 141022, 140522, 27100, 140883, 158992, 158993, 140907, 141320, 140491, 139974, 141003, 141204, 140953, 139786, 139828, 27559, 140893, 143198, 146762, 139876, 140334, 140902, 145153, 139904, 144903, 139988, 139739, 139700, 146763, 146764, 39903, 140985, 139851, 140887, 140188, 144922, 140939, 145368, 159341, 140946, 145697, 140895, 140445, 139998, 140894, 140068, 140885, 145369, 159356, 138300, 139887, 140170, 139999, 144904, 147212, 139779, 142659, 139551, 146775, 139953, 7326, 140954, 140884, 141049, 141039, 140175, 140438, 141057, 141284, 141313, 140532, 140792, 140793, 140397, 140868, 140867, 145175, 147213, 141279, 31429, 140862, 140863, 14704, 140817, 26787, 31436, 140905, 140920, 140888, 140897, 142379, 34577, 144912, 140872, 140873, 140921, 140874, 140876, 142632, 141281, 140879, 143185, 140908, 29260, 141282, 142130, 140941, 140944, 140948, 140947, 140957, 140952, 142666, 140956, 140959, 144304, 140960, 140961, 141126, 140971, 142512, 141354, 140978, 140980, 140981, 142511, 140977, 141015, 142183, 142390, 140979, 142214, 142280, 17944, 140999, 141040, 141355, 140881, 140986, 141010, 141667, 140370, 141086, 140984, 140989, 140998, 140997, 141002, 141007, 141013, 141016, 142432, 141174, 145568, 141141, 141142, 145216, 141064, 141021, 141023, 3900, 141177, 141071, 146264, 141502, 141366, 141031, 141027, 141032, 141025, 141024, 141036, 141028, 145700, 141038, 141026, 141041, 141043, 141044, 31661, 141090, 141146, 141175, 141088, 141153, 142529, 141256, 141061, 141139, 141143, 145178, 141112, 141150, 143356, 127901, 140858, 141062, 141054, 145791, 141074, 141255, 141066, 141068, 141488, 141554, 141082, 144906, 141069, 141073, 141072, 144226, 141108, 141445, 141312, 141148, 146321, 141138, 141115, 141145, 141666, 141117, 141137, 141152, 141199, 141123, 141124, 141122, 141119, 141151, 145908, 141128, 141140, 141135, 141132, 141193, 142047, 141130, 141134, 145388, 141178, 141187, 145701, 141185, 141184, 141295, 141157, 141259, 146784, 141290, 141154, 141158, 141662, 141167, 141169, 141228, 141127, 141159, 141156, 142090, 141234, 144911, 141528, 159353, 141190, 142919, 31553, 141287, 5356, 141163, 141171, 143020, 141168, 141166, 141170, 141173, 144785, 147928, 141195, 141194, 141196, 141191, 27213, 145909, 141215, 141262, 141261, 141144, 141260, 141660, 141205, 141200, 141201, 141206, 141209, 141243, 141280, 145910, 141283, 141235, 141211, 142418, 141208, 141248, 141249, 141219, 141276, 141245, 141959, 145392, 141214, 141218, 141220, 159350, 141222, 141958, 141274, 141268, 141221, 145567, 141223, 141225, 141446, 159443, 141224, 141737, 141983, 141291, 141265, 146393, 141239, 141241, 142006, 145587, 141253, 141254, 141263, 141311, 147214, 141257, 141258, 142242, 145950, 141266, 141267, 141289, 141292, 141293, 141269, 141270, 141277, 141271, 145364, 141278, 141272, 141273, 146394, 141275, 141285, 141286, 141299, 141288, 146776, 141296, 142193, 145201, 141297, 141298, 141369, 141304, 141305, 145951, 141319, 141306, 141317, 141307, 141309, 141318, 141310, 141462, 141473, 141337, 141565, 141321, 141326, 142880, 141329, 141322, 141323, 141324, 141486, 148263, 159351, 143620, 141325, 143545, 141561, 145839, 141327, 141330, 141334, 141332, 141367, 141331, 141752, 141333, 144913, 141336, 141456, 141338, 141792, 141346, 141339, 141340, 141341, 141342, 146777, 141344, 141345, 145588, 143629, 141527, 141347, 141348, 141654, 141349, 141479, 141359, 141350, 141360, 141351, 141352, 141356, 141357, 141358, 147215, 141520, 141362, 141363, 141655, 145535, 141364, 141467, 141365, 141370, 141420, 141728, 144914, 145763, 141372, 141468, 141373, 141374, 141375, 141376, 141417, 146778, 141512, 145491, 141377, 141480, 141383, 159366, 159369, 141394, 145028, 141386, 141378, 141421, 141379, 142013, 141425, 145490, 141380, 141481, 141432, 145579, 141711, 147749, 141382, 141384, 141469, 141422, 141447, 145472, 141427, 144915, 141482, 141483, 141496, 141387, 141389, 141435, 141472, 145496, 141485, 145952, 159015, 141388, 141392, 141395, 141396, 141397, 141453, 141454, 141455, 145572, 141526, 145532, 141398, 144918, 141400, 141470, 141401, 141466, 141436, 141444, 141465, 143547, 143802, 148094, 141402, 141564, 144227, 141403, 141428, 141405, 141410, 141461, 141440, 141463, 141407, 141471, 141411, 141426, 141429, 141430, 142323, 141413, 143828, 141416, 141414, 141443, 145764, 141415, 141419, 141557, 141418, 141448, 141423, 141458, 158693, 141434, 141555, 141475, 141503, 142258, 141500, 141487, 141484, 141230, 141489, 141491, 141492, 143597, 141521, 141498, 141494, 141493, 141499, 141659, 141495, 141549, 141501, 142456, 141522, 141702, 141517, 144878, 141531, 141532, 141530, 141559, 145590, 141545, 146396, 143839, 141695, 142847, 147750, 141573, 141556, 141550, 141552, 141553, 141560, 141562, 141558, 145999, 141638, 141065, 145703, 145019, 141739, 146920, 142106, 145920, 141669, 142128, 141987, 141633, 142840, 141953, 141842, 9408, 142707, 145652, 141704, 145704, 141664, 145604, 141644, 142072, 142180, 141642, 141670, 141703, 141696, 141637, 141635, 141636, 145224, 147216, 141641, 145196, 141665, 142657, 142667, 142435, 141682, 141409, 141697, 141202, 141640, 142236, 141806, 142201, 142060, 142281, 142131, 145390, 142217, 142073, 148095, 141683, 142132, 141750, 141698, 142043, 141648, 141650, 141672, 147217, 141656, 141198, 141647, 141726, 142282, 141714, 141708, 141709, 141217, 141653, 141663, 142170, 141661, 141657, 146397, 143122, 141986, 145404, 142245, 145921, 141705, 141712, 141747, 141715, 142283, 141751, 145706, 141822, 141727, 145398, 142210, 145455, 135371, 145708, 146460, 141798, 141771, 141725, 146475, 141813, 141716, 141745, 141746, 141749, 141713, 141717, 141718, 141328, 142437, 141721, 141723, 141722, 141729, 141724, 147751, 141733, 141731, 141734, 141735, 144028, 141736, 141738, 141740, 141744, 141748, 142284, 141116, 141991, 145707, 146000, 147752, 141580, 141551, 141542, 141757, 141758, 141760, 6009, 141165, 142195, 141777, 142018, 145030, 141767, 142424, 141768, 141797, 141770, 142133, 142196, 142237, 141810, 145709, 142235, 141769, 142134, 141772, 159355, 141213, 141773, 141775, 142197, 142061, 141085, 141782, 142262, 159330, 141226, 141406, 127499, 142221, 141778, 141431, 141779, 159360, 144112, 141781, 141233, 142219, 142238, 141118, 141784, 141802, 142063, 145124, 141107, 141060, 142074, 144115, 141843, 141804, 141649, 141048, 141785, 142169, 142220, 142264, 142265, 141809, 159386, 141796, 142200, 145953, 142152, 141511, 141790, 141793, 141794, 141795, 141182, 146804, 141799, 141244, 140919, 140870, 140708, 141801, 141192, 141805, 142879, 141807, 141812, 159361, 144259, 141803, 141811, 141814, 141818, 142208, 147267, 141242, 142172, 142266, 141780, 141819, 140903, 145710, 141490, 141820, 141821, 145954, 141817, 142036, 145405, 141816, 142202, 142206, 145711, 142050, 145263, 142068, 145591, 140975, 140915, 142067, 144749, 141441, 142189, 145407, 141063, 141464, 140891, 145958, 159390, 145194, 141732, 142668, 142181, 141121, 141081, 142892, 14122, 141092, 141093, 141045, 146002, 145923, 140855, 142203, 145021, 141136, 141497, 141188, 140992, 145423, 141227, 145956, 159391, 141701, 142207, 142034, 141197, 141691, 141668, 140931, 145955, 23023, 141998, 141030, 144587, 141160, 141457, 140983, 141250, 141000, 142065, 144920, 141181, 142268, 141844, 141720, 146003, 141766, 140949, 141164, 142912, 141231, 142209, 140990, 140942, 140809, 142153, 140988, 145865, 145924, 141236, 140889, 141995, 145784, 141774, 141240, 142234, 142140, 145415, 145925, 141840, 141838, 145592, 141247, 145411, 42176, 142056, 142188, 141839, 141841, 143751, 141634, 141834, 141833, 142051, 142426, 141404, 160560, 141343, 147218, 142244, 143734, 141835, 141076, 14126, 142191, 142430, 145410, 160584, 142084, 142259, 142158, 145926, 141005, 141837, 143953, 143001, 12721, 7136, 141993, 141860, 145768, 141994, 145774, 142020, 142787, 141180, 142024, 142027, 142041, 142040, 142045, 142046, 145727, 142168, 142159, 145412, 142156, 142300, 142069, 142157, 142324, 142075, 142079, 142076, 142077, 142078, 142081, 142211, 144921, 142669, 142083, 146461, 142429, 142086, 148133, 142087, 142088, 142109, 142212, 142141, 142160, 142161, 142167, 147753, 142171, 142326, 145197, 142243, 142110, 148134, 142111, 142115, 142114, 142112, 144923, 142129, 147219, 142327, 142165, 142166, 138644, 142186, 142177, 147032, 144554, 142182, 142187, 142190, 144778, 143009, 142239, 142240, 142241, 145593, 142322, 142263, 142222, 142224, 142225, 142427, 142232, 142226, 142227, 142233, 145570, 142228, 142229, 142230, 142231, 142455, 142414, 142425, 142248, 142285, 142257, 147220, 142306, 145421, 142317, 145220, 142501, 142321, 142373, 142249, 142250, 142289, 142290, 147785, 142251, 142261, 142253, 142255, 145416, 142256, 142307, 142304, 143935, 20118, 142294, 142295, 142287, 142439, 145594, 142296, 142291, 142292, 142298, 142301, 145417, 142305, 145571, 142308, 147266, 142303, 144861, 142311, 142477, 145562, 143485, 142450, 140854, 142310, 142312, 142316, 142441, 142313, 142314, 142318, 142442, 142320, 142444, 142488, 142474, 142332, 142330, 145900, 142331, 142746, 142328, 160682, 142335, 142447, 142336, 142334, 147311, 142471, 142339, 142375, 142453, 147033, 145837, 20403, 142376, 142377, 142458, 142380, 142428, 142002, 142448, 142399, 142395, 144761, 142381, 142382, 142383, 14203, 142386, 145328, 142388, 145960, 142420, 142387, 142385, 142415, 142015, 142647, 145031, 145595, 142412, 142392, 142421, 142489, 142457, 142035, 160667, 142026, 142038, 142393, 142400, 142402, 142409, 142410, 142401, 142403, 142404, 142413, 145596, 21856, 142452, 142029, 142030, 147076, 145418, 142454, 142483, 145033, 145728, 142044, 142461, 142459, 145330, 142460, 142472, 142469, 142644, 142464, 142473, 142014, 145564, 145961, 142054, 142480, 31720, 142516, 20196, 142476, 142484, 142504, 142897, 142487, 142502, 142506, 142493, 142500, 142498, 142494, 142515, 142526, 142518, 142524, 142503, 142522, 142507, 142535, 142770, 142627, 146790, 142530, 146462, 142650, 142885, 145770, 145573, 21861, 145748, 142539, 142658, 142670, 142662, 142564, 142700, 142541, 145126, 145032, 142546, 142543, 21879, 142545, 142544, 142568, 142573, 145221, 145729, 142576, 145127, 143797, 142588, 142586, 142584, 143101, 142651, 143411, 159358, 144724, 142589, 142660, 147312, 142705, 142848, 142716, 142636, 144958, 142590, 142645, 142685, 143954, 146004, 142688, 145329, 145816, 142592, 142594, 142595, 143128, 145034, 142597, 142641, 142638, 21893, 144668, 142684, 142882, 142604, 145901, 142599, 142646, 145041, 142652, 142600, 21898, 142661, 142602, 142637, 145962, 142608, 142578, 142607, 142653, 142697, 142616, 142648, 142610, 142663, 142706, 143120, 145495, 145730, 142654, 145838, 142640, 142689, 146688, 142611, 142642, 142889, 142579, 142612, 142613, 145714, 143121, 142649, 142691, 145419, 145963, 142615, 142614, 142664, 143010, 142617, 142824, 142674, 142678, 142916, 142633, 142620, 142621, 145825, 142626, 142623, 142622, 145841, 142625, 142628, 142630, 142629, 142631, 142681, 139850, 142643, 143104, 142675, 158655, 159363, 142676, 142671, 142679, 143527, 142673, 142680, 145597, 142686, 142788, 142698, 142913, 142694, 142699, 143106, 142703, 142696, 142977, 142976, 145393, 145394, 142708, 142911, 145824, 142712, 145826, 142711, 146078, 142845, 145772, 142958, 142719, 144299, 142713, 142721, 142728, 160668, 142717, 142744, 145771, 145223, 142729, 142722, 143957, 142785, 142841, 142771, 143184, 146689, 142724, 145827, 142725, 142730, 142726, 142727, 145225, 142731, 144464, 142748, 147599, 142741, 30826, 143050, 142745, 142811, 142732, 142734, 142737, 142738, 142739, 142772, 144149, 142768, 142751, 142752, 142773, 142758, 142904, 143012, 142801, 159375, 142759, 142753, 142757, 142767, 142761, 142906, 142763, 142762, 143672, 142926, 142920, 142764, 142766, 142765, 142774, 142775, 142806, 160671, 142929, 142776, 142778, 142782, 142779, 142780, 142783, 142781, 142784, 144998, 145198, 142786, 142860, 145575, 142789, 142790, 142791, 142793, 142792, 160680, 146747, 142804, 142842, 142797, 142867, 142794, 142795, 142798, 142863, 159368, 159382, 147787, 142796, 142890, 142799, 142809, 142802, 142818, 142803, 143083, 142807, 142822, 142808, 145001, 142760, 142972, 142869, 143125, 142865, 142827, 20173, 146900, 142810, 142812, 142813, 142830, 142831, 142970, 142814, 146962, 143159, 142815, 142816, 142821, 142817, 142828, 142834, 142829, 142844, 142832, 142833, 143117, 159379, 142942, 142836, 142843, 142838, 142839, 142862, 145600, 142849, 142850, 142851, 142895, 142853, 142854, 142855, 142856, 142857, 142858, 142864, 142871, 142872, 142870, 142873, 142877, 142878, 142927, 142917, 142930, 142925, 142923, 142933, 142868, 142934, 142939, 142936, 142896, 142997, 142957, 144256, 142935, 142937, 142959, 143409, 148136, 142931, 142940, 142884, 147275, 142941, 142886, 145828, 145829, 142887, 142952, 142987, 142949, 142951, 142908, 142948, 142950, 142954, 143443, 145830, 142995, 142928, 142962, 144925, 143018, 142961, 142963, 142443, 142964, 147473, 142965, 142969, 142992, 142967, 143530, 143014, 142979, 142980, 148584, 142986, 144298, 145226, 143107, 145000, 143005, 143021, 142981, 142983, 142888, 143358, 142990, 142984, 142989, 142988, 143003, 143007, 143004, 143019, 143024, 143002, 143027, 143361, 143028, 143006, 143008, 143013, 143022, 159600, 160720, 143015, 143016, 143017, 143023, 145186, 143026, 143194, 143123, 143029, 143030, 143036, 143031, 143032, 143053, 145139, 143038, 143070, 143206, 143158, 147788, 143033, 143037, 143040, 143041, 143042, 143043, 143044, 143045, 143046, 143047, 143048, 143108, 143535, 143059, 143396, 143051, 143052, 143054, 147797, 143056, 143057, 143049, 143146, 143061, 143151, 143062, 143077, 143063, 25595, 143134, 145602, 143064, 143084, 143065, 143067, 143093, 143068, 143073, 143076, 143066, 146690, 143069, 143071, 142411, 143092, 143085, 143074, 143075, 143091, 147313, 142199, 143078, 143124, 145151, 143079, 143082, 145399, 143096, 143109, 143094, 143118, 143116, 3337, 143136, 143137, 145155, 143143, 143145, 143102, 143103, 146033, 143099, 143110, 143112, 143113, 143114, 143115, 143131, 142975, 143135, 143130, 142966, 143544, 142826, 142286, 146031, 143129, 143088, 143148, 142398, 142319, 142198, 142178, 142635, 142683, 143168, 142687, 143173, 143204, 143095, 142218, 145274, 25860, 143150, 143152, 143157, 143155, 142690, 143161, 143105, 142462, 143488, 142718, 143163, 143164, 143176, 143165, 143166, 148161, 143160, 143162, 145200, 143705, 143167, 142899, 147314, 142702, 142901, 143174, 142709, 143081, 143034, 142777, 143086, 143698, 145927, 142715, 142104, 142985, 145228, 142968, 142825, 142819, 144608, 142136, 143186, 143499, 142932, 142315, 143080, 146086, 142194, 143526, 142174, 143156, 143189, 142272, 143501, 143502, 142800, 148314, 142837, 143209, 143207, 142596, 143382, 142058, 144295, 143197, 142269, 142223, 143183, 142293, 146124, 142039, 143169, 144036, 144255, 142754, 144932, 143172, 143180, 143060, 144887, 28369, 143669, 142861, 144933, 142973, 142299, 922, 142682, 147825, 142624, 143089, 143210, 143211, 142677, 144893, 142710, 143201, 143202, 143098, 143182, 143175, 143191, 143195, 143556, 143199, 142192, 143200, 143203, 143398, 145168, 143205, 143208, 145264, 143213, 145242, 142417, 142619, 143218, 142672, 143495, 145171, 142756, 143216, 143214, 143679, 145424, 143149, 143387, 143392, 143394, 143426, 142714, 143670, 145181, 142525, 148533, 142982, 143000, 145425, 145426, 143147, 143407, 143360, 146810, 142609, 142204, 142205, 143097, 142254, 142859, 143142, 145454, 145453, 143215, 143554, 145902, 143132, 142135, 144712, 143144, 142391, 143362, 143363, 142384, 143686, 144266, 159378, 142107, 143222, 142154, 143405, 143410, 143376, 142021, 142866, 145458, 159383, 141985, 144784, 142085, 142329, 142750, 142749, 144980, 143697, 142735, 143763, 143381, 143585, 146811, 142485, 142374, 142333, 14944, 143609, 146801, 142755, 142408, 142598, 159396, 159416, 148582, 143219, 144991, 145257, 142938, 146032, 143133, 143221, 143212, 143475, 141353, 24457, 143357, 143860, 146812, 143365, 143366, 143378, 145456, 143369, 143370, 143371, 143973, 143375, 143624, 159395, 143374, 143373, 143379, 143380, 143390, 143391, 143464, 143465, 144303, 143503, 145400, 145184, 159389, 143466, 143474, 143470, 143671, 143486, 145202, 143521, 143537, 100296, 143541, 143583, 143691, 143496, 143507, 143508, 143519, 145162, 143673, 143518, 143514, 143520, 143759, 143651, 143517, 143536, 143662, 143557, 143559, 145401, 143560, 143561, 143562, 143706, 143789, 143696, 143695, 143558, 143566, 145109, 143565, 143708, 143567, 143571, 143707, 143568, 143703, 143569, 145112, 145864, 145128, 143572, 146813, 143576, 143625, 143661, 143601, 143666, 143619, 143617, 143574, 145460, 145003, 143577, 143688, 143579, 145163, 143580, 143615, 143850, 143675, 143853, 143607, 4681, 143616, 143700, 143622, 143588, 143626, 143592, 143593, 143599, 143598, 143594, 143606, 143590, 143605, 143621, 143623, 146292, 143692, 143614, 143618, 143680, 143611, 143676, 143694, 143699, 145192, 143685, 143652, 143631, 143687, 143683, 143628, 143663, 143633, 148960, 143634, 143677, 143635, 143681, 143693, 145467, 143690, 143665, 143637, 143678, 143658, 143664, 143682, 143640, 143684, 143641, 143642, 143689, 143643, 143644, 143646, 143649, 144281, 143655, 143704, 143701, 143765, 145169, 143709, 143710, 143760, 143711, 145469, 143718, 143712, 143713, 145076, 143800, 146814, 143714, 143844, 144460, 143913, 143735, 143794, 145165, 143715, 143716, 143717, 143824, 143724, 143740, 143719, 143783, 143764, 143720, 143741, 145015, 143845, 148805, 143886, 143732, 143721, 143722, 143865, 143723, 143852, 147859, 143725, 143726, 143761, 143738, 143736, 143788, 143746, 143771, 143731, 143744, 143745, 143743, 143799, 143762, 143821, 145831, 143766, 143795, 143756, 143758, 143752, 143750, 145166, 143757, 143753, 143755, 143840, 145471, 143888, 145819, 143859, 143768, 143769, 148853, 143843, 143776, 143772, 143774, 145457, 143775, 143798, 144300, 143777, 143784, 148905, 143778, 143779, 143780, 144960, 145279, 143781, 145133, 143639, 143894, 143782, 143785, 21486, 143805, 143817, 143801, 144280, 143804, 143803, 143807, 145158, 145294, 143810, 1931, 143808, 145014, 143836, 145413, 143827, 143816, 143813, 143811, 143818, 143812, 145159, 143815, 143814, 143869, 145475, 143819, 143823, 145017, 145016, 143830, 145157, 143831, 146815, 143854, 145062, 145476, 143832, 143868, 145071, 145603, 143884, 145249, 143873, 143842, 143851, 144441, 143871, 143866, 143867, 143882, 143874, 143876, 143877, 143879, 143890, 143891, 143901, 143881, 145018, 145072, 145073, 144473, 143887, 143902, 143889, 143885, 143892, 143893, 143895, 143900, 22080, 3505, 145969, 143903, 143912, 145022, 143929, 145822, 143936, 145494, 143896, 145161, 143909, 143934, 143927, 145020, 21807, 21836, 143906, 143603, 143898, 143899, 143933, 145605, 144102, 144039, 144506, 143904, 143923, 143907, 143940, 143914, 144076, 148005, 143915, 144058, 143916, 143917, 143918, 143919, 143878, 144034, 144047, 143932, 145606, 143959, 145970, 143937, 143939, 143529, 143963, 143977, 145261, 144011, 144045, 144087, 145129, 145135, 143846, 145136, 144884, 144050, 143968, 143976, 143971, 146802, 143944, 143945, 145817, 143962, 143942, 145115, 144016, 143991, 143948, 144085, 143969, 145971, 144046, 144310, 144492, 143952, 143951, 143955, 143970, 159407, 10823, 144100, 144457, 143978, 144067, 144138, 144308, 144037, 144043, 144018, 144926, 145253, 143996, 144041, 144015, 144507, 145130, 144885, 144038, 145477, 145498, 145500, 159406, 145821, 143987, 143981, 145037, 143983, 144103, 144006, 144151, 143986, 159400, 143985, 143998, 143990, 144040, 143992, 144049, 145116, 144030, 144106, 19357, 144060, 144094, 143993, 143960, 144010, 144388, 144013, 144014, 145191, 145141, 144020, 144205, 144057, 146476, 144021, 144004, 144005, 144055, 143864, 144059, 144140, 144019, 143806, 144141, 145140, 144104, 144051, 144931, 145036, 149228, 144079, 144022, 144075, 144024, 144026, 144927, 145479, 144023, 144044, 144048, 144133, 144052, 144053, 145024, 144061, 144063, 144062, 144068, 144064, 144065, 144069, 144071, 144066, 144074, 8002, 144080, 144073, 144078, 144160, 144097, 144070, 144077, 144125, 144095, 144096, 144098, 159402, 149514, 144088, 144092, 144285, 144241, 144090, 145502, 144105, 144107, 144101, 144144, 144099, 144152, 144093, 144113, 144108, 144136, 144142, 144161, 144110, 144116, 146803, 144114, 144120, 145868, 144162, 144147, 148991, 144119, 144163, 144153, 144154, 146037, 144123, 144124, 144158, 144929, 144309, 144128, 144126, 145138, 144186, 144131, 144127, 144429, 144165, 144155, 144156, 144157, 145254, 144159, 145503, 145504, 144166, 144267, 144855, 144179, 149299, 149306, 144172, 144245, 145038, 144215, 144168, 144169, 144171, 145823, 144211, 145506, 144174, 159397, 145558, 144176, 144177, 145911, 144178, 144264, 144258, 144180, 144181, 144201, 145256, 144213, 145832, 159398, 144183, 144265, 145045, 145820, 144187, 144217, 144190, 145260, 144199, 144193, 144200, 144194, 144210, 144218, 144364, 145505, 14899, 144195, 144196, 144197, 144228, 144453, 144198, 144224, 144207, 159447, 144212, 145881, 144214, 144235, 144231, 144237, 144232, 144229, 144239, 144302, 144240, 144286, 159452, 22973, 144251, 144269, 145833, 144248, 145262, 146038, 144471, 144246, 144472, 144320, 144254, 144219, 145039, 144257, 144268, 144270, 144289, 145733, 144263, 144261, 144271, 144483, 144276, 144515, 144277, 144275, 144283, 145044, 145042, 144278, 144284, 145481, 144292, 144291, 145023, 145834, 145835, 144294, 144164, 144487, 145483, 144484, 144323, 145111, 145113, 145150, 145152, 159820, 144341, 144111, 144482, 144485, 144339, 144344, 145199, 144671, 144434, 144365, 144184, 144607, 144557, 144574, 144604, 145131, 144389, 144605, 144422, 144558, 144380, 144390, 144679, 145836, 144575, 144606, 144381, 144367, 145047, 21537, 144610, 143548, 144680, 144603, 144243, 144417, 148145, 144576, 144673, 144358, 144368, 144362, 145478, 143511, 144370, 144376, 145529, 144577, 144252, 144279, 144360, 22660, 144361, 143449, 144000, 144395, 144378, 144337, 144170, 145939, 144371, 21059, 144431, 145265, 145046, 144379, 144600, 144585, 144373, 144375, 144454, 144035, 144377, 144384, 142603, 3997, 143826, 144436, 144333, 144437, 144438, 144569, 144461, 144414, 144397, 144499, 144399, 145049, 144402, 145484, 144445, 144400, 144446, 144401, 143967, 144854, 145530, 146465, 143995, 145773, 144456, 144616, 144510, 144405, 144406, 145048, 144407, 144408, 145533, 144449, 144225, 144458, 144853, 144012, 144450, 143975, 143787, 145051, 144002, 143792, 145285, 143988, 21728, 21640, 21648, 18692, 149494, 143728, 143994, 144508, 144810, 144411, 144512, 145928, 143982, 145488, 144234, 143739, 144413, 144415, 145284, 145510, 143523, 144462, 144858, 144419, 145486, 145489, 144418, 144343, 144502, 144496, 144426, 144421, 144514, 144513, 144862, 144351, 144859, 144349, 145077, 145414, 143790, 144613, 144352, 144423, 144505, 144602, 146005, 143632, 144518, 144521, 144519, 144516, 144559, 144555, 144570, 144565, 144571, 144572, 144564, 142639, 144647, 144579, 144653, 145507, 144580, 144860, 144857, 144586, 144614, 146039, 144121, 144592, 2779, 144328, 144416, 144594, 144598, 144595, 144599, 144591, 143553, 143905, 145581, 145582, 145102, 145064, 145107, 145110, 144031, 144366, 143920, 145087, 144447, 26797, 143638, 144452, 145929, 143786, 144659, 144455, 145092, 145091, 145584, 144868, 145940, 144404, 143921, 160706, 143910, 144117, 144796, 144797, 143570, 144321, 143650, 143648, 144988, 143573, 144959, 143555, 144800, 145331, 143595, 145088, 145583, 144560, 143964, 144990, 144989, 145534, 144562, 144678, 144963, 143613, 145332, 143630, 144801, 144803, 145508, 144056, 145516, 145536, 145795, 144025, 144664, 143742, 145333, 144465, 143872, 144032, 144802, 144639, 145093, 145538, 144311, 143875, 144965, 145296, 144356, 144350, 144866, 144863, 144864, 160722, 143925, 144412, 145052, 145053, 145054, 144354, 144665, 144807, 144808, 144809, 143748, 159405, 144590, 144135, 144831, 144805, 144290, 144811, 144173, 145334, 145379, 145345, 144272, 148146, 144260, 145515, 144082, 144865, 144836, 144869, 145055, 145057, 145056, 144249, 143596, 159413, 27843, 145537, 144089, 144622, 145512, 144081, 143911, 145058, 145079, 145080, 145081, 145082, 145517, 145519, 145521, 143773, 144675, 144833, 144992, 144957, 144330, 144674, 143563, 144175, 144709, 144707, 144710, 145059, 145067, 145065, 145068, 144663, 143384, 143984, 144794, 144814, 143730, 144420, 145747, 159415, 144347, 142634, 144713, 144714, 145078, 144993, 145487, 143980, 145787, 144582, 143922, 143367, 28651, 143472, 143737, 143354, 144716, 144717, 144718, 144719, 144720, 143406, 144820, 143355, 144202, 144084, 144650, 144649, 145585, 145522, 148147, 144348, 144822, 143482, 143809, 144313, 144655, 144798, 144837, 145070, 145069, 161020, 28727, 144636, 144821, 144824, 144825, 147171, 28746, 24331, 145190, 145189, 144660, 144661, 144828, 144829, 144662, 144986, 31679, 144987, 144666, 144667, 144669, 144830, 144832, 144677, 144670, 144966, 159418, 149734, 144676, 148148, 144681, 144683, 144684, 144940, 145219, 145218, 144685, 144689, 144690, 144698, 144692, 144793, 145513, 145514, 145520, 145543, 145544, 145547, 145549, 145800, 145552, 145553, 145556, 145555, 145557, 145576, 145577, 145578, 145563, 145565, 145566, 145712, 145713, 145715, 145716, 145717, 145718, 145719, 145720, 145721, 145722, 145723, 145724, 145725, 145726, 145785, 145786, 145788, 145789, 145790, 148182, 145792, 145793, 145794, 145797, 145798, 145799, 145840, 145842, 145843, 145844, 145845, 145846, 145847, 145848, 146474, 145851, 145852, 145853, 145854, 145855, 145856, 145858, 145859, 145860, 145861, 145863, 145876, 145877, 145878, 145879, 145880, 145904, 145905, 145906, 145907, 145973, 148296, 145974, 145975, 145976, 145977, 145978, 145979, 145980, 145981, 145982, 145983, 145993, 145994, 145995, 145996, 146055, 147385, 146063, 146066, 146018, 146692, 146019, 146020, 146021, 146022, 146023, 146024, 146025, 146026, 146027, 146034, 146035, 146036, 146040, 146042, 146043, 146044, 146045, 146046, 146047, 146048, 146049, 146050, 146051, 146054, 146056, 146069, 146070, 146071, 146072, 146609, 146073, 146074, 146075, 146076, 146077, 146079, 146081, 146082, 146083, 146084, 146087, 146088, 146089, 146090, 146091, 146093, 146094, 146095, 146096, 146097, 146098, 146099, 146100, 146102, 146103, 146104, 146105, 146106, 146199, 146107, 146108, 146610, 146109, 146110, 146111, 146112, 146113, 146114, 146115, 146116, 146119, 146120, 146121, 146122, 146123, 146125, 146126, 146164, 146127, 146133, 146190, 146191, 146253, 146254, 146257, 146135, 146136, 146137, 146138, 146140, 146141, 146142, 146143, 146477, 146144, 146145, 146146, 146147, 146148, 146149, 146150, 146151, 146152, 146159, 146160, 146161, 146162, 146163, 146165, 146166, 146177, 146178, 146179, 146193, 146194, 146353, 146382, 146195, 149827, 149830, 146196, 146197, 146202, 146203, 146204, 146219, 146220, 146275, 146285, 146286, 146222, 146223, 146224, 146225, 146245, 146246, 146247, 146248, 146249, 146250, 146251, 146252, 148183, 146255, 146256, 146494, 146258, 146259, 146260, 149833, 146261, 146279, 146280, 146287, 146288, 146289, 146339, 146290, 146291, 146295, 146296, 146297, 146298, 146299, 146300, 146681, 146301, 146302, 146303, 146304, 146306, 146307, 146308, 146309, 146310, 146320, 146479, 146322, 146455, 146323, 146324, 146325, 146326, 146327, 146328, 146329, 146330, 146344, 146345, 146346, 146347, 146348, 146351, 146352, 146364, 146368, 146369, 146376, 146377, 146378, 146379, 146380, 146381, 146384, 146385, 146386, 146387, 146388, 146389, 146390, 146391, 146456, 150025, 146392, 146398, 146400, 146401, 146402, 146403, 146418, 146419, 146420, 146421, 146422, 146423, 146425, 146437, 146438, 146439, 146440, 146441, 146442, 146443, 146444, 146447, 146448, 146449, 146467, 146468, 146469, 146470, 146471, 146472, 146473, 146480, 146481, 146482, 146483, 146484, 149904, 146488, 146491, 146492, 146546, 146547, 146549, 146559, 146560, 146571, 146572, 146573, 146574, 146575, 146602, 149933, 146603, 146604, 146605, 146606, 146624, 146625, 146626, 146627, 146628, 146699, 146629, 146630, 146632, 146633, 146634, 146635, 146649, 146650, 146651, 146652, 146653, 146654, 146655, 146658, 146659, 146660, 146663, 146664, 146835, 146836, 146837, 146838, 146839, 146840, 146841, 146842, 146843, 146844, 146845, 146846, 146847, 146848, 146849, 146850, 146851, 146862, 146863, 146864, 146865, 146866, 146871, 146872, 146873, 146874, 146875, 146876, 146877, 146878, 146879, 146880, 146881, 148184, 146887, 146888, 146889, 146925, 146890, 146891, 146892, 146968, 146893, 146894, 146932, 147088, 146895, 146896, 147386, 146898, 146899, 146901, 146905, 146906, 146907, 146908, 146909, 146910, 146911, 146912, 146913, 146914, 146915, 146916, 146917, 146918, 146919, 146921, 146922, 146923, 146924, 146926, 146927, 147006, 146928, 146929, 146930, 146931, 146933, 146934, 146937, 146943, 146944, 146945, 146946, 146947, 146948, 146949, 146950, 146951, 146952, 146954, 146955, 146956, 146957, 146958, 146963, 146964, 146965, 146966, 146967, 146969, 146970, 146971, 146972, 146973, 148297, 146975, 146976, 149960, 146981, 146985, 146986, 146987, 146988, 146989, 146990, 146991, 146992, 146993, 146994, 146995, 146978, 146979, 146996, 146997, 146998, 146999, 147009, 147010, 147011, 147012, 147013, 147014, 147050, 150005, 147015, 147016, 147017, 147019, 147020, 147021, 147022, 147023, 147024, 147025, 147026, 147027, 147029, 147030, 147031, 147035, 147036, 147037, 147038, 147039, 147040, 147042, 147043, 147045, 147046, 147034, 147041, 147051, 147052, 25430, 147053, 147054, 147175, 147055, 147056, 147057, 147060, 147061, 147064, 147065, 147067, 147068, 147069, 147070, 147071, 147072, 147074, 147075, 147077, 147078, 147082, 147083, 147084, 147085, 147087, 147059, 147097, 147099, 147100, 147101, 147102, 147103, 147104, 147105, 147106, 147107, 147108, 147109, 147110, 147111, 147112, 147113, 147114, 147125, 147126, 147098, 147127, 147128, 147129, 147130, 147131, 147139, 147140, 147141, 147148, 147149, 147150, 147157, 147158, 147159, 147160, 147166, 147167, 147168, 147169, 147170, 147172, 147173, 147174, 147176, 147316, 147187, 147188, 147189, 147190, 147191, 147192, 147193, 147222, 147223, 147226, 147227, 147228, 147229, 147230, 147231, 147233, 147234, 147235, 147237, 147238, 147239, 147240, 147241, 147242, 147243, 147244, 147245, 147246, 147247, 147248, 147249, 147250, 147317, 147232, 147251, 147265, 147268, 147269, 147270, 147271, 147272, 147274, 147279, 147280, 147281, 147282, 147283, 147284, 147285, 147286, 147287, 147288, 147289, 147290, 147291, 147292, 25435, 147293, 147294, 147295, 147296, 147297, 147298, 147299, 147300, 147301, 147302, 147330, 147347, 147348, 147349, 147351, 147352, 147353, 147354, 147355, 147356, 147357, 147358, 147359, 147360, 147361, 147365, 147366, 147367, 147368, 147369, 147370, 150058, 147411, 147412, 147413, 147414, 147415, 147416, 147417, 147420, 147422, 147423, 147424, 147425, 147429, 147430, 147480, 147481, 147510, 147511, 147512, 147513, 147514, 147515, 147516, 147517, 147518, 147519, 147520, 147521, 147537, 147538, 147539, 147540, 147541, 147542, 147543, 147544, 147545, 147546, 147547, 147548, 147549, 147550, 147551, 147552, 147553, 147729, 147554, 147555, 147556, 147559, 147560, 147561, 148185, 147592, 147594, 147596, 147597, 147598, 147600, 147601, 147602, 147603, 147604, 147605, 147606, 147607, 147608, 147609, 147610, 147611, 147612, 147613, 147614, 147615, 25436, 147616, 147617, 147618, 147619, 147620, 147621, 147622, 147623, 147624, 147625, 147626, 147627, 147628, 147644, 147645, 147646, 147647, 147648, 147649, 147651, 147652, 147657, 147658, 147659, 147660, 147661, 147662, 147663, 147664, 147665, 147666, 147667, 147668, 147669, 11178, 147670, 147671, 147672, 147673, 147674, 147675, 147676, 147677, 147678, 147679, 147681, 147683, 147686, 147687, 147688, 147689, 147690, 147692, 147700, 147701, 147706, 147707, 147708, 147709, 147710, 147711, 147712, 147713, 147714, 147715, 147716, 147717, 147718, 147719, 147720, 147722, 147723, 147724, 147725, 147726, 147727, 147728, 147730, 147731, 147734, 147735, 147736, 147737, 147738, 147739, 147741, 147742, 147743, 147747, 147754, 147755, 147756, 147757, 147758, 147759, 147760, 147761, 147864, 147762, 147763, 147764, 147766, 147767, 147768, 147769, 147770, 147771, 147773, 147774, 147775, 147780, 147781, 147782, 147820, 147821, 147783, 147789, 147790, 147791, 147794, 3538, 147784, 148282, 148298, 147865, 147796, 147798, 147799, 147800, 147801, 147802, 147803, 147804, 147805, 147806, 147842, 147807, 147809, 147810, 147811, 147812, 147813, 147814, 147815, 147816, 147817, 147822, 147823, 147824, 147826, 31405, 147827, 147828, 147833, 147834, 147835, 147836, 147837, 147838, 147839, 147840, 147841, 147843, 147844, 147845, 149150, 147846, 147847, 147848, 147849, 147850, 147851, 147852, 147853, 147854, 147855, 147856, 147858, 147860, 147861, 147862, 147867, 147868, 147869, 147870, 147871, 147872, 147873, 147874, 147875, 147876, 147877, 147878, 147879, 147880, 147881, 148049, 147882, 147895, 147896, 147898, 147899, 147900, 147901, 147940, 148004, 147902, 147903, 148465, 147904, 147905, 147906, 147907, 147908, 147909, 147910, 147911, 147913, 147914, 147915, 147916, 147917, 147918, 147920, 147921, 147922, 147923, 147924, 147925, 147926, 147927, 147930, 147931, 147932, 147933, 147934, 147935, 147936, 144787, 147939, 147941, 147942, 147943, 147944, 147945, 147946, 147947, 147948, 147949, 147950, 147953, 147954, 147955, 147956, 147957, 147958, 147959, 147960, 147961, 147962, 147963, 147964, 147965, 147966, 147967, 147968, 147969, 147970, 147971, 148002, 148906, 148000, 147972, 147973, 147974, 147975, 147976, 147977, 147978, 147979, 147980, 147982, 147983, 147984, 147985, 147986, 147987, 147988, 147989, 147990, 147991, 147992, 147993, 147994, 147995, 147996, 147997, 147998, 148138, 146262, 147999, 148003, 148008, 148009, 148011, 148012, 148013, 148014, 148050, 148015, 148016, 148017, 148018, 148019, 148020, 148021, 148022, 148023, 148024, 148025, 148026, 148137, 148027, 148028, 148029, 148031, 148032, 148033, 148034, 31444, 148035, 148036, 148287, 148038, 148039, 148040, 148041, 148043, 148044, 148045, 148077, 148157, 148046, 148047, 148051, 148052, 148053, 148054, 148055, 148056, 148057, 148058, 148059, 148060, 148061, 148062, 148063, 148064, 148065, 148066, 148067, 148068, 148100, 148069, 148070, 148104, 148071, 148072, 148073, 148074, 148075, 148076, 148198, 148079, 148080, 148081, 148082, 148083, 148084, 148085, 148086, 148087, 148088, 148089, 148090, 148091, 148092, 148093, 148096, 148097, 148098, 148099, 148101, 148102, 148103, 148105, 148106, 148107, 148108, 148109, 148110, 148111, 148112, 148113, 148114, 148115, 148116, 148117, 148118, 148119, 148120, 148121, 148122, 148123, 148124, 148126, 148127, 148128, 148129, 148130, 148131, 148132, 148140, 148141, 148149, 148151, 148152, 148153, 148154, 148155, 148156, 148158, 148159, 148160, 148162, 148163, 148164, 148165, 148166, 148168, 148169, 148170, 148171, 148172, 148173, 148174, 148293, 148175, 148176, 148177, 148178, 148179, 148180, 148181, 148186, 148222, 148187, 148188, 148189, 148190, 148191, 148192, 148193, 148194, 148195, 148196, 148197, 148201, 148202, 148203, 148204, 148205, 148206, 148207, 148208, 148209, 148210, 148211, 148214, 148215, 148216, 148217, 148218, 148219, 148220, 148221, 148223, 148224, 148225, 148226, 148227, 148228, 148229, 148231, 148232, 148233, 148234, 148235, 148236, 148237, 148238, 149226, 148449, 148295, 148247, 148288, 148249, 148250, 148251, 148252, 148253, 148254, 148255, 148256, 148257, 148258, 148259, 148260, 148261, 148262, 148264, 148265, 148266, 148267, 148268, 148269, 148270, 148271, 148272, 148273, 148274, 148275, 148276, 148277, 148278, 148279, 145451, 148280, 148294, 148300, 148302, 148305, 148307, 148308, 148309, 148310, 148311, 148312, 148313, 148315, 148316, 148317, 148319, 148320, 148321, 148322, 148323, 148325, 148326, 148327, 148328, 148330, 147919, 148334, 148318, 148997, 148478, 145439, 148521, 143908, 31448, 148332, 148350, 148333, 148336, 148495, 148337, 148340, 148446, 148564, 144723, 148468, 148341, 148364, 148423, 150447, 149368, 148368, 148344, 148525, 149151, 148553, 144725, 145231, 148342, 148346, 148352, 148348, 145432, 148422, 148498, 148362, 148365, 148366, 148619, 148470, 148376, 148992, 148472, 148536, 148349, 148354, 148469, 144726, 148355, 148357, 148581, 145442, 148360, 145011, 148527, 148480, 148361, 148403, 3397, 148520, 148526, 148548, 148579, 144894, 148612, 145012, 145443, 148373, 148655, 145230, 148497, 148522, 148453, 144897, 148780, 144699, 144842, 148950, 148630, 148631, 148427, 148908, 148399, 148490, 31457, 148408, 17377, 148587, 148532, 144708, 148506, 144888, 148764, 148483, 148434, 144891, 148420, 148411, 148523, 148528, 148586, 148491, 148441, 148437, 148479, 148439, 148474, 148475, 148539, 148425, 148419, 148424, 148428, 148429, 31226, 148445, 148551, 149048, 11445, 148781, 148430, 148431, 148488, 148432, 145154, 148433, 148435, 31419, 148456, 145431, 148436, 148438, 148487, 148443, 148452, 148454, 148442, 144889, 145232, 148518, 148457, 148524, 148552, 148795, 148448, 148476, 148477, 148460, 148486, 148888, 148451, 144939, 148464, 148455, 148461, 148458, 148462, 148459, 148466, 148471, 145482, 145193, 148473, 148481, 148482, 144705, 148534, 148484, 148485, 148538, 148492, 148493, 148494, 148503, 148504, 148505, 148499, 148543, 148535, 148500, 144880, 148501, 148508, 148516, 148509, 148511, 148517, 148512, 148513, 144892, 144738, 148562, 154166, 148514, 148541, 148585, 148547, 144702, 144886, 148890, 148515, 145233, 148530, 148561, 144792, 154796, 144744, 148575, 14641, 144788, 144789, 144877, 144941, 144942, 148544, 145013, 148537, 148540, 148555, 144743, 148556, 144735, 148557, 144737, 148558, 148578, 144751, 144753, 148559, 144770, 144835, 148746, 149312, 148566, 145147, 148892, 148567, 148577, 148570, 144754, 148572, 148573, 144746, 144748, 144750, 144747, 148583, 144757, 149202, 31680, 159419, 148589, 144879, 148591, 145750, 145035, 148932, 144962, 148605, 24064, 148617, 145258, 22814, 14079, 144881, 144882, 144883, 148592, 144945, 144946, 148948, 148803, 148596, 148598, 144947, 148599, 144948, 144943, 144949, 144950, 148601, 148951, 148681, 148677, 148606, 148668, 157595, 148608, 148610, 144952, 148351, 144953, 144954, 144955, 144956, 148607, 148611, 144964, 148691, 145234, 148614, 148615, 148679, 148616, 148922, 148667, 148796, 148618, 148665, 148666, 145444, 145063, 148648, 32516, 148652, 145010, 148710, 148711, 148680, 148685, 148785, 148621, 154950, 148622, 148624, 148797, 145149, 148699, 148623, 148687, 148688, 148724, 148708, 148784, 157670, 148627, 149796, 21713, 39910, 148626, 145060, 145132, 148628, 145008, 148718, 148790, 148693, 148635, 148690, 148909, 148641, 148831, 148709, 148638, 148636, 145061, 148701, 148653, 148642, 148643, 21735, 32525, 148707, 148645, 148644, 145009, 145235, 148727, 148735, 148682, 148650, 148762, 148658, 148660, 3661, 150522, 148662, 145002, 145005, 145006, 145007, 148669, 148673, 148747, 148678, 148676, 159426, 159423, 159420, 150597, 8139, 148700, 148697, 148783, 27117, 148703, 148704, 148705, 148714, 159422, 148706, 148713, 148715, 148716, 148726, 145341, 148717, 148723, 148728, 148719, 159442, 3722, 148720, 3660, 148733, 145277, 148721, 148739, 148722, 148725, 148729, 148730, 148736, 34626, 148731, 148732, 148734, 148763, 148740, 145237, 148744, 148741, 148742, 148743, 148738, 148745, 148757, 148749, 148961, 148632, 148765, 149186, 148750, 148751, 148752, 148753, 145238, 148754, 145241, 148792, 148755, 125757, 148758, 148759, 148772, 148770, 148760, 148692, 148761, 148800, 148651, 145066, 148769, 148793, 148771, 148788, 148801, 21299, 148768, 148779, 148830, 148773, 148774, 148775, 145239, 148776, 148777, 148782, 148786, 145094, 148787, 148802, 148811, 148804, 145282, 148807, 148812, 148806, 148808, 148809, 148814, 148810, 148815, 148820, 148893, 149179, 148894, 148816, 148818, 145286, 145287, 148817, 148819, 148821, 145240, 148823, 148833, 148829, 145103, 148836, 159410, 27208, 148846, 145106, 148898, 148857, 148834, 148825, 145142, 145143, 145144, 148839, 145145, 145146, 145295, 145436, 148866, 148840, 148838, 148843, 28210, 148841, 148842, 148900, 145289, 148854, 28527, 148856, 34352, 148860, 148879, 148920, 148881, 159439, 150788, 148904, 28215, 148859, 148899, 145343, 148882, 145290, 149083, 148849, 148851, 148883, 145342, 148915, 149134, 148861, 148897, 150164, 148862, 148864, 148895, 148901, 148903, 148886, 28287, 148868, 148896, 148902, 148871, 148872, 148874, 148884, 148875, 149206, 22951, 148887, 150807, 150945, 145187, 148927, 148935, 148994, 148907, 145338, 148910, 148918, 148919, 148921, 148924, 145255, 148944, 148663, 148929, 148931, 148911, 148912, 148913, 148917, 14227, 148986, 148925, 144626, 148926, 148934, 142736, 148937, 148939, 148940, 148947, 148941, 148984, 145435, 148502, 147058, 148943, 148938, 148999, 148945, 148990, 148965, 149180, 148956, 148987, 148958, 148959, 149107, 148964, 149007, 149008, 148973, 148971, 149198, 149017, 145437, 148972, 150082, 148988, 149052, 150873, 148975, 149055, 149038, 148993, 149153, 145397, 149059, 145319, 148977, 148996, 148979, 145291, 145292, 145293, 148981, 148982, 145438, 159462, 148983, 148995, 148989, 149046, 149040, 149265, 148980, 149001, 149002, 149003, 149005, 149018, 150584, 149016, 149190, 149171, 149034, 149033, 149137, 149006, 145340, 149009, 149010, 149012, 149013, 149014, 148822, 145337, 149050, 149015, 149022, 149061, 149023, 149056, 149019, 149025, 149030, 148766, 149081, 23129, 28587, 149058, 148799, 149044, 149043, 149047, 148998, 145335, 145336, 149076, 145429, 149049, 145339, 22954, 125114, 149071, 149066, 149065, 149067, 149101, 148826, 149077, 149080, 149091, 149104, 149087, 149085, 149182, 149084, 149097, 149095, 149090, 149094, 149156, 149093, 149135, 29510, 149098, 149115, 145447, 149123, 149106, 149223, 149114, 149140, 149159, 149105, 149130, 149119, 149167, 159463, 149128, 149129, 149120, 149132, 149136, 149158, 149152, 30216, 149238, 149139, 149144, 149142, 148835, 145382, 145384, 149148, 145383, 149149, 149175, 149146, 149145, 145105, 149243, 149244, 148837, 149116, 149160, 149164, 149154, 149163, 149192, 149204, 149209, 149220, 149216, 149221, 149496, 149233, 152117, 149235, 149372, 21727, 149227, 145408, 148974, 149230, 149231, 158831, 149257, 149256, 145428, 145433, 149273, 149269, 149241, 148844, 148845, 149237, 149239, 147478, 149291, 149246, 149247, 150250, 149253, 149250, 21745, 149254, 149072, 149252, 149741, 149280, 149260, 149645, 149296, 150578, 149261, 149366, 151124, 151153, 148828, 149276, 148347, 149333, 149259, 144656, 149275, 149279, 149266, 149268, 149271, 149272, 151192, 149270, 144672, 149281, 145527, 149274, 149277, 149282, 150255, 149147, 149285, 149286, 149255, 149332, 149302, 149301, 149297, 149054, 153480, 149057, 149283, 150170, 145452, 149338, 149294, 149290, 149319, 149325, 149322, 149295, 150207, 149505, 149029, 148467, 149304, 149303, 149320, 149318, 149323, 149309, 149305, 149507, 149534, 148702, 144459, 149307, 149311, 149340, 29405, 149334, 149310, 145492, 148930, 149358, 149314, 149315, 149331, 145523, 149506, 149500, 149634, 149328, 149335, 149326, 149157, 149357, 149501, 148737, 149051, 150658, 149342, 153244, 149004, 144424, 153475, 148942, 149543, 149341, 150698, 145560, 149343, 148489, 149064, 149345, 160871, 149346, 149347, 144430, 144428, 148848, 149350, 2778, 149351, 149352, 2571, 148869, 148791, 151747, 149557, 149355, 148949, 149371, 149581, 148447, 149361, 149362, 149365, 148813, 148331, 149155, 145344, 150499, 31088, 149364, 149363, 145297, 149369, 148778, 149069, 149208, 148827, 22727, 149187, 29708, 149086, 148560, 25610, 144722, 148756, 148345, 36098, 150672, 149251, 149070, 148976, 149374, 138313, 149229, 146001, 148507, 159001, 150783, 27580, 148847, 149512, 23301, 148954, 149263, 144909, 144427, 148656, 2815, 3095, 148400, 22235, 143883, 148620, 148689, 148978, 148748, 150919, 148353, 144432, 149100, 160405, 148367, 148358, 149063, 149181, 147389, 30581, 148962, 149185, 149646, 154013, 144470, 149560, 149037, 149317, 149745, 148969, 148531, 149384, 149526, 148633, 149330, 149062, 159090, 30313, 149313, 148955, 148767, 149298, 150575, 149528, 148542, 149099, 149267, 149348, 13510, 22866, 159470, 149642, 148640, 149329, 144442, 149011, 148569, 149068, 22825, 148389, 149336, 148594, 144652, 144448, 148967, 149431, 151108, 149515, 150523, 149344, 148649, 148602, 149376, 148609, 149511, 15449, 144474, 159151, 159466, 5787, 150749, 149028, 149026, 148613, 148863, 159472, 149278, 149232, 149234, 148529, 144433, 148696, 159474, 149544, 8913, 148657, 149073, 148659, 149032, 149379, 147394, 149092, 149524, 149300, 12269, 148832, 160910, 149530, 150782, 148588, 149385, 149121, 149353, 22045, 149562, 159198, 149373, 149383, 148670, 149532, 148554, 20820, 160777, 144682, 34239, 14539, 25096, 148546, 144435, 148440, 144466, 149509, 149493, 20857, 149492, 149495, 149504, 149497, 149502, 149503, 149499, 149508, 149510, 20869, 20870, 20713, 149516, 144468, 144479, 31245, 149521, 144491, 38058, 150155, 20886, 149529, 149539, 149533, 149535, 149540, 149541, 149638, 149537, 149555, 149525, 154853, 149635, 149576, 149561, 149545, 30950, 149546, 149547, 149548, 149550, 149549, 149558, 149551, 149554, 149636, 149572, 149566, 34554, 26187, 15577, 150613, 149553, 149552, 150220, 149556, 149643, 149563, 149564, 150194, 149565, 149571, 149567, 151523, 149570, 149585, 146882, 149573, 149574, 21180, 149577, 149578, 149582, 149575, 149579, 149583, 6012, 149584, 149639, 149586, 149631, 149644, 149633, 149641, 149588, 31442, 160847, 149602, 149580, 149606, 149682, 149632, 153641, 153496, 149591, 157892, 159837, 13399, 149592, 149593, 149640, 149603, 149683, 149613, 151723, 149630, 150507, 149651, 150195, 149595, 150631, 149597, 149598, 149605, 149599, 149629, 149604, 149600, 151605, 151606, 149601, 149623, 158021, 149608, 149611, 149596, 152324, 22826, 149653, 149922, 149657, 159846, 151604, 149616, 149615, 149647, 149622, 149617, 150206, 149694, 25065, 149618, 19789, 32079, 22964, 149620, 155835, 149621, 149652, 150476, 149686, 149625, 159848, 149627, 149628, 149637, 149648, 149692, 149649, 149650, 3709, 149655, 149742, 149687, 21556, 149662, 151525, 149663, 150212, 150221, 149664, 149693, 149690, 31201, 149665, 149680, 21000, 149681, 154966, 149670, 149903, 149669, 149685, 149671, 149672, 149674, 149677, 149678, 145518, 149676, 149697, 149684, 154145, 149688, 149698, 149691, 149702, 149695, 149696, 149743, 149804, 149703, 149699, 149700, 149701, 149704, 149772, 149706, 149707, 3706, 31489, 149713, 149708, 150732, 149709, 154884, 139734, 149716, 149721, 149718, 149722, 149720, 149977, 150637, 150014, 149752, 31901, 148142, 149719, 149740, 149728, 149756, 149730, 154167, 149744, 149724, 149747, 149748, 159850, 149749, 149725, 149727, 149739, 149729, 149732, 149966, 160463, 149736, 149731, 149738, 149750, 149751, 149773, 149753, 149758, 149754, 149755, 147897, 149757, 150524, 151714, 149759, 150202, 150813, 151824, 149760, 32317, 149761, 149767, 149763, 149805, 149766, 145561, 149769, 149771, 153745, 149881, 149774, 151894, 150309, 154727, 151140, 149775, 149776, 149803, 21376, 149777, 149792, 149914, 149778, 3793, 149793, 145445, 149969, 149967, 149896, 151225, 149879, 150748, 149779, 149878, 154961, 149780, 149813, 150773, 149781, 149884, 149782, 149789, 149784, 149785, 149787, 149791, 149788, 24448, 149806, 22149, 149842, 149811, 8537, 150018, 145446, 149795, 149840, 149846, 149875, 152053, 149801, 149802, 149799, 149841, 149847, 149876, 149882, 149972, 149877, 149812, 149843, 150266, 149978, 149817, 2601, 149993, 149816, 149820, 14236, 158588, 149818, 159851, 21102, 34405, 149822, 149849, 32806, 149836, 149825, 149824, 149826, 149829, 149845, 149828, 149856, 150123, 149869, 149850, 149834, 149838, 149819, 149839, 149835, 149973, 149710, 149857, 149860, 149844, 149854, 149851, 149853, 149858, 149855, 149872, 149859, 150103, 149885, 149861, 149886, 149870, 149868, 149862, 149873, 149866, 149874, 156061, 2612, 149900, 149883, 149892, 149888, 149889, 149890, 149921, 149915, 149284, 149905, 149902, 149901, 149918, 150198, 149920, 149924, 149910, 149927, 149908, 149909, 150017, 149961, 149907, 149912, 149917, 149913, 149995, 149923, 150019, 149928, 149943, 150184, 149997, 149929, 150000, 149932, 150204, 144765, 151975, 149999, 149994, 149936, 150016, 151736, 149938, 149937, 150227, 150002, 156093, 3794, 149971, 149990, 149939, 149940, 149941, 149946, 149996, 149945, 149944, 149981, 154168, 150053, 149949, 149959, 149983, 149950, 149988, 149992, 150015, 151020, 153991, 149982, 150174, 34274, 149951, 149954, 149953, 149975, 154743, 153840, 149952, 149957, 149985, 149962, 149991, 149998, 150001, 150028, 149963, 149970, 149965, 149968, 149986, 150039, 149987, 150065, 150122, 24714, 149984, 150252, 150004, 150199, 150010, 150008, 150009, 150012, 159449, 150020, 150021, 150040, 150022, 150027, 150023, 150024, 35332, 150029, 150772, 151037, 150031, 150032, 150099, 150033, 150034, 150699, 150035, 154752, 150041, 150036, 150295, 150038, 125130, 34384, 150048, 156094, 159842, 10881, 150042, 150456, 150067, 150049, 150050, 150055, 144819, 150043, 150066, 150044, 150045, 150733, 150046, 150047, 150182, 150917, 33720, 150059, 159005, 150051, 150052, 150054, 150167, 150183, 150068, 150056, 150057, 13425, 150064, 150060, 150947, 150061, 150062, 150063, 145737, 159039, 150069, 150074, 150070, 150071, 150072, 150073, 150081, 159038, 150118, 152253, 150075, 150104, 150076, 150078, 150192, 150750, 150079, 1276, 150080, 150083, 150087, 150085, 150086, 150094, 150109, 150188, 7373, 145739, 150095, 150148, 150208, 150110, 150090, 150093, 150096, 149899, 159843, 150108, 150097, 160614, 150098, 150100, 150102, 150112, 150121, 151364, 143949, 150159, 160688, 150111, 150116, 150115, 150210, 150117, 150228, 150119, 150133, 150173, 150175, 150134, 150135, 150141, 150166, 150140, 150138, 150178, 150172, 150217, 150143, 150214, 150215, 150145, 150149, 150232, 150229, 150662, 150077, 135829, 150224, 22715, 150226, 150225, 150222, 150689, 150684, 150218, 150296, 150233, 150231, 150235, 150286, 150243, 150585, 150242, 25824, 152394, 150239, 151033, 150238, 150237, 152731, 150281, 150282, 150241, 150213, 150157, 150236, 150216, 32258, 150661, 150240, 150299, 150211, 150297, 150245, 25828, 16289, 150503, 36853, 150616, 150258, 22804, 150246, 150244, 151138, 25832, 26329, 150660, 151684, 31942, 150254, 150249, 150257, 150251, 150648, 160676, 150278, 150259, 150261, 150262, 147772, 150780, 150504, 150272, 150271, 150305, 150280, 150279, 154797, 150527, 150267, 11383, 150275, 150264, 150274, 150268, 150614, 23545, 150301, 150304, 150276, 150768, 26400, 11468, 150203, 149569, 150287, 150293, 150288, 150283, 151145, 150303, 150331, 150302, 150306, 150128, 34279, 150307, 150308, 150329, 150310, 150332, 150326, 150312, 150284, 12591, 150502, 152054, 150321, 149590, 150320, 150506, 150513, 150317, 150337, 150150, 150510, 159916, 150314, 149737, 149559, 150623, 150313, 150330, 150347, 147180, 147206, 25977, 150509, 150316, 150318, 150319, 13373, 150505, 17172, 31931, 147463, 17495, 32794, 150703, 150652, 3110, 152528, 150336, 150334, 156052, 150346, 13756, 150615, 150729, 150704, 150663, 149762, 150339, 151139, 150338, 150322, 150325, 150323, 150324, 150151, 149594, 150328, 150664, 150539, 150344, 150340, 150345, 150511, 150349, 150351, 34265, 150617, 150665, 152171, 150253, 152056, 15999, 150519, 150520, 150343, 150348, 149764, 159894, 150618, 149906, 150497, 149726, 150546, 150908, 149934, 149735, 32823, 149956, 150298, 149831, 150570, 152135, 149852, 149867, 149610, 150730, 42210, 149931, 150270, 147018, 150512, 152055, 157865, 150487, 149947, 149964, 152647, 150084, 157960, 149974, 149837, 150101, 150620, 150290, 149519, 149538, 42544, 149527, 149542, 150089, 150181, 158735, 3645, 149930, 150621, 150622, 150013, 150030, 149589, 23688, 3648, 149919, 149607, 150454, 147155, 149626, 149832, 149654, 149712, 149659, 150365, 150416, 150938, 150300, 152057, 149673, 150277, 149714, 149689, 149520, 149891, 150152, 150120, 147080, 149679, 150371, 150545, 150137, 135324, 149711, 149955, 149513, 150626, 150247, 150495, 150954, 150341, 149798, 149498, 149935, 150311, 150372, 150315, 150342, 153014, 150327, 150440, 150335, 150355, 150484, 150480, 151788, 146765, 150136, 149925, 150501, 149893, 150751, 150375, 15721, 150130, 150263, 149814, 150091, 149797, 150234, 150754, 153408, 150007, 150026, 150358, 150473, 150472, 152058, 150359, 159568, 42644, 23705, 23520, 152978, 150361, 150516, 150362, 150106, 152059, 149531, 147341, 150260, 2257, 152977, 152983, 150649, 150142, 10572, 34289, 150368, 150369, 18437, 150696, 150147, 150413, 159898, 5492, 150146, 150370, 150489, 150256, 150445, 150496, 19041, 150127, 152980, 152730, 150491, 150492, 18526, 149800, 150490, 150654, 36493, 159902, 152675, 18537, 148870, 150641, 18276, 150763, 150765, 14035, 19603, 18789, 30205, 2957, 150560, 150721, 38772, 34335, 150474, 150482, 26008, 148674, 150436, 150498, 13374, 17619, 150644, 150468, 150769, 150485, 150488, 150646, 150486, 2160, 150534, 150529, 150525, 150612, 150517, 150518, 150536, 158909, 153068, 150521, 150528, 150530, 150543, 150605, 150630, 150531, 150533, 5573, 158938, 26072, 150535, 150540, 150537, 150538, 150541, 150542, 150544, 150693, 2620, 150653, 150582, 150722, 150548, 150580, 150651, 150549, 150550, 150581, 151048, 150552, 150592, 151010, 150705, 150767, 150655, 150554, 150589, 154006, 150555, 150573, 23715, 2621, 150556, 150697, 150567, 150563, 150569, 147587, 159899, 150576, 150599, 150577, 150946, 150586, 151222, 150785, 150755, 150593, 150629, 34269, 150706, 150600, 150602, 150606, 150603, 159906, 150762, 145893, 150601, 150656, 150633, 150650, 150639, 150607, 25034, 25722, 150611, 150608, 152884, 152622, 42558, 150635, 150728, 151035, 150634, 150922, 150638, 150776, 150850, 150700, 159907, 154004, 150707, 150939, 150643, 150647, 150667, 150668, 150670, 150802, 150905, 126070, 150679, 150677, 150702, 20884, 150685, 150695, 150701, 150694, 150716, 150717, 150795, 150986, 42654, 150708, 150744, 125882, 150790, 150709, 150710, 150711, 150770, 160206, 150712, 150725, 150738, 150715, 150714, 150819, 150727, 152790, 150724, 150723, 151011, 150726, 150737, 150734, 150740, 150761, 150787, 150789, 150793, 150796, 150791, 151014, 150828, 150766, 150735, 150800, 150801, 156113, 150910, 150818, 150803, 150827, 150841, 15495, 150742, 150951, 150817, 150830, 158413, 150720, 150747, 150804, 150805, 150835, 150816, 150824, 150825, 150808, 151051, 138086, 146408, 150809, 150812, 150820, 150821, 150822, 150829, 150823, 150840, 2686, 150843, 150826, 150832, 150860, 150839, 150833, 150836, 150837, 150838, 1736, 150842, 150731, 150831, 151597, 150844, 151148, 150845, 150856, 23414, 150859, 23468, 150846, 150862, 150851, 150743, 150849, 150868, 150869, 150867, 150866, 150893, 158999, 22925, 21392, 150848, 150854, 150857, 150779, 145895, 26397, 150781, 151018, 151016, 150942, 150911, 156413, 159377, 26024, 150853, 150858, 150861, 150864, 150746, 11692, 150777, 150872, 150778, 151019, 150784, 150792, 150794, 3507, 150887, 150883, 150912, 150885, 150871, 150898, 150874, 151004, 10708, 150909, 150878, 150953, 150881, 151589, 150797, 150888, 150916, 150907, 150890, 159122, 150894, 150902, 150927, 152519, 150926, 19091, 11350, 150892, 150895, 150903, 22991, 150904, 150932, 150906, 150943, 150935, 150915, 150914, 20570, 146564, 16120, 150901, 150921, 150918, 152027, 150920, 150924, 150928, 150929, 150899, 150925, 146239, 150934, 150970, 150931, 150936, 151021, 151143, 3117, 150964, 21384, 150949, 20418, 150952, 150960, 150957, 151526, 150959, 150950, 150967, 150962, 150981, 150966, 151091, 150973, 150971, 151043, 151092, 150975, 150771, 23527, 150977, 150979, 150980, 21020, 14259, 150988, 150993, 150985, 152010, 150989, 5575, 150994, 150996, 150998, 151100, 150999, 150995, 151044, 151111, 151036, 151002, 152526, 151042, 151040, 151000, 151045, 151046, 151050, 151067, 151659, 23337, 18648, 151056, 151064, 151065, 151061, 151137, 151072, 18986, 151075, 151142, 159374, 151063, 151134, 151062, 151069, 151076, 159564, 151084, 151095, 151105, 151112, 151106, 151660, 151219, 22143, 151080, 151082, 151087, 151090, 151083, 26038, 151085, 151126, 151079, 151121, 13498, 150810, 151133, 153277, 151088, 151098, 151226, 151099, 151102, 151227, 151144, 7805, 16665, 151116, 151122, 151119, 151533, 10855, 151115, 151049, 151159, 151131, 151118, 151199, 146294, 151147, 151125, 151123, 151132, 151128, 151130, 150666, 151146, 150477, 151129, 151654, 151161, 150683, 150470, 151185, 150978, 150471, 151178, 150532, 155123, 151250, 150508, 150561, 150562, 152022, 151602, 151727, 28241, 5574, 11078, 151164, 151200, 151165, 151166, 151163, 151218, 151168, 151171, 151189, 151410, 151198, 151229, 151109, 151197, 151173, 151176, 151172, 151174, 151175, 151180, 150594, 151202, 151193, 151181, 151188, 153938, 153126, 151191, 151195, 150884, 150991, 151203, 151361, 151205, 151213, 146445, 151025, 151535, 159210, 152014, 153928, 151207, 151208, 151209, 150879, 150990, 153457, 151058, 151107, 151490, 151055, 151101, 151745, 150799, 150455, 151008, 151363, 151754, 150976, 151656, 151158, 150852, 151486, 151054, 151186, 151052, 151601, 150997, 151103, 151039, 151086, 151221, 150855, 151071, 151162, 159236, 146334, 151169, 151182, 151196, 151201, 151708, 4686, 151206, 153123, 151211, 151223, 151228, 150956, 149143, 153561, 151060, 149124, 19172, 151068, 151117, 151066, 151527, 151231, 23704, 149125, 151774, 152432, 150756, 150944, 151259, 126346, 151026, 151591, 151157, 6422, 151031, 151260, 151149, 151073, 150965, 150645, 153945, 149126, 153663, 151074, 158270, 150877, 151637, 151077, 150882, 149112, 30350, 151081, 150891, 151151, 150583, 151592, 151598, 151631, 151458, 150625, 151239, 150642, 149122, 150223, 151224, 150958, 150659, 150624, 139915, 3343, 149113, 160513, 151340, 146953, 149111, 149808, 149103, 149133, 151734, 151473, 149141, 149131, 149102, 150595, 149127, 6423, 151479, 151152, 150923, 150598, 14000, 150230, 150572, 151668, 153658, 149117, 150900, 150930, 151449, 159910, 151241, 151242, 151246, 160884, 150933, 151238, 151236, 1552, 151240, 151235, 151234, 151245, 151237, 6724, 151243, 151769, 160625, 1553, 151244, 151593, 150676, 151251, 151717, 151411, 151247, 1568, 150587, 151256, 150590, 150547, 151249, 151252, 151253, 152385, 151642, 151248, 151254, 151093, 17882, 151257, 150526, 151594, 2726, 151534, 153865, 150422, 151562, 150982, 150610, 36503, 151646, 151097, 150571, 150438, 151468, 151664, 127281, 151414, 151262, 151693, 150591, 150609, 150636, 160302, 151409, 151482, 29720, 13292, 151413, 17382, 150865, 150596, 151590, 159376, 151220, 151549, 150627, 151665, 150446, 151053, 151403, 151434, 23425, 153847, 151057, 26477, 12864, 148030, 151338, 151505, 151694, 23494, 151550, 150961, 151190, 149289, 148285, 151522, 151059, 151339, 152451, 150559, 146293, 151520, 152720, 151141, 151492, 151462, 3146, 153896, 149039, 7314, 152033, 140432, 141385, 151496, 151532, 151545, 22698, 151427, 151430, 151738, 151435, 151438, 151446, 151461, 151465, 151584, 151439, 151440, 151519, 151713, 151451, 151454, 151470, 151466, 151575, 151463, 151464, 151488, 151547, 151475, 151574, 151476, 151478, 152085, 19117, 151512, 151517, 30185, 151538, 151531, 151931, 151556, 151551, 15597, 15389, 151541, 151540, 151595, 16096, 151600, 151554, 135146, 151577, 151555, 151578, 151596, 151579, 151623, 151572, 151662, 151599, 13913, 151560, 151564, 151565, 151569, 151573, 151570, 151715, 151581, 151582, 151588, 151583, 152045, 151586, 22875, 151587, 151607, 151621, 151624, 151641, 151632, 151608, 151609, 155371, 151639, 153786, 151612, 151719, 151630, 151628, 151622, 151613, 151643, 3512, 151614, 3506, 151666, 160632, 151615, 151625, 151619, 151620, 151626, 151722, 151627, 151633, 151634, 20227, 151638, 151640, 151655, 151657, 151645, 151644, 151647, 151652, 151731, 21542, 151649, 151682, 151674, 151650, 151653, 151663, 151669, 151670, 152166, 151704, 3513, 151672, 151673, 151692, 151691, 151721, 151675, 151679, 151676, 151677, 151698, 160633, 3515, 151681, 151685, 151720, 151686, 151724, 155098, 151688, 151690, 151725, 151706, 151733, 151671, 151712, 147535, 151711, 151716, 151365, 151726, 151773, 151815, 151728, 151729, 151752, 151737, 151740, 151777, 151746, 10768, 151742, 151744, 151748, 151751, 156697, 151764, 151755, 151763, 151756, 3634, 151757, 151759, 151750, 151784, 151761, 151765, 151772, 156694, 151771, 151775, 151780, 151797, 151789, 151782, 151785, 151946, 152079, 151790, 152032, 151787, 152029, 151811, 152106, 151816, 151796, 151798, 151799, 151801, 151804, 151957, 157773, 151803, 151809, 151810, 151812, 151814, 151813, 151818, 152048, 154130, 152109, 151837, 160168, 151919, 14384, 151836, 7133, 152108, 151819, 152107, 158448, 29865, 151858, 151820, 151840, 153419, 152369, 151821, 151825, 158769, 25402, 153689, 12107, 151832, 151831, 151888, 151859, 151890, 152518, 151839, 151914, 151897, 35635, 154008, 151838, 151912, 151942, 151889, 151848, 151905, 151949, 151864, 151853, 151762, 146013, 151845, 152008, 151854, 152049, 151857, 151856, 22476, 21943, 30283, 151885, 145205, 151861, 151862, 142066, 151879, 151960, 151948, 151883, 151865, 7931, 151906, 151907, 151916, 147048, 151863, 151878, 151915, 151874, 151870, 151880, 151951, 151909, 151908, 151871, 151875, 151877, 151872, 151903, 151884, 151992, 151886, 151887, 151899, 151952, 151896, 151996, 152005, 151902, 151904, 151911, 145673, 151913, 151995, 151930, 151927, 151918, 151922, 151923, 151925, 151920, 151928, 158555, 23500, 154182, 151929, 151935, 152234, 151943, 151941, 151938, 138811, 151933, 152030, 151956, 151945, 151958, 151953, 151954, 151962, 151967, 152769, 151964, 151808, 7172, 151987, 151966, 151965, 26854, 151972, 151979, 151968, 151971, 145678, 139029, 151990, 22298, 151991, 151969, 151793, 151718, 151730, 151735, 151976, 151977, 151984, 152017, 152025, 151635, 151997, 154751, 151994, 151988, 151989, 151985, 151576, 151982, 152018, 145685, 151999, 151648, 3188, 152464, 159417, 151986, 152105, 151603, 151881, 152001, 158560, 23692, 151898, 151487, 151504, 151585, 151955, 152050, 152086, 139183, 139326, 23481, 151617, 151661, 151709, 22429, 152347, 152004, 151940, 151559, 152007, 152019, 146647, 159914, 151822, 151568, 151768, 152373, 152015, 151873, 154747, 15278, 139449, 142740, 145354, 151467, 151155, 151786, 152167, 151457, 152016, 152012, 151910, 144774, 138628, 159920, 3354, 151483, 151891, 152020, 151514, 152021, 22431, 151830, 151947, 159921, 151580, 151469, 151507, 151944, 152031, 151701, 159918, 151529, 151851, 151876, 152111, 152051, 152034, 153586, 159924, 145689, 151973, 152043, 151794, 151758, 151893, 152028, 153265, 152035, 151860, 152075, 151426, 151882, 152168, 14323, 152154, 151855, 152498, 22093, 151932, 151866, 152046, 152044, 151867, 151408, 151868, 151629, 151921, 152047, 24153, 152041, 152096, 26094, 154885, 151963, 151543, 152077, 152093, 151546, 152042, 152110, 152009, 151429, 152098, 152097, 3483, 6714, 152113, 146028, 151472, 152116, 151431, 151432, 151471, 153275, 145227, 152084, 152066, 152073, 152080, 152114, 20798, 151553, 152115, 152264, 12882, 152076, 151474, 15407, 152112, 146645, 21246, 151450, 152295, 145783, 139859, 151835, 151846, 151407, 20920, 23542, 151842, 21254, 152429, 152308, 146207, 151844, 25575, 152118, 152120, 151477, 151901, 151539, 151412, 151843, 151453, 151436, 152067, 152321, 151841, 152089, 152119, 151970, 152074, 21275, 147382, 151961, 151415, 152092, 149980, 152090, 21371, 154493, 154494, 147891, 152100, 152078, 152081, 151926, 152122, 152123, 152124, 152121, 154764, 152294, 152302, 152127, 152132, 152128, 152130, 22100, 138019, 152260, 140965, 31504, 152102, 152131, 152088, 152094, 21221, 152261, 152296, 152101, 152125, 152137, 151455, 152024, 152298, 154539, 152430, 152281, 152590, 152303, 152501, 152467, 152257, 152445, 152328, 144777, 146214, 152299, 152338, 17645, 152265, 152466, 144511, 3619, 152268, 152297, 152412, 125971, 152503, 152271, 152273, 152424, 152478, 152274, 152335, 147204, 152277, 152417, 152280, 152279, 152293, 7365, 152291, 152327, 152496, 152285, 152310, 152309, 152314, 152316, 152319, 154608, 152320, 147205, 152340, 152413, 152428, 152443, 152426, 153249, 152419, 152422, 152040, 152420, 140096, 140610, 152418, 153260, 152447, 152366, 152301, 152414, 152367, 152380, 152376, 152425, 152370, 152416, 152507, 153342, 152415, 153931, 152378, 152383, 152381, 152379, 152525, 152384, 152482, 152492, 152375, 152555, 152404, 152442, 152406, 152409, 152408, 152396, 152400, 152401, 152423, 152433, 152435, 152437, 152438, 152441, 152440, 3815, 152439, 152448, 152446, 152522, 152452, 152477, 152500, 153537, 152454, 152455, 159743, 152494, 152453, 152459, 154808, 152461, 152458, 152489, 152460, 152486, 152462, 152457, 152474, 152505, 153578, 152475, 152499, 152515, 152511, 152476, 152485, 152493, 152504, 152513, 152508, 152509, 152510, 152514, 152527, 152517, 152572, 152619, 152524, 152593, 152537, 152901, 152641, 150913, 152615, 152541, 152546, 152544, 152547, 152548, 154232, 11250, 6750, 152545, 152543, 152557, 152567, 152754, 152554, 152550, 152549, 152577, 152551, 152655, 152553, 152565, 152611, 152630, 152470, 152471, 152660, 152601, 152569, 152421, 152568, 152605, 152612, 152618, 152587, 152604, 152571, 152540, 152578, 152613, 152634, 152635, 152172, 152588, 153230, 152581, 152585, 152584, 152583, 152483, 152636, 22013, 152643, 152640, 152639, 152070, 152133, 152632, 152530, 152322, 7765, 20954, 152592, 152323, 152657, 152644, 152480, 152645, 152153, 159945, 152912, 152648, 152646, 152582, 152623, 153121, 152104, 152662, 152479, 159947, 155036, 20989, 152664, 152713, 152170, 153558, 152387, 152069, 152921, 152072, 152916, 152155, 20600, 152938, 152932, 152750, 152386, 152820, 152538, 152491, 152468, 159980, 155039, 152668, 152561, 152707, 152159, 151030, 153362, 152824, 152768, 152169, 152068, 153358, 140789, 152603, 152822, 152677, 153114, 152818, 152065, 152156, 152490, 152637, 152954, 152071, 154225, 153386, 152064, 152382, 152898, 147893, 153010, 16339, 152262, 152276, 153524, 152256, 152259, 152965, 152434, 159043, 152362, 152506, 153006, 153007, 152756, 152902, 152778, 152282, 159988, 152300, 152734, 152925, 152691, 152922, 152927, 152828, 152967, 153409, 159006, 152365, 152305, 152337, 22589, 152436, 152251, 9313, 152325, 152536, 147210, 152289, 152830, 153017, 152964, 9314, 152840, 152799, 156249, 152835, 152837, 152834, 152892, 160617, 160497, 152306, 153388, 152512, 152829, 140191, 152542, 152339, 152431, 153756, 153037, 152395, 152862, 152679, 152881, 152848, 152991, 153013, 22175, 152292, 152907, 152956, 152263, 152860, 152254, 152891, 153327, 152663, 152939, 152472, 152450, 152851, 152676, 152844, 152858, 152407, 152777, 152742, 152843, 152531, 152920, 153413, 152402, 152857, 152533, 152372, 152789, 152374, 152795, 152845, 152941, 152444, 152469, 152786, 153395, 152957, 152399, 152390, 154898, 145698, 152973, 152846, 152849, 152591, 152963, 152923, 152761, 152670, 152672, 24855, 152671, 152552, 152914, 152521, 152487, 1145, 152497, 152755, 153029, 153396, 153018, 145395, 152427, 152909, 152930, 152894, 152919, 153024, 153110, 152267, 153036, 141120, 153023, 153025, 152966, 152867, 152463, 152674, 152940, 152859, 152861, 152917, 152589, 153067, 152933, 152456, 152313, 152711, 154478, 152269, 152763, 152951, 16760, 152883, 152981, 4891, 153039, 153031, 153033, 145586, 152403, 154777, 153030, 144924, 152726, 152703, 152947, 152874, 152781, 152872, 152785, 152950, 152942, 152685, 152871, 152952, 152753, 152758, 153693, 152953, 5040, 152586, 152766, 152958, 153968, 152878, 152745, 152796, 152794, 152955, 152948, 153390, 152410, 152317, 152779, 153055, 16259, 153391, 153056, 153525, 153042, 152969, 152788, 153046, 152783, 153643, 152879, 160039, 153393, 154890, 152689, 145782, 153392, 153526, 153385, 154965, 152579, 152771, 152877, 152998, 152687, 152776, 152996, 153394, 152797, 152970, 22219, 152574, 153089, 152960, 153374, 144781, 141371, 152961, 152889, 152748, 7376, 152999, 153000, 152398, 22290, 153932, 152535, 153762, 152989, 152979, 152665, 152990, 152936, 153397, 153880, 152330, 153377, 152673, 22187, 141399, 145195, 141412, 152520, 152705, 153584, 152706, 152218, 155395, 152377, 154017, 152875, 154891, 153115, 152693, 7434, 153399, 153749, 152638, 152800, 152803, 153122, 145702, 153116, 154158, 153530, 152805, 152342, 152807, 152934, 152855, 153412, 153310, 152959, 153001, 152523, 153407, 157500, 152821, 152811, 153354, 152744, 152856, 153476, 153073, 145027, 154018, 152838, 154794, 153312, 152924, 152831, 153118, 152984, 141815, 152992, 1205, 152833, 153332, 153410, 152817, 152681, 152725, 153187, 152809, 160310, 152311, 152866, 152825, 153119, 144779, 152813, 160316, 155446, 152836, 152732, 153170, 152841, 152708, 153744, 152743, 152946, 153176, 152360, 157692, 152853, 152852, 153352, 152669, 152709, 153328, 152738, 142252, 152737, 159465, 152814, 153411, 152816, 144756, 144766, 152873, 4941, 152718, 152609, 152870, 153188, 153559, 27167, 145422, 152607, 22888, 21932, 155724, 152606, 152987, 152863, 145427, 152473, 153171, 152865, 152686, 153531, 153733, 152749, 26158, 153192, 153330, 152887, 152885, 152995, 153125, 153501, 16279, 22863, 7301, 154219, 152972, 152928, 153533, 153111, 152886, 158762, 5943, 152876, 153366, 152880, 152710, 153070, 23438, 145731, 152988, 152740, 153117, 153109, 153313, 152678, 152847, 23447, 145599, 152266, 152700, 152810, 152642, 153177, 159927, 22982, 152823, 152819, 152906, 153747, 152854, 38800, 5332, 152272, 153112, 153120, 153113, 153174, 153175, 147786, 145377, 152716, 5422, 145601, 153186, 152721, 153172, 153173, 153214, 153220, 149375, 158656, 153383, 143100, 152962, 153189, 153191, 153414, 153190, 153207, 153417, 153639, 153334, 153573, 153754, 153209, 153637, 153415, 153216, 154218, 153224, 153266, 153267, 153257, 153416, 153748, 153642, 153970, 154217, 153270, 22969, 22062, 155684, 153422, 153356, 153264, 153640, 154911, 153314, 152974, 153421, 153279, 153382, 146691, 153424, 153688, 153355, 153333, 153752, 153420, 152975, 158569, 155726, 154177, 37586, 143193, 153268, 25489, 153306, 153335, 6569, 153289, 153284, 153343, 24732, 153381, 153308, 15077, 16917, 153344, 153384, 153331, 153423, 153439, 5334, 153345, 147691, 153341, 153325, 153326, 153305, 153346, 153315, 153316, 153450, 153781, 153347, 153348, 153403, 153329, 31643, 153425, 153433, 160773, 153570, 153782, 153322, 153339, 153705, 153337, 153516, 27725, 154895, 153340, 153360, 155778, 153560, 153323, 153365, 153936, 153372, 153451, 154220, 153753, 153452, 143072, 153629, 153483, 153474, 153823, 153572, 153581, 153252, 153380, 8705, 146751, 153376, 153378, 153379, 153387, 153389, 153441, 153679, 155104, 153400, 24727, 153482, 153401, 147373, 153402, 153404, 153405, 153479, 154352, 147929, 153626, 159581, 153426, 153765, 153427, 153428, 153429, 153430, 153431, 153432, 153513, 153704, 153515, 153634, 153443, 21786, 153448, 153574, 153472, 153446, 153455, 153447, 153444, 153514, 153478, 153481, 153453, 153460, 153473, 153454, 153468, 153499, 153575, 153523, 153800, 153465, 153466, 153470, 153707, 153508, 153495, 154221, 153477, 155919, 153498, 145350, 32110, 154222, 153485, 153520, 153521, 153506, 155993, 143897, 153471, 153504, 145259, 143749, 153486, 153484, 153491, 153489, 154223, 153488, 153568, 155930, 153974, 154179, 143825, 143822, 143950, 153490, 153522, 153576, 153493, 153950, 153494, 153505, 153678, 154224, 153502, 154037, 153577, 153507, 153509, 153512, 153511, 153543, 153544, 153564, 153580, 145137, 145043, 153778, 153551, 153590, 153675, 153566, 8274, 153579, 153569, 153542, 153556, 154339, 153546, 153719, 153767, 153646, 153779, 153540, 153725, 153777, 154901, 145090, 153609, 155099, 154226, 153545, 153588, 153552, 153553, 153555, 153562, 153557, 153563, 153565, 153567, 153780, 155389, 153622, 153788, 157599, 153647, 153729, 154227, 8279, 153596, 155391, 154231, 151028, 20815, 153591, 153783, 153589, 154228, 153636, 153592, 154229, 153648, 153741, 153650, 153594, 33743, 153595, 154230, 153598, 150886, 153649, 153737, 153153, 144961, 153676, 153739, 153785, 153811, 153939, 153633, 153776, 153793, 151029, 153627, 13180, 147362, 8614, 153692, 153631, 153630, 153612, 147028, 153635, 153743, 153661, 144628, 144648, 144826, 153620, 153619, 152570, 1257, 153628, 143660, 153616, 154233, 144812, 146305, 153617, 153621, 153157, 153625, 20790, 156108, 153656, 153652, 153651, 153655, 153654, 153434, 154234, 153923, 153732, 21108, 6621, 153742, 153920, 153787, 153660, 153915, 153669, 153687, 153659, 153672, 153665, 153670, 153683, 7812, 153690, 157593, 153668, 153667, 153662, 153674, 146576, 153709, 153706, 153708, 23407, 153677, 153681, 153685, 153686, 139091, 153710, 153711, 146938, 153697, 153698, 153701, 3868, 153695, 153738, 153746, 153691, 153790, 147066, 147595, 153702, 153717, 21111, 21147, 1909, 153726, 153718, 153721, 153723, 153724, 153794, 147912, 148010, 153796, 153889, 24568, 153735, 153736, 153764, 153755, 153774, 153821, 153772, 153770, 153769, 153775, 153458, 153895, 153797, 153940, 153833, 153803, 155710, 153981, 153917, 153798, 153834, 153832, 155559, 153836, 153987, 153810, 153848, 148078, 153958, 160896, 153816, 153900, 153863, 153813, 153818, 153820, 159936, 8378, 153879, 153824, 153828, 153897, 153808, 153924, 153853, 153829, 153831, 153955, 153839, 153812, 154888, 153875, 153894, 153837, 153883, 154892, 153817, 153874, 153886, 153842, 153845, 153611, 153854, 153855, 3947, 148212, 153857, 153872, 153861, 153858, 153862, 151869, 145762, 153870, 22732, 155376, 153871, 155088, 153298, 5138, 18961, 153877, 153885, 159934, 153884, 153888, 154010, 153881, 153911, 153734, 153887, 159935, 8822, 148230, 153946, 158944, 153890, 153891, 153893, 23420, 153906, 153994, 153913, 154022, 160874, 5862, 153907, 153956, 155560, 153901, 153905, 153903, 153910, 153929, 153914, 22882, 153908, 160527, 153918, 153943, 153944, 153957, 153988, 153184, 153941, 153715, 148324, 153952, 153791, 153951, 154855, 153600, 153673, 22513, 154334, 22515, 148363, 153997, 153607, 153615, 153645, 153183, 154677, 5838, 154056, 145229, 144790, 153978, 153263, 153269, 154011, 154007, 159007, 4449, 156273, 154028, 154553, 153937, 155392, 18646, 153291, 153973, 153975, 153297, 153998, 156304, 22871, 144736, 144951, 153300, 153986, 154009, 153318, 154626, 153976, 153999, 154001, 145004, 153977, 153983, 153229, 154025, 153369, 153193, 153993, 154024, 153995, 153992, 15483, 154014, 154023, 154002, 154005, 154031, 159028, 159594, 153282, 145288, 149082, 154015, 154003, 154021, 154035, 154036, 154041, 154040, 8772, 154045, 154054, 22733, 154051, 156472, 154049, 154052, 154038, 154043, 154067, 154047, 154050, 154055, 154058, 154059, 156109, 159689, 154026, 154062, 154176, 148914, 154027, 154066, 154063, 154069, 154070, 155089, 154000, 154072, 154075, 21753, 154159, 154077, 153368, 154087, 155190, 153859, 154078, 148946, 153804, 153806, 22763, 153307, 157615, 153440, 155396, 153807, 153922, 154074, 154121, 153925, 153927, 154085, 158615, 21941, 154083, 154082, 154899, 154171, 154090, 151005, 154091, 154096, 153618, 154676, 151001, 154151, 149024, 153259, 154749, 154160, 154099, 139841, 154161, 153763, 145448, 145449, 153604, 22737, 154163, 153608, 154120, 153714, 153541, 154818, 145441, 153500, 22220, 153614, 154215, 153538, 154020, 154504, 154147, 154106, 154105, 154112, 154113, 153916, 154332, 5725, 154046, 152727, 159484, 153809, 154115, 154116, 149288, 149293, 154127, 154675, 153602, 154150, 147004, 153795, 150011, 159156, 153801, 23650, 149339, 149354, 153760, 154879, 153449, 153301, 141476, 153218, 154012, 159147, 144706, 22824, 153682, 154156, 154140, 153860, 153461, 153727, 154473, 153182, 153712, 154157, 154137, 154138, 153761, 154142, 154212, 39766, 149666, 154076, 154095, 153838, 151003, 153730, 154513, 154114, 154328, 159160, 153835, 160132, 6197, 153241, 154148, 154330, 154331, 154135, 154133, 155017, 149668, 153445, 20939, 24056, 153758, 153841, 153867, 154643, 160133, 153364, 153357, 153442, 152792, 154165, 153219, 160140, 156625, 156580, 153371, 153771, 154155, 154149, 154164, 7264, 14493, 156584, 156585, 154169, 155393, 154172, 154173, 154175, 155086, 23265, 154174, 155004, 152729, 153856, 154327, 153873, 154335, 155405, 153814, 6428, 155085, 155186, 153892, 153456, 154068, 11127, 149786, 152839, 154073, 151007, 154016, 154092, 146750, 146749, 154139, 146748, 160031, 154350, 155018, 22883, 151032, 153159, 153035, 154210, 153261, 160045, 7146, 153299, 154329, 154819, 153912, 153822, 154211, 5335, 154914, 153972, 153696, 154190, 155019, 160043, 154850, 1076, 23269, 153287, 153852, 153703, 153996, 154814, 153694, 153467, 154467, 34224, 153185, 3480, 160322, 155466, 153338, 153349, 153534, 154214, 153819, 160135, 1401, 152937, 153680, 154351, 154815, 154061, 147094, 154213, 156735, 155195, 153292, 151034, 154093, 157948, 154907, 153750, 151009, 5367, 22691, 154196, 153285, 153196, 155060, 155091, 154707, 159218, 158456, 156757, 158830, 152864, 152683, 153044, 152712, 155541, 154356, 154689, 154436, 154688, 154816, 154904, 154705, 154858, 155187, 149821, 149948, 153623, 155034, 154374, 154360, 154364, 156563, 160137, 154817, 154755, 154378, 154972, 154393, 154369, 154316, 153008, 155087, 154476, 155192, 154371, 155188, 154373, 154820, 154375, 153664, 5408, 154382, 154823, 150105, 150114, 146729, 155194, 153700, 154824, 23184, 154721, 156088, 154826, 155196, 154388, 152252, 155047, 154392, 154864, 16380, 153751, 156090, 155197, 154829, 154862, 150356, 150131, 155198, 154827, 155183, 154968, 2209, 154483, 154832, 155048, 153969, 154865, 154969, 154750, 154507, 154970, 153846, 154433, 153866, 154753, 153965, 150493, 150558, 153963, 154508, 154620, 160396, 154401, 154754, 153768, 153899, 154100, 154833, 154411, 156965, 157037, 155202, 152702, 154528, 157132, 154866, 154546, 154756, 154834, 154479, 154975, 154549, 154867, 154978, 154510, 154639, 154414, 154835, 154480, 154757, 157086, 154442, 154973, 7516, 154482, 154976, 154836, 154763, 154554, 154869, 154550, 150690, 150604, 154837, 5312, 154977, 154446, 154551, 154765, 154838, 154871, 154840, 154422, 155439, 154071, 17037, 154434, 154423, 154848, 154872, 154529, 154873, 154506, 154979, 154462, 154463, 154438, 154441, 154521, 154511, 154845, 154485, 154502, 150628, 150681, 154515, 154440, 154557, 154842, 154444, 154447, 154466, 154474, 154445, 154555, 154875, 154484, 154449, 154386, 154556, 154844, 154516, 158626, 154889, 154486, 154766, 154487, 154559, 154881, 154488, 154846, 154847, 154489, 154490, 154877, 154558, 154496, 154495, 150713, 150811, 150940, 154497, 154498, 154499, 154514, 157949, 154500, 154517, 154505, 154849, 154509, 154990, 154524, 154519, 154520, 22903, 154852, 154346, 154527, 154533, 154537, 154532, 154542, 154543, 159446, 156009, 154538, 154599, 154540, 154545, 154790, 154535, 154605, 154609, 154541, 154544, 154548, 155125, 154552, 155374, 154563, 154637, 157002, 160273, 154561, 154854, 155136, 154963, 151849, 154601, 157260, 154640, 154638, 151094, 151113, 149675, 154856, 154613, 154767, 154909, 155111, 154886, 154958, 154908, 151167, 22148, 154768, 154591, 154625, 154598, 154680, 159776, 7655, 154604, 154642, 154857, 156098, 154622, 154603, 154641, 160533, 5582, 154606, 154607, 159623, 154636, 154610, 11219, 154621, 154860, 154960, 154679, 154996, 154627, 23566, 154630, 154629, 154685, 154811, 154686, 154632, 154682, 154684, 154681, 151183, 154687, 154696, 154698, 154861, 154692, 154693, 154694, 154791, 155005, 155287, 154631, 154695, 156455, 154709, 154708, 154799, 154812, 154717, 156435, 154720, 154940, 154938, 154724, 154798, 155213, 155082, 154725, 154910, 154894, 154730, 154731, 154746, 154732, 160552, 154741, 154742, 154795, 154770, 154781, 154774, 154956, 154863, 154775, 154783, 154786, 154941, 155132, 154778, 154787, 154800, 160553, 154806, 153002, 153005, 154357, 152826, 152832, 149715, 154954, 154988, 154915, 154985, 154917, 154918, 155055, 154920, 5588, 4068, 23270, 154928, 154922, 154967, 154989, 154925, 154964, 155000, 154926, 154955, 154932, 154959, 155003, 155052, 160154, 5659, 155276, 20949, 154937, 154939, 154942, 154944, 155124, 157258, 153009, 22750, 154948, 154945, 154943, 154946, 154947, 154952, 155105, 160153, 160155, 5723, 151210, 155051, 154951, 154949, 154984, 154983, 154953, 154962, 20451, 154980, 154986, 154981, 154982, 154994, 154995, 155001, 155065, 155009, 155014, 159034, 155035, 155010, 155012, 155215, 156754, 155043, 155011, 7656, 155007, 155022, 155046, 155024, 155025, 160582, 155026, 155050, 156642, 21676, 160401, 155031, 155027, 155075, 155038, 160160, 155028, 155053, 155029, 155030, 155037, 155044, 155040, 144711, 155041, 155042, 155054, 155076, 155056, 155057, 155064, 155063, 155073, 155273, 155074, 155079, 155093, 155061, 155062, 160158, 7680, 155071, 155068, 155100, 155067, 155069, 155083, 155070, 155084, 155077, 155080, 155078, 8369, 155313, 155081, 155101, 27363, 155090, 155092, 155094, 155096, 155097, 2767, 155112, 155095, 155127, 155108, 155102, 155109, 159905, 1605, 155114, 155110, 155119, 155144, 155113, 155122, 155889, 155126, 22049, 155148, 155115, 155117, 155134, 155118, 155128, 156212, 155167, 155130, 155129, 155135, 155137, 155138, 21651, 155142, 155141, 159611, 155143, 155146, 155149, 155147, 155289, 155265, 155145, 155177, 155150, 23492, 1872, 155151, 155152, 155769, 155173, 151017, 157778, 155174, 155169, 154822, 157553, 155176, 154216, 155153, 155384, 155155, 155166, 151070, 19645, 155160, 155156, 156121, 152774, 155175, 155268, 154913, 155385, 155352, 159362, 155179, 155180, 155185, 155200, 155270, 155275, 155214, 154042, 158447, 155204, 154403, 155277, 154421, 4373, 154471, 153016, 4000, 22274, 14781, 153012, 154390, 155274, 154409, 155207, 155266, 155045, 154600, 154813, 154420, 154343, 157600, 154635, 155212, 148167, 154578, 154457, 154359, 154597, 154788, 154936, 154361, 154477, 155267, 152787, 157644, 154624, 154029, 139290, 152905, 154690, 155106, 155264, 153961, 154372, 2718, 154342, 9253, 153666, 155354, 155116, 155288, 157596, 153034, 152842, 21890, 160165, 154370, 155355, 153731, 154697, 154887, 16861, 154726, 154628, 153021, 157597, 154700, 151651, 155164, 155366, 155373, 155182, 154443, 154560, 155222, 155272, 154355, 154701, 153979, 155163, 154703, 154110, 154377, 155170, 11520, 154030, 154704, 155401, 11093, 155181, 15401, 155642, 155178, 155168, 154437, 27845, 155072, 154729, 2375, 154592, 155237, 155203, 155356, 155020, 154523, 155238, 155285, 152326, 154435, 155271, 154587, 15517, 154773, 159788, 155211, 3845, 155228, 146176, 155140, 155059, 23293, 23304, 157815, 154512, 154366, 8410, 155365, 153699, 155023, 157896, 154987, 147350, 16051, 152733, 153015, 155286, 155283, 155284, 155404, 155290, 156447, 155292, 155293, 152935, 155394, 152949, 155291, 155351, 158717, 10871, 156992, 155367, 155303, 155302, 155350, 155304, 155305, 155306, 155361, 157617, 155309, 155368, 26115, 22174, 155311, 155312, 155912, 155316, 155314, 155383, 158768, 1233, 155337, 155332, 155353, 155333, 155402, 155334, 25702, 157604, 155336, 34621, 155397, 157855, 31314, 155362, 155363, 155364, 155369, 155390, 155370, 155372, 155411, 155375, 155377, 155378, 155379, 155387, 155380, 155382, 155388, 156500, 155386, 155398, 151776, 151823, 151852, 155406, 155407, 155408, 155399, 155410, 155433, 155429, 155494, 155457, 156652, 155414, 155415, 151917, 155475, 155556, 155458, 155427, 155431, 155432, 156220, 155428, 155426, 155417, 155418, 155542, 155536, 155419, 155498, 155423, 155430, 155424, 155489, 155520, 155537, 155435, 2120, 155436, 155967, 155437, 155438, 155532, 155534, 155555, 154593, 155839, 155444, 155447, 155452, 155448, 158070, 155449, 155450, 155771, 155451, 157060, 155570, 155645, 155454, 155453, 22893, 155442, 155456, 159622, 155481, 151934, 155503, 155459, 155794, 155476, 155461, 158067, 123951, 155480, 155616, 155648, 155471, 155478, 152283, 157907, 22968, 155465, 155493, 155468, 155470, 155467, 151936, 155464, 155469, 155491, 155490, 22971, 155607, 155487, 155492, 155486, 155510, 155599, 152000, 155612, 155499, 155500, 22770, 155637, 155851, 155516, 155517, 155501, 151443, 155506, 155511, 155512, 19940, 155649, 155721, 155540, 155515, 155530, 152023, 155572, 155557, 154793, 155593, 159795, 158140, 155546, 156134, 155573, 155578, 152982, 152331, 155576, 155548, 155550, 155594, 155552, 155553, 155558, 155565, 155561, 155554, 155634, 155562, 155563, 11809, 155564, 157614, 151892, 155571, 155574, 154019, 155579, 155643, 155636, 155581, 155653, 155603, 155880, 155580, 155614, 155582, 23549, 155583, 155585, 155589, 155586, 155605, 155675, 155588, 151390, 155598, 155591, 155658, 155703, 155601, 155608, 155610, 155657, 155609, 155678, 158602, 155613, 155719, 155615, 155617, 156755, 155764, 155618, 155619, 155717, 155620, 155659, 155623, 155597, 158605, 155627, 155622, 155647, 155625, 22702, 155639, 155631, 155632, 155633, 155638, 155630, 156794, 155484, 155661, 155660, 155670, 23000, 156114, 155674, 155669, 155673, 155667, 155671, 155676, 156068, 155683, 155682, 155679, 155691, 23160, 155693, 155689, 155690, 156782, 155687, 155688, 155695, 155715, 155815, 155760, 155702, 155701, 22676, 155768, 156767, 22176, 155699, 155709, 155837, 156099, 155706, 23260, 22817, 156122, 155518, 155707, 155704, 156810, 155739, 155708, 155776, 22550, 23224, 22537, 155723, 155767, 155722, 155725, 155731, 155740, 155774, 155775, 152288, 155735, 155737, 155765, 155763, 160683, 155733, 155741, 155750, 942, 155780, 155746, 155497, 22548, 155766, 155753, 155755, 155756, 155868, 155757, 155792, 155800, 156221, 155770, 156288, 155772, 155793, 155773, 19295, 155828, 155752, 155519, 155777, 155791, 155795, 155789, 155521, 156250, 155335, 155816, 155813, 155823, 155814, 155819, 155838, 155832, 155821, 155830, 155917, 155479, 155840, 155858, 156251, 155908, 155850, 152341, 155946, 155841, 155400, 155844, 155847, 155846, 155845, 155863, 155848, 152363, 152411, 155852, 155904, 155873, 155854, 155859, 155853, 155855, 155893, 22501, 155860, 155864, 155874, 22188, 157329, 156131, 155879, 155891, 155872, 155898, 155906, 155425, 22581, 155877, 155875, 155881, 155876, 21134, 155884, 155886, 155883, 152405, 156342, 155901, 156448, 155887, 155892, 23230, 23055, 155909, 156077, 152465, 22910, 155584, 159573, 155964, 155567, 155885, 38115, 23238, 158367, 155888, 155982, 155961, 159272, 155914, 156222, 155911, 155916, 156005, 156337, 155413, 155890, 15896, 155939, 155957, 24242, 155923, 156002, 155926, 156555, 155928, 155977, 155943, 155969, 155963, 155929, 155931, 159471, 140388, 155925, 155932, 155985, 155934, 155959, 23221, 156028, 155935, 155938, 156053, 156416, 155936, 155937, 155940, 155941, 155984, 23264, 22884, 158406, 155381, 155981, 155968, 156417, 155945, 155953, 155950, 155948, 155951, 155949, 20794, 155403, 155966, 155970, 156022, 155972, 155983, 155979, 155980, 155974, 155989, 155987, 156024, 156311, 155988, 155990, 155991, 155992, 155994, 155995, 22741, 23051, 155900, 155624, 156025, 155996, 155997, 155998, 22744, 156054, 156020, 155999, 156000, 156049, 23136, 22757, 155986, 156011, 156003, 156013, 151027, 156015, 158844, 156030, 22482, 944, 156032, 156035, 156014, 156125, 152976, 156034, 22185, 156036, 156038, 156047, 156442, 156331, 153019, 152931, 11312, 152680, 156012, 156016, 156044, 156050, 156081, 156058, 156057, 156063, 156064, 156066, 156072, 156074, 156111, 156104, 156096, 154410, 154957, 156076, 155269, 152868, 153069, 152772, 156039, 156123, 156102, 156082, 156084, 156085, 156092, 155672, 156087, 153054, 152762, 156105, 155736, 151937, 159641, 156107, 156243, 156444, 155867, 156117, 156224, 156116, 156762, 156126, 156210, 155711, 156247, 153528, 155310, 155315, 156118, 156553, 156124, 156127, 152723, 156135, 155473, 156143, 156225, 22644, 22178, 156234, 155600, 155462, 156457, 156445, 155595, 156142, 156226, 153722, 155606, 155107, 156228, 155882, 159574, 153792, 160159, 158705, 155915, 155924, 159687, 155942, 156353, 155958, 155577, 156211, 160167, 160169, 144901, 155720, 155416, 138373, 139316, 155441, 155443, 155434, 157616, 155628, 156235, 156227, 22806, 155445, 155455, 22898, 155460, 21571, 155421, 155727, 23006, 155738, 155656, 156764, 160042, 15961, 156223, 22583, 157126, 156018, 159475, 22120, 155849, 155894, 156130, 156214, 156213, 21926, 155899, 156156, 155713, 156080, 155976, 156240, 155905, 159479, 156095, 155921, 156241, 147529, 156231, 156115, 155812, 159478, 156536, 155700, 156086, 156159, 158660, 156136, 155280, 159584, 160174, 10610, 155697, 156029, 153583, 156023, 156244, 156246, 155861, 22680, 14074, 155955, 154683, 156133, 156137, 156640, 160181, 156033, 156248, 156031, 156252, 156229, 151563, 4636, 155761, 156418, 155590, 156051, 157936, 156217, 19915, 159481, 155965, 156292, 155922, 155495, 156463, 155523, 153532, 154354, 159482, 14443, 155547, 156216, 156166, 155797, 154851, 153208, 37536, 156572, 159485, 160183, 158988, 159016, 140021, 155522, 156239, 7053, 155472, 156056, 159137, 159495, 159487, 159000, 155718, 156255, 156256, 19732, 155338, 156019, 156021, 156242, 155223, 153935, 153281, 42061, 156233, 156236, 144840, 159030, 159035, 156238, 156245, 156404, 156230, 156237, 153324, 19735, 156405, 159490, 10642, 156275, 156389, 156289, 156338, 156296, 156316, 153459, 156277, 156274, 156282, 156280, 156349, 156419, 156291, 156317, 156295, 159575, 156336, 153536, 153593, 153684, 156294, 156774, 156301, 156297, 156299, 156300, 156461, 156303, 156449, 156293, 156792, 156346, 153720, 153904, 153826, 153868, 153869, 156335, 156310, 156302, 156307, 156313, 22841, 156312, 156314, 156315, 156387, 153876, 155566, 156318, 156319, 160175, 156775, 156320, 156321, 156382, 156938, 156322, 156406, 22131, 156323, 156324, 156325, 156849, 156392, 22525, 158528, 156327, 157127, 22711, 22710, 144905, 159171, 159169, 156328, 156554, 156329, 156330, 156332, 156776, 21025, 156333, 156839, 22758, 160184, 156334, 156339, 156340, 156341, 156458, 156358, 22840, 156343, 156344, 156420, 156345, 156347, 156348, 156359, 155635, 154060, 156350, 156407, 156351, 156402, 156352, 156354, 156372, 17474, 22834, 153930, 156360, 157941, 156355, 156356, 156408, 2653, 156550, 156778, 156357, 9809, 156361, 156409, 156362, 154381, 156363, 156364, 156365, 156366, 156410, 156367, 156373, 156557, 17492, 153942, 153601, 156368, 156369, 156414, 156370, 156385, 156371, 156471, 157594, 156388, 157769, 160173, 144919, 156375, 156535, 156376, 156465, 3976, 160060, 156377, 156379, 158726, 160185, 156386, 156383, 156384, 156390, 154358, 156091, 156391, 156415, 156393, 156423, 156411, 156394, 156399, 159126, 154098, 23025, 8496, 156400, 156403, 156510, 156981, 156401, 156422, 156559, 156424, 156374, 156380, 156503, 156426, 156436, 156434, 156623, 159011, 100349, 156437, 156438, 156439, 156440, 156441, 156552, 156852, 157009, 156443, 156450, 156451, 156459, 156452, 156453, 156454, 156460, 156931, 156456, 156464, 156560, 156542, 2871, 156466, 156467, 156539, 156468, 156561, 156469, 156470, 156475, 156544, 156476, 156477, 156478, 156988, 156479, 156482, 22821, 156551, 157088, 156547, 156548, 156486, 156493, 156490, 156815, 156520, 156492, 157327, 156513, 156495, 156494, 156519, 156545, 156568, 156515, 156564, 156562, 156576, 156523, 156593, 159548, 156543, 156525, 156326, 156530, 156537, 156532, 156533, 156538, 156534, 156541, 156549, 156546, 156598, 156645, 156565, 156621, 156571, 156668, 156622, 156574, 156597, 156599, 157238, 156575, 156579, 159599, 22597, 8804, 156581, 156592, 156589, 156582, 156624, 156626, 21629, 8779, 23588, 156683, 157763, 156600, 156777, 156604, 156601, 156643, 156619, 17704, 21768, 23624, 156607, 156611, 156613, 156616, 156639, 16304, 156665, 23586, 159553, 156620, 156634, 22574, 158668, 156504, 156671, 157774, 156644, 156638, 22098, 4152, 156641, 156666, 156672, 156660, 156661, 156669, 156717, 157135, 156686, 156670, 12814, 156673, 156684, 156677, 156678, 156646, 156655, 156649, 156715, 156682, 157160, 156656, 156663, 156667, 156676, 156680, 157146, 160754, 156712, 156695, 156651, 156701, 156688, 156696, 156690, 156692, 156779, 156791, 154419, 156812, 156999, 156814, 156698, 157003, 157015, 156700, 157019, 157017, 156853, 156770, 156936, 156707, 156709, 156705, 156710, 157237, 156711, 156713, 156714, 154526, 156716, 156783, 156718, 156719, 156720, 156724, 156729, 156737, 156725, 156731, 154453, 154491, 156722, 156726, 156891, 156727, 156733, 157039, 156734, 156732, 156708, 156752, 156738, 2204, 156937, 156721, 157136, 156760, 156739, 156741, 156746, 156756, 156753, 8810, 156805, 156991, 156765, 156761, 157012, 156766, 156772, 21570, 156647, 156797, 156803, 139090, 156799, 156818, 156771, 156806, 156773, 156768, 156780, 156769, 156804, 2874, 156789, 156795, 154348, 154586, 156801, 156863, 2333, 156985, 156822, 156816, 156823, 156928, 156657, 154769, 154859, 156824, 157239, 156830, 157156, 156828, 156832, 156837, 156835, 156836, 156929, 156878, 156833, 156834, 156845, 4142, 157023, 156843, 156880, 156942, 156840, 156844, 156963, 156856, 22128, 4149, 156862, 156902, 156940, 156899, 157073, 156864, 157069, 156867, 156868, 160044, 156872, 156874, 156924, 156674, 157952, 160555, 22720, 156879, 156882, 156934, 156887, 156886, 156943, 156893, 156904, 160579, 156900, 156885, 156905, 156908, 156935, 156906, 159191, 157903, 157033, 156911, 157034, 156956, 159618, 156654, 156914, 156912, 156916, 156917, 156921, 156958, 156913, 156923, 159134, 4153, 156918, 156927, 158164, 156932, 156930, 156933, 156907, 156950, 156951, 4217, 157488, 156953, 156955, 156957, 156959, 156960, 157228, 156996, 156254, 156970, 160222, 156971, 156973, 156974, 156972, 157001, 157328, 156975, 156979, 156982, 156978, 156984, 157022, 157602, 157454, 156851, 156848, 157031, 157008, 4222, 157010, 157011, 157130, 157024, 157025, 160258, 157028, 157131, 8814, 156993, 157030, 156209, 156998, 156997, 15408, 154779, 157016, 156854, 157081, 157000, 157027, 156847, 156846, 157133, 157229, 154714, 155013, 155049, 157032, 156826, 156831, 157090, 157118, 157054, 15733, 157436, 157071, 157043, 157098, 157046, 157050, 157099, 157052, 157048, 157097, 160267, 160269, 157055, 157087, 157100, 157056, 158964, 157057, 157085, 157064, 157063, 7059, 154821, 157067, 157072, 157074, 157240, 157103, 157080, 157077, 8816, 22894, 12296, 157111, 157079, 157084, 157076, 157089, 157091, 157094, 157343, 157230, 160277, 157114, 155308, 155225, 154501, 157116, 157078, 157096, 157083, 157095, 157102, 157140, 20974, 157101, 159161, 157517, 156825, 157150, 157093, 157117, 156219, 157143, 157151, 146315, 9311, 157107, 156915, 157568, 157108, 157105, 157159, 159192, 157112, 157113, 3871, 155918, 155412, 156969, 156723, 159190, 157120, 157122, 157123, 157121, 22937, 22135, 157070, 155604, 155568, 156614, 158994, 157119, 156218, 157319, 4198, 156903, 156573, 158604, 157231, 156586, 20868, 156558, 160115, 22556, 156995, 156527, 158240, 157474, 156540, 157232, 156567, 157451, 160109, 160150, 156759, 156941, 155729, 155728, 155759, 156827, 143767, 156860, 156662, 156608, 158670, 156602, 157320, 157044, 156577, 158237, 2548, 156841, 157462, 156829, 156796, 156922, 157325, 159489, 156890, 156838, 143770, 156232, 156865, 156521, 160152, 157053, 156298, 157349, 156631, 157603, 157051, 156976, 156892, 156512, 156703, 159448, 141765, 159491, 156570, 157233, 155751, 156873, 156427, 157318, 156798, 157234, 3931, 157014, 157180, 157134, 156877, 156926, 159498, 159502, 3213, 156398, 156983, 157317, 157322, 142974, 156506, 157110, 148042, 156215, 156866, 159444, 156578, 156909, 157236, 156820, 157145, 157092, 157109, 157029, 156790, 156612, 158437, 157005, 157068, 157170, 156897, 157259, 157344, 159509, 159249, 155829, 157066, 157345, 157075, 157062, 157059, 21329, 156889, 156606, 155575, 156290, 159499, 15274, 156871, 156605, 159460, 156745, 157342, 157045, 157690, 156378, 159506, 4475, 156910, 157007, 21305, 156884, 155866, 155947, 156595, 156896, 157018, 25335, 159680, 156412, 156596, 157241, 157249, 156583, 157244, 157235, 22880, 157323, 157341, 159505, 159507, 20878, 157154, 157061, 156895, 157261, 157324, 157321, 22908, 157262, 157271, 157263, 157270, 157264, 157346, 22874, 157265, 157266, 157267, 157268, 157269, 157326, 157272, 157340, 157273, 159165, 158787, 157251, 157353, 157352, 157355, 157357, 157358, 158238, 159220, 157452, 157453, 159504, 159896, 25409, 157438, 22172, 157439, 157440, 21233, 4342, 157441, 157442, 157449, 156042, 157443, 158573, 157444, 157446, 157447, 159709, 159014, 157448, 20929, 157450, 159992, 157455, 157464, 157465, 157699, 159018, 157456, 157468, 20934, 157457, 159213, 157458, 157459, 157460, 157461, 157463, 157466, 157467, 157469, 157470, 157471, 159029, 157472, 157473, 147342, 157475, 157476, 22512, 157477, 158251, 159503, 159559, 159929, 157478, 157785, 157619, 157789, 157479, 157480, 157481, 157764, 157482, 157483, 157484, 4476, 157759, 157689, 157691, 157491, 157492, 157486, 157493, 157495, 157489, 24259, 157826, 155822, 157496, 157497, 157498, 157908, 157499, 1030, 157501, 31358, 156556, 157435, 157539, 157515, 157513, 22868, 157526, 157527, 157562, 157555, 157556, 157534, 157937, 157569, 157521, 140848, 12116, 159214, 157522, 157559, 159554, 16146, 157537, 157531, 157558, 159514, 157542, 157762, 157532, 11052, 157535, 157533, 157536, 157538, 157540, 157541, 159979, 157543, 159958, 159956, 157544, 157545, 157548, 157549, 157552, 157554, 21829, 157560, 159967, 159977, 157561, 157570, 157576, 157571, 157572, 21848, 156462, 127856, 157578, 157573, 157707, 158239, 157575, 159258, 157049, 157579, 157580, 157581, 157587, 157598, 157618, 157583, 3966, 156395, 157584, 157591, 157601, 157592, 23561, 157589, 157590, 21500, 21797, 147530, 158852, 157523, 156397, 157605, 157606, 157607, 157608, 157609, 157613, 157610, 159519, 157709, 159677, 157626, 160203, 158979, 157621, 157627, 157622, 160548, 147531, 160020, 160191, 157638, 157631, 157632, 157630, 159521, 159529, 4616, 160071, 157635, 157668, 157669, 158283, 157921, 159163, 157642, 157640, 160272, 157708, 157647, 158980, 158618, 157646, 157994, 142105, 23521, 157758, 19595, 157648, 160281, 160021, 157650, 157652, 157684, 156433, 157651, 157637, 157942, 157898, 159026, 157744, 157688, 157653, 160551, 157658, 157663, 157681, 157680, 157654, 157674, 157704, 158062, 157700, 157702, 157703, 157697, 157969, 157770, 159025, 157714, 157723, 157715, 157795, 157716, 157922, 159182, 157717, 157724, 158822, 144870, 157718, 157719, 157768, 17473, 157754, 157755, 157720, 157721, 157722, 158063, 157924, 157943, 158286, 157733, 157731, 157732, 157729, 157740, 160232, 157788, 157760, 156446, 157741, 157739, 157490, 157746, 157895, 157747, 157748, 160197, 156497, 156498, 156603, 157676, 157673, 157783, 157775, 157784, 157780, 157779, 157782, 157792, 156633, 156609, 156610, 157796, 157797, 157798, 157800, 157803, 157914, 156855, 157805, 157804, 157912, 157806, 1576, 158290, 157807, 156869, 156875, 156946, 157040, 157848, 157818, 158898, 157925, 157944, 4261, 157810, 157814, 22719, 157893, 157811, 157812, 159193, 159527, 1773, 157813, 157915, 157820, 157830, 157823, 159031, 17375, 2263, 1251, 157821, 157822, 157888, 157879, 157825, 157827, 157885, 157829, 157926, 157945, 157973, 157917, 157832, 159425, 157833, 157834, 157918, 157974, 157875, 157967, 15133, 157840, 157886, 157839, 157838, 157843, 4480, 157890, 157842, 157901, 157844, 157928, 159216, 157846, 157975, 157845, 159520, 157847, 157853, 157929, 157849, 157852, 157856, 157902, 5515, 158895, 157858, 157859, 157862, 157954, 157964, 158065, 158071, 157861, 157871, 100466, 157900, 157913, 158292, 157891, 159678, 157882, 5160, 157873, 157904, 157874, 157889, 157961, 24928, 157905, 157940, 1482, 157906, 157916, 157881, 157884, 157897, 157880, 157899, 157931, 157932, 16427, 157938, 157933, 157934, 157939, 157935, 157956, 158078, 159667, 157955, 157968, 157976, 2613, 158017, 158007, 159194, 158058, 157971, 158009, 158505, 157977, 28972, 158047, 159042, 2443, 157989, 157993, 159195, 25300, 159041, 17374, 157567, 157582, 158035, 159033, 158045, 158037, 158053, 158050, 158051, 158036, 159197, 158223, 157629, 24100, 158044, 158048, 158049, 158055, 159058, 158061, 158057, 158295, 158060, 158072, 144917, 158073, 158259, 158074, 158075, 157657, 158076, 158225, 158077, 158093, 158079, 159525, 160204, 157816, 157819, 158080, 158090, 159155, 158083, 158084, 158085, 157824, 135754, 159203, 158087, 158143, 158088, 158089, 159528, 160276, 158091, 158104, 158138, 158092, 158498, 158094, 158096, 160554, 157835, 157837, 157851, 158068, 158098, 158100, 159201, 158158, 159215, 158101, 159202, 160612, 158069, 158127, 158134, 157794, 158120, 158122, 158126, 158029, 158121, 158123, 158282, 100040, 158130, 158125, 158128, 158129, 157730, 157970, 158142, 158144, 158150, 158147, 158153, 158145, 158155, 158148, 158156, 158161, 12388, 23659, 159515, 158162, 158157, 159206, 159523, 158173, 158163, 158229, 158252, 158255, 158180, 159128, 158166, 159207, 159530, 160685, 158064, 158174, 158175, 158253, 158184, 158178, 158177, 158188, 158190, 158256, 158182, 158192, 159532, 158601, 158186, 158363, 158369, 158254, 158503, 158474, 158195, 158103, 159567, 158280, 158187, 158525, 157250, 158201, 158221, 159642, 158198, 158298, 159124, 159209, 158212, 158214, 158211, 157671, 158209, 158215, 158219, 158207, 158532, 158246, 158249, 159208, 158243, 158245, 157514, 157623, 158262, 157742, 158086, 157519, 157636, 157736, 158261, 159603, 157836, 158269, 159260, 158612, 157828, 157655, 157695, 157698, 159560, 159562, 157038, 158527, 157863, 157356, 160111, 157520, 158268, 158597, 158495, 157868, 157516, 157765, 157786, 158276, 157857, 157756, 158506, 159140, 157628, 158995, 25523, 159598, 157877, 158097, 157930, 158169, 158707, 159088, 153049, 139777, 159676, 21511, 158571, 157957, 157710, 21379, 22976, 157962, 158279, 159037, 159248, 157808, 157923, 157743, 4343, 158284, 157750, 158275, 23556, 157850, 157791, 158052, 22445, 157761, 158533, 21193, 159352, 159359, 158300, 158303, 157752, 157659, 158587, 157870, 139913, 159401, 157876, 157947, 158592, 158600, 158004, 157634, 158521, 158152, 158870, 159399, 157831, 157664, 158038, 158132, 21891, 157645, 158204, 157667, 157633, 157990, 4073, 158603, 158165, 157666, 159424, 158027, 158874, 21922, 22137, 22205, 160852, 157854, 157998, 158139, 158193, 158522, 22218, 4076, 158309, 158159, 158310, 158311, 147122, 158849, 159266, 1078, 157641, 158172, 22510, 160116, 4077, 157672, 158059, 158235, 124720, 158222, 158233, 158620, 158265, 945, 158342, 158352, 158535, 158116, 20847, 159433, 158730, 157649, 157677, 158241, 147308, 5617, 157678, 141100, 158350, 158524, 22156, 158206, 157682, 158434, 158609, 158258, 158260, 139914, 159602, 159468, 158496, 158497, 158360, 158539, 159644, 158325, 157683, 158364, 159486, 159615, 139873, 158355, 146631, 160131, 949, 158056, 159994, 158336, 157620, 157749, 158236, 157361, 1118, 38987, 158371, 153436, 157242, 158341, 160283, 25328, 157529, 158370, 29942, 160129, 24906, 160937, 28017, 158338, 158340, 139995, 158574, 158365, 160314, 157351, 157799, 11533, 158337, 158293, 158377, 158335, 158375, 157801, 157802, 158541, 158154, 158400, 158026, 158000, 158208, 158915, 13547, 158499, 159259, 1187, 160954, 159313, 158543, 158610, 158871, 158403, 158529, 22440, 22184, 158404, 158611, 158405, 158827, 158981, 159268, 159262, 158412, 158530, 159429, 22635, 30399, 158586, 158411, 158553, 158414, 158446, 158416, 158419, 159284, 158415, 22211, 20209, 25095, 22787, 158502, 158418, 158424, 159430, 158423, 28703, 158443, 23599, 158531, 158426, 158427, 158428, 158500, 156428, 156489, 20198, 1028, 158449, 158452, 158515, 22443, 158450, 158517, 158455, 158485, 158491, 158492, 158490, 158493, 158494, 22555, 158520, 158516, 158519, 158554, 158613, 158545, 158547, 158489, 22315, 22455, 158568, 159055, 158548, 158561, 158562, 159431, 158557, 158566, 158564, 158559, 158563, 158567, 158859, 158570, 158616, 158617, 158572, 158578, 22577, 158575, 158685, 158622, 158750, 158580, 158579, 158606, 158608, 158621, 158590, 159059, 158742, 23679, 158623, 158624, 159062, 158628, 158848, 159516, 22437, 25437, 158629, 158644, 158853, 22718, 2381, 22935, 158631, 158638, 159184, 158632, 158642, 158641, 158643, 14178, 22759, 22981, 158843, 158645, 159185, 158908, 158914, 25467, 158647, 158651, 158658, 158652, 159785, 158659, 158657, 158661, 22458, 22464, 22474, 25411, 158665, 158666, 158667, 158663, 159645, 158669, 158672, 22865, 1317, 158673, 158674, 158675, 159087, 159046, 158684, 158683, 158679, 23017, 22975, 158680, 158681, 158854, 160306, 26421, 1060, 158910, 158840, 158722, 158916, 17429, 158786, 158803, 22678, 158923, 21910, 25360, 1035, 158924, 158732, 158653, 158706, 158702, 158703, 17430, 158911, 22832, 21865, 25398, 1212, 27805, 158704, 158699, 17528, 158700, 158709, 159051, 158714, 21951, 22212, 158858, 158918, 158794, 158715, 17432, 159142, 158716, 159125, 22449, 158488, 158718, 158788, 158719, 158720, 939, 158860, 159144, 22463, 158713, 158724, 158729, 158919, 158727, 158939, 159432, 158862, 22468, 22471, 25438, 158743, 22736, 158912, 158739, 158734, 158863, 158809, 158913, 158745, 158789, 158744, 22477, 25440, 1721, 158741, 159086, 158747, 158756, 158749, 158753, 159480, 160345, 158757, 22649, 22257, 158758, 158866, 158764, 158759, 158865, 160327, 2445, 158922, 22430, 22095, 159593, 158761, 158818, 158765, 158766, 158767, 159493, 158792, 159830, 158770, 158904, 158772, 22916, 158773, 158820, 158799, 17384, 22686, 158948, 158905, 158784, 22670, 158814, 152391, 100273, 159082, 155463, 2449, 158793, 158795, 19852, 158801, 158807, 158805, 158837, 158838, 158839, 158836, 159984, 22473, 22475, 1065, 159187, 160762, 20712, 158876, 158884, 158907, 158846, 158883, 158885, 158889, 158891, 158896, 159518, 2448, 25427, 158926, 158936, 159186, 158925, 158935, 158937, 18102, 1055, 11054, 159079, 17465, 17526, 17555, 17667, 17696, 17372, 17403, 158949, 158957, 24649, 26423, 25383, 25386, 25388, 2628, 158960, 140244, 2619, 20814, 14754, 2614, 142155, 31774, 3408, 145075, 144764, 152258, 5710, 11063, 6887, 24128, 144851, 6938, 8048, 7927, 7521, 8123, 9142, 8964, 11501, 24647, 144703, 141037, 33356, 33695, 27450, 28337, 27854, 146768, 144767, 29217, 4986, 29976, 29713, 29997, 31880, 31433, 31597, 31762, 31748, 26299, 145683, 32874, 127852, 24768, 38798, 1139, 33217, 147404, 33209, 11993, 36039, 144740, 144742, 145935, 147407, 147138, 145944, 37119, 38998, 35259, 149321, 9279, 37168, 35556, 35695, 146618, 160946, 37400, 38131, 100271, 37435, 18605, 16321, 145172, 40021, 11451, 147638, 146130, 146185, 147830, 146507, 146169, 38181, 39690, 35570, 146186, 40855, 146525, 126313, 147117, 147119, 145649, 146667, 145653, 127222, 127757, 146852, 42388, 42487, 42113, 11036, 42428, 42430, 22071, 42420, 135639, 135806, 135802, 135817, 42194, 19257, 42219, 147153, 21812, 159824, 21663, 20811, 21693, 20789, 159948, 159989, 13125, 16017, 11299, 159957, 160041, 159971, 160003, 160017, 160014, 160018, 160033, 160024, 159309, 160202, 160235, 20945, 159679, 160539, 160578, 160588, 160639, 159587, 159583, 160702, 159620, 159606, 22280, 160834, 22281, 22301, 20593, 21832, 21904, 160923, 21654, 20264, 19908, 19201, 160951, 21679, 21866, 19590, 19611, 21312, 20138, 159617, 147532, 19270, 23546, 159746, 23627, 22760, 147221, 158576, 160976, 147225, 19913, 19258, 18837, 159052, 17514, 22761, 36325, 17650, 159054, 159053, 17489, 159310, 23585, 23616, 159319, 159303, 159394, 159601, 159437, 159436, 159304, 23578, 159306, 23634, 23584, 159435, 22795, 159477, 159648, 159421, 159585, 159440, 159445, 159441, 160255, 159526, 159540, 159538, 159537, 159588, 159536, 159572, 159535, 159541, 159605, 159561, 159681, 143880, 159556, 159670, 125091, 159577, 159576, 159590, 159580, 159582, 159579, 159718, 23465, 22902, 159720, 158409, 158639, 159261, 22915, 160005, 22920, 159365, 158959, 159230, 159738, 159223, 160257, 158646, 22928, 22941, 159265, 159647, 159273, 23469, 158648, 159867, 145156, 158410, 158451, 23484, 23220, 22519, 159017, 158432, 20645, 23564, 159072, 22933, 22938, 158481, 159096, 158509, 158407, 23568, 159119, 23603, 23716, 22950, 158731, 23518, 159654, 158453, 158998, 155535, 159747, 159684, 23572, 22919, 159591, 22960, 159501, 23446, 23426, 33952, 158662, 158589, 22716, 159146, 22923, 158454, 158591, 159280, 159393, 158577, 23432, 158796, 159761, 23528, 23532, 23535, 23543, 23710, 158686, 23428, 159373, 23684, 23605, 22994, 22722, 21621, 23502, 23508, 23533, 158682, 23286, 22878, 22947, 22953, 158746, 159434, 159467, 22688, 23295, 23302, 159570, 21554, 158728, 22955, 159305, 22657, 40973, 23330, 159592, 20247, 22899, 22765, 22768, 22771, 159103, 159340, 22932, 159784, 23477, 23355, 23388, 22751, 22774, 22901, 23607, 158878, 23711, 22487, 158697, 23379, 22756, 22905, 22906, 156811, 159074, 159344, 158808, 159483, 159726, 159715, 23399, 157864, 158695, 158710, 159781, 161029, 161035, 161036, 161037, 158401, 22772, 23707, 23728, 23011, 23608, 159736, 23470, 161030, 158614, 23325, 159925, 158997, 159778, 159777, 158630, 23424, 33008, 159023, 22496, 22499, 159730, 159627, 23018, 23019, 159734, 159737, 23377, 17024, 161031, 22885, 22766, 161032, 161038, 22891, 23029, 22831, 22896, 23140, 22762, 22838, 22839, 22222, 161033, 161039, 161040, 22889, 22979, 22989, 23005, 23134, 22674, 22843, 22833, 22846, 22850, 22853, 22860, 22794, 22328, 22331, 161041, 23007, 22782, 22887, 22786, 22792, 22886, 23003, 23013, 22699, 22788, 22791, 22201, 22216, 22544, 22116, 22542, 22117, 22439, 22591, 22617, 22204, 22516, 22578, 22586, 161042, 22631, 22640, 22436, 22441, 22602, 22606, 22629, 22646, 22215, 22534, 22658, 159357, 22166, 159692, 159404, 22160, 22161, 22338, 22341, 22362, 22363, 22416, 22559, 22249, 22304, 22454, 22613, 22159, 22354, 22365, 22415, 22407, 22374, 22395, 22401, 22405, 22355, 22366, 22381, 22386, 22306, 22234, 22221, 22239, 22268, 22091, 22099, 22112, 21508, 21614, 21499, 22010, 21037, 21767, 22240, 21558, 22452, 21776, 21775, 21674, 21837, 21983, 21946, 21062, 159847, 159864, 22626, 22075, 22103, 22106, 22110, 22379, 4341, 21569, 21586, 21599, 3180, 21577, 21608, 22119, 21575, 21505, 21553, 21522, 21985, 22043, 21618, 14271, 21620, 22031, 22033, 15792, 21844, 21725, 20797, 159852, 21719, 22042, 5039, 5043, 21769, 21990, 21991, 22001, 22002, 22009, 21899, 21466, 21901, 21736, 21639, 21650, 21808, 21816, 159859, 21842, 21724, 21751, 21878, 21887, 159912, 22017, 21854, 21845, 21906, 21813, 151542, 21685, 21691, 21717, 21919, 21496, 159838, 145613, 21641, 20781, 139092, 21950, 20904, 22052, 20871, 20925, 159828, 20926, 20935, 21052, 21060, 21353, 20792, 24093, 21053, 24089, 9348, 28616, 20796, 159915, 159861, 159834, 20818, 20888, 20903, 21011, 20897, 20849, 20912, 20924, 20883, 159839, 159840, 159845, 21074, 159853, 159855, 159887, 159856, 159862, 159857, 21437, 21447, 159863, 159870, 159875, 20816, 20821, 159880, 159876, 159884, 141114, 159883, 159886, 159885, 21284, 21291, 159888, 159892, 159889, 159890, 159891, 21265, 20997, 20803, 20806, 20830, 21349, 21325, 21039, 21453, 21270, 21245, 19824, 21293, 21303, 21333, 21024, 21040, 22059, 21380, 22066, 159865, 21018, 21038, 21160, 21009, 21076, 159926, 21098, 22057, 21297, 21320, 21322, 21335, 21345, 21423, 21317, 21318, 21355, 21373, 21361, 21294, 17083, 20859, 20801, 21319, 21460, 21463, 3835, 20780, 21365, 21242, 21378, 21366, 15299, 21337, 21411, 21413, 21415, 21421, 21427, 20787, 21416, 21446, 21252, 21260, 21236, 21249, 21123, 159930, 21139, 21140, 21141, 21144, 21204, 22118, 159939, 159932, 21181, 159933, 16000, 20791, 21206, 21045, 21124, 21133, 159944, 21186, 21202, 13391, 159949, 159981, 160105, 16240, 159937, 21229, 21328, 159938, 21228, 21208, 11010, 159990, 21213, 13506, 159982, 16783, 20788, 20950, 20969, 20990, 20991, 21005, 21150, 21165, 19918, 20658, 20310, 13804, 14015, 148048, 14815, 159940, 11493, 159952, 159941, 11813, 159942, 146982, 20316, 159943, 159950, 159951, 147236, 160006, 147534, 159953, 159954, 159955, 160009, 160008, 159959, 159962, 159963, 159972, 159964, 159965, 159973, 159966, 159974, 147575, 159976, 159969, 159975, 147633, 159970, 159961, 147371, 160000, 159995, 160088, 159993, 159999, 159996, 159997, 160016, 159998, 147254, 160001, 160002, 160004, 160007, 160010, 160030, 146974, 160037, 160090, 160012, 160011, 160015, 160019, 160023, 160025, 160034, 147073, 160027, 160026, 160028, 146977, 147092, 160035, 160217, 160046, 160050, 160047, 160048, 160049, 160100, 160101, 160051, 160052, 160053, 160054, 160102, 160055, 160142, 160056, 160057, 160059, 160062, 160065, 160107, 160201, 20356, 160067, 160068, 160069, 160073, 160072, 20300, 160320, 160260, 160074, 160110, 160075, 160076, 160077, 160081, 160091, 160079, 160148, 160092, 160080, 160082, 160083, 160087, 160108, 160085, 160086, 160089, 160093, 160103, 160096, 160097, 160104, 160099, 160117, 160121, 160134, 160124, 160125, 160130, 145803, 160127, 146367, 148683, 148684, 160195, 160187, 160196, 160188, 160189, 160193, 160198, 160200, 160207, 145801, 160223, 160321, 160262, 160263, 160213, 160209, 160210, 160259, 160212, 145922, 20357, 160268, 160216, 160220, 160253, 160226, 160228, 160227, 160231, 160234, 145188, 160278, 160243, 160246, 160248, 160218, 160264, 160249, 160279, 145251, 160274, 160251, 20786, 20994, 20958, 21263, 160280, 160301, 20683, 160286, 160395, 20334, 160296, 160291, 160293, 160298, 20363, 20365, 20366, 20829, 160311, 160338, 160308, 160318, 160319, 160324, 160325, 160328, 160331, 160333, 160330, 20238, 20241, 160334, 20211, 20677, 20667, 20660, 20690, 160342, 20665, 160347, 160356, 160355, 17392, 160369, 160360, 160361, 160367, 20774, 160363, 160502, 160392, 20640, 20629, 160379, 160373, 20643, 160374, 160362, 20650, 20555, 20627, 160393, 160388, 160496, 160380, 160378, 160383, 160382, 160385, 160387, 160390, 160394, 20537, 160428, 160400, 160252, 6516, 20770, 20771, 160404, 160417, 160407, 160413, 160410, 160408, 160433, 160418, 160421, 160424, 160422, 160420, 20239, 160429, 160432, 160431, 160435, 160434, 20436, 160444, 160445, 19774, 160458, 160457, 20440, 20476, 160493, 20980, 20767, 160450, 160451, 20292, 20296, 1267, 160449, 20298, 160514, 160465, 160545, 160462, 160464, 20493, 160467, 160469, 160474, 160470, 160471, 160501, 160473, 160485, 160478, 160486, 160475, 160487, 160482, 160490, 160078, 160505, 160504, 160508, 159909, 160510, 160512, 160509, 160524, 142003, 160517, 160523, 160526, 160568, 160537, 160538, 160532, 160535, 160543, 160593, 160561, 160562, 160546, 160565, 160581, 160573, 160574, 160575, 160577, 160567, 160528, 160592, 160586, 160591, 160622, 160595, 160686, 160590, 160597, 160599, 160518, 160598, 160675, 160596, 160594, 160616, 160643, 160600, 160602, 160603, 160604, 160613, 160607, 160611, 160610, 160620, 160618, 154094, 160631, 160630, 160628, 160636, 160638, 160634, 20104, 160629, 160648, 160650, 160266, 160653, 19388, 20236, 160731, 160665, 160655, 160657, 161018, 20533, 160672, 160658, 160659, 160662, 161019, 160670, 160776, 160669, 20832, 20772, 160689, 160690, 160697, 160691, 160694, 160693, 160695, 160730, 160700, 160732, 160313, 160701, 160703, 160711, 160712, 160704, 160710, 160715, 160716, 160714, 160696, 160718, 160805, 160723, 160729, 160724, 160727, 160721, 20743, 160749, 159804, 159805, 160735, 20582, 160870, 160741, 160742, 160744, 160745, 20416, 160747, 149109, 160748, 160857, 160750, 160751, 160755, 160752, 160753, 160758, 20764, 160759, 161013, 160760, 160761, 160763, 160764, 160770, 20595, 20502, 160765, 160769, 160794, 160766, 160768, 160778, 160858, 160811, 160883, 160775, 159895, 142723, 160771, 160772, 160098, 160774, 160583, 142720, 160784, 160781, 160783, 142743, 160779, 160780, 160782, 160791, 160787, 142747, 160789, 160788, 160790, 142742, 143657, 160792, 160795, 160797, 160859, 160798, 160182, 160571, 160876, 160799, 160801, 158978, 20719, 160808, 160846, 160843, 160810, 160812, 160809, 160813, 160719, 20605, 160837, 20612, 20339, 20568, 160815, 160822, 160823, 160832, 160827, 160826, 160830, 160833, 160835, 160841, 160164, 160848, 160911, 160850, 160861, 160912, 160877, 160899, 160499, 160851, 160284, 160642, 160646, 160863, 160563, 160853, 146080, 160627, 160288, 160856, 160519, 160855, 160640, 20405, 160652, 160862, 20438, 18888, 160820, 160734, 20390, 160829, 20397, 160868, 20407, 160869, 160872, 19027, 160885, 160887, 160888, 160214, 159931, 160900, 19383, 160890, 160892, 160893, 19980, 160894, 160895, 160897, 160743, 160898, 19512, 160901, 160908, 160904, 159881, 19440, 160905, 160909, 160906, 160907, 19524, 160913, 160919, 160914, 160915, 160916, 20348, 160917, 20411, 160918, 20446, 160921, 160922, 160239, 160929, 160925, 160928, 135022, 160930, 160940, 160931, 160932, 160933, 160934, 160708, 160935, 160936, 160938, 160927, 160939, 20289, 160942, 160950, 160943, 160944, 19239, 160945, 160947, 20159, 20129, 160948, 19834, 20160, 28899, 160681, 160949, 19992, 160709, 160793, 159879, 160740, 160952, 20109, 28891, 160953, 160955, 160956, 160957, 158399, 20133, 23275, 19297, 155956, 19806, 19983, 160406, 160739, 159897, 19553, 159866, 20147, 19615, 159882, 160412, 160477, 160606, 160414, 160481, 160375, 160570, 160679, 19699, 20108, 20120, 20142, 159893, 19047, 160726, 160426, 160403, 160430, 160503, 19095, 18984, 159903, 160756, 160215, 19860, 160767, 160817, 160713, 20113, 159900, 159901, 150219, 19482, 19594, 19073, 159904, 18932, 160443, 160344, 19626, 20049, 19343, 20005, 159878, 159911, 159908, 160660, 20139, 19829, 19504, 19409, 160058, 19963, 160454, 159991, 160221, 137708, 19330, 20006, 20148, 20137, 19518, 18846, 159913, 149110, 160446, 160757, 161015, 160346, 20000, 160376, 160398, 159917, 160558, 159919, 18980, 159922, 160032, 160219, 19975, 139784, 161021, 160615, 160224, 18985, 19909, 19949, 19422, 19519, 19396, 19688, 160225, 149108, 19459, 160506, 160240, 160969, 19904, 19438, 19945, 141474, 19534, 19205, 19169, 19861, 160970, 19864, 19884, 160973, 160229, 19538, 19605, 18830, 19537, 160977, 160991, 160585, 160649, 160233, 160498, 160236, 20040, 160237, 160507, 19453, 19619, 160456, 20075, 160241, 160460, 19467, 19635, 139912, 160244, 33677, 160245, 160247, 159928, 1883, 160250, 160993, 160983, 19350, 19557, 19522, 159835, 160867, 20054, 19696, 161016, 159783, 21578, 160986, 160988, 161002, 160978, 160609, 19790, 160995, 159923, 160997, 160814, 19880, 19928, 160999, 20033, 21838, 160013, 19927, 160698, 138509, 19698, 160411, 160674, 19718, 19728, 19676, 160802, 19586, 160022, 19697, 19766, 153418, 19427, 19385, 151230, 19078, 19071, 160061, 160806, 160647, 160785, 19261, 19273, 159841, 160800, 160399, 160381, 160326, 19386, 160070, 160968, 19234, 19292, 19406, 19683, 19576, 19589, 127306, 146101, 161014, 19133, 19228, 18944, 18824, 19104, 18870, 19109, 19134, 18699, 18865, 18764, 19131, 19038, 18955, 19092, 9122, 18816, 19024, 19035, 18860, 153864, 161044, 161045, 161046, 161047, 25391, 161048, 161049, 161050, 161051, 161052, 161053, 161065, 161054, 17368, 161062, 161063, 161099, 161100, 27313, 161057, 161058, 161059, 161061, 161066, 161101, 161060, 161068, 161069, 161102, 161103, 161070, 161104, 161112, 161113, 161108, 161109, 161114, 161110, 161107, 161111, 161071, 161105, 161072, 161106, 161073, 161074, 161115, 161116, 29901, 161117, 160323, 160461, 160587, 160580, 158508, 161118, 159968, 161119, 161075, 142805, 161120, 161121, 161122, 161123, 161124, 161076, 161125, 161077, 161078, 161079, 161126, 161129, 161131, 161080, 161127, 161130, 161132, 161081, 161082, 161083, 161128, 161133, 161134, 161084, 161135, 161136, 161085, 161137, 161138, 161139, 161140, 161086, 161141, 161142, 161143, 161087, 161144, 161145, 161088, 161146, 161150, 161159, 161160, 161161, 161162, 161163, 161164, 161165, 161166, 161167, 161168, 161089, 161147, 161148, 161151, 161169, 161170, 161171, 161172, 161173, 161174, 161175, 161176, 161177, 161090, 161149, 161152, 161153, 161178, 161179, 161180, 161181, 161182, 161183, 161184, 161185, 161186, 161187, 161188, 161189, 161091, 161154, 161190, 161191, 161192, 161193, 161194, 161195, 161196, 161197, 161198, 161199, 161200, 161201, 161202, 161203, 161204, 161205, 161206, 161207, 161092, 161155, 161208, 161209, 161210, 161211, 161212, 161213, 161214, 161215, 161216, 161217, 161218, 161219, 161220, 161221, 161222, 161093, 161156, 161157, 161223, 161224, 161225, 161226, 161227, 161228, 161229, 161230, 161231, 161232, 161233, 161234, 161235, 161236, 161237, 161238, 161239, 161094, 161158, 161240, 161241, 161242, 161243, 161244, 161245, 161246, 161247, 161248, 161249, 161250, 161251, 161252, 161253, 161254, 161095, 161255, 161256, 161257, 161258, 161259, 161260, 161261, 161262, 161263, 161264, 161265, 161266, 161267, 161268, 161269, 161270, 161271, 161096, 161272, 161273, 161274, 161275, 161276, 161277, 161278, 161279, 161280, 161281, 161282, 161283, 161284, 161285, 161286, 161287, 161288, 161289, 161290, 161291, 161292, 161097, 161293, 161294, 161295, 161296, 161297, 161298, 161299, 161300, 161301, 161302, 161303, 161304, 161305, 161306, 161307, 161308, 161309, 161310, 161098, 161311, 161312, 161313, 161314, 161315, 161316, 161317, 161318, 161319, 161320, 161321, 161322, 161323, 161324, 161325, 161326, 161327, 161328, 161329, 161330, 161331, 161332, 161333, 161334, 161335, 161336, 161337, 161338, 161339, 161340, 161341, 161342, 161343, 161344, 161345, 161346, 161347, 161348, 161349, 161350, 161351, 161352, 161353, 161354, 161355, 161356, 161357, 161358, 161359, 161360, 161361, 161362, 161363, 161364, 161365, 161366, 161367, 161368, 161369, 161370, 161371, 161372, 161373, 161374, 161375, 161376, 161377, 161378, 161379, 161380, 161381, 161382, 161383, 161384, 161385, 161386, 161387, 161388, 161389, 161390, 161391, 161392, 161393, 161394, 161395, 161396, 161397, 161398, 161399, 161400, 161401, 161402, 161403, 161404, 161405, 161406, 161407, 161408, 161409, 161410, 161411, 161412, 161413, 161414, 161415, 161416, 161417, 161418, 161419, 161420, 161421, 161422, 161423, 161424, 161425, 161426, 161427, 161428, 161429, 161430, 161431, 161432, 161433, 161434, 161435, 161436, 161437, 161438, 161439, 161440, 161441, 161442, 161443, 161444, 161445, 161446, 161447, 161448, 161449, 161450, 161451, 161452, 161453, 161454, 161455, 161456, 161457, 161458, 161459, 161460, 161461, 161462, 161463, 161464, 161465, 161466, 161467, 161468, 161469, 161470, 161471, 161472, 161473, 161474, 161475, 161476, 161477, 161478, 161479, 161480, 161481, 161482, 161483, 161484, 161485, 161486, 161487, 161488, 161489, 161490, 161491, 161492, 161493, 161494, 161495, 161496, 161497, 161498, 161499, 161500, 161501, 161502, 161503, 161504, 161505, 161506, 161507, 161508, 161509, 161510, 161511, 161512, 161513, 161514, 161515, 161516, 161517, 161518, 161519, 161520, 161521, 161522, 161523, 161524, 161525, 161526, 161527, 161528, 161529, 161530, 161531, 161532, 161533, 161534, 161535, 161536, 161537, 161538, 161539, 161540, 161541, 161542, 161543, 161544, 161545, 161546, 161547, 161548, 161549, 161550, 161551, 161552, 161553, 161554, 161555, 161556, 161557, 161558, 161559, 161560, 161561, 161562, 161563, 161564, 161565, 161566, 161567, 161568, 161569, 161570, 161571, 161572, 161573, 161574, 161575, 161576, 161577, 161578, 161579, 161580, 161581, 161582, 161583, 161584, 161585, 161586, 161587, 161588, 161589, 161590, 161591, 161592, 161593, 161594, 161595, 161596, 161597, 161598, 161599, 161600, 161601, 161602, 161603, 161604, 161605, 161606, 161607, 161608, 161609, 161610, 161611, 161612, 161613, 161614, 161615, 161616, 161617, 161618, 161619, 161620, 161621, 161622, 161623, 161624, 161625, 161626, 161627, 161628, 161629, 161630, 161631, 161632, 161633, 161634, 161635, 161636, 161637, 161638, 161639, 161640, 161641, 161642, 161643, 161644, 161645, 161646, 161647, 161648, 161649, 161650, 161651, 161652, 161653, 161654, 161655, 161656, 161657, 161658, 161659, 161660, 161661, 161662, 161663, 161664, 161665, 161666, 161667, 161668, 161669, 161670, 161671, 161672, 161673, 161674, 161675, 161676, 161677, 161678, 161679, 161680, 161681, 161682, 161683, 161684, 161685, 161686, 161687, 161688, 161689, 161690, 161691, 161692, 161693, 161694, 161695, 161696, 161697, 161698, 161699, 161700, 161701, 161702, 161703, 161704, 161705, 161706, 161707, 161708, 161709, 161710, 161711, 161712, 161713, 161714, 161715, 161716, 161717, 161718, 161719, 161720, 161721, 161722, 161723, 161724, 161725, 161726, 161727, 161728, 161729, 161730, 161731, 161732, 161733, 161734, 161735, 161736, 161737, 161738, 161739, 161740, 161741, 161742, 161743, 161744, 161745, 161746, 161747, 161748, 161749, 161750, 161751, 161752, 161753, 161754, 161755, 161756, 161757, 161758, 161759, 161760, 161761, 161762, 161763, 161764, 161765, 161766, 161767, 161768, 161769, 161770, 161771, 161772, 161773, 161774, 161775, 161776, 161777, 161778, 161779, 161780, 161781, 161782, 161783, 161784, 161785, 161786, 161787, 161788, 161789, 161790, 161791, 161792, 161793, 161794, 161795, 161796, 161797, 161798, 161799, 161800, 161801, 161802, 161803, 161804, 161805, 161806, 161807, 161808, 161809, 161810, 161811, 161812, 161813, 161814, 161815, 161816, 161817, 161818, 161819, 161820, 161821, 161822, 161823, 161824, 161825, 161826, 161827, 161828, 161829, 161830, 161831, 161832, 161833, 161834, 161835, 161836, 161837, 161838, 161839, 161840, 161841, 161842, 161843, 161844, 161845, 161846, 161847, 161848, 161849, 161850, 161851, 161852, 161853, 161854, 161855, 161856, 161857, 161858, 161859, 161860, 161861, 161862, 161863, 161864, 161865, 161866, 161867, 161868, 161869, 161870, 161871, 161872, 161873, 161874, 161875, 161876, 161877, 161878, 161879, 161880, 161881, 161882, 161883, 161884, 161885, 161886, 161887, 161888, 161889, 161890, 161891, 161892, 161893, 161894, 161895, 161896, 161897, 161898, 161899, 161900, 161901, 161902, 161903, 161904, 161905, 161906, 161907, 161908, 161909, 161910, 161911, 161912, 161913, 161914, 161915, 161916, 161917, 161918, 161919, 161920, 161921, 161922, 161923, 161924, 161925, 161926, 161927, 161928, 161929, 161930, 161931, 161932, 161933, 161934, 161935, 161936, 161937, 161938, 161939, 161940, 161941, 161942, 161943, 161944, 161945, 161946, 161947, 161948, 161949, 161950, 161951, 161952, 161953, 161954, 161955, 161956, 161957, 161958, 161959, 161960, 161961, 161962, 161963, 161964, 161965, 161966, 161967, 161968, 161969, 161970, 161971, 161972, 161973, 161974, 161975, 161976, 161977, 161978, 161979, 161980, 161981, 161982, 161983, 161984, 161985, 161986, 161987, 161988, 161989, 161990, 161991, 161992, 161993, 161994, 161995, 161996, 161997, 161998, 161999, 162000, 162001, 162002, 162003, 162004, 162005, 162006, 162007, 162008, 162009, 162010, 162011, 162012, 162013, 162014, 162015, 162016, 162017, 162018, 162020, 162021, 162022, 162023, 162024, 162025, 162026, 162027, 162028, 162029, 162030, 162019, 162031, 162032, 162033, 162034, 162035, 162036, 162037, 162038, 162039, 162040, 162041, 162042, 162043, 162044, 162045, 162046, 162047, 162048, 162049, 162050])) AND (sivel2_gen_conscaso.caso_id IN ( SELECT sip_ubicacion.id_caso
                   FROM public.sip_ubicacion
                  WHERE (sip_ubicacion.id_departamento = 55))))
          ORDER BY sivel2_gen_conscaso.fecha, sivel2_gen_conscaso.caso_id))
  ORDER BY conscaso.fecha, conscaso.caso_id
  WITH NO DATA;


--
-- Name: sivel2_gen_contexto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_contexto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_contexto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_contexto (
    id integer DEFAULT nextval('public.sivel2_gen_contexto_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT contexto_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_contextovictima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_contextovictima (
    id bigint NOT NULL,
    nombre character varying(100) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_gen_contextovictima_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_contextovictima_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_contextovictima_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_contextovictima_id_seq OWNED BY public.sivel2_gen_contextovictima.id;


--
-- Name: sivel2_gen_contextovictima_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_contextovictima_victima (
    contextovictima_id integer NOT NULL,
    victima_id integer NOT NULL
);


--
-- Name: sivel2_gen_departamento_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_departamento_region (
    departamento_id integer,
    region_id integer
);


--
-- Name: sivel2_gen_escolaridad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_escolaridad (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_gen_escolaridad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_escolaridad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_escolaridad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_escolaridad_id_seq OWNED BY public.sivel2_gen_escolaridad.id;


--
-- Name: sivel2_gen_estadocivil; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_estadocivil (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_gen_estadocivil_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_estadocivil_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_estadocivil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_estadocivil_id_seq OWNED BY public.sivel2_gen_estadocivil.id;


--
-- Name: sivel2_gen_etnia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_etnia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_etnia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_etnia (
    id integer DEFAULT nextval('public.sivel2_gen_etnia_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    descripcion character varying(1000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT etnia_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_etnia_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_etnia_victimacolectiva (
    etnia_id integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_filiacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_filiacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_filiacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_filiacion (
    id integer DEFAULT nextval('public.sivel2_gen_filiacion_id_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2001-01-01'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT filiacion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_filiacion_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_filiacion_victimacolectiva (
    id_filiacion integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_fotra; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_fotra (
    id integer DEFAULT nextval(('fuente_directa_seq'::text)::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_frontera_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_frontera_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_frontera; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_frontera (
    id integer DEFAULT nextval('public.sivel2_gen_frontera_id_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2001-01-01'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT frontera_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_iglesia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_iglesia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_iglesia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_iglesia (
    id integer DEFAULT nextval('public.sivel2_gen_iglesia_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    descripcion character varying(1000),
    fechacreacion date DEFAULT CURRENT_DATE NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT iglesia_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario (
    nusuario character varying(15) NOT NULL,
    nombre character varying(50) COLLATE public.es_co_utf_8,
    descripcion character varying(50),
    rol integer DEFAULT 4,
    password character varying(64) DEFAULT ''::character varying,
    idioma character varying(6) DEFAULT 'es_CO'::character varying NOT NULL,
    id integer DEFAULT nextval('public.usuario_id_seq'::regclass) NOT NULL,
    fechacreacion date DEFAULT CURRENT_DATE NOT NULL,
    fechadeshabilitacion date,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    sign_in_count integer DEFAULT 0 NOT NULL,
    failed_attempts integer,
    unlock_token character varying(64),
    locked_at timestamp without time zone,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    oficina_id integer,
    tema_id integer,
    observadorffechaini date,
    observadorffechafin date,
    CONSTRAINT usuario_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion))),
    CONSTRAINT usuario_rol_check CHECK ((rol >= 1))
);


--
-- Name: sivel2_gen_iniciador; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sivel2_gen_iniciador AS
 SELECT s3.id_caso,
    s3.fechainicio,
    s3.id_usuario,
    usuario.nusuario
   FROM public.usuario,
    ( SELECT s2.id_caso,
            s2.fechainicio,
            min(s2.id_usuario) AS id_usuario
           FROM public.sivel2_gen_caso_usuario s2,
            ( SELECT f1.id_caso,
                    min(f1.fechainicio) AS m
                   FROM public.sivel2_gen_caso_usuario f1
                  GROUP BY f1.id_caso) c
          WHERE ((s2.id_caso = c.id_caso) AND (s2.fechainicio = c.m))
          GROUP BY s2.id_caso, s2.fechainicio
          ORDER BY s2.id_caso, s2.fechainicio) s3
  WHERE (usuario.id = s3.id_usuario);


--
-- Name: sivel2_gen_intervalo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_intervalo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_intervalo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_intervalo (
    id integer DEFAULT nextval('public.sivel2_gen_intervalo_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    rango character varying(25) NOT NULL,
    fechacreacion date DEFAULT '2001-01-01'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT intervalo_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_maternidad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_maternidad (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_gen_maternidad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_maternidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_maternidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_maternidad_id_seq OWNED BY public.sivel2_gen_maternidad.id;


--
-- Name: sivel2_gen_municipio_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_municipio_region (
    municipio_id integer,
    region_id integer
);


--
-- Name: sivel2_gen_observador_filtrodepartamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_observador_filtrodepartamento (
    usuario_id integer,
    departamento_id integer
);


--
-- Name: sivel2_gen_organizacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_organizacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_organizacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_organizacion (
    id integer DEFAULT nextval('public.sivel2_gen_organizacion_id_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2001-01-01'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT organizacion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_organizacion_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_organizacion_victimacolectiva (
    id_organizacion integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_otraorga_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_otraorga_victima (
    organizacion_id integer,
    victima_id integer
);


--
-- Name: sivel2_gen_pconsolidado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_pconsolidado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_pconsolidado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_pconsolidado (
    id integer DEFAULT nextval('public.sivel2_gen_pconsolidado_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    tipoviolencia character varying(25) NOT NULL,
    clasificacion character varying(25) NOT NULL,
    peso integer DEFAULT 0,
    fechacreacion date DEFAULT '2001-01-01'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(500),
    CONSTRAINT parametros_reporte_consolidado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_profesion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_profesion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_profesion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_profesion (
    id integer DEFAULT nextval('public.sivel2_gen_profesion_id_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT CURRENT_DATE NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT profesion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_profesion_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_profesion_victimacolectiva (
    id_profesion integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_rangoedad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_rangoedad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_rangoedad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_rangoedad (
    id integer DEFAULT nextval('public.sivel2_gen_rangoedad_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    limiteinferior integer DEFAULT 0 NOT NULL,
    limitesuperior integer DEFAULT 0 NOT NULL,
    fechacreacion date DEFAULT '2001-01-01'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT rango_edad_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_rangoedad_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_rangoedad_victimacolectiva (
    id_rangoedad integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_region (
    id integer DEFAULT nextval('public.sivel2_gen_region_id_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2001-01-01'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT region_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_resagresion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_resagresion (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_gen_resagresion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_resagresion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_resagresion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_resagresion_id_seq OWNED BY public.sivel2_gen_resagresion.id;


--
-- Name: sivel2_gen_sectorsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_sectorsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_sectorsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_sectorsocial (
    id integer DEFAULT nextval('public.sivel2_gen_sectorsocial_id_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2001-01-01'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT sector_social_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_sectorsocial_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_sectorsocial_victimacolectiva (
    id_sectorsocial integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_sectorsocialsec_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_sectorsocialsec_victima (
    sectorsocial_id integer,
    victima_id integer
);


--
-- Name: sivel2_gen_tviolencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_tviolencia (
    id character(1) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    nomcorto character varying(10) NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT tipo_violencia_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_victimacolectiva_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_victimacolectiva_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_victimacolectiva (
    personasaprox integer,
    organizacionarmada integer DEFAULT 35,
    id_grupoper integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sivel2_gen_victimacolectiva_id_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_victimacolectiva_vinculoestado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_victimacolectiva_vinculoestado (
    victimacolectiva_id integer NOT NULL,
    id_vinculoestado integer NOT NULL
);


--
-- Name: sivel2_gen_vinculoestado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_vinculoestado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_vinculoestado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_vinculoestado (
    id integer DEFAULT nextval('public.sivel2_gen_vinculoestado_id_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2001-01-01'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT vinculo_estado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: vvictimasoundexesp; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.vvictimasoundexesp AS
 SELECT sivel2_gen_victima.id_caso,
    sip_persona.id AS id_persona,
    (((sip_persona.nombres)::text || ' '::text) || (sip_persona.apellidos)::text) AS nomap,
    public.soundexespm((((sip_persona.nombres)::text || ' '::text) || (sip_persona.apellidos)::text)) AS nomsoundexesp
   FROM public.sip_persona,
    public.sivel2_gen_victima
  WHERE (sip_persona.id = sivel2_gen_victima.id_persona)
  WITH NO DATA;


--
-- Name: apo214_asisreconocimiento id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_asisreconocimiento ALTER COLUMN id SET DEFAULT nextval('public.apo214_asisreconocimiento_id_seq'::regclass);


--
-- Name: apo214_cobertura id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_cobertura ALTER COLUMN id SET DEFAULT nextval('public.apo214_cobertura_id_seq'::regclass);


--
-- Name: apo214_disposicioncadaveres id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_disposicioncadaveres ALTER COLUMN id SET DEFAULT nextval('public.apo214_disposicioncadaveres_id_seq'::regclass);


--
-- Name: apo214_elementopaisaje id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_elementopaisaje ALTER COLUMN id SET DEFAULT nextval('public.apo214_elementopaisaje_id_seq'::regclass);


--
-- Name: apo214_evaluacionriesgo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_evaluacionriesgo ALTER COLUMN id SET DEFAULT nextval('public.apo214_evaluacionriesgo_id_seq'::regclass);


--
-- Name: apo214_infoanomalia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_infoanomalia ALTER COLUMN id SET DEFAULT nextval('public.apo214_infoanomalia_id_seq'::regclass);


--
-- Name: apo214_infoanomalialugar id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_infoanomalialugar ALTER COLUMN id SET DEFAULT nextval('public.apo214_infoanomalialugar_id_seq'::regclass);


--
-- Name: apo214_listaanexo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listaanexo ALTER COLUMN id SET DEFAULT nextval('public.apo214_listaanexo_id_seq'::regclass);


--
-- Name: apo214_listadepositados id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listadepositados ALTER COLUMN id SET DEFAULT nextval('public.apo214_listadepositados_id_seq'::regclass);


--
-- Name: apo214_listaevariesgo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listaevariesgo ALTER COLUMN id SET DEFAULT nextval('public.apo214_listaevariesgo_id_seq'::regclass);


--
-- Name: apo214_listainfofoto id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listainfofoto ALTER COLUMN id SET DEFAULT nextval('public.apo214_listainfofoto_id_seq'::regclass);


--
-- Name: apo214_listapersofuentes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listapersofuentes ALTER COLUMN id SET DEFAULT nextval('public.apo214_listapersofuentes_id_seq'::regclass);


--
-- Name: apo214_listasuelo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listasuelo ALTER COLUMN id SET DEFAULT nextval('public.apo214_listasuelo_id_seq'::regclass);


--
-- Name: apo214_lugarpreliminar id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_lugarpreliminar ALTER COLUMN id SET DEFAULT nextval('public.apo214_lugarpreliminar_id_seq'::regclass);


--
-- Name: apo214_propietario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_propietario ALTER COLUMN id SET DEFAULT nextval('public.apo214_propietario_id_seq'::regclass);


--
-- Name: apo214_riesgo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_riesgo ALTER COLUMN id SET DEFAULT nextval('public.apo214_riesgo_id_seq'::regclass);


--
-- Name: apo214_suelo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_suelo ALTER COLUMN id SET DEFAULT nextval('public.apo214_suelo_id_seq'::regclass);


--
-- Name: apo214_tipoentierro id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_tipoentierro ALTER COLUMN id SET DEFAULT nextval('public.apo214_tipoentierro_id_seq'::regclass);


--
-- Name: apo214_tipotestigo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_tipotestigo ALTER COLUMN id SET DEFAULT nextval('public.apo214_tipotestigo_id_seq'::regclass);


--
-- Name: heb412_gen_campohc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campohc ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_campohc_id_seq'::regclass);


--
-- Name: heb412_gen_campoplantillahcm id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campoplantillahcm ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_campoplantillahcm_id_seq'::regclass);


--
-- Name: heb412_gen_campoplantillahcr id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campoplantillahcr ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_campoplantillahcr_id_seq'::regclass);


--
-- Name: heb412_gen_carpetaexclusiva id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_carpetaexclusiva ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_carpetaexclusiva_id_seq'::regclass);


--
-- Name: heb412_gen_doc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_doc ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_doc_id_seq'::regclass);


--
-- Name: heb412_gen_formulario_plantillahcr id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcr ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_formulario_plantillahcr_id_seq'::regclass);


--
-- Name: heb412_gen_plantilladoc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantilladoc ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_plantilladoc_id_seq'::regclass);


--
-- Name: heb412_gen_plantillahcm id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantillahcm ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_plantillahcm_id_seq'::regclass);


--
-- Name: heb412_gen_plantillahcr id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantillahcr ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_plantillahcr_id_seq'::regclass);


--
-- Name: mr519_gen_campo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_campo ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_campo_id_seq'::regclass);


--
-- Name: mr519_gen_encuestapersona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_encuestapersona_id_seq'::regclass);


--
-- Name: mr519_gen_encuestausuario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_encuestausuario_id_seq'::regclass);


--
-- Name: mr519_gen_formulario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_formulario ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_formulario_id_seq'::regclass);


--
-- Name: mr519_gen_opcioncs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_opcioncs ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_opcioncs_id_seq'::regclass);


--
-- Name: mr519_gen_planencuesta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_planencuesta ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_planencuesta_id_seq'::regclass);


--
-- Name: mr519_gen_respuestafor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_respuestafor ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_respuestafor_id_seq'::regclass);


--
-- Name: mr519_gen_valorcampo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_valorcampo_id_seq'::regclass);


--
-- Name: sip_anexo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_anexo ALTER COLUMN id SET DEFAULT nextval('public.sip_anexo_id_seq'::regclass);


--
-- Name: sip_bitacora id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_bitacora ALTER COLUMN id SET DEFAULT nextval('public.sip_bitacora_id_seq'::regclass);


--
-- Name: sip_grupo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupo ALTER COLUMN id SET DEFAULT nextval('public.sip_grupo_id_seq'::regclass);


--
-- Name: sip_oficina id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_oficina ALTER COLUMN id SET DEFAULT nextval('public.sip_oficina_id_seq'::regclass);


--
-- Name: sip_orgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial ALTER COLUMN id SET DEFAULT nextval('public.sip_orgsocial_id_seq'::regclass);


--
-- Name: sip_orgsocial_persona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial_persona ALTER COLUMN id SET DEFAULT nextval('public.sip_orgsocial_persona_id_seq'::regclass);


--
-- Name: sip_pais id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_pais ALTER COLUMN id SET DEFAULT nextval('public.sip_pais_id_seq'::regclass);


--
-- Name: sip_pais_histvigencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_pais_histvigencia ALTER COLUMN id SET DEFAULT nextval('public.sip_pais_histvigencia_id_seq'::regclass);


--
-- Name: sip_perfilorgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_perfilorgsocial ALTER COLUMN id SET DEFAULT nextval('public.sip_perfilorgsocial_id_seq'::regclass);


--
-- Name: sip_sectororgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_sectororgsocial ALTER COLUMN id SET DEFAULT nextval('public.sip_sectororgsocial_id_seq'::regclass);


--
-- Name: sip_tdocumento id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tdocumento ALTER COLUMN id SET DEFAULT nextval('public.sip_tdocumento_id_seq'::regclass);


--
-- Name: sip_tema id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tema ALTER COLUMN id SET DEFAULT nextval('public.sip_tema_id_seq'::regclass);


--
-- Name: sip_trivalente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_trivalente ALTER COLUMN id SET DEFAULT nextval('public.sip_trivalente_id_seq'::regclass);


--
-- Name: sip_ubicacionpre id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacionpre ALTER COLUMN id SET DEFAULT nextval('public.sip_ubicacionpre_id_seq'::regclass);


--
-- Name: sivel2_gen_actividadoficio id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actividadoficio ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_actividadoficio_id_seq'::regclass);


--
-- Name: sivel2_gen_combatiente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_combatiente_id_seq'::regclass);


--
-- Name: sivel2_gen_contextovictima id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contextovictima ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_contextovictima_id_seq'::regclass);


--
-- Name: sivel2_gen_escolaridad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_escolaridad ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_escolaridad_id_seq'::regclass);


--
-- Name: sivel2_gen_estadocivil id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_estadocivil ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_estadocivil_id_seq'::regclass);


--
-- Name: sivel2_gen_maternidad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_maternidad ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_maternidad_id_seq'::regclass);


--
-- Name: sivel2_gen_resagresion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_resagresion ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_resagresion_id_seq'::regclass);


--
-- Name: sivel2_gen_acto acto_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_key UNIQUE (id);


--
-- Name: sivel2_gen_acto acto_id_presponsable_id_categoria_id_persona_id_caso_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_presponsable_id_categoria_id_persona_id_caso_key UNIQUE (id_presponsable, id_categoria, id_persona, id_caso);


--
-- Name: apo214_asisreconocimiento apo214_asisreconocimiento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_asisreconocimiento
    ADD CONSTRAINT apo214_asisreconocimiento_pkey PRIMARY KEY (id);


--
-- Name: apo214_cobertura apo214_cobertura_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_cobertura
    ADD CONSTRAINT apo214_cobertura_pkey PRIMARY KEY (id);


--
-- Name: apo214_disposicioncadaveres apo214_disposicioncadaveres_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_disposicioncadaveres
    ADD CONSTRAINT apo214_disposicioncadaveres_pkey PRIMARY KEY (id);


--
-- Name: apo214_elementopaisaje apo214_elementopaisaje_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_elementopaisaje
    ADD CONSTRAINT apo214_elementopaisaje_pkey PRIMARY KEY (id);


--
-- Name: apo214_evaluacionriesgo apo214_evaluacionriesgo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_evaluacionriesgo
    ADD CONSTRAINT apo214_evaluacionriesgo_pkey PRIMARY KEY (id);


--
-- Name: apo214_infoanomalia apo214_infoanomalia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_infoanomalia
    ADD CONSTRAINT apo214_infoanomalia_pkey PRIMARY KEY (id);


--
-- Name: apo214_infoanomalialugar apo214_infoanomalialugar_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_infoanomalialugar
    ADD CONSTRAINT apo214_infoanomalialugar_pkey PRIMARY KEY (id);


--
-- Name: apo214_listaanexo apo214_listaanexo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listaanexo
    ADD CONSTRAINT apo214_listaanexo_pkey PRIMARY KEY (id);


--
-- Name: apo214_listadepositados apo214_listadepositados_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listadepositados
    ADD CONSTRAINT apo214_listadepositados_pkey PRIMARY KEY (id);


--
-- Name: apo214_listaevariesgo apo214_listaevariesgo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listaevariesgo
    ADD CONSTRAINT apo214_listaevariesgo_pkey PRIMARY KEY (id);


--
-- Name: apo214_listainfofoto apo214_listainfofoto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listainfofoto
    ADD CONSTRAINT apo214_listainfofoto_pkey PRIMARY KEY (id);


--
-- Name: apo214_listapersofuentes apo214_listapersofuentes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listapersofuentes
    ADD CONSTRAINT apo214_listapersofuentes_pkey PRIMARY KEY (id);


--
-- Name: apo214_listasuelo apo214_listasuelo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listasuelo
    ADD CONSTRAINT apo214_listasuelo_pkey PRIMARY KEY (id);


--
-- Name: apo214_lugarpreliminar apo214_lugarpreliminar_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_lugarpreliminar
    ADD CONSTRAINT apo214_lugarpreliminar_pkey PRIMARY KEY (id);


--
-- Name: apo214_propietario apo214_propietario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_propietario
    ADD CONSTRAINT apo214_propietario_pkey PRIMARY KEY (id);


--
-- Name: apo214_riesgo apo214_riesgo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_riesgo
    ADD CONSTRAINT apo214_riesgo_pkey PRIMARY KEY (id);


--
-- Name: apo214_suelo apo214_suelo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_suelo
    ADD CONSTRAINT apo214_suelo_pkey PRIMARY KEY (id);


--
-- Name: apo214_tipoentierro apo214_tipoentierro_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_tipoentierro
    ADD CONSTRAINT apo214_tipoentierro_pkey PRIMARY KEY (id);


--
-- Name: apo214_tipotestigo apo214_tipotestigo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_tipotestigo
    ADD CONSTRAINT apo214_tipotestigo_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: sivel2_gen_caso_etiqueta caso_etiqueta_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_id_key UNIQUE (id);


--
-- Name: sivel2_gen_caso_presponsable caso_presponsable_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT caso_presponsable_id_key UNIQUE (id);


--
-- Name: sivel2_gen_categoria categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_frontera frontera_caso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_frontera
    ADD CONSTRAINT frontera_caso_pkey PRIMARY KEY (id_frontera, id_caso);


--
-- Name: heb412_gen_campohc heb412_gen_campohc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campohc
    ADD CONSTRAINT heb412_gen_campohc_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_campoplantillahcm heb412_gen_campoplantillahcm_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campoplantillahcm
    ADD CONSTRAINT heb412_gen_campoplantillahcm_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_campoplantillahcr heb412_gen_campoplantillahcr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campoplantillahcr
    ADD CONSTRAINT heb412_gen_campoplantillahcr_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_carpetaexclusiva heb412_gen_carpetaexclusiva_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_carpetaexclusiva
    ADD CONSTRAINT heb412_gen_carpetaexclusiva_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_doc heb412_gen_doc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_doc
    ADD CONSTRAINT heb412_gen_doc_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_formulario_plantillahcr heb412_gen_formulario_plantillahcr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcr
    ADD CONSTRAINT heb412_gen_formulario_plantillahcr_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_plantilladoc heb412_gen_plantilladoc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantilladoc
    ADD CONSTRAINT heb412_gen_plantilladoc_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_plantillahcm heb412_gen_plantillahcm_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantillahcm
    ADD CONSTRAINT heb412_gen_plantillahcm_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_plantillahcr heb412_gen_plantillahcr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantillahcr
    ADD CONSTRAINT heb412_gen_plantillahcr_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_campo mr519_gen_campo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_campo
    ADD CONSTRAINT mr519_gen_campo_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_encuestapersona mr519_gen_encuestapersona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT mr519_gen_encuestapersona_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_encuestausuario mr519_gen_encuestausuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario
    ADD CONSTRAINT mr519_gen_encuestausuario_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_formulario mr519_gen_formulario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_formulario
    ADD CONSTRAINT mr519_gen_formulario_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_opcioncs mr519_gen_opcioncs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_opcioncs
    ADD CONSTRAINT mr519_gen_opcioncs_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_planencuesta mr519_gen_planencuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_planencuesta
    ADD CONSTRAINT mr519_gen_planencuesta_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_respuestafor mr519_gen_respuestafor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_respuestafor
    ADD CONSTRAINT mr519_gen_respuestafor_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_valorcampo mr519_gen_valorcampo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo
    ADD CONSTRAINT mr519_gen_valorcampo_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_pconsolidado pconsolidado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_pconsolidado
    ADD CONSTRAINT pconsolidado_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sip_anexo sip_anexo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_anexo
    ADD CONSTRAINT sip_anexo_pkey PRIMARY KEY (id);


--
-- Name: sip_bitacora sip_bitacora_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_bitacora
    ADD CONSTRAINT sip_bitacora_pkey PRIMARY KEY (id);


--
-- Name: sip_clase sip_clase_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT sip_clase_id_key UNIQUE (id);


--
-- Name: sip_clase sip_clase_id_municipio_id_clalocal_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT sip_clase_id_municipio_id_clalocal_key UNIQUE (id_municipio, id_clalocal);


--
-- Name: sip_clase sip_clase_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT sip_clase_pkey PRIMARY KEY (id);


--
-- Name: sip_departamento sip_departamento_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_departamento
    ADD CONSTRAINT sip_departamento_id_key UNIQUE (id);


--
-- Name: sip_departamento sip_departamento_id_pais_id_deplocal_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_departamento
    ADD CONSTRAINT sip_departamento_id_pais_id_deplocal_unico UNIQUE (id_pais, id_deplocal);


--
-- Name: sip_departamento sip_departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_departamento
    ADD CONSTRAINT sip_departamento_pkey PRIMARY KEY (id);


--
-- Name: sip_grupo sip_grupo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupo
    ADD CONSTRAINT sip_grupo_pkey PRIMARY KEY (id);


--
-- Name: sip_grupoper sip_grupoper_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupoper
    ADD CONSTRAINT sip_grupoper_pkey PRIMARY KEY (id);


--
-- Name: sip_municipio sip_municipio_id_departamento_id_munlocal_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_municipio
    ADD CONSTRAINT sip_municipio_id_departamento_id_munlocal_unico UNIQUE (id_departamento, id_munlocal);


--
-- Name: sip_municipio sip_municipio_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_municipio
    ADD CONSTRAINT sip_municipio_id_key UNIQUE (id);


--
-- Name: sip_municipio sip_municipio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_municipio
    ADD CONSTRAINT sip_municipio_pkey PRIMARY KEY (id);


--
-- Name: sip_orgsocial_persona sip_orgsocial_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial_persona
    ADD CONSTRAINT sip_orgsocial_persona_pkey PRIMARY KEY (id);


--
-- Name: sip_orgsocial sip_orgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial
    ADD CONSTRAINT sip_orgsocial_pkey PRIMARY KEY (id);


--
-- Name: sip_pais sip_pais_codiso_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_pais
    ADD CONSTRAINT sip_pais_codiso_unico UNIQUE (codiso);


--
-- Name: sip_pais_histvigencia sip_pais_histvigencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_pais_histvigencia
    ADD CONSTRAINT sip_pais_histvigencia_pkey PRIMARY KEY (id);


--
-- Name: sip_perfilorgsocial sip_perfilorgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_perfilorgsocial
    ADD CONSTRAINT sip_perfilorgsocial_pkey PRIMARY KEY (id);


--
-- Name: sip_persona_trelacion sip_persona_trelacion_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT sip_persona_trelacion_id_key UNIQUE (id);


--
-- Name: sip_persona_trelacion sip_persona_trelacion_persona1_persona2_id_trelacion_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT sip_persona_trelacion_persona1_persona2_id_trelacion_key UNIQUE (persona1, persona2, id_trelacion);


--
-- Name: sip_persona_trelacion sip_persona_trelacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT sip_persona_trelacion_pkey PRIMARY KEY (id);


--
-- Name: sip_sectororgsocial sip_sectororgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_sectororgsocial
    ADD CONSTRAINT sip_sectororgsocial_pkey PRIMARY KEY (id);


--
-- Name: sip_tema sip_tema_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tema
    ADD CONSTRAINT sip_tema_pkey PRIMARY KEY (id);


--
-- Name: sip_trivalente sip_trivalente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_trivalente
    ADD CONSTRAINT sip_trivalente_pkey PRIMARY KEY (id);


--
-- Name: sip_ubicacionpre sip_ubicacionpre_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacionpre
    ADD CONSTRAINT sip_ubicacionpre_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_actividadoficio sivel2_gen_actividadoficio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actividadoficio
    ADD CONSTRAINT sivel2_gen_actividadoficio_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_acto sivel2_gen_acto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT sivel2_gen_acto_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_actocolectivo sivel2_gen_actocolectivo_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT sivel2_gen_actocolectivo_id_key UNIQUE (id);


--
-- Name: sivel2_gen_actocolectivo sivel2_gen_actocolectivo_id_presponsable_id_categoria_id_gr_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT sivel2_gen_actocolectivo_id_presponsable_id_categoria_id_gr_key UNIQUE (id_presponsable, id_categoria, id_grupoper, id_caso);


--
-- Name: sivel2_gen_actocolectivo sivel2_gen_actocolectivo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT sivel2_gen_actocolectivo_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_anexo_caso sivel2_gen_anexo_caso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_caso
    ADD CONSTRAINT sivel2_gen_anexo_caso_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_antecedente_caso sivel2_gen_antecedente_caso_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_caso
    ADD CONSTRAINT sivel2_gen_antecedente_caso_pkey1 PRIMARY KEY (id_antecedente, id_caso);


--
-- Name: sivel2_gen_antecedente_combatiente sivel2_gen_antecedente_combatiente_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_combatiente
    ADD CONSTRAINT sivel2_gen_antecedente_combatiente_pkey1 PRIMARY KEY (id_antecedente, id_combatiente);


--
-- Name: sivel2_gen_antecedente sivel2_gen_antecedente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente
    ADD CONSTRAINT sivel2_gen_antecedente_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_antecedente_victima sivel2_gen_antecedente_victima_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victima
    ADD CONSTRAINT sivel2_gen_antecedente_victima_pkey1 PRIMARY KEY (id_antecedente, id_victima);


--
-- Name: sivel2_gen_antecedente_victimacolectiva sivel2_gen_antecedente_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victimacolectiva
    ADD CONSTRAINT sivel2_gen_antecedente_victimacolectiva_pkey1 PRIMARY KEY (id_antecedente, victimacolectiva_id);


--
-- Name: sivel2_gen_caso_categoria_presponsable sivel2_gen_caso_categoria_pre_id_caso_presponsable_id_categ_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT sivel2_gen_caso_categoria_pre_id_caso_presponsable_id_categ_key UNIQUE (id_caso_presponsable, id_categoria);


--
-- Name: sivel2_gen_caso_categoria_presponsable sivel2_gen_caso_categoria_presponsable_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT sivel2_gen_caso_categoria_presponsable_id_key UNIQUE (id);


--
-- Name: sivel2_gen_caso_categoria_presponsable sivel2_gen_caso_categoria_presponsable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT sivel2_gen_caso_categoria_presponsable_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_contexto sivel2_gen_caso_contexto_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_contexto
    ADD CONSTRAINT sivel2_gen_caso_contexto_pkey1 PRIMARY KEY (id_caso, id_contexto);


--
-- Name: sivel2_gen_caso_etiqueta sivel2_gen_caso_etiqueta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_etiqueta
    ADD CONSTRAINT sivel2_gen_caso_etiqueta_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_fotra sivel2_gen_caso_fotra_id_caso_nombre_fecha_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fotra
    ADD CONSTRAINT sivel2_gen_caso_fotra_id_caso_nombre_fecha_key UNIQUE (id_caso, nombre, fecha);


--
-- Name: sivel2_gen_caso_fotra sivel2_gen_caso_fotra_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fotra
    ADD CONSTRAINT sivel2_gen_caso_fotra_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_fuenteprensa sivel2_gen_caso_fuenteprensa_id_caso_fecha_fuenteprensa_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT sivel2_gen_caso_fuenteprensa_id_caso_fecha_fuenteprensa_id_key UNIQUE (id_caso, fecha, fuenteprensa_id);


--
-- Name: sivel2_gen_caso_fuenteprensa sivel2_gen_caso_fuenteprensa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT sivel2_gen_caso_fuenteprensa_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso sivel2_gen_caso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso
    ADD CONSTRAINT sivel2_gen_caso_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_presponsable sivel2_gen_caso_presponsable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT sivel2_gen_caso_presponsable_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_region sivel2_gen_caso_region_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_region
    ADD CONSTRAINT sivel2_gen_caso_region_pkey1 PRIMARY KEY (id_caso, id_region);


--
-- Name: sivel2_gen_caso_respuestafor sivel2_gen_caso_respuestafor_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_respuestafor
    ADD CONSTRAINT sivel2_gen_caso_respuestafor_pkey1 PRIMARY KEY (caso_id, respuestafor_id);


--
-- Name: sivel2_gen_combatiente sivel2_gen_combatiente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT sivel2_gen_combatiente_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_contexto sivel2_gen_contexto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contexto
    ADD CONSTRAINT sivel2_gen_contexto_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_contextovictima sivel2_gen_contextovictima_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contextovictima
    ADD CONSTRAINT sivel2_gen_contextovictima_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_contextovictima_victima sivel2_gen_contextovictima_victima_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contextovictima_victima
    ADD CONSTRAINT sivel2_gen_contextovictima_victima_pkey1 PRIMARY KEY (contextovictima_id, victima_id);


--
-- Name: sivel2_gen_escolaridad sivel2_gen_escolaridad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_escolaridad
    ADD CONSTRAINT sivel2_gen_escolaridad_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_estadocivil sivel2_gen_estadocivil_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_estadocivil
    ADD CONSTRAINT sivel2_gen_estadocivil_pkey PRIMARY KEY (id);


--
-- Name: sip_etiqueta sivel2_gen_etiqueta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_etiqueta
    ADD CONSTRAINT sivel2_gen_etiqueta_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_etnia sivel2_gen_etnia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_etnia
    ADD CONSTRAINT sivel2_gen_etnia_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_etnia_victimacolectiva sivel2_gen_etnia_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_etnia_victimacolectiva
    ADD CONSTRAINT sivel2_gen_etnia_victimacolectiva_pkey1 PRIMARY KEY (etnia_id, victimacolectiva_id);


--
-- Name: sip_fuenteprensa sivel2_gen_ffrecuente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_fuenteprensa
    ADD CONSTRAINT sivel2_gen_ffrecuente_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_filiacion sivel2_gen_filiacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_filiacion
    ADD CONSTRAINT sivel2_gen_filiacion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_filiacion_victimacolectiva sivel2_gen_filiacion_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_filiacion_victimacolectiva
    ADD CONSTRAINT sivel2_gen_filiacion_victimacolectiva_pkey1 PRIMARY KEY (id_filiacion, victimacolectiva_id);


--
-- Name: sivel2_gen_fotra sivel2_gen_fotra_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_fotra
    ADD CONSTRAINT sivel2_gen_fotra_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_frontera sivel2_gen_frontera_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_frontera
    ADD CONSTRAINT sivel2_gen_frontera_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_iglesia sivel2_gen_iglesia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_iglesia
    ADD CONSTRAINT sivel2_gen_iglesia_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_intervalo sivel2_gen_intervalo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_intervalo
    ADD CONSTRAINT sivel2_gen_intervalo_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_maternidad sivel2_gen_maternidad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_maternidad
    ADD CONSTRAINT sivel2_gen_maternidad_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_organizacion sivel2_gen_organizacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_organizacion
    ADD CONSTRAINT sivel2_gen_organizacion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_organizacion_victimacolectiva sivel2_gen_organizacion_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_organizacion_victimacolectiva
    ADD CONSTRAINT sivel2_gen_organizacion_victimacolectiva_pkey1 PRIMARY KEY (id_organizacion, victimacolectiva_id);


--
-- Name: sip_pais sivel2_gen_pais_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_pais
    ADD CONSTRAINT sivel2_gen_pais_pkey PRIMARY KEY (id);


--
-- Name: sip_persona sivel2_gen_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT sivel2_gen_persona_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_presponsable sivel2_gen_presponsable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_presponsable
    ADD CONSTRAINT sivel2_gen_presponsable_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_profesion sivel2_gen_profesion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion
    ADD CONSTRAINT sivel2_gen_profesion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_profesion_victimacolectiva sivel2_gen_profesion_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion_victimacolectiva
    ADD CONSTRAINT sivel2_gen_profesion_victimacolectiva_pkey1 PRIMARY KEY (id_profesion, victimacolectiva_id);


--
-- Name: sivel2_gen_rangoedad sivel2_gen_rangoedad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_rangoedad
    ADD CONSTRAINT sivel2_gen_rangoedad_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_rangoedad_victimacolectiva sivel2_gen_rangoedad_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_rangoedad_victimacolectiva
    ADD CONSTRAINT sivel2_gen_rangoedad_victimacolectiva_pkey1 PRIMARY KEY (id_rangoedad, victimacolectiva_id);


--
-- Name: sivel2_gen_region sivel2_gen_region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_region
    ADD CONSTRAINT sivel2_gen_region_pkey PRIMARY KEY (id);


--
-- Name: sip_oficina sivel2_gen_regionsjr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_oficina
    ADD CONSTRAINT sivel2_gen_regionsjr_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_resagresion sivel2_gen_resagresion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_resagresion
    ADD CONSTRAINT sivel2_gen_resagresion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_sectorsocial sivel2_gen_sectorsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocial
    ADD CONSTRAINT sivel2_gen_sectorsocial_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_sectorsocial_victimacolectiva sivel2_gen_sectorsocial_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocial_victimacolectiva
    ADD CONSTRAINT sivel2_gen_sectorsocial_victimacolectiva_pkey1 PRIMARY KEY (id_sectorsocial, victimacolectiva_id);


--
-- Name: sivel2_gen_supracategoria sivel2_gen_supracategoria_id_tviolencia_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_supracategoria
    ADD CONSTRAINT sivel2_gen_supracategoria_id_tviolencia_codigo_key UNIQUE (id_tviolencia, codigo);


--
-- Name: sivel2_gen_supracategoria sivel2_gen_supracategoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_supracategoria
    ADD CONSTRAINT sivel2_gen_supracategoria_pkey PRIMARY KEY (id);


--
-- Name: sip_tdocumento sivel2_gen_tdocumento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tdocumento
    ADD CONSTRAINT sivel2_gen_tdocumento_pkey PRIMARY KEY (id);


--
-- Name: sip_tsitio sivel2_gen_tsitio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tsitio
    ADD CONSTRAINT sivel2_gen_tsitio_pkey PRIMARY KEY (id);


--
-- Name: sip_ubicacion sivel2_gen_ubicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT sivel2_gen_ubicacion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_victima sivel2_gen_victima_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT sivel2_gen_victima_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_victimacolectiva sivel2_gen_victimacolectiva_id_caso_id_grupoper_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT sivel2_gen_victimacolectiva_id_caso_id_grupoper_key UNIQUE (id_caso, id_grupoper);


--
-- Name: sivel2_gen_victimacolectiva sivel2_gen_victimacolectiva_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT sivel2_gen_victimacolectiva_id_key UNIQUE (id);


--
-- Name: sivel2_gen_victimacolectiva sivel2_gen_victimacolectiva_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT sivel2_gen_victimacolectiva_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_victimacolectiva_vinculoestado sivel2_gen_victimacolectiva_vinculoestado_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva_vinculoestado
    ADD CONSTRAINT sivel2_gen_victimacolectiva_vinculoestado_pkey1 PRIMARY KEY (victimacolectiva_id, id_vinculoestado);


--
-- Name: sivel2_gen_vinculoestado sivel2_gen_vinculoestado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_vinculoestado
    ADD CONSTRAINT sivel2_gen_vinculoestado_pkey PRIMARY KEY (id);


--
-- Name: sip_tclase tipo_clase_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tclase
    ADD CONSTRAINT tipo_clase_pkey PRIMARY KEY (id);


--
-- Name: sip_trelacion tipo_relacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_trelacion
    ADD CONSTRAINT tipo_relacion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_tviolencia tipo_violencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_tviolencia
    ADD CONSTRAINT tipo_violencia_pkey PRIMARY KEY (id);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_victima victima_id_caso_id_persona_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_caso_id_persona_key UNIQUE (id_caso, id_persona);


--
-- Name: sivel2_gen_victima victima_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_key UNIQUE (id);


--
-- Name: busca_sivel2_gen_conscaso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX busca_sivel2_gen_conscaso ON public.sivel2_gen_conscaso USING gin (q);


--
-- Name: caso_fecha_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX caso_fecha_idx ON public.sivel2_gen_caso USING btree (fecha);


--
-- Name: caso_fecha_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX caso_fecha_idx1 ON public.sivel2_gen_caso USING btree (fecha);


--
-- Name: index_heb412_gen_doc_on_tdoc_type_and_tdoc_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_heb412_gen_doc_on_tdoc_type_and_tdoc_id ON public.heb412_gen_doc USING btree (tdoc_type, tdoc_id);


--
-- Name: index_mr519_gen_encuestapersona_on_adurl; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_mr519_gen_encuestapersona_on_adurl ON public.mr519_gen_encuestapersona USING btree (adurl);


--
-- Name: index_sip_orgsocial_on_grupoper_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_orgsocial_on_grupoper_id ON public.sip_orgsocial USING btree (grupoper_id);


--
-- Name: index_sip_orgsocial_on_pais_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_orgsocial_on_pais_id ON public.sip_orgsocial USING btree (pais_id);


--
-- Name: index_sip_ubicacion_on_id_clase; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_ubicacion_on_id_clase ON public.sip_ubicacion USING btree (id_clase);


--
-- Name: index_sip_ubicacion_on_id_departamento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_ubicacion_on_id_departamento ON public.sip_ubicacion USING btree (id_departamento);


--
-- Name: index_sip_ubicacion_on_id_municipio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_ubicacion_on_id_municipio ON public.sip_ubicacion USING btree (id_municipio);


--
-- Name: index_sip_ubicacion_on_id_pais; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_ubicacion_on_id_pais ON public.sip_ubicacion USING btree (id_pais);


--
-- Name: index_sivel2_gen_otraorga_victima_on_organizacion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_otraorga_victima_on_organizacion_id ON public.sivel2_gen_otraorga_victima USING btree (organizacion_id);


--
-- Name: index_sivel2_gen_otraorga_victima_on_victima_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_otraorga_victima_on_victima_id ON public.sivel2_gen_otraorga_victima USING btree (victima_id);


--
-- Name: index_sivel2_gen_sectorsocialsec_victima_on_sectorsocial_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_sectorsocialsec_victima_on_sectorsocial_id ON public.sivel2_gen_sectorsocialsec_victima USING btree (sectorsocial_id);


--
-- Name: index_sivel2_gen_sectorsocialsec_victima_on_victima_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_sectorsocialsec_victima_on_victima_id ON public.sivel2_gen_sectorsocialsec_victima USING btree (victima_id);


--
-- Name: index_usuario_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_usuario_on_email ON public.usuario USING btree (email);


--
-- Name: index_usuario_on_regionsjr_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_usuario_on_regionsjr_id ON public.usuario USING btree (oficina_id);


--
-- Name: index_usuario_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_usuario_on_reset_password_token ON public.usuario USING btree (reset_password_token);


--
-- Name: indice_sip_ubicacion_sobre_id_caso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sip_ubicacion_sobre_id_caso ON public.sip_ubicacion USING btree (id_caso);


--
-- Name: indice_sivel2_gen_acto_sobre_id_caso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_acto_sobre_id_caso ON public.sivel2_gen_acto USING btree (id_caso);


--
-- Name: indice_sivel2_gen_acto_sobre_id_categoria; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_acto_sobre_id_categoria ON public.sivel2_gen_acto USING btree (id_categoria);


--
-- Name: indice_sivel2_gen_acto_sobre_id_persona; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_acto_sobre_id_persona ON public.sivel2_gen_acto USING btree (id_persona);


--
-- Name: indice_sivel2_gen_acto_sobre_id_presponsable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_acto_sobre_id_presponsable ON public.sivel2_gen_acto USING btree (id_presponsable);


--
-- Name: indice_sivel2_gen_caso_presponsable_sobre_id_caso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_caso_presponsable_sobre_id_caso ON public.sivel2_gen_caso_presponsable USING btree (id_caso);


--
-- Name: indice_sivel2_gen_caso_presponsable_sobre_id_presponsable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_caso_presponsable_sobre_id_presponsable ON public.sivel2_gen_caso_presponsable USING btree (id_presponsable);


--
-- Name: indice_sivel2_gen_caso_presponsable_sobre_ids_caso_presp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_caso_presponsable_sobre_ids_caso_presp ON public.sivel2_gen_caso_presponsable USING btree (id_caso, id_presponsable);


--
-- Name: indice_sivel2_gen_caso_sobre_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_caso_sobre_fecha ON public.sivel2_gen_caso USING btree (fecha);


--
-- Name: indice_sivel2_gen_caso_sobre_ubicacion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_caso_sobre_ubicacion_id ON public.sivel2_gen_caso USING btree (ubicacion_id);


--
-- Name: indice_sivel2_gen_categoria_sobre_supracategoria_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_categoria_sobre_supracategoria_id ON public.sivel2_gen_categoria USING btree (supracategoria_id);


--
-- Name: sip_busca_mundep; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sip_busca_mundep ON public.sip_mundep USING gin (mundep);


--
-- Name: sip_clase_id_municipio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sip_clase_id_municipio ON public.sip_clase USING btree (id_municipio);


--
-- Name: sip_departamento_id_pais; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sip_departamento_id_pais ON public.sip_departamento USING btree (id_pais);


--
-- Name: sip_municipio_id_departamento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sip_municipio_id_departamento ON public.sip_municipio USING btree (id_departamento);


--
-- Name: sip_nombre_ubicacionpre_b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sip_nombre_ubicacionpre_b ON public.sip_ubicacionpre USING gin (to_tsvector('spanish'::regconfig, public.f_unaccent((nombre)::text)));


--
-- Name: sip_persona_anionac; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sip_persona_anionac ON public.sip_persona USING btree (anionac);


--
-- Name: sip_persona_anionac_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sip_persona_anionac_ind ON public.sip_persona USING btree (anionac);


--
-- Name: sip_persona_sexo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sip_persona_sexo ON public.sip_persona USING btree (sexo);


--
-- Name: sip_persona_sexo_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sip_persona_sexo_ind ON public.sip_persona USING btree (sexo);


--
-- Name: sivel2_gen_caso_anio_mes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_caso_anio_mes ON public.sivel2_gen_caso USING btree (((((date_part('year'::text, (fecha)::timestamp without time zone))::text || '-'::text) || lpad((date_part('month'::text, (fecha)::timestamp without time zone))::text, 2, '0'::text))));


--
-- Name: sivel2_gen_obs_fildep_d_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_obs_fildep_d_idx ON public.sivel2_gen_observador_filtrodepartamento USING btree (departamento_id);


--
-- Name: sivel2_gen_obs_fildep_u_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_obs_fildep_u_idx ON public.sivel2_gen_observador_filtrodepartamento USING btree (usuario_id);


--
-- Name: sivel2_gen_victima_id_caso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_caso ON public.sivel2_gen_victima USING btree (id_caso);


--
-- Name: sivel2_gen_victima_id_etnia; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_etnia ON public.sivel2_gen_victima USING btree (id_etnia);


--
-- Name: sivel2_gen_victima_id_filiacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_filiacion ON public.sivel2_gen_victima USING btree (id_filiacion);


--
-- Name: sivel2_gen_victima_id_iglesia; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_iglesia ON public.sivel2_gen_victima USING btree (id_iglesia);


--
-- Name: sivel2_gen_victima_id_organizacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_organizacion ON public.sivel2_gen_victima USING btree (id_organizacion);


--
-- Name: sivel2_gen_victima_id_persona; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_persona ON public.sivel2_gen_victima USING btree (id_persona);


--
-- Name: sivel2_gen_victima_id_profesion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_profesion ON public.sivel2_gen_victima USING btree (id_profesion);


--
-- Name: sivel2_gen_victima_id_rangoedad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_rangoedad ON public.sivel2_gen_victima USING btree (id_rangoedad);


--
-- Name: sivel2_gen_victima_id_rangoedad_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_rangoedad_ind ON public.sivel2_gen_victima USING btree (id_rangoedad);


--
-- Name: sivel2_gen_victima_id_sectorsocial; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_sectorsocial ON public.sivel2_gen_victima USING btree (id_sectorsocial);


--
-- Name: sivel2_gen_victima_id_vinculoestado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_vinculoestado ON public.sivel2_gen_victima USING btree (id_vinculoestado);


--
-- Name: sivel2_gen_victima_orientacionsexual; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_orientacionsexual ON public.sivel2_gen_victima USING btree (orientacionsexual);


--
-- Name: usuario_nusuario; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX usuario_nusuario ON public.usuario USING btree (nusuario);


--
-- Name: sivel2_gen_supracategoria $1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_supracategoria
    ADD CONSTRAINT "$1" FOREIGN KEY (id_tviolencia) REFERENCES public.sivel2_gen_tviolencia(id);


--
-- Name: sivel2_gen_victimacolectiva $1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT "$1" FOREIGN KEY (organizacionarmada) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_caso $1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso
    ADD CONSTRAINT "$1" FOREIGN KEY (id_intervalo) REFERENCES public.sivel2_gen_intervalo(id);


--
-- Name: sivel2_gen_caso_frontera $1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_frontera
    ADD CONSTRAINT "$1" FOREIGN KEY (id_frontera) REFERENCES public.sivel2_gen_frontera(id);


--
-- Name: sivel2_gen_victima $1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT "$1" FOREIGN KEY (id_profesion) REFERENCES public.sivel2_gen_profesion(id);


--
-- Name: sivel2_gen_caso_fuenteprensa $1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT "$1" FOREIGN KEY (fuenteprensa_id) REFERENCES public.sip_fuenteprensa(id);


--
-- Name: sivel2_gen_caso_fotra $1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fotra
    ADD CONSTRAINT "$1" FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sip_clase $1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT "$1" FOREIGN KEY (id_tclase) REFERENCES public.sip_tclase(id);


--
-- Name: sivel2_gen_caso_categoria_presponsable $2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT "$2" FOREIGN KEY (id_categoria) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sivel2_gen_caso_frontera $2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_frontera
    ADD CONSTRAINT "$2" FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_victima $2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT "$2" FOREIGN KEY (id_rangoedad) REFERENCES public.sivel2_gen_rangoedad(id);


--
-- Name: sivel2_gen_caso_usuario $2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_usuario
    ADD CONSTRAINT "$2" FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_fuenteprensa $2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT "$2" FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_fotra $2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fotra
    ADD CONSTRAINT "$2" FOREIGN KEY (id_fotra) REFERENCES public.sivel2_gen_fotra(id);


--
-- Name: sivel2_gen_victima $3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT "$3" FOREIGN KEY (id_filiacion) REFERENCES public.sivel2_gen_filiacion(id);


--
-- Name: sivel2_gen_victima $4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT "$4" FOREIGN KEY (id_sectorsocial) REFERENCES public.sivel2_gen_sectorsocial(id);


--
-- Name: sivel2_gen_victima $5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT "$5" FOREIGN KEY (id_organizacion) REFERENCES public.sivel2_gen_organizacion(id);


--
-- Name: sivel2_gen_victima $6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT "$6" FOREIGN KEY (id_vinculoestado) REFERENCES public.sivel2_gen_vinculoestado(id);


--
-- Name: sivel2_gen_victima $7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT "$7" FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_victima $8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT "$8" FOREIGN KEY (organizacionarmada) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_acto acto_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_acto acto_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sivel2_gen_acto acto_id_p_responsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_p_responsable_fkey FOREIGN KEY (id_presponsable) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_acto acto_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_persona_fkey FOREIGN KEY (id_persona) REFERENCES public.sip_persona(id);


--
-- Name: sivel2_gen_acto acto_victima_lf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_victima_lf FOREIGN KEY (id_caso, id_persona) REFERENCES public.sivel2_gen_victima(id_caso, id_persona);


--
-- Name: sivel2_gen_actocolectivo actocolectivo_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_actocolectivo actocolectivo_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sivel2_gen_actocolectivo actocolectivo_id_grupoper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_grupoper_fkey FOREIGN KEY (id_grupoper) REFERENCES public.sip_grupoper(id);


--
-- Name: sivel2_gen_actocolectivo actocolectivo_id_p_responsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_p_responsable_fkey FOREIGN KEY (id_presponsable) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_anexo_caso anexo_fuenteprensa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_caso
    ADD CONSTRAINT anexo_fuenteprensa_id_fkey FOREIGN KEY (fuenteprensa_id) REFERENCES public.sip_fuenteprensa(id);


--
-- Name: sivel2_gen_anexo_caso anexo_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_caso
    ADD CONSTRAINT anexo_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_anexo_caso anexo_id_fuente_directa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_caso
    ADD CONSTRAINT anexo_id_fuente_directa_fkey FOREIGN KEY (id_fotra) REFERENCES public.sivel2_gen_fotra(id);


--
-- Name: sivel2_gen_antecedente_caso antecedente_caso_id_antecedente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_caso
    ADD CONSTRAINT antecedente_caso_id_antecedente_fkey FOREIGN KEY (id_antecedente) REFERENCES public.sivel2_gen_antecedente(id);


--
-- Name: sivel2_gen_antecedente_caso antecedente_caso_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_caso
    ADD CONSTRAINT antecedente_caso_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_antecedente_combatiente antecedente_combatiente_id_antecedente_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_combatiente
    ADD CONSTRAINT antecedente_combatiente_id_antecedente_fkey1 FOREIGN KEY (id_antecedente) REFERENCES public.sivel2_gen_antecedente(id);


--
-- Name: sivel2_gen_antecedente_combatiente antecedente_combatiente_id_combatiente_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_combatiente
    ADD CONSTRAINT antecedente_combatiente_id_combatiente_fkey1 FOREIGN KEY (id_combatiente) REFERENCES public.sivel2_gen_combatiente(id);


--
-- Name: sivel2_gen_antecedente_victima antecedente_victima_id_antecedente_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victima
    ADD CONSTRAINT antecedente_victima_id_antecedente_fkey1 FOREIGN KEY (id_antecedente) REFERENCES public.sivel2_gen_antecedente(id);


--
-- Name: sivel2_gen_antecedente_victima antecedente_victima_id_victima_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victima
    ADD CONSTRAINT antecedente_victima_id_victima_fkey FOREIGN KEY (id_victima) REFERENCES public.sivel2_gen_victima(id);


--
-- Name: sivel2_gen_antecedente_victimacolectiva antecedente_victimacolectiva_id_antecedente_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victimacolectiva
    ADD CONSTRAINT antecedente_victimacolectiva_id_antecedente_fkey1 FOREIGN KEY (id_antecedente) REFERENCES public.sivel2_gen_antecedente(id);


--
-- Name: sivel2_gen_antecedente_victimacolectiva antecedente_victimacolectiva_victimacolectiva_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victimacolectiva
    ADD CONSTRAINT antecedente_victimacolectiva_victimacolectiva_id_fkey1 FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_gen_caso_categoria_presponsable caso_categoria_presponsable_id_caso_presponsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT caso_categoria_presponsable_id_caso_presponsable_fkey FOREIGN KEY (id_caso_presponsable) REFERENCES public.sivel2_gen_caso_presponsable(id);


--
-- Name: sivel2_gen_caso_contexto caso_contexto_id_caso_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_contexto
    ADD CONSTRAINT caso_contexto_id_caso_fkey1 FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_contexto caso_contexto_id_contexto_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_contexto
    ADD CONSTRAINT caso_contexto_id_contexto_fkey1 FOREIGN KEY (id_contexto) REFERENCES public.sivel2_gen_contexto(id);


--
-- Name: sivel2_gen_caso caso_id_intervalo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso
    ADD CONSTRAINT caso_id_intervalo_fkey FOREIGN KEY (id_intervalo) REFERENCES public.sivel2_gen_intervalo(id);


--
-- Name: sivel2_gen_caso_region caso_region_id_caso_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_region
    ADD CONSTRAINT caso_region_id_caso_fkey1 FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_region caso_region_id_region_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_region
    ADD CONSTRAINT caso_region_id_region_fkey1 FOREIGN KEY (id_region) REFERENCES public.sivel2_gen_region(id);


--
-- Name: sivel2_gen_caso_respuestafor caso_respuestafor_caso_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_respuestafor
    ADD CONSTRAINT caso_respuestafor_caso_id_fkey1 FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_respuestafor caso_respuestafor_respuestafor_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_respuestafor
    ADD CONSTRAINT caso_respuestafor_respuestafor_id_fkey1 FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: sivel2_gen_categoria categoria_col_rep_consolidado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_categoria
    ADD CONSTRAINT categoria_col_rep_consolidado_fkey FOREIGN KEY (id_pconsolidado) REFERENCES public.sivel2_gen_pconsolidado(id);


--
-- Name: sivel2_gen_categoria categoria_contada_en_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_categoria
    ADD CONSTRAINT categoria_contada_en_fkey FOREIGN KEY (contadaen) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sivel2_gen_categoria categoria_contadaen_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_categoria
    ADD CONSTRAINT categoria_contadaen_fkey FOREIGN KEY (contadaen) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sivel2_gen_contextovictima_victima contextovictima_victima_contextovictima_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contextovictima_victima
    ADD CONSTRAINT contextovictima_victima_contextovictima_id_fkey1 FOREIGN KEY (contextovictima_id) REFERENCES public.sivel2_gen_contextovictima(id);


--
-- Name: sivel2_gen_contextovictima_victima contextovictima_victima_victima_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contextovictima_victima
    ADD CONSTRAINT contextovictima_victima_victima_id_fkey1 FOREIGN KEY (victima_id) REFERENCES public.sivel2_gen_victima(id);


--
-- Name: sip_departamento departamento_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_departamento
    ADD CONSTRAINT departamento_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.sip_pais(id);


--
-- Name: sivel2_gen_caso_etiqueta etiquetacaso_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_etiqueta
    ADD CONSTRAINT etiquetacaso_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_etiqueta etiquetacaso_id_etiqueta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_etiqueta
    ADD CONSTRAINT etiquetacaso_id_etiqueta_fkey FOREIGN KEY (id_etiqueta) REFERENCES public.sip_etiqueta(id);


--
-- Name: sivel2_gen_etnia_victimacolectiva etnia_victimacolectiva_etnia_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_etnia_victimacolectiva
    ADD CONSTRAINT etnia_victimacolectiva_etnia_id_fkey1 FOREIGN KEY (etnia_id) REFERENCES public.sivel2_gen_etnia(id);


--
-- Name: sivel2_gen_etnia_victimacolectiva etnia_victimacolectiva_victimacolectiva_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_etnia_victimacolectiva
    ADD CONSTRAINT etnia_victimacolectiva_victimacolectiva_id_fkey1 FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_gen_filiacion_victimacolectiva filiacion_victimacolectiva_id_filiacion_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_filiacion_victimacolectiva
    ADD CONSTRAINT filiacion_victimacolectiva_id_filiacion_fkey1 FOREIGN KEY (id_filiacion) REFERENCES public.sivel2_gen_filiacion(id);


--
-- Name: sivel2_gen_filiacion_victimacolectiva filiacion_victimacolectiva_victimacolectiva_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_filiacion_victimacolectiva
    ADD CONSTRAINT filiacion_victimacolectiva_victimacolectiva_id_fkey1 FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: apo214_propietario fk_rails_0425bff6ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_propietario
    ADD CONSTRAINT fk_rails_0425bff6ee FOREIGN KEY (id_persona) REFERENCES public.sip_persona(id);


--
-- Name: apo214_propietario fk_rails_0629f9fb2c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_propietario
    ADD CONSTRAINT fk_rails_0629f9fb2c FOREIGN KEY (id_lugarpreliminar) REFERENCES public.apo214_lugarpreliminar(id);


--
-- Name: sip_municipio fk_rails_089870a38d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_municipio
    ADD CONSTRAINT fk_rails_089870a38d FOREIGN KEY (id_departamento) REFERENCES public.sip_departamento(id);


--
-- Name: apo214_listadepositados fk_rails_094cd32464; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listadepositados
    ADD CONSTRAINT fk_rails_094cd32464 FOREIGN KEY (lugarpreliminar_id) REFERENCES public.apo214_lugarpreliminar(id);


--
-- Name: sivel2_gen_sectorsocialsec_victima fk_rails_0feb0e70eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocialsec_victima
    ADD CONSTRAINT fk_rails_0feb0e70eb FOREIGN KEY (sectorsocial_id) REFERENCES public.sivel2_gen_sectorsocial(id);


--
-- Name: sip_etiqueta_municipio fk_rails_10d88626c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_etiqueta_municipio
    ADD CONSTRAINT fk_rails_10d88626c3 FOREIGN KEY (etiqueta_id) REFERENCES public.sip_etiqueta(id);


--
-- Name: sivel2_gen_caso_presponsable fk_rails_118837ae4c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT fk_rails_118837ae4c FOREIGN KEY (id_presponsable) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: apo214_listaanexo fk_rails_15d910fc26; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listaanexo
    ADD CONSTRAINT fk_rails_15d910fc26 FOREIGN KEY (anexo_id) REFERENCES public.sip_anexo(id);


--
-- Name: mr519_gen_encuestausuario fk_rails_1b24d10e82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario
    ADD CONSTRAINT fk_rails_1b24d10e82 FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: heb412_gen_formulario_plantillahcr fk_rails_1bdf79898c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcr
    ADD CONSTRAINT fk_rails_1bdf79898c FOREIGN KEY (plantillahcr_id) REFERENCES public.heb412_gen_plantillahcr(id);


--
-- Name: heb412_gen_campohc fk_rails_1e5f26c999; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campohc
    ADD CONSTRAINT fk_rails_1e5f26c999 FOREIGN KEY (doc_id) REFERENCES public.heb412_gen_doc(id);


--
-- Name: apo214_listadepositados fk_rails_2449cb19a2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listadepositados
    ADD CONSTRAINT fk_rails_2449cb19a2 FOREIGN KEY (persona_id) REFERENCES public.sip_persona(id);


--
-- Name: mr519_gen_encuestausuario fk_rails_2cb09d778a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario
    ADD CONSTRAINT fk_rails_2cb09d778a FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: sip_bitacora fk_rails_2db961766c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_bitacora
    ADD CONSTRAINT fk_rails_2db961766c FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: heb412_gen_doc fk_rails_2dd6d3dac3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_doc
    ADD CONSTRAINT fk_rails_2dd6d3dac3 FOREIGN KEY (dirpapa) REFERENCES public.heb412_gen_doc(id);


--
-- Name: sip_ubicacionpre fk_rails_2e86701dfb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacionpre
    ADD CONSTRAINT fk_rails_2e86701dfb FOREIGN KEY (departamento_id) REFERENCES public.sip_departamento(id);


--
-- Name: sivel2_gen_otraorga_victima fk_rails_3029d2736a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_otraorga_victima
    ADD CONSTRAINT fk_rails_3029d2736a FOREIGN KEY (organizacion_id) REFERENCES public.sivel2_gen_organizacion(id);


--
-- Name: apo214_infoanomalialugar fk_rails_3aa92f63a0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_infoanomalialugar
    ADD CONSTRAINT fk_rails_3aa92f63a0 FOREIGN KEY (infoanomalia_id) REFERENCES public.apo214_infoanomalia(id);


--
-- Name: sip_ubicacionpre fk_rails_3b59c12090; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacionpre
    ADD CONSTRAINT fk_rails_3b59c12090 FOREIGN KEY (clase_id) REFERENCES public.sip_clase(id);


--
-- Name: apo214_listaevariesgo fk_rails_3ee6e4c376; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listaevariesgo
    ADD CONSTRAINT fk_rails_3ee6e4c376 FOREIGN KEY (evaluacionriesgo_id) REFERENCES public.apo214_evaluacionriesgo(id);


--
-- Name: apo214_lugarpreliminar fk_rails_42ec3f4e71; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_lugarpreliminar
    ADD CONSTRAINT fk_rails_42ec3f4e71 FOREIGN KEY (elementopaisaje_id) REFERENCES public.apo214_elementopaisaje(id);


--
-- Name: apo214_listapersofuentes fk_rails_44b1ed6894; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listapersofuentes
    ADD CONSTRAINT fk_rails_44b1ed6894 FOREIGN KEY (lugarpreliminar_id) REFERENCES public.apo214_lugarpreliminar(id);


--
-- Name: sip_orgsocial_persona fk_rails_4672f6cbcd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial_persona
    ADD CONSTRAINT fk_rails_4672f6cbcd FOREIGN KEY (persona_id) REFERENCES public.sip_persona(id);


--
-- Name: sip_ubicacion fk_rails_4dd7a7f238; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT fk_rails_4dd7a7f238 FOREIGN KEY (id_departamento) REFERENCES public.sip_departamento(id);


--
-- Name: mr519_gen_encuestapersona fk_rails_54b3e0ed5c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT fk_rails_54b3e0ed5c FOREIGN KEY (persona_id) REFERENCES public.sip_persona(id);


--
-- Name: sip_etiqueta_municipio fk_rails_5672729520; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_etiqueta_municipio
    ADD CONSTRAINT fk_rails_5672729520 FOREIGN KEY (municipio_id) REFERENCES public.sip_municipio(id);


--
-- Name: sivel2_gen_caso_presponsable fk_rails_5a8abbdd31; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT fk_rails_5a8abbdd31 FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sip_orgsocial fk_rails_5b21e3a2af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial
    ADD CONSTRAINT fk_rails_5b21e3a2af FOREIGN KEY (grupoper_id) REFERENCES public.sip_grupoper(id);


--
-- Name: apo214_lugarpreliminar fk_rails_5dc41e5b2c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_lugarpreliminar
    ADD CONSTRAINT fk_rails_5dc41e5b2c FOREIGN KEY (id_persona) REFERENCES public.sip_persona(id);


--
-- Name: sivel2_gen_combatiente fk_rails_6485d06d37; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_6485d06d37 FOREIGN KEY (id_vinculoestado) REFERENCES public.sivel2_gen_vinculoestado(id);


--
-- Name: mr519_gen_opcioncs fk_rails_656b4a3ca7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_opcioncs
    ADD CONSTRAINT fk_rails_656b4a3ca7 FOREIGN KEY (campo_id) REFERENCES public.mr519_gen_campo(id);


--
-- Name: heb412_gen_formulario_plantillahcr fk_rails_696d27d6f5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcr
    ADD CONSTRAINT fk_rails_696d27d6f5 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: heb412_gen_formulario_plantillahcm fk_rails_6e214a7168; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcm
    ADD CONSTRAINT fk_rails_6e214a7168 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: sip_ubicacion fk_rails_6ed05ed576; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT fk_rails_6ed05ed576 FOREIGN KEY (id_pais) REFERENCES public.sip_pais(id);


--
-- Name: sip_grupo_usuario fk_rails_734ee21e62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupo_usuario
    ADD CONSTRAINT fk_rails_734ee21e62 FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: apo214_infoanomalia fk_rails_78511df01b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_infoanomalia
    ADD CONSTRAINT fk_rails_78511df01b FOREIGN KEY (anexo_id) REFERENCES public.sip_anexo(id);


--
-- Name: apo214_listainfofoto fk_rails_7a80310d89; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listainfofoto
    ADD CONSTRAINT fk_rails_7a80310d89 FOREIGN KEY (anexo_id) REFERENCES public.sip_anexo(id);


--
-- Name: sip_orgsocial fk_rails_7bc2a60574; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial
    ADD CONSTRAINT fk_rails_7bc2a60574 FOREIGN KEY (pais_id) REFERENCES public.sip_pais(id);


--
-- Name: sip_orgsocial_persona fk_rails_7c335482f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial_persona
    ADD CONSTRAINT fk_rails_7c335482f6 FOREIGN KEY (orgsocial_id) REFERENCES public.sip_orgsocial(id);


--
-- Name: mr519_gen_respuestafor fk_rails_805efe6935; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_respuestafor
    ADD CONSTRAINT fk_rails_805efe6935 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: apo214_evaluacionriesgo fk_rails_81404f916d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_evaluacionriesgo
    ADD CONSTRAINT fk_rails_81404f916d FOREIGN KEY (riesgo_id) REFERENCES public.apo214_riesgo(id);


--
-- Name: mr519_gen_valorcampo fk_rails_819cf17399; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo
    ADD CONSTRAINT fk_rails_819cf17399 FOREIGN KEY (campo_id) REFERENCES public.mr519_gen_campo(id);


--
-- Name: apo214_listasuelo fk_rails_824ea49a05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listasuelo
    ADD CONSTRAINT fk_rails_824ea49a05 FOREIGN KEY (lugarpreliminar_id) REFERENCES public.apo214_lugarpreliminar(id);


--
-- Name: mr519_gen_encuestapersona fk_rails_83755e20b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT fk_rails_83755e20b9 FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: sivel2_gen_caso fk_rails_850036942a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso
    ADD CONSTRAINT fk_rails_850036942a FOREIGN KEY (ubicacion_id) REFERENCES public.sip_ubicacion(id);


--
-- Name: apo214_asisreconocimiento fk_rails_883533cb81; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_asisreconocimiento
    ADD CONSTRAINT fk_rails_883533cb81 FOREIGN KEY (lugarpreliminar_id) REFERENCES public.apo214_lugarpreliminar(id);


--
-- Name: mr519_gen_encuestapersona fk_rails_88eeb03074; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT fk_rails_88eeb03074 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: apo214_infoanomalialugar fk_rails_8bb02cf8f4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_infoanomalialugar
    ADD CONSTRAINT fk_rails_8bb02cf8f4 FOREIGN KEY (lugarpreliminar_id) REFERENCES public.apo214_lugarpreliminar(id);


--
-- Name: apo214_listaanexo fk_rails_8bb22a4c10; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listaanexo
    ADD CONSTRAINT fk_rails_8bb22a4c10 FOREIGN KEY (lugarpreliminar_id) REFERENCES public.apo214_lugarpreliminar(id);


--
-- Name: mr519_gen_valorcampo fk_rails_8bb7650018; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo
    ADD CONSTRAINT fk_rails_8bb7650018 FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: sip_grupo_usuario fk_rails_8d24f7c1c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupo_usuario
    ADD CONSTRAINT fk_rails_8d24f7c1c0 FOREIGN KEY (sip_grupo_id) REFERENCES public.sip_grupo(id);


--
-- Name: sip_departamento fk_rails_92093de1a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_departamento
    ADD CONSTRAINT fk_rails_92093de1a1 FOREIGN KEY (id_pais) REFERENCES public.sip_pais(id);


--
-- Name: apo214_lugarpreliminar fk_rails_9408f90341; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_lugarpreliminar
    ADD CONSTRAINT fk_rails_9408f90341 FOREIGN KEY (archivokml_id) REFERENCES public.sip_anexo(id);


--
-- Name: sivel2_gen_combatiente fk_rails_95f4a0b8f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_95f4a0b8f6 FOREIGN KEY (id_profesion) REFERENCES public.sivel2_gen_profesion(id);


--
-- Name: sip_orgsocial_sectororgsocial fk_rails_9f61a364e0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial_sectororgsocial
    ADD CONSTRAINT fk_rails_9f61a364e0 FOREIGN KEY (sectororgsocial_id) REFERENCES public.sip_sectororgsocial(id);


--
-- Name: mr519_gen_campo fk_rails_a186e1a8a0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_campo
    ADD CONSTRAINT fk_rails_a186e1a8a0 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: sip_ubicacion fk_rails_a1d509c79a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT fk_rails_a1d509c79a FOREIGN KEY (id_clase) REFERENCES public.sip_clase(id);


--
-- Name: apo214_listasuelo fk_rails_a510cd86fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listasuelo
    ADD CONSTRAINT fk_rails_a510cd86fa FOREIGN KEY (suelo_id) REFERENCES public.apo214_suelo(id);


--
-- Name: apo214_listapersofuentes fk_rails_abe0965e8d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listapersofuentes
    ADD CONSTRAINT fk_rails_abe0965e8d FOREIGN KEY (persona_id) REFERENCES public.sip_persona(id);


--
-- Name: sivel2_gen_combatiente fk_rails_af43e915a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_af43e915a6 FOREIGN KEY (id_filiacion) REFERENCES public.sivel2_gen_filiacion(id);


--
-- Name: apo214_lugarpreliminar fk_rails_b80776fd3b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_lugarpreliminar
    ADD CONSTRAINT fk_rails_b80776fd3b FOREIGN KEY (ubicacionpre_id) REFERENCES public.sip_ubicacionpre(id);


--
-- Name: sip_ubicacion fk_rails_b82283d945; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT fk_rails_b82283d945 FOREIGN KEY (id_municipio) REFERENCES public.sip_municipio(id);


--
-- Name: apo214_asisreconocimiento fk_rails_b9116c62bf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_asisreconocimiento
    ADD CONSTRAINT fk_rails_b9116c62bf FOREIGN KEY (persona_id) REFERENCES public.sip_persona(id);


--
-- Name: sivel2_gen_combatiente fk_rails_bfb49597e1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_bfb49597e1 FOREIGN KEY (organizacionarmada) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sip_ubicacionpre fk_rails_c08a606417; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacionpre
    ADD CONSTRAINT fk_rails_c08a606417 FOREIGN KEY (municipio_id) REFERENCES public.sip_municipio(id);


--
-- Name: sip_ubicacionpre fk_rails_c8024a90df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacionpre
    ADD CONSTRAINT fk_rails_c8024a90df FOREIGN KEY (tsitio_id) REFERENCES public.sip_tsitio(id);


--
-- Name: usuario fk_rails_cc636858ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fk_rails_cc636858ad FOREIGN KEY (tema_id) REFERENCES public.sip_tema(id);


--
-- Name: apo214_lugarpreliminar fk_rails_cd4febda02; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_lugarpreliminar
    ADD CONSTRAINT fk_rails_cd4febda02 FOREIGN KEY (cobertura_id) REFERENCES public.apo214_cobertura(id);


--
-- Name: apo214_lugarpreliminar fk_rails_d2074c8fa3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_lugarpreliminar
    ADD CONSTRAINT fk_rails_d2074c8fa3 FOREIGN KEY (otrolubicacionpre_id) REFERENCES public.sip_ubicacionpre(id);


--
-- Name: sivel2_gen_otraorga_victima fk_rails_e023799a03; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_otraorga_victima
    ADD CONSTRAINT fk_rails_e023799a03 FOREIGN KEY (victima_id) REFERENCES public.sivel2_gen_victima(id);


--
-- Name: sivel2_gen_sectorsocialsec_victima fk_rails_e04ef7c3e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocialsec_victima
    ADD CONSTRAINT fk_rails_e04ef7c3e5 FOREIGN KEY (victima_id) REFERENCES public.sivel2_gen_victima(id);


--
-- Name: apo214_listaevariesgo fk_rails_e07ebee0d2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listaevariesgo
    ADD CONSTRAINT fk_rails_e07ebee0d2 FOREIGN KEY (lugarpreliminar_id) REFERENCES public.apo214_lugarpreliminar(id);


--
-- Name: heb412_gen_campoplantillahcm fk_rails_e0e38e0782; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campoplantillahcm
    ADD CONSTRAINT fk_rails_e0e38e0782 FOREIGN KEY (plantillahcm_id) REFERENCES public.heb412_gen_plantillahcm(id);


--
-- Name: sivel2_gen_combatiente fk_rails_e2d01a5a99; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_e2d01a5a99 FOREIGN KEY (id_sectorsocial) REFERENCES public.sivel2_gen_sectorsocial(id);


--
-- Name: heb412_gen_carpetaexclusiva fk_rails_ea1add81e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_carpetaexclusiva
    ADD CONSTRAINT fk_rails_ea1add81e6 FOREIGN KEY (grupo_id) REFERENCES public.sip_grupo(id);


--
-- Name: sip_ubicacionpre fk_rails_eba8cc9124; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacionpre
    ADD CONSTRAINT fk_rails_eba8cc9124 FOREIGN KEY (pais_id) REFERENCES public.sip_pais(id);


--
-- Name: apo214_lugarpreliminar fk_rails_ee76bec01f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_lugarpreliminar
    ADD CONSTRAINT fk_rails_ee76bec01f FOREIGN KEY (disposicioncadaveres_id) REFERENCES public.apo214_disposicioncadaveres(id);


--
-- Name: apo214_listainfofoto fk_rails_efa5c4526f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_listainfofoto
    ADD CONSTRAINT fk_rails_efa5c4526f FOREIGN KEY (lugarpreliminar_id) REFERENCES public.apo214_lugarpreliminar(id);


--
-- Name: sip_orgsocial_sectororgsocial fk_rails_f032bb21a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial_sectororgsocial
    ADD CONSTRAINT fk_rails_f032bb21a6 FOREIGN KEY (orgsocial_id) REFERENCES public.sip_orgsocial(id);


--
-- Name: sivel2_gen_combatiente fk_rails_f0cf2a7bec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_f0cf2a7bec FOREIGN KEY (id_resagresion) REFERENCES public.sivel2_gen_resagresion(id);


--
-- Name: apo214_lugarpreliminar fk_rails_f52877c43f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_lugarpreliminar
    ADD CONSTRAINT fk_rails_f52877c43f FOREIGN KEY (tipoentierro_id) REFERENCES public.apo214_tipoentierro(id);


--
-- Name: sivel2_gen_combatiente fk_rails_f77dda7a40; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_f77dda7a40 FOREIGN KEY (id_organizacion) REFERENCES public.sivel2_gen_organizacion(id);


--
-- Name: sivel2_gen_combatiente fk_rails_fb02819ec4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_fb02819ec4 FOREIGN KEY (id_rangoedad) REFERENCES public.sivel2_gen_rangoedad(id);


--
-- Name: sip_clase fk_rails_fb09f016e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT fk_rails_fb09f016e4 FOREIGN KEY (id_municipio) REFERENCES public.sip_municipio(id);


--
-- Name: heb412_gen_formulario_plantillahcm fk_rails_fc3149fc44; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcm
    ADD CONSTRAINT fk_rails_fc3149fc44 FOREIGN KEY (plantillahcm_id) REFERENCES public.heb412_gen_plantillahcm(id);


--
-- Name: apo214_lugarpreliminar fk_rails_fd33b98714; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apo214_lugarpreliminar
    ADD CONSTRAINT fk_rails_fd33b98714 FOREIGN KEY (tipotestigo_id) REFERENCES public.apo214_tipotestigo(id);


--
-- Name: sivel2_gen_organizacion_victimacolectiva organizacion_victimacolectiva_id_organizacion_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_organizacion_victimacolectiva
    ADD CONSTRAINT organizacion_victimacolectiva_id_organizacion_fkey1 FOREIGN KEY (id_organizacion) REFERENCES public.sivel2_gen_organizacion(id);


--
-- Name: sivel2_gen_organizacion_victimacolectiva organizacion_victimacolectiva_victimacolectiva_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_organizacion_victimacolectiva
    ADD CONSTRAINT organizacion_victimacolectiva_victimacolectiva_id_fkey1 FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sip_persona persona_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT persona_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.sip_pais(id);


--
-- Name: sip_persona persona_nacionalde_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT persona_nacionalde_fkey FOREIGN KEY (nacionalde) REFERENCES public.sip_pais(id);


--
-- Name: sip_persona persona_tdocumento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT persona_tdocumento_id_fkey FOREIGN KEY (tdocumento_id) REFERENCES public.sip_tdocumento(id);


--
-- Name: sivel2_gen_presponsable presponsable_papa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_presponsable
    ADD CONSTRAINT presponsable_papa_fkey FOREIGN KEY (papa_id) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_caso_presponsable presuntos_responsables_caso_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT presuntos_responsables_caso_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_presponsable presuntos_responsables_caso_id_p_responsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT presuntos_responsables_caso_id_p_responsable_fkey FOREIGN KEY (id_presponsable) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_presponsable presuntos_responsables_id_papa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_presponsable
    ADD CONSTRAINT presuntos_responsables_id_papa_fkey FOREIGN KEY (papa_id) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_profesion_victimacolectiva profesion_victimacolectiva_id_profesion_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion_victimacolectiva
    ADD CONSTRAINT profesion_victimacolectiva_id_profesion_fkey1 FOREIGN KEY (id_profesion) REFERENCES public.sivel2_gen_profesion(id);


--
-- Name: sivel2_gen_profesion_victimacolectiva profesion_victimacolectiva_victimacolectiva_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion_victimacolectiva
    ADD CONSTRAINT profesion_victimacolectiva_victimacolectiva_id_fkey1 FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_gen_rangoedad_victimacolectiva rangoedad_victimacolectiva_id_rangoedad_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_rangoedad_victimacolectiva
    ADD CONSTRAINT rangoedad_victimacolectiva_id_rangoedad_fkey1 FOREIGN KEY (id_rangoedad) REFERENCES public.sivel2_gen_rangoedad(id);


--
-- Name: sivel2_gen_rangoedad_victimacolectiva rangoedad_victimacolectiva_victimacolectiva_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_rangoedad_victimacolectiva
    ADD CONSTRAINT rangoedad_victimacolectiva_victimacolectiva_id_fkey1 FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sip_persona_trelacion relacion_personas_id_persona1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT relacion_personas_id_persona1_fkey FOREIGN KEY (persona1) REFERENCES public.sip_persona(id);


--
-- Name: sip_persona_trelacion relacion_personas_id_persona2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT relacion_personas_id_persona2_fkey FOREIGN KEY (persona2) REFERENCES public.sip_persona(id);


--
-- Name: sip_persona_trelacion relacion_personas_id_tipo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT relacion_personas_id_tipo_fkey FOREIGN KEY (id_trelacion) REFERENCES public.sip_trelacion(id);


--
-- Name: sivel2_gen_sectorsocial_victimacolectiva sectorsocial_victimacolectiva_id_sectorsocial_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocial_victimacolectiva
    ADD CONSTRAINT sectorsocial_victimacolectiva_id_sectorsocial_fkey1 FOREIGN KEY (id_sectorsocial) REFERENCES public.sivel2_gen_sectorsocial(id);


--
-- Name: sivel2_gen_sectorsocial_victimacolectiva sectorsocial_victimacolectiva_victimacolectiva_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocial_victimacolectiva
    ADD CONSTRAINT sectorsocial_victimacolectiva_victimacolectiva_id_fkey1 FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sip_clase sip_clase_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT sip_clase_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.sip_municipio(id);


--
-- Name: sip_municipio sip_municipio_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_municipio
    ADD CONSTRAINT sip_municipio_id_departamento_fkey FOREIGN KEY (id_departamento) REFERENCES public.sip_departamento(id);


--
-- Name: sip_persona sip_persona_id_clase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT sip_persona_id_clase_fkey FOREIGN KEY (id_clase) REFERENCES public.sip_clase(id);


--
-- Name: sip_persona sip_persona_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT sip_persona_id_departamento_fkey FOREIGN KEY (id_departamento) REFERENCES public.sip_departamento(id);


--
-- Name: sip_persona sip_persona_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT sip_persona_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.sip_municipio(id);


--
-- Name: sip_ubicacion sip_ubicacion_id_clase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT sip_ubicacion_id_clase_fkey FOREIGN KEY (id_clase) REFERENCES public.sip_clase(id);


--
-- Name: sip_ubicacion sip_ubicacion_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT sip_ubicacion_id_departamento_fkey FOREIGN KEY (id_departamento) REFERENCES public.sip_departamento(id);


--
-- Name: sip_ubicacion sip_ubicacion_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT sip_ubicacion_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.sip_municipio(id);


--
-- Name: sivel2_gen_caso_fotra sivel2_gen_caso_fotra_anexo_caso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fotra
    ADD CONSTRAINT sivel2_gen_caso_fotra_anexo_caso_id_fkey FOREIGN KEY (anexo_caso_id) REFERENCES public.sivel2_gen_anexo_caso(id);


--
-- Name: sivel2_gen_caso_fuenteprensa sivel2_gen_caso_fuenteprensa_anexo_caso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT sivel2_gen_caso_fuenteprensa_anexo_caso_id_fkey FOREIGN KEY (anexo_caso_id) REFERENCES public.sivel2_gen_anexo_caso(id);


--
-- Name: sivel2_gen_caso_fuenteprensa sivel2_gen_caso_fuenteprensa_fuenteprensa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT sivel2_gen_caso_fuenteprensa_fuenteprensa_id_fkey FOREIGN KEY (fuenteprensa_id) REFERENCES public.sip_fuenteprensa(id);


--
-- Name: sivel2_gen_caso_fuenteprensa sivel2_gen_caso_fuenteprensa_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT sivel2_gen_caso_fuenteprensa_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_categoria sivel2_gen_categoria_supracategoria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_categoria
    ADD CONSTRAINT sivel2_gen_categoria_supracategoria_id_fkey FOREIGN KEY (supracategoria_id) REFERENCES public.sivel2_gen_supracategoria(id);


--
-- Name: sivel2_gen_observador_filtrodepartamento sivel2_gen_observador_filtrodepartamento_d_idx; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_observador_filtrodepartamento
    ADD CONSTRAINT sivel2_gen_observador_filtrodepartamento_d_idx FOREIGN KEY (departamento_id) REFERENCES public.sip_departamento(id);


--
-- Name: sivel2_gen_observador_filtrodepartamento sivel2_gen_observador_filtrodepartamento_u_idx; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_observador_filtrodepartamento
    ADD CONSTRAINT sivel2_gen_observador_filtrodepartamento_u_idx FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: sivel2_gen_supracategoria supracategoria_id_tipo_violencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_supracategoria
    ADD CONSTRAINT supracategoria_id_tipo_violencia_fkey FOREIGN KEY (id_tviolencia) REFERENCES public.sivel2_gen_tviolencia(id);


--
-- Name: sip_ubicacion ubicacion2_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT ubicacion2_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sip_ubicacion ubicacion2_id_tipo_sitio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT ubicacion2_id_tipo_sitio_fkey FOREIGN KEY (id_tsitio) REFERENCES public.sip_tsitio(id);


--
-- Name: sip_ubicacion ubicacion_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT ubicacion_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.sip_pais(id);


--
-- Name: sivel2_gen_victimacolectiva victima_colectiva_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT victima_colectiva_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_victimacolectiva victima_colectiva_id_grupoper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT victima_colectiva_id_grupoper_fkey FOREIGN KEY (id_grupoper) REFERENCES public.sip_grupoper(id);


--
-- Name: sivel2_gen_victimacolectiva victima_colectiva_id_organizacion_armada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT victima_colectiva_id_organizacion_armada_fkey FOREIGN KEY (organizacionarmada) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_victima victima_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_victima victima_id_etnia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_etnia_fkey FOREIGN KEY (id_etnia) REFERENCES public.sivel2_gen_etnia(id);


--
-- Name: sivel2_gen_victima victima_id_filiacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_filiacion_fkey FOREIGN KEY (id_filiacion) REFERENCES public.sivel2_gen_filiacion(id);


--
-- Name: sivel2_gen_victima victima_id_iglesia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_iglesia_fkey FOREIGN KEY (id_iglesia) REFERENCES public.sivel2_gen_iglesia(id);


--
-- Name: sivel2_gen_victima victima_id_organizacion_armada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_organizacion_armada_fkey FOREIGN KEY (organizacionarmada) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_victima victima_id_organizacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_organizacion_fkey FOREIGN KEY (id_organizacion) REFERENCES public.sivel2_gen_organizacion(id);


--
-- Name: sivel2_gen_victima victima_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_persona_fkey FOREIGN KEY (id_persona) REFERENCES public.sip_persona(id);


--
-- Name: sivel2_gen_victima victima_id_profesion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_profesion_fkey FOREIGN KEY (id_profesion) REFERENCES public.sivel2_gen_profesion(id);


--
-- Name: sivel2_gen_victima victima_id_rango_edad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_rango_edad_fkey FOREIGN KEY (id_rangoedad) REFERENCES public.sivel2_gen_rangoedad(id);


--
-- Name: sivel2_gen_victima victima_id_sector_social_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_sector_social_fkey FOREIGN KEY (id_sectorsocial) REFERENCES public.sivel2_gen_sectorsocial(id);


--
-- Name: sivel2_gen_victima victima_id_vinculo_estado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_vinculo_estado_fkey FOREIGN KEY (id_vinculoestado) REFERENCES public.sivel2_gen_vinculoestado(id);


--
-- Name: sivel2_gen_victimacolectiva_vinculoestado victimacolectiva_vinculoestado_id_vinculoestado_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva_vinculoestado
    ADD CONSTRAINT victimacolectiva_vinculoestado_id_vinculoestado_fkey1 FOREIGN KEY (id_vinculoestado) REFERENCES public.sivel2_gen_vinculoestado(id);


--
-- Name: sivel2_gen_victimacolectiva_vinculoestado victimacolectiva_vinculoestado_victimacolectiva_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva_vinculoestado
    ADD CONSTRAINT victimacolectiva_vinculoestado_victimacolectiva_id_fkey1 FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20131128151014'),
('20131204135932'),
('20131204140000'),
('20131204143718'),
('20131204183530'),
('20131206081531'),
('20131210221541'),
('20131220103409'),
('20131223175141'),
('20140117212555'),
('20140129151136'),
('20140207102709'),
('20140207102739'),
('20140211162355'),
('20140211164659'),
('20140211172443'),
('20140313012209'),
('20140514142421'),
('20140518120059'),
('20140527110223'),
('20140528043115'),
('20140804202100'),
('20140804202101'),
('20140804202958'),
('20140815111351'),
('20140827142659'),
('20140901105741'),
('20140901106000'),
('20140909165233'),
('20140918115412'),
('20140922102737'),
('20140922110956'),
('20141002140242'),
('20141111102451'),
('20141111203313'),
('20150313153722'),
('20150317084737'),
('20150413000000'),
('20150413160156'),
('20150413160157'),
('20150413160158'),
('20150413160159'),
('20150416074423'),
('20150416090140'),
('20150503120915'),
('20150505084914'),
('20150510125926'),
('20150521181918'),
('20150528100944'),
('20150602094513'),
('20150602095241'),
('20150602104342'),
('20150609094809'),
('20150609094820'),
('20150616095023'),
('20150616100351'),
('20150616100551'),
('20150707164448'),
('20150710114451'),
('20150716171420'),
('20150716192356'),
('20150717101243'),
('20150724003736'),
('20150803082520'),
('20150809032138'),
('20150826000000'),
('20151020203421'),
('20151124110943'),
('20151127102425'),
('20151130101417'),
('20160316093659'),
('20160316094627'),
('20160316100620'),
('20160316100621'),
('20160316100622'),
('20160316100623'),
('20160316100624'),
('20160316100625'),
('20160316100626'),
('20160519195544'),
('20160719195853'),
('20160719214520'),
('20160724160049'),
('20160724164110'),
('20160725123242'),
('20160725131347'),
('20161009111443'),
('20161010152631'),
('20161026110802'),
('20161027233011'),
('20161103080156'),
('20161103081041'),
('20161103083352'),
('20161108102349'),
('20170405104322'),
('20170406213334'),
('20170413185012'),
('20170414035328'),
('20170503145808'),
('20170526084502'),
('20170526100040'),
('20170526124219'),
('20170526131129'),
('20170529020218'),
('20170529154413'),
('20170609131212'),
('20170928100402'),
('20171019133203'),
('20180126035129'),
('20180126055129'),
('20180225152848'),
('20180320230847'),
('20180427194732'),
('20180509111948'),
('20180717134314'),
('20180717135811'),
('20180718094829'),
('20180719015902'),
('20180720140443'),
('20180720171842'),
('20180724135332'),
('20180724202353'),
('20180726213123'),
('20180726234755'),
('20180801105304'),
('20180810221619'),
('20180905031342'),
('20180905031617'),
('20180910132139'),
('20180912114413'),
('20180914153010'),
('20180917072914'),
('20180920031351'),
('20180921120954'),
('20181011104537'),
('20181012110629'),
('20181017094456'),
('20181018003945'),
('20181130112320'),
('20181213103204'),
('20181218165548'),
('20181218165559'),
('20181218215222'),
('20181219085236'),
('20181227093834'),
('20181227094559'),
('20181227095037'),
('20181227100523'),
('20181227114431'),
('20181227210510'),
('20190109125417'),
('20190110191802'),
('20190128032125'),
('20190208103518'),
('20190308195346'),
('20190322102311'),
('20190326150948'),
('20190331111015'),
('20190401175521'),
('20190406141156'),
('20190406164301'),
('20190418011743'),
('20190418014012'),
('20190418123920'),
('20190426125052'),
('20190430112229'),
('20190605143420'),
('20190612111043'),
('20190618135559'),
('20190625112649'),
('20190625140232'),
('20190703044126'),
('20190715083916'),
('20190715182611'),
('20190726203302'),
('20190804223012'),
('20190818013251'),
('20190924013712'),
('20190924112646'),
('20190926104116'),
('20190926104551'),
('20190926133640'),
('20190926143845'),
('20191012042159'),
('20191016100031'),
('20191021021621'),
('20191205200007'),
('20191205202150'),
('20191205204511'),
('20191219011910'),
('20191231102721'),
('20200106174710'),
('20200221181049'),
('20200224134339'),
('20200228235200'),
('20200319183515'),
('20200320152017'),
('20200324164130'),
('20200422103916'),
('20200423092828'),
('20200427091939'),
('20200428155536'),
('20200430101709'),
('20200622193241'),
('20200720005020'),
('20200720013144'),
('20200722210144'),
('20200723133542'),
('20200727021707'),
('20200907165157'),
('20200907174303'),
('20200916022934'),
('20200919003430'),
('20200921123831'),
('20201009004421'),
('20201021214107'),
('20201029153649'),
('20201029162732'),
('20201029220052'),
('20201102232506'),
('20201103175114'),
('20201105154106'),
('20201106155800'),
('20201108201914'),
('20201108203930'),
('20201110170225'),
('20201110170728'),
('20201119125643'),
('20201127233621'),
('20201128003003'),
('20201129144340'),
('20201129145302'),
('20201129152636'),
('20201129153038'),
('20201129153603'),
('20201129161641'),
('20201129175515'),
('20201129191238'),
('20201130020715'),
('20201201015501'),
('20201201023145'),
('20201203052009'),
('20201209230317'),
('20201209232557'),
('20201214215209'),
('20201215152027'),
('20201215161607'),
('20201215163716'),
('20201215164448'),
('20201215181622'),
('20201215182935'),
('20201215183649'),
('20201215184808'),
('20201215190623'),
('20201215191833'),
('20201215192951'),
('20201216022648'),
('20201216023915'),
('20201216025811'),
('20201219210527'),
('20201220130138'),
('20201221182135'),
('20201231194433'),
('20210130043950'),
('20210130052513'),
('20210130180841'),
('20210130202050'),
('20210131194508'),
('20210201201138'),
('20210201223910'),
('20210201225252'),
('20210201225836'),
('20210204025126'),
('20210204045410'),
('20210206191033'),
('20210218170554'),
('20210226155035'),
('20210316082124'),
('20210324141126'),
('20210401194637'),
('20210401210102'),
('20210406225904'),
('20210414201956'),
('20210428143811'),
('20210430160739'),
('20210511011442'),
('20210531223906'),
('20210601023450'),
('20210601023557'),
('20210614120835'),
('20210616003251'),
('20210619191706'),
('20210727111355'),
('20210728214424'),
('20210730120340'),
('20210823162357'),
('20210924022913'),
('20211011214752'),
('20211011233005'),
('20211019121200'),
('20211020221141'),
('20211024105450'),
('20211024105507'),
('20211117200456'),
('20211119085218'),
('20211119110211'),
('20211216125250'),
('20220122105047'),
('20220213031520'),
('20220214121713'),
('20220225222853'),
('20220316025851'),
('20220323001338'),
('20220323001645'),
('20220323004929'),
('20220413123127'),
('20220417203841'),
('20220417220914'),
('20220417221010'),
('20220420143020'),
('20220420154535'),
('20220422190546');


