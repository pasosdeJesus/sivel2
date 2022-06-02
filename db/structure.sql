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
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


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
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
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
    CONSTRAINT victima_orientacionsexual_check CHECK (((orientacionsexual = 'B'::bpchar) OR (orientacionsexual = 'G'::bpchar) OR (orientacionsexual = 'H'::bpchar) OR (orientacionsexual = 'I'::bpchar) OR (orientacionsexual = 'L'::bpchar) OR (orientacionsexual = 'O'::bpchar) OR (orientacionsexual = 'S'::bpchar) OR (orientacionsexual = 'T'::bpchar)))
);


--
-- Name: cben1; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cben1 AS
 SELECT caso.id AS id_caso,
    subv.id_victima,
    subv.id_persona,
    1 AS npersona,
    victima.id_filiacion
   FROM public.sivel2_gen_caso caso,
    public.sivel2_gen_victima victima,
    ( SELECT sivel2_gen_victima.id_persona,
            max(sivel2_gen_victima.id) AS id_victima
           FROM public.sivel2_gen_victima
          GROUP BY sivel2_gen_victima.id_persona) subv,
    public.sip_persona persona
  WHERE ((subv.id_victima = victima.id) AND (caso.id = victima.id_caso) AND ((persona.anionac IS NULL) OR (persona.anionac = ANY (ARRAY[1883, 1895, 1906, 1907, 1910, 1911, 1912, 1914, 1915, 1916, 1917, 1918, 1919, 1920, 1921, 1922, 1923, 1924, 1925, 1926, 1927, 1928, 1929, 1930, 1931, 1932, 1933, 1934, 1935, 1936, 1937, 1938, 1939, 1940, 1941, 1942, 1943, 1944, 1945, 1946, 1947, 1948, 1949, 1950, 1951, 1952, 1953, 1954, 1955, 1956, 1957, 1958, 1959, 1960, 1961, 1962, 1963, 1964, 1965, 1966, 1967, 1968, 1969, 1970, 1971, 1972, 1973, 1974, 1975, 1976, 1977, 1978, 1979, 1980, 1981, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020]))) AND (victima.id_etnia = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112])) AND (victima.id_filiacion = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 101, 102, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114])) AND ((((date_part('year'::text, caso.fecha))::text || '-'::text) || lpad((date_part('month'::text, caso.fecha))::text, 2, '0'::text)) = ANY (ARRAY['1900-01'::text, '1908-11'::text, '1909-12'::text, '1968-10'::text, '1968-12'::text, '1976-12'::text, '1977-06'::text, '1977-07'::text, '1977-12'::text, '1978-11'::text, '1979-06'::text, '1980-06'::text, '1980-07'::text, '1980-11'::text, '1981-02'::text, '1981-06'::text, '1981-09'::text, '1982-04'::text, '1982-05'::text, '1982-06'::text, '1983-02'::text, '1983-06'::text, '1983-07'::text, '1983-08'::text, '1984-01'::text, '1984-06'::text, '1984-07'::text, '1984-08'::text, '1984-09'::text, '1984-10'::text, '1984-11'::text, '1985-01'::text, '1985-02'::text, '1985-03'::text, '1985-04'::text, '1985-06'::text, '1985-07'::text, '1985-08'::text, '1985-09'::text, '1985-10'::text, '1985-11'::text, '1985-12'::text, '1986-03'::text, '1986-04'::text, '1986-06'::text, '1986-08'::text, '1986-09'::text, '1986-10'::text, '1986-11'::text, '1986-12'::text, '1987-01'::text, '1987-02'::text, '1987-03'::text, '1987-06'::text, '1987-07'::text, '1987-08'::text, '1987-09'::text, '1987-11'::text, '1987-12'::text, '1988-01'::text, '1988-02'::text, '1988-03'::text, '1988-04'::text, '1988-05'::text, '1988-06'::text, '1988-07'::text, '1988-08'::text, '1988-09'::text, '1988-10'::text, '1988-11'::text, '1988-12'::text, '1989-01'::text, '1989-02'::text, '1989-03'::text, '1989-04'::text, '1989-05'::text, '1989-06'::text, '1989-07'::text, '1989-08'::text, '1989-09'::text, '1989-10'::text, '1989-11'::text, '1989-12'::text, '1990-01'::text, '1990-02'::text, '1990-03'::text, '1990-04'::text, '1990-05'::text, '1990-06'::text, '1990-07'::text, '1990-08'::text, '1990-09'::text, '1990-10'::text, '1990-11'::text, '1990-12'::text, '1991-01'::text, '1991-02'::text, '1991-03'::text, '1991-04'::text, '1991-05'::text, '1991-06'::text, '1991-07'::text, '1991-08'::text, '1991-09'::text, '1991-10'::text, '1991-11'::text, '1991-12'::text, '1992-01'::text, '1992-02'::text, '1992-03'::text, '1992-04'::text, '1992-05'::text, '1992-06'::text, '1992-07'::text, '1992-08'::text, '1992-09'::text, '1992-10'::text, '1992-11'::text, '1992-12'::text, '1993-01'::text, '1993-02'::text, '1993-03'::text, '1993-04'::text, '1993-05'::text, '1993-06'::text, '1993-07'::text, '1993-08'::text, '1993-09'::text, '1993-10'::text, '1993-11'::text, '1993-12'::text, '1994-01'::text, '1994-02'::text, '1994-03'::text, '1994-04'::text, '1994-05'::text, '1994-06'::text, '1994-07'::text, '1994-08'::text, '1994-09'::text, '1994-10'::text, '1994-11'::text, '1994-12'::text, '1995-01'::text, '1995-02'::text, '1995-03'::text, '1995-04'::text, '1995-05'::text, '1995-06'::text, '1995-07'::text, '1995-08'::text, '1995-09'::text, '1995-10'::text, '1995-11'::text, '1995-12'::text, '1996-01'::text, '1996-02'::text, '1996-03'::text, '1996-04'::text, '1996-05'::text, '1996-06'::text, '1996-07'::text, '1996-08'::text, '1996-09'::text, '1996-10'::text, '1996-11'::text, '1996-12'::text, '1997-01'::text, '1997-02'::text, '1997-03'::text, '1997-04'::text, '1997-05'::text, '1997-06'::text, '1997-07'::text, '1997-08'::text, '1997-09'::text, '1997-10'::text, '1997-11'::text, '1997-12'::text, '1998-01'::text, '1998-02'::text, '1998-03'::text, '1998-04'::text, '1998-05'::text, '1998-06'::text, '1998-07'::text, '1998-08'::text, '1998-09'::text, '1998-10'::text, '1998-11'::text, '1998-12'::text, '1999-01'::text, '1999-02'::text, '1999-03'::text, '1999-04'::text, '1999-05'::text, '1999-06'::text, '1999-07'::text, '1999-08'::text, '1999-09'::text, '1999-10'::text, '1999-11'::text, '1999-12'::text, '2000-01'::text, '2000-02'::text, '2000-03'::text, '2000-04'::text, '2000-05'::text, '2000-06'::text, '2000-07'::text, '2000-08'::text, '2000-09'::text, '2000-10'::text, '2000-11'::text, '2000-12'::text, '2001-01'::text, '2001-02'::text, '2001-03'::text, '2001-04'::text, '2001-05'::text, '2001-06'::text, '2001-07'::text, '2001-08'::text, '2001-09'::text, '2001-10'::text, '2001-11'::text, '2001-12'::text, '2002-01'::text, '2002-02'::text, '2002-03'::text, '2002-04'::text, '2002-05'::text, '2002-06'::text, '2002-07'::text, '2002-08'::text, '2002-09'::text, '2002-10'::text, '2002-11'::text, '2002-12'::text, '2003-01'::text, '2003-02'::text, '2003-03'::text, '2003-04'::text, '2003-05'::text, '2003-06'::text, '2003-07'::text, '2003-08'::text, '2003-09'::text, '2003-10'::text, '2003-11'::text, '2003-12'::text, '2004-01'::text, '2004-02'::text, '2004-03'::text, '2004-04'::text, '2004-05'::text, '2004-06'::text, '2004-07'::text, '2004-08'::text, '2004-09'::text, '2004-10'::text, '2004-11'::text, '2004-12'::text, '2005-01'::text, '2005-02'::text, '2005-03'::text, '2005-04'::text, '2005-05'::text, '2005-06'::text, '2005-07'::text, '2005-08'::text, '2005-09'::text, '2005-10'::text, '2005-11'::text, '2005-12'::text, '2006-01'::text, '2006-02'::text, '2006-03'::text, '2006-04'::text, '2006-05'::text, '2006-06'::text, '2006-07'::text, '2006-08'::text, '2006-09'::text, '2006-10'::text, '2006-11'::text, '2006-12'::text, '2007-01'::text, '2007-02'::text, '2007-03'::text, '2007-04'::text, '2007-05'::text, '2007-06'::text, '2007-07'::text, '2007-08'::text, '2007-09'::text, '2007-10'::text, '2007-11'::text, '2007-12'::text, '2008-01'::text, '2008-02'::text, '2008-03'::text, '2008-04'::text, '2008-05'::text, '2008-06'::text, '2008-07'::text, '2008-08'::text, '2008-09'::text, '2008-10'::text, '2008-11'::text, '2008-12'::text, '2009-01'::text, '2009-02'::text, '2009-03'::text, '2009-04'::text, '2009-05'::text, '2009-06'::text, '2009-07'::text, '2009-08'::text, '2009-09'::text, '2009-10'::text, '2009-11'::text, '2009-12'::text, '2010-01'::text, '2010-02'::text, '2010-03'::text, '2010-04'::text, '2010-05'::text, '2010-06'::text, '2010-07'::text, '2010-08'::text, '2010-09'::text, '2010-10'::text, '2010-11'::text, '2010-12'::text, '2011-01'::text, '2011-02'::text, '2011-03'::text, '2011-04'::text, '2011-05'::text, '2011-06'::text, '2011-07'::text, '2011-08'::text, '2011-09'::text, '2011-10'::text, '2011-11'::text, '2011-12'::text, '2012-01'::text, '2012-02'::text, '2012-03'::text, '2012-04'::text, '2012-05'::text, '2012-06'::text, '2012-07'::text, '2012-08'::text, '2012-09'::text, '2012-10'::text, '2012-11'::text, '2012-12'::text, '2013-01'::text, '2013-02'::text, '2013-03'::text, '2013-04'::text, '2013-05'::text, '2013-06'::text, '2013-07'::text, '2013-08'::text, '2013-09'::text, '2013-10'::text, '2013-11'::text, '2013-12'::text, '2014-01'::text, '2014-02'::text, '2014-03'::text, '2014-04'::text, '2014-05'::text, '2014-06'::text, '2014-07'::text, '2014-08'::text, '2014-09'::text, '2014-10'::text, '2014-11'::text, '2014-12'::text, '2015-01'::text, '2015-02'::text, '2015-03'::text, '2015-04'::text, '2015-05'::text, '2015-06'::text, '2015-07'::text, '2015-08'::text, '2015-09'::text, '2015-10'::text, '2015-11'::text, '2015-12'::text, '2016-01'::text, '2016-02'::text, '2016-03'::text, '2016-04'::text, '2016-05'::text, '2016-06'::text, '2016-07'::text, '2016-08'::text, '2016-09'::text, '2016-10'::text, '2016-11'::text, '2016-12'::text, '2017-01'::text, '2017-02'::text, '2017-03'::text, '2017-04'::text, '2017-05'::text, '2017-06'::text, '2017-07'::text, '2017-08'::text, '2017-09'::text, '2017-10'::text, '2017-11'::text, '2017-12'::text, '2018-01'::text, '2018-02'::text, '2018-03'::text, '2018-04'::text, '2018-05'::text, '2018-06'::text, '2018-07'::text, '2018-08'::text, '2018-09'::text, '2018-10'::text, '2018-11'::text, '2018-12'::text, '2019-01'::text, '2019-02'::text, '2019-03'::text, '2019-04'::text, '2019-05'::text, '2019-06'::text, '2019-07'::text, '2019-08'::text, '2019-09'::text, '2019-10'::text, '2019-11'::text, '2019-12'::text, '2020-01'::text, '2020-02'::text, '2020-03'::text, '2020-04'::text, '2020-05'::text, '2020-06'::text, '2020-07'::text, '2020-08'::text, '2020-09'::text, '2020-10'::text, '2020-11'::text, '2020-12'::text, '2021-01'::text, '2021-02'::text, '2021-03'::text, '2021-04'::text, '2021-05'::text, '2021-06'::text, '2021-07'::text, '2021-08'::text, '2021-09'::text, '2021-11'::text])) AND (victima.id_organizacion = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 101, 102, 103])) AND (victima.id_profesion = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 101, 102, 103, 104, 105, 106, 108, 109, 110, 111, 112, 113, 114, 115, 116])) AND (victima.id_rangoedad = ANY (ARRAY[1, 2, 3, 4, 5, 6])) AND (victima.id_sectorsocial = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 101, 102, 103, 104, 105, 106, 107])) AND (persona.sexo = ANY (ARRAY['F'::bpchar, 'M'::bpchar, 'S'::bpchar])) AND (victima.id_vinculoestado = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 42, 43, 101])) AND (persona.id = victima.id_persona));


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
    cben1.id_filiacion,
    ubicacion.id_departamento,
    departamento.id_deplocal AS departamento_divipola,
    departamento.nombre AS departamento_nombre,
    ubicacion.id_municipio,
    municipio.id_munlocal AS municipio_divipola,
    municipio.nombre AS municipio_nombre,
    ubicacion.id_clase,
    clase.id_clalocal AS clase_divipola,
    clase.nombre AS clase_nombre
   FROM (((((public.cben1
     JOIN public.sivel2_gen_caso caso ON ((cben1.id_caso = caso.id)))
     LEFT JOIN public.sip_ubicacion ubicacion ON ((caso.ubicacion_id = ubicacion.id)))
     LEFT JOIN public.sip_departamento departamento ON ((ubicacion.id_departamento = departamento.id)))
     LEFT JOIN public.sip_municipio municipio ON ((ubicacion.id_municipio = municipio.id)))
     LEFT JOIN public.sip_clase clase ON ((ubicacion.id_clase = clase.id)))
  GROUP BY cben1.id_caso, cben1.id_victima, cben1.id_persona, cben1.npersona, cben1.id_filiacion, ubicacion.id_departamento, departamento.id_deplocal, departamento.nombre, ubicacion.id_municipio, municipio.id_munlocal, municipio.nombre, ubicacion.id_clase, clase.id_clalocal, clase.nombre;


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
-- Name: combatiente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.combatiente (
    id integer DEFAULT nextval('public.combatiente_seq'::regclass) NOT NULL,
    nombre character varying(100) NOT NULL,
    alias character varying(100),
    edad integer,
    sexo character(1) NOT NULL,
    id_resagresion integer NOT NULL,
    id_profesion integer,
    id_rangoedad integer,
    id_filiacion integer,
    id_sectorsocial integer,
    id_organizacion integer,
    id_vinculoestado integer,
    id_caso integer,
    organizacionarmada integer,
    CONSTRAINT combatiente_edad_check CHECK (((edad IS NULL) OR (edad >= 0))),
    CONSTRAINT combatiente_sexo_check CHECK (((sexo = 'S'::bpchar) OR (sexo = 'M'::bpchar) OR (sexo = 'F'::bpchar)))
);


--
-- Name: combatiente_presponsable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.combatiente_presponsable (
    id_p_responsable integer NOT NULL,
    id_combatiente integer NOT NULL
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
    categoria.nombre AS categoria,
    ubicacion.id_departamento,
    departamento.id_deplocal AS departamento_divipola,
    initcap((departamento.nombre)::text) AS departamento_nombre
   FROM (((((((public.sivel2_gen_acto acto
     JOIN public.sivel2_gen_caso caso ON ((acto.id_caso = caso.id)))
     JOIN public.sivel2_gen_categoria categoria ON ((acto.id_categoria = categoria.id)))
     JOIN public.sivel2_gen_supracategoria supracategoria ON ((categoria.supracategoria_id = supracategoria.id)))
     JOIN public.sivel2_gen_victima victima ON (((victima.id_persona = acto.id_persona) AND (victima.id_caso = caso.id))))
     JOIN public.sip_persona persona ON ((persona.id = acto.id_persona)))
     LEFT JOIN public.sip_ubicacion ubicacion ON ((caso.ubicacion_id = ubicacion.id)))
     LEFT JOIN public.sip_departamento departamento ON ((ubicacion.id_departamento = departamento.id)))
  WHERE (categoria.id = ANY (ARRAY[427, 527, 777, 197, 297, 397, 196, 776, 526, 426, 396, 296, 55, 15, 45, 25, 35, 73, 65, 92, 40, 50, 67, 801, 90, 37, 46, 26, 57, 16, 80, 85, 66, 64, 703, 706, 18, 28, 49, 59, 38, 501, 401, 904, 231, 331, 17, 402, 502, 705, 62, 104, 906, 713, 101, 11, 21, 76, 302, 27, 34, 902, 102, 903, 14, 24, 301, 30, 20, 10, 192, 522, 392, 422, 292, 772, 63, 93, 425, 775, 395, 525, 295, 195, 714, 78, 424, 394, 194, 524, 294, 774, 89, 905, 86, 701, 68, 241, 341, 141, 715, 704, 702, 43, 23, 53, 33, 13, 88, 98, 84, 709, 711, 707, 708, 710, 87, 97, 717, 917, 716, 916, 91, 95, 718, 393, 773, 193, 423, 523, 293, 48, 58, 75, 69, 41, 74, 22, 12, 56, 72, 47, 36, 421, 771, 391, 291, 191, 521, 39, 19, 420, 29, 77, 520, 712]));


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
    fechadeshabilitacion date,
    tipoorg_id integer DEFAULT 2 NOT NULL
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
-- Name: sip_tipoorg; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_tipoorg (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: sip_tipoorg_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_tipoorg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_tipoorg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_tipoorg_id_seq OWNED BY public.sip_tipoorg.id;


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
-- Name: sip_vereda; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_vereda (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    municipio_id integer,
    verlocal_id integer,
    observaciones character varying(5000),
    latitud double precision,
    longitud double precision,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: sip_vereda_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_vereda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_vereda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_vereda_id_seq OWNED BY public.sip_vereda.id;


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
          WHERE ((sivel2_gen_conscaso.caso_id IN ( SELECT sivel2_gen_caso.id
                   FROM public.sivel2_gen_caso)) AND (sivel2_gen_conscaso.q @@ plainto_tsquery('spanish'::regconfig, public.unaccent('ada'::text))))
          ORDER BY sivel2_gen_conscaso.ubicaciones, sivel2_gen_conscaso.caso_id))
  ORDER BY conscaso.ubicaciones, conscaso.caso_id
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
-- Name: sip_tipoorg id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tipoorg ALTER COLUMN id SET DEFAULT nextval('public.sip_tipoorg_id_seq'::regclass);


--
-- Name: sip_trivalente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_trivalente ALTER COLUMN id SET DEFAULT nextval('public.sip_trivalente_id_seq'::regclass);


--
-- Name: sip_ubicacionpre id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacionpre ALTER COLUMN id SET DEFAULT nextval('public.sip_ubicacionpre_id_seq'::regclass);


--
-- Name: sip_vereda id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_vereda ALTER COLUMN id SET DEFAULT nextval('public.sip_vereda_id_seq'::regclass);


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
-- Name: combatiente combatiente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.combatiente
    ADD CONSTRAINT combatiente_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_frontera frontera_caso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_frontera
    ADD CONSTRAINT frontera_caso_pkey PRIMARY KEY (id_frontera, id_caso);


--
-- Name: sivel2_gen_caso_usuario funcionario_caso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_usuario
    ADD CONSTRAINT funcionario_caso_pkey PRIMARY KEY (id_usuario, id_caso);


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
-- Name: combatiente_presponsable p_responsable_agrede_combatiente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.combatiente_presponsable
    ADD CONSTRAINT p_responsable_agrede_combatiente_pkey PRIMARY KEY (id_p_responsable, id_combatiente);


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
-- Name: sip_tipoorg sip_tipoorg_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tipoorg
    ADD CONSTRAINT sip_tipoorg_pkey PRIMARY KEY (id);


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
-- Name: sip_vereda sip_vereda_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_vereda
    ADD CONSTRAINT sip_vereda_pkey PRIMARY KEY (id);


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
-- Name: sivel2_gen_caso_presponsable $1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT "$1" FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


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
-- Name: sivel2_gen_caso_presponsable $2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT "$2" FOREIGN KEY (id_presponsable) REFERENCES public.sivel2_gen_presponsable(id);


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
-- Name: combatiente_presponsable $2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.combatiente_presponsable
    ADD CONSTRAINT "$2" FOREIGN KEY (id_combatiente) REFERENCES public.combatiente(id);


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
-- Name: sivel2_gen_antecedente_caso antecedente_caso_id_antecedente_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_caso
    ADD CONSTRAINT antecedente_caso_id_antecedente_fkey1 FOREIGN KEY (id_antecedente) REFERENCES public.sivel2_gen_antecedente(id);


--
-- Name: sivel2_gen_antecedente_caso antecedente_caso_id_caso_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_caso
    ADD CONSTRAINT antecedente_caso_id_caso_fkey1 FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


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
-- Name: sivel2_gen_caso_etiqueta caso_etiqueta_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id);


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
-- Name: sivel2_gen_caso_usuario caso_usuario_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_usuario
    ADD CONSTRAINT caso_usuario_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id);


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
('20211010164634'),
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
('20220214232150'),
('20220215095957'),
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
('20220422190546'),
('20220428145059');


